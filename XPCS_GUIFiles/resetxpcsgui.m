function resetxpcsgui(varargin)
% --- RESETXPCSGUI Close all windows related to xpcsgui except xpcsgui and
% --- reset ccdimginfo. Called by loadbatchinfo.m before new batchinfo file
% --- is loaded.
%
% --- Zhang Jiang
% --- $Revision: 1.0 $  $Date: 2005/01/07 $


% =========================================================================
% --- check for ccdimginfo & if exist remove the application data
% =========================================================================
hFigXPCSMain = findall(0,'Tag','xpcsmain_Fig')                             ;
if isempty(hFigXPCSMain)
    return                                                                 ;
end
if isappdata(hFigXPCSMain,'ccdimginfo')                                    ;
    rmappdata(hFigXPCSMain,'ccdimginfo')                                   ;
end

% =========================================================================
% --- close some windows
% =========================================================================
delete(findall(0,'Tag','viewinfo_Fig'))                                    ;
delete(findall(0,'Tag','viewsystem_Fig'))                                  ;
delete(findall(0,'Tag','viewanalysis_Fig'))                                ;
delete(findall(0,'Tag','mask_Fig'))                                        ;
delete(findall(0,'Tag','showimage_fig1'))                                  ; 
delete(findall(0,'Tag','showimage_fig2'))                                  ;
delete(findall(0,'Tag','showmaskpartition_Fig'))                           ;

% =========================================================================
% --- close some result windos
% =========================================================================
%%closeshowfigures                                                           ;

% ---
% EOF
