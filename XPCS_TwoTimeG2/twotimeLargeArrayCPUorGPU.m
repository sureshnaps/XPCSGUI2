function D = twotimeLargeArrayCPUorGPU(Iqt,Force_CPU)

try
    Use_GPU=1;
    GPU_id = gpuDevice;
    %0.75 is safety allowance and another 0.5 seems to be for the 2 copies of Iqt array???
    GPU_MEMORY_LIMIT_BYTES = GPU_id.TotalMemory * 0.75 * 0.3;
catch
    Use_GPU=0;
end

if (nargin == 2)
    if (Force_CPU == 1)
        Use_GPU = 0;
    end
end

foo=whos('Iqt');
GPU_Data_Bytes = foo.bytes;clear foo;
GPU_Data_Bytes = GPU_Data_Bytes + size(Iqt,2)^2*4; %%account for the output C matrix

if (Use_GPU)
    GPU_MEMORY_OVERFILL_RATIO = ceil(GPU_Data_Bytes/GPU_MEMORY_LIMIT_BYTES);
    fprintf('--------------------------------------------------------\n');
    fprintf('GPU Array size is %f GBytes\n',GPU_Data_Bytes/(1024*1024*1024));
    fprintf('GPU_MEMORY_OVERFILL_RATIO is %d\n',GPU_Data_Bytes/GPU_MEMORY_LIMIT_BYTES);
    
    if (GPU_MEMORY_OVERFILL_RATIO > 1)
        fprintf('Split Iqt Array into ----%d---- groups of pixels to not exceed GPU Memory\n',GPU_MEMORY_OVERFILL_RATIO);
    end
    
    try
        Iqt = GPU_Split_Iqt_Array(Iqt,GPU_MEMORY_LIMIT_BYTES);
    catch
        disp('ERROR: Iqt array was not split properly, Exiting...');
        return;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Need_to_kill_parpool=0; %if multiple gpus are not there, then no need to kill parpool at the end
    if (numel(Iqt) >= gpuDeviceCount)
        if ~isempty(gcp)
            delete(gcp);
        end
        %%open a parallel pool workers of the number of GPUs
        parpool('local',gpuDeviceCount);
        
        spmd
            % make each CPU worker select a different GPU device
            gpuDevice(labindex);
        end
        Need_to_kill_parpool=1;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Num_Full_GPU_Loops = max(1,floor(numel(Iqt)/gpuDeviceCount));
    Num_Partial_GPU_Loops = mod(numel(Iqt),gpuDeviceCount);
    counter_Iqt=0;

    if (numel(Iqt) == 1) %%only one loop, so do not set up parallel pool
            gpuDevice(1);
            Iqt_GPU=gpuArray(Iqt{1});
            C{1}=twotimeCPUorGPU(Iqt_GPU);
            counter_Iqt = counter_Iqt +1;
    end
    
    %%%Fewer Iqt cells than GPUs
    if (numel(Iqt) > 1) && (numel(Iqt) < gpuDeviceCount) %%do not do parfor loops
        Reset_GPUs;
        for kk=1:numel(Iqt)
            Iqt_GPU=gpuArray(Iqt{kk});
            C{kk}=twotimeCPUorGPU(Iqt_GPU);
            counter_Iqt = counter_Iqt +1;
        end
    elseif (numel(Iqt) > 1) && (numel(Iqt) >= gpuDeviceCount) %%Num Iqt cells >= GPUs, so have to break it up - confusing !!
        for loop_counter = 1:Num_Full_GPU_Loops %%all the full GPU loops
            Reset_GPUs;
            parfor kk=(loop_counter-1)*gpuDeviceCount+1:loop_counter*gpuDeviceCount
                Iqt_GPU=gpuArray(Iqt{kk});
                C{kk}=twotimeCPUorGPU(Iqt_GPU);
            end
            counter_Iqt = counter_Iqt + gpuDeviceCount;
        end
    end
    
    %%last remaining partial gpu loops (num gpus > remaining Iqt cells)
    if (Num_Partial_GPU_Loops > 0)
        for kk=counter_Iqt+1:numel(Iqt)
            Reset_GPUs;
            Iqt_GPU=gpuArray(Iqt{kk});
            C{kk}=twotimeCPUorGPU(Iqt_GPU);
        end
    end
    
    Reset_GPUs;
    if (Need_to_kill_parpool)
        delete(gcp);
    end
    fprintf('--------------------------------------------------------\n');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%   CCCCC PU   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (~Use_GPU)
    %%Normalize each pixel intnsity Iqt by (I0t/I0) to account for variations
    %%in the scattered intensity over time. I0 is to preserve the scale of each
    %%image around a norm of unity
%     whos Iqt
    C{1}=twotimeCPUorGPU(Iqt);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
D=mean(reshape(cell2mat(C),[size(C{1}),length(C)]),3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
D = twotimediagonal(D);%%compute the correct diagonal two time g2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

