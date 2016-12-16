function output_hdf5_metadata_fullfile_local = hadoop_submit_job(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
root_dir=varargin{1};
parent_folder=varargin{2};
data_folder=varargin{3};
qmap_filename=varargin{4};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,~,qmap_file_ext]=fileparts(qmap_filename);
if isempty(qmap_file_ext)
    qmap_filename=strcat(qmap_filename,'.h5');
    clear qmap_file_ext;
end

if (exist(qmap_filename,'file') ~=2)
    fprintf('Specified qmap file %s does not exist\n',qmap_filename);
    return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin >= 6) && ~isnan(varargin{5}) && ~isnan(varargin{6})
        data_begin_todo=varargin{5};
        data_end_todo=varargin{6};
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin ==7) && ~isnan(varargin{7})
    delays_per_level=varargin{7};
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
use_batchinfo=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (use_batchinfo == 1)
    %%check for batchinfo to be ready every 15 sec
    check_batchinfo_exists(fullfile(root_dir,parent_folder,data_folder));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    tmp=dir(fullfile(root_dir,parent_folder,data_folder,'*.batchinfo'));
else
    tmp=dir(fullfile(root_dir,parent_folder,data_folder,'*.hdf'));
end
[~,tmpindex] =  max([tmp(:).datenum]);
output_hdf5_metadata_fullfile_local=fullfile(root_dir,parent_folder,data_folder,tmp(tmpindex).name);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,~,file_ext]=fileparts(output_hdf5_metadata_fullfile_local);
if strcmp(file_ext,'.batchinfo')
    ccdimginfo=convert_batchinfo_loadhdf5MetaData(output_hdf5_metadata_fullfile_local);
    output_hdf5_metadata_fullfile_local=ccdimginfo.fullpath_info_name;
elseif strcmp(file_ext,'.hdf')
    ccdimginfo=loadhdf5MetaData(output_hdf5_metadata_fullfile_local);
    output_hdf5_metadata_fullfile_local=ccdimginfo.fullpath_info_name;    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin >= 6) && ~isnan(varargin{5}) && ~isnan(varargin{6})
    ccdimginfo.xpcs.data_begin_todo(1)=data_begin_todo;
    ccdimginfo.xpcs.data_end_todo(1)=data_end_todo;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin == 7) && ~isnan(varargin{7})
    ccdimginfo.xpcs.dpl=delays_per_level;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ccdimginfo = update_ccdimginfo_qmaps(ccdimginfo,qmap_filename);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%adding code to define /xpcs_N here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hdf5_create_file(output_hdf5_metadata_fullfile_local); %create the hdf5 file here

hdf5_xpcs_group_name = '/xpcs';
hdf5_xpcsResult_group_name = '/exchange';

try
    group_xpcs_next_suffix = hdf5_find_group_suffix(output_hdf5_metadata_fullfile_local,hdf5_xpcs_group_name);
catch    
end

if (group_xpcs_next_suffix == 0) %/xpcs group does not exist, so make it
    hdf5_create_group(output_hdf5_metadata_fullfile_local,hdf5_xpcs_group_name);
    hdf5_xpcsresult_group_name_new=hdf5_xpcsResult_group_name;
else %/xpcs exists, so rename it and then create the group
    hdf5_xpcs_group_name_new = [hdf5_xpcs_group_name,'_',num2str(group_xpcs_next_suffix)];
    hdf5_xpcsresult_group_name_new = [hdf5_xpcsResult_group_name,'_',num2str(group_xpcs_next_suffix)];
    
    xpcs_fid=H5F.open(output_hdf5_metadata_fullfile_local,'H5F_ACC_RDWR','H5P_DEFAULT');
    
    xpcs_exists=H5L.exists(xpcs_fid,hdf5_xpcs_group_name,'H5P_DEFAULT');
    
    if (xpcs_exists)
        hdf5_dataset_rename(output_hdf5_metadata_fullfile_local,hdf5_xpcs_group_name,hdf5_xpcs_group_name_new);
    end    
    hdf5_create_group(output_hdf5_metadata_fullfile_local,hdf5_xpcs_group_name);
    H5F.close(xpcs_fid);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[hdf5_xpcs_tag,hdf5_xpcs_tag_value,hdf5_xpcs_index] = write_MetaData_xpcs(hdf5_xpcs_group_name,ccdimginfo);
[hdf5_qmaps_xpcs_tag,hdf5_qmaps_xpcs_tag_value,hdf5_qmaps_xpcs_index] = write_qmaps_MetaData_xpcs(hdf5_xpcs_group_name,ccdimginfo);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%first instance when the hdf5 metadata file is created
create_MetaData_basic(output_hdf5_metadata_fullfile_local,ccdimginfo);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%hdf5 metadata file is updated for the first time with everything other than qmaps related /xpcs field
save_MetaData_xpcs_hdf5(output_hdf5_metadata_fullfile_local,hdf5_xpcs_group_name,hdf5_xpcs_tag,hdf5_xpcs_tag_value,hdf5_xpcs_index,hdf5_xpcsresult_group_name_new);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%hdf5 metadata file is updated for the first time with qmaps related /xpcs field
save_qmaps_MetaData_xpcs_hdf5(output_hdf5_metadata_fullfile_local,hdf5_xpcs_group_name,hdf5_qmaps_xpcs_tag,hdf5_qmaps_xpcs_tag_value,hdf5_qmaps_xpcs_index);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cmd=sprintf('chmod 666 %s',output_hdf5_metadata_fullfile_local);
system(cmd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cmd=sprintf('Successfully Loaded/Saved MetaData Information: %s',output_hdf5_metadata_fullfile_local);
disp(cmd);
updatemessage(cmd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% output_hdf5_metadata_fullfile_remote=strrep(output_hdf5_metadata_fullfile_local,'/net/wolfa/data/','/data/');
% Pipeline(output_hdf5_metadata_fullfile_remote,data_folder);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
