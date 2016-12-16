gpu = gpuDevice()
N=8192; data = rand(N,N); %
for k=1:100
    tic;
    gdata = gpuArray(data); wait(gpu);
    CPU2GPU(k) = N^2*8/1024^3/toc;
    tic;
    data2 = gather(gdata); wait(gpu);
    GPU2CPU(k) = N^2*8/1024^3/toc;
end
figure;
plot(1:100,CPU2GPU,'r.',1:100,GPU2CPU,'b.');
legend('CPU->GPU','GPU->CPU');