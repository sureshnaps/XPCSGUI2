%
% % Users only need to spacify the below path, rest are all derived from that:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
matroot='/local/XPCSGUI2/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(matroot);

str='XPCS_DetectorFiles';
addpath(fullfile(matroot,str));


str='XPCS_DEVELOPMENT';
addpath(fullfile(matroot,str));


str='XPCS_DisplayFiles';
addpath(fullfile(matroot,str));


str='XPCS_FileReader';
addpath(fullfile(matroot,str));


str='XPCS_Geometry';
addpath(fullfile(matroot,str));


str='XPCS_GUIFiles';
addpath(fullfile(matroot,str));


str='XPCS_HDF5Files';
addpath(fullfile(matroot,str));


str='XPCS_MetaDataFiles';
addpath(fullfile(matroot,str));

str='XPCS_LocalProcessing';
addpath(fullfile(matroot,str));

str='XPCS_ClusterProcessing';
addpath(fullfile(matroot,str));

str='XPCS_TwoTimeG2';
addpath(fullfile(matroot,str));

clear str matroot;
