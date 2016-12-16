function varargout = getsdqphispan
% GETSDQPHISPAN Calculate spans of sq, sphi, dq, dphi. Save to structure
%   ccdimginfo.sqspan
%   ccdimginfo.sphispan
%   ccdimginfo.dqspan
%   ccdimginfo.dphispan
%
%   The cases are:
%   1) from existing results file       -- not implemented yet (uses #2)
%   2) evenly spaced                    -- implemented
%   3) equal dq/q or evenly spaced      -- implemented
%   4) manually set                     -- implemented
%   5) no partion                       -- implemented
%
% Zhang Jiang
% $Revision: 1.0 $  $Date: 2005/01/14 $
% $Revision: 1.1 $  $Date: 2005/09/26 $ by MS 
% $Revision: 1.2 $  $Date: 2007/04/17 $ by MS include anglecontinuity
% $Revision: 1.3 $  $Date: 2014/07/27 $ by ZJ include binning

% =========================================================================
% --- get application data
% =========================================================================
hFigXPCSMain     = findall(0,'Tag','xpcsmain_Fig')                         ;
if ( isappdata(hFigXPCSMain,'ccdimginfo') )
    ccdimginfo = getappdata(hFigXPCSMain,'ccdimginfo')                     ;
else
    return                                                                 ;
end

% =========================================================================
% --- make sure correct usermask exists for batchmode 
% =========================================================================
if ( ccdimginfo.maskMethod == 1 )                                            % already implemented as default mode in loadbatchinfo
    xpixels = ccdimginfo.bin.detector.x_end-ccdimginfo.bin.detector.x_begin+1                      ;
    if ( ccdimginfo.detector.kinetics.mode == 1 )                   % (????? bin to be finished for kinetics mode?????)
        ypixels = ccdimginfo.detector.kinetics.window_size               ;
    else
        ypixels = ccdimginfo.bin.detector.y_end-ccdimginfo.bin.detector.y_begin+1                  ;
    end
    % --- calculate logical (1/0) mask and save it to ccdimginfo.usermask
    ccdimginfo.usermask = ones(ypixels,xpixels)                            ;
    % --- define mask roi as corner points of the whole slice/image roi
    if ccdimginfo.detector.kinetics.mode == 1           % (????? bin to be finished for kinetics mode?????)
        ccdimginfo.maskroi = [1                  1                    ; ...
                              xpixels            ccdimginfo.detector.kinetics.window_size ]   ;
    else
        ccdimginfo.maskroi = [1                  1                 ;    ...
                              xpixels            ypixels            ]      ;
    end
    % ---
    clear xpixels ypixels
end
% ---
if ( ccdimginfo.maskMethod == 2 )
    xpixels = ccdimginfo.bin.detector.x_end-ccdimginfo.bin.detector.x_begin+1                      ;
    if ( ccdimginfo.detector.kinetics.mode == 1 )       % (????? bin to be finished for kinetics mode?????)
        ypixels = ccdimginfo.detector.kinetics.window_size                                    ;
    else
        ypixels = ccdimginfo.bin.detector.y_end-ccdimginfo.bin.detector.y_begin+1                  ;
    end
    % ---
    if ( isempty(ccdimginfo.maskpoints) == 1 )                               % if no mask points are defined use the full image
        ccdimginfo.usermask = ones(ypixels,xpixels)                        ;
    else
        % --- calculate (1/0) mask and save it to ccdimginfo.usermask
        %          ccdimginfo.usermask =                                          ...
        %              outsidepolygonmask(ones(ypixels,xpixels),                  ...
        %                  ccdimginfo.maskpoints(:,1),ccdimginfo.maskpoints(:,2) )   ;
        ccdimginfo.usermask = zeros(ypixels,xpixels);
        for ii=1:length(ccdimginfo.maskpoints)
           ccdimginfo.usermask = ccdimginfo.usermask + ...
                outsidepolygonmask(ones(ypixels,xpixels),...
                ccdimginfo.maskpoints{ii}(:,1),ccdimginfo.maskpoints{ii}(:,2));
        end
        ccdimginfo.usermask(find(ccdimginfo.usermask))=1;
    end
    clear xpixels ypixels                                                  ;
    % --- define mask roi as the minimum rectangle around the chosen ROI
    %     ccdimginfo.maskroi = [min(ccdimginfo.maskpoints(:,1)) min(ccdimginfo.maskpoints(:,2));  ...
    %                           max(ccdimginfo.maskpoints(:,1)) max(ccdimginfo.maskpoints(:,2)) ]    ;
    tmp_maskpoints = cell2mat(ccdimginfo.maskpoints);
    ccdimginfo.maskroi    =                                     ...
        [min(tmp_maskpoints(:,1)) min(tmp_maskpoints(:,2)); ...
        max(tmp_maskpoints(:,1)) max(tmp_maskpoints(:,2))]    ;
end
% ---
if ( ccdimginfo.maskMethod == 3 )
    % ---
    custommaskload(ccdimginfo.maskfile)                                    ;
    ccdimginfo = getappdata(hFigXPCSMain,'ccdimginfo')                     ; % reload application data 'ccdimginfo'
    % ---
    xpixels = ccdimginfo.bin.detector.x_end-ccdimginfo.bin.detector.x_begin+1                      ;
    if ( ccdimginfo.detector.kinetics.mode == 1 )
        ypixels = ccdimginfo.detector.kinetics.window_size                                   ;
    else
        ypixels = ccdimginfo.bin.detector.y_end-ccdimginfo.bin.detector.y_begin+1                  ;
    end
    % ---
    if ( isempty(ccdimginfo.maskpoints) == 1 )                               % if no mask points are defined use the full image
        ccdimginfo.usermask = ones(ypixels,xpixels)                        ;
    else                                                                     % calculate (1/0) mask and save it to ccdimginfo.usermask
        %          ccdimginfo.usermask =                                          ...
        %              outsidepolygonmask(ones(ypixels,xpixels),                  ...
        %                  ccdimginfo.maskpoints(:,1),ccdimginfo.maskpoints(:,2) )   ;
        ccdimginfo.usermask = zeros(ypixels,xpixels);
        for ii=1:length(ccdimginfo.maskpoints)
           ccdimginfo.usermask = ccdimginfo.usermask + ...
                outsidepolygonmask(ones(ypixels,xpixels),...
                ccdimginfo.maskpoints{ii}(:,1),ccdimginfo.maskpoints{ii}(:,2));
        end
        ccdimginfo.usermask(find(ccdimginfo.usermask))=1;
    end
    clear xpixels ypixels                                                  ;
end


% =========================================================================
% --- if needed include blemish file
% =========================================================================
if ( ~isempty(regexp(ccdimginfo.detector.blemish_status{1},'ENABLED','once')) ) 
    blemish = getblemish(ccdimginfo)                                       ;
    ccdimginfo.usermask = ccdimginfo.usermask .* blemish                   ;
    clear blemish                                                          ;
end


% =========================================================================
% --- define minima & maxima
% --- Carefull: in transmission a 2pi jump from -pi to +pi 
% --- needs to be corrected
% =========================================================================
maxq    = max(max(ccdimginfo.qmap(ccdimginfo.usermask~=0)))                ;
minq    = min(min(ccdimginfo.qmap(ccdimginfo.usermask~=0)))                ;
if ( ccdimginfo.geometry == 0 )                                              % transmission geometry
    phiunmasked    = ccdimginfo.phimap(ccdimginfo.usermask~=0)             ;
    phiunmaskednew = anglecontinuity(phiunmasked)                          ;
    % ---
    maxphi  = max(phiunmaskednew)                                          ;
    minphi  = min(phiunmaskednew)                                          ;
    clear phiunmasked phiunmasknew                                         ;
else                                                                         % reflection geometry
    maxphi  = max(max(ccdimginfo.phimap(ccdimginfo.usermask~=0)))          ;
    minphi  = min(min(ccdimginfo.phimap(ccdimginfo.usermask~=0)))          ;
end


% =========================================================================
% --- static partitions
% =========================================================================
switch ccdimginfo.sqMethod
    case 1
        ccdimginfo.sqspan = linspace(minq,maxq,ccdimginfo.snoq+1)          ;
    case 2
        ccdimginfo.sqspan = linspace(minq,maxq,ccdimginfo.snoq+1)          ;
    case 3
        if ( minq > 0 && minq < maxq )
            logsqspan = linspace(log(minq),log(maxq),ccdimginfo.snoq+1)    ;
            ccdimginfo.sqspan = exp(logsqspan)                             ;
        else
            ccdimginfo.sqspan = linspace(minq,maxq,ccdimginfo.snoq+1)      ;
        end
    case 4
        ccdimginfo.sqspan = str2num(ccdimginfo.sqspanstr)                  ;
        ccdimginfo.snoq   = numel(ccdimginfo.sqspan) -1                    ;
    case 5
        ccdimginfo.snoq   = 1                                              ;
        ccdimginfo.sqspan = [minq maxq]                                    ;
end

switch ccdimginfo.sphiMethod
    case 1
        ccdimginfo.sphispan = linspace(minphi,maxphi,ccdimginfo.snophi+1)  ;
    case 2
        ccdimginfo.sphispan = linspace(minphi,maxphi,ccdimginfo.snophi+1)  ;
    case 3
        if ( ccdimginfo.geometry == 1 && minphi > 0 && minphi < maxphi )
            logsphispan =                                               ...
                linspace(log(minphi),log(maxphi),ccdimginfo.snophi+1)      ;
            ccdimginfo.sphispan = exp(logsphispan)                         ;
        else
            ccdimginfo.sphispan =                                       ...
                linspace(minphi,maxphi,ccdimginfo.snophi+1)                ;
        end
    case 4
        ccdimginfo.sphispan = str2num(ccdimginfo.sphispanstr)              ;
        ccdimginfo.snophi   = numel(ccdimginfo.sphispan) -1                ;
    case 5
        ccdimginfo.snophi   = 1                                            ;
        ccdimginfo.sphispan = [minphi maxphi]                              ;
end


% =========================================================================
% --- dynamic partitions
% =========================================================================
if ( ccdimginfo.analysistype == 1 )                                          % get dynamic if analysistype is 1 (dynamic analysis)
    switch ccdimginfo.dqMethod
        case 1
            ccdimginfo.dqspan = linspace(minq,maxq,ccdimginfo.dnoq+1)      ;
        case 2
            ccdimginfo.dqspan = linspace(minq,maxq,ccdimginfo.dnoq+1)      ;
        case 3
        if ( minq > 0 && minq < maxq )
            logdqspan = linspace(log(minq),log(maxq),ccdimginfo.dnoq+1)    ;
            ccdimginfo.dqspan = exp(logdqspan)                             ;
        else
            ccdimginfo.dqspan = linspace(minq,maxq,ccdimginfo.dnoq+1)      ;
        end
        case 4
            ccdimginfo.dqspan = str2num(ccdimginfo.dqspanstr)              ;
            ccdimginfo.dnoq   = numel(ccdimginfo.dqspan) -1                ;
        case 5
            ccdimginfo.dnoq   = 1                                          ;
            ccdimginfo.dqspan = [minq maxq]                                ;
    end
    
    switch ccdimginfo.dphiMethod
        case 1
            ccdimginfo.dphispan = linspace(minphi,maxphi,ccdimginfo.dnophi+1)  ;
        case 2
            ccdimginfo.dphispan = linspace(minphi,maxphi,ccdimginfo.dnophi+1)  ;
        case 3
        if ( ccdimginfo.geometry == 1 && minphi > 0 && minphi < maxphi )
            logdphispan =                                               ...
                linspace(log(minphi),log(maxphi),ccdimginfo.dnophi+1)      ;
            ccdimginfo.dphispan = exp(logdphispan)                         ;
        else
            ccdimginfo.dphispan =                                       ...
                linspace(minphi,maxphi,ccdimginfo.dnophi+1)                ;
        end
        case 4
            ccdimginfo.dphispan = str2num(ccdimginfo.dphispanstr)          ;
            ccdimginfo.dnophi   = numel(ccdimginfo.dphispan) -1            ;
        case 5
            ccdimginfo.dnophi   = 1                                        ;
            ccdimginfo.dphispan = [minphi maxphi]                          ;
    end
end
clear minq maxq minphi maxphi


% =========================================================================
% --- save the application data
% =========================================================================
if (nargout == 1)
    varargout{1}=ccdimginfo;
end
setappdata(hFigXPCSMain,'ccdimginfo',ccdimginfo)                           ;
clear hFigXPCSMain                                              ; 
% =========================================================================
% --- finish saving the application data
% =========================================================================

% whos

% ---
% EOF
