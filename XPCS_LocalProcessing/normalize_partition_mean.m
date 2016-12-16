function normalization_factor = normalize_partition_mean(hdf5_MetaDataFile)
%=========================================================================
% --- try to calculate absolute intensities
% The output of this function will be used to multiply the partition mean
% values at each static q-partition (in Hadoop map-reduce)
%Suresh, Sep 7, 2012
%=========================================================================
normalization_factor=1.0;
%=========================================================================
dpix_x=h5read(hdf5_MetaDataFile,'/measurement/instrument/detector/x_pixel_size');
dpix_y=h5read(hdf5_MetaDataFile,'/measurement/instrument/detector/y_pixel_size');
efficiency=h5read(hdf5_MetaDataFile,'/measurement/instrument/detector/efficiency');
adupphot=h5read(hdf5_MetaDataFile,'/measurement/instrument/detector/adu_per_photon');
preset=h5read(hdf5_MetaDataFile,'/measurement/instrument/detector/exposure_time');
rr=h5read(hdf5_MetaDataFile,'/measurement/instrument/detector/distance');
% flux_incident=h5read(hdf5_MetaDataFile,'/measurement/instrument/source_begin/beam_intensity_incident');
try
    flux_transmitted=h5read(hdf5_MetaDataFile,'/measurement/instrument/source_begin/beam_intensity_transmitted');
catch
    flux_transmitted = 1.0;
end
thickness=h5read(hdf5_MetaDataFile,'/measurement/sample/thickness');

%=========================================================================
normalization_factor  = normalization_factor/efficiency / adupphot /preset;% this can always be calculated (unit: [photons/sec])
%=========================================================================
% divide by the solid angle; unit is still [photons/sec]
    normalization_factor  = normalization_factor  / ( dpix_x/rr * dpix_y/rr )      ;
%=========================================================================
%normalize with transmitted flux through sample (I_0 cancels out)
normalization_factor = normalization_factor ./ flux_transmitted;
%=========================================================================
%%normalize with sample thickness
normalization_factor = normalization_factor ./thickness;
%=========================================================================
% --- end of calculating absolute intensities
% =========================================================================
end
