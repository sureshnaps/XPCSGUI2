function Reset_GPUs
fprintf('Resetting the memory in all the GPUs\n\n');
for ii=1:gpuDeviceCount
    gpuDevice(ii);
end
end