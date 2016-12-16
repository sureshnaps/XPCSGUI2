function save_MetaData_xpcs_hdf5(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
full_hdf5_filename=varargin{1};
hdf5_xpcs_group_name=varargin{2};
tag=varargin{3};
tag_value=varargin{4};
index=varargin{5};
hdf5_exchange_group_name=varargin{6};
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
property_list='H5P_DEFAULT';
xpcs_fid=H5F.open(full_hdf5_filename,'H5F_ACC_RDWR',property_list);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
tag1=[hdf5_xpcs_group_name,'/output_data'];
tag1_value=hdf5_exchange_group_name;
writeh5str(full_hdf5_filename,tag1,tag1_value);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%PROVENANCE
%%Removing all the provenance stuff as it is all now done in the
%%actor/pipeline/cluster
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % prov_exists=H5L.exists(xpcs_fid,'/provenance',property_list);
% % % % if (prov_exists)
% % % %     H5L.delete(xpcs_fid,'/provenance',property_list);
% % % % end
% % % % gid1=H5G.create(xpcs_fid,'/provenance',property_list,property_list,property_list);
% % % % gid2=H5G.create(xpcs_fid,'/provenance/process_1',property_list,property_list,property_list);
% % % % gid3=H5G.create(xpcs_fid,'/provenance/process_2',property_list,property_list,property_list);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % tag1='/provenance/process_1/reference';
% % % % tag1_value = 'xpcs';
% % % % writeh5str(full_hdf5_filename,tag1,tag1_value);
% % % % 
% % % % tag1='/provenance/process_1/status';
% % % % tag1_value = 'QUEUED ';
% % % % writeh5str(full_hdf5_filename,tag1,tag1_value);
% % % % 
% % % % tag1='/provenance/process_2/reference';
% % % % tag1_value = 'g2_fitting';
% % % % writeh5str(full_hdf5_filename,tag1,tag1_value);
% % % % 
% % % % tag1='/provenance/process_2/status';
% % % % tag1_value = 'QUEUED ';
% % % % writeh5str(full_hdf5_filename,tag1,tag1_value);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % H5G.close(gid3);
% % % % H5G.close(gid2);
% % % % H5G.close(gid1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
H5F.close(xpcs_fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
