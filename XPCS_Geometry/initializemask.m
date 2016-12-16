function ccdimginfo = initializemask(ccdimginfo)

ccdimginfo.bin.detector     = ccdimginfo.detector;
ccdimginfo.bin.acquisition  = ccdimginfo.acquisition;
ccdimginfo.bin.acquisition.x0 = (ccdimginfo.acquisition.x0-0.5)/double(ccdimginfo.bin.swbinX)+0.5;
ccdimginfo.bin.acquisition.y0 = (ccdimginfo.acquisition.y0-0.5)/double(ccdimginfo.bin.swbinY)+0.5;
ccdimginfo.bin.acquisition.xspec = (ccdimginfo.acquisition.xspec-0.5)/double(ccdimginfo.bin.swbinX)+0.5;
ccdimginfo.bin.acquisition.yspec = (ccdimginfo.acquisition.yspec-0.5)/double(ccdimginfo.bin.swbinY)+0.5;
ccdimginfo.bin.detector.dpix_x = double(ccdimginfo.bin.swbinX)*ccdimginfo.detector.dpix_x;
ccdimginfo.bin.detector.dpix_y = double(ccdimginfo.bin.swbinY)*ccdimginfo.detector.dpix_y;
ccdimginfo.bin.detector.rows = floor(ccdimginfo.detector.rows/ccdimginfo.bin.swbinY);
ccdimginfo.bin.detector.cols = floor(ccdimginfo.detector.cols/ccdimginfo.bin.swbinX);
ccdimginfo.bin.detector.x_begin = 0;
ccdimginfo.bin.detector.x_end = ccdimginfo.bin.detector.cols-1;
ccdimginfo.bin.detector.y_begin = 0;
ccdimginfo.bin.detector.y_end = ccdimginfo.bin.detector.rows-1;


% --- define mask points for the whole slice/image
xpixels = ccdimginfo.bin.detector.x_end-ccdimginfo.bin.detector.x_begin+1                      ;

if (ccdimginfo.detector.kinetics.mode==1)
    ypixels = ccdimginfo.detector.kinetics.window_size                                    ;
else
    ypixels = ccdimginfo.bin.detector.y_end-ccdimginfo.bin.detector.y_begin+1                  ;
end


% --- define the default (1/0) mask
ccdimginfo.mask.defaultmask = true(ypixels,xpixels)                    ;
ccdimginfo.mask.usermask = ccdimginfo.mask.defaultmask;
clear xpixels ypixels                                                  ;

