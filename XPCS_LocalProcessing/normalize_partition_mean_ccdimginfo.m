function normalization_factor = normalize_partition_mean_ccdimginfo(ccdimginfo)
%=========================================================================
% --- try to calculate absolute intensities
% The output of this function will be used to multiply the partition mean
% values at each static q-partition (in Hadoop map-reduce)
%Suresh, Sep 7, 2012
%=========================================================================
normalization_factor=1.0;
%=========================================================================
dpix_x=ccdimginfo.detector.dpix_x;
dpix_y=ccdimginfo.detector.dpix_y;
efficiency=ccdimginfo.detector.efficiency;
adupphot=ccdimginfo.detector.adu_per_photon;
preset=ccdimginfo.detector.exposure_time;
rr=ccdimginfo.detector.distance;
% flux_incident=h5read(hdf5_MetaDataFile,'/measurement/instrument/source_begin/beam_intensity_incident');
try
    flux_transmitted=max(ccdimginfo.measurement.instrument.source_begin.transmitted_flux,1.0);
catch
    flux_transmitted = 1.0;
end
thickness=ccdimginfo.measurement.sample.thickness;

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
