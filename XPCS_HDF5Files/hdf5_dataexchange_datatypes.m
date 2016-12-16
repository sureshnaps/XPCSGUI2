XPCS7 - 2012/03/05

/implements = "measurement:xpcs"

/version

/measurement

/measurement/sample                                             SAMPLE

/measurement/sample/name (string)

/measurement/sample/description (string)

/measurement/sample/preparation_date (string)

%/measurement/sample/experiment

/measurement/sample/experiment/proposal (string)

/measurement/sample/experiment/activity (string)

/measurement/sample/experiment/safety (string)

%%/measurement/sample/experimenter

/measurement/sample/experimenter/name (string)

/measurement/sample/experimenter/role (string)

/measurement/sample/experimenter/affiliation (string)

/measurement/sample/experimenter/address (string)

/measurement/sample/experimenter/phone (string)

/measurement/sample/experimenter/email (string)

/measurement/sample/experimenter/facility_user_id (string)

/measurement/sample/geometry/orientation (not decided yet)

/measurement/sample/geometry/translation (not decided yet)

/measurement/sample/temperature_A (float)

/measurement/sample/temperature_B (float)

/measurement/sample/temperature_A_set (float)

/measurement/sample/temperature_B_set (float)

/measurement/sample/thickness (float)

/measurement/sample/thickness@units = "mm"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%/measurement/instrument

/measurement/instrument/name = "SECTOR 8"

%%/measurement/instrument/source_begin

/measurement/instrument/source_begin/name (string)

/measurement/instrument/source_begin/datetime <- beginning time (string)

/measurement/instrument/source_begin/beamline (string)

/measurement/instrument/source_begin/distance (float)
/measurement/instrument/source_begin/current (float)

/measurement/instrument/source_begin/energy (float)

/measurement/instrument/source_begin/pulse_energy (float)

/measurement/instrument/source_begin/pulse_width (float)

/measurement/instrument/source_begin/mode (string)

/measurement/instrument/source_begin/beam_intensity_transmitted (float)

/measurement/instrument/source_begin/beam_intensity_incident (float)

%%/measurement/instrument/source_end

/measurement/instrument/source_end/name (string)

/measurement/instrument/source_end/datetime <- ending time (string)
 
/measurement/instrument/source_end/beamline (string)

/measurement/instrument/source_end/distance (float)

/measurement/instrument/source_end/current (float)

/measurement/instrument/source_end/energy (float)

/measurement/instrument/source_end/pulse_energy (float)

/measurement/instrument/source_end/pulse_width (float)

/measurement/instrument/source_end/mode (string)

/measurement/instrument/source_end/beam_intensity_transmitted (float)

/measurement/instrument/source_end/beam_intensity_incident (float)

%%/measurement/instrument/acquisition                             ACQUISITION

/measurement/instrument/acquisition/beam_center_x (float)

/measurement/instrument/acquisition/beam_center_y (float)

/measurement/instrument/acquisition/beam_size_h (float)

/measurement/instrument/acquisition/beam_size_v (float)

/measurement/instrument/acquisition/stage_zero_x (float)

/measurement/instrument/acquisition/stage_zero_z (float)

/measurement/instrument/acquisition/ccdyspec (float)
/measurement/instrument/acquisition/x (float)

/measurement/instrument/acquisition/stage_x (float)

/measurement/instrument/acquisition/stage_z (float)

/measurement/instrument/acquisition/xspec (float)
/measurement/instrument/acquisition/yspec (float)
/measurement/instrument/acquisition/ccdxspec (float)
/measurement/instrument/acquisition/y (float)
/measurement/instrument/acquisition/angle (float)

%%/measurement/instrument/detector                                DETECTOR
/measurement/instrument/detector/manufacturer (string)
/measurement/instrument/detector/model (string)
/measurement/instrument/detector/serial_number (string)
/measurement/instrument/detector/bit_depth (int32)
/measurement/instrument/detector/x_pixel_size  (float)
/measurement/instrument/detector/y_pixel_size (float)
/measurement/instrument/detector/x_dimension (int32)
/measurement/instrument/detector/y_dimension (int32)
/measurement/instrument/detector/x_binning (int32)
/measurement/instrument/detector/y_binning (int32)
/measurement/instrument/detector/exposure_time (float)
/measurement/instrument/detector/exposure_period (float)
/measurement/instrument/detector/distance (float)
/measurement/instrument/detector/flatfield (string)
/measurement/instrument/detector/efficiency  (float)
/measurement/instrument/detector/adu_per_photon (int32)
/measurement/instrument/detector/gain (int32)
/measurement/instrument/detector/blemish_mask (string)
/measurement/instrument/detector/geometry (string)
%%/measurement/instrument/detector/roi
/measurement/instrument/detector/roi/x1 (int32)
/measurement/instrument/detector/roi/y1 (int32)
/measurement/instrument/detector/roi/x2 (int32)
/measurement/instrument/detector/roi/y2 (int32)

/measurement/instrument/detector/kinetics                       KINETICS
/measurement/instrument/detector/kinetics/enabled (string)
/measurement/instrument/detector/kinetics/window_size (int32)
/measurement/instrument/detector/kinetics/top (int32)
/measurement/instrument/detector/kinetics/first_usable_window (int32)
/measurement/instrument/detector/kinetics/last_usable_window (int32)

%%/measurement/instrument/shutter                                 SHUTTER
/measurement/instrument/shutter/name (string)
/measurement/instrument/shutter/status (string)

%%/measurement/instrument/attenuator                              ATTENUATOR
/measurement/instrument/attenuator/thickness (float)
/measurement/instrument/attenuator/transmission (float)
/measurement/instrument/attenuator/type (string)

%%/xpcs                                                           XPCS
/xpcs/input_file_local (string)
/xpcs/input_file_remote (string)
/xpcs/output_file_local (string)
/xpcs/output_file_remote (string)
/xpcs/specfile (string)
/xpcs/specscan_data_number (int32)
/xpcs/specscan_dark_number (int32)
/xpcs/compression (string)
/xpcs/file_mode (string)
/xpcs/delays_per_level (int32)
/xpcs/lld (float)
/xpcs/sigma (float)
/xpcs/analysis_type (string)
/xpcs/batches (int32)
/xpcs/data_begin (int32)
/xpcs/data_end (int32)
/xpcs/dark_begin (int32)
/xpcs/dark_end (int32)
/xpcs/data_begin_todo (int32)
/xpcs/data_end_todo (int32)
/xpcs/dark_begin_todo (int32)
/xpcs/dark_end_todo (int32)
/xpcs/mask (int32)
/xpcs/dqmap (int32)
/xpcs/sqmap (int32)
/xpcs/dphimap (int32)
/xpcs/sphimap (int32)
/xpcs/dqspan (float)
/xpcs/dphispan (float)
/xpcs/sqspan (float)
/xpcs/sphispan (float)
/xpcs/sqlist (float)
/xpcs/dqlist (float)
/xpcs/sphilist (float)
/xpcs/dphilist (float)
/xpcs/normalization_method (string)
/xpcs/blemish_enabled (string)
/xpcs/flatfield_enabled (string)




