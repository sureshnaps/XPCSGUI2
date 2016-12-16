function varargout = custommaskload(varargin)

% =========================================================================
% --- get ccdimginfo
% =========================================================================
hFigXPCSMain   = findall(0,'Tag','xpcsmain_Fig')                           ;
if isappdata(hFigXPCSMain,'ccdimginfo')
    ccdimginfo = getappdata(hFigXPCSMain,'ccdimginfo')                     ;
else
    return                                                                 ;
end

% =========================================================================
% --- load MaskInfo from user defined file or from 'custommask.mat' 
% =========================================================================
currentPath  = pwd                                                         ;
if ( nargin >= 1 )                                                         ; % check if a file name is supplied (a better check is needed)
    file = varargin{1}                                                     ; % assign the input variable to file
    [fid,message] = fopen(file,'r')                                        ;        
    if ( fid == -1 )                                                         % return if open fails
        uiwait(msgbox(message,'File Open Error','error','modal'))          ;
        fclose(fid)                                                        ;
        [filename,filepath] = uigetfile({'*.mat','Mask Files (*.mat)'}  ...
                              ,'Select Mask File','MultiSelect','off')     ; % dialog to select file
        if isequal([filename,filepath],[0,0])
            restorePath(currentPath)                                       ;
            return                                                         ;
        end
        file = fullfile(filepath,filename)                                 ; % the whole filename
        restorePath(currentPath)                                           ; % restore path
    end
%     clear  fid message                                                     ;
else
    [filename,filepath] = uigetfile({'*.mat','Mask Files (*.mat)'}      ...
                                   ,'Select Mask File','MultiSelect','off'); % dialog to select file
    if isequal([filename,filepath],[0,0])
        restorePath(currentPath)                                           ;
        return                                                             ;
    end
    file = fullfile(filepath,filename)                                     ; % the whole filename
    restorePath(currentPath)                                               ; % restore path
end
load(file,'MaskInfo')                                                      ;
fclose(fid);
clear  fid message                                                         ;
clear currentPath filename filepath varargin                               ;


% =========================================================================
% --- check if MaskInfo contains a valid mask
% --- (!check of valid polygon is still missing!)
% =========================================================================
xpixels = ccdimginfo.bin.detector.x_end-ccdimginfo.bin.detector.x_begin+1                          ;
if ( ccdimginfo.detector.kinetics.mode == 1 )
    ypixels = ccdimginfo.detector.kinetics.window_size                                        ;
else
    ypixels = ccdimginfo.bin.detector.y_end-ccdimginfo.bin.detector.y_begin+1                      ;
end
% ---
Valid = 0                                                                  ;
for ii=1:length(MaskInfo.maskpoints)
    minRowMaskPoints = min(MaskInfo.maskpoints{ii}(:,2))                           ;
    maxRowMaskPoints = max(MaskInfo.maskpoints{ii}(:,2))                           ;
    minColMaskPoints = min(MaskInfo.maskpoints{ii}(:,1))                           ;
    maxColMaskPoints = max(MaskInfo.maskpoints{ii}(:,1))                           ;
    if (  minRowMaskPoints >= 1 && maxRowMaskPoints <= ypixels               ...
            && minColMaskPoints >= 1 && maxColMaskPoints <= xpixels               ...
            && numel(MaskInfo.maskpoints{ii}) >= 6                                    ...
            && mod(numel(MaskInfo.maskpoints{ii}),2) == 0                             ...
            && polyarea(MaskInfo.maskpoints{ii}(:,1),MaskInfo.maskpoints{ii}(:,2)) > 0 )
        Valid = 1                                                              ;
    else
        uiwait(msgbox(message,'This is not a valid mask! Use whole image!'  ...
            ,'error','modal'))                                               ;
    end
end


% =========================================================================
% --- save masking information to MaskInfo
% =========================================================================
if ( Valid == 1 )
    ccdimginfo.maskMethod = 3                                              ;
    ccdimginfo.maskfile   = file                                           ;
    ccdimginfo.maskpoints = MaskInfo.maskpoints                            ;
    %     ccdimginfo.maskroi    = [minColMaskPoints minRowMaskPoints;         ...
    %                              maxColMaskPoints maxRowMaskPoints]            ;
    tmp_maskpoints = cell2mat(ccdimginfo.maskpoints);
    ccdimginfo.maskroi    =                                     ...
        [min(tmp_maskpoints(:,1)) min(tmp_maskpoints(:,2)); ...
        max(tmp_maskpoints(:,1)) max(tmp_maskpoints(:,2))]    ;
    clear minColMaskPoints minRowMaskPoints maxColMaskPoints               ;
    clear maxRowMaskPoints file  tmp_maskpoints                                   ;
else
    ccdimginfo.maskMethod = 1                                              ;
    ccdimginfo.maskfile   = ''                                             ;
    ccdimginfo.maskpoints = {[1 1; xpixels 1; xpixels ypixels; 1 ypixels]}   ;
    if ( ccdimginfo.kinetics == 1 )
        ccdimginfo.maskroi = [1 1; xpixels ccdimginfo.kinwinsize ]         ;
    else
        ccdimginfo.maskroi = [1 1; xpixels ypixels]                        ;
    end
end
clear xpixels ypixels Valid


% =========================================================================
% --- overwrite ccdimginfo with the loaded information
% =========================================================================
setappdata(hFigXPCSMain,'ccdimginfo',ccdimginfo)                           ;


% =========================================================================
% --- assign possible function output
% =========================================================================
varargout{1} = MaskInfo                                                    ;


% =========================================================================
% --- clear application data 'ccdimginfo'
% =========================================================================
clear hFigXPCSMain ccdimginfo MaskInfo                                     ;


%==========================================================================
% --- restore to current path
%==========================================================================
function restorePath(currentPath)
path_str = ['cd ','''',currentPath,'''']                                   ;
eval(path_str)                                                             ;


% ---
% EOF
