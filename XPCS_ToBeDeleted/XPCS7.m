XPCS6 - 2012/03/05

/implements = "measurement:xpcs"

/version

/measurement

/measurement/sample                                             SAMPLE

/measurement/sample/name

/measurement/sample/description

/measurement/sample/preparation_date

%/measurement/sample/experiment

/measurement/sample/experiment/proposal

/measurement/sample/experiment/activity

/measurement/sample/experiment/safety

%%/measurement/sample/experimenter

/measurement/sample/experimenter/name

/measurement/sample/experimenter/role

/measurement/sample/experimenter/affiliation

/measurement/sample/experimenter/address

/measurement/sample/experimenter/phone

/measurement/sample/experimenter/email

/measurement/sample/experimenter/facility_user_id

/measurement/sample/geometry/orientation

/measurement/sample/geometry/translation

/measurement/sample/temperature_A

/measurement/sample/temperature_B

/measurement/sample/temperature_A_set

/measurement/sample/temperature_B_set

/measurement/sample/thickness

/measurement/sample/thickness@units = "mm"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%/measurement/instrument

/measurement/instrument/name = "SECTOR 8"

%%/measurement/instrument/source_begin

/measurement/instrument/source_begin/name

/measurement/instrument/source_begin/datetime <- beginning time

/measurement/instrument/source_begin/beamline

/measurement/instrument/source_begin/distance
/measurement/instrument/source_begin/current

/measurement/instrument/source_begin/energy

/measurement/instrument/source_begin/pulse_energy

/measurement/instrument/source_begin/pulse_width

/measurement/instrument/source_begin/mode

/measurement/instrument/source_begin/beam_intensity_transmitted

/measurement/instrument/source_begin/beam_intensity_incident

%%/measurement/instrument/source_end

/measurement/instrument/source_end/name

/measurement/instrument/source_end/datetime <- ending time

/measurement/instrument/source_end/beamline

/measurement/instrument/source_end/distance

/measurement/instrument/source_end/current

/measurement/instrument/source_end/energy

/measurement/instrument/source_end/pulse_energy

/measurement/instrument/source_end/pulse_width

/measurement/instrument/source_end/mode

/measurement/instrument/source_end/beam_intensity_transmitted

/measurement/instrument/source_end/beam_intensity_incident

%%/measurement/instrument/acquisition                             ACQUISITION

/measurement/instrument/acquisition/beam_center_x

/measurement/instrument/acquisition/beam_center_y

/measurement/instrument/acquisition/beam_size_h

/measurement/instrument/acquisition/beam_size_v

/measurement/instrument/acquisition/stage_zero_x

/measurement/instrument/acquisition/stage_zero_z

/measurement/instrument/acquisition/ccdyspec
/measurement/instrument/acquisition/x

/measurement/instrument/acquisition/stage_x

/measurement/instrument/acquisition/stage_z

/measurement/instrument/acquisition/xspec
/measurement/instrument/acquisition/yspec
/measurement/instrument/acquisition/ccdxspec
/measurement/instrument/acquisition/y
/measurement/instrument/acquisition/angle

%%/measurement/instrument/detector                                DETECTOR
/measurement/instrument/detector/manufacturer
/measurement/instrument/detector/model
/measurement/instrument/detector/serial_number
/measurement/instrument/detector/bit_depth
/measurement/instrument/detector/x_pixel_size
/measurement/instrument/detector/y_pixel_size
/measurement/instrument/detector/x_dimension
/measurement/instrument/detector/y_dimension
/measurement/instrument/detector/x_binning
/measurement/instrument/detector/y_binning
/measurement/instrument/detector/exposure_time
/measurement/instrument/detector/exposure_period
/measurement/instrument/detector/distance
/measurement/instrument/detector/flatfield
/measurement/instrument/detector/efficiency
/measurement/instrument/detector/adu_per_photon
/measurement/instrument/detector/gain
/measurement/instrument/detector/blemish_mask
/measurement/instrument/detector/geometry
%%/measurement/instrument/detector/roi
/measurement/instrument/detector/roi/x1
/measurement/instrument/detector/roi/y1
/measurement/instrument/detector/roi/x2
/measurement/instrument/detector/roi/y2

/measurement/instrument/detector/kinetics                       KINETICS
/measurement/instrument/detector/kinetics/enabled %%%%%%NEW
/measurement/instrument/detector/kinetics/window_size
/measurement/instrument/detector/kinetics/top
/measurement/instrument/detector/kinetics/first_usable_window
/measurement/instrument/detector/kinetics/last_usable_window

%%/measurement/instrument/shutter                                 SHUTTER
/measurement/instrument/shutter/name
/measurement/instrument/shutter/status

%%/measurement/instrument/attenuator                              ATTENUATOR
/measurement/instrument/attenuator/thickness
/measurement/instrument/attenuator/transmission
/measurement/instrument/attenuator/type

%%/xpcs                                                           XPCS
/xpcs/input_file_local
/xpcs/input_file_remote
/xpcs/output_file_local
/xpcs/output_file_remote
/xpcs/specfile
/xpcs/specscan_data_number
/xpcs/specscan_dark_number
/xpcs/compression
/xpcs/file_mode
/xpcs/delays_per_level
/xpcs/lld
/xpcs/sigma
/xpcs/analysis_type
/xpcs/batches
/xpcs/data_begin
/xpcs/data_end
/xpcs/dark_begin
/xpcs/dark_end
/xpcs/data_begin_todo
/xpcs/data_end_todo
/xpcs/dark_begin_todo
/xpcs/dark_end_todo
/xpcs/mask
/xpcs/dqmap
/xpcs/sqmap
/xpcs/dphimap
/xpcs/sphimap
/xpcs/dqspan
/xpcs/dphispan
/xpcs/sqspan
/xpcs/sphispan
/xpcs/sqlist
/xpcs/dqlist
/xpcs/sphilist
/xpcs/dphilist
/xpcs/normalization_method
/xpcs/blemish_enabled
/xpcs/flatfield_enabled




