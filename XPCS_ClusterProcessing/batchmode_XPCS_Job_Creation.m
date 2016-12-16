%%
%%%%%%%%%%%%%DO NOT TOUCH BELOW%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
root_folder_local='/net/wolf/data/xpcs8/2016-2/';
qmaps_local='/home/8-id-i/partitionMapLibrary/2016-2/';
global SELECT_XPCS_CLUSTER %#ok<NUSED>
SELECT_XPCS_CLUSTER = 'Default' ;
% % %type: SELECT_XPCS_CLUSTER = 'Default' ; %%(if XPCSM2 keeps failing)
%%%%%%%%%%%%%DO NOT TOUCH ABOVE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% %%%%%%%%%%USER DEFINABLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parent_folder='ludwig201608';
%%%%%DO NOT TOUCH ABOVE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
XPCSparams = []; %Initialize to start clean
XPCSparams.stride_frames=1;
XPCSparams.avg_frames=1;
%%
XPCSparams.start_frame = [];
XPCSparams.end_frame = [];
XPCSparams.delays_per_level = [];
XPCSparams.analysis_type = 'Multitau'; %%Twotime
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ii=1:1
    %data_folder=sprintf('A006_SiO2_phi45_0p24deg_sam2_Sq123_%03d',ii);
    data_folder='A015_Sapphire_phi45uvm_0p32deg_sam1_Sq123';
    qmap_filename='ludwig_qmap_A015_Sapphire_phi45_Sq1234_q1';
    [metadatafile,Job_Group]=Create_hdf5_XPCS_Job(root_folder_local,parent_folder,data_folder,fullfile(qmaps_local,qmap_filename),XPCSparams);
    runxpcs_cluster(metadatafile,Job_Group,data_folder);
end




