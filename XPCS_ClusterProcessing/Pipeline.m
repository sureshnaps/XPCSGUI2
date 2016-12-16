function Pipeline(varargin)
%submit job to Hadoop Cluster with the metadata hdf file as the input
%arg1: full path and hdf file name

metadatafile=varargin{1};
if (nargin>=2)
    job_name=varargin{2};
else
    job_name=varargin{1};
end


%%
%%pipeline .jar files are located in:
%%/home/beams/8IDIUSER/Pipeline_All/workingVersion/


ACTIVE_MQ_URL = 'tcp://mqvm-1:61616';
% ACTIVE_MQ_URL = 'tcp://mqvm-2:61616';
if (nargin==3)
    endpoint=varargin{3};
else
    endpoint = '/xpcs';
end

%%
% Launch pipeline with XPCS and Python (Data Fitting) actor
%cmd=sprintf('java -classpath /home/beams/8IDIUSER/Pipeline_All/workingVersion/sdm-pipeline-0.0.1-all.jar -Dlog4j.configuration=file:/home/beams/8IDIUSER/Pipeline_All/workingVersion/log4j.properties gov.anl.aps.aes.pipeline.tools.LaunchJob -b %s -i %s,%s -o %s,%s -p XPCS.8-ID-I -r XPCS,Python -n %s', ACTIVE_MQ_URL,metadatafile,metadatafile,metadatafile,metadatafile,job_name);
cmd=sprintf('java -classpath /home/beams/8IDIUSER/Pipeline_All/workingVersion/sdm-pipeline-0.0.1-all.jar -Dlog4j.configuration=file:/home/beams/8IDIUSER/Pipeline_All/workingVersion/log4j.properties gov.anl.aps.aes.pipeline.tools.LaunchJob -b %s -i %s,%s -o %s,%s -p XPCS.8-ID-I -r XPCS,Python -n %s -e %s,%s', ACTIVE_MQ_URL,metadatafile,metadatafile,metadatafile,metadatafile,job_name,endpoint,endpoint);

% Launch pipeline with XPCS actor and without python fitting
% cmd=sprintf('java -classpath /home/beams/8IDIUSER/Pipeline_All/workingVersion/sdm-pipeline-0.0.1-all.jar -Dlog4j.configuration=file:/home/beams/8IDIUSER/Pipeline_All/workingVersion/log4j.properties gov.anl.aps.aes.pipeline.tools.LaunchJob -b %s -i %s -o %s -p XPCS.8-ID-I -r XPCS -n %s',ACTIVE_MQ_URL,metadatafile,metadatafile,job_name);
% cmd=sprintf('java -classpath /home/beams/8IDIUSER/Pipeline_All/workingVersion/sdm-pipeline-0.0.1-all.jar -Dlog4j.configuration=file:/home/beams/8IDIUSER/Pipeline_All/workingVersion/log4j.properties gov.anl.aps.aes.pipeline.tools.LaunchJob -b %s -i %s -o %s -p XPCS.8-ID-I -r XPCS -n %s -e %s',ACTIVE_MQ_URL,metadatafile,metadatafile,job_name,endpoint);


% Launch pipeline with Python actor and without XPCS
% cmd=sprintf('java -classpath /home/beams/8IDIUSER/Pipeline_All/workingVersion/sdm-pipeline-0.0.1-all.jar -Dlog4j.configuration=file:/home/beams/8IDIUSER/Pipeline_All/workingVersion/log4j.properties gov.anl.aps.aes.pipeline.tools.LaunchJob -b %s -i %s -o %s -p XPCS.8-ID-I -r Python -n %s',ACTIVE_MQ_URL,metadatafile,metadatafile,job_name);
% cmd=sprintf('java -classpath /home/beams/8IDIUSER/Pipeline_All/workingVersion/sdm-pipeline-0.0.1-all.jar -Dlog4j.configuration=file:/home/beams/8IDIUSER/Pipeline_All/workingVersion/log4j.properties gov.anl.aps.aes.pipeline.tools.LaunchJob -b %s -i %s -o %s -p XPCS.8-ID-I -r Python -n %s -e %s',ACTIVE_MQ_URL,metadatafile,metadatafile,job_name,endpoint);


% % disp(cmd);
system(cmd);
disp('Submitted XPCS job to Hadoop Cluster')
