function [img,ccdimginfo] = create_IMM_dataMatrix(varargin)
%help:create_IMM_dataMatrix(varargin)
%Returns: img as #pixels * #frames as arg 1
%             ccdimginfo as arg 2
%
if (nargin < 2)
    error('Correct Usage: create_IMM_dataMatrix(metadatafilename,params');
end
%%
tic;
batchinfoname = varargin{1};
XPCSparams = varargin{2};

if ~isempty(whos('global','ccdimginfo'))
    evalin('base','global ccdimginfo'); %%to make it global in base workspace
end
%%
%conditional execution based on metadata file type: batchinfo/hdf5
if ~isempty(regexp(batchinfoname,'batchinfo','once')) %is a batchinfo file
    
    ccdimginfo = convert_batchinfo_loadhdf5MetaData(batchinfoname);
        
    try
        stride_frames = ccdimginfo.xpcs.stride_frames;
    catch
        stride_frames = 1;
    end

    try
        avg_frames = ccdimginfo.xpcs.avg_frames;
    catch
        avg_frames = 1;
    end
    
    ccdimginfo = getimgmap(ccdimginfo);
    
    %read in user mask
    if isfield(XPCSparams,'usermask') && ~isempty(XPCSparams.usermask)
        usermask = logical(XPCSparams.usermask);
    else
        usermask = true(ccdimginfo.detector.rows,ccdimginfo.detector.cols);
    end
    %check that usermask has the same dims as the image
    if (ccdimginfo.detector.kinetics.mode == 0)
        if ( (size(usermask,1) ~= ccdimginfo.detector.rows) && ...
                (size(usermask,2) ~= ccdimginfo.detector.rows) )
            error('usermask provided is not the same size as the data');
        end
    else %kinetics mode
        if ( (size(usermask,1) ~= ccdimginfo.detector.kinetics.window_size) && ...
                (size(usermask,2) ~= ccdimginfo.detector.kinetics.window_size) )
            error('usermask provided is not the same size as the data');
        end
    end
    ccdimginfo.mask.usermask = logical(usermask);

    %compute partition maps and bins
    if isfield(XPCSparams,'partition_name') && ~isempty(XPCSparams.partition_name)
        ccdimginfo.partition.name = XPCSparams.partition_name;
    end
    
    if isfield(XPCSparams,'partition_static') && ~isempty(XPCSparams.partition_static)
        ccdimginfo.partition.snpt = XPCSparams.partition_static;
    end

    if isfield(XPCSparams,'partition_dynamic') && ~isempty(XPCSparams.partition_dynamic)
        ccdimginfo.partition.dnpt = XPCSparams.partition_dynamic;
    end

    ccdimginfo = getimgpartition(ccdimginfo);
    ccdimginfo = getimgpartitionindex(ccdimginfo);
    
elseif H5F.is_hdf5(batchinfoname) %is a hdf file
    
    ccdimginfo = loadhdf5MetaData(batchinfoname);
        
    if ((nargin >= 2) && ~isempty(varargin{3}))
        endpoint = varargin{3};
    else
        endpoint = '/xpcs';
    end
    
    try
        stride_frames = h5read(batchinfoname,[endpoint,'/stride_frames']);
    catch
        stride_frames = 1;
    end

    try
        avg_frames = h5read(batchinfoname,[endpoint,'/avg_frames']);
    catch
        avg_frames = 1;
    end
    
    try
        usermask = logical(transpose(double(h5read(batchinfoname,[endpoint,'/dqmap']))));
    catch
        usermask = true(ccdimginfo.detector.rows,ccdimginfo.detector.cols);
    end
    ccdimginfo.mask.usermask = logical(usermask);
    
    %read partition information from hdf file
    tmp = hdf2ccdpartition(batchinfoname,endpoint); %function defined below in this file
    ccdimginfo.partition.sindexmap = tmp.partition.sindexmap;
    ccdimginfo.partition.dindexmap = tmp.partition.dindexmap;
    ccdimginfo.partition.smeanmap = tmp.partition.smeanmap;
    ccdimginfo.partition.dmeanmap = tmp.partition.dmeanmap;
    ccdimginfo.partition.snpt = tmp.partition.snpt;
    ccdimginfo.partition.dnpt = tmp.partition.dnpt;
    clear tmp;
end
%%
%overwrite some params as needed
if isfield(XPCSparams,'start_frame') && ~isempty(XPCSparams.start_frame)
    ccdimginfo.xpcs.data_begin_todo(1)=XPCSparams.start_frame;
end

if isfield(XPCSparams,'end_frame') && ~isempty(XPCSparams.end_frame)
    ccdimginfo.xpcs.data_end_todo(1)=XPCSparams.end_frame;
end

if isfield(XPCSparams,'dark_start_frame') && ~isempty(XPCSparams.dark_start_frame)
    ccdimginfo.xpcs.dark_begin_todo(1)=XPCSparams.dark_start_frame;
end

if isfield(XPCSparams,'dark_end_frame') && ~isempty(XPCSparams.dark_end_frame)
    ccdimginfo.xpcs.dark_end_todo(1)=XPCSparams.dark_end_frame;
end

if isfield(XPCSparams,'stride_frames') && ~isempty(XPCSparams.stride_frames)
    [ccdimginfo.xpcs.stride_frames,stride_frames]=deal(XPCSparams.stride_frames);
    
end

if isfield(XPCSparams,'avg_frames') && ~isempty(XPCSparams.avg_frames)
    [ccdimginfo.xpcs.avg_frames,avg_frames]=deal(XPCSparams.avg_frames);
end

if isfield(XPCSparams,'delays_per_level') && ~isempty(XPCSparams.delays_per_level)
    ccdimginfo.xpcs.dpl = XPCSparams.delays_per_level;
else
    ccdimginfo.xpcs.dpl = 4; %default
end
%%
%collect some params for reading from IMM file
COMPRESSION = isempty(regexp(ccdimginfo.xpcs.compression{1},'DISABLED','once'));

data_begin_todo=ccdimginfo.xpcs.data_begin_todo;
data_end_todo=ccdimginfo.xpcs.data_end_todo;

dark_begin_todo=ccdimginfo.xpcs.dark_begin_todo;
dark_end_todo=ccdimginfo.xpcs.dark_end_todo;

LLD=ccdimginfo.xpcs.lld;
rms_multiplier=ccdimginfo.xpcs.rms_multiplier;

imm_filename = ccdimginfo.xpcs.input_file_local{1};

try
    numrows = double(ccdimginfo.bin.detector.rows);
    numcols = double(ccdimginfo.bin.detector.cols);
catch
    numrows = double(ccdimginfo.detector.rows);
    numcols = double(ccdimginfo.detector.cols);
end

%some more fields from /xpcs
ccdimginfo.xpcs.static_mean_window_size = ...
    max(floor((data_end_todo - data_begin_todo + 1)/10),2);
%%
frames_list = double(data_begin_todo:stride_frames:data_end_todo);
n2tframes=numel(frames_list);
%%
if (COMPRESSION == 0)
    %%Compute dark averages
    disp('Collecting Dark images into memory...');
    dk=collectimg(imm_filename,dark_begin_todo,dark_end_todo);
    disp('Averaging darks...');
    dkavg=mean(dk,3);
    %Compute std dev of the dark images
    dk=permute(dk,[3,1,2]);
    dkstd=squeeze(std(dk));
    clear dk;
    %%%% compute LLD threshold matrix combining scalar LLD and pixel specific
    %%%% RMS*sigma
    dark_threshold_matrix = dkstd * rms_multiplier + LLD;
    clear LLD dkstd rms_multiplier
    
    f=openmultiimm(imm_filename,1);
    dlen = ones(data_end_todo,1)*f.header{24,2};
    pixel_bytes = f.header{17,2};
    clear f;
    %read for all the frames including dark
    SByte = ((1:data_end_todo)-1) * (1024+(dlen(1)*pixel_bytes));
    %trim to only the frames needed for processing
    SByte_frames_to_process = SByte(frames_list);
    
    %%%%Allocate memory for the frames
    img = zeros(numrows*numcols, n2tframes);
    
else %%COMPRESSION == 1
    dkavg=[];
    dark_threshold_matrix=[];
    fprintf('Indexing Compressed IMM file to make the file reading faster and parallel...\n\n');
    tic;
    [SByte,dlen]=indexcompressedmultiimm(imm_filename,data_end_todo);
    IMM_indexing_time=toc;
    fprintf('Indexing Compressed IMM file took %d seconds..\n\n',round(IMM_indexing_time));
    SByte_frames_to_process = SByte(frames_list);
    %%%%Allocate memory for the frames
    img = spalloc(numrows*numcols,n2tframes,max(dlen));
    
end
%%
%read time stamps from IMM file (works only for PI and Coreco frame grabber
%stuff, rest of the detectors do not have timestamps for now)
ccdimginfo.xpcs.timeStamps{1} = immelapsed(imm_filename,data_begin_todo,data_end_todo,SByte);
%%
disp('Starting to Read IMM frames in parallel');
swbinX = ccdimginfo.bin.swbinX;
swbinY = ccdimginfo.bin.swbinY;

%find a rectangular boundary that includes the usermask
[tmpx,tmpy]=find(usermask);
tmpX = [min(tmpx),max(tmpx)];
tmpY = [min(tmpy),max(tmpy)];
rectangular_usermask = usermask(tmpX(1):tmpX(2),tmpY(1):tmpY(2));

kinetics_mode = ccdimginfo.detector.kinetics.mode;

parfor ii=1:n2tframes
    data = openmultiimm(imm_filename,frames_list(ii),SByte_frames_to_process(ii));
    data = data.imm;
    
    if (COMPRESSION == 0)
        data = double(data - dkavg);
        data(data <= dark_threshold_matrix) = 0;
        
        data = binimg(data,swbinX,swbinY);
        
        if (~kinetics_mode)
            data = data .* cast(usermask,'like',data);
        end
        
        data = data(:);
    elseif (COMPRESSION == 1)
        data = binimg(data,swbinX,swbinY);
        data = data .* cast(usermask,'like',data);
        data=sparse(double(data(:)));
    end
    
    img(:,ii) = data;
end

%bin frames in time if specified
if (avg_frames > 1)
    img = Iqt_bin_data(img,avg_frames);
end

if ~issparse(img)
    img = single(img);
end
%%
toc;
disp('img matrix: #pixels * #frames in double prec and ccdimginfo is returned');
end

function tmp = hdf2ccdpartition(batchinfoname,endpoint)

tmp.partition.sindexmap = transpose(h5read(batchinfoname,[endpoint,'/sqmap']));
tmp.partition.dindexmap = transpose(h5read(batchinfoname,[endpoint,'/dqmap']));


tmp.partition.smeanmap(:,1) = h5read(batchinfoname,[endpoint,'/sqlist']);
tmp.partition.smeanmap(:,2) = h5read(batchinfoname,[endpoint,'/sphilist']);
tmp.partition.dmeanmap(:,1) = h5read(batchinfoname,[endpoint,'/dqlist']);
tmp.partition.dmeanmap(:,2) = h5read(batchinfoname,[endpoint,'/dphilist']);


try
    tmp.partition.snpt(1) = numel(h5read(batchinfoname,[endpoint,'/sqspan']))-1;
catch
    %tmp.partition.snpt(1) = numel(h5read(batchinfoname,[endpoint,'/sqlist']));
end

try
    tmp.partition.snpt(2) = numel(h5read(batchinfoname,[endpoint,'/sphispan']))-1;
catch
    %tmp.partition.snpt(2) = numel(h5read(batchinfoname,[endpoint,'/sphilist']));
end

try
    tmp.partition.dnpt(1) = numel(h5read(batchinfoname,[endpoint,'/dqspan']))-1;
catch
    %tmp.partition.dnpt(1) = numel(h5read(batchinfoname,[endpoint,'/dqlist']));
end

try
    tmp.partition.dnpt(2) = numel(h5read(batchinfoname,[endpoint,'/dphispan']))-1;
catch
    %tmp.partition.dnpt(2) = numel(h5read(batchinfoname,[endpoint,'/dphilist']));
end

try
    tmp.xpcs.static_mean_window_size = h5read(batchinfoname,[endpoint,'/static_mean_window_size']);
catch
end
% try
%     tmp.bin.swbinX = double(h5read(batchinfoname,'/xpcs/swbinX'));
%     tmp.bin.swbinY = double(h5read(batchinfoname,'/xpcs/swbinY'));
% catch
%     tmp.bin.swbinX = 1;
%     tmp.bin.swbinY = 1;
% end

% tmp.detector.rows = double(floor(double(h5read(batchinfoname,'/measurement/instrument/detector/y_dimension'))/...
%     double(tmp.bin.swbinY)));
% tmp.detector.cols = double(floor(h5read(batchinfoname,'/measurement/instrument/detector/x_dimension')/...
%     double(tmp.bin.swbinX)));


end
