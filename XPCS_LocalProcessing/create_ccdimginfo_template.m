%%
ccdimginfo.measurement.instrument.source_begin.energy = 10; %in keV
ccdimginfo.detector.distance= 4900;

ccdimginfo.acquisition.x0 = 31;
ccdimginfo.acquisition.y0 = 21;

fccdx0=-89.0;
fccdz0=2.5;

fccdx=-76.5;
fccdz=2.5;


% ccdimginfo.partition.snpt=[60,1];
% ccdimginfo.partition.dnpt=[9,1];

ccdimginfo.detector.manufacturer = {'VIPIC_64'};
ccdimginfo.detector.blemish_status = {'DISABLED'};

ccdimginfo.bin.detector.dpix_x=0.08;
ccdimginfo.bin.detector.dpix_y=0.08;


ccdimginfo.ccdxsense = +1;
ccdimginfo.ccdzsense = +1;

ccdimginfo.geometry=0;

ccdimginfo.detector.rows=64;
ccdimginfo.detector.cols=64;

%%
ccdimginfo.acquisition.ccdx0 = fccdz0;
ccdimginfo.acquisition.ccdz0 = fccdx0;

ccdimginfo.acquisition.ccdx = fccdz;
ccdimginfo.acquisition.ccdz = fccdx;



ccdimginfo.detector.kinetics.mode = 0;


ccdimginfo.detector.x_begin = 0;
ccdimginfo.detector.x_end = ccdimginfo.detector.cols -1;

ccdimginfo.detector.y_begin = 0;
ccdimginfo.detector.y_end = ccdimginfo.detector.rows -1;

ccdimginfo.bin.swbinX=1;
ccdimginfo.bin.swbinY=1;

ccdimginfo.bin.acquisition.x0 = ccdimginfo.acquisition.x0;
ccdimginfo.bin.acquisition.y0 = ccdimginfo.acquisition.y0;


ccdimginfo.bin.acquisition.ccdx0 = ccdimginfo.acquisition.ccdx0;
ccdimginfo.bin.acquisition.ccdz0 = ccdimginfo.acquisition.ccdz0;

ccdimginfo.bin.acquisition.ccdx = ccdimginfo.acquisition.ccdx;
ccdimginfo.bin.acquisition.ccdz = ccdimginfo.acquisition.ccdz;

ccdimginfo.bin.detector.x_begin = ccdimginfo.detector.x_begin;
ccdimginfo.bin.detector.x_end = ccdimginfo.detector.x_end;

ccdimginfo.bin.detector.y_begin = ccdimginfo.detector.y_begin;
ccdimginfo.bin.detector.y_end = ccdimginfo.detector.y_end;

ccdimginfo.bin.detector.rows = ccdimginfo.detector.rows;
ccdimginfo.bin.detector.cols = ccdimginfo.detector.cols;


ccdimginfo.mask.usermask=true(ccdimginfo.detector.rows,...
    ccdimginfo.detector.cols);

