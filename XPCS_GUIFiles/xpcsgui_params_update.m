%This file should be executed after any changes are made to the
%"ccdimginfo" structure so that the application is updated.
%For example, after loading a batch information, 
%run "xpcsgui_debug" to get the variable "ccdimginfo" into the workspace.
%Then, change any field, for example, 
%"ccdimginfo.batchestodo=[1,2,4,5]

setappdata(hFigXPCSMain,'ccdimginfo',ccdimginfo)

% --
% EOF
