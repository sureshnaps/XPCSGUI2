function ccdimginfo = convert_batchinfo_loadhdf5MetaData(file)
%this function is used instead of loadhdf5MetaData when batchinfo file is
%used to create a hdf5 metadata file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% XPCS7

% /implements = "measurement:xpcs"
% ccdimginfo.batchinfoversion = h5read(file,'/version');
% /measurement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
needed_for_analysis=0;%% saves if set to 1
nBatch=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
combined_result_folder = 'cluster_results';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[filepath,info_name,~]=fileparts(file);
%change hdf location from the data folder to a general cluster_results
%folder
[newfilepath,~,~]=fileparts(filepath);
newfilepath = fullfile(newfilepath,combined_result_folder);
if (exist(newfilepath,'dir') ~= 7)
    [success_dir,~,~]=mkdir(newfilepath);
    if (success_dir == 0)
        fprintf('Creating directory %s Failed\n',newfilepath);
        return;
    end
end
ext='.hdf';
ccdimginfo.info_name=[info_name,ext];
ccdimginfo.fullpath_info_name=fullfile(newfilepath,[info_name,ext]);

file=ccdimginfo.fullpath_info_name;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%need some params from batchinfo file for now, needs to be fixed later
batchinfofile=dir(fullfile(filepath,'*.batchinfo'));
batchinfofile=fullfile(filepath,batchinfofile(1).name);
tmp=loadbatchinfo(batchinfofile,1);

% bin
ccdimginfo.bin.swbinX = tmp.swbinX;
ccdimginfo.bin.swbinY = tmp.swbinY;

%%added temp., fix in XML later
ccdimginfo.geometry=tmp.geometry;
ccdimginfo.ccdxsense=tmp.ccdxsense;
ccdimginfo.ccdzsense=tmp.ccdzsense;

foo=strfind(tmp.parent,'/');
if (foo(end)==numel(tmp.parent))
    [~,ccdimginfo.parent_folder,~]=fileparts(tmp.parent(1:end-1));
else
    [~,ccdimginfo.parent_folder,~]=fileparts(tmp.parent);
end
clear foo;

[ccdimginfo.data_folder,~,~]=fileparts(tmp.child);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ccdimginfo.xpcs.input_file_local{1}=tmp.imagefile{nBatch};
[~,immfilename,immfileext]=fileparts(tmp.imagefile{nBatch});
% ccdimginfo.xpcs.input_file_remote={fullfile('/user/xpcs8/',ccdimginfo.parent_folder,ccdimginfo.data_folder,[immfilename,immfileext])};
ccdimginfo.xpcs.input_file_remote={fullfile(ccdimginfo.parent_folder,ccdimginfo.data_folder,[immfilename,immfileext])};
ccdimginfo.xpcs.output_file_local={file};
ccdimginfo.xpcs.output_file_remote={'output/results'};%%for now, this is a fixed relative location for hadoop job
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
foo=strfind(tmp.specfile,'"');
if (numel(foo) == 2)
    ccdimginfo.xpcs.specfile = tmp.specfile(foo(1)+1:foo(2)-1);
else
    ccdimginfo.xpcs.specfile = tmp.specfile(3:end-1);
end
ccdimginfo.xpcs.spec_datascan_number = tmp.data_scanN;

if (tmp.compression==1)
    ccdimginfo.xpcs.compression = {'ENABLED'};
else
    ccdimginfo.xpcs.compression = {'DISABLED'};
end

if (tmp.mode == 2)
    ccdimginfo.xpcs.file_mode = {'MULTI'};
else
    ccdimginfo.xpcs.file_mode = {'SINGLE'};
end

ccdimginfo.xpcs.dpl = tmp.dpl;
if (tmp.lld < 0)
    ccdimginfo.xpcs.lld = abs(tmp.lld);
    ccdimginfo.xpcs.rms_multiplier=0;
else
    ccdimginfo.xpcs.lld=0;
    ccdimginfo.xpcs.rms_multiplier = abs(tmp.lld);
end

ccdimginfo.xpcs.analysis_type = 'Multitau';
if strcmpi(ccdimginfo.xpcs.analysis_type,'DYNAMIC') || ...
        strcmpi(ccdimginfo.xpcs.analysis_type,'Multitau')
    ccdimginfo.analysistype=1;
else
    ccdimginfo.analysistype=0;
end

ccdimginfo.xpcs.batches = 1;
ccdimginfo.xpcs.data_begin = tmp.ndata0(nBatch);
ccdimginfo.xpcs.data_end = tmp.ndataend(nBatch);
ccdimginfo.xpcs.data_begin_todo = tmp.ndata0todo(nBatch);
ccdimginfo.xpcs.data_end_todo = tmp.ndataendtodo(nBatch);

if (tmp.compression==0)
    ccdimginfo.xpcs.dark_begin = tmp.ndark0(nBatch);
    ccdimginfo.xpcs.dark_end = tmp.ndarkend(nBatch);
    ccdimginfo.xpcs.dark_begin_todo = tmp.ndark0todo(nBatch);
    ccdimginfo.xpcs.dark_end_todo = tmp.ndarkendtodo(nBatch);
else
    ccdimginfo.xpcs.dark_begin = -1;
    ccdimginfo.xpcs.dark_end = -1;
    ccdimginfo.xpcs.dark_begin_todo = -1;
    ccdimginfo.xpcs.dark_end_todo = -1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ccdimginfo.xpcs.stride_frames=1;
ccdimginfo.xpcs.avg_frames=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % ccdimginfo.xpcs.mask = h5read(file,'/xpcs/mask');
% % ccdimginfo.xpcs.dqmap = h5read(file,'/xpcs/dqmap');
% % ccdimginfo.xpcs.sqmap = h5read(file,'/xpcs/sqmap');
% % ccdimginfo.xpcs.dphimap = h5read(file,'/xpcs/dphimap');
% % ccdimginfo.xpcs.sphimap = h5read(file,'/xpcs/sphimap');
% % ccdimginfo.xpcs.dqspan = h5read(file,'/xpcs/dqspan');
% % ccdimginfo.xpcs.dphispan = h5read(file,'/xpcs/dphispan');
% % ccdimginfo.xpcs.sqspan = h5read(file,'/xpcs/sqspan');
% % ccdimginfo.xpcs.sphispan = h5read(file,'/xpcs/sphispan');
% % ccdimginfo.xpcs.sqlist = h5read(file,'/xpcs/sqlist');
% % ccdimginfo.xpcs.dqlist = h5read(file,'/xpcs/dqlist');
% % ccdimginfo.xpcs.sphilist = h5read(file,'/xpcs/sphilist');
% % ccdimginfo.xpcs.dphilist = h5read(file,'/xpcs/dphilist');
% % ccdimginfo.xpcs.normalization_method = h5read(file,'/xpcs/normalization_method');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% /measurement/sample                                             SAMPLE
if (needed_for_analysis)
    ccdimginfo.sample.name = h5read(file,'/measurement/sample/name');
    ccdimginfo.sample.description = h5read(file,'/measurement/sample/description');
    ccdimginfo.sample.preparation_date = h5read(file,'/measurement/sample/preparation_date');
end

%/measurement/sample/experiment
if (needed_for_analysis)
    ccdimginfo.experiment.proposalID = h5read(file,'/measurement/sample/experiment/proposal');
    ccdimginfo.experiment.activityID = h5read(file,'/measurement/sample/experiment/activity');
    ccdimginfo.experiment.safetyID = h5read(file,'/measurement/sample/experiment/safety');
end

%%/measurement/sample/experimenter
if (needed_for_analysis)
    ccdimginfo.experimenter.name = h5read(file,'/measurement/sample/experimenter/name');
    ccdimginfo.experimenter.role = h5read(file,'/measurement/sample/experimenter/role');
    ccdimginfo.experimenter.affiliation = h5read(file,'/measurement/sample/experimenter/affiliation');
    ccdimginfo.experimenter.address = h5read(file,'/measurement/sample/experimenter/address');
    ccdimginfo.experimenter.phone = h5read(file,'/measurement/sample/experimenter/phone');
    ccdimginfo.experimenter.email = h5read(file,'/measurement/sample/experimenter/email');
    ccdimginfo.experimenter.facility_user_id = h5read(file,'/measurement/sample/experimenter/facility_user_id');
end

% %%/measurement/geometry
if (needed_for_analysis)
    ccdimginfo.geometry.orientation = h5read(file,'/measurement/sample/geometry/orientation');
    ccdimginfo.geometry.orientation = h5read(file,'/measurement/sample/geometry/translation');
end

%%/measurement/sample
if (needed_for_analysis)
    ccdimginfo.measurement.sample.Temperature_A = h5read(file,'/measurement/sample/temperature_A');
    ccdimginfo.measurement.sample.Temperature_B = h5read(file,'/measurement/sample/temperature_B');
    ccdimginfo.measurement.sample.Set_Temperature_A = h5read(file,'/measurement/sample/temperature_A_set');
    ccdimginfo.measurement.sample.Set_Temperature_B = h5read(file,'/measurement/sample/temperature_B_set');
    ccdimginfo.measurement.sample.thickness = h5read(file,'/measurement/sample/thickness');
end
ccdimginfo.measurement.sample.thickness = 1.0;
    
%%/measurement/instrument
if (needed_for_analysis)
    ccdimginfo.measurement.instrument.name = h5read(file,'/measurement/instrument/name');
end

%%/measurement/instrument/source_begin
if (needed_for_analysis)
    ccdimginfo.measurement.instrument.source_begin.name = h5read(file,'/measurement/instrument/source_begin/name');
    ccdimginfo.measurement.instrument.source_begin.datetime = h5read(file,'/measurement/instrument/source_begin/datetime');
    ccdimginfo.measurement.instrument.source_begin.beamline = h5read(file,'/measurement/instrument/source_begin/beamline');
    ccdimginfo.measurement.instrument.source_begin.distance = h5read(file,'/measurement/instrument/source_begin/distance');
    ccdimginfo.measurement.instrument.source_begin.current = h5read(file,'/measurement/instrument/source_begin/current');
    ccdimginfo.measurement.instrument.source_begin.energy = h5read(file,'/measurement/instrument/source_begin/energy');
    ccdimginfo.measurement.instrument.source_begin.pulse_energy = h5read(file,'/measurement/instrument/source_begin/pulse_energy');
    ccdimginfo.measurement.instrument.source_begin.pulse_width = h5read(file,'/measurement/instrument/source_begin/pulse_width');
    ccdimginfo.measurement.instrument.source_begin.mode = h5read(file,'/measurement/instrument/source_begin/mode');
    ccdimginfo.measurement.instrument.source_begin.transmitted_flux = h5read(file,'/measurement/instrument/source_begin/beam_intensity_transmitted');
    ccdimginfo.measurement.instrument.source_begin.incident_flux = h5read(file,'/measurement/instrument/source_begin/beam_intensity_incident');
end
ccdimginfo.measurement.instrument.source_begin.current = tmp.ring_i_beg(nBatch);
ccdimginfo.measurement.instrument.source_begin.energy = tmp.energy;
ccdimginfo.measurement.instrument.source_begin.transmitted_flux = tmp.beam_i(nBatch);
ccdimginfo.measurement.instrument.source_begin.incident_flux = tmp.beam_i_vacuum(nBatch);

%%/measurement/instrument/source_end
if (needed_for_analysis)
    ccdimginfo.measurement.instrument.source_end.name = h5read(file,'/measurement/instrument/source_end/name');
    ccdimginfo.measurement.instrument.source_end.datetime = h5read(file,'/measurement/instrument/source_end/datetime');
    ccdimginfo.measurement.instrument.source_end.beamline = h5read(file,'/measurement/instrument/source_end/beamline');
    ccdimginfo.measurement.instrument.source_end.distance = h5read(file,'/measurement/instrument/source_end/distance');
    ccdimginfo.measurement.instrument.source_end.current = h5read(file,'/measurement/instrument/source_end/current');
    ccdimginfo.measurement.instrument.source_end.energy = h5read(file,'/measurement/instrument/source_end/energy');
    ccdimginfo.measurement.instrument.source_end.pulse_energy = h5read(file,'/measurement/instrument/source_end/pulse_energy');
    ccdimginfo.measurement.instrument.source_end.pulse_width = h5read(file,'/measurement/instrument/source_end/pulse_width');
    ccdimginfo.measurement.instrument.source_end.name = h5read(file,'/measurement/instrument/source_end/mode');
    ccdimginfo.measurement.instrument.source_end.transmitted_flux = h5read(file,'/measurement/instrument/source_end/beam_intensity_transmitted');
    ccdimginfo.measurement.instrument.source_end.incident_flux = h5read(file,'/measurement/instrument/source_end/beam_intensity_incident');
end

%%/measurement/instrument/acquisition                             ACQUISITION
ccdimginfo.acquisition.x0 = tmp.x0;
ccdimginfo.acquisition.y0 = tmp.y0;
ccdimginfo.acquisition.hgap = tmp.hgap;
ccdimginfo.acquisition.vgap = tmp.vgap;
ccdimginfo.acquisition.ccdx0 = tmp.ccdx0;
ccdimginfo.acquisition.ccdz0 = tmp.ccdz0;

ccdimginfo.acquisition.ccdx = tmp.ccdx;
ccdimginfo.acquisition.ccdz = tmp.ccdz;

ccdimginfo.acquisition.xspec = tmp.xspec;
ccdimginfo.acquisition.yspec = tmp.yspec;
ccdimginfo.acquisition.ccdxspec = tmp.ccdxspec;
ccdimginfo.acquisition.ccdzspec = tmp.ccdzspec;
ccdimginfo.acquisition.angle = tmp.nominal_angle;

%%/measurement/instrument/detector                                DETECTOR
if (tmp.detector == 8) || (tmp.detector == 13)
    ccdimginfo.detector.manufacturer = {'PI Princeton Instruments'};
elseif ( (tmp.detector == 5) || (tmp.detector == 6) )
    ccdimginfo.detector.manufacturer={'DALSA'};
elseif ( (tmp.detector == 15) || (tmp.detector == 20) || (tmp.detector == 30))
    ccdimginfo.detector.manufacturer={'ANL-LBL FastCCD Detector'};
elseif ( (tmp.detector == 25) )
    ccdimginfo.detector.manufacturer={'LAMBDA'};
end

foo_tmp = detectorinfo(tmp);
if (foo_tmp.blemish == 1)
    ccdimginfo.detector.blemish_status = {'ENABLED'};
else
    ccdimginfo.detector.blemish_status = {'DISABLED'};
end

if (foo_tmp.flatfield == 1)
    ccdimginfo.detector.flatfield_status = {'ENABLED'};
else
    ccdimginfo.detector.flatfield_status = {'DISABLED'};
end

% ccdimginfo.detector.model = h5read(file,'/measurement/instrument/detector/model');
% ccdimginfo.detector.serial_number = h5read(file,'/measurement/instrument/detector/serial_number');

if (needed_for_analysis)
    ccdimginfo.detector.bit_depth = h5read(file,'/measurement/instrument/detector/bit_depth');
end

ccdimginfo.detector.dpix_x = tmp.dpix;
ccdimginfo.detector.dpix_y = tmp.dpix;
ccdimginfo.detector.rows = tmp.rows;
ccdimginfo.detector.cols = tmp.cols;

%adding the full sensor size so ROI can be handled properly (March 2016)
try
    ccdimginfo.detector.SensorSizeRows = tmp.ccdHardwareRowSize;
    ccdimginfo.detector.SensorSizeCols = tmp.ccdHardwareColSize;
catch
    ccdimginfo.detector.SensorSizeRows = tmp.rows;
    ccdimginfo.detector.SensorSizeCols = tmp.cols;
end    

% ccdimginfo.detector.x_binning = h5read(file,'/measurement/instrument/detector/x_binning');
% ccdimginfo.detector.y_binning = h5read(file,'/measurement/instrument/detector/y_binning');
ccdimginfo.detector.exposure_time = tmp.preset(nBatch);
% ccdimginfo.detector.exposure_period = h5read(file,'/measurement/instrument/detector/exposure_period');
ccdimginfo.detector.distance = tmp.rr;

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


% if (needed_for_analysis)
%     ccdimginfo.detector.flatfield = h5read(file,'/measurement/instrument/detector/flatfield');
% end

ccdimginfo.detector.efficiency = tmp.efficiency;
ccdimginfo.detector.adu_per_photon = tmp.adupphot;
ccdimginfo.detector.gain = tmp.gain;

if (needed_for_analysis)
    ccdimginfo.detector.blemish_mask = h5read(file,'/measurement/instrument/detector/blemish_mask');
    ccdimginfo.detector.geometry = h5read(file,'/measurement/instrument/detector/geometry');
end

%%/measurement/instrument/detector/roi
if ( (tmp.detector ==5) || (tmp.detector == 6) )
    ccdimginfo.detector.x_begin = tmp.col_beg -1;
    ccdimginfo.detector.y_begin = tmp.row_beg -1;
    ccdimginfo.detector.x_end = tmp.col_end -1;
    ccdimginfo.detector.y_end = tmp.row_end -1;
else
    ccdimginfo.detector.x_begin = tmp.col_beg;
    ccdimginfo.detector.y_begin = tmp.row_beg;
    ccdimginfo.detector.x_end = tmp.col_end;
    ccdimginfo.detector.y_end = tmp.row_end;    
end

%%/measurement/instrument/detector/kinetics                       KINETICS

ccdimginfo.detector.kinetics.mode=tmp.kinetics;
if (needed_for_analysis)
    ccdimginfo.detector.kinetics.status = h5read(file,'/measurement/instrument/detector/kinetics/enabled');
end

ccdimginfo.detector.kinetics.window_size = tmp.kinwinsize;
ccdimginfo.detector.kinetics.slice_top = tmp.slicetop;
ccdimginfo.detector.kinetics.first_usable_slice = tmp.firstslice;
ccdimginfo.detector.kinetics.last_usable_slice = tmp.lastslice;
ccdimginfo.detector.kinetics.sliceinfo=tmp.sliceinfo;

%%/measurement/instrument/shutter                                 SHUTTER
% ccdimginfo.shutter.name = h5read(file,'/measurement/instrument/shutter/name');
% ccdimginfo.shutter.status = h5read(file,'/measurement/instrument/shutter/status');

%%/measurement/instrument/attenuator                              ATTENUATOR
% ccdimginfo.attenuator.thickness = h5read(file,'/measurement/instrument/attenuator/thickness');
% ccdimginfo.attenuator.transmission = h5read(file,'/measurement/instrument/attenuator/transmission');
% ccdimginfo.attenuator.type = h5read(file,'/measurement/instrument/attenuator/type');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%/xpcs                                                           XPCS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % ccdimginfo.xpcs.input_file_local = h5read(file,'/xpcs/input_file_remote');
% % [~,immfilename,immfileext]=fileparts(ccdimginfo.xpcs.input_file_local{1});
% % full_immfilename=[immfilename,immfileext];
% % full_immfilename=cellstr(full_immfilename);
% % full_immfilename=full_immfilename{1};
% % ccdimginfo.xpcs.input_file_local{1}=fullfile(filepath,full_immfilename);
% % 
% % ccdimginfo.xpcs.input_file_remote = h5read(file,'/xpcs/input_file_remote');
% % ccdimginfo.xpcs.output_file_local = h5read(file,'/xpcs/output_file_local');
% % ccdimginfo.xpcs.output_file_remote = h5read(file,'/xpcs/output_file_remote');
% % 
% % ccdimginfo.xpcs.specfile = h5read(file,'/xpcs/specfile');
% % ccdimginfo.xpcs.spec_datascan_number = h5read(file,'/xpcs/specscan_data_number');
% % ccdimginfo.xpcs.spec_darkscan_number = h5read(file,'/xpcs/specscan_dark_number');
% % ccdimginfo.xpcs.compression = h5read(file,'/xpcs/compression');
% % ccdimginfo.xpcs.file_mode = h5read(file,'/xpcs/file_mode');
% % ccdimginfo.xpcs.dpl = h5read(file,'/xpcs/delays_per_level');
% % ccdimginfo.xpcs.lld = h5read(file,'/xpcs/lld');
% % ccdimginfo.xpcs.rms_multiplier = h5read(file,'/xpcs/sigma');
% % ccdimginfo.xpcs.analysis_type = h5read(file,'/xpcs/analysis_type');
% % ccdimginfo.xpcs.batches = h5read(file,'/xpcs/batches');
% % ccdimginfo.xpcs.data_begin = h5read(file,'/xpcs/data_begin');
% % ccdimginfo.xpcs.data_end = h5read(file,'/xpcs/data_end');
% % ccdimginfo.xpcs.dark_begin = h5read(file,'/xpcs/dark_begin');
% % ccdimginfo.xpcs.dark_end = h5read(file,'/xpcs/dark_end');
% % ccdimginfo.xpcs.data_begin_todo = h5read(file,'/xpcs/data_begin_todo');
% % ccdimginfo.xpcs.data_end_todo = h5read(file,'/xpcs/data_end_todo');
% % ccdimginfo.xpcs.dark_begin_todo = h5read(file,'/xpcs/dark_begin_todo');
% % ccdimginfo.xpcs.dark_end_todo = h5read(file,'/xpcs/dark_end_todo');
% % ccdimginfo.xpcs.mask = h5read(file,'/xpcs/mask');
% % ccdimginfo.xpcs.dqmap = h5read(file,'/xpcs/dqmap');
% % ccdimginfo.xpcs.sqmap = h5read(file,'/xpcs/sqmap');
% % ccdimginfo.xpcs.dphimap = h5read(file,'/xpcs/dphimap');
% % ccdimginfo.xpcs.sphimap = h5read(file,'/xpcs/sphimap');
% % ccdimginfo.xpcs.dqspan = h5read(file,'/xpcs/dqspan');
% % ccdimginfo.xpcs.dphispan = h5read(file,'/xpcs/dphispan');
% % ccdimginfo.xpcs.sqspan = h5read(file,'/xpcs/sqspan');
% % ccdimginfo.xpcs.sphispan = h5read(file,'/xpcs/sphispan');
% % ccdimginfo.xpcs.sqlist = h5read(file,'/xpcs/sqlist');
% % ccdimginfo.xpcs.dqlist = h5read(file,'/xpcs/dqlist');
% % ccdimginfo.xpcs.sphilist = h5read(file,'/xpcs/sphilist');
% % ccdimginfo.xpcs.dphilist = h5read(file,'/xpcs/dphilist');
% % ccdimginfo.xpcs.normalization_method = h5read(file,'/xpcs/normalization_method');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    
elseif (ccdimginfo.geometry == 2) %%wide angle    
    ccdimginfo.partition.snpt(1)=1;
    ccdimginfo.partition.snpt(2)=1;
    ccdimginfo.partition.dnpt(1)=1;
    ccdimginfo.partition.dnpt(2)=1;
    ccdimginfo.partition.name = {'x','y'};    
end

ccdimginfo.batchestodo=1;

ccdimginfo.savepath = fileparts(ccdimginfo.fullpath_info_name);

[~,ccdimginfo.name,~]=fileparts(ccdimginfo.info_name);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================
% --- define mask information method:
% 1. no mask (use all pixles) 
% 2. new mask (not should not be defined here --> use case 3 instead)
% 3. from existing custom mask file
%==========================================================================
ccdimginfo = initializemask(ccdimginfo);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end




