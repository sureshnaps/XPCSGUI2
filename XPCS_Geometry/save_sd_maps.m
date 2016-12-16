function ccdimginfo = save_sd_maps(ccdimginfo)
% % % % loadbatchinfo
% % % % make mask
% % % % set static and dynamic partitions such that static/dynamic=integer (eg: 90,18)
% % % % save mask as .mat file and remember the name to pass as input here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
full_hdf5_filename=strcat(fullfile(ccdimginfo.map_local_location,ccdimginfo.map_filename));
ccdimginfo.hdf5_partitionmap_filename=full_hdf5_filename;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%force the ratio of snpt to dnpt to be a integer (cluster requirement)
[ccdimginfo.partition.snpt(1),ccdimginfo.partition.dnpt(1)] = ...
    adjust_part_no(ccdimginfo.partition.snpt(1),ccdimginfo.partition.dnpt(1));
%%force the ratio of snpt to dnpt to be a integer (cluster requirement)
[ccdimginfo.partition.snpt(2),ccdimginfo.partition.dnpt(2)] = ...
    adjust_part_no(ccdimginfo.partition.snpt(2),ccdimginfo.partition.dnpt(2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
add_full_params_to_hdf5_mapfile(ccdimginfo,full_hdf5_filename);%%add additional q/phi fields
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%add qmap related fields to ccdimginfo after reading from the h5 file made
%for MPI or any cluster for that matter
ccdimginfo=update_ccdimginfo_qmaps(ccdimginfo,full_hdf5_filename);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

function add_full_params_to_hdf5_mapfile(ccdimginfo,full_hdf5_filename)
%%overwrite the first to delete the contents of the existing file and append the rest

version_number = 3.0;
hdf5write(full_hdf5_filename,'/data/Version',version_number); %over writes the file
%version num changed to 2 where ccdimginfo.maps fields are added (Sep2015)
%version num changed to 3 where x0,y0,xspec,yspec fields are added (Oct2016)
try
    h5write(full_hdf5_filename,'/data/Version',version_number);%%Start Hadoop with V1.0
catch
    h5create(full_hdf5_filename,'/data/Version',size(1,1));
    h5write(full_hdf5_filename,'/data/Version',version_number);%%Start Hadoop with V1.0
end

writeh5str(full_hdf5_filename,'/data/data_name',ccdimginfo.data_folder);%%overwrite the first

try
    h5write(full_hdf5_filename,'/data/x0',ccdimginfo.acquisition.x0);
catch
    h5create(full_hdf5_filename,'/data/x0',size(ccdimginfo.acquisition.x0));
    h5write(full_hdf5_filename,'/data/x0',ccdimginfo.acquisition.x0);
end

try
    h5write(full_hdf5_filename,'/data/y0',ccdimginfo.acquisition.y0);
catch
    h5create(full_hdf5_filename,'/data/y0',size(ccdimginfo.acquisition.y0));
    h5write(full_hdf5_filename,'/data/y0',ccdimginfo.acquisition.y0);
end

try
    h5write(full_hdf5_filename,'/data/xspec',ccdimginfo.acquisition.xspec);
catch
    h5create(full_hdf5_filename,'/data/xspec',size(ccdimginfo.acquisition.xspec));
    h5write(full_hdf5_filename,'/data/xspec',ccdimginfo.acquisition.xspec);
end

try
    h5write(full_hdf5_filename,'/data/yspec',ccdimginfo.acquisition.yspec);
catch
    h5create(full_hdf5_filename,'/data/yspec',size(ccdimginfo.acquisition.yspec));
    h5write(full_hdf5_filename,'/data/yspec',ccdimginfo.acquisition.yspec);
end

try
    h5write(full_hdf5_filename,'/data/ccdx0',ccdimginfo.acquisition.ccdx0);
catch
    h5create(full_hdf5_filename,'/data/ccdx0',size(ccdimginfo.acquisition.ccdx0));
    h5write(full_hdf5_filename,'/data/ccdx0',ccdimginfo.acquisition.ccdx0);
end

try
    h5write(full_hdf5_filename,'/data/ccdz0',ccdimginfo.acquisition.ccdz0);
catch
    h5create(full_hdf5_filename,'/data/ccdz0',size(ccdimginfo.acquisition.ccdz0));
    h5write(full_hdf5_filename,'/data/ccdz0',ccdimginfo.acquisition.ccdz0);
end

try
    h5write(full_hdf5_filename,'/data/ccdx',ccdimginfo.acquisition.ccdx);
catch
    h5create(full_hdf5_filename,'/data/ccdx',size(ccdimginfo.acquisition.ccdx));
    h5write(full_hdf5_filename,'/data/ccdx',ccdimginfo.acquisition.ccdx);
end

try
    h5write(full_hdf5_filename,'/data/ccdz',ccdimginfo.acquisition.ccdz);
catch
    h5create(full_hdf5_filename,'/data/ccdz',size(ccdimginfo.acquisition.ccdz));
    h5write(full_hdf5_filename,'/data/ccdz',ccdimginfo.acquisition.ccdz);
end

try
    h5write(full_hdf5_filename,'/data/snoq',ccdimginfo.partition.snpt(1));
catch
    h5create(full_hdf5_filename,'/data/snoq',size(ccdimginfo.partition.snpt(1)));
    h5write(full_hdf5_filename,'/data/snoq',ccdimginfo.partition.snpt(1));
end

try
    h5write(full_hdf5_filename,'/data/dnoq',ccdimginfo.partition.dnpt(1));
catch
    h5create(full_hdf5_filename,'/data/dnoq',size(ccdimginfo.partition.dnpt(1)));
    h5write(full_hdf5_filename,'/data/dnoq',ccdimginfo.partition.dnpt(1));
end

try
    h5write(full_hdf5_filename,'/data/snophi',ccdimginfo.partition.snpt(2));
catch
    h5create(full_hdf5_filename,'/data/snophi',size(ccdimginfo.partition.snpt(2)));
    h5write(full_hdf5_filename,'/data/snophi',ccdimginfo.partition.snpt(2));
end

try
    h5write(full_hdf5_filename,'/data/dnophi',ccdimginfo.partition.dnpt(2));
catch
    h5create(full_hdf5_filename,'/data/dnophi',size(ccdimginfo.partition.dnpt(2)));
    h5write(full_hdf5_filename,'/data/dnophi',ccdimginfo.partition.dnpt(2));
end

try
    h5write(full_hdf5_filename,'/data/sqval',ccdimginfo.partition.smeanmap(:,1));
catch
    h5create(full_hdf5_filename,'/data/sqval',size(ccdimginfo.partition.smeanmap(:,1)));
    h5write(full_hdf5_filename,'/data/sqval',ccdimginfo.partition.smeanmap(:,1));
end

try
    h5write(full_hdf5_filename,'/data/dqval',ccdimginfo.partition.dmeanmap(:,1));
catch
    h5create(full_hdf5_filename,'/data/dqval',size(ccdimginfo.partition.dmeanmap(:,1)));
    h5write(full_hdf5_filename,'/data/dqval',ccdimginfo.partition.dmeanmap(:,1));
end

try
    h5write(full_hdf5_filename,'/data/sphival',ccdimginfo.partition.smeanmap(:,2));
catch
    h5create(full_hdf5_filename,'/data/sphival',size(ccdimginfo.partition.smeanmap(:,2)));
    h5write(full_hdf5_filename,'/data/sphival',ccdimginfo.partition.smeanmap(:,2));
end

try
    h5write(full_hdf5_filename,'/data/dphival',ccdimginfo.partition.dmeanmap(:,2));
catch
    h5create(full_hdf5_filename,'/data/dphival',size(ccdimginfo.partition.dmeanmap(:,2)));
    h5write(full_hdf5_filename,'/data/dphival',ccdimginfo.partition.dmeanmap(:,2));
end

try
    h5write(full_hdf5_filename,'/data/sqspan',ccdimginfo.partition.sspan{1}');
catch
    h5create(full_hdf5_filename,'/data/sqspan',size(ccdimginfo.partition.sspan{1}'));
    h5write(full_hdf5_filename,'/data/sqspan',ccdimginfo.partition.sspan{1}');
end

try
    h5write(full_hdf5_filename,'/data/dqspan',ccdimginfo.partition.dspan{1}');
catch
    h5create(full_hdf5_filename,'/data/dqspan',size(ccdimginfo.partition.dspan{1}'));
    h5write(full_hdf5_filename,'/data/dqspan',ccdimginfo.partition.dspan{1}');
end

try
    h5write(full_hdf5_filename,'/data/sphispan',ccdimginfo.partition.sspan{2}');
catch
    h5create(full_hdf5_filename,'/data/sphispan',size(ccdimginfo.partition.sspan{2}'));
    h5write(full_hdf5_filename,'/data/sphispan',ccdimginfo.partition.sspan{2}');
end

try
    h5write(full_hdf5_filename,'/data/dphispan',ccdimginfo.partition.dspan{2}');
catch
    h5create(full_hdf5_filename,'/data/dphispan',size(ccdimginfo.partition.dspan{2}'));
    h5write(full_hdf5_filename,'/data/dphispan',ccdimginfo.partition.dspan{2}');
end

try
    h5write(full_hdf5_filename,'/data/dynamicMap',uint32(ccdimginfo.partition.dindexmap'));
catch
    h5create(full_hdf5_filename,'/data/dynamicMap',size(uint32(ccdimginfo.partition.dindexmap')),'DataType','uint32');
    h5write(full_hdf5_filename,'/data/dynamicMap',uint32(ccdimginfo.partition.dindexmap'));
end

try
    h5write(full_hdf5_filename,'/data/staticMap',uint32(ccdimginfo.partition.sindexmap'));
catch
    h5create(full_hdf5_filename,'/data/staticMap',size(uint32(ccdimginfo.partition.sindexmap')),'DataType','uint32');
    h5write(full_hdf5_filename,'/data/staticMap',uint32(ccdimginfo.partition.sindexmap'));
end

try
    h5write(full_hdf5_filename,'/data/dynamicQList',[0;ccdimginfo.partition.dmeanmapindex]);
catch
    h5create(full_hdf5_filename,'/data/dynamicQList',size([0;ccdimginfo.partition.dmeanmapindex]));
    h5write(full_hdf5_filename,'/data/dynamicQList',[0;ccdimginfo.partition.dmeanmapindex]);
end

try
    h5write(full_hdf5_filename,'/data/staticQList',[0;ccdimginfo.partition.smeanmapindex]);
catch
    h5create(full_hdf5_filename,'/data/staticQList',size([0;ccdimginfo.partition.smeanmapindex]));
    h5write(full_hdf5_filename,'/data/staticQList',[0;ccdimginfo.partition.smeanmapindex]);
end

try
    h5write(full_hdf5_filename,'/data/mask',uint8(ccdimginfo.mask.usermask'));
catch
    h5create(full_hdf5_filename,'/data/mask',size(ccdimginfo.mask.usermask'),'DataType','uint8');
    h5write(full_hdf5_filename,'/data/mask',uint8(ccdimginfo.mask.usermask'));
end


%newly added with version number changed to 2.0
%%
try
    h5write(full_hdf5_filename,'/data/Maps/x',ccdimginfo.maps.x');
catch
    h5create(full_hdf5_filename,'/data/Maps/x',size(ccdimginfo.maps.x'));
    h5write(full_hdf5_filename,'/data/Maps/x',ccdimginfo.maps.x');
end

try
    h5write(full_hdf5_filename,'/data/Maps/y',ccdimginfo.maps.y');
catch
    h5create(full_hdf5_filename,'/data/Maps/y',size(ccdimginfo.maps.y'));
    h5write(full_hdf5_filename,'/data/Maps/y',ccdimginfo.maps.y');
end

if (ccdimginfo.geometry ~= 2) %wide angle xpcs case
    try
        h5write(full_hdf5_filename,'/data/Maps/q',ccdimginfo.maps.q');
    catch
        h5create(full_hdf5_filename,'/data/Maps/q',size(ccdimginfo.maps.q'));
        h5write(full_hdf5_filename,'/data/Maps/q',ccdimginfo.maps.q');
    end
    
    
    try
        h5write(full_hdf5_filename,'/data/Maps/phi',ccdimginfo.maps.phi');
    catch
        h5create(full_hdf5_filename,'/data/Maps/phi',size(ccdimginfo.maps.phi'));
        h5write(full_hdf5_filename,'/data/Maps/phi',ccdimginfo.maps.phi');
    end
end

if (ccdimginfo.geometry == 1)
    try
        h5write(full_hdf5_filename,'/data/Maps/qz',ccdimginfo.maps.qz');
    catch
        h5create(full_hdf5_filename,'/data/Maps/qz',size(ccdimginfo.maps.qz'));
        h5write(full_hdf5_filename,'/data/Maps/qz',ccdimginfo.maps.qz');
    end
    
    try
        h5write(full_hdf5_filename,'/data/Maps/qx',ccdimginfo.maps.qx');
    catch
        h5create(full_hdf5_filename,'/data/Maps/qx',size(ccdimginfo.maps.qx'));
        h5write(full_hdf5_filename,'/data/Maps/qx',ccdimginfo.maps.qx');
    end
    
    try
        h5write(full_hdf5_filename,'/data/Maps/qy',ccdimginfo.maps.qy');
    catch
        h5create(full_hdf5_filename,'/data/Maps/qy',size(ccdimginfo.maps.qy'));
        h5write(full_hdf5_filename,'/data/Maps/qy',ccdimginfo.maps.qy');
    end
    
    
    try
        h5write(full_hdf5_filename,'/data/Maps/qr',ccdimginfo.maps.qr');
    catch
        h5create(full_hdf5_filename,'/data/Maps/qr',size(ccdimginfo.maps.qr'));
        h5write(full_hdf5_filename,'/data/Maps/qr',ccdimginfo.maps.qr');
    end
    
    try
        h5write(full_hdf5_filename,'/data/Maps/exitAngle',ccdimginfo.maps.exitAngle');
    catch
        h5create(full_hdf5_filename,'/data/Maps/exitAngle',size(ccdimginfo.maps.exitAngle'));
        h5write(full_hdf5_filename,'/data/Maps/exitAngle',ccdimginfo.maps.exitAngle');
    end
    
    try
        h5write(full_hdf5_filename,'/data/Maps/outOfPlaneAngle',ccdimginfo.maps.outOfPlaneAngle');
    catch
        h5create(full_hdf5_filename,'/data/Maps/outOfPlaneAngle',size(ccdimginfo.maps.outOfPlaneAngle'));
        h5write(full_hdf5_filename,'/data/Maps/outOfPlaneAngle',ccdimginfo.maps.outOfPlaneAngle');
    end    
end


%%
end
