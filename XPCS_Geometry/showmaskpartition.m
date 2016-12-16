function showmaskpartition(varargin)
% --- SHOWMASKPARTITION Called by viewanalysis gui only to show user defined
% --- mask and  partition.
% ---
% --- Zhang Jiang & Michael Sprung
% --- $Revision: 1.0 $  $Date: 2005/01/12 $
% --- $Revision: 2.0 $  $Date: 2006/09/29 $
% --- $Revision: 2.1 $  $Date: 2009/09/09 $ by ZJ
%       1) New algorithm by interpolation to speed up contour plot. 
%       2) Contour plots are in thin lines. 
%       3) Remove upper level discrimination for image display.
%       4) Correct the display of the q values.   

% =========================================================================
% ---get application data
% =========================================================================
global ccdimginfo
% =========================================================================
% --- load image if ccdimginfo.xpcs.testimg does not exist
% =========================================================================
if ( ~isfield(ccdimginfo.xpcs,'testimg') )   
    [~,ccdimginfo] = Compute_IMM_SumImages(ccdimginfo);     % update testimage        
end
% =========================================================================
% --- create figure layout for 'showmaskpartition_Fig'
% =========================================================================
delete(findall(0,'Tag','showmaskpartition_Fig'))                           ;
figureSize = [640 480]                                                     ;
% ---
hFigShowmaskpartition = figure('BackingStore','on','Units','pixels'     ...
    ,'DockControls','off','PaperOrient','portrait','IntegerHandle','off'...
    ,'NumberTitle','off','MenuBar','none'                               ...
    ,'Name','XPCS - Image with Mask & Partition'                        ...
    ,'WindowButtonMotionFcn',@showmaskpartition_WindowButtonMotionFcn   ...
    ,'color',[1 1 0.85],'Toolbar','none','Position',[300,225,figureSize]...
    ,'Tag','showmaskpartition_Fig','UserData',[])                          ;
% ---
hToolbar = uitoolbar(hFigShowmaskpartition,'Tag',...
                    'showmaskpartition_Toolbar')                           ;
iconToolbarZoom = load('zoom.mat')                                         ;
hToolbarZoom = uitoggletool(hToolbar,'CDATA',iconToolbarZoom.zoomCData  ...
                           ,'Separator','on','TooltipString','Zoom'     ...
                           ,'State','off','Tag','toolbarZoom'           ...
                           ,'ClickedCallback',@toolbarZoomFcn)             ;
iconToolbarPan = load('pan.mat')                                           ;
hToolbarPan = uitoggletool(hToolbar,'CDATA',iconToolbarPan.cdata        ...
                          ,'TooltipString','Pan','Tag','toolbarPan'     ...
                          ,'ClickedCallback',@toolbarPanFcn)               ;
iconToolbarColormapeditor = load('colormapeditor.mat')                     ;
hToolbarColormapeditor = uipushtool(hToolbar                            ...
    ,'CDATA',iconToolbarColormapeditor.cdata                            ...
    ,'TooltipString','Edit Colormap','ClickedCallback','colormapeditor;'...
    ,'Tag','toolbarColormapeditor')                                        ;
% =========================================================================
% --- reset toolbar controls of image figure
% =========================================================================
resetToolbar(hFigShowmaskpartition)                                        ;
% =========================================================================
% --- define some abbreviations
% =========================================================================
[y,x] = find(ccdimginfo.mask.usermask);
R1 = min(y);
R2 = max(y);
C1 = min(x);
C2 = max(x);
% =========================================================================
% --- create displayImage
% =========================================================================
displayImage = ccdimginfo.xpcs.testimg .* cast(ccdimginfo.mask.usermask,'like',ccdimginfo.xpcs.testimg);
figure(hFigShowmaskpartition);

try
    data_std = std(displayImage(:));
    data_mean = mean(displayImage(:));
    hImm = imagesc(displayImage,[max(data_mean-5*data_std,0),data_mean+5*data_std]);   
catch
    hImm = imagesc(displayImage,[0,100]); %%some constant value so it does not crash
end
colormap('jet');

if (   ccdimginfo.geometry == 0 &&                                      ...
        max(size(displayImage,1),size(displayImage,2))                   ...
        / min(size(displayImage,1),size(displayImage,2)) <= 4/3 )
    axis image                                                             ;
end

set(hImm,'Tag','showmaskpartition_fig_image');

uicontrol(...
    'Parent',hFigShowmaskpartition,...
    'Style','Text',...
    'BackgroundColor',[1 1 0.85],...
    'units','normalized',...
    'String',' ',...
    'HorizontalAlignment','left',...
    'FontSize',8,...
    'position',[0.05 0.005 0.9 0.05],...
    'Tag','mouseposition');
set(get(hImm,'Parent'),'YDir','normal')                                    ;
% set(gca,'xlim',[C1,C2]);
% set(gca,'ylim',[R1,R2]);

nR = R2-R1+1;
nC = C2-C1+1;
%maxNP = 100000; %takes a long time to draw
maxNP = double(ccdimginfo.detector.rows*ccdimginfo.detector.cols/4);
if nR*nC >= maxNP
    tmp_nR = nR; tmp_nC = nC;
    nR = round(maxNP/tmp_nC);
    nC = round(maxNP/tmp_nR);
end
RR = round(linspace(R1,R2,nR));
CC = round(linspace(C1,C2,nC));
hold on;
map1 = ccdimginfo.maps.(ccdimginfo.partition.name{1});
map2 = ccdimginfo.maps.(ccdimginfo.partition.name{2});
[C21,h21] = contour(map1(RR,CC),ccdimginfo.partition.sspan{1},  'r-');
[C22,h22] = contour(map2(RR,CC),ccdimginfo.partition.sspan{2},'r-');
%[C21,h21] = contour(ccdimginfo.qmap(RR,CC), ccdimginfo.sqspan,  'r-');
%[C22,h22] = contour(ccdimginfo.phimap(RR,CC),ccdimginfo.sphispan,'r-');
hold off;

if verLessThan('Matlab','8.4')
    a21=get(h21,'children');
    a22=get(h22,'children');
    xdata = get(a21,'XData');
    ydata = get(a21,'YData');
    if iscell(xdata)==0, xdata = {xdata}; end
    if iscell(ydata)==0, ydata = {ydata}; end
    
    for ii=1:length(a21)
        set(a21(ii),'XData',interp1(1:nC,CC,xdata{ii}));
        set(a21(ii),'YData',interp1(1:nR,RR,ydata{ii}));
    end
    xdata = get(a22,'XData');
    ydata = get(a22,'YData');
    if iscell(xdata)==0, xdata = {xdata}; end
    if iscell(ydata)==0, ydata = {ydata}; end
    
    for ii=1:length(a22)
        set(a22(ii),'XData',interp1(1:nC,CC,xdata{ii}));
        set(a22(ii),'YData',interp1(1:nR,RR,ydata{ii}));
    end
else
    set(h21,'XData',interp1(1:nC,CC,get(h21,'XData')));
    set(h21,'YData',interp1(1:nR,RR,get(h21,'YData')));   
    set(h22,'XData',interp1(1:nC,CC,get(h22,'XData')));
    set(h22,'YData',interp1(1:nR,RR,get(h22,'YData')));
end

if ccdimginfo.analysistype == 1
    hold on;
    [C21,h21] = contour(map1(RR,CC),ccdimginfo.partition.dspan{1},'g-');
    [C22,h22] = contour(map2(RR,CC),ccdimginfo.partition.dspan{2},'g-');
    hold off;
    if verLessThan('Matlab','8.4')
        
        a21=get(h21,'children');
        a22=get(h22,'children');
        xdata = get(a21,'XData');
        ydata = get(a21,'YData');
        if iscell(xdata)==0, xdata = {xdata}; end
        if iscell(ydata)==0, ydata = {ydata}; end
        for ii=1:length(a21)
            set(a21(ii),'XData',interp1(1:nC,CC,xdata{ii}));
            set(a21(ii),'YData',interp1(1:nR,RR,ydata{ii}));
        end
        
        xdata = get(a22,'XData');
        ydata = get(a22,'YData');
        if iscell(xdata)==0, xdata = {xdata}; end
        if iscell(ydata)==0, ydata = {ydata}; end
        for ii=1:length(a22)
            set(a22(ii),'XData',interp1(1:nC,CC,xdata{ii}));
            set(a22(ii),'YData',interp1(1:nR,RR,ydata{ii}));
        end
    else
        set(h21,'XData',interp1(1:nC,CC,get(h21,'XData')));
        set(h21,'YData',interp1(1:nR,RR,get(h21,'YData')));
        set(h22,'XData',interp1(1:nC,CC,get(h22,'XData')));
        set(h22,'YData',interp1(1:nR,RR,get(h22,'YData')));
    end
end


%==========================================================================
% --- toolbar zoom callback
%==========================================================================
function toolbarZoomFcn(hObject,eventdata) %#ok<INUSD>
hFig         = gcbf                                                        ;
hToolbarZoom = findall(hFig,'Tag','toolbarZoom')                           ;
hToolbarPan  = findall(hFig,'Tag','toolbarPan')                            ;
pan off                                                                    ;
set(hToolbarPan,'state','off')                                             ;
zoom                                                                       ;


%==========================================================================
% --- toolbar pan callback
%==========================================================================
function toolbarPanFcn(hObject,eventdata) %#ok<INUSD>
hFig         = gcbf                                                        ;
hToolbarZoom = findall(hFig,'Tag','toolbarZoom')                           ;
hToolbarPan  = findall(hFig,'Tag','toolbarPan')                            ;
zoom off                                                                   ;
set(hToolbarZoom,'state','off')                                            ;
pan                                                                        ;


%==========================================================================
% --- reset toolbars
%==========================================================================
function resetToolbar(varargin)
hFigShowImage = varargin{1}                                                ;
hToolbarZoom  = findall(hFigShowImage,'Tag','toolbarZoom')                 ;
hToolbarPan   = findall(hFigShowImage,'Tag','toolbarPan')                  ;
set(hToolbarZoom,'state','off')                                            ;
set(hToolbarPan,'state','off')                                             ;
zoom(hFigShowImage,'off')                                                  ;
pan(hFigShowImage,'off')                                                   ;


%==========================================================================
% --- tracking mouse position
%==========================================================================
function showmaskpartition_WindowButtonMotionFcn(hObject,eventdata) %#ok<INUSD>
%hFigXPCSMain = findall(0,'Tag','xpcsmain_Fig')                             ;
%ccdimginfo = getappdata(hFigXPCSMain,'ccdimginfo')                         ;
global ccdimginfo
set(gcf,'selected','on')                                                   ;
pointPosition = get(gca,'CurrentPoint')                                    ;
XLim=get(gca,'XLim')                                                       ;
YLim=get(gca,'YLim')                                                       ;
XLimFlag=(pointPosition(1,1)>=XLim(1) & pointPosition(1,1)<=XLim(2))       ;
YLimFlag=(pointPosition(1,2)>=YLim(1) & pointPosition(1,2)<=YLim(2))       ;
cdata = get(findall(gcf,'type','image'),'cdata')                           ;
xpos = round(pointPosition(1,1))                                           ;
ypos = round(pointPosition(1,2))                                           ;
if (  xpos >= 1 && xpos <= size(cdata,2) ...
   && ypos >= 1 && ypos <= size(cdata,1) && XLimFlag == 1 && YLimFlag ==1 )
    set(gcf,'Pointer','crosshair')                                         ;
    if ccdimginfo.geometry == 0
        display_str = ['x=',num2str(xpos),                              ...
                     ', y=',num2str(ypos),                              ...
                     ', value=',num2str(cdata(ypos,xpos)),              ...
                     ', q=',num2str(ccdimginfo.maps.q(ypos,xpos)),        ...
                     ', phi=',num2str(ccdimginfo.maps.phi(ypos,xpos))]       ;
    elseif ccdimginfo.geometry == 1
        display_str = ['x=',num2str(xpos),                              ...
                     ', y=',num2str(ypos),                              ...
                     ', value=',num2str(cdata(ypos,xpos)),              ...
                     ', q=',num2str(ccdimginfo.maps.q(ypos,xpos)),      ...                     
                     ', phi=',num2str(ccdimginfo.maps.phi(ypos,xpos)),      ...                             
                     ', q||=',num2str(ccdimginfo.maps.qr(ypos,xpos)),      ...
                     ', qx=',num2str(ccdimginfo.maps.qx(ypos,xpos)),      ...
                     ', qy=',num2str(ccdimginfo.maps.qy(ypos,xpos)),      ...
                     ', qz=',num2str(ccdimginfo.maps.qz(ypos,xpos)),...
                     ', exitAngle=',num2str(ccdimginfo.maps.exitAngle(ypos,xpos)),...
                     ', outOfPlaneAngle=',num2str(ccdimginfo.maps.outOfPlaneAngle(ypos,xpos))];
    elseif ccdimginfo.geometry == 2
        display_str = ['x=',num2str(xpos),                              ...
                     ', y=',num2str(ypos),                              ...
                     ', value=',num2str(cdata(ypos,xpos))];
    end
    set(findall(gcf,'Tag','mouseposition'),'string',display_str)           ;
    
else
    set(gcf,'Pointer','arrow')                                             ;
end
clear XLim YLim XLimFlag YLimFlag                                          ;
clear pointPosition xpos ypos cdata                                        ;


% ---
% EOF
