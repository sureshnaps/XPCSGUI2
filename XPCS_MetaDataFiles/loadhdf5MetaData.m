function ccdimginfo = loadhdf5MetaData(file_input)
%this function is used instead of convert_batchinfo_loadhdf5MetaData when
%hdf5 file is directly used as the metadata file instead of taking the
%batchinfo file and creating hdf5 file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% XPCS7
% /implements = "measurement:xpcs"
% ccdimginfo.batchinfoversion = h5read(file,'/version');
% /measurement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
needed_for_analysis=0;%% saves if set to 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
combined_result_folder = 'cluster_results';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[filepath,info_name,ext]=fileparts(file_input);
%change hdf location from the data folder to a general cluster_results
%folder
[newfilepath,~,~]=fileparts(filepath);

if isempty(regexp(file_input,combined_result_folder,'once'))
    newfilepath = fullfile(newfilepath,combined_result_folder);
else %file is in cluster_results folder
    newfilepath = fullfile(newfilepath);
end
% if isempty(regexp(file_input,combined_result_folder,'once'))
%     newfilepath = fullfile(newfilepath,combined_result_folder);
% else %file is in cluster_results folder
%     newfilepath = filepath;
%     [filepath,~,~]=fileparts(newfilepath);
% end

if (exist(newfilepath,'dir') ~= 7)
    [success_dir,~,~]=mkdir(newfilepath);
    if (success_dir == 0)
        fprintf('Creating directory %s Failed\n',newfilepath);
        return;
    end
end
ccdimginfo.imgPath = filepath;
ccdimginfo.info_name=[info_name,ext];
ccdimginfo.fullpath_info_name=fullfile(newfilepath,[info_name,ext]);

file=ccdimginfo.fullpath_info_name;

if (exist(file,'file') == 0) %file does not exist
    try
        copyfile(file_input,file,'f');
    catch
        disp('Unable to Clone metadata .hdf file from data --> results folder, Exiting...');
        return;
    end
else
    disp('Metadata .hdf file exists in the results folder, continuing with analysis...');
end

%%
ccdimginfo.parent_folder=h5read(file,'/measurement/instrument/acquisition/parent_folder');
if iscellstr(ccdimginfo.parent_folder)
    ccdimginfo.parent_folder = ccdimginfo.parent_folder{1};
end

ccdimginfo.data_folder=h5read(file,'/measurement/instrument/acquisition/data_folder');
if iscellstr(ccdimginfo.data_folder)
    ccdimginfo.data_folder = ccdimginfo.data_folder{1};
end

ccdimginfo.datafilename=h5read(file,'/measurement/instrument/acquisition/datafilename');
if iscellstr(ccdimginfo.datafilename)
    ccdimginfo.datafilename = ccdimginfo.datafilename{1};
end

%%
fulldatafilename = fullfile(ccdimginfo.parent_folder,ccdimginfo.data_folder,ccdimginfo.datafilename);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ccdimginfo.bin.swbinX = h5read(file,'/measurement/instrument/detector/x_binning');
ccdimginfo.bin.swbinY = h5read(file,'/measurement/instrument/detector/y_binning');

foo_geometry = h5read(file,'/measurement/instrument/detector/geometry');
if ~iscellstr(foo_geometry)
    foo_geometry = cellstr(foo_geometry);
end
if ~isempty(regexp(foo_geometry{1},'TRANSMISSION','once'))
    ccdimginfo.geometry=0;
elseif ~isempty(regexp(foo_geometry{1},'REFLECTION','once'))
    ccdimginfo.geometry=1;
else
    disp('Unknown Scattering Geometry, Exiting...');
    return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%this section is to come up with a file path that will work for local
%analysis, not clear how to do for the user home computers
foo1_start = regexp(file,ccdimginfo.parent_folder,'once');
if iscell(foo1_start)
    foo1_start = foo1_start{1};
end
if ~iscellstr(fulldatafilename)
    ccdimginfo.xpcs.input_file_local{1}=fullfile(file(1:foo1_start(1)-1),fulldatafilename);
else
    ccdimginfo.xpcs.input_file_local=fullfile(file(1:foo1_start(1)-1),fulldatafilename);
end
clear foo1 foo1_start
%%
ccdimginfo.xpcs.input_file_remote={fulldatafilename};
ccdimginfo.xpcs.output_file_local={file};
ccdimginfo.xpcs.output_file_remote={'output/results'};%%for now, this is a fixed location for hadoop job
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
ccdimginfo.xpcs.specfile = h5read(file,'/measurement/instrument/acquisition/specfile');
if iscell(ccdimginfo.xpcs.specfile)
    ccdimginfo.xpcs.specfile = ccdimginfo.xpcs.specfile{1};
end
ccdimginfo.xpcs.spec_datascan_number = h5read(file,'/measurement/instrument/acquisition/specscan_data_number');

ccdimginfo.xpcs.compression = h5read(file,'/measurement/instrument/acquisition/compression');

ccdimginfo.xpcs.dpl = 4; %%default setting

ccdimginfo.xpcs.lld = h5read(file,'/measurement/instrument/detector/lld');
ccdimginfo.xpcs.rms_multiplier=h5read(file,'/measurement/instrument/detector/sigma');

ccdimginfo.xpcs.analysis_type = 'Multitau';

ccdimginfo.xpcs.batches = 1;
ccdimginfo.xpcs.data_begin = h5read(file,'/measurement/instrument/acquisition/data_begin');
ccdimginfo.xpcs.data_end = h5read(file,'/measurement/instrument/acquisition/data_end');

ccdimginfo.xpcs.data_begin_todo = ccdimginfo.xpcs.data_begin;
ccdimginfo.xpcs.data_end_todo = ccdimginfo.xpcs.data_end;

if ~isempty(regexp(ccdimginfo.xpcs.compression{1},'DISABLED','once'))
    ccdimginfo.xpcs.dark_begin = h5read(file,'/measurement/instrument/acquisition/dark_begin');
    ccdimginfo.xpcs.dark_end = h5read(file,'/measurement/instrument/acquisition/dark_end');
    ccdimginfo.xpcs.dark_begin_todo = ccdimginfo.xpcs.dark_begin;
    ccdimginfo.xpcs.dark_end_todo = ccdimginfo.xpcs.dark_end;
else
    ccdimginfo.xpcs.dark_begin = -1;
    ccdimginfo.xpcs.dark_end = -1;
    ccdimginfo.xpcs.dark_begin_todo = -1;
    ccdimginfo.xpcs.dark_end_todo = -1;
end

ccdimginfo.xpcs.stride_frames=1;
ccdimginfo.xpcs.avg_frames=1;

ccdimginfo.detector.gain=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%/measurement/geometry
if (needed_for_analysis)
    ccdimginfo.geometry.orientation = h5read(file,'/measurement/sample/geometry/orientation');
    ccdimginfo.geometry.translation = h5read(file,'/measurement/sample/geometry/translation');
end

%%/measurement/sample
ccdimginfo.measurement.sample.Temperature_A = h5read(file,'/measurement/sample/temperature_A');
ccdimginfo.measurement.sample.Temperature_B = h5read(file,'/measurement/sample/temperature_B');
ccdimginfo.measurement.sample.Set_Temperature_A = h5read(file,'/measurement/sample/temperature_A_set');
ccdimginfo.measurement.sample.Set_Temperature_B = h5read(file,'/measurement/sample/temperature_B_set');
try
    ccdimginfo.measurement.sample.thickness = h5read(file,'/measurement/sample/thickness');
catch
    ccdimginfo.measurement.sample.thickness = 1.0;
end

%%/measurement/instrument/source_begin
ccdimginfo.measurement.instrument.source_begin.datetime = h5read(file,'/measurement/instrument/source_begin/datetime');
if iscellstr(ccdimginfo.measurement.instrument.source_begin.datetime)
    ccdimginfo.measurement.instrument.source_begin.datetime = ccdimginfo.measurement.instrument.source_begin.datetime{1};
end
ccdimginfo.measurement.instrument.source_begin.current = h5read(file,'/measurement/instrument/source_begin/current');
ccdimginfo.measurement.instrument.source_begin.energy = h5read(file,'/measurement/instrument/source_begin/energy');
ccdimginfo.measurement.instrument.source_begin.transmitted_flux = h5read(file,'/measurement/instrument/source_begin/beam_intensity_transmitted');
ccdimginfo.measurement.instrument.source_begin.incident_flux = h5read(file,'/measurement/instrument/source_begin/beam_intensity_incident');

%%/measurement/instrument/source_end
% ccdimginfo.measurement.instrument.source_end.datetime = h5read(file,'/measurement/instrument/source_end/datetime');
% if iscellstr(ccdimginfo.measurement.instrument.source_end.datetime)
%     ccdimginfo.measurement.instrument.source_end.datetime = ccdimginfo.measurement.instrument.source_end.datetime{1};
% end
% ccdimginfo.measurement.instrument.source_end.current = h5read(file,'/measurement/instrument/source_end/current');
% ccdimginfo.measurement.instrument.source_end.energy = h5read(file,'/measurement/instrument/source_end/energy');
% ccdimginfo.measurement.instrument.source_end.transmitted_flux = h5read(file,'/measurement/instrument/source_end/beam_intensity_transmitted');
% ccdimginfo.measurement.instrument.source_end.incident_flux = h5read(file,'/measurement/instrument/source_end/beam_intensity_incident');

%%/measurement/instrument/acquisition                             ACQUISITION
ccdimginfo.acquisition.x0 = h5read(file,'/measurement/instrument/acquisition/beam_center_x');
ccdimginfo.acquisition.y0 = h5read(file,'/measurement/instrument/acquisition/beam_center_y');
ccdimginfo.acquisition.hgap = h5read(file,'/measurement/instrument/acquisition/beam_size_H');
ccdimginfo.acquisition.vgap = h5read(file,'/measurement/instrument/acquisition/beam_size_V');
ccdimginfo.acquisition.ccdx0 = h5read(file,'/measurement/instrument/acquisition/stage_zero_x');
ccdimginfo.acquisition.ccdz0 = h5read(file,'/measurement/instrument/acquisition/stage_zero_z');

ccdimginfo.acquisition.ccdx = h5read(file,'/measurement/instrument/acquisition/stage_x');
ccdimginfo.acquisition.ccdz = h5read(file,'/measurement/instrument/acquisition/stage_z');
ccdimginfo.acquisition.xspec = h5read(file,'/measurement/instrument/acquisition/xspec');
ccdimginfo.acquisition.yspec = h5read(file,'/measurement/instrument/acquisition/zspec');
ccdimginfo.acquisition.ccdxspec = h5read(file,'/measurement/instrument/acquisition/ccdxspec');
ccdimginfo.acquisition.ccdzspec = h5read(file,'/measurement/instrument/acquisition/ccdzspec');
ccdimginfo.acquisition.angle = h5read(file,'/measurement/instrument/acquisition/angle');

%%/measurement/instrument/detector                                DETECTOR
try
    ccdimginfo.detector.manufacturer = h5read(file,'/measurement/instrument/detector/manufacturer');
    if ~iscellstr(ccdimginfo.detector.manufacturer)
        ccdimginfo.detector.manufacturer = cellstr(ccdimginfo.detector.manufacturer);
    end
catch
    %seems like a hdf bug, this field always gets lost during copy
    foo_det_manufacturer = h5read(file_input,'/measurement/instrument/detector/manufacturer');
    writeh5str(file,'/measurement/instrument/detector/manufacturer',foo_det_manufacturer{1});    
end

ccdimginfo.detector.dpix_x = h5read(file,'/measurement/instrument/detector/x_pixel_size');
ccdimginfo.detector.dpix_y = h5read(file,'/measurement/instrument/detector/y_pixel_size');
ccdimginfo.detector.exposure_time = h5read(file,'/measurement/instrument/detector/exposure_time');
ccdimginfo.detector.exposure_period = h5read(file,'/measurement/instrument/detector/exposure_period');
ccdimginfo.detector.distance = h5read(file,'/measurement/instrument/detector/distance');
ccdimginfo.detector.efficiency = h5read(file,'/measurement/instrument/detector/efficiency');
ccdimginfo.detector.adu_per_photon = h5read(file,'/measurement/instrument/detector/adu_per_photon');

%rows and cols are replaced with sensor Rows and Cols to allow for roi size
%to be the rows and cols and are calculated from roi sizes below (March 2016)
%adding the full sensor size so ROI can be handled properly (March 2016)
ccdimginfo.detector.SensorSizeRows = h5read(file,'/measurement/instrument/detector/y_dimension');
ccdimginfo.detector.SensorSizeCols = h5read(file,'/measurement/instrument/detector/x_dimension');

%%/measurement/instrument/detector/roi
ccdimginfo.detector.x_begin = h5read(file,'/measurement/instrument/detector/roi/x1');
ccdimginfo.detector.y_begin = h5read(file,'/measurement/instrument/detector/roi/y1');
ccdimginfo.detector.x_end = h5read(file,'/measurement/instrument/detector/roi/x2');
ccdimginfo.detector.y_end = h5read(file,'/measurement/instrument/detector/roi/y2');

ccdimginfo.detector.rows = (ccdimginfo.detector.y_end - ccdimginfo.detector.y_begin +1);
ccdimginfo.detector.cols = (ccdimginfo.detector.x_end - ccdimginfo.detector.x_begin +1);
%%
%correct for the direct beam co-ords for FCCD when the DB was measured in
%the full frame mode and ROI was used to collect data (SN, Feb 11, 2015)
if ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'LBL', 'once')) )
    if (ccdimginfo.detector.rows == 92)
        y0_foo=ccdimginfo.acquisition.y0;
        y0_foo = (y0_foo - 962/2)+92/2;
        ccdimginfo.acquisition.y0=y0_foo;
    end
end
clear y0_foo;
%%
if (needed_for_analysis)
    ccdimginfo.detector.blemish_mask = h5read(file,'/measurement/instrument/detector/blemish_mask');
    ccdimginfo.detector.geometry = h5read(file,'/measurement/instrument/detector/geometry');
end

%%/measurement/instrument/detector/kinetics                       KINETICS
foo_kinetics_state = h5read(file,'/measurement/instrument/detector/kinetics_enabled');
if strcmp(foo_kinetics_state,'ENABLED')
    ccdimginfo.detector.kinetics.mode=1;
else
    ccdimginfo.detector.kinetics.mode=0;
end
if (needed_for_analysis)
    ccdimginfo.detector.kinetics.status = h5read(file,'/measurement/instrument/detector/kinetics/enabled');
end

ccdimginfo.detector.kinetics.window_size = h5read(file,'/measurement/instrument/detector/kinetics/window_size');
ccdimginfo.detector.kinetics.slice_top = h5read(file,'/measurement/instrument/detector/kinetics/top');
ccdimginfo.detector.kinetics.first_usable_slice = h5read(file,'/measurement/instrument/detector/kinetics/first_usable_window');
ccdimginfo.detector.kinetics.last_usable_slice = h5read(file,'/measurement/instrument/detector/kinetics/last_usable_window');
%%
%==========================================================================
% --- for kinetics mode, determine the first and last usable slices;
% --- & determine positions of each slice and save to ccdimginfo.sliceinfo
%==========================================================================
if ccdimginfo.detector.kinetics.mode == 1                                                  % kinetic mode
    ccdimginfo.detector.kinetics.first_usable_slice = 2                                              ;
    ccdimginfo.detector.kinetics.last_usable_slice  = floor((ccdimginfo.detector.y_end - ccdimginfo.detector.y_begin +1)/ccdimginfo.detector.kinetics.window_size);      
    shiftOffset           = ccdimginfo.detector.kinetics.slice_top-ccdimginfo.detector.y_end         ; % offset for the first used row (negative value!!!)
    sliceInfo             = zeros(numel(1 : ccdimginfo.detector.kinetics.last_usable_slice),2)       ;
    for iSlice = 1 : ccdimginfo.detector.kinetics.last_usable_slice
        sliceInfo(iSlice,1) = shiftOffset      ...
                            + (iSlice-1) * ccdimginfo.detector.kinetics.window_size           ; % bottom row of slice
        sliceInfo(iSlice,2) = shiftOffset - 1  ...
                            +  iSlice    * ccdimginfo.detector.kinetics.window_size           ; % top row of slice
    end
    if (ccdimginfo.detector.kinetics.last_usable_slice >=3 )
    	ccdimginfo.detector.kinetics.last_usable_slice = ccdimginfo.detector.kinetics.last_usable_slice -1                     ;
    end
    clear shiftOffset j
else                                                                         % full frame or roi mode
    ccdimginfo.detector.kinetics.first_usable_slice   = 0                                           ;
    ccdimginfo.detector.kinetics.last_usable_slice    = 0                                           ;
    sliceInfo(1,1)= ccdimginfo.detector.y_begin                                   ;
    sliceInfo(1,2)= ccdimginfo.detector.y_end                                     ;
end
ccdimginfo.detector.kinetics.sliceinfo = sliceInfo                                           ;
clear sliceInfo
%%
if ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'DALSA', 'once')) )
    temp_ccdimginfo.detector = 5;
elseif ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'SMD', 'once')) )
    temp_ccdimginfo.detector = 6;
elseif ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'Princeton', 'once')) )
    temp_ccdimginfo.detector = 13;
elseif ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'LBL', 'once')) )
    if (ccdimginfo.detector.adu_per_photon > 10) %%kludge for FCCD or certainly not Eiger
        temp_ccdimginfo.detector = 20;
    else
        temp_ccdimginfo.detector = 30; %Kludge for Eiger
    end
elseif ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'LAMBDA', 'once')) )
    temp_ccdimginfo.detector = 25;   
else
    disp('Unknown detector in the metadata file');
    return;
end
temp_ccdimginfo.rows = ccdimginfo.detector.rows;
temp_ccdimginfo.cols = ccdimginfo.detector.cols;

temp_ccdimginfo = detectorinfo(temp_ccdimginfo);
ccdimginfo.ccdxsense = temp_ccdimginfo.ccdxsense;
ccdimginfo.ccdzsense = temp_ccdimginfo.ccdzsense;

ccdimginfo.detector.blemish_status = h5read(file,'/measurement/instrument/detector/blemish_enabled');
try
    ccdimginfo.detector.flatfield_status = h5read(file,'/measurement/instrument/detector/flatfield_enabled');
catch
    ccdimginfo.detector.flatfield_status = {'DISABLED'};
end

%%/measurement/instrument/shutter                                 SHUTTER
% ccdimginfo.shutter.name = h5read(file,'/measurement/instrument/shutter/name');
% ccdimginfo.shutter.status = h5read(file,'/measurement/instrument/shutter/status');

%%/measurement/instrument/attenuator                              ATTENUATOR
% ccdimginfo.attenuator.thickness = h5read(file,'/measurement/instrument/attenuator/thickness');
% ccdimginfo.attenuator.transmission = h5read(file,'/measurement/instrument/attenuator/transmission');
% ccdimginfo.attenuator.type = h5read(file,'/measurement/instrument/attenuator/type');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%define some input defaults for q-partitions
ccdimginfo.partition.smethod(1)=1;
ccdimginfo.partition.smethod(2)=1;
ccdimginfo.partition.dmethod(1)=1;
ccdimginfo.partition.dmethod(2)=1;

if (ccdimginfo.geometry == 0) %%Transmission
    ccdimginfo.partition.snpt(1)=90;
    ccdimginfo.partition.snpt(2)=1;
    ccdimginfo.partition.dnpt(1)=18;
    ccdimginfo.partition.dnpt(2)=1;
    ccdimginfo.partition.name = {'q','phi'};

elseif (ccdimginfo.geometry == 1) %%Reflection
    if (ccdimginfo.detector.kinetics.mode == 0)
        ccdimginfo.partition.snpt(1)=54;
        ccdimginfo.partition.snpt(2)=60;
        ccdimginfo.partition.dnpt(1)=18;
        ccdimginfo.partition.dnpt(2)=1;
    else
        ccdimginfo.partition.snpt(1)=54;
        ccdimginfo.partition.snpt(2)=30;
        ccdimginfo.partition.dnpt(1)=18;
        ccdimginfo.partition.dnpt(2)=1;
    end
    ccdimginfo.partition.name = {'qr','qz'};
end

ccdimginfo.batchestodo=1;

ccdimginfo.savepath = fileparts(ccdimginfo.fullpath_info_name);

[~,ccdimginfo.name,~]=fileparts(ccdimginfo.info_name);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ccdimginfo = initializemask(ccdimginfo);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cmd=sprintf('Successfully Loaded DAQ MetaData from .batchinfo equivalent: %s',[info_name,ext]);
disp(cmd);
updatemessage(cmd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end




