function varargout = getqspan(varargin)
% GETQSPAN Calculate spans of static and dynamic partitions. 
%
%   Input:
%       ccdimginfo.partition.name               : q/phi/qz/qx/qy/qr/outOfPlaneAngle/exitAngle/x/y
%       ccdimginfo.partition.(snpt/dnpt)        : number of points in the span for static and dynamic    
%       ccdimginfo.partition.(smethod/dmethod)  : 1/2 (evenly spaced in linear/log10 scale)
%
%   Output:
%       ccdimginfo.partition.(sspan/dspan)      : list of partition boundary points
%
% $Revision: 1.0 $  $Date: 2005/01/14 $ by Zhang Jiang
% $Revision: 1.1 $  $Date: 2005/09/26 $ by MS 
% $Revision: 1.2 $  $Date: 2007/04/17 $ by MS include anglecontinuity
% $Revision: 1.3 $  $Date: 2014/07/27 $ by ZJ include binning
% $Revision: 1.4 $  $Date: 2014/09/11 $ by ZJ independent of main XPCSGUI
%       figure; modified from old file getdqphispan.m

if nargin ~= 1
    error('Invalid input.');
end
ccdimginfo = varargin{1};

% =========================================================================
% --- make sure correct usermask exists for batchmode
% =========================================================================
xpixels = ccdimginfo.bin.detector.x_end-ccdimginfo.bin.detector.x_begin+1;
if ( ccdimginfo.detector.kinetics.mode == 1 )      % no binning for kinetics mode
    ypixels = ccdimginfo.detector.kinetics.window_size;
else
    ypixels = ccdimginfo.bin.detector.y_end-ccdimginfo.bin.detector.y_begin+1;
end
% ---
if ( isempty(ccdimginfo.mask.maskpoints) == 1 )      % if no mask points are defined use the full image
    ccdimginfo.mask.usermask = ones(ypixels,xpixels);
else
    % --- calculate (1/0) mask and save it to ccdimginfo.usermask
    %          ccdimginfo.usermask =                                          ...
    %              outsidepolygonmask(ones(ypixels,xpixels),                  ...
    %                  ccdimginfo.maskpoints(:,1),ccdimginfo.maskpoints(:,2) )   ;
    ccdimginfo.mask.usermask = zeros(ypixels,xpixels);
    for ii=1:length(ccdimginfo.mask.maskpoints)
        ccdimginfo.mask.usermask = ccdimginfo.mask.usermask + ...
            outsidepolygonmask(ones(ypixels,xpixels),...
            ccdimginfo.mask.maskpoints{ii}(:,1),ccdimginfo.mask.maskpoints{ii}(:,2));
    end
    ccdimginfo.mask.usermask(ccdimginfo.mask.usermask~=0)=1;
end
% --- define mask roi as the minimum rectangle around the chosen ROI
%     ccdimginfo.mask.maskroi = [min(ccdimginfo.mask.maskpoints(:,1)) min(ccdimginfo.mask.maskpoints(:,2));  ...
%                           max(ccdimginfo.mask.maskpoints(:,1)) max(ccdimginfo.mask.maskpoints(:,2)) ]    ;
tmp_maskpoints = cell2mat(ccdimginfo.mask.maskpoints);
ccdimginfo.mask.maskroi    =  ...
    [min(tmp_maskpoints(:,1)) min(tmp_maskpoints(:,2)); ...
    max(tmp_maskpoints(:,1)) max(tmp_maskpoints(:,2))];

% =========================================================================
% --- if needed include blemish file
% =========================================================================
if ( ~isempty(regexp(ccdimginfo.detector.blemish_status{1},'ENABLED','once')) ) 
    blemish = getblemish(ccdimginfo)                                       ;
    ccdimginfo.mask.usermask = ccdimginfo.mask.usermask .* blemish                   ;
    clear blemish                                                          ;
end

% =========================================================================
% --- define minima & maxima
% --- Carefull: a 2pi jump from -pi to +pi 
% --- needs to be corrected
% =========================================================================
% --- static and dynamic partitions
for ii=1:length(ccdimginfo.partition.name)
    mapname = ccdimginfo.partition.name{ii};
    if strcmpi(mapname,'phi')
        phiunmasked    = ccdimginfo.maps.phi(ccdimginfo.mask.usermask~=0);
        phiunmaskednew = anglecontinuity(phiunmasked);
        max_val  = max(phiunmaskednew);
        min_val  = min(phiunmaskednew);
    else
        max_val    = max(max(ccdimginfo.maps.(mapname)(ccdimginfo.mask.usermask~=0)));
        min_val    = min(min(ccdimginfo.maps.(mapname)(ccdimginfo.mask.usermask~=0)));
    end
    switch ccdimginfo.partition.smethod(ii) % for static
        case 1  % evenly spaced
            ccdimginfo.partition.sspan{ii} = linspace(min_val,max_val,ccdimginfo.partition.snpt(ii)+1);
        case 2  % evenly spaced in log space (or equal dq/q)
        if ( min_val > 0 && min_val < max_val )
            ccdimginfo.partition.sspan{ii} = 10.^linspace(log10(min_val),log10(max_val),ccdimginfo.partition.snpt(ii)+1);
        else    
            ccdimginfo.partition.sspan{ii} = linspace(min_val,max_val,ccdimginfo.partition.snpt(ii)+1);
        end
    end
    switch ccdimginfo.partition.dmethod(ii) % for dynamic
        case 1  % evenly spaced
            ccdimginfo.partition.dspan{ii} = linspace(min_val,max_val,ccdimginfo.partition.dnpt(ii)+1);
        case 2  % evenly spaced in log space (or equal dq/q)
            if ( min_val > 0 && min_val < max_val )
                ccdimginfo.partition.dspan{ii} = 10.^linspace(log10(min_val),log10(max_val),ccdimginfo.partition.dnpt(ii)+1);
            else
                ccdimginfo.partition.dspan{ii} = linspace(min_val,max_val,ccdimginfo.partition.dnpt(ii)+1);
            end
    end
    
end

% =========================================================================
% --- output
% =========================================================================
if (nargout == 1)
    varargout{1}=ccdimginfo;
end
return;