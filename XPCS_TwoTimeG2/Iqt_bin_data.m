function A = Iqt_bin_data(Iqt,bin_size)

if (bin_size > 1)
    if ( floor(size(Iqt,2)/bin_size)*bin_size ~= size(Iqt,2) )
        Iqt = Iqt(:,1:end-mod(size(Iqt,2),bin_size));
    end
    
    A =   reshape(mean(reshape(Iqt,size(Iqt,1),bin_size,size(Iqt,2)/bin_size),2),size(Iqt,1),size(Iqt,2)/bin_size);
else
    A=Iqt;
end
