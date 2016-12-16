XPCS6 - 2012/03/05

/implements = "measurement:xpcs"

/version

/measurement

/measurement/sample                                             SAMPLE

/measurement/sample/name (8idi:StrReg1)

/measurement/sample/description (8idi:StrReg2)

/measurement/sample/preparation_date (8idi:StrReg3)

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

/measurement/sample/temperature_A (8idi:LS331:TC1:SampleA)

/measurement/sample/temperature_B (8idi:LS331:TC1:SampleA)

/measurement/sample/temperature_A_set (8idi:LS331:TC1:SP)

/measurement/sample/temperature_B_set (8idi:LS331:TC1:SP)

/measurement/sample/thickness (8idi:StrReg4)

/measurement/sample/thickness@units = "mm"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%/measurement/instrument

/measurement/instrument/name = "SECTOR 8" (8idi:StrReg5)

%%/measurement/instrument/source_begin

/measurement/instrument/source_begin/name (8idi:StrReg6)

/measurement/instrument/source_begin/datetime <- beginning time (8idi:StrReg7)

/measurement/instrument/source_begin/beamline (8idi)

/measurement/instrument/source_begin/distance (65)
/measurement/instrument/source_begin/current (S:SRcurrentAI)

/measurement/instrument/source_begin/energy (8idimono:sm2)

/measurement/instrument/source_begin/pulse_energy (8idimono:sm2)

/measurement/instrument/source_begin/pulse_width (constant 0)

/measurement/instrument/source_begin/mode (Mt:TopUpMessage.VAL)

/measurement/instrument/source_begin/beam_intensity_transmitted (8idi:StrReg8)

/measurement/instrument/source_begin/beam_intensity_incident (8idi:StrReg9)

%%/measurement/instrument/source_end

/measurement/instrument/source_end/name (constant 8idi)

/measurement/instrument/source_end/datetime <- ending time (8idi:StrReg10)

/measurement/instrument/source_end/beamline (constant 8idi)

/measurement/instrument/source_end/distance (constant 65)
 
/measurement/instrument/source_end/current (S:SRcurrentAI)

/measurement/instrument/source_end/energy (8idimono:sm2)

/measurement/instrument/source_end/pulse_energy (constant 0)
 
/measurement/instrument/source_end/pulse_width (constant 0)

/measurement/instrument/source_end/mode (Mt:TopUpMessage.VAL)

/measurement/instrument/source_end/beam_intensity_transmitted (8idi:StrReg10)

/measurement/instrument/source_end/beam_intensity_incident (8idi:StrReg11)

%%/measurement/instrument/acquisition                             ACQUISITION

/measurement/instrument/acquisition/beam_center_x (8idi:Reg11)
 
/measurement/instrument/acquisition/beam_center_y (8idi:Reg12)

/measurement/instrument/acquisition/beam_size_h (8idi:Slit2Hsize.VAL)

/measurement/instrument/acquisition/beam_size_v (8idi:Slit2Vsize.VAL)

/measurement/instrument/acquisition/stage_zero_x (8idi:Reg13)

/measurement/instrument/acquisition/stage_zero_z (8idi:Reg14)

/measurement/instrument/acquisition/ccdyspec (8idi:Reg18)
/measurement/instrument/acquisition/x (not sure if this is needed)

/measurement/instrument/acquisition/stage_x (8idi:m90.RBV)

/measurement/instrument/acquisition/stage_z (8idi:m91.RBV)

/measurement/instrument/acquisition/xspec (8idi:Reg15)
/measurement/instrument/acquisition/yspec (8idi:Reg16)
/measurement/instrument/acquisition/ccdxspec (8idi:Reg17)
/measurement/instrument/acquisition/y (not sure if this is needed)
/measurement/instrument/acquisition/angle (8idi:Reg19)

%%/measurement/instrument/detector                                DETECTOR
/measurement/instrument/detector/manufacturer
/measurement/instrument/detector/model
/measurement/instrument/detector/serial_number
/measurement/instrument/detector/bit_depth (constant 16)
/measurement/instrument/detector/x_pixel_size (constant 0.02)
/measurement/instrument/detector/y_pixel_size (constant 0.02)
/measurement/instrument/detector/x_dimension
/measurement/instrument/detector/y_dimension
/measurement/instrument/detector/x_binning
/measurement/instrument/detector/y_binning
/measurement/instrument/detector/exposure_time
/measurement/instrument/detector/exposure_period
/measurement/instrument/detector/distance (8idi:Reg5)
/measurement/instrument/detector/flatfield (??)
/measurement/instrument/detector/efficiency (constant 0.5)
/measurement/instrument/detector/adu_per_photon (constant 800)
/measurement/instrument/detector/gain
/measurement/instrument/detector/blemish_mask (??)
/measurement/instrument/detector/geometry (8idi:Reg3)
%%/measurement/instrument/detector/roi
/measurement/instrument/detector/roi/x1
/measurement/instrument/detector/roi/y1
/measurement/instrument/detector/roi/x2
/measurement/instrument/detector/roi/y2

/measurement/instrument/detector/kinetics                       KINETICS
/measurement/instrument/detector/kinetics/enabled 
/measurement/instrument/detector/kinetics/window_size
/measurement/instrument/detector/kinetics/top
/measurement/instrument/detector/kinetics/first_usable_window
/measurement/instrument/detector/kinetics/last_usable_window

%%/measurement/instrument/shutter                                 SHUTTER
/measurement/instrument/shutter/name (constant Azsol)
/measurement/instrument/shutter/status (???)

%%/measurement/instrument/attenuator                              ATTENUATOR
/measurement/instrument/attenuator/thickness (???)
/measurement/instrument/attenuator/transmission (???)
/measurement/instrument/attenuator/type (constant Copper)

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




