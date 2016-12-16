function Iqt_data = GPU_Split_Iqt_Array(Iqt,GPU_MEMORY_LIMIT_BYTES)
%%When the Iqt array exceeds GPU memory, split the array into groups of
%%lesser pixels and then calculate two-time for each group and then average
%%them together to get the final 2-t 

if iscell(Iqt)
    disp('Iqt array cannot be a cell at the input of function:GPU_Split_Iqt_Array. Exiting...');
    return;
end

Iqt_ARRAY_NUM_PIXELS_MAX = floor(GPU_MEMORY_LIMIT_BYTES/(size(Iqt,2)*4)); %%4 is for single precision bytes
 
Iqt_section_index=1:Iqt_ARRAY_NUM_PIXELS_MAX:size(Iqt,1);
 
Iqt_section_index(end+1)=size(Iqt,1)+1;

for jj=1:numel(Iqt_section_index)-1
    foo_index=(Iqt_section_index(jj) : Iqt_section_index(jj+1) -1 );
    Iqt_data{jj}=Iqt(foo_index,:);
end

end
