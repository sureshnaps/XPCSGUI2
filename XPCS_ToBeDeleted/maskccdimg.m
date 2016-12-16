function maskccdimg(varargin)
% MASKCCDIMG Called by viewanalysis PUSHBUTTON mask to allow user to 
%   define the polygon region used for analysis.
%
%   If ccdimginfo.testimg exists (from showimage.m), it is displayed;   
%   otherwise load images and display in the same way as showimage.m does.
% 
% Zhang Jiang & Michael Sprung
% $Revision: 1.0 $  $Date: 2005/01/11 $
% $Revision: 2.0 $  $Date: 2006/09/30 $
% $Revision: 2.1 $  $Date: 2009/09/08 $ Enable selection of multiple
%   mask polygons. By Zhang Jiang

% =========================================================================
% --- get application data
% =========================================================================
hFigXPCSMain     = findall(0,'Tag','xpcsmain_Fig');
hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig');
ccdimginfo       = getappdata(hFigXPCSMain,'ccdimginfo');
%assignin('base','ccdimginfo',ccdimginfo);

% =========================================================================
% --- change status bar of fig viewanalysis and disable pushbuttons
% =========================================================================
hEditStatus   = findall(hFigViewanalysis,'Tag','figviewanalysis_TextStatus');
originalColor = get(hEditStatus,'Color');
originalText  = get(hEditStatus,'String');
set(hEditStatus,'String','Status: Loading images ...','color','r');
set(findall(hFigViewanalysis,'Tag','viewanalysis_PushbuttonClose'),'Enable','off');
set(findall(hFigViewanalysis,'Tag','viewanalysis_PushbuttonApply'),'Enable','off');
set(findall(hFigViewanalysis,'Tag','viewanalysis_PushbuttonShow'),'Enable','off');
set(findall(hFigViewanalysis,'Tag','figviewanalysis_PushbuttonNewMask'),'Enable','off');
pause(0.001);

% =========================================================================
% --- if ccdimginfo.testimg does not exist than create it at this point 
% =========================================================================
selectedBatch=ccdimginfo.batchestodo;
if (1)%%( ~isfield(ccdimginfo,'testimg'))
    % --- deterimine the data and dark frames to be loaded
    displayBatchIndex = ccdimginfo.batchestodo(1);
    dataIndex = ccdimginfo.xpcs.data_begin_todo(displayBatchIndex):ccdimginfo.xpcs.data_end_todo(displayBatchIndex);
    darkIndex = ccdimginfo.xpcs.dark_begin_todo(displayBatchIndex):ccdimginfo.xpcs.dark_end_todo(displayBatchIndex);
    % ---
    if ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'Princeton', 'once')) )
        dataIndexToDisplay = dataIndex(1:min(50,length(dataIndex)))             ; % 50 data images
        darkIndexToDisplay = darkIndex(1:min(10,length(darkIndex)))             ; % 10 dark images
    else
        dataIndexToDisplay = dataIndex(1:min(500,length(dataIndex)))            ; % 100 data images for SMD camera
        darkIndexToDisplay = darkIndex(1:min(100,length(darkIndex)))            ; % 100 dark images for SMD camera
    end
    
    % --- get data images from image file
    sumData = 0;
    for iDataIndexToDisplay = dataIndexToDisplay
        f = openfile(ccdimginfo.xpcs.input_file_local{selectedBatch},uint32(iDataIndexToDisplay));
        sumData = single(f.imm) + sumData;
    end
    % --- get dark images from image file
    sumDark = 0;
    foo = regexp(ccdimginfo.xpcs.compression,'ENABLED', 'once');
    if isempty(foo{1})
        for iDarkIndexToDisplay = darkIndexToDisplay
            f = openfile(ccdimginfo.xpcs.input_file_local{selectedBatch},uint32(iDarkIndexToDisplay));
            sumDark = single(f.imm) + sumDark;
        end
    end
    % --- calculate true data image by subtracting dark & applying lld
    if ( ~isempty(darkIndexToDisplay) )
        trueData = sumData/length(dataIndexToDisplay) - sumDark/length(darkIndexToDisplay);
    else
        trueData = sumData/length(dataIndexToDisplay);
    end
%     trueData( trueData <= abs(ccdimginfo.xpcs.lld) ) = 0;
    % --- save trueData to testimg
    trueData = binimg(trueData,ccdimginfo.bin.swbinX,ccdimginfo.bin.swbinY);
    ccdimginfo.testimg = trueData;
    setappdata(hFigXPCSMain,'ccdimginfo',ccdimginfo);
    clear sumData sumDark trueData f dataIndex darkIndex;
    clear displayBatchIndex dataIndexToDisplay darkIndexToDisplay;
end

% =========================================================================
% --- create figure layout for 'mask_Fig'
% =========================================================================
delete(findall(0,'Tag','mask_Fig'));
figureSize = [640 480];
hFigMask = figure('BackingStore','off','Units','pixels'                 ...
                 ,'DockControls','off','PaperOrient','portrait'         ...
                 ,'IntegerHandle','off','NumberTitle','off'             ...
                 ,'MenuBar','none','color',[1 1 0.85],'Toolbar','none'  ...
                 ,'Name','XPCS - Define Mask Polygons'  ...
                 ,'Position',[300,225,figureSize],'Tag','mask_Fig'      ...
                 ,'WindowStyle','normal','WindowButtonDownFcn',''       ...
                 ,'WindowButtonMotionFcn',@maskfig_WindowButtonMotionFcn...
                 ,'WindowButtonUpFcn','','HandleVisibility','callback'  ...
                 ,'UserData',[])                                           ;
% =========================================================================
% --- toolbar layout
% =========================================================================
hToolbar = uitoolbar(hFigMask,'Tag','mask_fig_Toolbar');
iconToolbarLoadMask = load('opendoc.mat');
hToolbarLoadMask    = uipushtool(hToolbar,...
    'Tag','toolbarLoadMask',...
    'CDATA',iconToolbarLoadMask.cdata,...
    'TooltipString','Load Custom Mask',...
    'ClickedCallback',@toolbarLoadMaskFcn);
iconToolbarSaveMask = load('savedoc.mat');
hToolbarSaveMask    = uipushtool(hToolbar,...
    'Tag','toolbarSaveMask',...
    'CDATA',iconToolbarSaveMask.cdata,...
    'TooltipString','Save Custom Mask',...
    'ClickedCallback',@toolbarSaveMaskFcn);
iconToolbarZoom = load('zoom.mat')                                         ;
hToolbarZoom = uitoggletool(hToolbar,'CDATA',iconToolbarZoom.zoomCData  ...
    ,'Separator','on','TooltipString','Zoom','State','off'              ...
    ,'ClickedCallback',@toolbarZoomFcn,'Tag','toolbarZoom')                ;
iconToolbarPan = load('pan.mat')                                           ;
hToolbarPan = uitoggletool(hToolbar,'CDATA',iconToolbarPan.cdata        ...
    ,'TooltipString','Pan','ClickedCallback',@toolbarPanFcn             ...
    ,'Tag','toolbarPan')                                                   ;
iconToolbarColormapeditor = load('colormapeditor.mat')                     ;
hToolbarColormapeditor = uipushtool(hToolbar                            ...
    ,'CDATA',iconToolbarColormapeditor.cdata                            ...
    ,'TooltipString','Edit Colormap','ClickedCallback','colormapeditor;'...
    ,'Tag','toolbarColormapeditor')                                        ;
iconxpcsgui = load('iconxpcsgui.mat');
hToolbarMask = uipushtool(hToolbar,...
    'CDATA',iconxpcsgui.maskCData,...
    'Separator','on',...
    'TooltipString','Start Masking',...
    'ClickedCallback',@toolbarMaskFcn,...
    'Tag','toolbarMask');
hToolbarMaskFinish = uipushtool(hToolbar,...
    'Tag','toolbarMaskFinish',...
    'CDATA',iconxpcsgui.maskfinishCData,...
    'TooltipString','Finish Masking',...
    'ClickedCallback',@toolbarMaskFinishFcn,...
    'Enable','off');
hToolbarMaskClear = uipushtool(hToolbar,...
    'CDATA',iconxpcsgui.maskclearCData,...
    'TooltipString','Clear Mask',...
    'ClickedCallback',@toolbarMaskClearFcn,...
    'Tag','toolbarClear');
uicontrol('Parent',hFigMask,'Style','Text','BackgroundColor',[1 1 0.85] ...
         ,'String',' ','units','normalized','HorizontalAlignment','left'...
         ,'position',[0.05 0.01 0.5 0.05],'Tag','mouseposition')           ;

% =========================================================================
% --- reset toolbar controls of image figure
% =========================================================================
resetToolbar(hFigMask)                                                     ;

% =========================================================================
% --- create displayImage
% =========================================================================
displayImage = zeros(size(ccdimginfo.usermask))                            ;

if ( ccdimginfo.detector.kinetics.mode == 0 )
    sliceStart = 1                                                     ; % in full frame / roi mode use this as slice start
    sliceEnd   = ccdimginfo.bin.detector.y_end - ccdimginfo.bin.detector.y_begin + 1           ; % in full frame / roi mode use this as slice end
    displayImage(:,:) = displayImage(:,:)                               ...
        + ccdimginfo.testimg(sliceStart:sliceEnd,:)          ; % sum of all good slices
else                        %(????? bin to be finished for kinetics mode?????)
    for j = 1 : (ccdimginfo.detector.kinetics.last_usable_slice - ccdimginfo.detector.kinetics.first_usable_slice + 1)               % loop over good slices only        
        k          = (j-1) + ccdimginfo.detector.kinetics.first_usable_slice                          ; % shift the counter in a way that ccdimginfo.firstslice == 1
        sliceStart = ccdimginfo.detector.kinetics.sliceinfo(k,1)                             ; % get the sliceStart position for each slice
        sliceEnd   = ccdimginfo.detector.kinetics.sliceinfo(k,2)                             ; % get the sliceEnd   position for each slice
        displayImage(:,:) = displayImage(:,:)                               ...
            + ccdimginfo.testimg(sliceStart:sliceEnd,:)          ; % sum of all good slices
    end
end
    
    
% =========================================================================
% --- apply upper level discrimination to displayImage
% =========================================================================
% if ( ccdimginfo.detector ~= 5 && ccdimginfo.detector ~= 6 )
%     displayImage(displayImage > 1.1*(min(min(displayImage(:))+1500,max(displayImage(:))+1))) = ...
%                                 1.1*(min(min(displayImage(:))+1500,max(displayImage(:))+1))       ;
% else
%     displayImage(displayImage > 1.1*(min(min(displayImage(:))+ 100,max(displayImage(:))+1))) = ...
%                                 1.1*(min(min(displayImage(:))+ 100,max(displayImage(:))+1))       ;
% end


% =========================================================================
% --- activate figure and plot average of images
% =========================================================================
figure(hFigMask)                                                           ;
try
    %hImm = imagesc(displayImage,[0,round(max(max(displayImage(:))/2,10))]);
    data_std = std(displayImage(:));
    data_mean = mean(displayImage(:));
    hImm = imagesc(displayImage,[max(data_mean-5*data_std,0),data_mean+5*data_std]);
catch
    hImm = imagesc(displayImage,[0,100]); %%some constant value so it does not crash
end
% ---
if (  ccdimginfo.geometry == 0 &&                                       ...
      max(size(displayImage,1),size(displayImage,2))                    ...
    / min(size(displayImage,1),size(displayImage,2)) <= 4/3 )
    axis image                                                             ;
end
axis xy;
% ---
set(hImm,'Tag','mask_fig_testimage')                                       ;
uicontrol('Parent',hFigMask,'Style','Text','BackgroundColor',[1 1 0.85] ...
         ,'String',' ','Units','normalized','HorizontalAlignment','left'...
         ,'Position',[0.05 0.01 0.5 0.05],'Tag','mouseposition')           ;
set(get(hImm,'Parent'),'YDir','normal')                                    ;
% --- plot pre-mask if it is exist
if isfield(ccdimginfo,'maskpoints')
    maskpoints = ccdimginfo.maskpoints;
    if ~isempty(maskpoints) & iscell(maskpoints)
        for ii=1:length(maskpoints)
            if polyarea(maskpoints{ii}(:,1),maskpoints{ii}(:,2))>0
                line(...
                    'Parent',get(hImm,'Parent'),...
                    'XData',[maskpoints{ii}(:,1);maskpoints{ii}(1,1)],...
                    'YData',[maskpoints{ii}(:,2);maskpoints{ii}(1,2)],...
                    'Tag','maskpointline','color','g','LineWidth',2);
            end
        end
    end
end
clear displayImage hImm maskpoints

%==========================================================================
% --- set firstmask flag 
setappdata(hFigMask,'flagfirstmask',1);         
%==========================================================================

%==========================================================================
% --- set status bar back to Ready
%==========================================================================
set(findall(hFigViewanalysis,'Tag',                                     ...
           'viewanalysis_PushbuttonClose'),'Enable','on')                  ;
set(findall(hFigViewanalysis,'Tag',                                     ...
           'viewanalysis_PushbuttonApply'),'Enable','on')                  ;
set(findall(hFigViewanalysis,'Tag',                                     ...
           'viewanalysis_PushbuttonShow'),'Enable','on')                   ;
set(findall(hFigViewanalysis,'Tag',                                     ...
           'figviewanalysis_PushbuttonNewMask'),'Enable','on')             ;
set(hEditStatus,'String',originalText,'color',originalColor)               ;



%==========================================================================
% --- toolbar load custom mask callback
%==========================================================================
function toolbarLoadMaskFcn(hObject,eventdata)
% ---
hFigXPCSMain     = findall(0,'Tag','xpcsmain_Fig')                         ;
hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig')                     ;
hFigMask         = findall(0,'Tag','mask_Fig')                             ;
hToolbarZoom     = findall(hFigMask,'Tag','toolbarZoom')                   ;
hToolbarPan      = findall(hFigMask,'Tag','toolbarPan')                    ;
hToolbarLoadMask = findall(hFigMask,'Tag','toolbarLoadMask')               ;
hToolbarSaveMask = findall(hFigMask,'Tag','toolbarSaveMask')               ;
ccdimginfo       = getappdata(hFigXPCSMain,'ccdimginfo')                   ;

% ---
pan  off                                                                   ;
zoom off                                                                   ;
set(hToolbarPan ,'state','off')                                            ;
set(hToolbarZoom,'state','off')                                            ;

% --- load MaskInfo from user supplied file 
currentPath  = pwd                                                         ;
[filename,filepath] = uigetfile({'*.mat','Mask Files (*.mat)'}          ...
                               ,'Select Mask File','MultiSelect','off')    ; % dialog to select file
if isequal([filename,filepath],[0,0])
    restorePath(currentPath)                                               ;
    return                                                                 ;
end
file = fullfile(filepath,filename)                                         ; % the whole filename
restorePath(currentPath)                                                   ; % restore path
load(file,'MaskInfo')                                                      ;

% --- check if MaskInfo contains a valid mask
% --- (!check of valid polygon is still missing!)
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
        uiwait(msgbox('This is not a valid mask! Use whole image!','error','modal'))                                               ;
    end
end
% --- save masking information to MaskInfo
if ( Valid == 1 )
    ccdimginfo.maskMethod = 2                                              ;
    ccdimginfo.maskfile   = file                                           ;
    ccdimginfo.maskpoints = MaskInfo.maskpoints                            ;
    %     ccdimginfo.maskroi    = [minColMaskPoints minRowMaskPoints;         ...
    %                              maxColMaskPoints maxRowMaskPoints]            ;
    tmp_maskpoints = cell2mat(ccdimginfo.maskpoints);
    ccdimginfo.maskroi    =                                     ...
        [min(tmp_maskpoints(:,1)) min(tmp_maskpoints(:,2)); ...
        max(tmp_maskpoints(:,1)) max(tmp_maskpoints(:,2))]    ;
else
    
    ccdimginfo.maskMethod = 1                                              ;
    ccdimginfo.maskfile   = ''                                             ;
    ccdimginfo.maskpoints = {[1 1; xpixels 1; xpixels ypixels; 1 ypixels]}   ;
    if ( ccdimginfo.detector.kinetics.mode == 1 )
        ccdimginfo.maskroi = [1 1; xpixels ccdimginfo.detector.kinetics.window_size ]         ;
    else
        ccdimginfo.maskroi = [1 1; xpixels ypixels]                        ;
    end
end
% --- store masking information to application data of hFigXPCSMain
setappdata(hFigXPCSMain,'ccdimginfo',ccdimginfo)                           ;
% --- save maskpoints to application data of hFigViewanalysis
%maskpoints = MaskInfo.maskpoints                                           ;
maskpoints = ccdimginfo.maskpoints;
setappdata(hFigViewanalysis,'maskpoints',maskpoints)                       ;
setappdata(hFigViewanalysis,'usermaskflag',0)                              ;
figure(hFigMask)                                                           ;
set(gcf,'selected','on')                                                   ;
delete(findall(hFigMask,'Tag','maskpointline'))                            ;
for ii=1:length(maskpoints)
    if polyarea(maskpoints{ii}(:,1),maskpoints{ii}(:,2))>0
        line(...
            'Parent',get(findall(hFigMask,'tag','mask_fig_testimage'),'Parent'),...  
            'XData',[maskpoints{ii}(:,1);maskpoints{ii}(1,1)],...
            'YData',[maskpoints{ii}(:,2);maskpoints{ii}(1,2)],...
            'Tag','maskpointline','color','g','LineWidth',2);
    end
end

%==========================================================================
% --- toolbar save custom mask callback
%==========================================================================
function toolbarSaveMaskFcn(hObject,eventdata)
% ---
hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig')                     ;
hFigMask         = findall(0,'Tag','mask_Fig')                             ;
hToolbarZoom     = findall(hFigMask,'Tag','toolbarZoom')                   ;
hToolbarPan      = findall(hFigMask,'Tag','toolbarPan')                    ;
maskpoints       = getappdata(hFigViewanalysis,'maskpoints')               ;
usermaskflag     = getappdata(hFigViewanalysis,'usermaskflag')             ;
% ---
pan  off                                                                   ;
zoom off                                                                   ;
set(hToolbarPan ,'state','off')                                            ;
set(hToolbarZoom,'state','off')                                            ;
% ---
if ( usermaskflag == 0 && ~isempty(maskpoints) == 1 )                        % masking is finished & and a new mask exists
    currentPath  = pwd                                                     ;
    MaskInfo.maskpoints = maskpoints                                       ;
    [filename,filepath] = uiputfile({'*.mat','Save Mask File (*.mat)'})    ; % dialog to select file
    if isequal([filename,filepath],[0,0])
        restorePath(currentPath)                                           ;
        return                                                             ;
    end
    file = fullfile(filepath,filename)                                     ; % the whole filename
    save(file,'MaskInfo')                                                  ;
    restorePath(currentPath)                                               ; % restore path    
else
    uiwait(msgbox('Can not save mask file!','error','modal'))              ;
    figure(hFigMask)                                                       ;
    set(gcf,'selected','on')                                               ;
end


%==========================================================================
% --- toolbar zoom callback
%==========================================================================
function toolbarZoomFcn(hObject,eventdata)
hFig = gcbf                                                                ;
hToolbarZoom     = findall(hFig,'Tag','toolbarZoom')                       ;
hToolbarPan      = findall(hFig,'Tag','toolbarPan')                        ;
hToolbarLoadMask = findall(hFig,'Tag','toolbarLoadMask')                   ;
hToolbarSaveMask = findall(hFig,'Tag','toolbarSaveMask')                   ;
pan  off                                                                   ;
zoom                                                                       ;
set(hToolbarPan,'state','off')                                             ;


%==========================================================================
% --- toolbar pan callback
%==========================================================================
function toolbarPanFcn(hObject,eventdata)
hFig = gcbf                                                                ;
hToolbarZoom     = findall(hFig,'Tag','toolbarZoom')                       ;
hToolbarPan      = findall(hFig,'Tag','toolbarPan')                        ;
hToolbarLoadMask = findall(hFig,'Tag','toolbarLoadMask')                   ;
hToolbarSaveMask = findall(hFig,'Tag','toolbarSaveMask')                   ;
zoom off                                                                   ;
pan                                                                        ;
set(hToolbarZoom,'state','off')                                            ;


%==========================================================================
% --- toolbar mask callback
%==========================================================================
function toolbarMaskFcn(hObject,eventdata)
hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig');
hFigMask         = findall(0,'Tag','mask_Fig');
set(findall(hFigMask,'Tag','toolbarMaskFinish'),'Enable','on');
resetToolbar(hFigMask);

% --- reset maskpoints & set flag to 1 to get more points 
% --- (toolbarMaskFinishFcn turns flag to 0 to stop getting any more point)
setappdata(hFigMask,'singlemaskpoints',[]);
setappdata(hFigViewanalysis,'usermaskflag',1);
if getappdata(hFigMask,'flagfirstmask');           % initialize the maskpoints when select the first mask region
        delete(findall(gcf,'Tag','maskpointline'));
end

% --- use windowbuttondownfcn to get points
set(hFigMask,'WindowButtonDownFcn',@maskfig_WindowButtonDownFcn);


%==========================================================================
% --- toolbar mask callback
%==========================================================================
function toolbarMaskFinishFcn(hObject,eventdata)
hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig');
hFigMask = findall(0,'Tag','mask_Fig');
resetToolbar(hFigMask);

% --- set flag to 0 to stop getting any more points
setappdata(hFigViewanalysis,'usermaskflag',0);
set(hFigMask,'WindowButtonDownFcn','');

% --- plot polygon (if # of points is less than 3, set maskpoints to [])
singlemaskpoints = getappdata(hFigMask,'singlemaskpoints');
if ~isempty(singlemaskpoints) & polyarea(singlemaskpoints(:,1),singlemaskpoints(:,2))>0
    if getappdata(hFigMask,'flagfirstmask');           % initialize the maskpoints when select the first mask region
        delete(findall(gcf,'Tag','maskpointline'));
        setappdata(hFigViewanalysis,'maskpoints',{});
        setappdata(hFigMask,'flagfirstmask',0);
    end
    line('Parent',get(findall(hFigMask,...
        'tag','mask_fig_testimage'),'Parent'),...
        'XData',[singlemaskpoints(:,1);singlemaskpoints(1,1)],...
        'YData',[singlemaskpoints(:,2);singlemaskpoints(1,2)],...
        'Tag','maskpointline',...
        'color','g','LineWidth',2);
    maskpoints = [getappdata(hFigViewanalysis,'maskpoints');singlemaskpoints];
    setappdata(hFigViewanalysis,'maskpoints',maskpoints);
else
    setappdata(hFigMask,'singlemaskpoints',[]);
    hMSGBox = msgbox('Invalid mask polygon !','Mask Error','error','modal');
    set(hMSGBox,'color',[1 1 0.85]);
    uiwait(hMSGBox);
end
delete(findall(gcf,'Tag','maskpointline','Color','r'));


%==========================================================================
% --- toolbar mask callback
%==========================================================================
function toolbarMaskClearFcn(hObject,eventdata)
hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig');
hFigMask         = findall(0,'Tag','mask_Fig');
resetToolbar(hFigMask);
delete(findall(hFigMask,'Tag','maskpointline'));
setappdata(hFigMask,'singlemaskpoints',[]);
setappdata(hFigViewanalysis,'maskpoints',{});


%==========================================================================
% --- maskfig windowbuttonmotionfcn callback
%==========================================================================
function maskfig_WindowButtonMotionFcn(hObject,eventdata)
set(gcf,'selected','on')                                                   ;
pointPosition = get(gca,'CurrentPoint')                                    ;
XLim=get(gca,'XLim')                                                       ;
YLim=get(gca,'YLim')                                                       ;
XLimFlag=(pointPosition(1,1)>=XLim(1) & pointPosition(1,1)<=XLim(2))       ;
YLimFlag=(pointPosition(1,2)>=YLim(1) & pointPosition(1,2)<=YLim(2))       ;
cdata = get(findall(gcf,'type','image'),'cdata')                           ;
xpos = round(pointPosition(1,1))                                           ;
ypos = round(pointPosition(1,2))                                           ;
if ( xpos >= 1 & xpos <= size(cdata,2) ...
   & ypos >= 1 & ypos <= size(cdata,1) & XLimFlag == 1 & YLimFlag ==1)
    if getappdata(findall(0,'Tag','viewanalysis_Fig'),'usermaskflag') == 1
        set(gcf,'Pointer','fullcrosshair')                                 ;
    else
        set(gcf,'Pointer','crosshair')                                     ;
    end
    set(findall(gcf,'Tag','mouseposition'),'string',                    ...
        ['x=',num2str(xpos),' y=',num2str(ypos),' value=',              ...
        num2str(cdata(ypos,xpos))])                                        ;
else
    set(gcf,'Pointer','arrow')                                             ;
end
clear XLim YLim XLimFlag YLimFlag                                          ;
clear pointPosition xpos ypos cdata                                        ;


%==========================================================================
% --- maskfig windowbuttondownfcn callback
%==========================================================================
function maskfig_WindowButtonDownFcn(hObject,eventdata)
hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig');
hFigMask         = findall(0,'Tag','mask_Fig');
if getappdata(hFigViewanalysis,'usermaskflag') == 1
    pointPosition = get(gca,'CurrentPoint');
    XLim=get(gca,'XLim');
    YLim=get(gca,'YLim');
    XLimFlag=(pointPosition(1,1)>=XLim(1) & pointPosition(1,1)<=XLim(2));
    YLimFlag=(pointPosition(1,2)>=YLim(1) & pointPosition(1,2)<=YLim(2));
    cdata = get(findall(gcf,'type','image'),'cdata');
    xpos = round(pointPosition(1,1));
    ypos = round(pointPosition(1,2));
    if ( xpos >= 1 & xpos <= size(cdata,2) ...
       & ypos >= 1 & ypos <= size(cdata,1) & XLimFlag == 1 & YLimFlag ==1) ;
        singlemaskpoints = [ getappdata(hFigMask,'singlemaskpoints'); [xpos, ypos]];
        setappdata(hFigMask,'singlemaskpoints',singlemaskpoints);
        line(...
            'Parent',gca,...
            'XData',singlemaskpoints(:,1),...
            'YData',singlemaskpoints(:,2),...
            'Tag','maskpointline',...
            'color','r','LineWidth',2);
    end
    clear cdata pointPosition XLim YLim XLimFlag YLimFlag singlemaskpoints;
end


%==========================================================================
% --- reset toolbars
%==========================================================================
function resetToolbar(varargin)
hFigMask = varargin{1}                                                     ;
hToolbarZoom = findall(hFigMask,'Tag','toolbarZoom')                       ;
hToolbarPan = findall(hFigMask,'Tag','toolbarPan')                         ;
set(hToolbarZoom,'state','off')                                            ;
set(hToolbarPan,'state','off')                                             ;
zoom(hFigMask,'off')                                                       ;
pan(hFigMask,'off')                                                        ;


%==========================================================================
% --- restore to current path
%==========================================================================
function restorePath(currentPath)
path_str = ['cd ','''',currentPath,'''']                                   ;
eval(path_str)                                                             ;


% ---
% EOF
