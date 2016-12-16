function C = twotimediagonal(C)
%%calculate the correct diagonal of two time g2
n2tframes=size(C,2);
for k = 1 : n2tframes
    if ( k ~= 1 && k ~= n2tframes )
        C(k,k) = 1/4 * (C(k-1,k)+C(k+1,k)+C(k,k-1)+C(k,k+1))               ; % calculate the diagonal as average
    elseif ( k == 1 )
        C(k,k) = 1/2 * (C(k+1,k)+C(k,k+1))                                 ; % calculate the diagonal as average            
    elseif ( k == n2tframes )
        C(k,k) = 1/2 * (C(k-1,k)+C(k,k-1))                                 ; % calculate the diagonal as average
    end
end
end