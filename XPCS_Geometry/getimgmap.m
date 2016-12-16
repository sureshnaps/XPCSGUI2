function varargout = getimgmap(varargin)
% GETIMGMAP Map each pixel to q, phi, x, and y for transmission geometry,
%    or to q, phi, qz, qx, qy, qr, x, and y for reflection geometry.
%
%   Input: getimgmap(ccdimginfo) or getimgmap(ccdimginfo,plotflag).
%       plotflag = 0/1 is a flag to plot maps. Its default is 0 (not
%       plotting)
%
%   Output: Map matrices are exported under new field name ccdimginfo.maps
%
%   Note: Binning does not work for kinetics mode
%
% $Revision: 1.0 $Date: 2005/01/14 $ by Zhang Jiang
% $Revision: 1.1 $Date: 2005/10/11 $ by MS to incorporate different pixel
%       sizes in x & y direction (e.g. for the  tilted CMOS camera)
% $Revision: 1.2 $Date: 2006/08/23 $ by MS simplified mapping
% $Revision: 1.3 $Date: 2014/07/27 $ by ZJ include binning
% $Revision: 1.4 $Date: 2014/09/11 $ by ZJ independent function without
%       main XPCSGUI figure; modified from mapccdpixel.m
% $Revision: 1.5 $Date: 2015/01/13 $ by ZJ use matrix method

if nargin == 1
    ccdimginfo = varargin{1};
    plotflag = 0;
elseif nargin == 2
    ccdimginfo = varargin{1};
    plotflag = varargin{2};
    if ~isnumeric(plotflag) || (plotflag ~= 0 && plotflag  ~=1)
        error('Invalid plotflag.');
    end
else
    error('Invalid number of inputs.');
end

% --- some setup constants
wavelength = 12.398/ccdimginfo.measurement.instrument.source_begin.energy;
k = 2*pi/wavelength;
SDD = ccdimginfo.detector.distance;         % sample to detector distance (mm)
dpix_x = ccdimginfo.bin.detector.dpix_x;    % detector x pixel size (mm)
dpix_y = ccdimginfo.bin.detector.dpix_y;    % detector y pixel size (mm)

% --- get pixel positions for beam0 and specular beam (in fact a point in the center scattering plane)
xDBpix = ccdimginfo.bin.acquisition.x0 + ccdimginfo.ccdxsense * (ccdimginfo.acquisition.ccdx - ccdimginfo.acquisition.ccdx0) / dpix_x ;
yDBpix = ccdimginfo.bin.acquisition.y0 + ccdimginfo.ccdzsense * (ccdimginfo.acquisition.ccdz - ccdimginfo.acquisition.ccdz0) / dpix_y ;
if ( ccdimginfo.geometry == 1 )     % for reflection
    xRBpix = ccdimginfo.bin.acquisition.xspec + ccdimginfo.ccdxsense * (ccdimginfo.acquisition.ccdx - ccdimginfo.acquisition.ccdxspec) / dpix_x ;
    yRBpix = ccdimginfo.bin.acquisition.yspec + ccdimginfo.ccdzsense * (ccdimginfo.acquisition.ccdz - ccdimginfo.acquisition.ccdzspec) / dpix_y ;
end

% --- distances of each pixel to beam0 and sample
if ccdimginfo.detector.kinetics.mode == 0   % non-kinetics mode (full or roi mode)
    xpix = ccdimginfo.bin.detector.x_begin:ccdimginfo.bin.detector.x_end                           ;
    ypix = ccdimginfo.bin.detector.y_begin:ccdimginfo.bin.detector.y_end                           ;
elseif ccdimginfo.detector.kinetics.mode == 1   % no binning for kinetics mode
    xpix = ccdimginfo.detector.x_begin:ccdimginfo.detector.x_end;
    ypix = ccdimginfo.detector.kinetics.slice_top-ccdimginfo.detector.kinetics.window_size+1:ccdimginfo.detector.kinetics.slice_top;
end
rx     = ones(length(ypix),1) * (single(xpix) - xDBpix) * dpix_x;  % x distance of each pixel to Beam0
ry     = (single(ypix') - yDBpix) * dpix_y * ones(1,length(xpix)); % y distance of each pixel to Beam0
r_complex = rx + 1i*ry;     % complex pixel-beam0 distance
r = abs(r_complex);         % pixel-beam0 distance
R = sqrt(r.^2+SDD^2);       % pixel-sample distance

% --- x,y pixel mesh
[ccdimginfo.maps.x,ccdimginfo.maps.y] = meshgrid(1:length(xpix),1:length(ypix));
ccdimginfo.maps.x = single(ccdimginfo.maps.x);
ccdimginfo.maps.y = single(ccdimginfo.maps.y);

% --- q map
theta = atan(r/SDD);      % scattering angle
ccdimginfo.maps.q = single(2*k*sin(theta/2));

% --- calcualte maps
%  phi map for both transmission and reflection
if ccdimginfo.geometry == 0 % for transmission geometry: phi map
    ccdimginfo.maps.phi = single(unwrap(angle(r_complex)))*180/pi;
elseif ccdimginfo.geometry == 1 %  for reflection geometry: other maps and tilt-corrected phi map
    % incident angle [rad] (negative because of sector 8IDI's geometry)
    %make it abs to be safe (Oct 2016)
    incidentangle = abs(ccdimginfo.acquisition.angle); 
    specular = (yRBpix-yDBpix) + 1i*(xRBpix-xDBpix);
    chi = -(angle(specular)+pi/2);             % tilt angle
    r_complex = r_complex*exp(-1i*chi);     % rotate r to correct tilt
    ccdimginfo.maps.phi = single(unwrap(angle(r_complex))*180/pi);   % correct phi with respect to sample horizon  
   %ccdimginfo.maps.phi = single(angle(r_complex)*180/pi);   % correct phi with respect to sample horizon
    % assume detector is perpendicular to the beam
    gamma = atan(ry/SDD);
    delta = -atan(rx./sqrt(SDD^2+ry.^2));
    % incident wave vector in lab system
    kx_in = k;
    ky_in = 0;
    kz_in = 0;
    % scatterred wave vector in lab system
    kx_sc = k*cos(delta).*cos(gamma);
    ky_sc = k*cos(delta).*sin(gamma);
    kz_sc = k*sin(delta);
    % q maps in lab system
    qx = kx_sc - kx_in;
    qy = ky_sc - ky_in;
    qz = kz_sc - kz_in;
    % coordinate transformation matrix for the rotation of incident angle
    % the rotation angle is -alpha
    alpha = incidentangle*pi/180;
    Ry_rot = [
        cos(alpha)   0   sin(-alpha);
        0            1   0;
        -sin(-alpha) 0   cos(alpha)];
    % coordinate transformation matrix for the rotation of chi
    % rotation angle is chi
    Rx_rot = [
        1   0           0;
        0   cos(chi)    -sin(chi);
        0   sin(chi)    cos(chi);];
    % total tranform matrix
    R_rot = Ry_rot*Rx_rot;
    % calculate q maps in sample system
    [qx,qy,qz] = frametransform(R_rot,qx,qy,qz);
    ccdimginfo.maps.qz  = single(qz);
    ccdimginfo.maps.qx = single(qx);
    %non-signed qy and qr
    ccdimginfo.maps.qy  = abs(single(qy));
    ccdimginfo.maps.qr = single(sqrt(qx.^2+qy.^2));
    % signed qy and qr
%     ccdimginfo.maps.qy  = single(qy);
%     sign_idx = sign(ccdimginfo.maps.qy);
%     sign_idx(sign_idx==0) = 1;
%     ccdimginfo.maps.qr  = single(sign_idx.*sqrt(qx.^2+qy.^2));  % singed qr
    ccdimginfo.maps.exitAngle    = single(asin(qz/k - sin(alpha))*180/pi);
    ccdimginfo.maps.outOfPlaneAngle  = single(asin(qy/k./cos(ccdimginfo.maps.exitAngle*pi/180))*180/pi);
elseif ccdimginfo.geometry == 2 %  for wide angle xpcs or diffraction
    ccdimginfo.maps = rmfield(ccdimginfo.maps,'q');
    %to be defined
end

% --- plot maps
if plotflag == 1
    figure;
    if ccdimginfo.geometry == 0
        subplot(1,2,1);
        imagesc(ccdimginfo.maps.q);
        set(gca,'Ydir','norm');
        title('q')
        subplot(1,2,2)
        imagesc(ccdimginfo.maps.phi);
        set(gca,'Ydir','norm');
        title('phi')
    elseif ccdimginfo.geometry == 1
        maplist = {'q','phi','qz','qx','qy','qr','outOfPlaneAngle','exitAngle'};
        for ii=1:length(maplist)
            subplot(3,3,ii);
            imagesc(ccdimginfo.maps.(maplist{ii}));
            set(gca,'Ydir','norm');
            title(maplist{ii});
        end
    elseif ccdimginfo.geometry == 2 %wa xpcs
        %to be defined
    end
end

% --- output
if nargout == 1
    varargout{1} = ccdimginfo;
elseif nargout>1
    error('Invalid number of outputs.');
end



function [x1,y1,z1] = frametransform(T,x,y,z)
% FRAMETRANSFORM Rotate frame.
%   [X1,Y1,Z1] = FRAMETRANSFORM(T,X,Y,Z) calculates new vector (X1,Y1,Z1)
%   in the transformed Cartesian coordinate system. (X,Y,Z) is the vector
%   in in the old Cartesian coordinate system. R (3x3) is coordinate
%   transformation matrix. X,Y,Z can be arrays.

%   Zhang Jiang
%   $Revision: 1.0 $  $Date: 2012/07/27 $

T=inv(T);

x1 = T(1,1)*x + T(1,2)*y + T(1,3)*z;
y1 = T(2,1)*x + T(2,2)*y + T(2,3)*z;
z1 = T(3,1)*x + T(3,2)*y + T(3,3)*z;
