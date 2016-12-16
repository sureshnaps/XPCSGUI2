function [ goodN ] = fft_good( N )
%FFT_GOOD Stolen from convol.i include with yorick and then MS
%        returns the smallest number of the form 2^x*3^y*5^z greater
%     than or equal to n.  An fft of this length will be much faster
%     than a number with larger prime factors; the speed difference
%     can be an order of magnitude or more.

%     For n>100, the worst cases result in a little over a 11% increase
%     in n; for n>1000, the worst are a bit over 6%; still larger n are
%     better yet.  The median increase for n<=10000 is about 1.5%.

  if N<7
      goodN = max([N 1]); 
      return
  end
  
  logN= log(N);
  n5 = 5.^[0:(logN/log(5) + 1.0e-6)]; % exact integers
  n3 = 3.^[0:(logN/log(3) + 1.0e-6)]; % exact integers
  n35 = n3'*n5;
  n35 = n35(n35<N);
  n235 = 2.^floor(((logN-log(n35))/log(2) + 0.999999)) .* n35;
  goodN =  min(n235);
end

