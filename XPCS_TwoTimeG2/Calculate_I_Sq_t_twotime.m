function Isqt = Calculate_I_Sq_t_twotime(data,sqmap)
%%try to do Mark's 2nd level of norm that is based on q
%%not sure if this is needed

%sqmap contains zeros that does not work with accumarray, so fix that
num_sqmap_unique=numel(unique(nonzeros(sqmap)));
sqmap(sqmap==0)=num_sqmap_unique+1; %change zero to the last+1 index

Isqt=accumarray(sqmap(:),data(:));

Isqt=Isqt(1:num_sqmap_unique); %get rid of the last value which is for zero

sqmap(sqmap==num_sqmap_unique+1)=0; %undo the last change

sqmap_pixel_count=histc(nonzeros(sqmap),unique(nonzeros(sqmap)));

Isqt=Isqt./sqmap_pixel_count;
end
