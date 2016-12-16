function save_qmaps_MetaData_xpcs_hdf5(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
full_hdf5_filename=varargin{1};
hdf5_xpcs_group_name=varargin{2};
tag=varargin{3};
tag_value=varargin{4};
index=varargin{5};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
property_list='H5P_DEFAULT';
xpcs_fid=H5F.open(full_hdf5_filename,'H5F_ACC_RDWR',property_list);
xpcs_exists=H5L.exists(xpcs_fid,hdf5_xpcs_group_name,property_list);
if (~xpcs_exists)
    fprintf('%s is not a field in the HDF5 MetaData file',hdf5_xpcs_group_name);
    return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ii=1:index
    if isnumeric(tag_value{ii})
        try
            h5create(full_hdf5_filename,tag{ii},size(tag_value{ii}),'Datatype',class(tag_value{ii}));
            h5write(full_hdf5_filename,tag{ii},tag_value{ii});
        catch
            h5write(full_hdf5_filename,tag{ii},tag_value{ii});
        end
    else
        writeh5str(full_hdf5_filename,tag{ii},tag_value{ii});
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
H5F.close(xpcs_fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
