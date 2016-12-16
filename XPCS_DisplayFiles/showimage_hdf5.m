function showimage_hdf5(varargin)
% SHOWIMAGE Function called by pushbutton of figure by viewinfo.m to
%   display average of images after correction to some batchinfo
%   parameters.
%
% Zhang Jiang
% $Revision: 1.0 $  $Date: 2004/12/19 $
% $Revision: 1.1 $  $Date: 2006/08/23 $ MS fixed offset issue of specular
%                                       line


% =========================================================================
% --- get ccdimginfo
% =========================================================================
hFigXPCSMain     = findall(0,'Tag','xpcsmain_Fig')                         ;
hFigViewinfo     = findall(0,'Tag','viewinfo_Fig')                         ;
hFigShowImage    = findall(0,'Tag','showimage_fig1')                       ; % display image
hFigShowImageInt = findall(0,'Tag','showimage_fig2')                       ; % display intensity
global ccdimginfo
if ~exist('ccdimginfo','var')
    return;
end
%if isappdata(hFigXPCSMain,'ccdimginfo')
%    ccdimginfo = getappdata(hFigXPCSMain,'ccdimginfo')                     ;
%else
%    return                                                                 ;
%end


% =========================================================================
% --- create figures if image figure or intensity figure does not exist
% =========================================================================
figureSize = [640 480];
if isempty(hFigShowImage)
    hFigShowImage = figure('BackingStore','off','Units','pixels',       ...
                           'DockControls','off',                        ...
                           'PaperOrient','portrait',                    ...
                           'IntegerHandle','off',                       ...
                           'NumberTitle','off','MenuBar','none',        ...
                           'Name','XPCS','color',[1 1 0.85],            ...
                           'Toolbar','none',                            ...
                           'WindowButtonMotionFcn',@imagefigure_WindowButtonMotionFcn,...
                           'Position',[300,225,figureSize],             ...
                           'Tag','showimage_fig1',                      ...
                           'UserData',[])                                  ;
    hToolbar = uitoolbar(hFigShowImage,'Tag','showimage_fig1_Toolbar')     ;
    iconToolbarZoom = load('zoom.mat')                                     ;
    hToolbarZoom = uitoggletool(hToolbar,                               ...
                                'CDATA',iconToolbarZoom.zoomCData,      ...
                                'Separator','on',                       ...
                                'TooltipString','Zoom',                 ...
                                'State','off',                          ...
                                'ClickedCallback',@toolbarZoomFcn,      ...
                                'Tag','toolbarZoom')                       ;
    iconToolbarPan = load('pan.mat')                                       ;
    hToolbarPan = uitoggletool(hToolbar,                                ...
                               'CDATA',iconToolbarPan.cdata,            ...
                               'TooltipString','Pan',                   ...
                               'ClickedCallback',@toolbarPanFcn,        ...
                               'Tag','toolbarPan')                         ;
    iconToolbarColormapeditor = load('colormapeditor.mat')                 ;
    hToolbarColormapeditor = uipushtool(hToolbar                                ...
                                       ,'CDATA',iconToolbarColormapeditor.cdata ...
                                       ,'TooltipString','Edit Colormap'         ...
                                       ,'ClickedCallback','colormapeditor;'     ...
                                       ,'Tag','toolbarColormapeditor')             ;
    if ( ccdimginfo.geometry == 1 )
        iconToolbarCorrectSpecular = load('correctspecular.mat')               ;
        hToolbarCorrectSpecular    = uipushtool(hToolbar                                 ...
                                               ,'CDATA',iconToolbarCorrectSpecular.cdata ...
                                               ,'TooltipString','Correct specular'       ...
                                               ,'ClickedCallback',@toolbarCorSpec        ...
                                               ,'Tag','toolbarCorrectSpecular')             ;
    end
else
    figure(hFigShowImage)                                                  ;
end


% =========================================================================
% --- reset toolbar controls of image figure
% =========================================================================
resetToolbar(hFigShowImage)                                                ;


% =========================================================================
% --- if there is any change to the selected frames to display, 
% --- reset figure name and reload frames
% =========================================================================  
%%
%move the computing of summed image for display to a separate function
trueData = ccdimginfo.xpcs.fullimg;

%%
% --- activate figure and plot average of images
figure(hFigShowImage)                                                  ;
data_std = std(trueData(:));
data_mean = mean(trueData(:));
hImm = imagesc(trueData,[max(data_mean-5*data_std,0),data_mean+5*data_std]);
colormap('jet');
%axis image;
set(hImm,'Tag','showimage_image')                                      ;
uicontrol('Parent',hFigShowImage,'Style','Text',                    ...
    'BackgroundColor',[1 1 0.85],      ...
    'String','',                       ...
    'units','normalized',              ...
    'HorizontalAlignment','left',      ...
    'position',[0.05 0.01 0.5 0.05],   ...
    'Tag','mouseposition')                ;
set(get(hImm,'Parent'),'YDir','normal')                                ;
clear sumData sumDark trueData f figureName hImm                       ;

% =========================================================================
% --- for kinetics mode, calculate offset & shifted pixels to plot
% --- correction line and total # of slices
% =========================================================================
if ccdimginfo.detector.kinetics.mode == 1
    shiftOffset = (-ccdimginfo.detector.kinetics.slice_top+ccdimginfo.detector.y_end)                 ;
    shiftedPixels = ccdimginfo.detector.kinetics.slice_top - shiftOffset                   ...
        - ccdimginfo.detector.kinetics.last_usable_slice * ccdimginfo.detector.kinetics.window_size  ;
    totalSlice = floor(ccdimginfo.detector.y_end/ccdimginfo.detector.kinetics.window_size)           ;
end

% --- draw correction line for reflection geometry
if ccdimginfo.geometry == 1

    % =====================================================================
    % --- check if ccdimginfo.dpix (pixel size) is a scalar or a vector 
    % --- & assign values to dpix_x & dpix_y accordingly
    % =====================================================================
        dpix_x = ccdimginfo.detector.dpix_x;
        dpix_y = ccdimginfo.detector.dpix_y;
    % =====================================================================
    % --- coordinates of DB & RB in pixel in respect to the position of the 
    % --- CCD during the measurement
    % =====================================================================
    xDBpix = ccdimginfo.acquisition.x0    + ccdimginfo.ccdxsense * (ccdimginfo.acquisition.ccdx - ccdimginfo.acquisition.ccdx0)    / dpix_x ;
    yDBpix = ccdimginfo.acquisition.y0    + ccdimginfo.ccdzsense * (ccdimginfo.acquisition.ccdz - ccdimginfo.acquisition.ccdz0)    / dpix_y ;
    xRBpix = ccdimginfo.acquisition.xspec + ccdimginfo.ccdxsense * (ccdimginfo.acquisition.ccdx - ccdimginfo.acquisition.ccdxspec) / dpix_x ;
    yRBpix = ccdimginfo.acquisition.yspec + ccdimginfo.ccdzsense * (ccdimginfo.acquisition.ccdz - ccdimginfo.acquisition.ccdzspec) / dpix_y ;
    % ---
    xDB2RB = (xRBpix - xDBpix) * dpix_x                                    ;
    yDB2RB = (yRBpix - yDBpix) * dpix_y                                    ;
    % =====================================================================
    % --- calculate the tilt angle from specular to beam0
    % =====================================================================
    if ( xDB2RB ~= 0 )
        tilt = atan( yDB2RB / xDB2RB )                                     ;
    else
        tilt = sign(yDB2RB) * pi / 2                                       ;
    end
    % =====================================================================
    % --- generate points on the specular streak at the image limits
    % =====================================================================
    xleft  = ccdimginfo.detector.x_begin         ;
    yleft  = (xleft -xDBpix)*tan(tilt)+yDBpix     ;
    xright = ccdimginfo.detector.x_end        ;
    yright = (xright-xDBpix)*tan(tilt)+yDBpix   ;
    % =====================================================================
    % --- shift yRBpix, xRBpix, yDBpix,xDBpix,xleft,yleft,xright,yright
    % --- if only part of of CCD is used to store images (ROI mode)
    % =====================================================================
    yRBpix = yRBpix - (ccdimginfo.detector.y_begin-1)                               ;
    xRBpix = xRBpix - (ccdimginfo.detector.x_begin-1)                               ;
    yDBpix = yDBpix - (ccdimginfo.detector.y_begin-1)                               ;
    xDBpix = xDBpix - (ccdimginfo.detector.x_begin-1)                               ;
    yleft  = yleft  - (ccdimginfo.detector.y_begin-1)                               ;
    xleft  = xleft  - (ccdimginfo.detector.x_begin-1)                               ;
    yright = yright - (ccdimginfo.detector.y_begin-1)                               ;
    xright = xright - (ccdimginfo.detector.x_begin-1)                               ;
    % =====================================================================
    % --- For kinetics mode, shift yRBpix, yDBpix, yleft
    % --- according to the last selected slice
    % =====================================================================
    if ( ccdimginfo.detector.kinetics.mode == 1 )
        yRBpix = yRBpix - shiftedPixels                                    ;
        yDBpix = yDBpix - shiftedPixels                                    ;
        yleft  = yleft  - shiftedPixels                                    ;
        yright = yright - shiftedPixels                                    ;
    end
    % =====================================================================
    % --- save the direct beam and specular reflected beam position 
    % =====================================================================
    showimageinfo.db    = [xDBpix,yDBpix]                                  ;
    showimageinfo.rb    = [xRBpix,yRBpix]                                  ;
    showimageinfo.left  = [xleft,yleft]                                    ;
    showimageinfo.right = [xright,yright]                                  ;    
    setappdata(hFigShowImage,'showimageinfo',showimageinfo)                ;
    % =====================================================================
    % --- draw the correction lines for reflection geometry
    % =====================================================================
    delete(findall(hFigShowImage,'tag','showimage_line'))                  ;
    % ---
    xdata = [xleft,xright,xRBpix,xDBpix]                                   ;
    ydata = [yleft,yright,yRBpix,yDBpix]                                   ;
    [xdata,xindex] = sort(xdata)                                           ;
    ydata          = ydata(xindex)                                         ;
    % ---
    line('Parent',get(findall(hFigShowImage,'tag','showimage_image'),'Parent') ...
        ,'XData',xdata,'YData',ydata                                    ...
        ,'LineStyle','-','Color','r'                                    ...
        ,'Marker','x','MarkerSize',20,'Tag','showimage_line')              ;
end


% =========================================================================
% For kinetics mode: 
% 1. label all the slices and draw slice separation lines
% 2. create 2nd figure to show the average intensity of columns
% =========================================================================
if ccdimginfo.detector.kinetics.mode == 1
    % --- label all the slices and draw slice separation lines
    delete(findall(hFigShowImage,'Tag','showimage_slicelabel'));
    delete(findall(hFigShowImage,'Tag','showimag_sliceseparationline'));
    for iSlice = 1:totalSlice
        text('Parent',get(findall(hFigShowImage,'tag','showimage_image'),'Parent'),...
            'Position',[50 ccdimginfo.detector.kinetics.window_size*(iSlice-0.5)+shiftOffset],...
            'String',num2str(iSlice),...
            'FontName','FixedWidth',...
            'FontWeight','normal',...
            'HorizontalAlignment','center',...
            'color',[1 1 1],...
            'Tag','showimage_slicelabel');
        line('Parent',get(findall(hFigShowImage,'tag','showimage_image'),'Parent'),...
            'XData',[0.5,ccdimginfo.detector.x_end-ccdimginfo.detector.x_begin+0.5],...
            'YData',[ccdimginfo.detector.kinetics.window_size*iSlice+0.5+shiftOffset,ccdimginfo.detector.kinetics.window_size*iSlice+0.5+shiftOffset],...
            'Tag','showimag_sliceseparationline',...
            'color','g');
    end
    % --- create figure if not exist, else refresh it
    if isempty(hFigShowImageInt)
        hFigShowImageInt = figure(...
        'BackingStore','off',...
        'Units','pixels',...
        'DockControls','off',...
        'PaperOrient','portrait',...
        'IntegerHandle','off',...
        'NumberTitle','off',...
        'MenuBar','none',...
        'Name','XPCS',...
        'color',[1 1 0.85],...
        'Toolbar','none',...
        'Position',[350,250,figureSize],...
        'Tag','showimage_fig2',...
        'UserData',[]);
    hAxes = axes('Parent',hFigShowImageInt,...
        'Units','normalized',...
        'Position',[0.13 0.11 0.775 0.815],...
        'Box','on',...
        'Tag','showimage_fig2_axes');
    set(hAxes,'XLim',[1 ccdimginfo.detector.y_end-ccdimginfo.detector.y_begin+1]);
    set(get(hAxes,'XLabel'),'String','Row Pixel Number');
    set(get(hAxes,'YLabel'),'String','ADU');
    hToolbar = uitoolbar(hFigShowImageInt,'Tag','showimage_fig2_Toolbar');
    iconToolbarZoom = load('zoom.mat');
    hToolbarZoom = uitoggletool(hToolbar,...
        'CDATA',iconToolbarZoom.zoomCData,...
        'Separator','on',...
        'TooltipString','Zoom',...
        'State','off',...
        'ClickedCallback',@toolbarZoomFcn,...
        'Tag','toolbarZoom');
    iconToolbarPan = load('pan.mat');
    hToolbarPan = uitoggletool(hToolbar,...
        'CDATA',iconToolbarPan.cdata,...
        'TooltipString','Pan',...
        'ClickedCallback',@toolbarPanFcn,...
        'Tag','toolbarPan');
    else
        figure(hFigShowImageInt);
        resetToolbar(hFigShowImageInt);
    end
    % --- calculate average intensity of colums and plot
    imageIntensity = get(findall(findall(0,'Tag','showimage_fig1'),'type','image'),'cdata');
    avgInt = sum(imageIntensity,2)/(ccdimginfo.detector.x_end - ccdimginfo.detector.x_begin + 1);
    delete(findall(hFigShowImageInt,'Tag','showimage_fig2_line'));  
    hLine = line('Parent',findall(hFigShowImageInt,'Tag','showimage_fig2_axes'),...
        'XData',[1:length(avgInt)],...
        'YData',avgInt,...
        'Tag','showimage_fig2_line'); %#ok<NBRAK>
%     set(hFigShowImageInt,'Name',['XPCS - Average Intensity in Column of Frame ',num2str(dataIndexToDisplay(1)),':',num2str(dataIndexToDisplay(end))]);
    set(hFigShowImageInt,'Name','XPCS - Average Intensity in Column of Frame');
    % --- label slice number 
    delete(findall(hFigShowImageInt,'Tag','showimage_fig2_slicelabel'));
    for iSlice = 1:totalSlice
        if iSlice < ccdimginfo.detector.kinetics.first_usable_slice || iSlice > ccdimginfo.detector.kinetics.last_usable_slice
            text('Parent',findall(hFigShowImageInt,'Tag','showimage_fig2_axes'),...
                'Position',[ccdimginfo.detector.kinetics.window_size*(iSlice-0.5)+shiftOffset max(avgInt)/10],...
                'String',num2str(iSlice),...
                'FontName','FixedWidth',...
                'FontWeight','normal',...
                'HorizontalAlignment','center',...
                'color','r',...
                'BackgroundColor',[1.00 1.00 1.00],...
                'Tag','showimage_fig2_slicelabel');
        else
            text('Parent',findall(hFigShowImageInt,'Tag','showimage_fig2_axes'),...
                'Position',[ccdimginfo.detector.kinetics.window_size*(iSlice-0.5)+shiftOffset max(avgInt)/10],...
                'String',num2str(iSlice),...
                'FontName','FixedWidth',...
                'FontWeight','normal',...
                'HorizontalAlignment','center',...
                'color','g',...
                'BackgroundColor',[1.00 1.00 1.00],...
                'Tag','showimage_fig2_slicelabel');
        end
    end
end


%==========================================================================
% --- show image figure in the front
%==========================================================================
figure(hFigShowImage)                                                      ;


%==========================================================================
% --- tracking mouse position
%==========================================================================
function imagefigure_WindowButtonMotionFcn(hObject,eventdata) %#ok<INUSD>
set(gcf,'selected','on')                                                   ;
pointPosition = get(gca,'CurrentPoint')                                    ;
XLim=get(gca,'XLim')                                                       ;
YLim=get(gca,'YLim')                                                       ;
XLimFlag=(pointPosition(1,1)>=XLim(1) & pointPosition(1,1)<=XLim(2))       ;
YLimFlag=(pointPosition(1,2)>=YLim(1) & pointPosition(1,2)<=YLim(2))       ;
cdata = get(findall(gcf,'type','image'),'cdata')                           ;
xpos = round(pointPosition(1,1))                                           ;
ypos = round(pointPosition(1,2))                                           ;
if (  xpos >= 1 && xpos <= size(cdata,2)                                ...
   && ypos >= 1 && ypos <= size(cdata,1)                                ...
   && XLimFlag == 1 && YLimFlag ==1 )
    set(gcf,'Pointer','crosshair')                                         ;
    set(findall(gcf,'Tag','mouseposition'),'string',['x=',num2str(xpos) ...
       ,', y=',num2str(ypos),', value=',num2str(cdata(ypos,xpos))])        ;
else
    set(gcf,'Pointer','arrow')                                             ;
end
clear XLim YLim XLimFlag YLimFlag                                          ;
clear pointPosition xpos ypos cdata                                        ;


%==========================================================================
% --- toolbar zoom callback
%==========================================================================
function toolbarZoomFcn(hObject,eventdata) %#ok<INUSD>
hFig = gcbf                                                                ;
hToolbarZoom = findall(hFig,'Tag','toolbarZoom')                           ;
hToolbarPan = findall(hFig,'Tag','toolbarPan')                             ;
zoom                                                                       ;
pan off                                                                    ;
set(hToolbarPan,'state','off')                                             ;


%==========================================================================
% --- toolbar pan callback
%==========================================================================
function toolbarPanFcn(hObject,eventdata) %#ok<INUSD>
hFig = gcbf                                                                ;
hToolbarZoom = findall(hFig,'Tag','toolbarZoom')                           ;
hToolbarPan = findall(hFig,'Tag','toolbarPan')                             ;
zoom off                                                                   ;
pan                                                                        ;
set(hToolbarZoom,'state','off')                                            ;


%==========================================================================
% --- toolbar correct specular callback
%==========================================================================
function toolbarCorSpec(hObject,eventdata) %#ok<INUSD>

hFigXPCSMain  = findall(0,'Tag','xpcsmain_Fig')                            ;
hFigShowImage = findall(0,'Tag','showimage_fig1')                          ;
hFigViewinfo  = findall(0,'Tag','viewinfo_Fig')                            ;
%==========================================================================
global ccdimginfo
%ccdimginfo    = getappdata(hFigXPCSMain,'ccdimginfo')                      ;
showimageinfo = getappdata(hFigShowImage,'showimageinfo')                  ;
%==========================================================================
hToolbarZoom            = findall(hFigShowImage,'Tag','toolbarZoom')       ;
hToolbarPan             = findall(hFigShowImage,'Tag','toolbarPan')        ;
hToolbarCorrectSpecular = findall(hFigShowImage,'Tag','toolbarCorrectSpecular')     ;
zoom off                                                                   ;
pan off                                                                    ;
set(hToolbarZoom,'state','off')                                            ;
set(hToolbarPan,'state','off')                                             ;
%==========================================================================
[x,y] = ginput(2)                                                          ; % get two points on the specular rod
m     = (y(2)-y(1)) / (x(2)-x(1))                                          ;
b     = y(1) - m*x(1)                                                      ;
%==========================================================================
% --- calculate correction offsets
%==========================================================================
dboffset    = showimageinfo.db(2)    - (m * showimageinfo.db(1)   + b)     ;
rboffset    = showimageinfo.rb(2)    - (m * showimageinfo.rb(1)   + b)     ;
leftoffset  = showimageinfo.left(2)  - (m * showimageinfo.left(1) + b)     ;
rightoffset = showimageinfo.right(2) - (m * showimageinfo.right(1)+ b)     ;
% =========================================================================
% --- update the 'showimageinfo' application data
% =========================================================================
showimageinfo.db(2)    = showimageinfo.db(2)    - dboffset                 ;
showimageinfo.rb(2)    = showimageinfo.rb(2)    - rboffset                 ;
showimageinfo.left(2)  = showimageinfo.left(2)  - leftoffset               ;
showimageinfo.right(2) = showimageinfo.right(2) - rightoffset              ;
setappdata(hFigShowImage,'showimageinfo',showimageinfo)                    ;
%==========================================================================
% --- update position parameters on the viewinfo window 
%==========================================================================
y0    = str2double(get(findall(hFigViewinfo,'Tag','figviewinfo_y0'),'string'))    ;
yspec = str2double(get(findall(hFigViewinfo,'Tag','figviewinfo_yspec'),'string')) ;
set(findall(hFigViewinfo,'Tag','figviewinfo_y0')   ,'string',y0-dboffset)         ;
set(findall(hFigViewinfo,'Tag','figviewinfo_yspec'),'string',yspec-rboffset)      ;
%==========================================================================
% --- update main application data 
%==========================================================================
ccdimginfo.y0    = str2double(get(findall(hFigViewinfo,'Tag','figviewinfo_y0'),'string'))    ;
ccdimginfo.yspec = str2double(get(findall(hFigViewinfo,'Tag','figviewinfo_yspec'),'string')) ;
%setappdata(hFigXPCSMain,'ccdimginfo',ccdimginfo)                                             ;
%==========================================================================
delete(findall(hFigShowImage,'tag','showimage_line'))                      ; % delete the old correction line
%==========================================================================
xdata = [showimageinfo.left(1),showimageinfo.right(1),showimageinfo.rb(1),showimageinfo.db(1)] ;
ydata = [showimageinfo.left(2),showimageinfo.right(2),showimageinfo.rb(2),showimageinfo.db(2)] ;
%==========================================================================
[xdata,xindex] = sort(xdata)                                               ;
ydata          = ydata(xindex)                                             ;
%==========================================================================
line('Parent',get(findall(hFigShowImage,'tag','showimage_image'),'Parent') ...
    ,'XData',xdata,'YData',ydata                                           ...
    ,'LineStyle','-','Color','r'                                           ...
    ,'Marker','x','MarkerSize',20,'Tag','showimage_line')                  ; % create the new correction line


%==========================================================================
% --- reset toolbars
%==========================================================================
function resetToolbar(varargin)
hFigShowImage = varargin{1}                                                ;
hToolbarZoom = findall(hFigShowImage,'Tag','toolbarZoom')                  ;
hToolbarPan = findall(hFigShowImage,'Tag','toolbarPan')                    ;
set(hToolbarZoom,'state','off')                                            ;
set(hToolbarPan,'state','off')                                             ;
zoom(hFigShowImage,'off')                                                  ;
pan(hFigShowImage,'off')                                                   ;


% ---
% EOF
