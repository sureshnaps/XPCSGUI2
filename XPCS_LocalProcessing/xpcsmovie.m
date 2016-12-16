function xpcsmovie(varargin)
% XPCSMOVIE GUI to make movies from XPCS images.
%
%   By Zhang Jiang
%   $Revision: 1.0 $  $Date: 2005/02/24 $
%   $Revision: 1.1 $  $Date: 2005/08/08 $ Fix problems in toobarSaveFcn. 
%       Image can be saved to uint16 format instead of uint8.
%   $Revision: 1.2 $  $Date: 2012/01/19 % Use writeVideo instead of avifile
%       for 2010Rb and later releases. The codec is now independent of OS.

% =========================================================================
% --- check: if figure already exists bring it to the foreground
% =========================================================================
hFigXPCSMovie = findall(0,'Tag','xpcsmovie_Fig')                           ;
if ( ~isempty(hFigXPCSMovie) )
    figure(hFigXPCSMovie)                                                  ;
    return                                                                 ;
end

% =========================================================================
% --- create new figure
% =========================================================================
figXPCSMovieSize = [700 500]                                               ;
screenSize = get(0,'ScreenSize')                                           ;
hFigXPCSMovie = figure('BackingStore','on','Units','pixels',            ...
    'DockControls','off','Resize','off',             ...
    'PaperOrient','portrait',                        ...
    'PaperPositionMode','auto','IntegerHandle','off',...
    'NumberTitle','off','MenuBar','none',            ...
    'Toolbar','none',                                ...
    'CloseRequestFcn',@xpcsmovie_CloseRequestFcn,    ...
    'Name','XPCS - Movie Maker',                     ...
    'Position',[(screenSize(3)-figXPCSMovieSize(1))/2 ...
    ,(screenSize(4)-figXPCSMovieSize(2))/2 ...
    ,figXPCSMovieSize],                   ...
    'HandleVisibility','callback',                   ...
    'Tag','xpcsmovie_Fig',                           ...
    'UserData',[])                                      ;
% --- initial figure layout
backgroundcolor = [1 1 0.85]                                               ;
facecolor       = [1 1 0.9]                                                ;
textcolor       = [0.4 0.3 0]                                              ; % text color
subtextcolor    = 'b'                                                      ; % subtext color
hAxes = axes('Parent',hFigXPCSMovie,'Units','pixels',...
    'Position',[0 0 figXPCSMovieSize],'Tag','figxpcsmovie_Axes')  ;

hPatch1 = patch('Parent',hAxes,'XData',[0 1 1 0],'YData',[0 0 1 1]      ...
    ,'FaceColor',backgroundcolor,'EdgeColor',backgroundcolor)   ;
hGroupPatch = hggroup('Parent',hAxes)                                      ;
hPatch2 = patch('Parent',hGroupPatch,'XData',[0.02 0.49 0.49 0.02]      ...
    ,'YData',[0.1 0.1 0.925 0.925])                             ;
hPatch3 = patch('Parent',hGroupPatch,'XData',[0.51 0.98 0.98 0.51]      ...
    ,'YData',[0.1 0.1 0.925 0.925])                             ;
set(get(hGroupPatch,'Children'),'FaceColor',backgroundcolor+[0 0 0.05]  ...
    ,'EdgeColor',[0.7 0.7 0.7])                 ;
hGroupText      = hggroup('Parent',hAxes)                                  ;
hGroupSubText   = hggroup('Parent',hAxes)                                  ;
hGroupSubText1  = hggroup('Parent',hAxes)                                  ;


% =========================================================================
% --- layout of 'Load batchinfo file' button
% =========================================================================
text('Parent',hAxes,'Position',[0.28 0.965]                             ...
    ,'String','XPCS CCD Image Movie Maker (APS 8-ID-I)','FontSize',12   ...
    ,'FontWeight','demi','color',[0.4 0.3 0])                              ;
uicontrol('Parent',hFigXPCSMovie,'style','pushbutton'                   ...
    ,'Units','normalized','String','Load Batchinfo File ...'       ...
    ,'Position',[0.03 0.86 0.45 0.05]                              ...
    ,'Tag','figxpcsmovie_PushbuttonLoadbatchinfo'                  ...
    ,'TooltipString','Load batchinfo file'                         ...
    ,'callback',@xpcsmovie_loadbatchinfo)                             ;


% =========================================================================
% --- layout of CCD image size information
% =========================================================================
text('Parent',hGroupText,'Position',[0.03 0.84]                         ...
    ,'String','Saved CCD Image Size (ROI):')                               ;
text('Parent',hGroupSubText,'Position',[0.1 0.76],'String','begin')        ;
text('Parent',hGroupSubText,'Position',[0.1 0.72],'String','  end')        ;
text('Parent',hGroupSubText,'Position',[0.16 0.8],'String','column (x)')   ;
text('Parent',hGroupSubText,'Position',[0.33 0.8],'String','   row (y)')   ;

uicontrol('Parent',hFigXPCSMovie,'Style','Edit','Units','normalized'    ...
    ,'Position',[0.15 0.74 0.1 0.035]'                             ...
    ,'HorizontalAlignment','right','Enable','off'                  ...
    ,'backgroundcolor','w','String','1','Tag','figxpcsmovie_col_beg') ;
uicontrol('Parent',hFigXPCSMovie,'Style','Edit','Units','normalized'    ...
    ,'Position',[0.15 0.7 0.1 0.035]','HorizontalAlignment','right'...
    ,'Enable','off','backgroundcolor','w','String','1340'          ...
    ,'Tag','figxpcsmovie_col_end')                                    ;
uicontrol('Parent',hFigXPCSMovie,'Style','Edit','Units','normalized'    ...
    ,'Position',[.32 .74 .10 .035]','HorizontalAlignment','right'  ...
    ,'Enable','off','backgroundcolor','w','String','1'             ...
    ,'Tag','figxpcsmovie_row_beg')                                    ;
uicontrol('Parent',hFigXPCSMovie,'Style','Edit','Units','normalized'    ...
    ,'Position',[.32 .70 .10 .035]','HorizontalAlignment','right'  ...
    ,'Enable','off','backgroundcolor','w','String','1300'          ...
    ,'Tag','figxpcsmovie_row_end')                                    ;


% =========================================================================
% --- layout of CCD working mode (slice information)
% =========================================================================
text('Parent',hGroupText,'Position',[0.03 0.68]                         ...
    ,'String','CCD Working Mode:')                                         ;
uicontrol('Parent',hFigXPCSMovie,'Style','Edit','Units','normalized'    ...
    ,'Enable','off','Position',[0.35 0.66 0.12 0.035]              ...
    ,'HorizontalAlignment','right','backgroundcolor','w'           ...
    ,'Tag','figxpcsmovie_kinetics','String','Non-Kinetics')           ;
text('Parent',hGroupSubText,'Position',[0.06 0.64]                      ...
    ,'String','kinetics window size')                                      ;
hEditKinetics1 = uicontrol('Parent',hFigXPCSMovie,'Style','Edit'        ...
    ,'Units','normalized'                         ...
    ,'Position',[0.37 0.62 0.1 0.035]'            ...
    ,'HorizontalAlignment','right'                ...
    ,'Enable','off','backgroundcolor','w'         ...
    ,'String','-1','Tag','figxpcsmovie_kinwinsize')  ;
text('Parent',hGroupSubText,'Position',[0.06 0.60]                      ...
    ,'String','top row number of visible slice')                           ;
hEditKinetics2 = uicontrol('Parent',hFigXPCSMovie,'Style','Edit'        ...
    ,'Units','normalized'                         ...
    ,'Position',[0.37 0.58 0.1 0.035]'            ...
    ,'HorizontalAlignment','right'                ...
    ,'Enable','off','backgroundcolor','w'         ...
    ,'String','-1','Tag','figxpcsmovie_slicetop')    ;
text('Parent',hGroupSubText,'Position',[0.06 0.56]                      ...
    ,'String','first usable kinetics slice')                               ;
hEditKinetics3 = uicontrol('Parent',hFigXPCSMovie,'Style','Edit'        ...
    ,'Units','normalized'                         ...
    ,'Position',[0.37 0.54 0.1 0.035]'            ...
    ,'HorizontalAlignment','right'                ...
    ,'backgroundcolor','w','String','-1'          ...
    ,'Enable','off','Tag','figxpcsmovie_firstslice');
text('Parent',hGroupSubText,'Position',[0.06 0.52]                      ...
    ,'String','last usable kinetics slice')                                ;
hEditKinetics4 = uicontrol('Parent',hFigXPCSMovie,'Style','Edit'        ...
    ,'Units','normalized'                         ...
    ,'Position',[0.37 0.50 0.1 0.035]'            ...
    ,'HorizontalAlignment','right'                ...
    ,'backgroundcolor','w','String','-1'          ...
    ,'Enable','off','Tag','figxpcsmovie_lastslice')  ;


% =========================================================================
% --- layout of batch information
% =========================================================================
text('Parent',hGroupText,'Position',[0.03 0.4775]                       ...
    ,'String','View and Edit Batch #')                                     ;
uicontrol('Parent',hFigXPCSMovie,'Style','Popupmenu'                    ...
    ,'Units','normalized','Position',[0.225 0.46 0.06 0.035]'      ...
    ,'HorizontalAlignment','right','backgroundcolor','w'           ...
    ,'String','1','Enable','off'                                   ...
    ,'callback',@PopupmenuBatchnumberCallbackFcn                   ...
    ,'Tag','figxpcsmovie_PopupmenuBatchnumber')                       ;
text('Parent',hGroupSubText,'Position',[0.180 0.44],'String','start')      ;
text('Parent',hGroupSubText,'Position',[0.280 0.44],'String','end')        ;
text('Parent',hGroupSubText,'Position',[0.355 0.44],'String','time (sec)') ;
text('Parent',hGroupSubText,'Position',[0.100 0.40],'String','data')       ;
uicontrol('Parent',hFigXPCSMovie,'Style','Edit','Units','normalized'    ...
    ,'Position',[.15 .38 .085 .035]','HorizontalAlignment','right' ...
    ,'backgroundcolor','w','Enable','off','String','-1'            ...
    ,'Tag','figxpcsmovie_ndata0todo')                                 ;
uicontrol('Parent',hFigXPCSMovie,'Style','Edit','Units','normalized'    ...
    ,'Enable','off','Position',[0.25 0.38 0.085 0.035]'            ...
    ,'HorizontalAlignment','right','backgroundcolor','w'           ...
    ,'String','-1','Tag','figxpcsmovie_ndataendtodo')                 ;
uicontrol('Parent',hFigXPCSMovie,'Style','Edit','Units','normalized'    ...
    ,'Position',[0.35 .38 .085 .035]','HorizontalAlignment','right'...
    ,'backgroundcolor','w','Enable','off','String','-1'            ...
    ,'Tag','figxpcsmovie_preset')                                     ;
text('Parent',hGroupSubText,'Position',[0.1 0.36],'String','dark')         ;
uicontrol('Parent',hFigXPCSMovie,'Style','Edit','Units','normalized'    ...
    ,'Position',[.15 .34 .085 .035]','HorizontalAlignment','right' ...
    ,'backgroundcolor','w','String','-1','Enable','off'            ...
    ,'Tag','figxpcsmovie_ndark0todo')                                 ;
uicontrol('Parent',hFigXPCSMovie,'Style','Edit','Units','normalized'    ...
    ,'Position',[.25 .34 .085 .035]','HorizontalAlignment','right' ...
    ,'backgroundcolor','w','Enable','off','String','-1'            ...
    ,'Tag','figxpcsmovie_ndarkendtodo')                               ;
uicontrol('Parent',hFigXPCSMovie,'Style','Edit','Units','normalized'    ...
    ,'Position',[.35 .34 .085 .035]','HorizontalAlignment','right' ...
    ,'backgroundcolor','w','Enable','off','String','-1'            ...
    ,'Tag','figxpcsmovie_dark_preset')                                ;


% =========================================================================
% --- layout of dark information
% =========================================================================
text('Parent',hGroupText,'Position',[0.03 0.32]                         ...
    ,'String','Dark Subtraction:')                                         ;
uicontrol('Parent',hFigXPCSMovie,'Style','Popupmenu','Units','normalized'   ...
    ,'Position',[.37 .3 .10 .035]','HorizontalAlignment','right'   ...
    ,'backgroundcolor','w','String',{'Yes';'No'},'Value',1         ...
    ,'Enable','off','Tag','figxpcsmovie_PopupmenuDarkSubtract'     ...
    ,'callback',@PopupmenuDarkSubtractCallbackFcn)                    ;
uicontrol('Parent',hFigXPCSMovie,'Style','Radiobutton','Units','normalized' ...
    ,'String','no LLD (Lower Level Discrimination)','FontSize',10  ...
    ,'BackgroundColor',facecolor,'ForegroundColor',subtextcolor    ...
    ,'Position',[0.06 0.25 0.35 0.04],'Enable','off','Value',0     ...
    ,'Tag','figxpcsmovie_RadiobuttonLLD1'                          ...
    ,'Callback',@figxpcsmovie_RadiobuttonLLDCallbackFcn)              ;
uicontrol('Parent',hFigXPCSMovie,'Style','Radiobutton','Units','normalized' ...
    ,'String','            X ADU','FontSize',10                    ...
    ,'BackgroundColor',facecolor,'ForegroundColor',subtextcolor    ...
    ,'HorizontalAlignment','right','Position',[0.06 0.205 0.3 0.04]...
    ,'Enable','off','Value',1,'Tag','figxpcsmovie_RadiobuttonLLD2' ...
    ,'Callback',@figxpcsmovie_RadiobuttonLLDCallbackFcn)              ;
uicontrol('Parent',hFigXPCSMovie,'Style','Edit','Units','normalized'    ...
    ,'String','15','BackgroundColor','w','Enable','off'            ...
    ,'HorizontalAlignment','right','Position',[.09 .21 .05 .035]   ...
    ,'Tag','figxpcsmovie_EditLLD2')                                   ;
uicontrol('Parent',hFigXPCSMovie,'Style','Radiobutton','Units','normalized'...
    ,'String','            X dark RMS','FontSize',10               ...
    ,'BackgroundColor',facecolor,'ForegroundColor',subtextcolor    ...
    ,'HorizontalAlignment','right','Position',[0.06 0.16 0.3 0.04] ...
    ,'value',0,'Enable','off','Tag','figxpcsmovie_RadiobuttonLLD3' ...
    ,'Callback',@figxpcsmovie_RadiobuttonLLDCallbackFcn)              ;
uicontrol('Parent',hFigXPCSMovie,'Style','Edit','Units','normalized'    ...
    ,'String','4','BackgroundColor','w','Enable','off'             ...
    ,'HorizontalAlignment','right','Position',[.09 .16 .05 .035]   ...
    ,'Tag','figxpcsmovie_EditLLD3')                                   ;


% =========================================================================
% --- layout of tilt angle (not shown for transmission)
% =========================================================================
text('Parent',hGroupText,'Position',[0.03 0.14]                         ...
    ,'String','CCD Image Tilt Angle (Degree):','Visible','off')            ;
uicontrol('Parent',hFigXPCSMovie,'Style','Edit','Units','normalized'    ...
    ,'Enable','off','Position',[.37 .115 .10 .035]                 ...
    ,'HorizontalAlignment','right','backgroundcolor','w'           ...
    ,'Tag','figxpcsmovie_tiltAngle','Visible','off','String','0')     ;


% =========================================================================
% --- layout for movie settings (start of 2nd panel)
% =========================================================================
text('Parent',hGroupText,'Position',[0.53 0.9],'String','Movie Settings:') ;
text('Parent',hGroupSubText,'Position',[0.56 0.86]                      ...
    ,'String','movie quality (100%)','Tag','figxpcsmovie_TextQuality')     ;
uicontrol('Parent',hFigXPCSMovie,'style','slider','Units','normalized'  ...
    ,'Enable','off','Max',100,'Min',0,'SliderStep',[0.01 0.1]      ...
    ,'Value',100,'TooltipString','100%'                            ...
    ,'Position',[.78 .84 .18 .035]                                 ...
    ,'Tag','figxpcsmovie_SliderQuality'                            ...
    ,'callback',@figxpcsmovie_SliderQualityCallbackFcn)               ;

text('Parent',hGroupSubText,'Position',[0.56 0.82]                      ...
    ,'String','frame per second (fps)')                                    ;
uicontrol('Parent',hFigXPCSMovie,'Style','Edit','Units','normalized'    ...
    ,'Enable','off','String','15','Position',[0.85 0.80 0.11 0.035]...
    ,'HorizontalAlignment','right','backgroundcolor','w'           ...
    ,'Tag','figxpcsmovie_EditFps')                                    ;

text('Parent',hGroupSubText,'Position',[0.56 0.78],'String','colormap')    ;
colormap_cell = {'autumn';'bone';'colorcube';'cool';'copper';'flag'     ...
    ;'gray';'hot';'hsv';'jet';'lines';'pink';'prism'        ...
    ;'spring';'summer';'white';'winter'}                       ;
uicontrol('Parent',hFigXPCSMovie,'Style','Popupmenu','Units','normalized'  ...
    ,'Position',[0.85 0.76 0.11 0.035]','HorizontalAlignment','left'  ...
    ,'backgroundcolor','w','String',colormap_cell,'Value',10       ...
    ,'Enable','off','Tag','figxpcsmovie_PopupmenuColormap')           ;

text('Parent',hGroupSubText,'Position',[0.56 0.74]                      ...
    ,'String','image contrast')                                            ;
text('Parent',hGroupSubText,'Position',[0.59 0.7],'String','min:')         ;
uicontrol('Parent',hFigXPCSMovie,'Style','Edit','Units','normalized'    ...
    ,'Enable','off','String','0','Position',[0.63 0.68 0.1 0.035]  ...
    ,'HorizontalAlignment','right','backgroundcolor','w'           ...
    ,'Tag','figxpcsmovie_EditContrastMin')                            ;

text('Parent',hGroupSubText,'Position',[0.76 0.7],'String','max:')         ;
uicontrol('Parent',hFigXPCSMovie,'Style','Edit','Units','normalized'    ...
    ,'Enable','off','String','2000','Position',[.80 .68 .10 .035]  ...
    ,'HorizontalAlignment','right','backgroundcolor','w'           ...
    ,'Tag','figxpcsmovie_EditContrastMax')                            ;

text('Parent',hGroupSubText,'Position',[0.56 0.655]                     ...
    ,'String','label real time on images')                                 ;
uicontrol('Parent',hFigXPCSMovie,'Style','Popupmenu','Units','normalized'  ...
    ,'Position',[0.85 0.64 0.11 0.035]','HorizontalAlignment','left'  ...
    ,'backgroundcolor','w','String',{'Yes';'No'},'Value',2         ...
    ,'Enable','off','Tag','figxpcsmovie_PopupmenuLabelRealtime')      ;


% =========================================================================
% --- layout for saving settings
% =========================================================================
text('Parent',hGroupText,'Position',[0.53 0.62]                         ...
    ,'String','Saving Settings:')                                          ;
text('Parent',hGroupSubText,'Position',[0.56 0.58]                      ...
    ,'String','save XPCS movie (AVI) to file:')                            ;
uicontrol('Parent',hFigXPCSMovie,'Style','pushbutton','Units','normalized' ...
    ,'String','File ...','Enable','off','Position',[.85 .56 .11 .0425]...
    ,'Tag','figxpcsmovie_PushbuttonMovieFile'                      ...
    ,'TooltipString','Enter movie file name'                       ...
    ,'callback',@figxpcsmovie_PushbuttonMovieFileCallbackFcn)         ;
uicontrol('Parent',hFigXPCSMovie,'Style','Edit','Units','normalized'    ...
    ,'Enable','off','String','','Position',[0.56 0.52 0.4 0.035]   ...
    ,'HorizontalAlignment','right','backgroundcolor','w'           ...
    ,'Tag','figxpcsmovie_EditMovieFile')                              ;

text('Parent',hGroupSubText,'Position',[0.56 0.495]                     ...
    ,'String','save averaged XPCS movie')                                  ;
uicontrol('Parent',hFigXPCSMovie,'Style','Popupmenu','Units','normalized'  ...
    ,'Position',[.85 .48 .11 .035]','HorizontalAlignment','center' ...
    ,'backgroundcolor','w','String',{'Yes';'No'},'Value',2         ...
    ,'Enable','off','Tag','figxpcsmovie_PopupmenuSaveAvgMovie')       ;

text('Parent',hGroupText,'Position',[0.53 0.455]                        ...
    ,'String','Display Summed Image (Static):')                            ;
uicontrol('Parent',hFigXPCSMovie,'Style','Popupmenu','Units','normalized'  ...
    ,'Position',[.85 .435 .11 .035]','HorizontalAlignment','center'...
    ,'backgroundcolor','w','String',{'Yes';'No'},'Value',1         ...
    ,'Enable','off','Tag','figxpcsmovie_PopupmenuDisplayStaticImage') ;

text('Parent',hGroupText,'Position',[0.53 0.41]                         ...
    ,'String','Playback (Windows Only):')                                  ;
uicontrol('Parent',hFigXPCSMovie,'Style','Popupmenu','Units','normalized'  ...
    ,'Position',[.85 .392 .11 .035]','HorizontalAlignment','center'...
    ,'backgroundcolor','w','String',{'Yes';'No'},'Value',2         ...
    ,'Enable','off','Tag','figxpcsmovie_PopupmenuPlayback')           ;


% =========================================================================
% --- layout of message box
% =========================================================================
text('Parent',hGroupText,'Position',[0.675 0.34]                        ...
    ,'String','Message Window','FontWeight','demi')                        ;
start_str = {'';'XPCS CCD Image Movie Maker';'Version 1.1 (03/10/2005)' ...
    ;'';'Zhang Jiang';'University of California at San Diego';}    ;
uicontrol('Parent',hFigXPCSMovie,'Style','Edit','Units','normalized'    ...
    ,'Position',[0.509 0.097 0.471 0.21]'                          ...
    ,'HorizontalAlignment','center','backgroundcolor',facecolor    ...
    ,'ForegroundColor',textcolor,'Enable','Inactive'               ...
    ,'Max',2,'Min',0,'String',start_str                            ...
    ,'Tag','figxpcsmovie_EditMessage')                                ;


% =========================================================================
% --- set properties of group text and group sub text
% =========================================================================
set(get(hGroupText,'Children'),'Units','normalized'                     ...
    ,'HorizontalAlignment','left','Color',textcolor)                        ;
set(get(hGroupSubText,'Children'),'Units','normalized'                  ...
    ,'HorizontalAlignment','left','Color',subtextcolor)                     ;
set(get(hGroupSubText1,'Children'),'Units','normalized'                 ...
    ,'HorizontalAlignment','left','Color',subtextcolor)                     ;


% =========================================================================
% --- create pushbuttons on the bottom of figure (Close, Start, Stop ...)
% =========================================================================
hPushbuttonClose = uicontrol(hFigXPCSMovie,'Style','pushbutton'         ...
    ,'Units','normalized','String','Close','Position',[.02 .02 .12 .05] ...
    ,'Tag','figxpcsmovie_PushbuttonClose','TooltipString','Close window'...
    ,'callback',@xpcsmovie_CloseRequestFcn)                                ;
hPushbuttonShowImage = uicontrol(hFigXPCSMovie,'Style','pushbutton'     ...
    ,'Units','normalized','String','Show Image'                         ...
    ,'Position',[0.16 0.02 0.12 0.05],'Enable','off'                    ...
    ,'Tag','figxpcsmovie_PushbuttonShowImage'                           ...
    ,'TooltipString','Apply changes and show image'                     ...
    ,'callback',@figxpcsmovie_ShowImageFcn)                                ;
hPushbuttonStart = uicontrol(hFigXPCSMovie,'Style','pushbutton'         ...
    ,'Units','normalized','String','Start','Enable','off'               ...
    ,'Position',[0.72 0.02 0.12 0.05]                                   ...
    ,'Tag','figxpcsmovie_PushbuttonStart'                               ...
    ,'TooltipString','Apply changes and start making movie'             ...
    ,'callback',@figxpcsmovie_StartFcn)                                    ;
hPushbuttonStop = uicontrol(hFigXPCSMovie,'Style','pushbutton'          ...
    ,'Units','normalized','String','Stop','Enable','off'                ...
    ,'Position',[0.86 0.02 0.12 0.05]                                   ...
    ,'Tag','figxpcsmovie_PushbuttonStop'                                ...
    ,'TooltipString','Apply changes and stop making movie'              ...
    ,'callback',@figxpcsmovie_StopPushButtonCallbackFcn)                   ;


% =========================================================================
% =========================================================================
% =========================================================================
% --- End of layout part & start of part for callback functions
% =========================================================================
% =========================================================================
% =========================================================================


% =========================================================================
% --- Pushbutton Movie File Callback Function
% =========================================================================
function figxpcsmovie_PushbuttonMovieFileCallbackFcn(hObject,eventdata)
hFigXPCSMovie = findall(0,'Tag','xpcsmovie_Fig')                           ;
ccdmovie = getappdata(hFigXPCSMovie,'ccdmovie')                            ;
currentPath = pwd                                                          ;
go_path_str = ['cd ','''',ccdmovie.imgPath,'''']                           ;
eval(go_path_str)                                                          ;
[filename,pathname] = uiputfile({'*.avi','XPCS Movie File (.avi)'}      ...
    ,'AVI File to Save XPCS Movie','*.avi')     ;
saveFilename = [pathname,filename]                                         ;
if isequal([filename,pathname],[0,0])                                      ;
    go_path_str = ['cd ','''',currentPath,'''']                            ;
    eval(go_path_str)                                                      ;
    clear filename pathname saveFilename ccdmovie currentPath              ;
    clear go_path_str hFigXPCSMovie                                        ;
    return                                                                 ;
end
if strcmp(saveFilename(end-3:end),'.avi') == 0
    saveFilename = [saveFilename,'.avi']                                   ;
end
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditMovieFile')           ...
    ,'String',saveFilename)                           ;
go_path_str = ['cd ','''',currentPath,'''']                                ;
eval(go_path_str)                                                          ;
clear filename pathname saveFilename ccdmovie currentPath                  ;
clear go_path_str hFigXPCSMovie                                            ;


% =========================================================================
% --- Slider Quality Callback Function
% =========================================================================
function figxpcsmovie_SliderQualityCallbackFcn(hObject,eventdata)
set(gco,'TooltipString',[num2str(round(get(gco,'Value'))),'%'])            ;
set(findall(gcf,'Tag','figxpcsmovie_TextQuality')                       ...
    ,'String',['movie quality (',num2str(round(get(gco,'Value'))),'%',')']) ;


% =========================================================================
% --- Close figure close callback fcn
% =========================================================================
function xpcsmovie_CloseRequestFcn(hObject,eventdata)
delete(findall(0,'tag','figxpcsmovie_showimage'))                          ;
delete(findall(0,'Tag','figxpcsmovie_showimage_intensity'))                ;
delete(findall(0,'Tag','figxpcsmovie_showslice'))                          ;
delete(findall(0,'Tag','figxpcsmovie_movie'))                              ;
delete(findall(0,'Tag','figxpcsmovie_staticimage'))                        ;
delete(findall(0,'Tag','figxpcsmovie_avgmovie'))                           ;
delete(gcf)                                                                ;


% =========================================================================
% --- Stop button callback fcn
% =========================================================================
function figxpcsmovie_StopPushButtonCallbackFcn(hObject,eventdata)
setappdata(findall(0,'tag','xpcsmovie_Fig'),'stopflag',1)                  ;


% =========================================================================
%--- LLD radiobuttons callback fcn
% =========================================================================
function figxpcsmovie_RadiobuttonLLDCallbackFcn(hObject,eventdata)
hFigXPCSMovie = findall(0,'Tag','xpcsmovie_Fig');
hRadiobuttonLLD1 = findall(hFigXPCSMovie,'Tag','figxpcsmovie_RadiobuttonLLD1');
hRadiobuttonLLD2 = findall(hFigXPCSMovie,'Tag','figxpcsmovie_RadiobuttonLLD2');
hRadiobuttonLLD3 = findall(hFigXPCSMovie,'Tag','figxpcsmovie_RadiobuttonLLD3');
hEditLLD2        = findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditLLD2');
hEditLLD3        = findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditLLD3');
switch hObject
    case hRadiobuttonLLD1
        set(hRadiobuttonLLD1,'value',1);
        set(hRadiobuttonLLD2,'value',0);
        set(hRadiobuttonLLD3,'value',0);
        set(hEditLLD2,'Enable','on');
        set(hEditLLD3,'Enable','on');
    case hRadiobuttonLLD2
        set(hRadiobuttonLLD1,'value',0);
        set(hRadiobuttonLLD2,'value',1);
        set(hRadiobuttonLLD3,'value',0);
        set(hEditLLD2,'Enable','on');
        set(hEditLLD3,'Enable','on');
    case hRadiobuttonLLD3
        set(hRadiobuttonLLD1,'value',0);
        set(hRadiobuttonLLD2,'value',0);
        set(hRadiobuttonLLD3,'value',1);
        set(hEditLLD2,'Enable','on');
        set(hEditLLD3,'Enable','on');
end


%==========================================================================
% --- Load batchinfo information
%==========================================================================
function xpcsmovie_loadbatchinfo(hObject,eventdata)
hFigXPCSMovie = findall(0,'Tag','xpcsmovie_Fig')                           ;

% --- dlg to select file
[filename, filepath] = uigetfile({'*.batchinfo','Batchinfo Files (*.batchinfo)'} ...
    ,'Select Batchinfo File','MultiSelect', 'off')     ;
if ( isequal([filename,filepath],[0,0]) )
    return                                                                 ;
end
file = fullfile(filepath,filename)                                         ; % full the whole filename

% --- get info file extension
[pathstr,name,ext]    = fileparts(file)                              ;
ccdmovie.batchinfoExtension = ext                                          ;
ccdmovie.imgPath            = pathstr                                      ;
ccdmovie.batchinfoFile      = file                                         ;

% --- open the batchinfo file & read the information
[fid,message] = fopen(file)                                                ; % open file
if fid == -1                                                                 % return if open fails
    uiwait(msgbox(message,'File Open Error','error','modal'))              ;
    fclose(fid)                                                            ;
    return                                                                 ;
end
while feof(fid) == 0
    scanline  = fgetl(fid)                                                 ;
    equal_pos = find(scanline == '=')                                      ;
    left_str  = scanline(1:equal_pos-1)                                    ;
    left_str(findstr(left_str,' '))=''                                     ;
    right_str = scanline(equal_pos+1:end)                                  ;
    eval(['ccdmovie.',left_str,'=','''',right_str,''';'])                  ;
end
fclose(fid)                                                                ; % close file

% --- process the batchinfo information ----
% --- batchinfo_ver
if ( isfield(ccdmovie,'batchinfo_ver') == 1 )
    ccdmovie.batchinfo_ver = str2num(ccdmovie.batchinfo_ver)         ; % should be greater 10
    ccdmovie.mode=2;
else
    ccdmovie.batchinfo_ver = 10                                         ; % if exists batchinfo_ver is always greater 10!!!
end
% --- mode (single : 1 | multi : 2 | not dertmined : 0)
ccdmovie.mode=0;
if ( isfield(ccdmovie,'multi_img') == 1 )
    ccdmovie.multi_img     = str2num(ccdmovie.multi_img)               ;
    ccdmovie.mode          = ccdmovie.multi_img + 1                    ; % reset ccdimginfo.mode (single ~ 1; multi ~ 2) 
end
% --- compression (odd : uncompressed; even : compressed)
if ( isfield(ccdmovie,'compression') == 1 )
    ccdmovie.compression = str2num(ccdmovie.compression)                   ;
else
    if ( ccdmovie.batchinfo_ver > 10 )
        dummy = inputdlg('Please provide file storage mode (single:1|multi:2):', ...
            'Loadbatchinfo dialog')                           ;
        ccdmovie.compression = str2num(dummy)                              ;
    else
        ccdmovie.compression = 0                                           ; % try later to figure the 'compression' out by file analysis
    end
end

if ( isfield(ccdmovie,'info_name') == 1 )
    ccdmovie.info_name(findstr(ccdmovie.info_name,'"')) = ''               ; % remove "
    ccdmovie.info_name(find(ccdmovie.info_name == ' ')) = ''               ; % remove spaces
else
    ccdmovie.info_name = name                                              ; % still available from file parts
end
if ( isfield(ccdmovie,'parent') == 1 )
    ccdmovie.parent(findstr(ccdmovie.parent,'"'))       = ''               ; % remove "
    ccdmovie.parent(find(ccdmovie.parent == ' '))       = ''               ; % remove spaces
end
if ( isfield(ccdmovie,'child') == 1 )
    ccdmovie.child(findstr(ccdmovie.child,'"'))         = ''               ; % remove "
    ccdmovie.child(find(ccdmovie.child == ' '))         = ''               ; % remove spaces
end
if ( isfield(ccdmovie,'suffix') == 1 )
    ccdmovie.suffix(findstr(ccdmovie.suffix,'"'))       = ''               ; % remove "
    ccdmovie.suffix(find(ccdmovie.suffix == ' '))       = ''               ; % remove spaces
end
if ( isfield(ccdmovie,'topup') == 1 )
    ccdmovie.topup(findstr(ccdmovie.topup,'"'))         = ''               ; % remove "
    ccdmovie.topup(find(ccdmovie.topup == ' '))         = ''               ; % remove spaces
end
if ( isfield(ccdmovie,'name') == 1 )
    ccdmovie.name(findstr(ccdmovie.name,'"'))           = ''               ; % remove "
    ccdmovie.name(find(ccdmovie.name == ' '))           = ''               ; % remove spaces
end

ccdmovie.detector         = str2num(ccdmovie.detector)                     ;
ccdmovie.geometry         = str2num(ccdmovie.geometry)                     ;
ccdmovie.kinetics         = str2num(ccdmovie.kinetics)                     ;
if ccdmovie.kinetics == 1
    ccdmovie.kinwinsize   = str2num(ccdmovie.kinwinsize)                   ;
    ccdmovie.slicetop     = str2num(ccdmovie.slicetop)                     ;
else
    ccdmovie.kinwinsize   = -1                                             ;
    ccdmovie.slicetop     = -1                                             ;
end
ccdmovie.rows             = str2num(ccdmovie.rows)                         ;
ccdmovie.cols             = str2num(ccdmovie.cols)                         ;
ccdmovie.col_beg          = str2num(ccdmovie.col_beg)                      ;
ccdmovie.col_end          = str2num(ccdmovie.col_end)                      ;
ccdmovie.row_beg          = str2num(ccdmovie.row_beg)                      ;
ccdmovie.row_end          = str2num(ccdmovie.row_end)                      ;
if (    ccdmovie.batchinfo_ver < 11                                  ...
        && ( ccdmovie.detector == 5 || ccdmovie.detector == 6 ) )                 % correct values for SMD or Dalsa camera
    ccdmovie.col_beg      = ccdmovie.col_beg + 1                           ;
    ccdmovie.col_end      = ccdmovie.col_end + 1                           ;
    ccdmovie.row_beg      = ccdmovie.row_beg + 1                           ;
    ccdmovie.row_end      = ccdmovie.row_end + 1                           ;
end
ccdmovie.ndata0           = str2num(ccdmovie.ndata0)                       ;
ccdmovie.ndataend         = str2num(ccdmovie.ndataend)                     ;
ccdmovie.preset           = str2num(ccdmovie.preset)                       ;

% --- information for the dark images
% --- allow for special treatment of the SMD camera
if ( isfield(ccdmovie,'ndark0') == 1 )
    ccdmovie.ndark0           = str2num(ccdmovie.ndark0)                   ;
else
    ccdmovie.ndark0           = 0.0 * ccdmovie.ndata0 + 99999              ; % dummy value
end
if ( isfield(ccdmovie,'ndarkend') == 1 )
    ccdmovie.ndarkend         = str2num(ccdmovie.ndarkend)                 ;
else
    ccdmovie.ndarkend         = 0.0 * ccdmovie.ndataend + 99998            ; % dummy value ( ndarkend < ndark0 !!! )
end
if ( isfield(ccdmovie,'dark_preset') == 1 )
    ccdmovie.dark_preset      = str2num(ccdmovie.dark_preset)              ;
else
    ccdmovie.dark_preset      = ccdmovie.preset                            ; % set dark preset to data preset
end

% --- for kinetics mode, determine the 1st and last usable slice
% --- also determine positions of each slice
% --- and save these to ccdmovie.sliceinfo
if ccdmovie.kinetics == 1                                                    % kinetic mode
    ccdmovie.firstslice   = 2                                              ;
    ccdmovie.lastslice    = floor( ccdmovie.row_end / ccdmovie.kinwinsize) ;
    shiftOffset = ccdmovie.slicetop - ccdmovie.row_end                     ; % offset for the first used row (negative value!!!)
    for iSlice = 1 : ccdmovie.lastslice
        sliceInfo(iSlice,1) = shiftOffset  +(iSlice-1)*ccdmovie.kinwinsize ; % bottom row of slice
        sliceInfo(iSlice,2) = shiftOffset-1+ iSlice   *ccdmovie.kinwinsize ; % top row of slice
    end
    clear shiftOffset j
else                                                                         % full frame or roi mode
    ccdmovie.firstslice   = -1                                             ;
    ccdmovie.lastslice    = -1                                             ;
    sliceInfo(1,1)= ccdmovie.row_beg                                       ;
    sliceInfo(1,2)= ccdmovie.row_end                                       ;
end
ccdmovie.sliceinfo = sliceInfo                                             ;
clear sliceInfo                                                            ;

% --- initialize the batches, ndata0, ndataend, ndark, ndarkend
% --- to be used in analysis
ccdmovie.batchestodo   = 1                                                 ;
ccdmovie.ndata0todo    = ccdmovie.ndata0                                   ;
ccdmovie.ndataendtodo  = ccdmovie.ndataend                                 ;
ccdmovie.ndark0todo    = ccdmovie.ndark0                                   ;
ccdmovie.ndarkendtodo  = ccdmovie.ndarkend                                 ;

% --- generate file names for all the batches and store in a cell structure
% (Suresh, Jan. 2012)
if ( ( ccdmovie.mode == 0 || ccdmovie.mode == 2 ) && ...
     (ccdmovie.batchinfo_ver >= 13) && (isfield(ccdmovie,'datafilename') == 1) )                        % all old data sets plus all new multi sets
        tmp = strfind(ccdmovie.datafilename,'"');
        tmp = ccdmovie.datafilename(tmp(1)+1 : tmp(end)-1);
        tmp = regexp(tmp,'","','split');
        ccdmovie.imagefile = cell(length(ccdmovie.ndata0),1)           ;        
        for iBatch = 1:length(tmp)
            ccdmovie.imagefile{iBatch} = fullfile(ccdmovie.imgPath,tmp{iBatch}) ;
        end
        if (ccdmovie.compression == 0)
            ccdmovie.darkfile=ccdmovie.imagefile;
        end
        clear tmp;
end

if ( ccdmovie.mode == 1 )                                               % all new data sets in single file storage mode
% % % %     ccdmovie.imagefile = cell(length(ccdmovie.ndata0),1)                   ;
% % % %     if ( ccdmovie.detector ~= 5 && ccdmovie.detector ~= 6 )
% % % %         ccdmovie.imagefile = cell(length(ccdmovie.ndata0),1)               ;
% % % %         for iBatch = 1:length(ccdmovie.ndata0)
% % % %             frameBeg = '00000'                                             ;
% % % %             batchStart = num2str(min(ccdmovie.ndata0(iBatch)            ...
% % % %                 ,ccdmovie.ndark0(iBatch) ) )           ;
% % % %             frameBeg(5-length(num2str(batchStart))+1:end) = batchStart     ;
% % % %             % ---
% % % %             ccdmovie.imagefile{iBatch} = fullfile(ccdmovie.imgPath,     ...
% % % %                 [ccdmovie.name,frameBeg,ccdmovie.suffix])      ;
% % % %             % ---
% % % %             clear batchStart                                               ;
% % % %         end
% % % %     else
% % % %         ccdmovie.imagefile = cell(length(ccdmovie.ndata0),1)               ;
% % % %         for iBatch = 1:length(ccdmovie.ndata0)
% % % %             frameBeg = sprintf('%04i',ccdmovie.ndata0(iBatch))             ;
% % % %             ccdmovie.imagefile{iBatch} = fullfile(ccdmovie.imgPath,     ...
% % % %                 [ccdmovie.name,frameBeg,ccdmovie.suffix])      ;
% % % %         end
% % % %         ccdmovie.darkfile = cell(length(ccdmovie.ndark0),1)                ;
% % % %         for iBatch = 1:length(ccdmovie.ndark0)
% % % %             frameBeg = sprintf('%04i',ccdmovie.ndark0(iBatch))             ;
% % % %             ccdmovie.darkfile{iBatch} = fullfile(ccdmovie.imgPath,      ...
% % % %                 [ccdmovie.name,frameBeg,ccdmovie.suffix])      ;
% % % %         end
% % % %     end
end


% --- some constant or seldom changed information
ccdmovie.tiltAngle                  = 0                                    ; % ccd image tilt angle
ccdmovie.darkSubtract               = ~(ccdmovie.compression)               ; % flag to determine dark subtract 1/0: Yes/No
ccdmovie.lld                        = -15                                  ; % lower-level discrimination; 0 means no lld;minus means absolute lld, plus means relative lld, etc., -12: 12 x ADU, 4 : 4 x dark RMS; in gui, display plus always
ccdmovie.quality                    = 100                                  ; % movie quality (0-100)
ccdmovie.fps                        = 15                                   ; % frame per second
ccdmovie.colormap                   = 'jet'                                ; % colormap for the movie
ccdmovie.contrastMin                = 0                                    ; % image contrast min
ccdmovie.contrastMax                = 2000                                 ; % image contrast max
ccdmovie.labelRealtime              = 1                                    ; % flag to label real time on movie
ccdmovie.saveAvgMovie               = 0                                    ; % flag to save averaged xpcs movie;
ccdmovie.displayStaticImage         = 1                                    ; % flag to display static image 1/0: Yes/No
ccdmovie.playback                   = 0                                    ; % flag to playback (windows os only)

% saving information
ccdmovie.movieFile                  = fullfile(ccdmovie.imgPath,[ccdmovie.name,'Batch_1.avi'])     ; % file to save movie
ccdmovie.avgMovieFile               = fullfile(ccdmovie.imgPath,[ccdmovie.name,'Batch_1_avg.avi']) ; % file to save averaged movie

% --- save ccdmovie to figure
setappdata(hFigXPCSMovie,'ccdmovie',ccdmovie)                              ;
set(hFigXPCSMovie,'Name',['XPCS - Movie Maker - ',filename])               ;

% --- initialize the parameters in figure layout
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_col_beg'),'String',ccdmovie.col_beg,'Enable','inactive');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_col_end'),'String',ccdmovie.col_end,'Enable','inactive');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_row_beg'),'String',ccdmovie.row_beg,'Enable','inactive');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_row_end'),'String',ccdmovie.row_end,'Enable','inactive');
if ccdmovie.kinetics == 1
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_kinetics')  ,'String','Kinetics'         ,'Enable','inactive');
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_kinwinsize'),'String',ccdmovie.kinwinsize,'Enable','inactive');
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_slicetop')  ,'String',ccdmovie.slicetop  ,'Enable','inactive');
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_firstslice'),'String',ccdmovie.firstslice,'Enable','on')      ;
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_lastslice') ,'String',ccdmovie.lastslice ,'Enable','on')      ;
else
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_kinetics')  ,'String','Non-Kinetics'     ,'Enable','inactive');
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_kinwinsize'),'String',ccdmovie.kinwinsize,'Enable','off')     ;
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_slicetop')  ,'String',ccdmovie.slicetop  ,'Enable','off')     ;
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_firstslice'),'String',ccdmovie.firstslice,'Enable','off')     ;
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_lastslice') ,'String',ccdmovie.lastslice ,'Enable','off')     ;
end
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PopupmenuBatchnumber') ,'String',cellstr(num2str([1:length(ccdmovie.ndata0)]')),'Enable','on')      ;
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_ndata0todo')           ,'String',num2str(ccdmovie.ndata0todo(1))               ,'Enable','on')      ;
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_ndataendtodo')         ,'String',num2str(ccdmovie.ndataendtodo(1))             ,'Enable','on')      ;
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_preset')               ,'String',num2str(ccdmovie.preset(1))                   ,'Enable','inactive');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_ndark0todo')           ,'String',num2str(ccdmovie.ndark0todo(1))               ,'Enable','on')      ;
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_ndarkendtodo')         ,'String',num2str(ccdmovie.ndarkendtodo(1))             ,'Enable','on')      ;
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_dark_preset')          ,'String',num2str(ccdmovie.dark_preset(1))              ,'Enable','inactive');

set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PopupmenuDarkSubtract'),'Value',1,'Enable','on');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_RadiobuttonLLD1')      ,'Value',0,'Enable','on');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_RadiobuttonLLD2')      ,'Value',1,'Enable','on');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditLLD2')             ,'String',num2str(abs(ccdmovie.lld)),'Enable','on');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_RadiobuttonLLD3')      ,'Value',0,'Enable','on');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditLLD3')             ,'String','4','Enable','on');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_tiltAngle')            ,'String',num2str(ccdmovie.tiltAngle),'Enable','on');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_SliderQuality')        ,'Enable','on','Value',100,'TooltipString','100%');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_TextQuality')          ,'String','movie quality (100%)');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditFps')              ,'Enable','on','String','15');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PopupmenuColormap')    ,'Enable','on','Value',10);
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditContrastMin')      ,'Enable','on','String','0');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditContrastMax')      ,'Enable','on','String','2000');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PopupmenuLabelRealtime'),'Enable','on','Value',2);
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PushbuttonMovieFile')  ,'Enable','on');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditMovieFile')        ,'String',ccdmovie.movieFile,'Enable','on');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PopupmenuSaveAvgMovie'),'Enable','on','Value',2);
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PopupmenuDisplayStaticImage'),'Enable','on','Value',1);
if ispc == 1
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PopupmenuPlayback'),'Value',2,'Enable','on');
end
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditMessage'),'String',{['   Loaded ',ccdmovie.info_name,'.']},'HorizontalAlignment','left');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PushbuttonShowImage'),'Enable','on');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PushbuttonStart'),'Enable','on');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PushbuttonStop'),'Enable','off');

% --- close all the other figures
delete(findall(0,'tag','figxpcsmovie_showimage'));
delete(findall(0,'Tag','figxpcsmovie_showimage_intensity'));
delete(findall(0,'Tag','figxpcsmovie_showslice'));
delete(findall(0,'Tag','figxpcsmovie_movie'));
delete(findall(0,'Tag','figxpcsmovie_avgmovie'));
delete(findall(0,'Tag','figxpcsmovie_staticimage'));


%==========================================================================
% --- callback of pushbutton show image
%==========================================================================
function figxpcsmovie_ShowImageFcn(hObject,eventdata)
hFigXPCSMovie = findall(0,'Tag','xpcsmovie_Fig')                           ;
hEditMessage  = findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditMessage')    ;
applyXPCSMovie(hFigXPCSMovie)                                              ; % apply all the user changes
ccdmovie      = getappdata(hFigXPCSMovie,'ccdmovie')                       ;

%--- delete previous figures
delete(findall(0,'tag','figxpcsmovie_showimage'))                          ;
delete(findall(0,'Tag','figxpcsmovie_showimage_intensity'))                ;
delete(findall(0,'Tag','figxpcsmovie_showslice'))                          ;
delete(findall(0,'Tag','figxpcsmovie_movie'))                              ;
delete(findall(0,'Tag','figxpcsmovie_avgmovie'))                           ;
delete(findall(0,'Tag','figxpcsmovie_staticimage'))                        ;

% --- load image and dark, calculate true image
if ( ccdmovie.detector ~= 5 && ccdmovie.detector ~= 6 )                    % use only one image for the other cameras
    f = openfile( ccdmovie.imagefile{ccdmovie.batchestodo}               ...
        , ccdmovie.ndata0todo(ccdmovie.batchestodo))                ;
    DI = f.imm                                                             ;
else                                                                         % try to aveage 50 images for the SMD
    FPB = ccdmovie.ndataendtodo(ccdmovie.batchestodo)                   ...
        - ccdmovie.ndata0todo(ccdmovie.batchestodo)                        ;
    f = openfile( ccdmovie.imagefile{ccdmovie.batchestodo}               ...
        , ccdmovie.ndata0todo(ccdmovie.batchestodo))                ;
    DI = zeros(size(f.imm))                                                ;
    for i = 1 : min(50,FPB)
        f = openfile( ccdmovie.imagefile{ccdmovie.batchestodo}           ...
            , ccdmovie.ndata0todo(ccdmovie.batchestodo)+(i-1))      ;
        DI = DI + f.imm                                                    ;
    end
    DI = DI / min(50,FPB)                                                  ;
end
displayImage = (DI)                                            ;
clear DI FPB                                                               ;
if ccdmovie.darkSubtract == 1
    if ( ccdmovie.detector ~= 5 && ccdmovie.detector ~= 6 )
        f = openfile( ccdmovie.imagefile{ccdmovie.batchestodo}           ...
            , ccdmovie.ndark0todo(ccdmovie.batchestodo))            ; % load one dark images for other cameras
        DarkI = f.imm                                                      ;
    else
        FPB = ccdmovie.ndarkendtodo(ccdmovie.batchestodo)               ...
            - ccdmovie.ndark0todo(ccdmovie.batchestodo)                    ;
        if ( FPB > 0 )                                                       % data is not dark subtracted
            f = openfile( ccdmovie.darkfile{ccdmovie.batchestodo}        ...
                , ccdmovie.ndark0todo(ccdmovie.batchestodo))        ;
        else                                                                 % data is already dark subtracted
            f = openfile( ccdmovie.imagefile{ccdmovie.batchestodo}       ...
                , ccdmovie.ndata0todo(ccdmovie.batchestodo))        ; % no dark images taken, take 1st image as dummy
        end
        DarkI = zeros(size(f.imm))                                         ;
        for i = 1 : min(50,FPB)
            f = openfile(ccdmovie.darkfile{ccdmovie.batchestodo}         ...
                ,ccdmovie.ndark0todo(ccdmovie.batchestodo)+(i-1))   ; % load dark images
            DarkI = DarkI + f.imm                                          ;
        end
        DarkI = DarkI / min(50,FPB)                                        ;
    end
    darkImage = (DarkI)                                        ;
    clear DarkI FPB                                                        ;
    
    trueData = displayImage - darkImage                                    ;
    if ccdmovie.lld == 0
        lld = 0                                                            ;
    elseif ccdmovie.lld < 0
        lld = abs(ccdmovie.lld)                                            ;
    elseif ccdmovie.lld > 0
        lld = abs(ccdmovie.lld)*sqrt(mean(darkImage(:)))                   ;
    end
    trueData(find(trueData<lld)) = 0                                       ;
elseif ccdmovie.darkSubtract == 0
    trueData = displayImage                                                ;
end
if ( nnz(trueData) == 0 )
    set(hEditMessage,'String',[get(hEditMessage,'String')               ...
        ;{' ';'   Invalid lower level discrimination.'}]) ;
    return                                                                 ;
end

% --- create figure
figureSize = [560 420];
hFigXPCSMovieShowImage = figure('BackingStore','off','Units','pixels'   ...
    ,'DoubleBuffer','on','DockControls','off'...
    ,'PaperOrient','portrait'                ...
    ,'IntegerHandle','off'                   ...
    ,'NumberTitle','off'                     ...
    ,'MenuBar','none'                        ...
    ,'Name',['XPCS - Movie Maker - Image of Frame ',num2str(ccdmovie.ndata0todo(ccdmovie.batchestodo))] ...
    ,'color',[1 1 0.85],'Toolbar','none'                   ...
    ,'WindowButtonMotionFcn',@figure_WindowButtonMotionFcn ...
    ,'Position',[100,100,figureSize]                       ...
    ,'Tag','figxpcsmovie_showimage'                        ...
    ,'UserData',[])                                           ;
hToolbar = uitoolbar(hFigXPCSMovieShowImage,'Tag','figxpcsmovie_showimage_Toolbar');
iconToolbarSave = load('savedoc.mat');
hToolbarSave = uipushtool(hToolbar,...
    'CDATA',iconToolbarSave.cdata,...
    'Separator','on',...
    'TooltipString','Save Figure',...
    'ClickedCallback',@toolbarSaveFcn,...
    'Tag','toolbarSave');
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
iconToolbarColormapeditor = load('colormapeditor.mat');
hToolbarColormapeditor = uipushtool(hToolbar,...
    'CDATA',iconToolbarColormapeditor.cdata,...
    'Separator','on',...
    'TooltipString','Edit Colormap',...
    'ClickedCallback','colormapeditor;',...
    'Tag','toolbarColormapeditor');
% --- activate figure and plot true image
figure(hFigXPCSMovieShowImage);
hImm = imagesc(trueData,[ccdmovie.contrastMin ccdmovie.contrastMax]);
colormap(ccdmovie.colormap);
set(hImm,'Tag','figxpcsmovie_showimage_image');
uicontrol('Parent',hFigXPCSMovieShowImage,...
    'Style','Text',...
    'BackgroundColor',[1 1 0.85],...
    'String',' ',...
    'units','normalized',...
    'HorizontalAlignment','left',...
    'position',[0.05 0.01 0.5 0.05],...
    'Tag','mouseposition');
set(get(hImm,'Parent'),'YDir','normal');
% --- for kinetics mode, calculate offset, shifted pixels for plotting correction line and total # of slices
if ccdmovie.kinetics == 1
    shiftOffset = (ccdmovie.slicetop-ccdmovie.row_end);
    shiftedPixels = ccdmovie.row_end - shiftOffset ...
        - ccdmovie.lastslice * ccdmovie.kinwinsize;
    totalSlice = floor(ccdmovie.row_end/ccdmovie.kinwinsize);
end
% --- For kinetics mode,
% 1. label all the slices and draw slice separation lines;
% 2. creat figure to show the average intensity of columns
if ccdmovie.kinetics == 1
    % --- label all the slices and draw slice separation lines
    for iSlice = 1:totalSlice
        text('Parent',get(hImm,'Parent'),...
            'Position',[12 ccdmovie.kinwinsize*(iSlice-0.5)+shiftOffset],...
            'String',num2str(iSlice),...
            'FontWeight','demi',...
            'color',[1 1 1],...
            'Tag','figxpcsmovie_showimage_slicelabel');
        line('Parent',get(hImm,'Parent'),...
            'XData',[0.5,ccdmovie.col_end-ccdmovie.col_beg+0.5],...
            'YData',[ccdmovie.kinwinsize*iSlice+0.5+shiftOffset,ccdmovie.kinwinsize*iSlice+0.5+shiftOffset],...
            'Tag','figxpcsmovie_showimag_sliceseparationline',...
            'color','g');
    end
    % --- create figure if not exist, else refresh it
    hFigXPCSMovieShowImageInt = figure(...
        'BackingStore','off',...
        'Units','pixels',...
        'DockControls','off',...
        'DoubleBuffer','on',...
        'PaperOrient','portrait',...
        'IntegerHandle','off',...
        'NumberTitle','off',...
        'MenuBar','none',...
        'Name',['XPCS - Movie Maker - Intensity in Column of Frame ',num2str(ccdmovie.ndata0todo(ccdmovie.batchestodo))],...
        'color',[1 1 0.85],...
        'Toolbar','none',...
        'HandleVisibility','callback',...
        'Position',[100,150,figureSize],...
        'Tag','figxpcsmovie_showimage_intensity',...
        'UserData',[]);
    hAxes = axes('Parent',hFigXPCSMovieShowImageInt,...
        'Units','normalized',...
        'Position',[0.13 0.11 0.775 0.815],...
        'Box','on',...
        'Tag','figxpcsmovie_showimage_intensity_axes');
    set(hAxes,'XLim',[1 ccdmovie.row_end-ccdmovie.row_beg+1]);
    set(get(hAxes,'XLabel'),'String','Row Pixel Number');
    set(get(hAxes,'YLabel'),'String','ADU');
    hToolbar = uitoolbar(hFigXPCSMovieShowImageInt,'Tag','figxpcsmovie_showimage_intensity_Toolbar');
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
    % --- calculate average intensity of colums and plot
    imageIntensity = get(findall(findall(0,'Tag','figxpcsmovie_showimage_image'),'type','image'),'cdata');
    avgInt = sum(imageIntensity,2)/(ccdmovie.col_end - ccdmovie.col_beg + 1);
    hLine = line('Parent',findall(hFigXPCSMovieShowImageInt,'Tag','figxpcsmovie_showimage_intensity_axes'),...
        'XData',[1:length(avgInt)],...
        'YData',avgInt,...
        'Tag','figxpcsmovie_showimage_intensity_line');
    % --- label slice number
    for iSlice = 1:totalSlice
        if iSlice < ccdmovie.firstslice | iSlice > ccdmovie.lastslice
            text('Parent',findall(hFigXPCSMovieShowImageInt,'Tag','figxpcsmovie_showimage_intensity_axes'),...
                'Position',[ccdmovie.kinwinsize*(iSlice-0.5)+shiftOffset max(avgInt)/10],...
                'String',num2str(iSlice),...
                'FontWeight','demi',...
                'color','r',...
                'Tag','figxpcsmovie_showimage_intensity_slicelabel');
        else
            text('Parent',findall(hFigXPCSMovieShowImageInt,'Tag','figxpcsmovie_showimage_intensity_axes'),...
                'Position',[ccdmovie.kinwinsize*(iSlice-0.5) max(avgInt)/10],...
                'String',num2str(iSlice),...
                'FontWeight','demi',...
                'color','g',...
                'Tag','figxpcsmovie_showimage_intensity_slicelabel');
        end
    end
    % --- creat image to show sum of user selected slices in one frame
    figureSize = [560 420];
    hFigXPCSMovieShowSlice = figure(...
        'BackingStore','off',...
        'Units','pixels',...
        'DockControls','off',...
        'DoubleBuffer','on',...
        'PaperOrient','portrait',...
        'IntegerHandle','off',...
        'NumberTitle','off',...
        'MenuBar','none',...
        'Name',['XPCS - Movie Maker - Slice Sum of Frame ',num2str(ccdmovie.ndata0todo(ccdmovie.batchestodo))],...
        'color',[1 1 0.85],...
        'Toolbar','none',...
        'Position',[100,125,figureSize],...
        'Tag','figxpcsmovie_showslice',...
        'WindowButtonMotionFcn',@figure_WindowButtonMotionFcn,...
        'WindowStyle','normal',...
        'WindowButtonDownFcn','',...
        'WindowButtonUpFcn','',...
        'UserData',[]);
    % --- toolbar layout
    hToolbar = uitoolbar(hFigXPCSMovieShowSlice,'Tag','figxpcsmovie_showslice_Toolbar');
    iconToolbarSave = load('savedoc.mat');
    hToolbarSave = uipushtool(hToolbar,...
        'CDATA',iconToolbarSave.cdata,...
        'Separator','on',...
        'TooltipString','Save Figure',...
        'ClickedCallback',@toolbarSaveFcn,...
        'Tag','toolbarSave');
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
    iconToolbarColormapeditor = load('colormapeditor.mat');
    hToolbarColormapeditor = uipushtool(hToolbar,...
        'CDATA',iconToolbarColormapeditor.cdata,...
        'Separator','on',...
        'TooltipString','Edit Colormap',...
        'ClickedCallback','colormapeditor;',...
        'Tag','toolbarColormapeditor');
    uicontrol('Parent',hFigXPCSMovieShowSlice,...
        'Style','Text',...
        'BackgroundColor',[1 1 0.85],...
        'String',' ',...
        'units','normalized',...
        'HorizontalAlignment','left',...
        'position',[0.05 0.01 0.5 0.05],...
        'Tag','mouseposition');
    % --- activate figure and plot sum of slices
    figure(hFigXPCSMovieShowSlice);
    displaySlice = trueData(ccdmovie.sliceinfo(ccdmovie.lastslice,1):ccdmovie.sliceinfo(ccdmovie.lastslice,2),:);
    for iSlice = ccdmovie.lastslice-1:-1:ccdmovie.lastslice-2
        try
            displaySlice = displaySlice + trueData(ccdmovie.sliceinfo(iSlice,1):ccdmovie.sliceinfo(iSlice,2),:);
        catch
        end
    end
    hImm = imagesc(displaySlice,[ccdmovie.contrastMin ccdmovie.contrastMax]);
    colormap(ccdmovie.colormap);
    set(hImm,'Tag','figxpcsmovie_showslice_image');
    set(get(hImm,'Parent'),'YDir','normal');
    % --- arrange figure display order
    figure(hFigXPCSMovieShowImageInt);
    pause(0);
    figure(hFigXPCSMovieShowImage);
    pause(0);
    figure(hFigXPCSMovieShowSlice);
end


%================================================================
% --- function to apply user changes
%================================================================
function applyXPCSMovie(hFigXPCSMovie)
ccdmovie = getappdata(hFigXPCSMovie,'ccdmovie');
% --- get slice information
if ccdmovie.kinetics == 1
    if ~isnan(str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_kinwinsize'),'string')))
        ccdmovie.kinwinsize   = str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_kinwinsize'),'string'));
    end
    if ~isnan(str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_slicetop'),'string')))
        ccdmovie.slicetop    = str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_slicetop'),'string'));
    end
    if ~isnan(str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_firstslice'),'string')))
        ccdmovie.firstslice  = str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_firstslice'),'string'));
    else
        set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_firstslice'),'string',num2str(ccdmovie.firstslice));
    end
    if ~isnan(str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_lastslice'),'string')))
        ccdmovie.lastslice   = str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_lastslice'),'string'));
    else
        set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_lastslice'),'string',num2str(ccdmovie.lastslice));
    end
end
% --- get informtion of each batch and batch to do
iBatch = get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PopupmenuBatchnumber'),'value');
temp = str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_ndata0todo'),'string'));
if ~isnan(temp) & temp >= ccdmovie.ndata0(iBatch) & temp <= ccdmovie.ndataend(iBatch)
    ccdmovie.ndata0todo(iBatch)           = temp;
else
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_ndata0todo'),'string',num2str(ccdmovie.ndata0todo(iBatch)));
end
temp = str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_ndataendtodo'),'string'));
if ~isnan(temp) & temp >= ccdmovie.ndata0todo(iBatch) & temp <= ccdmovie.ndataend(iBatch)
    ccdmovie.ndataendtodo(iBatch)         = temp;
else
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_ndataendtodo'),'string',num2str(ccdmovie.ndataendtodo(iBatch)));
end
temp = str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_ndark0todo'),'string'));
if ~isnan(temp) & temp >= ccdmovie.ndark0(iBatch) & temp <= ccdmovie.ndarkend(iBatch)
    ccdmovie.ndark0todo(iBatch)           = temp;
else
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_ndark0todo'),'string',num2str(ccdmovie.ndark0todo(iBatch)));
end
temp = str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_ndarkendtodo'),'string'));
if ~isnan(temp) & temp >= ccdmovie.ndark0todo(iBatch) & temp <= ccdmovie.ndarkend(iBatch)
    ccdmovie.ndarkendtodo(iBatch)         = temp;
else
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_ndarkendtodo'),'string',num2str(ccdmovie.ndarkendtodo(iBatch)));
end
ccdmovie.batchestodo = iBatch;
% --- get dark information
if get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PopupmenuDarkSubtract'),'value') == 1
    ccdmovie.darkSubtract = 1;
    % --- get lld
    switch 1
        case get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_RadiobuttonLLD1'),'value')
            ccdmovie.lld              = 0;
        case get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_RadiobuttonLLD2'),'value')
            if ~isnan(str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditLLD2'),'string')))
                ccdmovie.lld          = -abs(str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditLLD2'),'string')));
            else
                ccdmovie.lld          = -15;
                set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditLLD2'),'string','15');
            end
        case get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_RadiobuttonLLD3'),'value')
            if ~isnan(str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditLLD3'),'string')))
                ccdmovie.lld          = abs(str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditLLD3'),'string')));
            else
                ccdmovie.lld          = 4;
                set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditLLD3'),'string','4');
            end
    end
elseif get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PopupmenuDarkSubtract'),'value') == 2
    ccdmovie.darkSubtract = 0;
end
% --- get tilt angle
if ~isnan(str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_tiltAngle'),'string')))
    ccdmovie.tiltAngle = str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_tiltAngle'),'string'));
else
    ccdmovie.tiltAngle = 0;
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_tiltAngle'),'string','0');
end
% --- get movie settings
ccdmovie.quality = round(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_SliderQuality'),'Value'));
temp = str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditFps'),'string'));
if ~isnan(temp) & temp > 0
    ccdmovie.fps = temp;
else
    ccdmovie.fps = 15;
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditFps'),'string','15');
end
colormap_str = get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PopupmenuColormap'),'String');
ccdmovie.colormap = colormap_str{get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PopupmenuColormap'),'Value')};
temp = str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditContrastMin'),'string'));
if ~isnan(temp) & temp >= 0
    ccdmovie.contrastMin = temp;
else
    ccdmovie.contrastMin = 0;
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditContrastMin'),'string','0');
end
temp = str2double(get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditContrastMax'),'string'));
if ~isnan(temp) & temp > ccdmovie.contrastMin
    ccdmovie.contrastMax = temp;
else
    ccdmovie.contrastMax = ccdmovie.contrastMin+2000;
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditContrastMax'),'string',num2str(ccdmovie.contrastMax));
end
switch get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PopupmenuLabelRealtime'),'Value')
    case 1
        ccdmovie.labelRealtime = 1;
    case 2
        ccdmovie.labelRealtime = 0;
end
% --- get saving settings
ccdmovie.movieFile = get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditMovieFile'),'String');
if isempty(ccdmovie.movieFile) | length(ccdmovie.movieFile) <= 4
    ccdmovie.movieFile    = fullfile(ccdmovie.imgPath,[ccdmovie.name,'Batch_',num2str(ccdmovie.batchestodo),'.avi']);
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditMovieFile'),'String',ccdmovie.movieFile);
end
ccdmovie.avgMovieFile     = [ccdmovie.movieFile(1:end-4),'_avg.avi'];
switch get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PopupmenuSaveAvgMovie'),'value')
    case 1
        ccdmovie.saveAvgMovie = 1;
    case 2
        ccdmovie.saveAvgMovie = 0;
end
% --- get display static settings
switch get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PopupmenuDisplayStaticImage'),'value')
    case 1
        ccdmovie.displayStaticImage = 1;
    case 2
        ccdmovie.displayStaticImage = 0;
end
% --- playback settings
switch get(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PopupmenuPlayback'),'Value')
    case 1
        ccdmovie.playback = 1;
    case 2
        ccdmovie.playback = 0;
end
% --- save ccdmovie to xpcsmovie figure
setappdata(hFigXPCSMovie,'ccdmovie',ccdmovie);
%assignin('base','ccdmovie',ccdmovie);


% =========================================================================
% --- toolbar save callback function to save current figure
% =========================================================================
function toolbarSaveFcn(hObject,eventdata)
hFig = gcf;
hAxes = gca;
[filename,pathname,filterIndex] =uiputfile(...
    {'*.tiff','TIFF image (*.tiff)';...
    '*.png','Portable Network Graphics file (*.png)'},...
    'Save As','*.tiff');
saveFilename = [pathname,filename];
if isequal([filename,pathname],[0,0])
    return;
end
hImage      = findall(hFig,'type','image');
warning off;
cdata       = uint16(get(hImage(end),'cdata'));
warning on;
switch filterIndex
    case 1
        imwrite(cdata,saveFilename,'tiff');
    case 2
        imwrite(cdata,saveFilename,'png');
end


%================================================================
% --- toolbar zoom callback
%================================================================
function toolbarZoomFcn(hObject,eventdata)
hFig = gcbf;
hToolbarZoom = findall(hFig,'Tag','toolbarZoom');
hToolbarPan = findall(hFig,'Tag','toolbarPan');
zoom;
pan off;
set(hToolbarPan,'state','off');


%================================================================
% --- toolbar pan callback
%================================================================
function toolbarPanFcn(hObject,eventdata)
hFig = gcbf;
hToolbarZoom = findall(hFig,'Tag','toolbarZoom');
hToolbarPan = findall(hFig,'Tag','toolbarPan');
zoom off;
pan;
set(hToolbarZoom,'state','off');


%================================================================
% --- tracking mouse position
%================================================================
function figure_WindowButtonMotionFcn(hObject,eventdata)
set(gcf,'selected','on');
pointPosition = get(gca,'CurrentPoint');
XLim=get(gca,'XLim');
YLim=get(gca,'YLim');
XLimFlag=(pointPosition(1,1)>=XLim(1) & pointPosition(1,1)<=XLim(2));
YLimFlag=(pointPosition(1,2)>=YLim(1) & pointPosition(1,2)<=YLim(2));
cdata = get(findall(gcf,'type','image'),'cdata');
xpos = round(pointPosition(1,1));
ypos = round(pointPosition(1,2));
if xpos >= 1 & xpos <= size(cdata,2) & ypos >= 1 & ypos <= size(cdata,1) & XLimFlag == 1 & YLimFlag ==1
    set(gcf,'Pointer','crosshair');
    set(findall(gcf,'Tag','mouseposition'),'string',['x=',num2str(xpos),', y=',num2str(ypos),', value=',num2str(cdata(ypos,xpos))]);
else
    set(gcf,'Pointer','arrow');
end
clear XLim YLim XLimFlag YLimFlag;
clear pointPosition xpos ypos cdata;


%================================================================
% --- callback Fcn of pushbutton 'Start' to make movie
%================================================================
function figxpcsmovie_StartFcn(hObject,eventdata)
hFigXPCSMovie = findall(0,'Tag','xpcsmovie_Fig');
hEditMessage =findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditMessage');
applyXPCSMovie(hFigXPCSMovie);                % apply all the user changes
ccdmovie = getappdata(hFigXPCSMovie,'ccdmovie');
%--- delete previous figures
delete(findall(0,'tag','figxpcsmovie_showimage'));
delete(findall(0,'Tag','figxpcsmovie_showimage_intensity'));
delete(findall(0,'Tag','figxpcsmovie_showslice'));
delete(findall(0,'Tag','figxpcsmovie_movie'));
delete(findall(0,'Tag','figxpcsmovie_avgmovie'));
delete(findall(0,'Tag','figxpcsmovie_staticimage'));
% --- set pushbutton status
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PushbuttonShowImage'),'Enable','off');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PushbuttonStart'),'Enable','off');
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PushbuttonStop'),'Enable','on');
% --- set stop flag
setappdata(hFigXPCSMovie,'stopflag',0);
% --- determine the existence of the saving folder
[savePath,saveName,saveExtension] = fileparts(ccdmovie.movieFile);
if ~isdir(savePath)
    buttonName = questdlg('Saving folder does not exist. Do you want to creat it?','Create New Folder','Yes','No','Yes');
    switch buttonName
        case 'Yes'
            try
                mkdir(savePath);
                set(hEditMessage,'String',[get(hEditMessage,'String');{' ';'   Created new saving folder:';savePath}]);
            catch
                set(hEditMessage,'String',[get(hEditMessage,'String');{' ';'   Failed in creating new saving folder:';savePath;'   Abort making movie.'}]);
                reset_status(hFigXPCSMovie);
                return;
            end
        case 'No'
            set(hEditMessage,'String',[get(hEditMessage,'String');{' ';'   Cancelled creating new folder. Aborted making movie.'}]);
            reset_status(hFigXPCSMovie);
            return;
    end
end
% --- determine the existence of the file, if exist delete it
warning off                                                                ;
if exist(ccdmovie.movieFile) == 2
    delete(ccdmovie.movieFile)                                             ;
    set(hEditMessage,'String',[get(hEditMessage,'String');{' ';'   Movie(AVI) file exist. Will overwrite the existing file.'}]);
    pause(0);
end
if exist(ccdmovie.avgMovieFile) == 2
    delete(ccdmovie.avgMovieFile)                                          ;
    set(hEditMessage,'String',[get(hEditMessage,'String');{' ';'   Averaged movie(AVI) file exist. Will overwrite the existing file.'}]);
    pause(0);
end
warning on                                                                 ;

% --- get dark if user choose to do dark subtraction
if ( ccdmovie.darkSubtract == 1 )
    msgstr = get(hEditMessage,'String')                                    ;
    tic                                                                    ;
    % ---
    dummy     = openfile( ccdmovie.imagefile{ccdmovie.batchestodo}       ...
        , ccdmovie.ndata0todo(ccdmovie.batchestodo))        ; % take 1st data image as dummy (always there)
    darkImage = zeros(size(dummy.imm))                                     ; % initialize the dark image
    clear dummy                                                            ;
    % ---
    if ( ccdmovie.detector ~= 5 && ccdmovie.detector ~= 6 )
        for iDark = ccdmovie.ndark0todo(ccdmovie.batchestodo)            ...
                : ccdmovie.ndarkendtodo(ccdmovie.batchestodo)
            if getappdata(hFigXPCSMovie,'stopflag') == 1
                set(hEditMessage,'String',[get(hEditMessage,'String')   ...
                    ;{' ';'   Abort making movie.'}]);
                pause(0)                                                   ;
                reset_status(hFigXPCSMovie)                                ;
                return                                                     ;
            end
            TI = openfile(ccdmovie.imagefile{ccdmovie.batchestodo},iDark)   ;
            darkImage = (TI.imm) + darkImage                   ;
            set(hEditMessage,'String',[msgstr;{' ';['   Getting dark image of frame ',num2str(iDark),' ...']}]);
            pause(0)                                                       ;
        end
        darkImage = darkImage/(ccdmovie.ndarkendtodo(ccdmovie.batchestodo)-ccdmovie.ndark0todo(ccdmovie.batchestodo)+1);
        set(hEditMessage,'String',[msgstr;{' ';['   Finish getting dark images (',num2str(ccdmovie.ndark0todo(ccdmovie.batchestodo)),'-',num2str(ccdmovie.ndarkendtodo(ccdmovie.batchestodo)),') in ',num2str(toc),' secondes.']}]);
        pause(0)                                                           ;
    else
        FPB = ccdmovie.ndarkendtodo(ccdmovie.batchestodo)               ...
            - ccdmovie.ndark0todo(ccdmovie.batchestodo)                    ;
        for iDark = ccdmovie.ndark0todo(ccdmovie.batchestodo)            ...
                : ccdmovie.ndarkendtodo(ccdmovie.batchestodo)
            if getappdata(hFigXPCSMovie,'stopflag') == 1
                set(hEditMessage,'String',[get(hEditMessage,'String')   ...
                    ;{' ';'   Abort making movie.'}]);
                pause(0)                                                   ;
                reset_status(hFigXPCSMovie)                                ;
                return                                                     ;
            end
            TI = openfile(ccdmovie.darkfile{ccdmovie.batchestodo},iDark)    ;
            darkImage = (TI.imm) + darkImage                   ;
            set(hEditMessage,'String',[msgstr;{' ';['   Getting dark image of frame ',num2str(iDark),' ...']}]);
            pause(0)                                                       ;
        end
        if ( FPB > 0 )                                                       % data is not dark subtracted
            darkImage = darkImage/(ccdmovie.ndarkendtodo(ccdmovie.batchestodo)-ccdmovie.ndark0todo(ccdmovie.batchestodo)+1);
        end
        set(hEditMessage,'String',[msgstr;{' ';['   Finish getting dark images (',num2str(ccdmovie.ndark0todo(ccdmovie.batchestodo)),'-',num2str(ccdmovie.ndarkendtodo(ccdmovie.batchestodo)),') in ',num2str(toc),' secondes.']}]);
        pause(0)                                                           ;
    end
    if ccdmovie.lld == 0
        lld = 0                                                            ;
    elseif ccdmovie.lld < 0
        lld = abs(ccdmovie.lld)                                            ;
    elseif ccdmovie.lld > 0
        lld = abs(ccdmovie.lld)*sqrt(mean(darkImage(:)))                   ;
    end
end

% --- for kinetics mode, calculate offset, shifted pixels for plotting correction line and total # of slices
if ccdmovie.kinetics == 1
    shiftOffset = (ccdmovie.slicetop-ccdmovie.row_end);
    shiftedPixels = ccdmovie.row_end - shiftOffset ...
        - ccdmovie.lastslice * ccdmovie.kinwinsize;
    totalSlice = floor(ccdmovie.row_end/ccdmovie.kinwinsize);
end

% --- get images
try
    mov = VideoWriter(ccdmovie.movieFile);
    mov.FrameRate = ccdmovie.fps;
    mov.Quality = ccdmovie.quality;
    open(mov);
    
    set(hEditMessage,'String',[get(hEditMessage,'String');{' ';'   Open/Create and write to AVI file:';ccdmovie.movieFile}]);
catch
    set(hEditMessage,'String',[get(hEditMessage,'String');{' ';'   Failed in creating/opening AVI file:';ccdmovie.movieFile}]);
    reset_status(hFigXPCSMovie);
    return;
end
if ccdmovie.saveAvgMovie == 1
    try
        avgmov = VideoWriter(ccdmovie.avgMovieFile);
        avgmov.FrameRate = ccdmovie.fps;
        avgmov.Quality = ccdmovie.quality;
        open(avgmov);
        set(hEditMessage,'String',[get(hEditMessage,'String');{' ';'   Open/Create and write to AVI file:';ccdmovie.avgMovieFile}]);
    catch
        set(hEditMessage,'String',[get(hEditMessage,'String');{' ';'   Failed in creating/opening AVI file:';ccdmovie.avgMovieFile}]);
        reset_status(hFigXPCSMovie);
        return;
    end
end
% --- figure for dynamic movie
figureSize = [560 420];
hFigMovie = figure(...
    'BackingStore','off',...
    'Units','pixels',...
    'DoubleBuffer','on',...
    'DockControls','off',...
    'PaperOrient','portrait',...
    'IntegerHandle','off',...
    'NumberTitle','off',...
    'MenuBar','none',...
    'Name',['XPCS - Movie Maker'],...
    'color',[1 1 0.85],...
    'Toolbar','none',...
    'position',[30 50 figureSize],...
    'Resize','off',...
    'Tag','figxpcsmovie_movie',...
    'UserData',[]);
hAxes = gca;
% --- figure for averaged movie
if ccdmovie.saveAvgMovie == 1
    hFigAvgMovie = figure(...
        'BackingStore','off',...
        'Units','pixels',...
        'DoubleBuffer','on',...
        'DockControls','off',...
        'PaperOrient','portrait',...
        'IntegerHandle','off',...
        'NumberTitle','off',...
        'MenuBar','none',...
        'Name',['XPCS - Movie Maker'],...
        'color',[1 1 0.85],...
        'Toolbar','none',...
        'position',[30+figureSize(1)+20 50 figureSize],...
        'Resize','off',...
        'Tag','figxpcsmovie_avgmovie',...
        'UserData',[]);
    hAxesAvg = gca;
end
msgstr = get(hEditMessage,'String');
tic;
warning off;
sumImage = 0;
for iData = ccdmovie.ndata0todo(ccdmovie.batchestodo):ccdmovie.ndataendtodo(ccdmovie.batchestodo)
    % --- if stop button clicked
    if getappdata(hFigXPCSMovie,'stopflag') == 1
        set(hEditMessage,'String',[get(hEditMessage,'String');{' ';'   Aborted making movie.'}]);
        pause(0);
        delete(findall(0,'Tag','figxpcsmovie_movie'));
        delete(findall(0,'Tag','figxpcsmovie_avgmovie'));
        if exist(ccdmovie.movieFile) == 2
            close(mov);
            delete(ccdmovie.movieFile);
            set(hEditMessage,'String',[get(hEditMessage,'String');{' ';'   AVI file was deleted.'}]);
            pause(0);
        end
        if ccdmovie.saveAvgMovie == 1
            if exist(ccdmovie.avgMovieFile) == 2
                close(avgmov);
                delete(ccdmovie.avgMovieFile);
                set(hEditMessage,'String',[get(hEditMessage,'String');{' ';'   AVI file was deleted.'}]);
                pause(0);
            end
        end
        reset_status(hFigXPCSMovie);
        return;
    end
    % --- get data
    set(hEditMessage,'String',[msgstr;{' ';['   Getting data image of frame ',num2str(iData),' ...']}]);
    set(hFigMovie,'Name',['XPCS - Movie Maker - Frame ',num2str(iData),' (Do NOT Close!)']);
    if ccdmovie.saveAvgMovie == 1
        set(hFigAvgMovie,'Name',['XPCS - Movie Maker - Averaged Frames ',num2str(ccdmovie.ndata0todo(ccdmovie.batchestodo)),'-',num2str(iData),' (Do NOT Close!)']);
    end
    pause(0);
    temp_image = openfile(ccdmovie.imagefile{ccdmovie.batchestodo},iData);
    image_time = temp_image.header{20,2};
    trueData = (temp_image.imm);
    if ccdmovie.darkSubtract == 1
        trueData = trueData - darkImage;
        trueData(trueData<lld) = 0;
    end
    if ccdmovie.kinetics == 1
        displayImage = trueData(ccdmovie.sliceinfo(ccdmovie.lastslice,1):ccdmovie.sliceinfo(ccdmovie.lastslice,2),:);
        for iSlice = ccdmovie.lastslice-1:-1:ccdmovie.lastslice-2
            try
                displayImage = displayImage + trueData(ccdmovie.sliceinfo(iSlice,1):ccdmovie.sliceinfo(iSlice,2),:);
            catch
            end
        end
    else
        displayImage = trueData;
    end
    sumImage = displayImage + sumImage;
    % --- display the figure image
    if iData == ccdmovie.ndata0todo(ccdmovie.batchestodo)
        start_time = image_time;
        % --- movie
        image(displayImage,'CDataMapping','scaled','parent',hAxes,'EraseMode','normal');
        colormap(hAxes,ccdmovie.colormap);
        set(hAxes,...
            'NextPlot','replace',...
            'TickDir','out',...
            'YDir','normal',...
            'DrawMode','fast',...
            'CLimMode','manual',...
            'CLim',[ccdmovie.contrastMin,ccdmovie.contrastMax]);
        hImm = findall(hFigMovie,'type','image');
        if ccdmovie.labelRealtime == 1
            hText = text('Parent',hAxes,...
                'Tag','figxpcsmovie_movie_text_time',...
                'String','time(sec): 0',...
                'Position',[0.05 0.05],...
                'Units','normalized',...
                'HorizontalAlignment','left',...
                'BackgroundColor','w',...
                'Color','b',...
                'FontWeight','demi');
        end
        % --- averaged movie
        if ccdmovie.saveAvgMovie == 1
            image(sumImage/(iData-ccdmovie.ndata0todo(ccdmovie.batchestodo)+1),'CDataMapping','scaled','parent',hAxesAvg,'EraseMode','normal');
            colormap(hAxesAvg,ccdmovie.colormap);
            set(hAxesAvg,...
                'NextPlot','replace',...
                'TickDir','out',...
                'YDir','normal',...
                'DrawMode','fast',...
                'CLimMode','manual',...
                'CLim',[ccdmovie.contrastMin,ccdmovie.contrastMax]);
            hImmAvg = findall(hFigAvgMovie,'type','image');
            if ccdmovie.labelRealtime == 1
                hTextAvg = text('Parent',hAxesAvg,...
                    'Tag','figxpcsmovie_movie_text_time',...
                    'String','time(sec): 0',...
                    'Position',[0.05 0.05],...
                    'Units','normalized',...
                    'HorizontalAlignment','left',...
                    'BackgroundColor','w',...
                    'Color','b',...
                    'FontWeight','demi');
            end
        end
    else
        set(hImm,'cdata',displayImage);
        if ccdmovie.labelRealtime == 1
            set(hText,'String',['time(sec): ',num2str(image_time-start_time)]);
        end
        if ccdmovie.saveAvgMovie == 1
            set(hImmAvg,'cdata',sumImage/(iData-ccdmovie.ndata0todo(ccdmovie.batchestodo)+1));
            if ccdmovie.labelRealtime == 1
                set(hTextAvg,'String',['time(sec): ',num2str(image_time-start_time)]);
            end
        end
    end
    F = getframe(hAxes);
    writeVideo(mov,F);
    if ccdmovie.saveAvgMovie == 1
        F = getframe(hAxesAvg);
        writeVideo(avgmov,F);
    end
end
close(mov);
set(hFigMovie,'Name',['XPCS - Movie Maker - Done']);
if ccdmovie.saveAvgMovie == 1
    close(avgmov);
    set(hFigAvgMovie,'Name',['XPCS - Movie Maker - Done - Averaged Movie']);
end
set(hEditMessage,'String',[msgstr;{' ';['   Finish getting data images (',num2str(ccdmovie.ndata0todo(ccdmovie.batchestodo)),'-',num2str(ccdmovie.ndataendtodo(ccdmovie.batchestodo)),') in ',num2str(toc),' secondes.']}]);
set(hEditMessage,'String',[get(hEditMessage,'String');{' ';'   Saved movie to:';ccdmovie.movieFile}]);
if ccdmovie.saveAvgMovie == 1
    set(hEditMessage,'String',[get(hEditMessage,'String');{' ';'   Saved movie to:';ccdmovie.avgMovieFile}]);
end
pause(0);
warning on;
% --- display averaged summed static image
sumImage = sumImage/(ccdmovie.ndataendtodo(ccdmovie.batchestodo)-ccdmovie.ndata0todo(ccdmovie.batchestodo)+1);
if ccdmovie.displayStaticImage == 1
    set(hEditMessage,'String',[get(hEditMessage,'String');{' ';'   Displayed summed static image.'}]);
    figureSize = [560 420];
    hFigStaticImage = figure(...
        'BackingStore','off',...
        'Units','pixels',...
        'DockControls','off',...
        'PaperOrient','portrait',...
        'IntegerHandle','off',...
        'NumberTitle','off',...
        'MenuBar','none',...
        'Name',['XPCS - Movie Maker - Averaged Static Image of Frame ',num2str(ccdmovie.ndata0todo(ccdmovie.batchestodo)),'-',num2str(ccdmovie.ndataendtodo(ccdmovie.batchestodo))],...
        'color',[1 1 0.85],...
        'Toolbar','none',...
        'WindowButtonMotionFcn',@figure_WindowButtonMotionFcn,...
        'Position',[30,50+figureSize(2)+40,figureSize],...
        'Tag','figxpcsmovie_staticimage',...
        'UserData',[]);
    hToolbar = uitoolbar(hFigStaticImage,'Tag','figxpcsmovie_staticimage_Toolbar');
    iconToolbarSave = load('savedoc.mat');
    hToolbarSave = uipushtool(hToolbar,...
        'CDATA',iconToolbarSave.cdata,...
        'Separator','on',...
        'TooltipString','Save Figure',...
        'ClickedCallback',@toolbarSaveFcn,...
        'Tag','toolbarSave');
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
    iconToolbarColormapeditor = load('colormapeditor.mat');
    hToolbarColormapeditor = uipushtool(hToolbar,...
        'CDATA',iconToolbarColormapeditor.cdata,...
        'Separator','on',...
        'TooltipString','Edit Colormap',...
        'ClickedCallback','colormapeditor;',...
        'Tag','toolbarColormapeditor');
    % --- activate figure and plot true image
    figure(hFigStaticImage);
    hImm = imagesc(sumImage,[ccdmovie.contrastMin ccdmovie.contrastMax]);
    colormap(ccdmovie.colormap);
    set(hImm,'Tag','figxpcsmovie_staticimage_image');
    uicontrol('Parent',hFigStaticImage,...
        'Style','Text',...
        'BackgroundColor',[1 1 0.85],...
        'String',' ',...
        'units','normalized',...
        'HorizontalAlignment','left',...
        'position',[0.05 0.01 0.5 0.05],...
        'Tag','mouseposition');
    set(get(hImm,'Parent'),...
        'TickDir','out',...
        'YDir','normal');
end
reset_status(hFigXPCSMovie);
if ccdmovie.playback == 1
    try
        runmovie_str = ['!',ccdmovie.movieFile];
        set(hEditMessage,'String',[get(hEditMessage,'String');{' ';'   Loading the default player to play movie.'}]);
        eval(runmovie_str);
    catch
        set(hEditMessage,'String',[get(hEditMessage,'String');{' ';'   Failed to load the default player to play movie. Please try manually.'}]);
    end
end


%================================================================
%--- PopupmenuBatchnumber callback fcn
%================================================================
function PopupmenuBatchnumberCallbackFcn(hObject,eventdata)

iBatch   = get(gco,'value')                                                                          ;
ccdmovie = getappdata(findall(0,'Tag','xpcsmovie_Fig'),'ccdmovie')                                   ;
% ---
set(findobj(gcf,'Tag','figxpcsmovie_ndata0todo')   ,'string',num2str(ccdmovie.ndata0todo(iBatch)))   ;
set(findobj(gcf,'Tag','figxpcsmovie_ndataendtodo') ,'string',num2str(ccdmovie.ndataendtodo(iBatch))) ;
set(findobj(gcf,'Tag','figxpcsmovie_preset')       ,'string',num2str(ccdmovie.preset(iBatch)))       ;
set(findobj(gcf,'Tag','figxpcsmovie_ndark0todo')   ,'string',num2str(ccdmovie.ndark0todo(iBatch)))   ;
set(findobj(gcf,'Tag','figxpcsmovie_preset')       ,'string',num2str(ccdmovie.preset(iBatch)))       ;
set(findobj(gcf,'Tag','figxpcsmovie_dark_preset')  ,'string',num2str(ccdmovie.dark_preset(iBatch)))  ;
set(findobj(gcf,'Tag','figxpcsmovie_ndarkendtodo') ,'string',num2str(ccdmovie.ndarkendtodo(iBatch))) ;
% ---
set(findall(findall(0,'Tag','xpcsmovie_Fig')       ,'Tag','figxpcsmovie_EditMovieFile')          ...
    ,'String',fullfile(ccdmovie.imgPath,[ccdmovie.name,'Batch_',num2str(iBatch),'.avi'])) ;
% ---
clear ccdmovie iBatch                                            ;


%================================================================
%--- PopupmenuDarkSubtract callback fcn
%================================================================
function PopupmenuDarkSubtractCallbackFcn(hObject,eventdata)

hFigXPCSMovie = findall(0,'Tag','xpcsmovie_Fig')                                    ;
if ( get(gco,'value') == 1 )
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_RadiobuttonLLD1'),'Enable','on')  ;
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_RadiobuttonLLD2'),'Enable','on')  ;
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditLLD2')       ,'Enable','on')  ;
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_RadiobuttonLLD3'),'Enable','on')  ;
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditLLD3')       ,'Enable','on')  ;
else
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_RadiobuttonLLD1'),'Enable','off') ;
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_RadiobuttonLLD2'),'Enable','off') ;
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditLLD2')       ,'Enable','off') ;
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_RadiobuttonLLD3'),'Enable','off') ;
    set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_EditLLD3')       ,'Enable','off') ;
end
clear hFigXPCSMovie                                                                 ;


% =========================================================================
% --- reset figure statuts to ready status
% =========================================================================
function reset_status(hFigXPCSMovie)
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PushbuttonShowImage'),'Enable','on')  ;
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PushbuttonStart')    ,'Enable','on')  ;
set(findall(hFigXPCSMovie,'Tag','figxpcsmovie_PushbuttonStop')     ,'Enable','off') ;

% ---
% EOF
