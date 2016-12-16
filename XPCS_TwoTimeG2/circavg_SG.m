function SG = circavg_SG(varargin)
%%
hdf5_filename=varargin{1};
AvgData = varargin{2};

xDB0=h5read(hdf5_filename,'/measurement/instrument/acquisition/beam_center_x');

yDB0=h5read(hdf5_filename,'/measurement/instrument/acquisition/beam_center_y');

x_dpix=h5read(hdf5_filename,'/measurement/instrument/detector/x_pixel_size');

y_dpix=h5read(hdf5_filename,'/measurement/instrument/detector/y_pixel_size');


ccdx0=h5read(hdf5_filename,'/measurement/instrument/acquisition/stage_zero_x');

ccdz0=h5read(hdf5_filename,'/measurement/instrument/acquisition/stage_zero_z');


ccdx=h5read(hdf5_filename,'/measurement/instrument/acquisition/stage_x');

ccdz=h5read(hdf5_filename,'/measurement/instrument/acquisition/stage_z');

mask=transpose(h5read(hdf5_filename,'/xpcs/mask'));


%%PI
if ( ~isempty(regexp(h5read(hdf5_filename,'/measurement/instrument/detector/manufacturer'),'Princeton', 'once')) )
    ccdxsense = -1;
    ccdzsense = -1;
elseif ( ~isempty(regexp(h5read(hdf5_filename,'/measurement/instrument/detector/manufacturer'),'DALSA', 'once')) )
    ccdxsense = +1;
    ccdzsense = -1;
elseif ( ~isempty(regexp(h5read(hdf5_filename,'/measurement/instrument/detector/manufacturer'),'LBL', 'once')) && ...
        h5read(hdf5_filename,'/measurement/instrument/detector/adu_per_photon') > 10) %%FCCD2
    ccdxsense = +1;
    ccdzsense = -1;
elseif ( ~isempty(regexp(h5read(hdf5_filename,'/measurement/instrument/detector/manufacturer'),'LBL', 'once')) && ...
        h5read(hdf5_filename,'/measurement/instrument/detector/adu_per_photon') < 10) %%EIGER
    ccdxsense = +1;
    ccdzsense = +1;
else
    ccdxsense = -1;
    ccdzsense = -1;
end


% load /clhome/XPCS8/matlab/TwoTimeG2/avgdata_pi.mat; %%AvgData from a sample
% load /clhome/XPCS8/matlab/TwoTimeG2/avgdata_dalsa.mat; %%AvgData from a sample
%% define q and circular averages
ncols=size(AvgData,2);nrows=size(AvgData,1);
[X,Y]= meshgrid(1:ncols,1:nrows);

x0 = xDB0 + ccdxsense * (ccdx - ccdx0)/x_dpix;
y0 = yDB0 + ccdzsense * (ccdz - ccdz0)/y_dpix;

cen=[x0, y0];
R=hypot(X-cen(1),Y-cen(2));

w=find(mask);
rr=R(w);

radius_bin_step=5;
bins=min(rr)+radius_bin_step:max(1,radius_bin_step):max(rr)-radius_bin_step;

[h,b]=histc(rr,bins);
bins=bins(1:end-1);

c=accumarray(b+1,AvgData(w)');

Sq=c(2:end)./max(1,h(1:end-1));

% figure(11);semilogy(bins,Sq);axis xy

SG=zeros(size(AvgData));
SG(w)=interp1(bins,Sq,rr);

% figure(12);imagesc(SG);axis xy

end