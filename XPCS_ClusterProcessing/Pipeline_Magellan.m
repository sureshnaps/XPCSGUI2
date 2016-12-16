function Pipeline_Magellan(varargin)
%submit job to Hadoop Cluster with the metadata hdf file as the input
%arg1: full path and hdf file name

metadatafile_in=varargin{1};
if (nargin>=2)
    job_name=varargin{2};
else
    job_name=varargin{1};
end

%%
matching_char = 'xpcs8';
a=strfind(metadatafile_in,matching_char);

metadatafile = strcat('/mnt',metadatafile_in(a+length(matching_char):end));

scp_cmd=sprintf('scp -q %s hadoop@140.221.40.81:%s ',metadatafile_in,metadatafile);
system(scp_cmd);
%%
%%pipeline .jar files are located in:
%%/home/beams/8IDIUSER/Pipeline_All/workingVersion/


ACTIVE_MQ_URL = 'tcp://mqvm-1:61616';
% % ACTIVE_MQ_URL = 'tcp://mqvm-2:61616';

endpoint = '/xpcs';
%%
% Launch pipeline with XPCS and Python (Data Fitting) actor
% cmd=sprintf('java -classpath /home/beams/8IDIUSER/Pipeline_All/workingVersion/pipeline-all.jar -Dlog4j.configuration=file:/home/beams/8IDIUSER/Pipeline_All/workingVersion/log4j.properties gov.anl.aps.aes.pipeline.tools.LaunchJob -b %s -i %s,%s -o %s,%s -p XPCS.8-ID-I -r XPCSM2,PythonM2 -n %s', ACTIVE_MQ_URL,metadatafile,metadatafile,metadatafile,metadatafile,job_name);
cmd=sprintf('java -classpath /home/beams/8IDIUSER/Pipeline_All/workingVersion/pipeline-all.jar -Dlog4j.configuration=file:/home/beams/8IDIUSER/Pipeline_All/workingVersion/log4j.properties gov.anl.aps.aes.pipeline.tools.LaunchJob -b %s -i %s,%s -o %s,%s -p XPCS.8-ID-I -r XPCSM2,PythonM2 -n %s -e %s,%s', ACTIVE_MQ_URL,metadatafile,metadatafile,metadatafile,metadatafile,job_name,endpoint,endpoint);

% Launch pipeline with XPCS actor and without python fitting
% cmd=sprintf('java -classpath /home/beams/8IDIUSER/Pipeline_All/workingVersion/pipeline-all.jar -Dlog4j.configuration=file:/home/beams/8IDIUSER/Pipeline_All/workingVersion/log4j.properties gov.anl.aps.aes.pipeline.tools.LaunchJob -b %s -i %s -o %s -p XPCS.8-ID-I -r XPCSM2 -n %s',ACTIVE_MQ_URL,metadatafile,metadatafile,job_name);
% cmd=sprintf('java -classpath /home/beams/8IDIUSER/Pipeline_All/workingVersion/pipeline-all.jar -Dlog4j.configuration=file:/home/beams/8IDIUSER/Pipeline_All/workingVersion/log4j.properties gov.anl.aps.aes.pipeline.tools.LaunchJob -b %s -i %s -o %s -p XPCS.8-ID-I -r XPCSM2 -n %s -e %s',ACTIVE_MQ_URL,metadatafile,metadatafile,job_name,endpoint);


% Launch pipeline with Python actor and without XPCS
% cmd=sprintf('java -classpath /home/beams/8IDIUSER/Pipeline_All/workingVersion/pipeline-all.jar -Dlog4j.configuration=file:/home/beams/8IDIUSER/Pipeline_All/workingVersion/log4j.properties gov.anl.aps.aes.pipeline.tools.LaunchJob -b %s -i %s -o %s -p XPCS.8-ID-I -r PythonM2 -n %s',ACTIVE_MQ_URL,metadatafile,metadatafile,job_name);
% cmd=sprintf('java -classpath /home/beams/8IDIUSER/Pipeline_All/workingVersion/pipeline-all.jar -Dlog4j.configuration=file:/home/beams/8IDIUSER/Pipeline_All/workingVersion/log4j.properties gov.anl.aps.aes.pipeline.tools.LaunchJob -b %s -i %s -o %s -p XPCS.8-ID-I -r PythonM2 -n %s -e %s',ACTIVE_MQ_URL,metadatafile,metadatafile,job_name,endpoint);


% % disp(cmd);
system(cmd);
disp('Submitted XPCS job to Hadoop Cluster')
