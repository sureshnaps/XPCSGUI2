%%
%%%%%%%%%%%%%DO NOT TOUCH BELOW%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
root_folder_local='/home/8-id-e/2016-2/';
qmaps_local='/home/8-id-e/partitionMapLibrary/';
global SELECT_XPCS_CLUSTER %#ok<NUSED>
SELECT_XPCS_CLUSTER = 'Default' ;
% % %type: SELECT_XPCS_CLUSTER = 'Default' ; %%(if XPCSM2 keeps failing)
%%%%%%%%%%%%%DO NOT TOUCH ABOVE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% %%%%%%%%%%USER DEFINABLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parent_folder='sutton1608';
%%%%%DO NOT TOUCH ABOVE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
XPCSparams = []; %Initialize to start clean
XPCSparams.stride_frames=1;
XPCSparams.avg_frames=1;
%%
XPCSparams.dark_start_frame = [];
XPCSparams.dark_end_frame = [];

XPCSparams.start_frame = [];
XPCSparams.end_frame = [];
XPCSparams.delays_per_level = [];
XPCSparams.analysis_type = 'Multitau'; %%Twotime

XPCSparams.partition_name = {'x','y'};
XPCSparams.partition_static = [15,15];
XPCSparams.partition_dynamic = [1,1];
mask= load('/home/8-id-e/2016-2/sutton1608/cluster_results/mask_logical_R050.mat');
XPCSparams.usermask = logical(mask.usermask);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data_folder='R050_sma_10-15Cloop_q7';
metadatafile = dir(fullfile(root_folder_local,parent_folder,data_folder,'*.batchinfo'));
metadatafile = fullfile(root_folder_local,parent_folder,data_folder,metadatafile.name);
[viewresultinfo,ccdimginfo,img] = runxpcs_local(metadatafile,XPCSparams);





