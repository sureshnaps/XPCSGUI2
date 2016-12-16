function send_qphimap_to_cluster(ccdimginfo)
% % % % loadbatchinfo
% % % % make mask
% % % % set static and dynamic partitions such that static/dynamic=integer (eg: 90,18)
% % % % save mask as .mat file and remember the name to pass as input here
%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cluster_mask_folder='/data/xpcs8/partitionMapLibrary/';
local_cluster_mask_path='/net/wolfa/data/xpcs8/partitionMapLibrary/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% foo=strfind(mask_matfilename,'.mat');
% if isempty(foo)
%     mask_filename=mask_matfilename;
% else
%     mask_filename=mask_matfilename(1:foo-1);
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hFigXPCSMain   = findall(0,'Tag','xpcsmain_Fig')  ;
% ccdimginfo = getappdata(hFigXPCSMain,'ccdimginfo')  ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%force the ratio of snoq to dnoq to be a integer (cluster requirement)
[ccdimginfo.partition.snpt(1),ccdimginfo.partition.dnpt(1)]=adjust_part_no(ccdimginfo.partition.snpt(1),ccdimginfo.partition.dnpt(1));

%%force the ratio of snophi to dnophi to be a integer (cluster requirement)
[ccdimginfo.partition.snpt(2),ccdimginfo.partition.dnpt(2)]=adjust_part_no(ccdimginfo.partition.snpt(2),ccdimginfo.partition.dnpt(2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setappdata(hFigXPCSMain,'ccdimginfo',ccdimginfo);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mapccdpixel;%%creates qmap
% getsdqphispan;%%creates sqspan, etc
% qphipartition;%%creates smask,dmask
% ccdimginfo = getappdata(hFigXPCSMain,'ccdimginfo')  ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ccdimginfo = create_maps_batchmode(ccdimginfo);%%defined in this file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setappdata(hFigXPCSMain,'ccdimginfo',ccdimginfo);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ccdimginfo.map_name=mask_filename;
ccdimginfo.map_local_location=local_cluster_mask_path;
full_hdf5_filename=strcat(fullfile(local_cluster_mask_path,mask_filename),'.h5');
ccdimginfo.hdf5_partitionmap_filename=full_hdf5_filename;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setappdata(hFigXPCSMain,'ccdimginfo',ccdimginfo);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ccdimginfo=add_full_params_to_hdf5_mapfile(ccdimginfo,full_hdf5_filename);%%add additional q/phi fields
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%add qmap related fields to ccdimginfo after reading from the h5 file made
%for MPI or any cluster for that matter
ccdimginfo=update_ccdimginfo_qmaps(ccdimginfo,full_hdf5_filename);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(dir([local_cluster_mask_path,mask_filename,'.h5']));
system('ls -lt /net/wolfa/data/xpcs8/partitionMapLibrary/ |head');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
setappdata(hFigXPCSMain,'ccdimginfo',ccdimginfo);
end

function ccdimginfo = create_maps_batchmode(ccdimginfo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%qd_index and qs_index go to the cluster h5 file for cluster usage
%%%%qd and qs go to the h5 file for matlab usage (new from May 2012)
% [yd,qd,dphi,qd_index]=create_dqphimap(ccdimginfo);
% [ys,qs,sphi,qs_index]=create_sqphimap(ccdimginfo);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- modify for cluster
ccdimginfo.current_smask=ccdimginfo.partition.sindexmap;%ys;
ccdimginfo.current_spart_list=[0;ccdimginfo.partition.smeanmapindex];%   [0;qs_index];
ccdimginfo.current_dmask=ccdimginfo.partition.dindexmap;%    yd;
ccdimginfo.current_dpart_list=[0;ccdimginfo.partition.dmeanmapindex];%[0;qd_index];

ccdimginfo.sqval=ccdimginfo.partition.smeanmap(:,1);%    qs;
ccdimginfo.dqval=ccdimginfo.partition.dmeanmap(:,1);%qd;
ccdimginfo.sphival=ccdimginfo.partition.smeanmap(:,2);%sphi;
ccdimginfo.dphival=ccdimginfo.partition.dmeanmap(:,2);%dphi;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

function ccdimginfo=add_full_params_to_hdf5_mapfile(ccdimginfo,full_hdf5_filename)
%%overwrite the first to delete the contents of the existing file and append the rest
hdf5write(full_hdf5_filename,'/data/data_name',ccdimginfo.name);%%overwrite the first
hdf5write(full_hdf5_filename,'WriteMode','append','/data/Version',1.0);%%Start Hadoop with V1.0
hdf5write(full_hdf5_filename,'WriteMode','append','/data/ccdx0',ccdimginfo.acquisition.ccdx0);
hdf5write(full_hdf5_filename,'WriteMode','append','/data/ccdz0',ccdimginfo.acquisition.ccdz0);
hdf5write(full_hdf5_filename,'WriteMode','append','/data/ccdx',ccdimginfo.acquisition.ccdx);
hdf5write(full_hdf5_filename,'WriteMode','append','/data/ccdz',ccdimginfo.acquisition.ccdz);
hdf5write(full_hdf5_filename,'WriteMode','append','/data/snoq',ccdimginfo.snoq);
hdf5write(full_hdf5_filename,'WriteMode','append','/data/dnoq',ccdimginfo.dnoq);
hdf5write(full_hdf5_filename,'WriteMode','append','/data/snophi',ccdimginfo.snophi);
hdf5write(full_hdf5_filename,'WriteMode','append','/data/dnophi',ccdimginfo.dnophi);

hdf5write(full_hdf5_filename,'WriteMode','append','/data/sqval',ccdimginfo.sqval);
hdf5write(full_hdf5_filename,'WriteMode','append','/data/dqval',ccdimginfo.dqval);
hdf5write(full_hdf5_filename,'WriteMode','append','/data/sphival',ccdimginfo.sphival);
hdf5write(full_hdf5_filename,'WriteMode','append','/data/dphival',ccdimginfo.dphival);

hdf5write(full_hdf5_filename,'WriteMode','append','/data/sqspan',ccdimginfo.sqspan);
hdf5write(full_hdf5_filename,'WriteMode','append','/data/dqspan',ccdimginfo.dqspan);
hdf5write(full_hdf5_filename,'WriteMode','append','/data/sphispan',ccdimginfo.sphispan);
hdf5write(full_hdf5_filename,'WriteMode','append','/data/dphispan',ccdimginfo.dphispan);

temp_dmask=int16(ccdimginfo.current_dmask');
temp_dmask(temp_dmask==32767)=-1;
temp_smask=int16(ccdimginfo.current_smask');
temp_smask(temp_smask==32767)=-1;

hdf5write(full_hdf5_filename,'WriteMode','append','/data/dynamicMap',temp_dmask);
hdf5write(full_hdf5_filename,'WriteMode','append','/data/staticMap',temp_smask);
hdf5write(full_hdf5_filename,'WriteMode','append','/data/dynamicQList',ccdimginfo.current_dpart_list);
hdf5write(full_hdf5_filename,'WriteMode','append','/data/staticQList',ccdimginfo.current_spart_list);

end
