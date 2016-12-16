function hdf5_create_file(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
full_hdf5_filename=varargin{1};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fcpl = H5P.create('H5P_FILE_CREATE');
fapl = H5P.create('H5P_FILE_ACCESS');
if ~( (exist(full_hdf5_filename,'file')) && H5F.is_hdf5(full_hdf5_filename) )%%hdf5 file does not exist
    hdf_fid=H5F.create(full_hdf5_filename,'H5F_ACC_TRUNC',fcpl,fapl);
    H5F.close(hdf_fid);
else
    disp('HDF5 already exists');
end

end
