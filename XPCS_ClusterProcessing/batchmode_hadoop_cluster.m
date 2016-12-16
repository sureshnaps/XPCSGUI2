%%
%%%%%%%%%%%%%DO NOT TOUCH BELOW%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% qmaps_remote='/data/xpcs8/partitionMapLibrary/';
qmaps_local='/net/wolfa/data/xpcs8/partitionMapLibrary/';

% root_folder_remote='/data/xpcs8/2014-2/';
root_folder_local='/net/wolfa/data/xpcs8/2014-2/';
%%%%%%%%%%%%%DO NOT TOUCH ABOVE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% %%%%%%%%%%USER DEFINABLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parent_folder='archer201405';
%%%%%DO NOT TOUCH ABOVE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_folder='test_AA_covalent_PEG5k_2_080C_Sq1_001';
qmap_filename = 'AA_qmap_covalent_Sq1_1';
metadatafile_local=create_hdf5_xpcs_job(root_folder_local,parent_folder,data_folder,fullfile(qmaps_local,qmap_filename),nan,nan,nan);%%ndata0,ndataend,dpl
metadatafile_remote = XPCS_cluster_job_submit(metadatafile_local);


