function tmp2TInfo = Preview_and_Download_TwoTime_hdf(varargin)

full_hdf5_filename=varargin{1};

if (nargin >1)
    TwoTime_Matrices_To_Download = varargin{2};
else
    TwoTime_Matrices_To_Download = '';
end

if (nargin > 2)
        hdf5_group_name=varargin{3};
else
    hdf5_group_name = '/xpcs';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
result_group_location=deblank(h5read(full_hdf5_filename,[hdf5_group_name,'/output_data']));
if iscellstr(result_group_location)
    result_group_location=result_group_location{1};
    result_group_location=cellstr(result_group_location);
    result_group_location=result_group_location{1};
end
hdf5_group_2T_name=[result_group_location,'/TwoTime'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    tmp2TInfo.dqmap = transpose(h5read(full_hdf5_filename,[hdf5_group_name,'/dqmap']));
catch
    tmp2TInfo.dqmap = [];
end
dqmap = tmp2TInfo.dqmap;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    tmp2TInfo.qphi_bin_to_process = int32(h5read(full_hdf5_filename,[hdf5_group_name,'/qphi_bin_to_process']));
catch
    tmp2TInfo.qphi_bin_to_process = [];
end
qphi_bin_to_process = tmp2TInfo.qphi_bin_to_process;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dqmap_index_qbin=zeros(size(dqmap),'like',dqmap);
for jj=1:numel(qphi_bin_to_process)
    dqmap_index_qbin=dqmap_index_qbin+cast(cast((dqmap == qphi_bin_to_process(jj)),'like',qphi_bin_to_process)*qphi_bin_to_process(jj),'like',dqmap_index_qbin);
end

try
    tmp2TInfo.dqmap_index_qbin = dqmap_index_qbin;
catch
    tmp2TInfo.dqmap_index_qbin = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    tmp2TInfo.stride_frames = h5read(full_hdf5_filename,[hdf5_group_name,'/stride_frames']);    
catch
    tmp2TInfo.stride_frames = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    tmp2TInfo.frames_bin_size = h5read(full_hdf5_filename,[hdf5_group_name,'/frames_bin_size']);    
catch
    tmp2TInfo.frames_bin_size = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    tmp2TInfo.I0t = h5read(full_hdf5_filename,[hdf5_group_name,'/frameSum']);    
catch
    tmp2TInfo.I0t = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    tmp2TInfo.AvgData = transpose(h5read(full_hdf5_filename,[hdf5_group_name,'/pixelSum']));    
catch
    tmp2TInfo.AvgData = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    tmp2TInfo.SG_smoothed_data = transpose(h5read(full_hdf5_filename,[hdf5_group_name,'/SG_smoothed_data']));    
catch
    tmp2TInfo.SG_smoothed_data = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    tmp2TInfo.Normalize_by_Intensity = h5read(full_hdf5_filename,[hdf5_group_name,'/Normalize_by_Intensity']);    
catch
    tmp2TInfo.Normalize_by_Intensity = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    tmp2TInfo.Normalize_by_Smoothed_Img = h5read(full_hdf5_filename,[hdf5_group_name,'/Normalize_by_Smoothed_Img']);    
catch
    tmp2TInfo.Normalize_by_Smoothed_Img = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    tmp2TInfo.Normalize_by_Smoothed_Sqmap = h5read(full_hdf5_filename,[hdf5_group_name,'/Normalize_by_Smoothed_Sqmap']);    
catch
    tmp2TInfo.Normalize_by_Smoothed_Sqmap = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    tmp2TInfo.Subtract_Ref_Speckle = h5read(full_hdf5_filename,[hdf5_group_name,'/Subtract_Ref_Speckle']);    
catch
    tmp2TInfo.Subtract_Ref_Speckle = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    tmp2TInfo.Num_g2partials = h5read(full_hdf5_filename,[hdf5_group_name,'/Num_g2partials']);    
catch
    tmp2TInfo.Num_g2partials = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    tmp2TInfo.g2full = h5read(full_hdf5_filename,[hdf5_group_name,'/g2full']);    
catch
    tmp2TInfo.g2full = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    tmp2TInfo.g2partials = h5read(full_hdf5_filename,[hdf5_group_name,'/g2partials']);    
catch
    tmp2TInfo.g2partials = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Read 2T matrix %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmp2TInfo.good_qphi_bins = nonzeros(unique(tmp2TInfo.dqmap_index_qbin));
foo_info=h5info(full_hdf5_filename,hdf5_group_2T_name);
foo_num_datasets = numel(foo_info.Datasets);
foo_size=foo_info.Datasets(1).Dataspace.Size;
foo_type_size=foo_info.Datasets(1).Datatype.Size;
TwoTime_Matrix_Size_GB = max(foo_size)*max(foo_size)*foo_type_size(1)/(1024^3);
Num_TwoTime_Matrix_Size = foo_num_datasets;
Total_TwoTime_Matrix_Size_GB = TwoTime_Matrix_Size_GB * Num_TwoTime_Matrix_Size;
%%
if isempty(TwoTime_Matrices_To_Download)
    fprintf('------------------\n');
    fprintf('Two Time Matrices in HDF5 file : Details.....\n');
    fprintf('Each 2T Matrix is of size %f GBytes....\n',TwoTime_Matrix_Size_GB);
    fprintf('There are a TOTAL of %i Two Time matrices in the file....\n',Num_TwoTime_Matrix_Size);
    fprintf('Combined size of all the 2T Matrices is %f GBytes....\n',Total_TwoTime_Matrix_Size_GB);
    fprintf('You have the option of downloading ALL or a SELECT few\n');
    fprintf('------------------\n');
    disp(tmp2TInfo);
    fprintf('PREVIEW of TwoTime Results SAVED into the HDF5 file is Done...\n');    
    return;
end
%%
start_2T_download = tic;
if ~isempty(TwoTime_Matrices_To_Download)
    for ii=1:numel(TwoTime_Matrices_To_Download)
        try
            tmp2TInfo.C{ii} = transpose(squeeze(h5read(full_hdf5_filename,[hdf5_group_2T_name,'/C_',sprintf('%04i',TwoTime_Matrices_To_Download(ii))])));
            %convert from triangular 2T matrix to full square matrix
            tmp2TInfo.C{ii} = tmp2TInfo.C{ii} + triu(tmp2TInfo.C{ii},1)';
        catch
            tmp2TInfo.C{ii} = [];
        end
    end
    tmp2TInfo.TwoTime_Matrices_Downloaded = TwoTime_Matrices_To_Download;
    disp(tmp2TInfo);
    fprintf('------------------\n');
    fprintf('TwoTime Matrices : %i out of %i -- are DOWNLOADED from the HDF5 file in %i Seconds\n',...
        numel(TwoTime_Matrices_To_Download),foo_num_datasets,round(toc(start_2T_download)));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmp2TInfo.Num_g2partials=10;
tmp2TInfo=Compute_TwoTime2OneTime(tmp2TInfo);


