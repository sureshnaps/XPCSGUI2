function [tag,tag_value,index] = write_MetaData_xpcs(varargin)
%writeDX Write DataExchange example code.
%        Detailed explanation goes here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hdf5_xpcs_group_name=varargin{1};
ccdimginfo=varargin{2};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     index=0; %%%Initialize the counter
     nBatch=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % Implements - /implements
%      implements = 'measurement:xpcs';
%      hdf5write(hdf5_filename', '/implements', implements);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
%%%XPCS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/Version'];
     tag_value{index} = num2str(0.5);
     %this field is introduced in version 0.5 - added functionality include
     %stride and sum frames, two time, etc...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/input_file_local'];
     tag_value{index} =ccdimginfo.xpcs.input_file_local{nBatch};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/input_file_remote'];
     tag_value{index} = ccdimginfo.xpcs.input_file_remote{nBatch};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/output_file_local'];
     tag_value{index} = ccdimginfo.xpcs.output_file_local{nBatch};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/output_file_remote'];%%is a folder for now
     tag_value{index} = ccdimginfo.xpcs.output_file_remote{nBatch};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/specfile'];
     tag_value{index} = ccdimginfo.xpcs.specfile;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/specscan_data_number'];
     tag_value{index} = ccdimginfo.xpcs.spec_datascan_number;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/compression'];
     if (strcmp(ccdimginfo.xpcs.compression,'ENABLED') == 1)
         tag_value{index} = 'ENABLED';
     else
         tag_value{index} = 'DISABLED';
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/kinetics'];
     if (ccdimginfo.detector.kinetics.mode == 1)
         tag_value{index} = 'ENABLED';
     else
         tag_value{index} = 'DISABLED';
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
if (strcmp(ccdimginfo.xpcs.compression,'DISABLED') == 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/dark_begin'];
     tag_value{index} = uint64(ccdimginfo.xpcs.dark_begin);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/dark_end'];
     tag_value{index} = uint64(ccdimginfo.xpcs.dark_end);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/dark_begin_todo'];
     tag_value{index} = uint64(ccdimginfo.xpcs.dark_begin_todo);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/dark_end_todo'];
     tag_value{index} = uint64(ccdimginfo.xpcs.dark_end_todo);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/specscan_dark_number'];
     tag_value{index} = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
else     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/dark_begin'];
     tag_value{index} = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/dark_end'];
     tag_value{index} = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/dark_begin_todo'];
     tag_value{index} = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/dark_end_todo'];
     tag_value{index} = 0;   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/specscan_dark_number'];
     tag_value{index} = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
% %      index=index+1;
% %      tag{index}=[hdf5_xpcs_group_name,'/file_mode'];
% %      tag_value{index} = ccdimginfo.xpcs.file_mode{1};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/delays_per_level'];
     tag_value{index} = uint64(ccdimginfo.xpcs.dpl);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/lld'];
     tag_value{index} = ccdimginfo.xpcs.lld;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/sigma'];
     tag_value{index} = ccdimginfo.xpcs.rms_multiplier;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/analysis_type'];
     if (1)
         tag_value{index} = ccdimginfo.xpcs.analysis_type;
%          tag_value{index} = 'Multitau';
     else
         tag_value{index} = 'STATIC';
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
     if (ccdimginfo.detector.kinetics.mode == 1)
         kinetics_numslices = (ccdimginfo.detector.kinetics.last_usable_slice ...
             - ccdimginfo.detector.kinetics.first_usable_slice +1);
     end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/static_mean_window_size'];
     tag_value{index} = uint64(max(floor((ccdimginfo.xpcs.data_end_todo(nBatch)-ccdimginfo.xpcs.data_begin_todo(nBatch)+1)/10),2));
     if (ccdimginfo.detector.kinetics.mode == 1)
         tag_value{index} = tag_value{index}*cast(kinetics_numslices,'like',tag_value{index});
     end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/dynamic_mean_window_size'];
     tag_value{index} = uint64(max(floor((ccdimginfo.xpcs.data_end_todo(nBatch)-ccdimginfo.xpcs.data_begin_todo(nBatch)+1)/10),2));
     if (ccdimginfo.detector.kinetics.mode == 1)
         tag_value{index} = tag_value{index}*cast(kinetics_numslices,'like',tag_value{index});
     end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/batches'];
     tag_value{index} = uint64(ccdimginfo.batchestodo(nBatch));
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/data_begin'];
     tag_value{index} = uint64(ccdimginfo.xpcs.data_begin);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/data_end'];
     tag_value{index} = uint64(ccdimginfo.xpcs.data_end);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/data_begin_todo'];
     tag_value{index} = uint64(ccdimginfo.xpcs.data_begin_todo);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/data_end_todo'];
     tag_value{index} = uint64(ccdimginfo.xpcs.data_end_todo);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/normalization_method'];
     tflux=ccdimginfo.measurement.instrument.source_begin.transmitted_flux;
     iflux=ccdimginfo.measurement.instrument.source_begin.incident_flux;
     if ((tflux ~=1) && (iflux ==1))
         tag_value{index} = 'TRANSMITTED';
     elseif  ((iflux ~=1) && (tflux ==1))
         tag_value{index} = 'INCIDENT';
     elseif ((iflux ~=1) && (tflux ~=1))
         tag_value{index} = 'BOTH';
     else
         tag_value{index} = 'NONE';
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/blemish_enabled'];
     tag_value{index} = ccdimginfo.detector.blemish_status{1};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/flatfield_enabled'];
     tag_value{index} = ccdimginfo.detector.flatfield_status{1};     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%April 2014: planning on using contract work with Faisal Khan to enhance
%XPCS capabilities such as binning, skipping, summing frames, two time, and
%may be other stuff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/swbinX'];
     try
         tag_value{index} = ccdimginfo.bin.swbinX;
     catch
         tag_value{index} = 1;
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/swbinY'];
     try
         tag_value{index} = ccdimginfo.bin.swbinY;
     catch
         tag_value{index} = uint32(1);
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/stride_frames'];
     tag_value{index} = uint64(ccdimginfo.xpcs.stride_frames);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     index=index+1;
     tag{index}=[hdf5_xpcs_group_name,'/avg_frames'];
     tag_value{index} = uint64(ccdimginfo.xpcs.avg_frames);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%move this field to save_MetaData_xpcs_hdf5 as it is easy to cutomize the
%value of N in /exchange_N 
% %      index=index+1;
% %      tag{index}=[hdf5_xpcs_group_name,'/output_data';
% %      tag_value{index} = '/exchange';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%ANYTHING NEW GOES HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%WRITE HDF5 FILE CONTAINING THE METADATA
%%%TRY to move saving to hdf5 file to a separate function
%%%saving is done in save_MetaData_xpcs_hdf5.m
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
