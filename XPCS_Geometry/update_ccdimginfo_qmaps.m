function ccdimginfo = update_ccdimginfo_qmaps(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ccdimginfo=varargin{1};
qmap_hdf5_file=varargin{2};%h5 file made for MPI, created using send_qphimap_to_cluster
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%get the masked pixels
usermask=h5read(qmap_hdf5_file,'/data/dynamicMap');
usermask=usermask';usermask(usermask==-1)=0;usermask(usermask>0)=1;
ccdimginfo.usermask=uint8(usermask);clear usermask;

ccdimginfo.dynamic_map=int32(transpose(h5read(qmap_hdf5_file,'/data/dynamicMap')));
ccdimginfo.static_map=int32(transpose(h5read(qmap_hdf5_file,'/data/staticMap')));

ccdimginfo.dqspan=h5read(qmap_hdf5_file,'/data/dqspan');
ccdimginfo.dphispan=h5read(qmap_hdf5_file,'/data/dphispan');

ccdimginfo.sqspan=h5read(qmap_hdf5_file,'/data/sqspan');
ccdimginfo.sphispan=h5read(qmap_hdf5_file,'/data/sphispan'); 

ccdimginfo.sqval=h5read(qmap_hdf5_file,'/data/sqval');
ccdimginfo.dqval=h5read(qmap_hdf5_file,'/data/dqval');

ccdimginfo.sphival=h5read(qmap_hdf5_file,'/data/sphival');
ccdimginfo.dphival=h5read(qmap_hdf5_file,'/data/dphival');

%added in Oct 2015 so it will be part of hdf5 Data Exchange file as well
ccdimginfo.snpt(1)=h5read(qmap_hdf5_file,'/data/snoq');
ccdimginfo.snpt(2)=h5read(qmap_hdf5_file,'/data/snophi');
ccdimginfo.dnpt(1)=h5read(qmap_hdf5_file,'/data/dnoq');
ccdimginfo.dnpt(2)=h5read(qmap_hdf5_file,'/data/dnophi');

[~,foo,foo_ext]=fileparts(qmap_hdf5_file);
ccdimginfo.qmap_hdf5_filename=[foo,foo_ext];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end