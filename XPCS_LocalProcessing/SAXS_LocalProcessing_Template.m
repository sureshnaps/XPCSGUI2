%%
%%%%%%%%%%%%%DO NOT TOUCH BELOW%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
root_folder_local='/home/8-id-i/2016-3/';
qmaps_local='/home/8-id-i/partitionMapLibrary/2016-3/';
%%%%%%%%%%%%%DO NOT TOUCH ABOVE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% %%%%%%%%%%USER DEFINABLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parent_folder='vinod201611';
%%%%%DO NOT TOUCH ABOVE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
XPCSparams = []; %Initialize to start clean
XPCSparams.stride_frames=1;
XPCSparams.avg_frames=1;
%%
XPCSparams.start_frame = [];
XPCSparams.end_frame = [];
XPCSparams.analysis_type = 'Static';

XPCSparams.partition_name = {'q','phi'};
XPCSparams.partition_static = [180,1];
mask= load('/home/8-id-i/2016-3/vinod201611/Local_results/mask_test.mat');
XPCSparams.usermask = logical(mask.usermask);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_folder='V02_15um_Xp5.14_Zm5.20';
metadatafile = dir(fullfile(root_folder_local,parent_folder,data_folder,'*.batchinfo'));
metadatafile = fullfile(root_folder_local,parent_folder,data_folder,metadatafile.name);
[img,ccdimginfo] = create_IMM_dataMatrix(metadatafile,XPCSparams,'');
viewresultinfo = Process_img_StaticCalc(img,ccdimginfo);
% viewresult(viewresultinfo);
savefull = fullfile(root_folder_local,parent_folder,'Local_results',[data_folder,'.mat']);
if (exist(savefull,'file') == 2)
    savefull = fullfile(root_folder_local,parent_folder,'Local_results',[data_folder,datestr(now,'_yyyymmddTHHMMSS'),'.mat']);
end
save(savefull,'-mat','-v7.3','ccdimginfo','viewresultinfo');
viewresult(savefull);




