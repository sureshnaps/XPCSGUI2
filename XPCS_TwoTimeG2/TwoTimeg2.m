function TwoTimeInfo = TwoTimeg2(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TwoTimeInfo=varargin{1};

try
    xpcs_entry = TwoTimeInfo.xpcs_entry;
catch
    xpcs_entry = '/xpcs';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hdf5_filename=TwoTimeInfo.hdf5_filename;
qmap_filename=TwoTimeInfo.qmap_filename;
qphi_bin_to_process=TwoTimeInfo.qphi_bin_to_process;
stride_frames=TwoTimeInfo.stride_frames;
frames_bin_size = TwoTimeInfo.frames_bin_size;
Num_CPU_Cores = TwoTimeInfo.Num_CPU_Cores;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(TwoTimeInfo.Num_CPU_Cores)
    Num_CPU_Cores=8;
end

if isempty(TwoTimeInfo.stride_frames)
    stride_frames=1;
end

if isempty(TwoTimeInfo.frames_bin_size)
    frames_bin_size=1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ( (stride_frames <= 0) || isnan(stride_frames) || isempty(stride_frames) )
    stride_frames = 1;
end
if ( (frames_bin_size <= 0) || isnan(frames_bin_size) || isempty(frames_bin_size) )
    frames_bin_size = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imm_filename = h5read(hdf5_filename,[xpcs_entry,'/input_file_local']);
if iscellstr(imm_filename)
    imm_filename = imm_filename{1};
end

[pre_filepath,file_name,file_ext]=fileparts(imm_filename);
[~,folder_name,~]=fileparts(pre_filepath);
if isempty(folder_name)
    folder_name=h5read(hdf5_filename,'/measurement/instrument/acquisition/data_folder');
    if iscellstr(folder_name)
        folder_name = folder_name{1};
        if folder_name(end)=='/'
            folder_name = folder_name(1:end-1);
        end
    end
end
imm_filename = fullfile(TwoTimeInfo.parent_data_folder,folder_name,[file_name,file_ext]);

if ( exist(imm_filename,'file') ~=2 ) %%check for the existence of the new file path again
    fprintf('Raw Data IMM file %s name does not seem to exist',imm_filename);
    return;
end
compression_value = h5read(hdf5_filename,[xpcs_entry,'/compression']);
if iscellstr(compression_value)
    compression_value = compression_value{1};
end
COMPRESSION = ~isempty(regexp(compression_value,'ENABLED','once'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(TwoTimeInfo,'dark_begin') && ~isempty(TwoTimeInfo.dark_begin)
    dark_begin_todo = TwoTimeInfo.dark_begin;
else
    dark_begin_todo = double(h5read(hdf5_filename,[xpcs_entry,'/dark_begin_todo']));
end

if isfield(TwoTimeInfo,'dark_end') && ~isempty(TwoTimeInfo.dark_end)
    dark_end_todo = TwoTimeInfo.dark_end;
else
    dark_end_todo = double(h5read(hdf5_filename,[xpcs_entry,'/dark_end_todo']));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (COMPRESSION == 0)
    LLD=double(h5read(hdf5_filename,[xpcs_entry,'/lld']));
    rms_multiplier=double(h5read(hdf5_filename,[xpcs_entry,'/sigma']));
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
    
    SByte=[];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (COMPRESSION == 1)
    dkavg=[];
    dark_threshold_matrix=[];
%     fprintf('Indexing Compressed IMM file to make the file reading faster and parallel...\n');
    tic;
    SByte=indexcompressedmultiimm(imm_filename);
    IMM_indexing_time=toc;
    fprintf('Indexing Compressed IMM file took %d seconds..\n',round(IMM_indexing_time));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TwoTimeInfo.IMM_Frame_Markers=SByte;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf('Reading qmap and selecting q-bin pixel indices...\n\n');
%%read dynamic qmap from qmap_file if defined, else use hdf file
try
    dqmap=transpose(h5read(qmap_filename,'/data/dynamicMap'));
    sqmap=transpose(h5read(qmap_filename,'/data/staticMap'));
    dqmap(dqmap==-1)=0;
    sqmap(sqmap==-1)=0;
catch
    dqmap=transpose(h5read(hdf5_filename,[xpcs_entry,'/dqmap']));
    sqmap=transpose(h5read(hdf5_filename,[xpcs_entry,'/sqmap']));
    dqmap(dqmap==-1)=0;
    sqmap(sqmap==-1)=0;
end

%%get logical map of all the pixels
dqmap_index_all= (dqmap > 0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%get logical map of all the pixels in the q-bin (typically 10K-75K pixels)
% dqmap_index_qbin=(dqmap == qphi_bin_to_process);
%skipped using logical map as it does not allow multiple bin extraction
dqmap_index_qbin=zeros(size(dqmap));
for jj=1:numel(qphi_bin_to_process)
    dqmap_index_qbin=dqmap_index_qbin+(dqmap == qphi_bin_to_process(jj))*qphi_bin_to_process(jj);
end
TwoTimeInfo.dqmap_index_qbin = dqmap_index_qbin;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning('OFF','MATLAB:mir_warning_maybe_uninitialized_temporary');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(TwoTimeInfo,'data_begin') && ~isempty(TwoTimeInfo.data_begin)
    data_begin_todo = TwoTimeInfo.data_begin;
else
    data_begin_todo = double(h5read(hdf5_filename,[xpcs_entry,'/data_begin_todo']));
end

if isfield(TwoTimeInfo,'data_end') && ~isempty(TwoTimeInfo.data_end)
    data_end_todo = TwoTimeInfo.data_end;
else
    data_end_todo = double(h5read(hdf5_filename,[xpcs_entry,'/data_end_todo']));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%read time stamps from IMM file (works only for PI and Coreco frame grabber
%stuff, rest of the detectors do not have timestamps for now)
timestamps{1} = immelapsed(imm_filename,data_begin_todo,data_end_todo,SByte);
%%
%find frame spacing from time stamps or exposure time, as deemed appropriate
framespacinginfo.xpcs.timeStamps = timestamps;
framespacinginfo.detector.manufacturer = h5read(hdf5_filename,'/measurement/instrument/detector/manufacturer');
framespacinginfo.detector.adu_per_photon=h5read(hdf5_filename,'/measurement/instrument/detector/adu_per_photon');
framespacinginfo.detector.exposure_time=h5read(hdf5_filename,'/measurement/instrument/detector/exposure_time');
framespacinginfo.xpcs.stride_frames = stride_frames;
framespacinginfo.xpcs.avg_frames = frames_bin_size;
TwoTimeInfo.framespacing = compute_framespacing(framespacinginfo);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Fill the Iqt array with time sequence data of the pixels from the q-bin
tic;
[AvgData,I0t,Iqt,SG_smoothed_data] = Multiple_bin_Extract_Iqt_Array_TwoTime(TwoTimeInfo,imm_filename,data_begin_todo,data_end_todo,stride_frames,...
    dkavg,dqmap_index_all,dqmap_index_qbin,sqmap,SByte,COMPRESSION,dark_threshold_matrix,Num_CPU_Cores);
%Note: Iqt will be a 3-D array with dims:
%(num bins * num largest num pixels * num frames)
Iqt_array_extract_time = toc;
fprintf('Extracting Iq array took %d seconds..\n',round(Iqt_array_extract_time));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (TwoTimeInfo.Compute_SG_per_frame == 1)
    TwoTimeInfo.SG_smoothed_data = SG_smoothed_data;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% store relevant fields in the TwoTimeInfo struct
TwoTimeInfo.AvgData=AvgData;
TwoTimeInfo.I0t=I0t;
%convert 3D Iqt array with lots of NaN's into a cell array with no NaNs
Iqt=Convert_Iqt_3d_to_cell(Iqt,dqmap_index_qbin,qphi_bin_to_process);
TwoTimeInfo.Iqt=Iqt;
clear AvgData I0t;
clear Iqt;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
