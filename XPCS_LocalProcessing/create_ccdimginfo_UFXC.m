%%
%%
%data from lurio201512/dbeam1_001/ with beam stop in place
x0 = 137.515;
y0 = 63.484;
ccdx0=-160.65;
ccdz0=-99.0;

%%
ccdimginfo.measurement.instrument.source_begin.energy = 7.385; %in keV
ccdimginfo.detector.distance= 3900;

ccdimginfo.acquisition.x0 = x0;
ccdimginfo.acquisition.y0 = y0;

% 
% ccdx=-185.0;
% ccdz=-105.0;

ccdimginfo.detector.manufacturer = {'UFXC_256_128'};
ccdimginfo.detector.blemish_status = {'DISABLED'};

ccdimginfo.bin.detector.dpix_x=0.075;
ccdimginfo.bin.detector.dpix_y=0.075;

%this was changed as per lurio201512/ccdx(z)senseplus2mm_001
ccdimginfo.ccdxsense = -1;
ccdimginfo.ccdzsense = +1;

ccdimginfo.geometry=0;

ccdimginfo.detector.rows=128;
ccdimginfo.detector.cols=256;

%%
ccdimginfo.acquisition.ccdx0 = ccdz0;
ccdimginfo.acquisition.ccdz0 = ccdx0;

ccdimginfo.acquisition.ccdx = ccdz;
ccdimginfo.acquisition.ccdz = ccdx;



ccdimginfo.detector.kinetics.mode = 0;


ccdimginfo.detector.x_begin = 0;
ccdimginfo.detector.x_end = ccdimginfo.detector.cols -1;

ccdimginfo.detector.y_begin = 0;
ccdimginfo.detector.y_end = ccdimginfo.detector.rows -1;

ccdimginfo.bin.swbinX=1;
ccdimginfo.bin.swbinY=1;

ccdimginfo.bin.acquisition.x0 = ccdimginfo.acquisition.x0;
ccdimginfo.bin.acquisition.y0 = ccdimginfo.acquisition.y0;


ccdimginfo.bin.acquisition.ccdx0 = ccdimginfo.acquisition.ccdz0;
ccdimginfo.bin.acquisition.ccdz0 = ccdimginfo.acquisition.ccdx0;

ccdimginfo.bin.acquisition.ccdx = ccdimginfo.acquisition.ccdz;
ccdimginfo.bin.acquisition.ccdz = ccdimginfo.acquisition.ccdx;

ccdimginfo.bin.detector.x_begin = ccdimginfo.detector.x_begin;
ccdimginfo.bin.detector.x_end = ccdimginfo.detector.x_end;

ccdimginfo.bin.detector.y_begin = ccdimginfo.detector.y_begin;
ccdimginfo.bin.detector.y_end = ccdimginfo.detector.y_end;

ccdimginfo.bin.detector.rows = ccdimginfo.detector.rows;
ccdimginfo.bin.detector.cols = ccdimginfo.detector.cols;


ccdimginfo.mask.usermask=true(ccdimginfo.detector.rows,...
    ccdimginfo.detector.cols);

