function save_TwoTime_hdf5(varargin)
full_hdf5_filename=varargin{1};
hdf5_group_name=varargin{2};
TwoTimeInfo=varargin{3};

if (nargin == 4)
    hdf5_gzip_compression_factor = varargin{4};
    if ( (hdf5_gzip_compression_factor < 0) || (hdf5_gzip_compression_factor > 9) )
        disp('Not a valid compression factor, so forcing to compressed HDF5 file');
        hdf5_gzip_compression_factor = 1;
    end
else
    hdf5_gzip_compression_factor=1;
end

save_2T_start = tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning('OFF','MATLAB:imagesci:hdf5dataset:datatypeOutOfRange');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% result_group_location=deblank(h5read(full_hdf5_filename,[hdf5_group_name,'/output_data']));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hdf5_create_file(full_hdf5_filename);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hdf5_create_group(full_hdf5_filename,hdf5_group_name);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hdf5_group_2T_name=[hdf5_group_name,'/C2T_all'];
hdf5_create_group(full_hdf5_filename,hdf5_group_2T_name);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
writeh5str(full_hdf5_filename,[hdf5_group_name,'/hdf5_filename'],TwoTimeInfo.hdf5_filename);
if isempty(TwoTimeInfo.qmap_filename)
    TwoTimeInfo.qmap_filename = 'null';
end

writeh5str(full_hdf5_filename,[hdf5_group_name,'/qmap_filename'],TwoTimeInfo.qmap_filename);
writeh5str(full_hdf5_filename,[hdf5_group_name,'/xpcs_entry'],TwoTimeInfo.xpcs_entry);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(full_hdf5_filename,[hdf5_group_name,'/dqmap'],cast(TwoTimeInfo.dqmap,'uint32'));
catch
    h5create(full_hdf5_filename,[hdf5_group_name,'/dqmap'],size(TwoTimeInfo.dqmap),'Datatype','uint32');
    h5write(full_hdf5_filename,[hdf5_group_name,'/dqmap'],cast(TwoTimeInfo.dqmap,'uint32'));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(full_hdf5_filename,[hdf5_group_name,'/dqmap_index_qbin'],cast(TwoTimeInfo.dqmap_index_qbin,'uint32'));
catch
    h5create(full_hdf5_filename,[hdf5_group_name,'/dqmap_index_qbin'],size(TwoTimeInfo.dqmap_index_qbin),'Datatype','uint32');
    h5write(full_hdf5_filename,[hdf5_group_name,'/dqmap_index_qbin'],cast(TwoTimeInfo.dqmap_index_qbin,'uint32'));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(full_hdf5_filename,[hdf5_group_name,'/qphi_bin_to_process'],cast(TwoTimeInfo.qphi_bin_to_process,'uint32'));
catch
    h5create(full_hdf5_filename,[hdf5_group_name,'/qphi_bin_to_process'],size(TwoTimeInfo.qphi_bin_to_process),'Datatype','uint32');
    h5write(full_hdf5_filename,[hdf5_group_name,'/qphi_bin_to_process'],cast(TwoTimeInfo.qphi_bin_to_process,'uint32'));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(full_hdf5_filename,[hdf5_group_name,'/dqval'],TwoTimeInfo.dqval);
catch
    h5create(full_hdf5_filename,[hdf5_group_name,'/dqval'],size(TwoTimeInfo.dqval));
    h5write(full_hdf5_filename,[hdf5_group_name,'/dqval'],TwoTimeInfo.dqval);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(full_hdf5_filename,[hdf5_group_name,'/stride_frames'],cast(TwoTimeInfo.stride_frames,'uint32'));
catch
    h5create(full_hdf5_filename,[hdf5_group_name,'/stride_frames'],size(TwoTimeInfo.stride_frames),'Datatype','uint32');
    h5write(full_hdf5_filename,[hdf5_group_name,'/stride_frames'],cast(TwoTimeInfo.stride_frames,'uint32'));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(full_hdf5_filename,[hdf5_group_name,'/frames_bin_size'],cast(TwoTimeInfo.frames_bin_size,'uint32'));
catch
    h5create(full_hdf5_filename,[hdf5_group_name,'/frames_bin_size'],size(TwoTimeInfo.frames_bin_size),'Datatype','uint32');
    h5write(full_hdf5_filename,[hdf5_group_name,'/frames_bin_size'],cast(TwoTimeInfo.frames_bin_size,'uint32'));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(full_hdf5_filename,[hdf5_group_name,'/I0t'],TwoTimeInfo.I0t);
catch
    h5create(full_hdf5_filename,[hdf5_group_name,'/I0t'],size(TwoTimeInfo.I0t));
    h5write(full_hdf5_filename,[hdf5_group_name,'/I0t'],TwoTimeInfo.I0t);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(full_hdf5_filename,[hdf5_group_name,'/AvgData'],TwoTimeInfo.AvgData);
catch
    h5create(full_hdf5_filename,[hdf5_group_name,'/AvgData'],size(TwoTimeInfo.AvgData));
    h5write(full_hdf5_filename,[hdf5_group_name,'/AvgData'],TwoTimeInfo.AvgData);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(full_hdf5_filename,[hdf5_group_name,'/SG_smoothed_data'],TwoTimeInfo.SG_smoothed_data);
catch
    h5create(full_hdf5_filename,[hdf5_group_name,'/SG_smoothed_data'],size(TwoTimeInfo.SG_smoothed_data));
    h5write(full_hdf5_filename,[hdf5_group_name,'/SG_smoothed_data'],TwoTimeInfo.SG_smoothed_data);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(full_hdf5_filename,[hdf5_group_name,'/Normalize_by_Intensity'],cast(TwoTimeInfo.Normalize_by_Intensity,'uint32'));
catch
    h5create(full_hdf5_filename,[hdf5_group_name,'/Normalize_by_Intensity'],size(TwoTimeInfo.Normalize_by_Intensity),'Datatype','uint32');
    h5write(full_hdf5_filename,[hdf5_group_name,'/Normalize_by_Intensity'],cast(TwoTimeInfo.Normalize_by_Intensity,'uint32'));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(full_hdf5_filename,[hdf5_group_name,'/Normalize_by_Smoothed_Img'],cast(TwoTimeInfo.Normalize_by_Smoothed_Img,'uint32'));
catch
    h5create(full_hdf5_filename,[hdf5_group_name,'/Normalize_by_Smoothed_Img'],size(TwoTimeInfo.Normalize_by_Smoothed_Img),'Datatype','uint32');
    h5write(full_hdf5_filename,[hdf5_group_name,'/Normalize_by_Smoothed_Img'],cast(TwoTimeInfo.Normalize_by_Smoothed_Img,'uint32'));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(full_hdf5_filename,[hdf5_group_name,'/Smoothing_Method'],cast(TwoTimeInfo.Smoothing_Method,'uint32'));
catch
    h5create(full_hdf5_filename,[hdf5_group_name,'/Smoothing_Method'],size(TwoTimeInfo.Smoothing_Method),'Datatype','uint32');
    h5write(full_hdf5_filename,[hdf5_group_name,'/Smoothing_Method'],cast(TwoTimeInfo.Smoothing_Method,'uint32'));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(full_hdf5_filename,[hdf5_group_name,'/Subtract_Ref_Speckle'],cast(TwoTimeInfo.Subtract_Ref_Speckle,'uint32'));
catch
    h5create(full_hdf5_filename,[hdf5_group_name,'/Subtract_Ref_Speckle'],size(TwoTimeInfo.Subtract_Ref_Speckle),'Datatype','uint32');
    h5write(full_hdf5_filename,[hdf5_group_name,'/Subtract_Ref_Speckle'],cast(TwoTimeInfo.Subtract_Ref_Speckle,'uint32'));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(full_hdf5_filename,[hdf5_group_name,'/Num_g2partials'],cast(TwoTimeInfo.Num_g2partials,'uint32'));
catch
    h5create(full_hdf5_filename,[hdf5_group_name,'/Num_g2partials'],size(TwoTimeInfo.Num_g2partials),'Datatype','uint32');
    h5write(full_hdf5_filename,[hdf5_group_name,'/Num_g2partials'],cast(TwoTimeInfo.Num_g2partials,'uint32'));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(full_hdf5_filename,[hdf5_group_name,'/g2full'],TwoTimeInfo.g2full);
catch
    h5create(full_hdf5_filename,[hdf5_group_name,'/g2full'],size(TwoTimeInfo.g2full));
    h5write(full_hdf5_filename,[hdf5_group_name,'/g2full'],TwoTimeInfo.g2full);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(full_hdf5_filename,[hdf5_group_name,'/g2partials'],TwoTimeInfo.g2partials);
catch
    h5create(full_hdf5_filename,[hdf5_group_name,'/g2partials'],size(TwoTimeInfo.g2partials));
    h5write(full_hdf5_filename,[hdf5_group_name,'/g2partials'],TwoTimeInfo.g2partials);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% save 2T matrix %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
size_2T = size(TwoTimeInfo.C{1});
good_qphi_bins = nonzeros(unique(TwoTimeInfo.dqmap_index_qbin));
if (hdf5_gzip_compression_factor == 1)
    disp('Starting to Save 2T matrix into HDF5 file as one big chunk and gzip COMPRESSED');
else
    disp('Starting to Save 2T matrix into HDF5 file as one big chunk and _UN_COMPRESSED');
end

for ii=1:numel(TwoTimeInfo.C)
    try
        h5write(full_hdf5_filename,[hdf5_group_2T_name,'/C2T_',sprintf('%05i',good_qphi_bins(ii))],triu(TwoTimeInfo.C{ii}));
    catch
        h5create(full_hdf5_filename,[hdf5_group_2T_name,'/C2T_',sprintf('%05i',good_qphi_bins(ii))],...
            size_2T,'Datatype',class(TwoTimeInfo.C{ii}),'ChunkSize',size_2T,'Deflate',hdf5_gzip_compression_factor);
        h5write(full_hdf5_filename,[hdf5_group_2T_name,'/C2T_',sprintf('%05i',good_qphi_bins(ii))],triu(TwoTimeInfo.C{ii}));
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('TwoTime Results are SAVED into the HDF5 file in %i Seconds\n',round(toc(save_2T_start)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
