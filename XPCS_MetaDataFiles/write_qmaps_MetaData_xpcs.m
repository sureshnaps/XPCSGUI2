function [tag,tag_value,index] = write_qmaps_MetaData_xpcs(varargin)
%writeDX Write DataExchange example code.
%        Detailed explanation goes here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hdf5_xpcs_group_name=varargin{1};
ccdimginfo=varargin{2};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     index=0; %%%Initialize the counter
%      nBatch=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/mask'];
     tag_value{index} = transpose(ccdimginfo.usermask);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/dqmap'];
     tag_value{index} = transpose(ccdimginfo.dynamic_map);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/sqmap'];
     tag_value{index} = transpose(ccdimginfo.static_map);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
% %     index=index+1;
% %   tag{index}=[hdf5_xpcs_group_name,'/dphimap'];
% %    tag_value{index} = -1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
% %    index=index+1;
% %    tag{index}=[hdf5_xpcs_group_name,'/sphimap'];
% %    tag_value{index} = -1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/dqspan'];
     tag_value{index} = ccdimginfo.dqspan;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/dphispan'];
     tag_value{index} = ccdimginfo.dphispan;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/sqspan'];
     tag_value{index} = ccdimginfo.sqspan;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/sphispan'];
     tag_value{index} = ccdimginfo.sphispan;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/sqlist'];
     tag_value{index} = ccdimginfo.sqval;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/dqlist'];
     tag_value{index} = ccdimginfo.dqval;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/sphilist'];
     tag_value{index} = ccdimginfo.sphival;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/dphilist'];
     tag_value{index} = ccdimginfo.dphival;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/qmap_hdf5_filename'];
     tag_value{index} = ccdimginfo.qmap_hdf5_filename;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%added snpt and dnpt in Oct 2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     index=index+1;
     tag{index}='/xpcs/snoq';
     tag_value{index} = ccdimginfo.snpt(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
     index=index+1;
     tag{index}='/xpcs/snophi';
     tag_value{index} = ccdimginfo.snpt(2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
     index=index+1;
     tag{index}='/xpcs/dnoq';
     tag_value{index} = ccdimginfo.dnpt(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
     index=index+1;
     tag{index}='/xpcs/dnophi';
     tag_value{index} = ccdimginfo.dnpt(2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%ANYTHING NEW GOES HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%WRITE HDF5 FILE CONTAINING THE qmaps METADATA
%%%TRY to move saving to hdf5 file to a separate function
% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % property_list='H5P_DEFAULT';
% % % xpcs_fid=H5F.open(full_hdf5_filename,'H5F_ACC_RDWR',property_list);
% % % xpcs_exists=H5L.exists(xpcs_fid,[hdf5_xpcs_group_name,'',property_list);
% % % if (~xpcs_exists)
% % %     disp([hdf5_xpcs_group_name,' is not a field in the HDF5 MetaData file');
% % %     return;
% % % end
% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % for ii=1:index
% % %     if isnumeric(tag_value{ii})
% % %         try
% % %             %hdf5write(full_hdf5_filename,tag{ii},tag_value{ii},'WriteMode','append');            
% % %             h5create(full_hdf5_filename,tag{ii},size(tag_value{ii}),'Datatype',class(tag_value{ii}));
% % %             h5write(full_hdf5_filename,tag{ii},tag_value{ii});
% % %         catch
% % %             h5write(full_hdf5_filename,tag{ii},tag_value{ii});
% % %         end
% % %     else
% % %         writeh5str(full_hdf5_filename,tag{ii},tag_value{ii});
% % %     end
% % % end
% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % H5F.close(xpcs_fid);
% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


