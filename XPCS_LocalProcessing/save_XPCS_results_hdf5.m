function save_XPCS_results_hdf5(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hdf5_metadata_fullfile=varargin{1};
xpcs_group_location=varargin{2};
result_structure=varargin{3};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
result_group_location=h5read(hdf5_metadata_fullfile,[xpcs_group_location,'/output_data']);
if iscellstr(result_group_location)
    result_group_location = result_group_location{1};
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nBatch=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%Raw calculation results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/pixelSum'],transpose(result_structure.aIt{nBatch}));
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/pixelSum'],size(transpose(result_structure.aIt{nBatch})));
    h5write(hdf5_metadata_fullfile,[result_group_location,'/pixelSum'],transpose(result_structure.aIt{nBatch}));
end

try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/frameSum'],[transpose(1:numel(result_structure.totalIntensity{nBatch})),result_structure.totalIntensity{nBatch}]);
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/frameSum'],[size(result_structure.totalIntensity{nBatch},1),2]);
    h5write(hdf5_metadata_fullfile,[result_group_location,'/frameSum'],[transpose(1:numel(result_structure.totalIntensity{nBatch})),result_structure.totalIntensity{nBatch}]);
end

try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/partition-mean-total'],result_structure.Iqphi{nBatch});
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/partition-mean-total'],size(result_structure.Iqphi{nBatch}));
    h5write(hdf5_metadata_fullfile,[result_group_location,'/partition-mean-total'],result_structure.Iqphi{nBatch});
end

%Iqphit is converted from 3-D to 2-D for saving to hdf5, loadhdf5result
%will convert to 3-D when plotting
foo_Iqphit=result_structure.Iqphit{nBatch};
if (ndims(foo_Iqphit) == 3)
    foo_Iqphit = reshape(foo_Iqphit,size(foo_Iqphit,1)*size(foo_Iqphit,2),[]);
end
try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/partition-mean-partial'],foo_Iqphit);
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/partition-mean-partial'],size(foo_Iqphit));
    h5write(hdf5_metadata_fullfile,[result_group_location,'/partition-mean-partial'],foo_Iqphit);
end

tau_values = result_structure.delay{nBatch}./result_structure.framespacing{nBatch};
try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/tau'],tau_values);
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/tau'],size(tau_values));
    h5write(hdf5_metadata_fullfile,[result_group_location,'/tau'],tau_values);
end

try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/norm-0-g2'],result_structure.g2avg{nBatch});
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/norm-0-g2'],size(result_structure.g2avg{nBatch}));
    h5write(hdf5_metadata_fullfile,[result_group_location,'/norm-0-g2'],result_structure.g2avg{nBatch});
end

try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/norm-0-stderr'],result_structure.g2avgErr{nBatch});
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/norm-0-stderr'],size(result_structure.g2avgErr{nBatch}));
    h5write(hdf5_metadata_fullfile,[result_group_location,'/norm-0-stderr'],result_structure.g2avgErr{nBatch});
end

result_structure.timeStamps;
foo_timestamps = transpose([(1:numel(result_structure.timeStamps{nBatch}));result_structure.timeStamps{nBatch}]);
try
    h5write(hdf5_metadata_fullfile,[result_group_location,'/timeStamps'],foo_timestamps);
catch
    h5create(hdf5_metadata_fullfile,[result_group_location,'/timeStamps'],size(foo_timestamps));
    h5write(hdf5_metadata_fullfile,[result_group_location,'/timeStamps'],foo_timestamps);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
