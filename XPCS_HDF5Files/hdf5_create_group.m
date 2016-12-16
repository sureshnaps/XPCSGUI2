function hdf5_create_group(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
full_hdf5_filename=varargin{1};
New_hdf5_group_name=varargin{2};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~( (exist(full_hdf5_filename,'file')) && H5F.is_hdf5(full_hdf5_filename) )   %%hdf5 file does not exist
    disp('HDF5 file does not exist. Create the file first before creating a group');
    return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
property_list='H5P_DEFAULT';
xpcs_fid=H5F.open(full_hdf5_filename,'H5F_ACC_RDWR',property_list);
try
    gid = H5G.open(xpcs_fid,New_hdf5_group_name);
%     fprintf('HDF5 group %s already exists\n',New_hdf5_group_name);
    H5G.close(gid);
    return;
catch
%     fprintf('HDF5 group %s _does not_ exist, creating the group\n',New_hdf5_group_name);
    gid1=H5G.create(xpcs_fid,New_hdf5_group_name,property_list,property_list,property_list);
    H5G.close(gid1);
end

H5F.close(xpcs_fid);

end