function [output_hdf5_metadata_fullfile_local,hdf5_xpcs_group_name_new] = Create_hdf5_XPCS_Job(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
evalin('base','global SELECT_XPCS_CLUSTER'); %%to make it global in base workspace
global ccdimginfo;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
root_dir=varargin{1};
parent_folder=varargin{2};
data_folder=varargin{3};
qmap_filename=varargin{4};
XPCSparams=varargin{5}; %struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%if 0, expects and uses a hdf metadata file
%if 1, forces to use batchinfo even if hdf5 file is there
use_batchinfo=0; 
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
if isfield(XPCSparams,'analysis_type')
    analysis_type=XPCSparams.analysis_type;
else
    analysis_type='Multitau';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%check for metadata batchinfo/hdf to be ready every 15 sec
try
    check_batchinfo_exists(fullfile(root_dir,parent_folder,data_folder));
catch
    %for cases where this function is not defined (esp. for users back home)
end

tmp_hdf=dir(fullfile(root_dir,parent_folder,data_folder,'*.hdf'));
tmp_batchinfo=dir(fullfile(root_dir,parent_folder,data_folder,'*.batchinfo'));

if (~isempty(tmp_hdf) && (use_batchinfo == 0))
    tmp=tmp_hdf;
else
    tmp=tmp_batchinfo;
end
[~,tmpindex] =  max([tmp(:).datenum]);
output_hdf5_metadata_fullfile_local=fullfile(root_dir,parent_folder,data_folder,tmp(tmpindex).name);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if H5F.is_hdf5(output_hdf5_metadata_fullfile_local) == 0 %assume it is batchinfo
    try
        ccdimginfo=convert_batchinfo_loadhdf5MetaData(output_hdf5_metadata_fullfile_local);
        output_hdf5_metadata_fullfile_local=ccdimginfo.fullpath_info_name;
    catch
        fprintf('Something wrong with the .batchinfo metadata file.. %s\n',output_hdf5_metadata_fullfile_local);
        return;
    end    
elseif H5F.is_hdf5(output_hdf5_metadata_fullfile_local) > 0 %is a hdf file
    try
        ccdimginfo=loadhdf5MetaData(output_hdf5_metadata_fullfile_local);
        output_hdf5_metadata_fullfile_local=ccdimginfo.fullpath_info_name;
    catch
        fprintf('Something wrong with the HDF metadata file.. %s\n',output_hdf5_metadata_fullfile_local);        
    end
else
    fprintf('Specified metadata file %s is not a known file..\n',output_hdf5_metadata_fullfile_local);
    return;
end

ccdimginfo.xpcs.analysis_type=analysis_type; %set to multitau or twotime
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(XPCSparams,'start_frame') && ~isempty(XPCSparams.start_frame)
    ccdimginfo.xpcs.data_begin_todo(1)=XPCSparams.start_frame;
end

if isfield(XPCSparams,'end_frame') && ~isempty(XPCSparams.end_frame)
    ccdimginfo.xpcs.data_end_todo(1)=XPCSparams.end_frame;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(XPCSparams,'stride_frames') && ~isempty(XPCSparams.stride_frames)
    ccdimginfo.xpcs.stride_frames=XPCSparams.stride_frames;
end

if isfield(XPCSparams,'avg_frames') && ~isempty(XPCSparams.avg_frames)
    ccdimginfo.xpcs.avg_frames=XPCSparams.avg_frames;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(XPCSparams,'delays_per_level') && ~isempty(XPCSparams.delays_per_level)
    ccdimginfo.xpcs.dpl = XPCSparams.delays_per_level;
else
    ccdimginfo.xpcs.dpl = 4; %default
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ccdimginfo = update_ccdimginfo_qmaps(ccdimginfo,qmap_filename);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%adding code to define /xpcs_N here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
hdf5_create_file(output_hdf5_metadata_fullfile_local); %create the hdf5 file here

%create the different groups required other than /xpcs and /exchange
hdf5_create_group(output_hdf5_metadata_fullfile_local,'/measurement');
hdf5_create_group(output_hdf5_metadata_fullfile_local,'/measurement/sample');
hdf5_create_group(output_hdf5_metadata_fullfile_local,'/measurement/instrument');
hdf5_create_group(output_hdf5_metadata_fullfile_local,'/measurement/instrument/source_begin');
hdf5_create_group(output_hdf5_metadata_fullfile_local,'/measurement/instrument/acquisition');
hdf5_create_group(output_hdf5_metadata_fullfile_local,'/measurement/instrument/detector');
hdf5_create_group(output_hdf5_metadata_fullfile_local,'/measurement/instrument/detector/roi');
hdf5_create_group(output_hdf5_metadata_fullfile_local,'/measurement/instrument/detector/kinetics');
%%
hdf5_xpcs_group_name = '/xpcs';
hdf5_xpcsResult_group_name = '/exchange';

try
    group_xpcs_next_suffix = hdf5_find_group_suffix(output_hdf5_metadata_fullfile_local,hdf5_xpcs_group_name);
catch    
end

if (group_xpcs_next_suffix == 0) %/xpcs group does not exist, so make it
    hdf5_create_group(output_hdf5_metadata_fullfile_local,hdf5_xpcs_group_name);
    hdf5_xpcs_group_name_new = hdf5_xpcs_group_name;
    hdf5_xpcsresult_group_name_new=hdf5_xpcsResult_group_name;
else %/xpcs exists, so rename it and then create the group
    hdf5_xpcs_group_name_new = [hdf5_xpcs_group_name,'_',num2str(group_xpcs_next_suffix)];
    hdf5_xpcsresult_group_name_new = [hdf5_xpcsResult_group_name,'_',num2str(group_xpcs_next_suffix)];
end

xpcs_fid=H5F.open(output_hdf5_metadata_fullfile_local,'H5F_ACC_RDWR','H5P_DEFAULT');
%%
%%use this until Faisal's endpoint option is working
%     xpcs_exists=H5L.exists(xpcs_fid,hdf5_xpcs_group_name,'H5P_DEFAULT');
%     if (xpcs_exists)
%         hdf5_dataset_rename(output_hdf5_metadata_fullfile_local,hdf5_xpcs_group_name,hdf5_xpcs_group_name_new);
%     end
% hdf5_create_group(output_hdf5_metadata_fullfile_local,hdf5_xpcs_group_name);
%%
%%use this when faisal fixes the endpoint option
hdf5_create_group(output_hdf5_metadata_fullfile_local,hdf5_xpcs_group_name_new);

H5F.close(xpcs_fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[hdf5_xpcs_tag,hdf5_xpcs_tag_value,hdf5_xpcs_index] = write_MetaData_xpcs(hdf5_xpcs_group_name_new,ccdimginfo);
[hdf5_qmaps_xpcs_tag,hdf5_qmaps_xpcs_tag_value,hdf5_qmaps_xpcs_index] = write_qmaps_MetaData_xpcs(hdf5_xpcs_group_name_new,ccdimginfo);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%first instance when the hdf5 metadata file is created
create_MetaData_basic(output_hdf5_metadata_fullfile_local,ccdimginfo);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%hdf5 metadata file is updated for the first time with everything other than qmaps related /xpcs field
save_MetaData_xpcs_hdf5(output_hdf5_metadata_fullfile_local,hdf5_xpcs_group_name_new,hdf5_xpcs_tag,hdf5_xpcs_tag_value,hdf5_xpcs_index,hdf5_xpcsresult_group_name_new);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%hdf5 metadata file is updated for the first time with qmaps related /xpcs field
save_qmaps_MetaData_xpcs_hdf5(output_hdf5_metadata_fullfile_local,hdf5_xpcs_group_name_new,hdf5_qmaps_xpcs_tag,hdf5_qmaps_xpcs_tag_value,hdf5_qmaps_xpcs_index);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (~ispc) %will not work on windows PC
    cmd=sprintf('chmod 666 %s',output_hdf5_metadata_fullfile_local);
    system(cmd);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cmd=sprintf('Successfully Added Analysis related Info: %s',output_hdf5_metadata_fullfile_local);
disp(cmd);
updatemessage(cmd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('XPCS Job Group is ...%s\n',hdf5_xpcs_group_name_new);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
