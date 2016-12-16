function getimgmask(varargin)
% GETIMGMASK Let user to select and save mask interactively for an image.
%
%   GETIMAMASK(IMAGE)
%
%   GETIMAMASK(IMAGE,CCDIMGINFO) also add mask information to ccdimginfo.mask
%
% $Revision: 1.0 $  $Date: 2014/08/12 $ by Zhang Jiang

hFigMask = findall(0,'Tag','fig_getimgmask');
if nargin == 0 
    if ~isempty(hFigMask)
        figure(hFigMask);
    else
        error('Need image as the input.');
    end
    return;
elseif nargin >2
    error('Need image as the input.');
elseif nargin == 2  
    ccdimginfo = varargin{2};   
else
    ccdimginfo = [];
end
displayImage = varargin{1};
if isempty(displayImage) || (~isnumeric(displayImage) && ~islogical(displayImage))
    error('Invalid image input.');
end
displayImage = full(displayImage);

% --- figure layout
delete(hFigMask);
hFigMask = figure(...
    'NumberTitle','off',...
    'MenuBar','none',...
    'Toolbar','none',...
    'Name','Get Mask Polygon',...
    'Tag','fig_getimgmask',...
    'WindowButtonDownFcn','',...
    'WindowButtonUpFcn','',...
    'WindowButtonMotionFcn',{@maskfig_WindowButtonMotionFcn,ccdimginfo},...
    'UserData',displayImage);
setappdata(hFigMask,'ccdimginfo',ccdimginfo);
% --- toolbar layout
hToolbar = uitoolbar(hFigMask,'Tag','mask_fig_Toolbar');
icons = load('getimgmask_icon.mat');
hToolbarLoadMask    = uipushtool(hToolbar,...
    'Tag','toolbarLoadMask',...
    'CDATA',icons.icon_opendoc,...
    'TooltipString','Load Mask',...
    'ClickedCallback',@toolbarLoadMaskFcn);
hToolbarSaveMask2File    = uipushtool(hToolbar,...
    'Tag','toolbarSaveMask2File',...
    'CDATA',icons.icon_savedoc,...
    'TooltipString','Save Mask to Disk',...
    'ClickedCallback',@toolbarSaveMaskFcn);
hToolbarSaveMask2Workspace    = uipushtool(hToolbar,...
    'Tag','toolbarSaveMask2Workspace',...
    'CDATA',icons.icon_save2workspace,...
    'TooltipString','Save Mask/ccdimginfo to Workspace',...
    'ClickedCallback',@toolbarSaveMaskFcn);
hToolbarZoom = uitoggletool(hToolbar,...
    'CDATA',icons.icon_zoom,...
	'Separator','on',...
    'TooltipString','Zoom',...
    'State','off',...
    'ClickedCallback',@toolbarZoomFcn,...
    'Tag','toolbarZoom');
hToolbarPan = uitoggletool(hToolbar,...
    'CDATA',icons.icon_pan,...
    'TooltipString','Pan',...
    'ClickedCallback',@toolbarPanFcn,...
    'Tag','toolbarPan');
hToolbarColormapeditor = uipushtool(hToolbar,...
    'CDATA',icons.icon_colormapeditor,...
    'TooltipString','Colormap',...
    'ClickedCallback','colormapeditor;',...
    'Tag','toolbarColormapeditor');
tri_up = [
    1 1 1 1 1 1 0 1 1 1 1 1 1 
    1 1 1 1 1 0 0 0 1 1 1 1 1 
    1 1 1 1 0 0 0 0 0 1 1 1 1 
    1 1 1 0 0 0 0 0 0 0 1 1 1 
    1 1 0 0 0 0 0 0 0 0 0 1 1 
    1 0 0 0 0 0 0 0 0 0 0 0 1     
    ];
tri_down = tri_up(end:-1:1,:);

cmax_up = repmat(...
    [zeros(2,length(tri_up)); nan(2,length(tri_up)); tri_up;nan(4,length(tri_up));],...
    [1 1 3]);
cmax_up(cmax_up == 1) = NaN;
cmax_down = repmat(...
    [zeros(2,length(tri_down)); nan(2,length(tri_down)); tri_down;nan(4,length(tri_down));],...
    [1 1 3]);
cmax_down(cmax_down == 1) = NaN;
cmin_up = repmat(...
    [nan(4,length(tri_up)); tri_up;nan(2,length(tri_up));zeros(2,length(tri_up)); ],...
    [1 1 3]);
cmin_up(cmin_up == 1) = NaN;
cmin_down = repmat(...
    [nan(4,length(tri_down)); tri_down;nan(2,length(tri_down));zeros(2,length(tri_down));],...
    [1 1 3]);
cmin_down(cmin_down == 1) = NaN;


uipushtool(hToolbar,...
    'CDATA',cmin_down,...
    'TooltipString','CMin Down',...
    'ClickedCallback',@toolbarCMapFcn,...
    'Tag','toolbarCMinDown');
uipushtool(hToolbar,...
    'CDATA',cmin_up,...
    'TooltipString','CMin Up',...
    'ClickedCallback',@toolbarCMapFcn,...
    'Tag','toolbarCMinUp');
uipushtool(hToolbar,...
    'CDATA',cmax_down,...
    'TooltipString','CMax Down',...
    'ClickedCallback',@toolbarCMapFcn,...
    'Tag','toolbarCMaxDown');
uipushtool(hToolbar,...
    'CDATA',cmax_up,...
    'TooltipString','CMax UP',...
    'ClickedCallback',@toolbarCMapFcn,...
    'Tag','toolbarCMaxUp');

hToolbarLog = uitoggletool(hToolbar,...
    'separator','on',...
    'CDATA',icons.icon_logscale,...
    'TooltipString','Log10 Scale',...
    'ClickedCallback',@toolbarLogFcn,...
    'Tag','toolbarLog');
uitoggletool(hToolbar,...
    'CDATA',icons.icon_maskinclude,...
    'Separator','on',...
    'TooltipString','Toggle inclusive/exclusive',...
    'ClickedCallback',@toolbarMaskInclusiveFcn,...
    'Tag','toolbarMaskInclusive');
hToolbarMask = uipushtool(hToolbar,...
    'CDATA',icons.icon_maskstart,...
    'TooltipString','Start masking',...
    'ClickedCallback',@toolbarMaskFcn,...
    'Tag','toolbarMask');
hToolbarMaskFinish = uipushtool(hToolbar,...
    'Tag','toolbarMaskFinish',...
    'CDATA',icons.icon_maskfinish,...
    'TooltipString','Finish masking',...
    'ClickedCallback',@toolbarMaskFinishFcn,...
    'Enable','off');
hToolbarMaskClear = uipushtool(hToolbar,...
    'CDATA',icons.icon_maskclear,...
    'TooltipString','Clear mask and initialize mask to full image',...
    'ClickedCallback',@toolbarMaskClearFcn,...
    'Tag','toolbarClear');
uipushtool(hToolbar,...
    'CDATA',icons.icon_showmask,...
    'TooltipString','Show Mask',...
    'ClickedCallback',@toolbarShowMaskFcn,...
    'Tag','toolbarShow');
uicontrol('Parent',hFigMask,...
    'Style','Text',...
    'String',' ',...
    'Units','normalized',...
    'FontSize',8,...
    'HorizontalAlignment','left',...
    'Position',[0.05 0.005 0.9 0.05],...    
    'Tag','mouseposition');

% --- reset toolbar controls of image figure
%resetToolbar(hFigMask);  

% --- activate figure and plot image
figure(hFigMask);
tmp_displayImage = displayImage(displayImage~=-Inf);
data_std = std(tmp_displayImage(:));
data_mean = mean(tmp_displayImage(:));
try
    hImm = imagesc(displayImage,[max(data_mean-5*data_std,0),data_mean+5*data_std]);    
catch
    hImm = imagesc(displayImage);
end
axis xy;
set(gca,'tickDir','out');
set(hImm,'Tag','fig_getimgmask_img');
set(get(hImm,'Parent'),'YDir','normal');
colormap('jet');
clear tmp_displayImage

% display ccdimginfo has mask, then plot it
%if isempty(ccdimginfo)
%     [Y, X] = size(displayImage);
%     maskpoints = {[1 1; 1 Y; X Y;X 1]};
%else
%    maskpoints = ccdimginfo.mask.maskpoints;
%end
if isempty(ccdimginfo)
    usermask = true(size(displayImage));
else
    usermask = ccdimginfo.mask.usermask;
end

%hold on;
plotmask(hFigMask,usermask);
% for ii=1:length(maskpoints)
%     if polyarea(maskpoints{ii}(:,1),maskpoints{ii}(:,2))>0
%         line(...
%             'Parent',get(findall(hFigMask,'tag','fig_getimgmask_img'),'Parent'),...
%             'XData',[maskpoints{ii}(:,1);maskpoints{ii}(1,1)],...
%             'YData',[maskpoints{ii}(:,2);maskpoints{ii}(1,2)],...
%             'Tag','maskpointline','color','g','LineWidth',2);
%     end
% end
setappdata(hFigMask,'flagfirstmask',1);
%setappdata(hFigMask,'maskpoints',maskpoints);
setappdata(hFigMask,'usermaskflag',0);
setappdata(hFigMask,'usermask',usermask);

%==========================================================================
% --- toolbar load custom mask callback
%==========================================================================
function toolbarLoadMaskFcn(hObject,eventdata)
hFigMask         = findall(0,'Tag','fig_getimgmask');
displayImage     = get(hFigMask,'UserData');
hToolbarZoom     = findall(hFigMask,'Tag','toolbarZoom');
hToolbarPan      = findall(hFigMask,'Tag','toolbarPan');
pan  off;
zoom off;
set(hToolbarPan ,'state','off');
set(hToolbarZoom,'state','off');
% --- load MaskInfo from user supplied file 
currentPath  = pwd;
[filename,filepath] = uigetfile({'*.mat','Mask Files (*.mat)'},...
    'Select Mask File','MultiSelect','off'); % dialog to select file
if isequal([filename,filepath],[0,0])
    restorePath(currentPath);
    return;
end
file = fullfile(filepath,filename); % the whole filename
restorePath(currentPath); % restore path
load(file,'usermask');
% --- check if usermask is valid
if ~islogical(usermask) || ~isequal(size(displayImage),size(usermask))
    usermask = true(size(displayImage));
    uiwait(msgbox('This is not a valid mask. Whole image will be used.','Error','modal'));    
end
%Valid = 0;
% for ii=1:length(MaskInfo.maskpoints)
%     minRowMaskPoints = min(MaskInfo.maskpoints{ii}(:,2));
%     maxRowMaskPoints = max(MaskInfo.maskpoints{ii}(:,2));
%     minColMaskPoints = min(MaskInfo.maskpoints{ii}(:,1));
%     maxColMaskPoints = max(MaskInfo.maskpoints{ii}(:,1));
%     if minRowMaskPoints >= 1 && maxRowMaskPoints <= ypixels ...
%             && minColMaskPoints >= 1 && maxColMaskPoints <= xpixels...
%             && numel(MaskInfo.maskpoints{ii}) >= 6 ...
%             && mod(numel(MaskInfo.maskpoints{ii}),2) == 0 ...
%             && polyarea(MaskInfo.maskpoints{ii}(:,1),MaskInfo.maskpoints{ii}(:,2)) > 0
%         Valid = 1;
%     else
%        uiwait(msgbox('This is not a valid mask. Whole image will be used.','Error','modal'));
%    end
%end
% % --- save masking information to MaskInfo
% if Valid == 1
%     maskpoints = MaskInfo.maskpoints;
% else
%     maskpoints = {[1 1; xpixels 1; xpixels ypixels; 1 ypixels]};
% end
%setappdata(hFigMask,'maskpoints',maskpoints);
setappdata(hFigMask,'usermaskflag',0);
setappdata(hFigMask,'usermask',usermask);
% --- update ccdimginfo
ccdimginfo = getappdata(hFigMask,'ccdimginfo');
if ~isempty(ccdimginfo)
    ccdimginfo.mask.usermask = usermask;
    setappdata(hFigMask,'ccdimginfo',ccdimginfo);
end


% ccdimginfo = getappdata(hFigMask,'ccdimginfo');
% if ~isempty(ccdimginfo)
%     ccdimginfo.mask.maskpoints = maskpoints;
%     if Valid == 1
%         tmp_maskpoints = cell2mat(maskpoints);
%         ccdimginfo.mask.maskroi    =  ...
%             [min(tmp_maskpoints(:,1)) min(tmp_maskpoints(:,2)); ...
%             max(tmp_maskpoints(:,1)) max(tmp_maskpoints(:,2))];
%     else
%         if ( ccdimginfo.detector.kinetics.mode == 1 )
%             ccdimginfo.mask.maskroi = [1 1; xpixels ccdimginfo.detector.kinetics.window_size];
%         else
%             ccdimginfo.mask.maskroi = [1 1; xpixels ypixels];
%         end
%     end
%     setappdata(hFigMask,'ccdimginfo',ccdimginfo);
% end
% --- plot mask
plotmask(hFigMask,usermask);
% for ii=1:length(maskpoints)
%     if polyarea(maskpoints{ii}(:,1),maskpoints{ii}(:,2))>0
%         line(...
%             'Parent',get(findall(hFigMask,'tag','fig_getimgmask_img'),'Parent'),...
%             'XData',[maskpoints{ii}(:,1);maskpoints{ii}(1,1)],...
%             'YData',[maskpoints{ii}(:,2);maskpoints{ii}(1,2)],...
%             'Tag','maskpointline','color','g','LineWidth',2);
%     end
% end

%==========================================================================
% --- plot mask
%==========================================================================
function plotmask(hFigMask,usermask)
figure(hFigMask);
set(hFigMask,'selected','on');
delete(findall(hFigMask,'Tag','maskpointline'));
% % B = bwboundaries(usermask); % mask boundaries for plotting
% % for ii=1:length(B)
% %     line(...
% %         'Parent',get(findall(hFigMask,'tag','fig_getimgmask_img'),'Parent'),...
% %         'XData',B{ii}(:,2),...
% %         'YData',B{ii}(:,1),...
% %         'Tag','maskpointline','color','g','LineWidth',2);
% % end
hold on;
warning('off','MATLAB:contour:ConstantData');

[~,hPatches] = contour(usermask,1);
warning('on','MATLAB:contour:ConstantData');
hold off;
if verLessThan('Matlab','8.4')
    set(get(hPatches,'Children'),'EdgeColor','g','linewidth',2);
else
    set(hPatches,'LineColor','g','linewidth',2);
end
set(hPatches,'tag','maskpointline');


%==========================================================================
% --- toolbar save custom mask callback
%==========================================================================
function toolbarSaveMaskFcn(hObject,eventdata)
hgcbo = gcbo;
hFigMask         = findall(0,'Tag','fig_getimgmask');
hToolbarZoom     = findall(hFigMask,'Tag','toolbarZoom');
hToolbarPan      = findall(hFigMask,'Tag','toolbarPan');
%maskpoints       = getappdata(hFigMask,'maskpoints');
usermaskflag     = getappdata(hFigMask,'usermaskflag');
usermask         = getappdata(hFigMask,'usermask');
ccdimginfo       = getappdata(hFigMask,'ccdimginfo');
pan  off;
zoom off;
set(hToolbarPan ,'state','off');
set(hToolbarZoom,'state','off');
if usermaskflag == 0
    if strcmpi(get(hgcbo,'tag'),'toolbarSaveMask2File')     % save to file
        currentPath  = pwd;
        %MaskInfo.maskpoints = maskpoints;
        %MaskInfo.maskroi = maskroi;
        [filename,filepath] = uiputfile({'*.mat','Save Mask File (*.mat)'}); % dialog to select file
        if isequal([filename,filepath],[0,0])
            restorePath(currentPath);
            return;
        end
        file = fullfile(filepath,filename); % the whole filename
        save(file,'usermask');
        restorePath(currentPath); % restore path
    elseif strcmpi(get(hgcbo,'tag'),'toolbarSaveMask2Workspace')    % save to workspace
        if isempty(ccdimginfo)      % save mask points to workspace
            dlgAnswer = inputdlg('Enter variable name','Save to Workspace',[1 50],{'usermask'});
            if isempty(dlgAnswer)
                return;
            end
            dlgAnswer = matlab.lang.makeValidName(dlgAnswer{1});
            assignin('base',dlgAnswer,usermask);
        else        % save ccdimginfo to workspace
            assignin('base','ccdimginfo',ccdimginfo);
            warndlg('Mask information has been updated in ccdimginfo.mask, and saved back to workspace.', 'Save to Workspace', 'modal');
        end
    end
else
    uiwait(msgbox('Please finish masking','Error','modal'));
    figure(hFigMask);
    set(gcf,'selected','on');
end


% if ( usermaskflag == 0 && ~isempty(maskpoints) == 1 )                        % masking is finished & and a new mask exists
%         tmp_maskpoints = cell2mat(maskpoints);
%         maskroi    =  ...
%             [min(tmp_maskpoints(:,1)) min(tmp_maskpoints(:,2)); ...
%             max(tmp_maskpoints(:,1)) max(tmp_maskpoints(:,2))];    
%     if strcmpi(get(hgcbo,'tag'),'toolbarSaveMask2File')     % save to file
%         currentPath  = pwd;
%         MaskInfo.maskpoints = maskpoints;
%         MaskInfo.maskroi = maskroi;
%         [filename,filepath] = uiputfile({'*.mat','Save Mask File (*.mat)'}); % dialog to select file
%         if isequal([filename,filepath],[0,0])
%             restorePath(currentPath);
%             return;
%         end
%         file = fullfile(filepath,filename); % the whole filename
%         save(file,'MaskInfo');
%         restorePath(currentPath); % restore path
%     elseif strcmpi(get(hgcbo,'tag'),'toolbarSaveMask2Workspace')    % save to workspace
%         if isempty(ccdimginfo)      % save mask points to workspace
%             dlgAnswer = inputdlg('Enter variable name','Save to Workspace',[1 50],{'MaskInfo'});
%             if isempty(dlgAnswer)
%                 return;
%             end
%             dlgAnswer = matlab.lang.makeValidName(dlgAnswer{1});
%             eval([dlgAnswer,'.maskpoints=maskpoints;']);
%             eval([dlgAnswer,'.maskroi=maskroi;']);           
%             eval(['assignin(''base'',dlgAnswer,',dlgAnswer,')']);
%         else        % save ccdimginfo to workspace
%             assignin('base','ccdimginfo',ccdimginfo);
%             warndlg('Mask information has been updated in ccdimginfo.mask, and saved back to workspace.', 'Save to Workspace', 'modal');
%         end
%     end
% else
%     uiwait(msgbox('Invalid mask or mask does not exist.','Error','modal'));
%     figure(hFigMask);
%     set(gcf,'selected','on');
% end


%==========================================================================
% --- toolbar zoom callback
%==========================================================================
function toolbarZoomFcn(hObject,eventdata)
hFig = gcbf;
hToolbarPan      = findall(hFig,'Tag','toolbarPan');
pan  off;
zoom;
set(hToolbarPan,'state','off');


%==========================================================================
% --- toolbar pan callback
%==========================================================================
function toolbarPanFcn(hObject,eventdata)
hFig = gcbf;
hToolbarZoom     = findall(hFig,'Tag','toolbarZoom');
zoom off;
pan;
set(hToolbarZoom,'state','off');

%==========================================================================
% --- toolbar cmap callback
%==========================================================================
function toolbarCMapFcn(hObject,eventdata)
hFig = gcbf;
tag = get(gcbo,'tag'); 
himg = findall(hFig,'tag','fig_getimgmask_img');
haxes = get(himg,'Parent');
img = get(himg,'CData');
clim0 = get(haxes,'clim');
dclim = clim0(2)-clim0(1);
switch 1
    case strcmpi(tag,'toolbarCMinDown')
        clim1 = [clim0(1)-dclim/10,clim0(2)];
    case strcmpi(tag,'toolbarCMinUp')
        clim1 = [min(clim0(1)+dclim/10,clim0(2)),clim0(2)];
    case strcmpi(tag,'toolbarCMaxDown')
        clim1 = [clim0(1),max(clim0(2)-dclim/10,clim0(1))];
    case strcmpi(tag,'toolbarCMaxUp') 
        clim1 = [clim0(1),clim0(2)+dclim/10];
end
set(haxes,'Clim',clim1);

%==========================================================================
% --- toolbar log callback
%==========================================================================
function toolbarLogFcn(hObject,eventdata)
hFig = gcbf;
hToolbarLog = gcbo; 
himg = findall(hFig,'tag','fig_getimgmask_img');
haxes = get(himg,'Parent');
img = get(himg,'CData');
clim = get(haxes,'clim');
if strcmpi(get(hToolbarLog,'state'),'on')
    img(img<0) = 0;
    clim(clim<=0) = 1e-3;
    clim = log10(clim);
    set(himg,'CData',log10(img));
    set(haxes,'Clim',clim);    
else
    set(himg,'CData',10.^(img));
    set(haxes,'Clim',10.^(clim));
end

%==========================================================================
% --- toolbar mask callback
%==========================================================================
function toolbarMaskInclusiveFcn(hObject,eventdata)
hFigMask         = findall(0,'Tag','fig_getimgmask');
icons = load('getimgmask_icon.mat');
h = findall(hFigMask,'Tag','toolbarMaskInclusive');
if strcmpi('off',get(h,'State'))
    set(h,'CDATA',icons.icon_maskinclude);
else
    set(h,'CDATA',icons.icon_maskexclude);
end

%==========================================================================
% --- toolbar mask callback
%==========================================================================
function toolbarMaskFcn(hObject,eventdata)
hFigMask         = findall(0,'Tag','fig_getimgmask');
set(findall(hFigMask,'Tag','toolbarMaskFinish'),'Enable','on');
resetToolbar(hFigMask);

% --- reset maskpoints & set flag to 1 to get more points 
% --- (toolbarMaskFinishFcn turns flag to 0 to stop getting any more point)
setappdata(hFigMask,'singlemaskpoints',[]);
setappdata(hFigMask,'usermaskflag',1);
if getappdata(hFigMask,'flagfirstmask');           % initialize the maskpoints when select the first mask region
        delete(findall(gcf,'Tag','maskpointline'));
end
% --- use windowbuttondownfcn to get points
set(hFigMask,'WindowButtonDownFcn',@maskfig_WindowButtonDownFcn);

%==========================================================================
% --- toolbar mask callback
%==========================================================================
function toolbarMaskFinishFcn(hObject,eventdata)
hFigMask = findall(0,'Tag','fig_getimgmask');
resetToolbar(hFigMask);
usermask = getappdata(hFigMask,'usermask');
% --- set flag to 0 to stop getting any more points
setappdata(hFigMask,'usermaskflag',0);
set(hFigMask,'WindowButtonDownFcn','');
% --- plot polygon (if # of points is less than 3, set maskpoints to [])
singlemaskpoints = getappdata(hFigMask,'singlemaskpoints');
maskstate = get(findall(hFigMask,'Tag','toolbarMaskInclusive'),'state');
if ~isempty(singlemaskpoints) & polyarea(singlemaskpoints(:,1),singlemaskpoints(:,2))>0
     if getappdata(hFigMask,'flagfirstmask');           % initialize the maskpoints when select the first mask region
         delete(findall(gcf,'Tag','maskpointline'));
         %setappdata(hFigMask,'maskpoints',{});
         setappdata(hFigMask,'flagfirstmask',0);
         if strcmpi(maskstate,'off')        % inclusive
            usermask = false(size(usermask));
         else       % exclusive
            usermask = true(size(usermask));
         end
     end
    if strcmpi(maskstate,'off') 
        line_color = 'g';
    else
        line_color = 'm';
    end
    line('Parent',get(findall(hFigMask,...
        'tag','fig_getimgmask_img'),'Parent'),...
        'XData',[singlemaskpoints(:,1);singlemaskpoints(1,1)],...
        'YData',[singlemaskpoints(:,2);singlemaskpoints(1,2)],...
        'Tag','maskpointline',...
        'color',line_color,'LineWidth',2);
   [xgrid,ygrid] = meshgrid(1:size(usermask,2),1:size(usermask,1));
   in = inpolygon(xgrid(:),ygrid(:),singlemaskpoints(:,1),singlemaskpoints(:,2));
   BW = reshape(in,size(usermask)); 
   if strcmpi(maskstate,'off')        % inclusive
       usermask(BW) = true; % = (usermask | BW);
   else
       usermask(BW) = false;
   end   
   setappdata(hFigMask,'usermask',usermask);
   % maskpoints = [getappdata(hFigMask,'maskpoints');singlemaskpoints];
   % setappdata(hFigMask,'maskpoints',maskpoints);
    % --- update ccdimginfo
    ccdimginfo = getappdata(hFigMask,'ccdimginfo');
    if ~isempty(ccdimginfo)
        
%         ccdimginfo.mask.maskpoints = maskpoints;
%         tmp_maskpoints = cell2mat(maskpoints);
%         ccdimginfo.mask.maskroi    =  ...
%             [min(tmp_maskpoints(:,1)) min(tmp_maskpoints(:,2)); ...
%             max(tmp_maskpoints(:,1)) max(tmp_maskpoints(:,2))];
        ccdimginfo.mask.usermask = usermask;
        setappdata(hFigMask,'ccdimginfo',ccdimginfo);
    end   
else
    setappdata(hFigMask,'singlemaskpoints',[]);
    hMSGBox = msgbox('Invalid mask polygon !','Mask Error','Error','modal');
    uiwait(hMSGBox);
end
delete(findall(gcf,'Tag','maskpointline','Color','r'));



%==========================================================================
% --- toolbar mask callback
%==========================================================================
function toolbarMaskClearFcn(hObject,eventdata)
hFigMask         = findall(0,'Tag','fig_getimgmask');
resetToolbar(hFigMask);
delete(findall(hFigMask,'Tag','maskpointline'));
usermask = getappdata(hFigMask,'usermask');
ccdimginfo = getappdata(hFigMask,'ccdimginfo');
usermask = true(size(usermask));        % initialize usermask to ones
if ~isempty(ccdimginfo)
    ccdimginfo.mask.usermask = usermask;
end
setappdata(hFigMask,'singlemaskpoints',[]);
setappdata(hFigMask,'flagfirstmask',1);
setappdata(hFigMask,'usermask',usermask);
setappdata(hFigMask,'ccdimginfo',ccdimginfo);
plotmask(hFigMask,usermask);
%setappdata(hFigMask,'maskpoints',{});

function toolbarShowMaskFcn(hObject,eventdata)
hFigMask         = findall(0,'Tag','fig_getimgmask');
usermask = getappdata(hFigMask,'usermask');
figure
imagesc(usermask,[0,1]);
set(gca,'ydir','norm');

%==========================================================================
% --- maskfig windowbuttonmotionfcn callback
%==========================================================================
function maskfig_WindowButtonMotionFcn(hObject,eventdata,ccdimginfo)
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
    if getappdata(findall(0,'Tag','fig_getimgmask'),'usermaskflag') == 1
        set(gcf,'Pointer','crosshair')                                 ;
    else
        set(gcf,'Pointer','crosshair')                                     ;
    end
%     set(findall(gcf,'Tag','mouseposition'),'string',                    ...
%         ['(',num2str(xpos),',',num2str(ypos),') : ',              ...
%         num2str(cdata(ypos,xpos))])                                        ;
    if isempty(ccdimginfo)
        display_str = ['(',num2str(xpos),',',num2str(ypos),') : ',num2str(cdata(ypos,xpos))];
    elseif ccdimginfo.geometry == 0
%         display_str = ['x=',num2str(xpos),                              ...
%                      ', y=',num2str(ypos),                              ...
%                      ', value=',num2str(cdata(ypos,xpos)),              ...
%                      ', q=',num2str(ccdimginfo.qmap(ypos,xpos)),        ...
%                      ', phi=',num2str(ccdimginfo.phimap(ypos,xpos))]       ;
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
    else
        display_str = '';
    end
    set(findall(gcf,'Tag','mouseposition'),'string',display_str)           ;
else
    set(gcf,'Pointer','arrow')                                             ;
end
clear XLim YLim XLimFlag YLimFlag                                          ;
clear pointPosition xpos ypos cdata                                        ;


%==========================================================================
% --- maskfig windowbuttondownfcn callback
%==========================================================================
function maskfig_WindowButtonDownFcn(hObject,eventdata)
hFigMask         = findall(0,'Tag','fig_getimgmask');
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

%==========================================================================
% --- reset toolbars
%==========================================================================
function resetToolbar(varargin)
hFigMask = varargin{1};
hToolbarZoom = findall(hFigMask,'Tag','toolbarZoom');
hToolbarPan = findall(hFigMask,'Tag','toolbarPan');
set(hToolbarZoom,'state','off');
set(hToolbarPan,'state','off');
zoom(hFigMask,'off');
pan(hFigMask,'off');

%==========================================================================
% --- restore to current path
%==========================================================================
function restorePath(currentPath)
path_str = ['cd ','''',currentPath,''''];
eval(path_str);
