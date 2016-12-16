function viewanalysis_hdf5(varargin)
% VIEWANALYSIS GUI to display and change analysis settings.
%
% Zhang Jiang & Michael Sprung
% $Revision: 1.0 $  $Date: 2005/01/07 $
% $Revision: 2.0 $  $Date: 2006/10/04 $

% =========================================================================
% --- get ccdimginfo
% =========================================================================
% ccdimginfo = varargin{1};
hFigXPCSMain   = findall(0,'Tag','xpcsmain_Fig');
global ccdimginfo
if ~exist('ccdimginfo','var')
    return;
end
% if isappdata(hFigXPCSMain,'ccdimginfo')
%     ccdimginfo = getappdata(hFigXPCSMain,'ccdimginfo')                     ;
% else
%     return                                                                 ;
% end


% =========================================================================
% --- if viewanalysis fig exists, display it in front; else create it
% =========================================================================
hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig')                     ;
if ~isempty(hFigViewanalysis)  
    figure(hFigViewanalysis)                                               ;
    return                                                                 ;
end


% =========================================================================
% --- figure layout
% =========================================================================
backgroundcolor = [1 1 0.85]                                               ;
facecolor = [1 1 0.9]                                                      ;
textcolor = [0.4 0.3 0]                                                    ; % text color
subtextcolor = 'b'                                                         ; % subtext color
MainPos = get(hFigXPCSMain,'position')                                     ;
figViewanalysisSize = [720 540]                                            ;
hFigViewanalysis = figure('BackingStore','on','Units','pixels'          ...
    ,'DockControls','off','Resize','off','PaperOrient','portrait'       ...
    ,'PaperPositionMode','auto','IntegerHandle','off'                   ...
    ,'NumberTitle','off','MenuBar','none','Toolbar','none'              ...
    ,'CloseRequestFcn',@viewanalysis_CloseRequestFcn                    ...
    ,'Name','XPCS - Analysis Settings','WindowStyle','normal'            ...
    ,'Position',[MainPos(1)+ 150,MainPos(2)+ 60,figViewanalysisSize]    ...
    ,'HandleVisibility','callback','Tag','viewanalysis_Fig','UserData',[]) ;
clear MainPos                                                              ;

hAxes = axes('Parent',hFigViewanalysis,'Units','pixels'                ...
    ,'Position',[0 0 figViewanalysisSize],'Tag','figviewanalysis_Axes')    ;

patch('Parent',hAxes,'XData',[0 1 1 0],'YData',[0 0 1 1]                ...
     ,'FaceColor',backgroundcolor,'EdgeColor',backgroundcolor)             ;
hGroupPatch = hggroup('Parent',hAxes)                                      ;

patch('Parent',hGroupPatch,'XData',[0.02 0.49 0.49 0.02]                ...
     ,'YData',[0.1 0.1 0.925 0.925])                                       ;
patch('Parent',hGroupPatch,'XData',[0.51 0.98 0.98 0.51]                ...
     ,'YData',[0.1 0.1 0.925 0.925])                                       ;
set(get(hGroupPatch,'Children'),'FaceColor',facecolor                   ...
                               ,'EdgeColor',[0.7 0.7 0.7])                 ;

hGroupText      = hggroup('Parent',hAxes)                                  ;
hGroupSubText   = hggroup('Parent',hAxes)                                  ;
hGroupSubText1  = hggroup('Parent',hAxes)                                  ;


% =========================================================================
% --- gui title
% =========================================================================
text('Parent',hAxes,'Position',[.415 .965],'String','Analysis Settings' ...
    ,'FontSize',12,'FontWeight','demi','color',[0.4 0.3 0])                ;


% =========================================================================
% --- layout of selection for analysis type
% =========================================================================
text('Parent',hGroupText,'Position',[0.03 0.9],                         ...
     'String','Select Analysis Type:')                                     ;
 
uicontrol('Parent',hFigViewanalysis,'style','Radiobutton'               ...
         ,'Units','normalized','String','static analysis'               ...
         ,'FontSize',10,'BackgroundColor',facecolor                     ...
         ,'ForegroundColor',subtextcolor,'HorizontalAlignment','left'   ...
         ,'Position',[0.06 0.835 0.3 0.04]                              ...
         ,'Tag','figviewanalysis_RadiobuttonAnalysisTypeS'              ...
         ,'Callback',@figviewanalysis_RadiobuttonAnalysisTypeCallbackFcn)  ;

uicontrol('Parent',hFigViewanalysis,'style','Radiobutton'               ...
         ,'Units','normalized','String','dynamic analysis','FontSize',10 ...
         ,'BackgroundColor',facecolor,'ForegroundColor',subtextcolor    ...
         ,'HorizontalAlignment','left','Position',[0.06 0.79 0.3 0.04]  ...
         ,'Tag','figviewanalysis_RadiobuttonAnalysisTypeD'              ...
         ,'Callback',@figviewanalysis_RadiobuttonAnalysisTypeCallbackFcn)  ;


% =========================================================================
% ---define strings for the partition methods
% =========================================================================
qpartitionMethodString = {                                              ...
    'evenly spaced (Linear)';                                           ...
    'evenly spaced (Log)' ...
    };

phipartitionMethodString = {                                            ...
    'evenly spaced (Linear)';                                           ...
    'evenly spaced (Log)' ...
    };

% =========================================================================
% ---layout partition maps
% =========================================================================
text('Parent',hGroupText,'Position',[0.03 0.77],...
     'String','Partition Map Variable:');
if ccdimginfo.geometry == 0 
    popupmenu_str = {'q','phi','x','y'};
    popupmenu_value = [1 2];
elseif ccdimginfo.geometry == 1
    popupmenu_str = {'q','phi','qz','qx','qy','qr','exitAngle','outOfPlaneAngle','x','y'};
    popupmenu_value = [6 3];
elseif ccdimginfo.geometry == 2
    popupmenu_str = {'x','y'};
    popupmenu_value = [1 2];    
end
text('Parent',hGroupSubText,'Position',[0.06 0.73],'String','Map 1')      ;
uicontrol('Parent',hFigViewanalysis,                                    ...
    'Style','popupmenu',                                                ...
    'Units','normalized',                                               ...
    'backgroundcolor','w',                                              ...
    'Position',[0.1 0.7 0.15 0.04]',                                  ...
    'String',popupmenu_str,                                    ...
    'Value',popupmenu_value(1),                                        ...
    'Tag','figviewanalysis_PopupmenuPartitionMap1',                          ...
    'callback',@figviewanalysis_PopupmenuPartitionMapCallbackFcn)              ;
text('Parent',hGroupSubText,'Position',[0.29 0.73],'String','Map 2')      ;
uicontrol('Parent',hFigViewanalysis,                                    ...
    'Style','popupmenu',                                                ...
    'Units','normalized',                                               ...
    'backgroundcolor','w',                                              ...
    'Position',[0.33 0.7 0.15 0.04]',                                  ...
    'String',popupmenu_str,                                    ...
    'Value',popupmenu_value(2),                                        ...
    'Tag','figviewanalysis_PopupmenuPartitionMap2',                          ...
    'callback',@figviewanalysis_PopupmenuPartitionMapCallbackFcn)              ;

% =========================================================================
% ---layout static q partition
% =========================================================================
text('Parent',hGroupText,'Position',[0.03 0.69],...
     'String','Static Partition Map 1:')                                       ;
text('Parent',hGroupSubText,'Position',[0.06 0.65],'String','method')      ;
uicontrol('Parent',hFigViewanalysis,                                    ...
    'Style','popupmenu',                                                ...
    'Units','normalized',                                               ...
    'backgroundcolor','w',                                              ...
    'Position',[0.2 0.635 0.28 0.04]',                                  ...
    'String',qpartitionMethodString,                                    ...
    'Value',ccdimginfo.partition.smethod(1),                                        ...
    'Tag','figviewanalysis_PopupmenuSqMethod',                          ...
    'callback',@figviewanalysis_PopupmenuSqMethodCallbackFcn)              ;

text('Parent',hGroupSubText,'Position',[0.06 0.61],...
     'String','Number')                                          ;
uicontrol('Parent',hFigViewanalysis,                                    ...
    'Style','Edit',                                                     ...
    'Units','normalized',                                               ...
    'backgroundcolor','w',                                              ...
    'Position',[0.2 0.59 0.19 0.035]',                                  ...
    'HorizontalAlignment','right',                                      ...
    'String',num2str(ccdimginfo.partition.snpt(1)),                                  ...
    'Tag','figviewanalysis_EditSnoq')                                      ;

uicontrol('Parent',hFigViewanalysis,                                    ...
    'style','pushbutton',                                               ...
    'Units','normalized',                                               ...
    'String','Browse ...',                                              ...
    'Position',[0.4 0.59 0.08 0.04],                                    ...
    'Enable','off',                                                     ...
    'Tag','figviewanalysis_PushbuttonSqMethod',                         ...
    'callback',@figviewanalysis_BrowseSQCallbackFcn)                       ;


% =========================================================================
% --- layout static phi partition
% =========================================================================
text('Parent',hGroupText,'Position',[0.03 0.57],...
     'String','Static Partition Map 2:')                                     ;
text('Parent',hGroupSubText,'Position',[0.06 0.53],'String','method')      ;
uicontrol('Parent',hFigViewanalysis,                                    ...
    'Style','popupmenu',                                                ...
    'Units','normalized',                                               ...
    'backgroundcolor','w',                                              ...
    'Position',[0.2 0.515 0.28 0.04]',                                  ...
    'String',phipartitionMethodString,                                  ...
    'Value',ccdimginfo.partition.smethod(2),                                      ...
    'Tag','figviewanalysis_PopupmenuSphiMethod',                        ...
    'callback',@figviewanalysis_PopupmenuSphiMethodCallbackFcn)            ;

text('Parent',hGroupSubText,'Position',[0.06 0.49],...
     'String','Number')                                          ;
uicontrol('Parent',hFigViewanalysis,                                    ...
    'Style','Edit',                                                     ...
    'Units','normalized',                                               ...
    'backgroundcolor','w',                                              ...
    'Position',[0.2 0.47 0.19 0.035]',                                  ...
    'HorizontalAlignment','right',                                      ...
    'String',num2str(ccdimginfo.partition.snpt(2)),                                ...
    'Tag','figviewanalysis_EditSnophi')                                    ;

uicontrol('Parent',hFigViewanalysis,                                    ...
    'style','pushbutton',                                               ...
    'Units','normalized',                                               ...
    'String','Browse ...',                                              ...
    'Position',[0.4 0.47 0.08 0.04],                                    ...
    'Enable','off',                                                     ...
    'Tag','figviewanalysis_PushbuttonSphiMethod',                       ...
    'callback',@figviewanalysis_BrowseSPHICallbackFcn)                     ;


% =========================================================================
% --- layout dynamic q partition
% =========================================================================
text('Parent',hGroupText,'Position',[0.03 0.45],...
     'String','Dynamic Partition Map 1:')                                      ;
text('Parent',hGroupSubText,'Position',[0.06 0.41],'String','method')      ;
uicontrol('Parent',hFigViewanalysis,                                    ...
    'Style','popupmenu',                                                ...
    'Units','normalized',                                               ...
    'backgroundcolor','w',                                              ...
    'Position',[0.2 0.395 0.28 0.04]',                                  ...
    'String',qpartitionMethodString,                                    ...
    'Value',ccdimginfo.partition.dmethod(1),                                        ...
    'Tag','figviewanalysis_PopupmenuDqMethod',                          ...
    'callback',@figviewanalysis_PopupmenuDqMethodCallbackFcn)              ;

text('Parent',hGroupSubText,'Position',[0.06 0.37],                     ...
     'String','Number')                                          ;
uicontrol('Parent',hFigViewanalysis,                                    ...
    'Style','Edit',                                                     ...
    'Units','normalized',                                               ...
    'backgroundcolor','w',                                              ...
    'Position',[0.2 0.35 0.19 0.035]',                                  ...
    'HorizontalAlignment','right',                                      ...
    'String',num2str(ccdimginfo.partition.dnpt(1)),                                  ...
    'Tag','figviewanalysis_EditDnoq')                                      ;

uicontrol('Parent',hFigViewanalysis,                                    ...
    'style','pushbutton',                                               ...
    'Units','normalized',                                               ...
    'String','Browse ...',                                              ...
    'Position',[0.4 0.35 0.08 0.04],                                    ...
    'Enable','off',                                                     ...
    'Tag','figviewanalysis_PushbuttonDqMethod',                         ...
    'callback',@figviewanalysis_BrowseDQCallbackFcn)                       ;


% =========================================================================
% --- layout dynamic phi partition
% =========================================================================
text('Parent',hGroupText,'Position',[0.03 0.33],                        ...
     'String','Dynamic Partition Map 2:')                                    ;
text('Parent',hGroupSubText,'Position',[0.06 0.29],'String','method')      ;
uicontrol('Parent',hFigViewanalysis,                                    ...
    'Style','popupmenu',                                                ...
    'Units','normalized',                                               ...
    'backgroundcolor','w',                                              ...
    'Position',[0.2 0.275 0.28 0.04]',                                  ...
    'String',phipartitionMethodString,                                  ...
    'Value',ccdimginfo.partition.dmethod(2),                                      ...
    'Tag','figviewanalysis_PopupmenuDphiMethod',                        ...
    'callback',@figviewanalysis_PopupmenuDphiMethodCallbackFcn)            ;

text('Parent',hGroupSubText,'Position',[0.06 0.25],...
     'String','Number')                                          ;
uicontrol('Parent',hFigViewanalysis,                                    ...
    'Style','Edit',                                                     ...
    'Units','normalized',                                               ...
    'backgroundcolor','w',                                              ...
    'Position',[0.2 0.23 0.19 0.035]',                                  ...
    'HorizontalAlignment','right',                                      ...
    'String',num2str(ccdimginfo.partition.dnpt(2)),                                ...
    'Tag','figviewanalysis_EditDnophi')                                    ;

uicontrol('Parent',hFigViewanalysis,                                    ...
    'style','pushbutton',                                               ...
    'Units','normalized',                                               ...
    'String','Browse ...',                                              ...
    'Position',[0.4 0.23 0.08 0.04],                                    ...
    'Enable','off',                                                     ...
    'Tag','figviewanalysis_PushbuttonDphiMethod',                       ...
    'callback',@figviewanalysis_BrowseDPHICallbackFcn)                     ;


% =========================================================================
% --- layout for mask selection
% ccdimginfo.maskMethod
% 1. no mask
% 2. new mask
% 3. from existing result file (not working yet)
% =========================================================================
text('Parent',hGroupText,'Position',[0.03 0.21],'String','Mask Settings:') ;
text('Parent',hGroupSubText,'Position',[0.06 0.17],...
    'String','Default: use the full image')  
% hRadiobuttonMask1 = uicontrol('Parent',hFigViewanalysis,                ...
%     'style','Radiobutton',                                              ...
%     'Units','normalized',                                               ...
%     'String','no mask (use all pixles)',                                ...
%     'FontSize',10,                                                      ...
%     'BackgroundColor',facecolor,                                        ...
%     'ForegroundColor',subtextcolor,                                     ...
%     'HorizontalAlignment','left',                                       ...
%     'Position',[0.06 0.23 0.3 0.04],                                    ...
%     'Enable','inactive',...
%     'Tag','figviewanalysis_RadiobuttonMask1',                           ...
%     'Callback',@figviewanalysis_RadiobuttonMaskCallbackFcn)                ;

% hRadiobuttonMask2 = uicontrol('Parent',hFigViewanalysis,                ...
%     'style','Radiobutton',                                              ...
%     'Units','normalized',                                               ...
%     'String','new mask',                                                ...
%     'FontSize',10,                                                      ...
%     'BackgroundColor',facecolor,                                        ...
%     'ForegroundColor',subtextcolor,                                     ...
%     'HorizontalAlignment','left',                                       ...
%     'Enable','inactive',...
%     'Position',[0.06 0.19 0.15 0.04],                                   ...
%     'Tag','figviewanalysis_RadiobuttonMask2',                           ...
%     'Callback',@figviewanalysis_RadiobuttonMaskCallbackFcn)                ;

uicontrol('Parent',hFigViewanalysis,                                    ...
    'style','pushbutton',                                               ...
    'Units','normalized',                                               ...
    'String','Mask Polygon',                                            ...
    'Position',[0.33 0.15 0.15 0.04],                                   ...
    'Enable','on',                                                      ...
    'Tag','figviewanalysis_PushbuttonNewMask',                          ...
    'TooltipString','Show/define mask',                                 ...
    'callback',@figviewanalysis_PushbuttonNewMaskCallbackFcn)             ;

%add new button to show blemish
uicontrol('Parent',hFigViewanalysis,                                    ...
    'style','pushbutton',                                               ...
    'Units','normalized',                                               ...
    'String','Show Blemish',                                            ...
    'Position',[0.33 0.1 0.15 0.04],                                   ...
    'Enable','on',                                                      ...
    'Tag','figviewanalysis_PushbuttonShowBlemishMask',                          ...
    'TooltipString','Show Detector Blemish',                                 ...
    'callback',@figviewanalysis_PushbuttonShowBlemishCallbackFcn)             ;


% hRadiobuttonMask3 = uicontrol('Parent',hFigViewanalysis,                ...
%     'style','Radiobutton',                                              ...
%     'Units','normalized',                                               ...
%     'String','from existing file',                                      ...
%     'FontSize',10,                                                      ...
%     'Enable','inactive',...    
%     'BackgroundColor',facecolor,                                        ...
%     'ForegroundColor',subtextcolor,                                     ...
%     'HorizontalAlignment','left',                                       ...
%     'Position',[0.06 0.15 0.25 0.04],                                   ...
%     'Tag','figviewanalysis_RadiobuttonMask3',                           ...
%     'Callback',@figviewanalysis_RadiobuttonMaskCallbackFcn)                ;

% uicontrol('Parent',hFigViewanalysis,                                    ...
%     'style','pushbutton',                                               ...
%     'Units','normalized',                                               ...
%     'String','Browser ...',                                             ...
%     'Position',[0.33 0.15 0.15 0.04],                                   ...
%     'Tag','figviewanalysis_PushbuttonMaskFile',                         ...
%     'callback',@figviewanalysis_BrowseMaskFileCallbackFcn)                 ;

% 
% uicontrol('Parent',hFigViewanalysis,                                    ...
%     'style','Edit',                                                     ...
%     'Units','normalized',                                               ...
%     'backgroundcolor','w',                                              ...
%     'String',ccdimginfo.mask.maskfile,                                       ...
%     'HorizontalAlignment','left',                                       ...
%     'TooltipString','Browse existing result file containing mask',      ...
%     'Position',[0.1 0.11 0.38 0.035],                                   ...
%     'Tag','figviewanalysis_maskfile')                                      ;

% % --- initialize gui objects of mask settings
% switch ccdimginfo.mask.maskMethod
%     case 1
%         figviewanalysis_RadiobuttonMaskCallbackFcn(hRadiobuttonMask1,[])   ;
%     case 2
%         figviewanalysis_RadiobuttonMaskCallbackFcn(hRadiobuttonMask2,[])   ;
%     case 3
%         figviewanalysis_RadiobuttonMaskCallbackFcn(hRadiobuttonMask3,[])   ;
% end


% =========================================================================
% --- layout for dynamics analysis options
% =========================================================================
text('Parent',hGroupText,'Position',[0.53 0.9],                         ...
     'String','Dynamic Analysis Options:')                                 ;
text('Parent',hGroupSubText,'Position',[0.56 0.86],                     ...
     'String','# of delays per multiple tau level')                        ;
uicontrol('Parent',hFigViewanalysis,                                    ...
    'Style','Edit',                                                     ...
    'Units','normalized',                                               ...
    'backgroundcolor','w',                                              ...
    'Position',[0.87 0.84 0.1 0.035]',                                  ...
    'HorizontalAlignment','right',                                      ...
    'String',num2str(ccdimginfo.xpcs.dpl),                              ...
    'Tag','figviewanalysis_dpl')                                           ;
% =========================================================================
% --- layout for lld
% =========================================================================
text('Parent',hGroupText,'Position',[0.53 0.82],                        ... %%[0.53,.66 before)
     'String','Lower Level Discrimination (LLD):')                         ;
uicontrol('Parent',hFigViewanalysis,                                    ...
    'style','Radiobutton',                                              ...
    'Units','normalized',                                               ...
    'String','no LLD',                                                  ...
    'FontSize',10,                                                      ...
    'BackgroundColor',facecolor,                                        ...
    'ForegroundColor',subtextcolor,                                     ...
    'Position',[0.53 0.75 0.1 0.04],                                   ...
    'Tag','figviewanalysis_RadiobuttonLLD1',                            ...
    'Callback',@figviewanalysis_RadiobuttonLLDCallbackFcn)                 ;

uicontrol('Parent',hFigViewanalysis,                                    ...
    'style','Radiobutton',                                              ...
    'Units','normalized',                                               ...
    'String',' ',                                                       ...
    'FontSize',10,                                                      ...
    'BackgroundColor',facecolor,                                        ...
    'ForegroundColor',subtextcolor,                                     ...
    'HorizontalAlignment','right',                                      ...
    'Position',[0.63 0.75 0.04 0.04],                                  ...
    'Tag','figviewanalysis_RadiobuttonLLD2',                            ...
    'Callback',@figviewanalysis_RadiobuttonLLDCallbackFcn)                 ;
uicontrol('Parent',hFigViewanalysis,                                    ...
    'style','Edit',                                                     ...
    'Units','normalized',                                               ...
    'String','',                                                        ...
    'BackgroundColor','w',                                              ...
    'HorizontalAlignment','right',                                      ...
    'Position',[0.66 0.755 0.05 0.035],                                  ...
    'Tag','figviewanalysis_EditLLD2')                                      ;
text('Parent',hGroupSubText,'Position',[0.72 0.775],'String','X ADU')       ;

uicontrol('Parent',hFigViewanalysis,                                    ...
    'style','Radiobutton',                                              ...
    'Units','normalized',                                               ...
    'String',' ',                                                       ...
    'FontSize',10,                                                      ...
    'BackgroundColor',facecolor,                                        ...
    'ForegroundColor',subtextcolor,                                     ...
    'HorizontalAlignment','right',                                      ...
    'Position',[0.79 0.75 0.04 0.04],                                  ...
    'Tag','figviewanalysis_RadiobuttonLLD3',                            ...
    'Callback',@figviewanalysis_RadiobuttonLLDCallbackFcn)                 ;
uicontrol('Parent',hFigViewanalysis,                                    ...
    'style','Edit',                                                     ...
    'Units','normalized',                                               ...
    'String','',                                                        ...
    'BackgroundColor','w',                                              ...
    'HorizontalAlignment','right',                                      ...
    'Position',[0.82 0.75 0.05 0.035],                                  ...
    'Tag','figviewanalysis_EditLLD3')                                      ;
text('Parent',hGroupSubText,'Position',[0.88 0.775],'String','X dark RMS')  ;

if ( ~isempty(regexp(ccdimginfo.xpcs.compression,'ENABLED', 'once')) ) %%not compressed
    set(findall(0,'Tag','figviewanalysis_RadiobuttonLLD1'),'value',0)      ;
    set(findall(0,'Tag','figviewanalysis_RadiobuttonLLD2'),'value',1)      ;
    set(findall(0,'Tag','figviewanalysis_RadiobuttonLLD3'),'value',0)      ;
    set(findall(0,'Tag','figviewanalysis_EditLLD2'),'Enable','on',...
        'string',num2str(abs(ccdimginfo.xpcs.lld)))              ;
    set(findall(0,'Tag','figviewanalysis_EditLLD3'),'Enable','off')        ;

    if (ccdimginfo.xpcs.rms_multiplier > 0)
        set(findall(0,'Tag','figviewanalysis_RadiobuttonLLD1'),'value',0)      ;
        set(findall(0,'Tag','figviewanalysis_RadiobuttonLLD2'),'value',0)      ;
        set(findall(0,'Tag','figviewanalysis_RadiobuttonLLD3'),'value',1)      ;
        set(findall(0,'Tag','figviewanalysis_EditLLD2'),'Enable','off')        ;
        set(findall(0,'Tag','figviewanalysis_EditLLD3'),'Enable','on',...
            'string',num2str(abs(ccdimginfo.xpcs.rms_multiplier)))         ;
    end

elseif ( isempty(regexp(ccdimginfo.xpcs.compression,'ENABLED', 'once')) )
    set(findall(0,'Tag','figviewanalysis_RadiobuttonLLD1'),'value',1)      ;
    set(findall(0,'Tag','figviewanalysis_RadiobuttonLLD2'),'value',0)      ;
    set(findall(0,'Tag','figviewanalysis_RadiobuttonLLD3'),'value',0)      ;
    set(findall(0,'Tag','figviewanalysis_EditLLD2'),'Enable','off')        ;
    set(findall(0,'Tag','figviewanalysis_EditLLD3'),'Enable','off')        ;
end
% =========================================================================
% --- layout of map sending options
% =========================================================================
text('Parent',hGroupText,'Position',[0.53 0.73],...
     'String','SAVE q/phi digitized pixel map to a .h5 FILE');
text('Parent',hGroupSubText,'Position',[0.53 0.68],...
     'String','Enter q/phi map name:');
uicontrol('Parent',hFigViewanalysis,                                    ...
    'style','Edit',                                                     ...
    'Units','normalized',                                               ...
    'backgroundcolor','w',                                              ...
    'String','username_qmap_sampleid_Sq1',                              ...
    'HorizontalAlignment','left',                                       ...
    'Enable','on',                                                ...
    'Position',[0.55 0.62 0.42 0.035],                                   ...
    'Tag','figviewanalysis_EditMapName')                                      ;
uicontrol('Parent',hFigViewanalysis,...
    'style','pushbutton',...
    'Units','normalized',...
    'String','Save map to .h5 file',...
    'Position',[0.74 0.66 0.23 0.04],...
    'Tag','figviewanalysis_PushbuttonSendMap2Cluster',...
    'TooltipString','Save q/phi map to a .h5 file. This may take a while.',...
    'callback',@figviewanalysis_PushbuttonSendMap2ClusterCbf)             ;
uicontrol('Parent',hFigViewanalysis,...
    'style','pushbutton',...
    'Units','normalized',...
    'String','View map from .h5 file',...
    'Position',[0.74 0.57 0.23 0.04],...
    'Tag','figviewanalysis_PushbuttonViewQPhiMapFromCluster',...
    'callback',@figviewanalysis_PushbuttonViewQPhiMapFromClusterCbf)             ;

% text('Parent',hGroupSubText,'Position',[0.56 0.36],                     ...
%      'String','save results with file name prefix')                        ;
% uicontrol('Parent',hFigViewanalysis,                                    ...
%     'style','Edit',                                                     ...
%     'Units','normalized',                                               ...
%     'backgroundcolor','w',                                              ...
%     'String',ccdimginfo.name,                                           ...
%     'HorizontalAlignment','left',                                       ...
%     'Position',[0.6 0.30 0.36 0.035],                                   ...
%     'Tag','figviewanalysis_prefix')                                        ;
% =========================================================================
% --- layout of status bar
% =========================================================================
text('Parent',hGroupText,'Position',[0.03 0.05],                        ...
     'String','Status: Ready!','Tag','figviewanalysis_TextStatus')         ;

% --- set properties of group text and group sub text
set(get(hGroupText,'Children'),                                         ...
    'Units','normalized',                                               ...
    'HorizontalAlignment','left',                                       ...
    'Color',textcolor)                                                     ;

set(get(hGroupSubText,'Children'),                                      ...
    'Units','normalized',                                               ...
    'HorizontalAlignment','left',                                       ...
    'Color',subtextcolor)                                                  ;

set(get(hGroupSubText1,'Children'),                                     ...
    'Units','normalized',                                               ...
    'HorizontalAlignment','left',                                       ...
    'Color',subtextcolor)                                                  ;


% =========================================================================
% --- layout of close, apply and show pushbuttons
% =========================================================================
hPushbottonClose = uicontrol(hFigViewanalysis,'Style','pushbutton'      ...
    ,'Units','normalized','String','Close','position',[.5 .02 .125 .05] ...
    ,'Tag','viewanalysis_PushbuttonClose'                               ...
    ,'TooltipString','Close window'                                     ...
    ,'callback',@viewanalysis_CloseRequestFcn)                             ;

hPushbottonApply = uicontrol(hFigViewanalysis,'Style','pushbutton'      ...
    ,'Units','normalized','String','Apply','position',[.65 .02 .125 .05]...
    ,'Tag','viewanalysis_PushbuttonApply'                               ...
    ,'TooltipString','Apply changes'                                    ...
    ,'callback',@viewanalysis_ApplyFcn)                                    ;

hPushbottonShowMask = uicontrol(hFigViewanalysis,'Style','pushbutton'   ...
    ,'Units','normalized','String','Show Mask & Partitions'             ...
    ,'position',[.8 .02 .18 .05],'Tag','viewanalysis_PushbuttonShow'    ...
    ,'TooltipString','Apply changes & show image with mask & partitions'...
    ,'callback',@viewanalysis_ShowFcn)                                      ;


% =========================================================================
% --- for dynamics or static analysis initalize the enable properties of
% --- each object in the figure
% =========================================================================
ccdimginfo.analysistype=1;
if ccdimginfo.analysistype == 0                                             % static analysis
    set(findall(0,'Tag','figviewanalysis_RadiobuttonAnalysisTypeS'),    ...
                  'value',0)                                               ;
    set(findall(0,'Tag','figviewanalysis_RadiobuttonAnalysisTypeD'),    ...
                  'value',1)                                               ;
    figviewanalysis_RadiobuttonAnalysisTypeCallbackFcn(                 ...
        findall(hFigViewanalysis, 'Tag',                                ...
               'figviewanalysis_RadiobuttonAnalysisTypeS'),[])             ;
elseif ccdimginfo.analysistype == 1                                         % dynamic analysis
    set(findall(0,'Tag','figviewanalysis_RadiobuttonAnalysisTypeS'),    ...
                  'value',0)                                               ;
    set(findall(0,'Tag','figviewanalysis_RadiobuttonAnalysisTypeD'),    ...
                  'value',1)                                               ;
    figviewanalysis_RadiobuttonAnalysisTypeCallbackFcn(                 ...
        findall(hFigViewanalysis, 'Tag',                                ...
               'figviewanalysis_RadiobuttonAnalysisTypeD'),[])             ;
end

% setappdata(hFigViewanalysis,'maskpoints',ccdimginfo.mask.maskpoints)            ;


%==========================================================================
%==========================================================================
% --- Start to define Callback Functions & Subfunctions
%==========================================================================
%==========================================================================


%==========================================================================
% --- Browsing Callback Functions
%==========================================================================
function figviewanalysis_BrowseSQCallbackFcn(hObject,eventdata)
[filename, filepath]=uigetfile('*.*','Load existing result file for static q partition');
if filename == 0
    clear filename filepath                                                ;
    return
end
file=fullfile(filepath,filename)                                           ;
set(findall(0,'Tag','figviewanalysis_EditSnoq'),'String',file           ...
             ,'HorizontalAlignment','right')                               ;
clear file filename filepath                                               ;

function figviewanalysis_BrowseSPHICallbackFcn(hObject,eventdata)
[filename, filepath]=uigetfile('*.*','Load existing result file for static phi partition');
if filename == 0
    clear filename filepath                                                ;
    return
end
file=fullfile(filepath,filename)                                           ;
set(findall(0,'Tag','figviewanalysis_EditSnophi'),'String',file         ...
             ,'HorizontalAlignment','right')                               ;
clear file filename filepath                                               ;

function figviewanalysis_BrowseDQCallbackFcn(hObject,eventdata)
[filename, filepath]=uigetfile('*.*','Load existing result file for dynamic q partition');
if filename == 0
    clear filename filepath                                                ;
    return
end
file=fullfile(filepath,filename)                                           ;
set(findall(0,'Tag','figviewanalysis_EditDnoq'),'String',file           ...
              ,'HorizontalAlignment','right')                              ;
clear file filename filepath                                               ;

function figviewanalysis_BrowseDPHICallbackFcn(hObject,eventdata)
[filename, filepath]=uigetfile('*.*','Load existing result file for dynamic phi partition');
if filename == 0
    clear filename filepath                                                ;
    return
end
file=fullfile(filepath,filename)                                           ;
set(findall(0,'Tag','figviewanalysis_EditDnophi'),'String',file         ...
                   ,'HorizontalAlignment','right')                         ;
clear file filename filepath                                               ;

function figviewanalysis_BrowseMaskFileCallbackFcn(hObject,eventdata)
[filename, filepath]=uigetfile('*.*','Load existing result file for mask')  ;
if filename == 0
    clear filename filepath                                                ;
    return
end
file=fullfile(filepath,filename)                                           ;
set(findall(0,'Tag','figviewanalysis_maskfile'),'String',file           ...
             ,'HorizontalAlignment','left')                                ;
clear file filename filepath                                               ;

function figviewanalysis_BrowseSavingFolderCallbackFcn(hObject,eventdata)
savepath = uigetdir(get(findall(0,'Tag','figviewanalysis_savepath'),'String')    ...
                                 ,'Select a folder to save XPCS analysis result')   ;
if savepath == 0
    clear savepath                                                         ;
    return
end
set(findall(0,'Tag','figviewanalysis_savepath'),'String',savepath       ...
             ,'HorizontalAlignment','left')                                ;
clear savepath                                                             ;


%==========================================================================
% --- Analysis Type radiobuttons callback fcn
%==========================================================================
function figviewanalysis_RadiobuttonAnalysisTypeCallbackFcn(hObject,eventdata)
hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig');
hRadiobuttonAnalysisTypeS = findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonAnalysisTypeS');
hRadiobuttonAnalysisTypeD = findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonAnalysisTypeD');
hObject = hRadiobuttonAnalysisTypeD; % disable static analysis for cluster only
switch hObject
    case hRadiobuttonAnalysisTypeS                                           % static
        set(hRadiobuttonAnalysisTypeS,'value',1)                           ;
        set(hRadiobuttonAnalysisTypeD,'value',0)                           ;
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuDqMethod')   ,'Enable','off');
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuDphiMethod') ,'Enable','off');
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_EditDnoq')            ,'Enable','off');
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_EditDnophi')          ,'Enable','off');
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PushbuttonDqMethod')  ,'Enable','off');
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PushbuttonDphiMethod'),'Enable','off');
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_dpl')                 ,'Enable','off');
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_slicedpl')            ,'Enable','off');
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuSsn')        ,'Enable','off');
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_ssnmin')              ,'Enable','off');
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuTWOTIME')    ,'Enable','off');
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuSTABILITY')  ,'Enable','off');
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuASCII')      ,'Enable','on') ;
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuFIT1')       ,'Enable','off');
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuFIT2')       ,'Enable','off');
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuPNG')        ,'Enable','on') ;
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuCUSTOMFIT')  ,'Enable','off');
        figviewanalysis_PopupmenuSqMethodCallbackFcn                       ;
        figviewanalysis_PopupmenuSphiMethodCallbackFcn                     ;
    case hRadiobuttonAnalysisTypeD                                           % dynamic
        set(hRadiobuttonAnalysisTypeS,'value',0)                           ;
        set(hRadiobuttonAnalysisTypeD,'value',1)                           ;
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuDqMethod')  ,'Enable','on') ;
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuDphiMethod'),'Enable','on') ;
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_dpl')                ,'Enable','on') ;
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_slicedpl')           ,'Enable','on') ;
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuSsn')       ,'Enable','off');
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_ssnmin')             ,'Enable','off');
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuTWOTIME')   ,'Enable','on') ;
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuSTABILITY') ,'Enable','on') ;
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuASCII')     ,'Enable','on') ;
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuFIT1')      ,'Enable','on') ;
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuFIT2')      ,'Enable','on') ;
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuPNG')       ,'Enable','on') ;
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuCUSTOMFIT') ,'Enable','on') ;
        figviewanalysis_PopupmenuSqMethodCallbackFcn                       ;
        figviewanalysis_PopupmenuSphiMethodCallbackFcn                     ;
        figviewanalysis_PopupmenuDqMethodCallbackFcn                       ;
        figviewanalysis_PopupmenuDphiMethodCallbackFcn                     ;
end


function figviewanalysis_PopupmenuPartitionMapCallbackFcn(hObject,eventdata)
global ccdimginfo
value = get(gcbo,'Value');
str = get(gcbo,'string');
if strcmpi(get(gcbo,'tag'),'figviewanalysis_PopupmenuPartitionMap1')
    ccdimginfo.partition.name{1} = str{value};
else
    ccdimginfo.partition.name{2} = str{value};   
end

%==========================================================================
% --- PopupmenuSqMethod callback fcn
%==========================================================================
function figviewanalysis_PushbuttonNewMaskCallbackFcn(hObject,eventdata)
hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig')                     ;
global ccdimginfo
ccdimginfo = getimgmap(ccdimginfo); %maps structure
if ( ~isfield(ccdimginfo.xpcs,'testimg') ) 
    [~,ccdimginfo]=Compute_IMM_SumImages(ccdimginfo);
end
getimgmask(ccdimginfo.xpcs.testimg,ccdimginfo);


function figviewanalysis_PushbuttonShowBlemishCallbackFcn(hObject,eventdata)
hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig')                     ;
global ccdimginfo
try
    ccdimginfo.mask.blemish_mask=getblemish(ccdimginfo);    
catch
    ccdimginfo.mask.blemish_mask = ccdimginfo.mask.usermask;
end
figure;imagesc(ccdimginfo.mask.blemish_mask);axis xy;colormap('jet');

%==========================================================================
% --- PopupmenuSqMethod callback fcn
%==========================================================================
function figviewanalysis_PopupmenuSqMethodCallbackFcn(hObject,eventdata)
hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig')                     ;
global ccdimginfo
%ccdimginfo = getappdata(findall(0,'Tag','xpcsmain_Fig'),'ccdimginfo')      ;
switch get(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuSqMethod'),'Value')
    case {1,2}
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_EditSnoq'), ...
            'Enable','on','String',num2str(ccdimginfo.partition.snpt(1)),            ...
            'TooltipString','Enter number of partitions')                  ;
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PushbuttonSqMethod'),'Enable','off');
end


%==========================================================================
% --- PopupmenuSphiMethod callback fcn
%==========================================================================
function figviewanalysis_PopupmenuSphiMethodCallbackFcn(hObject,eventdata)
hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig');
global ccdimginfo
%ccdimginfo = getappdata(findall(0,'Tag','xpcsmain_Fig'),'ccdimginfo');
switch get(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuSphiMethod'),'Value')
    case {1,2}
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_EditSnophi'),...
            'Enable','on','String',num2str(ccdimginfo.partition.snpt(2)),...
            'TooltipString','Enter number of partitions');
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PushbuttonSphiMethod'),'Enable','off');
end


%==========================================================================
% --- PopupmenuDqMethod callback fcn
%==========================================================================
function figviewanalysis_PopupmenuDqMethodCallbackFcn(hObject,eventdata)
hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig');
global ccdimginfo
% ccdimginfo = getappdata(findall(0,'Tag','xpcsmain_Fig'),'ccdimginfo');
switch get(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuDqMethod'),'Value')
    case {1,2}
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_EditDnoq'),...
            'Enable','on','String',num2str(ccdimginfo.partition.dnpt(1)),...
            'TooltipString','Enter number of partitions');
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PushbuttonDqMethod'),'Enable','off');
end


%==========================================================================
% --- PopupmenuDphiMethod callback fcn
%==========================================================================
function figviewanalysis_PopupmenuDphiMethodCallbackFcn(hObject,eventdata)
hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig');
global ccdimginfo
% ccdimginfo = getappdata(findall(0,'Tag','xpcsmain_Fig'),'ccdimginfo');
switch get(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuDphiMethod'),'Value')
    case {1,2}
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_EditDnophi'),...
            'Enable','on','String',num2str(ccdimginfo.partition.dnpt(2)),...
            'TooltipString','Enter number of partitions');
        set(findall(hFigViewanalysis,'Tag','figviewanalysis_PushbuttonDphiMethod'),'Enable','off');
end


%==========================================================================
% --- Radiobutton mask callback fcn
%==========================================================================
% function figviewanalysis_RadiobuttonMaskCallbackFcn(hObject,eventdata)
% hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig')                     ;
% switch hObject
%     case findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonMask1')
%         set(findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonMask1')  ,'value',1)     ;
%         set(findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonMask2')  ,'value',0)     ;
%         set(findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonMask3')  ,'value',0)     ;
%         set(findall(hFigViewanalysis,'Tag','figviewanalysis_PushbuttonNewMask') ,'enable','off');
%         set(findall(hFigViewanalysis,'Tag','figviewanalysis_PushbuttonMaskFile'),'enable','off');
%         set(findall(hFigViewanalysis,'Tag','figviewanalysis_maskfile')          ,'enable','off');
%     case findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonMask2')
%         set(findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonMask1')  ,'value',0)     ;
%         set(findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonMask2')  ,'value',1)     ;
%         set(findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonMask3')  ,'value',0)     ;
%         set(findall(hFigViewanalysis,'Tag','figviewanalysis_PushbuttonNewMask') ,'enable','on') ;
%         set(findall(hFigViewanalysis,'Tag','figviewanalysis_PushbuttonMaskFile'),'enable','off');
%         set(findall(hFigViewanalysis,'Tag','figviewanalysis_maskfile')          ,'enable','off');        
%     case findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonMask3')
%         set(findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonMask1')  ,'value',0)     ;
%         set(findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonMask2')  ,'value',0)     ;
%         set(findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonMask3')  ,'value',1)     ;
%         set(findall(hFigViewanalysis,'Tag','figviewanalysis_PushbuttonNewMask') ,'enable','off');
%         set(findall(hFigViewanalysis,'Tag','figviewanalysis_PushbuttonMaskFile'),'enable','on') ;
%         set(findall(hFigViewanalysis,'Tag','figviewanalysis_maskfile')          ,'enable','on') ;        
% end 


%==========================================================================
%--- LLD radiobuttons callback fcn
%==========================================================================
function figviewanalysis_RadiobuttonLLDCallbackFcn(hObject,eventdata)
hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig')                              ;
hRadiobuttonLLD1 = findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonLLD1');
hRadiobuttonLLD2 = findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonLLD2');
hRadiobuttonLLD3 = findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonLLD3');
hEditLLD2        = findall(hFigViewanalysis,'Tag','figviewanalysis_EditLLD2')       ;
hEditLLD3        = findall(hFigViewanalysis,'Tag','figviewanalysis_EditLLD3')       ;
switch hObject
    case hRadiobuttonLLD1
        set(hRadiobuttonLLD1,'value',1)                                    ;
        set(hRadiobuttonLLD2,'value',0)                                    ;
        set(hRadiobuttonLLD3,'value',0)                                    ;
        set(hEditLLD2,'Enable','off')                                      ;
        set(hEditLLD3,'Enable','off')                                      ;
    case hRadiobuttonLLD2
        set(hRadiobuttonLLD1,'value',0)                                    ;
        set(hRadiobuttonLLD2,'value',1)                                    ;
        set(hRadiobuttonLLD3,'value',0)                                    ;
        set(hEditLLD2,'Enable','on')                                       ;
        set(hEditLLD3,'Enable','off')                                      ;
    case hRadiobuttonLLD3
        set(hRadiobuttonLLD1,'value',0)                                    ;
        set(hRadiobuttonLLD2,'value',0)                                    ;
        set(hRadiobuttonLLD3,'value',1)                                    ;
        set(hEditLLD2,'Enable','off')                                      ;
        set(hEditLLD3,'Enable','on')                                       ;
end


%==========================================================================
%--- Popupmenu SSN callback fcn
%==========================================================================
% function figviewanalysis_PopupmenuSsnCallbackFcn(hObject,eventdata)
% hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig')                           ;
% hPopupmenuSsn = findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuSsn')   ;
% if ( get(hPopupmenuSsn,'value')==1 )
%     set(findall(hFigViewanalysis,'Tag','figviewanalysis_ssnmin'),'Enable','off') ;
% else
%     set(findall(hFigViewanalysis,'Tag','figviewanalysis_ssnmin'),'Enable','off') ;
% end


function figviewanalysis_PushbuttonSendMap2ClusterCbf(~,~)
global ccdimginfo;
hEdit = findall(gcbf,'tag','figviewanalysis_EditMapName');
mapname = get(hEdit,'string');
if isempty(mapname)
  errordlg('Invalid map name.','Error Dialog','model');
  return;
end

ccdimginfo.map_filename=strcat(mapname,'.h5');

try
    hwarndlg = warndlg('Please wait while the map is being SAVED to a .h5 file ...','Saving Map to File Warning','modal');    
    pause(0.01);
    viewanalysis_ApplyFcn;%%push apply in case the user had not done this as else wrong qmap will be sent
    ccdimginfo.map_local_location = '/home/8-id-i/partitionMapLibrary/2016-3/';
    save_sd_maps(ccdimginfo);
catch
    delete(hwarndlg);
    errordlg('Failed Saving the map.','Error Dialog','modal');    
    return;
end
delete(hwarndlg);

function figviewanalysis_PushbuttonViewQPhiMapFromClusterCbf(~,~)
hEdit = findall(gcbf,'tag','figviewanalysis_EditMapName');
mapname = get(hEdit,'string');
try
    preview_qphimap_cluster(mapname);
catch
    errordlg('Map does not exist.','Error Dialog','modal');    
    return;
end

%==========================================================================
%--- Close figure close callback fcn
%==========================================================================
function viewanalysis_CloseRequestFcn(hObject,eventdata)
hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig')                     ;
% --- call viewanalysis_ApplyFcn
viewanalysis_ApplyFcn                                                      ;
% --- close figure windows
delete(findall(0,'Tag','mask_Fig'))                                        ;
delete(findall(0,'Tag','showmaskpartition_Fig'))                           ;
delete(hFigViewanalysis)                                                   ;


%==========================================================================
% --- Apply pushbutton callback fcn (save information, do mapping)
%==========================================================================
function viewanalysis_ApplyFcn(hObject,eventdata)
hFigXPCSMain     = findall(0,'Tag','xpcsmain_Fig')                         ;
hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig')                     ;
global ccdimginfo
% ccdimginfo       = getappdata(hFigXPCSMain,'ccdimginfo')                   ;
% =========================================================================
% --- change status bar and disable pushbuttons
% =========================================================================
hEditStatus  = findall(hFigViewanalysis,'Tag','figviewanalysis_TextStatus');
originalColor = get(hEditStatus,'Color')                                   ;
originalText  = get(hEditStatus,'String')                                  ;
set(hEditStatus,'String','Status: Applying changes and masking image ...','color','r')    ;
set(findall(hFigViewanalysis,'Tag','viewanalysis_PushbuttonClose')       ,'Enable','off') ;
set(findall(hFigViewanalysis,'Tag','viewanalysis_PushbuttonApply')       ,'Enable','off') ;
set(findall(hFigViewanalysis,'Tag','viewanalysis_PushbuttonShow')        ,'Enable','off') ;
pause(0.001)                                                               ;


% =========================================================================
% --- get analysis type
% =========================================================================
ccdimginfo.analysistype = 1                                                ; % assume dynamic analysis
if ( get(findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonAnalysisTypeS'),'value') == 1 )
    ccdimginfo.analysistype = 0                                            ; % if needed change to static analysis
end


% =========================================================================
% --- get static q partition information
% =========================================================================
ccdimginfo.partition.smethod(1) = get(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuSqMethod'),'Value')    ;
switch ccdimginfo.partition.smethod(1)
    case {1,2}      % get # of partitions
        ccdimginfo.partition.snpt(1)      = str2double(get(findall(hFigViewanalysis,'Tag','figviewanalysis_EditSnoq'),'String'))  ;
end


% =========================================================================
% --- get static phi partition information
% =========================================================================
ccdimginfo.partition.smethod(2) = get(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuSphiMethod'),'Value')          ;
switch ccdimginfo.partition.smethod(2)
    case {1,2}      % get # of partitions
        ccdimginfo.partition.snpt(2)   = str2double(get(findall(hFigViewanalysis,'Tag','figviewanalysis_EditSnophi'),'String'));
end


% =========================================================================
% --- get dynamic partition information if necessary
% =========================================================================
if ( ccdimginfo.analysistype == 1 )
    % --- get dynamic q partition information
    ccdimginfo.partition.dmethod(1) = get(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuDqMethod'),'Value')               ;
    switch ccdimginfo.partition.dmethod(1)
        case {1,2}      % get # of partitions
            ccdimginfo.partition.dnpt(1)      = str2double(get(findall(hFigViewanalysis,'Tag','figviewanalysis_EditDnoq'),'String'))  ;
    end
    % --- get dynamic phi partition information
    ccdimginfo.partition.dmethod(2) = get(findall(hFigViewanalysis,'Tag','figviewanalysis_PopupmenuDphiMethod'),'Value')              ;
    switch ccdimginfo.partition.dmethod(2)
        case {1,2}      % get # of partitions
            ccdimginfo.partition.dnpt(2)      = str2double(get(findall(hFigViewanalysis,'Tag','figviewanalysis_EditDnophi'),'String')) ;
    end
end




% =========================================================================
% --- get mask information
% =========================================================================



% xpixels = ccdimginfo.bin.detector.x_end-ccdimginfo.bin.detector.x_begin+1                          ;
% if ( ccdimginfo.detector.kinetics.mode == 1 )
%     ypixels = ccdimginfo.detector.kinetics.window_size                                        ;
% else
%     ypixels = ccdimginfo.bin.detector.y_end-ccdimginfo.bin.detector.y_begin+1                      ;
% end
% switch 1
%     case get(findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonMask1'),'Value')    % for no mask
%         ccdimginfo.mask.maskMethod = 1;
%         ccdimginfo.mask.maskpoints = {[1       1;
%                                  xpixels  1;
%                                  xpixels  ypixels;
%                                  1        ypixels]};
%         % --- define mask roi as corner points of the whole slice/image roi
%         if ccdimginfo.detector.kinetics.mode == 1
%             ccdimginfo.mask.maskroi = [1              1                    ; ...
%                                   xpixels        ccdimginfo.detector.kinetics.window_size ]   ;
%         else
%             ccdimginfo.mask.maskroi = [1              1                 ;    ...
%                                   xpixels        ypixels            ]      ;
%         end
%         ccdimginfo.mask.maskfile   = ''                                         ;
%         setappdata(hFigViewanalysis,'maskpoints',ccdimginfo.mask.maskpoints)    ;
%         
%     case get(findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonMask2'),'Value')    % for new mask
%         ccdimginfo.mask.maskMethod = 2                                          ;
%         maskpoints = getappdata(hFigViewanalysis,'maskpoints')             ;
%         if ( ~isempty(maskpoints) )
%             ccdimginfo.mask.maskpoints = maskpoints                             ;
%             tmp_maskpoints = cell2mat(ccdimginfo.mask.maskpoints);
%             ccdimginfo.maskroi    =                                     ...
%                 [min(tmp_maskpoints(:,1)) min(tmp_maskpoints(:,2)); ...
%                  max(tmp_maskpoints(:,1)) max(tmp_maskpoints(:,2))]    ;
%         else
%             hMSGBox = msgbox('Invalid polygon --> use whole image!'     ...
%                             ,'Mask Warning Message','warn','modal')        ;
%             set(hMSGBox,'color',[1 1 0.85])                                ;
%             uiwait(hMSGBox)                                                ;
%             pause(0.010)                                                   ;
%             ccdimginfo.maskpoints = {[1       1;...
%                                      xpixels  1;...
%                                      xpixels  ypixels;...
%                                      1        ypixels]};
%             % --- define mask roi as corner points of the slice/image roi
%             if ccdimginfo.detector.kinetics.mode == 1
%                 ccdimginfo.maskroi = [1          1                    ; ...
%                                       xpixels    ccdimginfo.detector.kinetics.window_size ]   ;
%             else
%                 ccdimginfo.maskroi = [1          1                 ;    ...
%                                       xpixels    ypixels            ]      ;
%             end
%         end
%         ccdimginfo.maskfile   = ''                                         ;
%         setappdata(hFigViewanalysis,'maskpoints',ccdimginfo.maskpoints)    ;
% 
%  
%     case get(findall(hFigViewanalysis,'Tag','figviewanalysis_RadiobuttonMask3'),'Value')        % for existing mask
%         % --- save changes before calling 'custommaskload'
%        % setappdata(hFigXPCSMain,'ccdimginfo',ccdimginfo)                   ; % save all current changes
%         % --- call 'custommaskload'
%         maskfile = get(findall(hFigViewanalysis,'Tag','figviewanalysis_maskfile'),'String')        ;
%         custommaskload(maskfile)                                           ; % this updates the main application data
%         % --- reload updated 'ccdimginfo' structure
%         %ccdimginfo = getappdata(hFigXPCSMain,'ccdimginfo')                 ; % get the updated application data
%         maskpoints = ccdimginfo.maskpoints                                 ;
%         setappdata(hFigViewanalysis,'maskpoints',maskpoints)               ;
%         clear maskfile maskpoints                                          ;
% 
% end

% 
% % =========================================================================
% % --- calculate the logical (1/0) usermask
% % =========================================================================
% if isappdata(hFigViewanalysis,'maskflag')
%     maskflag = getappdata(hFigViewanalysis,'maskflag');
%     if ~isequal(maskflag,ccdimginfo.maskpoints)
%         ccdimginfo.usermask = zeros(ypixels,xpixels);
%         for ii=1:length(ccdimginfo.maskpoints)
%             ccdimginfo.usermask = ccdimginfo.usermask + ...
%                 outsidepolygonmask(ones(ypixels,xpixels),...
%                 ccdimginfo.maskpoints{ii}(:,1),ccdimginfo.maskpoints{ii}(:,2));
%         end
%         ccdimginfo.usermask(find(ccdimginfo.usermask))=1;
%     end
% else
%         ccdimginfo.usermask = zeros(ypixels,xpixels);
%         for ii=1:length(ccdimginfo.maskpoints)
%            ccdimginfo.usermask = ccdimginfo.usermask + ...
%                 outsidepolygonmask(ones(ypixels,xpixels),...
%                 ccdimginfo.maskpoints{ii}(:,1),ccdimginfo.maskpoints{ii}(:,2));
%         end
%         ccdimginfo.usermask(find(ccdimginfo.usermask))=1;
% end
% maskflag = ccdimginfo.maskpoints;
% setappdata(hFigViewanalysis,'maskflag',maskflag);

% --- update map and partition
ccdimginfo = getimgmap(ccdimginfo);
ccdimginfo = getimgpartition(ccdimginfo); %partition structure
ccdimginfo = getimgpartitionindex(ccdimginfo);

% =========================================================================
% --- get dynamic analysis settings
% =========================================================================
if ccdimginfo.analysistype == 1
    if ~isnan(str2double(get(findall(hFigViewanalysis,'Tag',            ...
                            'figviewanalysis_dpl'),'string')))
        ccdimginfo.xpcs.dpl = str2double(get(findall(hFigViewanalysis,'Tag', ...
                                       'figviewanalysis_dpl'),'string'))   ;
    end
%     if ~isnan(str2double(get(findall(hFigViewanalysis,'Tag',            ...
%                                     'figviewanalysis_slicedpl'),'string')));
%         ccdimginfo.slicedpl = str2double(get(findall(hFigViewanalysis,  ...
%                               'Tag','figviewanalysis_slicedpl'),'string')) ;
%     end
%     if ( get(findall(hFigViewanalysis,'Tag',                            ...
%             'figviewanalysis_PopupmenuSsn'),'Value') == 1 )
%         ccdimginfo.ssn = 1                                                 ;
%         if ~isnan(str2double(get(findall(hFigViewanalysis,'Tag',...
%                                 'figviewanalysis_ssnmin'),'string')))
%             ccdimginfo.ssnmin = str2double(get(findall(hFigViewanalysis,...
%                                 'Tag','figviewanalysis_ssnmin'),'string')) ;
%         end
%     elseif ( get(findall(hFigViewanalysis,'Tag',                        ...
%                 'figviewanalysis_PopupmenuSsn'),'Value') == 2 )
%         ccdimginfo.ssn = 0                                                 ;
%     end
end


% =========================================================================
% --- get lld
% =========================================================================
switch 1
    case get(findall(hFigViewanalysis,'Tag',                            ...
            'figviewanalysis_RadiobuttonLLD1'),'value')
        ccdimginfo.xpcs.lld = 0                                                 ;
        
    case get(findall(hFigViewanalysis,'Tag',                            ...
            'figviewanalysis_RadiobuttonLLD2'),'value')
        if ~isnan(str2double(get(findall(hFigViewanalysis,'Tag',        ...
                            'figviewanalysis_EditLLD2'),'string')))
            ccdimginfo.xpcs.lld = -abs(str2double(get(findall(               ...
                                  hFigViewanalysis,'Tag',               ...
                                  'figviewanalysis_EditLLD2'),'string')))  ;
        end
        
    case get(findall(hFigViewanalysis,'Tag',                            ...
            'figviewanalysis_RadiobuttonLLD3'),'value')
        if ~isnan(str2double(get(findall(hFigViewanalysis,'Tag',        ...
                                'figviewanalysis_EditLLD3'),'string')))
            ccdimginfo.xpcs.lld = abs(str2double(get(findall(                ...
                                 hFigViewanalysis,'Tag',                ...
                                 'figviewanalysis_EditLLD3'),'string')))   ;
        end
end


% =========================================================================
% --- get saving folder information
% =========================================================================
% % savepath = get(findall(hFigViewanalysis,'Tag',                          ...
% %               'figviewanalysis_savepath'),'String')                        ;
% % if isdir(savepath)
% %     ccdimginfo.savepath = savepath                                         ; % directory exists already
% % else
% %     hEditStatus = findall(hFigViewanalysis,'Tag',                       ...
% %                          'figviewanalysis_TextStatus')                     ;
% %     str1 = 'Status: Try to create saving directory ...'                    ;
% %     set(hEditStatus,'String',str1,'color','r')                             ;
% %     pause(0.01)                                                            ;
% %     % ---
% %     [success,message,messageID] = mkdir(savepath)                          ;
% %     % ---
% %     if ( success == 1 )
% %         ccdimginfo.savepath = savepath                                     ; % the saving directory was successfully created
% %     else
% %         hEditStatus = findall(hFigViewanalysis,'Tag',                   ...
% %                              'figviewanalysis_TextStatus')                 ;
% %         str1 = {'Status: Failed to create saving directory ...';        ...
% %                 '        Try to save in Matlab XPCSGUI folder!'}           ;
% %         set(hEditStatus,'String',str1,'color','r')                         ;
% %         pause(0.01)                                                        ;
% %         % ---
% %         savepath = fullfile(pwd,'result')                                  ; % try to create a subdirectory in the Matlab XPCSGUI folder
% %         % ---
% %         [success,message,messageID] = mkdir(savepath)                      ;
% %         % ---
% %         if ( success == 1 )
% %             ccdimginfo.savepath = savepath                                 ; % the 'emergency' saving directory was successfully created
% %         else
% %             hEditStatus = findall(hFigViewanalysis,'Tag',               ...
% %                                  'figviewanalysis_TextStatus')             ;
% %             str1 = {'Status: Failed to create saving directory !!!'}       ;
% %             set(hEditStatus,'String',str1,'color','r')                     ;
% %             pause(0.01)                                                    ;
% %             % ---
% %             ccdimginfo.savepath = pwd                                      ; % set the saving directory to the XPCSGUI folder
% %             set(findall(hFigViewanalysis,'Tag',                         ...
% %                 'figviewanalysis_savepath'),'String',ccdimginfo.savepath)  ;
% %             % ---
% %             uiwait(msgbox('Failed in creating new directory ...',       ...
% %                           'Error Message','error','modal'))                ;
% %         end        
% %     end
% % end


% =========================================================================
% --- get saving prefix information
% =========================================================================
ccdimginfo.name = get(findall(hFigViewanalysis,'Tag',                   ...
                             'figviewanalysis_prefix'),'string')           ;
                        
% =========================================================================
% --- save ccdimginfo to main figure
% =========================================================================
Modifyhdf5MetaData(ccdimginfo);
%setappdata(hFigXPCSMain,'ccdimginfo',ccdimginfo)                           ;

% --- set status bar back to Ready
set(findall(hFigViewanalysis,'Tag',                                     ...
           'viewanalysis_PushbuttonClose'),'Enable','on')                  ;
set(findall(hFigViewanalysis,'Tag',                                     ...
           'viewanalysis_PushbuttonApply'),'Enable','on')                  ;
set(findall(hFigViewanalysis,'Tag',                                     ...
           'viewanalysis_PushbuttonShow'),'Enable','on')                   ;
set(hEditStatus,'String',originalText,'color',originalColor)               ;

%%%added for hadoop, not sure where this should go: Suresh (Dec 2012)
% hPushbuttonRun       = findall(hFigXPCSMain,'Tag','xpcsmain_PushbuttonRun')       ;
% set(hPushbuttonRun      ,'Enable','on')                                    ;





% =========================================================================
% --- Show Mask & Partitions pushbutton callback fcn
% =========================================================================
function viewanalysis_ShowFcn(hObject,eventdata)
hFigXPCSMain = findall(0,'Tag','xpcsmain_Fig')                             ;
hFigViewanalysis = findall(0,'Tag','viewanalysis_Fig')                     ;
% --- call viewanalysis_ApplyFcn to save information
viewanalysis_ApplyFcn                                                      ;
% --- change status bar and disable pushbuttons
hEditStatus   = findall(hFigViewanalysis,'Tag',                         ...
                       'figviewanalysis_TextStatus')                       ;
originalColor = get(hEditStatus,'Color')                                   ;
originalText  = get(hEditStatus,'String')                                  ;
set(hEditStatus,'String',                                               ...
   'Status: Loading, mapping image and drawing contours ...','color','r')  ;
set(findall(hFigViewanalysis,'Tag',                                     ...
   'viewanalysis_PushbuttonClose'),'Enable','off')                         ;
set(findall(hFigViewanalysis,'Tag',                                     ...
   'viewanalysis_PushbuttonApply'),'Enable','off')                         ;
set(findall(hFigViewanalysis,'Tag',                                     ...
   'viewanalysis_PushbuttonShow'),'Enable','off')                          ;
pause(0)                                                                   ;
% =========================================================================
% --- call showmaskpartition function to show
% =========================================================================
global ccdimginfo
if ( ~isfield(ccdimginfo.xpcs,'testimg') ) 
    [~,ccdimginfo] = Compute_IMM_SumImages(ccdimginfo);     % update testimage
end
showmaskpartition;
% =========================================================================
% --- set status bar back to Ready
% =========================================================================
set(findall(hFigViewanalysis,'Tag',                                     ...
           'viewanalysis_PushbuttonClose'),'Enable','on')                  ;
set(findall(hFigViewanalysis,'Tag',                                     ...
           'viewanalysis_PushbuttonApply'),'Enable','on')                  ;
set(findall(hFigViewanalysis,'Tag',                                     ...
           'viewanalysis_PushbuttonShow'),'Enable','on')                   ;
set(hEditStatus,'String',originalText,'color',originalColor)               ;


% ---
% EOF
