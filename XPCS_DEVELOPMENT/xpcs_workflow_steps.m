%%
% clear all;

% cd /net/wolfa/data/xpcs8/2014-3/jonghun201410/cluster_results;

clear ccdimginfo;
root_folder_local='/net/wolf/data/xpcs8/2015-2/';
parent_folder='jonghun201508';

global ccdimginfo

% data_folder='I135_Silica310nm_56vol_Steady_Stress_10000Pa_att4_Sq0_001';
% data_folder='I136_Silica310nm_56vol_Quiescent_After_Shear_Stress_10000Pa_att1_FCCDq0_001';
data_folder='I058_Silica310nm_52vol_f_1Hz_Strain_16_att3_FCCDq0_090';

batchinfoname =  dir(fullfile(root_folder_local,parent_folder,data_folder,'*.batchinfo'));
batchinfoname=fullfile(root_folder_local,parent_folder,data_folder,batchinfoname.name);

%%
ccdimginfo = convert_batchinfo_loadhdf5MetaData(batchinfoname);
[~,ccdimginfo]=Compute_IMM_SumImages(ccdimginfo);

% % ccdimginfo.bin.acquisition.x0=648.5;
% % ccdimginfo.bin.acquisition.y0=654.5;
%%
% calculate all the different q-maps at the pixel level
% ccdimginfo = getimgmap(ccdimginfo,1); %maps structure with display
ccdimginfo = getimgmap(ccdimginfo); %maps structure with no display
%% mask
% --- from getimgmask
% === case 1: use getimgmask(img,ccdimginfo). Saving to workspace will automatically add mask information to ccdimginfo 
% getimgmask(ccdimginfo.xpcs.testimg,ccdimginfo);
% % %getimgmask(ccdimginfo.xpcs.testimg); %this will dump the mask to the workspace
% === case 3: use a mask file saved to the disk
oldmask = load('FCCD_mask_new.mat');
% oldmask = load('Sq_mask.mat');
ccdimginfo.mask.usermask = oldmask.usermask;
% hdf_filename = 'E072_Silica300nm_60pvol_PEG200_step_07_oscl_f_1_strain_100_Sq0_001_0001-0202.hdf';
% sqmap=transpose(h5read(hdf_filename,'/xpcs/sqmap'));

%% PI mask (master_mask.mat)
% %getimgmask(ccdimginfo.xpcs.testimg,ccdimginfo)
% 
% %[~,min_pixel] = min(abs(ccdimginfo.maps.q(:))); min_pixel=min_pixel(1);
% x0 = 696;
% y0 = 671;
% r = sqrt( (ccdimginfo.maps.x(:)-x0).^2 +(ccdimginfo.maps.y(:)-y0).^2);
% %r = sqrt( (ccdimginfo.maps.x(:)-ccdimginfo.maps.x(min_pixel)).^2 +(ccdimginfo.maps.y(:)-ccdimginfo.maps.y(min_pixel)).^2);
% r_cutoff = 100;
% usermask=true(size(ccdimginfo.mask.usermask)); 
% usermask(r<r_cutoff) = 0;
% ccdimginfo.mask.usermask = usermask;
% %ccdimginfo.mask.usermask(r<r_cutoff) = 0;
% figure;
% imagesc(ccdimginfo.xpcs.testimg.*(~ccdimginfo.mask.usermask));
% axis image;
% set(gca,'ydir','norm');%% PI mask master_mask

% %% FCDD mask (mask_maskFCCD.mat)
% %[~,min_pixel] = min(abs(ccdimginfo.maps.q(:))); min_pixel=min_pixel(1);
% x0 = 206.5;
% y0 = 24.0;
% r = sqrt( (ccdimginfo.maps.x(:)-x0).^2 +(ccdimginfo.maps.y(:)-y0).^2);
% %r = sqrt( (ccdimginfo.maps.x(:)-ccdimginfo.maps.x(min_pixel)).^2 +(ccdimginfo.maps.y(:)-ccdimginfo.maps.y(min_pixel)).^2);
% r_cutoff = 88;
% usermask=ones(size(ccdimginfo.mask.usermask)); 
% usermask(r<r_cutoff) = 0;
% ccdimginfo.mask.usermask = usermask;
% %ccdimginfo.mask.usermask(r<r_cutoff) = 0;
% figure;
% imagesc(ccdimginfo.xpcs.testimg.*(~ccdimginfo.mask.usermask));
% axis image;
% set(gca,'ydir','norm');

%%
% qy=ccdimginfo.maps.qy;
% qx=ccdimginfo.maps.qx;
% qr=ccdimginfo.maps.qr;
% qz=ccdimginfo.maps.qz;
% index = abs(qy)<0.001 & qx>0.000148 & qx<0.000446;

q=ccdimginfo.maps.q;
phi=ccdimginfo.maps.phi;

%make sure to reset to full mask each time before running this section
%flow

% index = (abs(q)>= 0.0033 & abs(q)<0.0037 & phi >= -250.5 & phi <= 79.5) ;
index = (abs(q)>= 0.0048 & abs(q)<0.0056 & phi >= -250.5 & phi <= 79.5) ;

% index = (abs(q)>= 0.0015 & abs(q)<0.0016) ;
% index = (abs(q)>= 0.0016 & abs(q)<0.0017) ;
% index = (abs(q)>= 0.0022 & abs(q)<0.0023) ;
% index = (abs(q)>= 0.0023 & abs(q)<0.0024) ;

% % & ...
% %     ((phi >=-1.5 & phi <= 1.5) | (phi >=-181.5 & phi <=-178.5));    % 0 & 180 degree

% % index = (abs(q)> 0.0018 & abs(q)<0.0022) & ...
% %     ((phi >=-1.5 & phi <= 1.5) | (phi >=-181.5 & phi <=-178.5));    % 0 & 180 degree
        
%vorticity
% index = (abs(q)> 0.0018 & abs(q)<0.0022) & ...
%     ((phi >-270 & phi < -264) | (phi >84 & phi <90) | (phi>-96 & phi < -84));


usermask=ones(size(ccdimginfo.mask.usermask)); 
usermask(~index) = 0;
figure
imagesc(usermask);
set(gca,'ydir','norm');
ccdimginfo.mask.usermask = usermask;

%%
% ind_rotation = find(ccdimginfo.maps.phi>0);
% ccdimginfo.maps.phi(ind_rotation) = ccdimginfo.maps.phi(ind_rotation) - 360;
% calculate the q-partitions based on the below parameters
ccdimginfo.partition.name = {'q','phi'};
ccdimginfo.partition.snpt = [9, 110];
ccdimginfo.partition.dnpt = [1, 110];
ccdimginfo.partition.smethod = [1, 1]; %1-linear,2-log
ccdimginfo.partition.dmethod = [1, 1]; %1-linear,2-log
%%%%%%%%%%%%%%
% ccdimginfo.partition.name = {'qr','qz'};
% ccdimginfo.partition.snpt = [54, 15];
% ccdimginfo.partition.dnpt = [18, 1];
% ccdimginfo.partition.smethod = [1, 1]; %1-linear,2-log
% ccdimginfo.partition.dmethod = [1, 1]; %1-linear,2-log


ccdimginfo = getimgpartition(ccdimginfo); %partition structure
ccdimginfo = getimgpartitionindex(ccdimginfo); %integer partition map
% showmaskpartition;

%%
% % ccdimginfo.map_local_location =  '/home/8-id-i/partitionMapLibrary/2015-2/';
% % ccdimginfo.map_filename = 'jonghun_qmap_201508_silica_Sq0p0052_delq8em4_110phis3deg.h5';
% % save_sd_maps(ccdimginfo); %creates hdf5 file with qmaps
% % eval(['ls -rtl ',ccdimginfo.map_local_location])
% % preview_qphimap_cluster(fullfile(ccdimginfo.map_local_location,ccdimginfo.map_filename));
% % list_qmaps

%%
% root_dir='/net/wolfa/data/xpcs8/2014-3/';
% parent_folder='archer201405';
% data_folder='AA_covalent_PEG4p5k_080C_Fq2_007';
% qmap_filename='foo.h5';
% 
% output_hdf5_metadata_fullfile_local = create_hdf5_xpcs_job(root_dir,parent_folder,data_folder,qmap_filename);
%%