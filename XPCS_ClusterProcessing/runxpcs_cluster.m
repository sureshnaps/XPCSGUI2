function runxpcs_cluster(varargin)

metadatafile_local = varargin{1};
xpcs_hdf5_group = varargin{2};
data_folder = varargin{3};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
metadatafile_remote=strrep(metadatafile_local,'/net/wolf/data/','/data/');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pipeline(output_hdf5_metadata_fullfile_remote,data_folder,hdf5_xpcs_group_name_new);
% Pipeline_Magellan(output_hdf5_metadata_fullfile_local,data_folder,hdf5_xpcs_group_name_new);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global SELECT_XPCS_CLUSTER
try
    if (isempty(SELECT_XPCS_CLUSTER) || strcmpi(SELECT_XPCS_CLUSTER,'APS') ...
            || strcmpi(SELECT_XPCS_CLUSTER,'Default'))
        Pipeline(metadatafile_remote,data_folder,xpcs_hdf5_group);
        if (~strcmpi(SELECT_XPCS_CLUSTER,'Default'))
            SELECT_XPCS_CLUSTER = 'MCS';
        end
        
    elseif (strcmpi(SELECT_XPCS_CLUSTER,'MCS'))
        Pipeline_Magellan(metadatafile_local,data_folder,xpcs_hdf5_group);
        SELECT_XPCS_CLUSTER = 'APS';
    else
        disp('Seems like neither the APS or the MCS cluster is working');
        return;
    end
catch
    disp('Seems like neither the APS or the MCS cluster is working');
    return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%