function create_MetaData_basic(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
full_hdf5_filename=varargin{1};
ccdimginfo=varargin{2};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fcpl = H5P.create('H5P_FILE_CREATE');
fapl = H5P.create('H5P_FILE_ACCESS');
if ~( (exist(full_hdf5_filename,'file')) && H5F.is_hdf5(full_hdf5_filename) )%%hdf5 file does not exist
    hdf_fid=H5F.create(full_hdf5_filename,'H5F_ACC_TRUNC',fcpl,fapl);
else
    %hdf5 already exists
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
property_list='H5P_DEFAULT';
xpcs_fid=H5F.open(full_hdf5_filename,'H5F_ACC_RDWR',property_list);

if ~( (exist(full_hdf5_filename,'file')==2) && H5F.is_hdf5(full_hdf5_filename) )%%hdf5 file does not exist
    gid1=H5G.create(xpcs_fid,'/measurement',property_list,property_list,property_list);
    gid2=H5G.create(xpcs_fid,'/measurement/sample',property_list,property_list,property_list);
    gid3=H5G.create(xpcs_fid,'/measurement/instrument',property_list,property_list,property_list);
    gid4=H5G.create(xpcs_fid,'/measurement/instrument/source_begin',property_list,property_list,property_list);
    gid5=H5G.create(xpcs_fid,'/measurement/instrument/acquisition',property_list,property_list,property_list);
    gid6=H5G.create(xpcs_fid,'/measurement/instrument/detector',property_list,property_list,property_list);
    gid7=H5G.create(xpcs_fid,'/measurement/instrument/detector/roi',property_list,property_list,property_list);
    gid8=H5G.create(xpcs_fid,'/measurement/instrument/detector/kinetics',property_list,property_list,property_list);
    H5F.close(hdf_fid);
end

if ~( (exist(full_hdf5_filename,'file')) && H5F.is_hdf5(full_hdf5_filename) )%%hdf5 file does not exist
    H5G.close(gid1);
    H5G.close(gid2);
    H5G.close(gid3);
    H5G.close(gid4);
    H5G.close(gid5);
    H5G.close(gid6);
    H5G.close(gid7);
    H5G.close(gid8);
end

H5F.close(xpcs_fid);

warning('OFF','MATLAB:imagesci:hdf5dataset:datatypeOutOfRange');

try
    h5write(full_hdf5_filename,'/measurement/sample/thickness',ccdimginfo.measurement.sample.thickness);
catch
    h5create(full_hdf5_filename,'/measurement/sample/thickness',size(ccdimginfo.measurement.sample.thickness));
    h5write(full_hdf5_filename,'/measurement/sample/thickness',ccdimginfo.measurement.sample.thickness);
end


try
    h5write(full_hdf5_filename,'/measurement/instrument/source_begin/current',ccdimginfo.measurement.instrument.source_begin.current);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/source_begin/current',size(ccdimginfo.measurement.instrument.source_begin.current));
    h5write(full_hdf5_filename,'/measurement/instrument/source_begin/current',ccdimginfo.measurement.instrument.source_begin.current);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/source_begin/energy',ccdimginfo.measurement.instrument.source_begin.energy);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/source_begin/energy',size(ccdimginfo.measurement.instrument.source_begin.energy));
    h5write(full_hdf5_filename,'/measurement/instrument/source_begin/energy',ccdimginfo.measurement.instrument.source_begin.energy);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/source_begin/beam_intensity_transmitted',ccdimginfo.measurement.instrument.source_begin.transmitted_flux);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/source_begin/beam_intensity_transmitted',size(ccdimginfo.measurement.instrument.source_begin.transmitted_flux));
    h5write(full_hdf5_filename,'/measurement/instrument/source_begin/beam_intensity_transmitted',ccdimginfo.measurement.instrument.source_begin.transmitted_flux);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/source_begin/beam_intensity_incident',ccdimginfo.measurement.instrument.source_begin.incident_flux);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/source_begin/beam_intensity_incident',size(ccdimginfo.measurement.instrument.source_begin.incident_flux));
    h5write(full_hdf5_filename,'/measurement/instrument/source_begin/beam_intensity_incident',ccdimginfo.measurement.instrument.source_begin.incident_flux);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/acquisition/beam_center_x',ccdimginfo.acquisition.x0);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/acquisition/beam_center_x',size(ccdimginfo.acquisition.x0));
    h5write(full_hdf5_filename,'/measurement/instrument/acquisition/beam_center_x',ccdimginfo.acquisition.x0);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/acquisition/beam_center_y',ccdimginfo.acquisition.y0);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/acquisition/beam_center_y',size(ccdimginfo.acquisition.y0));
    h5write(full_hdf5_filename,'/measurement/instrument/acquisition/beam_center_y',ccdimginfo.acquisition.y0);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/acquisition/stage_zero_x',ccdimginfo.acquisition.ccdx0);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/acquisition/stage_zero_x',size(ccdimginfo.acquisition.ccdx0));
    h5write(full_hdf5_filename,'/measurement/instrument/acquisition/stage_zero_x',ccdimginfo.acquisition.ccdx0);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/acquisition/stage_zero_z',ccdimginfo.acquisition.ccdz0);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/acquisition/stage_zero_z',size(ccdimginfo.acquisition.ccdz0));
    h5write(full_hdf5_filename,'/measurement/instrument/acquisition/stage_zero_z',ccdimginfo.acquisition.ccdz0);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/acquisition/stage_x',ccdimginfo.acquisition.ccdx);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/acquisition/stage_x',size(ccdimginfo.acquisition.ccdx));
    h5write(full_hdf5_filename,'/measurement/instrument/acquisition/stage_x',ccdimginfo.acquisition.ccdx);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/acquisition/stage_z',ccdimginfo.acquisition.ccdz);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/acquisition/stage_z',size(ccdimginfo.acquisition.ccdz));
    h5write(full_hdf5_filename,'/measurement/instrument/acquisition/stage_z',ccdimginfo.acquisition.ccdz);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/acquisition/xspec',ccdimginfo.acquisition.xspec);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/acquisition/xspec',size(ccdimginfo.acquisition.xspec));
    h5write(full_hdf5_filename,'/measurement/instrument/acquisition/xspec',ccdimginfo.acquisition.xspec);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/acquisition/zspec',ccdimginfo.acquisition.yspec);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/acquisition/zspec',size(ccdimginfo.acquisition.yspec));
    h5write(full_hdf5_filename,'/measurement/instrument/acquisition/zspec',ccdimginfo.acquisition.yspec);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/acquisition/angle',ccdimginfo.acquisition.angle);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/acquisition/angle',size(ccdimginfo.acquisition.angle));
    h5write(full_hdf5_filename,'/measurement/instrument/acquisition/angle',ccdimginfo.acquisition.angle);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(full_hdf5_filename,'/measurement/instrument/detector/x_pixel_size',ccdimginfo.detector.dpix_x);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/detector/x_pixel_size',size(ccdimginfo.detector.dpix_x));
    h5write(full_hdf5_filename,'/measurement/instrument/detector/x_pixel_size',ccdimginfo.detector.dpix_x);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/detector/y_pixel_size',ccdimginfo.detector.dpix_y);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/detector/y_pixel_size',size(ccdimginfo.detector.dpix_y));
    h5write(full_hdf5_filename,'/measurement/instrument/detector/y_pixel_size',ccdimginfo.detector.dpix_y);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/detector/y_dimension',ccdimginfo.detector.rows);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/detector/y_dimension',size(ccdimginfo.detector.rows),'Datatype','uint64');
    h5write(full_hdf5_filename,'/measurement/instrument/detector/y_dimension',ccdimginfo.detector.rows);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/detector/x_dimension',ccdimginfo.detector.cols);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/detector/x_dimension',size(ccdimginfo.detector.cols),'Datatype','uint64');
    h5write(full_hdf5_filename,'/measurement/instrument/detector/x_dimension',ccdimginfo.detector.cols);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/detector/exposure_time',ccdimginfo.detector.exposure_time);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/detector/exposure_time',size(ccdimginfo.detector.exposure_time));
    h5write(full_hdf5_filename,'/measurement/instrument/detector/exposure_time',ccdimginfo.detector.exposure_time);
end

% %%For now, update kinetics mode exposure time
% if (ccdimginfo.detector.kinetics.mode == 1)
%     h5write(full_hdf5_filename,'/measurement/instrument/detector/exposure_time',ccdimginfo.detector.exposure_time);
% end

try
    h5write(full_hdf5_filename,'/measurement/instrument/detector/distance',ccdimginfo.detector.distance);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/detector/distance',size(ccdimginfo.detector.distance));
    h5write(full_hdf5_filename,'/measurement/instrument/detector/distance',ccdimginfo.detector.distance);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/detector/efficiency',ccdimginfo.detector.efficiency);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/detector/efficiency',size(ccdimginfo.detector.efficiency));
    h5write(full_hdf5_filename,'/measurement/instrument/detector/efficiency',ccdimginfo.detector.efficiency);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/detector/adu_per_photon',ccdimginfo.detector.adu_per_photon);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/detector/adu_per_photon',size(ccdimginfo.detector.adu_per_photon));
    h5write(full_hdf5_filename,'/measurement/instrument/detector/adu_per_photon',ccdimginfo.detector.adu_per_photon);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/detector/gain',ccdimginfo.detector.gain);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/detector/gain',size(ccdimginfo.detector.gain));
    h5write(full_hdf5_filename,'/measurement/instrument/detector/gain',ccdimginfo.detector.gain);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/detector/roi/x1',ccdimginfo.detector.x_begin);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/detector/roi/x1',size(ccdimginfo.detector.x_begin),'Datatype','uint64');
    h5write(full_hdf5_filename,'/measurement/instrument/detector/roi/x1',ccdimginfo.detector.x_begin);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/detector/roi/x2',ccdimginfo.detector.x_end);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/detector/roi/x2',size(ccdimginfo.detector.x_end),'Datatype','uint64');
    h5write(full_hdf5_filename,'/measurement/instrument/detector/roi/x2',ccdimginfo.detector.x_end);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/detector/roi/y1',ccdimginfo.detector.y_begin);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/detector/roi/y1',size(ccdimginfo.detector.y_begin),'Datatype','uint64');
    h5write(full_hdf5_filename,'/measurement/instrument/detector/roi/y1',ccdimginfo.detector.y_begin);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/detector/roi/y2',ccdimginfo.detector.y_end);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/detector/roi/y2',size(ccdimginfo.detector.y_end),'Datatype','uint64');
    h5write(full_hdf5_filename,'/measurement/instrument/detector/roi/y2',ccdimginfo.detector.y_end);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/detector/kinetics/window_size',ccdimginfo.detector.kinetics.window_size);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/detector/kinetics/window_size',size(ccdimginfo.detector.kinetics.window_size),'Datatype','uint64');
    h5write(full_hdf5_filename,'/measurement/instrument/detector/kinetics/window_size',ccdimginfo.detector.kinetics.window_size);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/detector/kinetics/top',ccdimginfo.detector.kinetics.slice_top);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/detector/kinetics/top',size(ccdimginfo.detector.kinetics.slice_top),'Datatype','uint64');
    h5write(full_hdf5_filename,'/measurement/instrument/detector/kinetics/top',ccdimginfo.detector.kinetics.slice_top);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/detector/kinetics/first_usable_window',ccdimginfo.detector.kinetics.first_usable_slice);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/detector/kinetics/first_usable_window',size(ccdimginfo.detector.kinetics.first_usable_slice),'Datatype','uint64');
    h5write(full_hdf5_filename,'/measurement/instrument/detector/kinetics/first_usable_window',ccdimginfo.detector.kinetics.first_usable_slice);
end

try
    h5write(full_hdf5_filename,'/measurement/instrument/detector/kinetics/last_usable_window',ccdimginfo.detector.kinetics.last_usable_slice);
catch
    h5create(full_hdf5_filename,'/measurement/instrument/detector/kinetics/last_usable_window',size(ccdimginfo.detector.kinetics.last_usable_slice),'Datatype','uint64');
    h5write(full_hdf5_filename,'/measurement/instrument/detector/kinetics/last_usable_window',ccdimginfo.detector.kinetics.last_usable_slice);
end

%flatfield matrix
if ( strcmpi(ccdimginfo.detector.manufacturer{1},'LAMBDA') || strcmpi(ccdimginfo.detector.manufacturer,'LAMBDA') )
    foo1 = load('Flatfield_AsKa_Th5p5keV.mat');
    %note that flatfield has to be transposed to be saved to HDF5 file%%
    try
        h5write(full_hdf5_filename,'/measurement/instrument/detector/flatfield',transpose(foo1.flatField));
    catch
        h5create(full_hdf5_filename,'/measurement/instrument/detector/flatfield',size(transpose(foo1.flatField)));
        h5write(full_hdf5_filename,'/measurement/instrument/detector/flatfield',transpose(foo1.flatField));
    end
    clear foo1;
end

writeh5str(full_hdf5_filename,'/measurement/instrument/detector/manufacturer',ccdimginfo.detector.manufacturer{1});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Python script to enter GUP info onto the hdf5 metadata file (broken due to
%username/password issues, to be resolved by SSG)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cmd=sprintf('/APSshare/epd/rh6-x86_64/bin/python /home/beams/8IDIUSER/XPCSUI/beamlineSchedulerLookup.py -b 8-ID-I -f %s\n',full_hdf5_filename);
% system(cmd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end