function hdf5_dataset_rename(varargin)
%renames an existing group in the hdf5 file to a new group
%
full_hdf5_filename=varargin{1};
group_to_change_from=varargin{2};
group_to_change_to=varargin{3};

if strcmp(group_to_change_from,group_to_change_to)
    disp('hdf5 source and destination groups are the same. Exiting..');
    return;
end

hdf5_fid=H5F.open(full_hdf5_filename,'H5F_ACC_RDWR','H5P_DEFAULT');

group_id = H5G.open(hdf5_fid,group_to_change_from,'H5P_DEFAULT');

%prefered way is one of the two options below
% H5L.move(hdf5_fid,group_to_change_from,hdf5_fid,group_to_change_to,'H5P_DEFAULT','H5P_DEFAULT');
H5L.move(hdf5_fid,group_to_change_from,'H5L_SAME_LOC',group_to_change_to,'H5P_DEFAULT','H5P_DEFAULT');

fprintf('Renaming HDF group: %s -------> %s\n',group_to_change_from,group_to_change_to);
H5G.close(group_id);
H5F.close(hdf5_fid);

end