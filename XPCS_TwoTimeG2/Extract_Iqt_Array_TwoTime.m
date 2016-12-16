function [AvgData,I0t,Iqt] = Extract_Iqt_Array_TwoTime(varargin)
% Usage:
% [AvgData,I0t,Iqt] = Extract_Iqt_Array_TwoTime(imm_filename,data_begin_todo,...
% data_end_todo,stride_frames,dkavg,dqmap_index_all,dqmap_index_qbin,SByte,COMPRESSION)

imm_filename=varargin{1};
data_begin_todo=varargin{2};
data_end_todo=varargin{3};
stride_frames=varargin{4};
dkavg=varargin{5};
dqmap_index_all=varargin{6};
dqmap_index_qbin=varargin{7};
SByte=varargin{8};
COMPRESSION=varargin{9};
dark_threshold_matrix=varargin{10};
Num_CPU_Cores=varargin{11};


if (stride_frames == 0)
    stride_frames = 1;
end

frames_list = double(data_begin_todo:stride_frames:data_end_todo);
n2tframes=numel(frames_list);

AvgData=zeros(size(dqmap_index_all),'single');
Iqt = zeros(numel(nonzeros(dqmap_index_qbin)),n2tframes,'single'); % initialize Iqt

try
    if isempty(gcp('nocreate'))
        disp('Setting up a Parallel Pool of workers');
        parpool(Num_CPU_Cores);
        disp('Done Setting up a Parallel Pool of workers');
    end
catch
    disp('No Parallel processing toolbox found. Proceeding with a serial implementation');
end

if (COMPRESSION == 1)
    parfor ii=1:n2tframes
        
        data = openfile(imm_filename,frames_list(ii),SByte(ii));
        data=data.imm;
        
        AvgData = AvgData + data;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%compute Isqt - 2nd level of Mark's norm. - not sure if this is needed
        %     Isqt(:,ii)=Calculate_I_Sq_t_twotime(data,sqmap);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%compute I0t - the average of whole image per frame
        I0t(ii)=mean(data(dqmap_index_all));
        
        %%collect intensities from pixels vs time that belong to the specified qphi-bin
        Iqt(:,ii)=data(dqmap_index_qbin);
    end
end

if (COMPRESSION == 0)
    parfor ii=1:n2tframes
        data=openfile(imm_filename,frames_list(ii));
        data=data.imm;
        data=data-dkavg;
        data(data<dark_threshold_matrix)=0; %%need to use LLD here
        
        AvgData = AvgData + data;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%compute Isqt - 2nd level of Mark's norm. - not sure if this is needed
        %     Isqt(:,ii)=Calculate_I_Sq_t_twotime(data,sqmap);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%compute I0t - the average of whole image per frame
        I0t(ii)=mean(data(dqmap_index_all));
        
        %%collect intensities from pixels vs time that belong to the specified qphi-bin
        Iqt(:,ii)=data(dqmap_index_qbin);
    end
end

AvgData = AvgData ./n2tframes;

end