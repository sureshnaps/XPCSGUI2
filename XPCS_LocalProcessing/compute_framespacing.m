function framespacing = compute_framespacing(varargin)
%find frame spacing from time stamps or exposure time, as deemed appropriate

framespacinginfo = varargin{1};

try
    stride_frames=framespacinginfo.xpcs.stride_frames;
catch
    stride_frames=1;
end

try
    avg_frames=framespacinginfo.xpcs.avg_frames;
catch
    avg_frames=1;
end

new_framespacing_factor = double(stride_frames) .* double(avg_frames);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    camera_make=framespacinginfo.detector.manufacturer;
    if iscellstr(camera_make)
        camera_make=camera_make{1};
    end
    if ~isempty(regexpi(camera_make,'PI Princeton Instruments','once'))
        framespacing = mean(diff(framespacinginfo.xpcs.timeStamps{1}(2:end-1)));
    end
    if ~isempty(regexp(camera_make,'FastCCD','once')) && ...
            (framespacinginfo.detector.adu_per_photon > 10) %%kludge to detect FCCD vs counting det
        framespacing = framespacinginfo.detector.exposure_time;
    end
    framespacing = framespacing .* new_framespacing_factor;
catch
    framespacing=1.0;
end


end