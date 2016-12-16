function [ simg, avgimg, navgimg ] = SGsmooth( img, nfilt, method)
%SGsmooth smooth using a 3rd order SG filter of size nfilt(1) X nfilt(2) 
%   SGsmooth smooth using a 3rd order SG filter of size nfilt(1) X nfilt(2)
%   nfilt is typically 21 X 21 - i.e. [21 21]
filter = mksgfilt(size(img),nfilt, method);
if strcmp('conv2', method) == 1
    simg = conv2conv(img, filter, nfilt);
elseif strcmp('fft', method) == 1
    simg=fftconv(img,filter,nfilt);
end

nz=simg~=0;
avgimg=img;
avgimg(nz)=img(nz)./simg(nz);
navgimg = avgimg-1;

end

function [simg] = fftconv(IMG, sgfft, N)
%fftconv convolve by fft. IMG is to be smoothed, sgfft is fft of filter
%   and N is filter size (must be length 2). Note: sgfft should be divided
%   by numberof(sgfft) so inverse fft is correct.
simg=IMG;
b=zeros(size(sgfft));
b(1:size(IMG,1),1:size(IMG,2))=IMG;
c=real(ifft2(fft2(b).*sgfft));
Nlim = floor(N/2);
simg(Nlim+1:end-Nlim,Nlim+1:end-Nlim)=c(N(1):size(IMG,1),N(2):size(IMG,2));

end

function [simg] = conv2conv(IMG, filter, N)
%conv2conv convolve with MATLAB conv2 function
simg=IMG;
simgTmp = conv2(IMG, filter, 'valid');
Nlim = floor(N/2);
simg(Nlim+1:end-Nlim,Nlim+1:end-Nlim)=simgTmp;
end