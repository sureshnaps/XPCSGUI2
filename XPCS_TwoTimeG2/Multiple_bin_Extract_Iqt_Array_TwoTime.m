function [AvgData,I0t,Iqt,SG_smoothed_data] = Multiple_bin_Extract_Iqt_Array_TwoTime(varargin)
% Usage:
% [AvgData,I0t,Iqt] = Extract_Iqt_Array_TwoTime(imm_filename,data_begin_todo,...
% data_end_todo,stride_frames,dkavg,dqmap_index_all,dqmap_index_qbin,SByte,COMPRESSION)

TwoTimeInfo=varargin{1};
imm_filename=varargin{2};
data_begin_todo=varargin{3};
data_end_todo=varargin{4};
stride_frames=varargin{5};
dkavg=varargin{6};
dqmap_index_all=varargin{7};
dqmap_index_qbin=varargin{8};
sqmap=varargin{9};
SByte=varargin{10};
COMPRESSION=varargin{11};
dark_threshold_matrix=varargin{12};
Num_CPU_Cores=varargin{13};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (stride_frames == 0)
    stride_frames = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
frames_list = double(data_begin_todo:stride_frames:data_end_todo);
n2tframes=numel(frames_list);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (COMPRESSION) %pick only the frames being used to compute
    SByte = SByte(frames_list);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AvgData=zeros(size(dqmap_index_all),'double');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
binpixlist = cell(1,numel(unique(nonzeros(dqmap_index_qbin))));
dqmap_bins_unique = unique(nonzeros(dqmap_index_qbin));
for jj=1:numel(unique(nonzeros(dqmap_index_qbin)))
    binpixlist{jj} = find(dqmap_index_qbin==dqmap_bins_unique(jj));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NumPixels_bin = max(cellfun(@numel, binpixlist));
Iqt = NaN(numel(dqmap_bins_unique), NumPixels_bin, n2tframes,'single');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%kludge for parfor to work with the if-else condition
if isempty(SByte)
    SByte=NaN(1,n2tframes);
end

if isempty(dark_threshold_matrix)
    dark_threshold_matrix=0;
end

if isempty(dkavg)
    dkavg=0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    if isempty(gcp('nocreate'))
        disp('Setting up a Parallel Pool of workers');
        parpool(Num_CPU_Cores);
        disp('Done Setting up a Parallel Pool of workers');
    end
catch
    disp('No Parallel processing toolbox found. Proceeding with a serial implementation');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (TwoTimeInfo.Compute_SG_per_frame == 1)
    Compute_SG_per_frame=1;
    SG_smoothed_data = zeros(size(AvgData,1),size(AvgData,2),n2tframes,'single');
else
    Compute_SG_per_frame = 0;
    SG_smoothed_data=zeros(size(AvgData),'single');
end
hdf5_filename = TwoTimeInfo.hdf5_filename;

%%collect intensities from pixels vs time that belong to the specified qphi-bin
fprintf('Creating Iqt array - pixel list vs time for 2-time correlation\n');                                                                                    
parfor ii=1:n2tframes
    Iqt_temp = Iqt(:,:,ii); %temporary variable which has the 3rd dimensional slice of Iqt
    
    if (COMPRESSION == 0)
        data = openfile(imm_filename,frames_list(ii));
        data = data.imm;
        data = data - dkavg;
        data(data <= dark_threshold_matrix) = 0; %%need to use LLD+sigma*std(darks) here
    elseif (COMPRESSION == 1)
        data = openfile(imm_filename,frames_list(ii),SByte(ii));
        data = data.imm;
    end
    
    if (Compute_SG_per_frame == 1)
        SG_smoothed_data(:,:,ii)=qparallel_avg_SG(hdf5_filename,data);
    end
    
    AvgData = AvgData + data;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%compute Isqt - 2nd level of Mark's norm. - not sure if this is needed
    %         Isqt(:,ii)=Calculate_I_Sq_t_twotime(data,sqmap);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%compute I0t - the average of whole image per frame
    I0t(ii)=mean(data(dqmap_index_all));
    
    %the body of "for" loop becomes a black-box with respect to "parfor"
    %"parfor" need not know what is happening inside "for"(tech. support)
    for jj=1:numel(dqmap_bins_unique)
        tmp=NaN(1,NumPixels_bin);
        tmp(1:numel(binpixlist{jj})) = data(binpixlist{jj});
        Iqt_temp(jj,:)=tmp; % Work on the temporary variable inside "for"
    end
    Iqt(:,:,ii)=Iqt_temp; % assign the populated values back to the original variable
end

AvgData = AvgData ./n2tframes;

end
