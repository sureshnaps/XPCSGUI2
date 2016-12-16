function [ sgfilt ] = mksgfilt( d, N, method )
%mksgfilt 2-D SG filter fft'ed and padded to a nice size (fft) or not (conv2).
%   Returns a 2-D SG filter. d is size(img), and N is filter size (row X col)
%   For method == 'fft', padded to a nice size and fft'ed
%   For method == 'conv2', returns SG coeffecients in N(1) X N(2) array

SGPOLY = 3; % degree of SG polynomial in X and Y direction
SGCOUPLE = 0; % x, y coupling term for 2-D SG filter 

rowLim = floor(N(1)/2);
colLim = floor(N(2)/2);
tmp_sgfilt=sgsf_2d(-rowLim:rowLim, -colLim:colLim, SGPOLY, SGPOLY, SGCOUPLE);

if strcmp('conv2', method) == 1
       sgfilt=tmp_sgfilt;
elseif strcmp('fft', method) == 1
       d(1)=fft_good(d(1)+N(1));
       d(2)=fft_good(d(2)+N(2));
       sgfilt = zeros(d(1),d(2));
       sgfilt(1:N(1),1:N(2))=tmp_sgfilt;
       %sgfilt = fft2(sgfilt)/numel(sgfilt); % Mark uses this normalization
       % but it seems to make resulting convolution too small by this
       % factor so eliminate this normalization
       sgfilt = fft2(sgfilt);
end
end