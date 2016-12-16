function varargout = mapccdpixel(varargin)
%
% MAPCCDPIXEL Map each pixel to q|| and phi for transmission geometry or to
%    qx, qy, phi(qz) and q|| for reflection geometry. 
%
%   Output: 
%       1. Transmission mode: save qmap, phimap into ccdimginfo
%       2. Reflection mode: save qmap, phimap, qxmap, qymap into ccdimginfo
%
% 
% $Revision: 1.0 $Date: 2005/01/14 $ by Zhang Jiang
% $Revision: 1.1 $Date: 2005/10/11 $ by MS to incorporate different
%                       pixel sizes in x & y direction (e.g. for the
%                       tilted CMOS camera)
% $Revision: 1.2 $Date: 2006/08/23 $ by MS simplified mapping
% $Revision: 1.3 $Date: 2014/07/27 $ by ZJ include binning

% =========================================================================
% --- get application data
% =========================================================================
hFigXPCSMain = findall(0,'Tag','xpcsmain_Fig')                             ;
if isempty(hFigXPCSMain)
    return                                                                 ;
end
if isappdata(hFigXPCSMain,'ccdimginfo')
    ccdimginfo = getappdata(hFigXPCSMain,'ccdimginfo')                     ;
else
    return                                                                 ;
end


% =========================================================================
% --- check if ccdimginfo.dpix (pixel size) is a scalar or a vector and 
% --- assign values to dpix_x & dpix_y accordingly
% =========================================================================

    dpix_x = ccdimginfo.bin.detector.dpix_x                                            ;
    dpix_y = ccdimginfo.bin.detector.dpix_y                                            ;
  


% =========================================================================
% --- calculate the coordinates of direct beam and reflected beam in
% --- respect to the ccd positions during the measurement
% =========================================================================
xDBpix = ccdimginfo.bin.acquisition.x0 + ccdimginfo.ccdxsense * (ccdimginfo.acquisition.ccdx - ccdimginfo.acquisition.ccdx0) / dpix_x ;
yDBpix = ccdimginfo.bin.acquisition.y0 + ccdimginfo.ccdzsense * (ccdimginfo.acquisition.ccdz - ccdimginfo.acquisition.ccdz0) / dpix_y ;
if ( ccdimginfo.geometry == 1 )
    xRBpix = ccdimginfo.bin.acquisition.xspec + ccdimginfo.ccdxsense * (ccdimginfo.acquisition.ccdx - ccdimginfo.acquisition.ccdxspec) / dpix_x ;
    yRBpix = ccdimginfo.bin.acquisition.yspec + ccdimginfo.ccdzsense * (ccdimginfo.acquisition.ccdz - ccdimginfo.acquisition.ccdzspec) / dpix_y ;
end
% --- create vectors with x & y pixel positions
if ccdimginfo.detector.kinetics.mode == 0                                                  % non-kinetics mode (full or roi mode)
    xpix = ccdimginfo.bin.detector.x_begin:ccdimginfo.bin.detector.x_end                           ;
    ypix = ccdimginfo.bin.detector.y_begin:ccdimginfo.bin.detector.y_end                           ;
elseif ccdimginfo.detector.kinetics.mode == 1               % kinetics mode (?????bin to be finished for kinetics mode?????)
    xpix = ccdimginfo.detector.x_begin:ccdimginfo.detector.x_end                           ;
    ypix = ccdimginfo.detector.kinetics.slice_top-ccdimginfo.detector.kinetics.window_size+1:ccdimginfo.detector.kinetics.slice_top ;
end
xmm     = ones(length(ypix),1) * (single(xpix) - xDBpix) * dpix_x                  ;
ymm     = (single(ypix') - yDBpix) * dpix_y * ones(1,length(xpix))                 ;
% --- calculate the coordinates with beam0 being the origin in mm
d2Beam0 = sqrt( xmm.^2 + ymm.^2)                                           ; % distance of each pixel to beam0
% ---
clear xpix ypix                                                            ;


% =========================================================================
% --- do mapping for transmission and reflection geometry
% =========================================================================
if ccdimginfo.geometry == 0                                                  % transmission geometry

    % --- determine q map (no x,y or z component)
    ccdimginfo.qmap = single(4*pi/(12.398/ccdimginfo.measurement.instrument.source_begin.energy) ...
                    * sin(1/2*atan( d2Beam0 / ccdimginfo.detector.distance)) )            ;

    % --- determine phi map
    % --- Angle phi is defined with respect to the vertical axis;
    % --- The order of the four quadrants goes clockwise 
    % --- (by looking at the CCD in an upstream direction):
    % --- 1st quadrant: [0,pi/2]        (x>0, y>0)
    % --- 2nd quadrant: [pi/2,pi)       (x>0, y<0)
    % --- 3rd quadrant: [-pi,-pi/2]     (x<0, y<0)
    % --- 4th quadrant: [-pi/2,0]       (x<0, y>0)
    % --- Phi angles in 1st and 4th quardant are defined automatically.
    % --- (Only angles in 2nd and 3rd need to be adjusted)
    ccdimginfo.phimap         = zeros(size(xmm))                           ; % initialize Phi map
    ccdimginfo.phimap(ymm~=0) = atan( xmm(ymm~=0) ./ ymm(ymm~=0))          ;
    % --- case i) y = 0 & x > 0
    findIndex = find( xmm > 0 & ymm == 0)                                  ;
    if ~isempty(findIndex)
        ccdimginfo.phimap(findIndex) = pi /2                               ; 
    end
    % --- case ii) y = 0 & x < 0
    findIndex = find( xmm < 0 & ymm == 0)                                  ;
    if ~isempty(findIndex)
        ccdimginfo.phimap(findIndex) = - pi /2                             ;
    end
    % --- case iii) y = 0 & x = 0
    findIndex = find( xmm == 0 & ymm == 0)                                 ;
    if ~isempty(findIndex)
        ccdimginfo.phimap(findIndex) = 0                                   ;
    end
    % --- 2nd quadrant
    findIndex = find( xmm >= 0 & ymm <= 0)                                 ;
    if ~isempty(findIndex)
        ccdimginfo.phimap(findIndex) = pi + ccdimginfo.phimap(findIndex)   ;
    end
    % --- 3rd quadrant
    findIndex = find( xmm <= 0 & ymm <= 0 )                                ;
    if ~isempty(findIndex)
        ccdimginfo.phimap(findIndex) = -pi + ccdimginfo.phimap(findIndex)  ;
    end
    % --- convert to single precission
    ccdimginfo.phimap = single(ccdimginfo.phimap)                          ;
    
%     incidentangle=(3.14/180)*90;
%     
%     
%         % qx map
%     ccdimginfo.qxmap  = single(2*pi/ccdimginfo.wavelength               ...
%                       * ( cos(incidentangle) - cos(exitAngle).*cos(outOfPlaneAngle) ) ) ;
%     
%     % qy map
%     ccdimginfo.qymap  = single(2*pi/ccdimginfo.wavelength               ...
%                       * cos(exitAngle).*sin(outOfPlaneAngle))              ;
    
    
    
    
    clear findIndex                                                        ;
    

elseif ccdimginfo.geometry == 1                                              % reflection geometry

    % distance from the direct beam to the reflected beam [mm]
    xDB2RB = (xRBpix - xDBpix) * dpix_x                                    ;
    yDB2RB = (yRBpix - yDBpix) * dpix_y                                    ;
    
    % calculate the true incident angle for the measurement of the specular
%     dDB2RB = sqrt( xDB2RB^2 + yDB2RB^2 )                                   ;
%     trueAlpha = 1/2 * atan( dDB2RB / ccdimginfo.rr )                       ; % true specular angle [rad]
    
    % convert the measurement incident angle (nominal angle to [rad])
    incidentangle = pi / 180 * abs(ccdimginfo.acquisition.angle)               ; % incident angle [rad]

    % determine the tilt angle of the streak with respect to the
    % negative direction of the ccdx axis (define that tilt is positive
    % if streak goes up; negative for down streak; 0 for no tilt)
    if ( xDB2RB ~= 0 )
        tilt = atan( yDB2RB / xDB2RB )                                     ;
    else
        tilt = sign(yDB2RB) * pi / 2                                       ;
    end
   
    % projected distance of each pixel to the plane of reflection [POR])
    % [positive means above the streak, negative below the streak]
    d2POR = zeros(size(xmm))                                               ; % initialize D2POR map
    d2POR(xmm~=0) =  d2Beam0(xmm~=0)                                    ...
                  .* sin(atan(ymm(xmm~=0)./xmm(xmm~=0)) - tilt)            ;
    % --- case i) x = 0 & y > 0
    findIndex = find( ymm > 0 & xmm == 0)                                  ;
    if ~isempty(findIndex)
        d2POR(findIndex) = d2Beam0(findIndex).*sin(pi/2 - tilt)            ; 
    end
    % --- case ii) x = 0 & y < 0
    findIndex = find( ymm < 0 & xmm == 0)                                  ;
    if ~isempty(findIndex)
        d2POR(findIndex) = d2Beam0(findIndex).*sin(-pi/2 - tilt)           ; 
    end
    % --- case iii) x = 0 & y = 0
    findIndex = find( ymm == 0 & xmm == 0)                                 ;
    if ~isempty(findIndex)
        d2POR(findIndex) = d2Beam0(findIndex).*sin(0 - tilt)               ; 
    end
   
    % in plane exit angle of each pixel (not true exit angle)
    inPlaneExitAngle = atan(sqrt(d2Beam0.^2-d2POR.^2)/ccdimginfo.detector.distance)-incidentangle ;
    
    % distance of projected point (PPT) to sample
    dPPt2Sample = sqrt(d2Beam0.^2+ccdimginfo.detector.distance^2-d2POR.^2)                ;
    
    % out of plane angle
    outOfPlaneAngle = atan(d2POR./(dPPt2Sample.*cos(inPlaneExitAngle)))    ;
    
    % true exit angle
    exitAngle = sign(inPlaneExitAngle)                                  ...
        .* acos( sqrt(d2POR.^2+(dPPt2Sample.*cos(inPlaneExitAngle)).^2) ...
              ./ sqrt(d2Beam0.^2+ccdimginfo.detector.distance^2))                         ;
    
    % phi map is actually qz map in reflection geometry
    ccdimginfo.phimap = single(2*pi/(12.398/ccdimginfo.measurement.instrument.source_begin.energy) ...
                      * (sin(incidentangle) + sin(exitAngle)))             ; 
    
    % qx map
    ccdimginfo.qxmap  = single(2*pi/(12.398/ccdimginfo.measurement.instrument.source_begin.energy) ...
                      * ( cos(incidentangle) - cos(exitAngle).*cos(outOfPlaneAngle) ) ) ;
    
    % qy map
    ccdimginfo.qymap  = single(2*pi/(12.398/ccdimginfo.measurement.instrument.source_begin.energy) ...
                      * cos(exitAngle).*sin(outOfPlaneAngle))              ;
    
    % parallel q map
    ccdimginfo.qmap   = single(sqrt( ccdimginfo.qxmap.^2                ...
                                   + ccdimginfo.qymap.^2) )                ;
    
    clear tilt inPlaneExitAngle dProjectedPt2Sample trueAlpha              ;
    clear outOfPlaneAngle exitAngle dDB2RB xDB2RB yDB2RB xRBpix yRBpix     ;
end
clear d2Beam0 xmm ymm dpix_x dpix_y xDBpix yDBpix                          ;
% =========================================================================
% --- finish mapping for transmission and reflection geometry
% =========================================================================



% =========================================================================
% --- save application data 'ccdimginfo' to main figure
% =========================================================================
if (nargout == 1)
    varargout{1}=ccdimginfo;
end
setappdata(hFigXPCSMain,'ccdimginfo',ccdimginfo)                           ;
clear hFigXPCSMain varargin                                     ;
% =========================================================================
% --- finish saving application data 'ccdimginfo' to main figure
% =========================================================================


% whos
% ---
% EOF
