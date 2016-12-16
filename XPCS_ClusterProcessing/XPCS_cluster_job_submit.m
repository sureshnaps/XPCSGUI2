function metadatafile_remote = XPCS_cluster_job_submit(metadatafile_local,data_folder)
%convert the file path from local NFS mount to remote cluster mount
metadatafile_remote=strrep(metadatafile_local,'/net/wolfa/data/','/data/');
Pipeline(metadatafile_remote,data_folder);
