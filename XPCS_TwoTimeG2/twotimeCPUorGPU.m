function C = twotimeCPUorGPU(Iqt)
%%main code that computes the 2-t correlation from the Iqt array
%%depending on if Iqt is a CPU/GPU array, the computation will take place
%%in CPU/GPU
C = (Iqt.' * Iqt) ./ size(Iqt, 1);  % Mark's version, vectorized with help from Matlab Newsgroup

%%the below is too slow on a GPU, move it to CPU 
%%calculate the correct diagonal
% n2tframes=size(Iqt,2);
% for k = 1 : n2tframes
%     if ( k ~= 1 && k ~= n2tframes )
%         C(k,k) = 1/4 * (C(k-1,k)+C(k+1,k)+C(k,k-1)+C(k,k+1))               ; % calculate the diagonal as average
%     elseif ( k == 1 )
%         C(k,k) = 1/2 * (C(k+1,k)+C(k,k+1))                                 ; % calculate the diagonal as average            
%     elseif ( k == n2tframes )
%         C(k,k) = 1/2 * (C(k-1,k)+C(k,k-1))                                 ; % calculate the diagonal as average
%     end
% end

if isa(Iqt,'gpuArray')
    C=gather(C);
end

end