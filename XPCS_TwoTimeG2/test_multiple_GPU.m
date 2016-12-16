parpool('local', 2); % 13b syntax - use "matlabpool open local 2"
spmd
  % make each worker select a different GPU device
  gpuDevice(labindex)
end


% % parfor ii=1:2
% %     x=gpuArray(rand(4024,4024));
% %     y(ii)=mean(x(:))
% % end
% % y

% gpuDevice(1);
% gpuDevice(2);

tic;
parfor kk=1:2
    gpuDevice(kk);
    Iqt_GPU=gpuArray(Iqt{kk});
    C{kk}=twotimeCPUorGPU(Iqt_GPU);
    disp('Two Time Computation took so many seconds...');
end
toc;
