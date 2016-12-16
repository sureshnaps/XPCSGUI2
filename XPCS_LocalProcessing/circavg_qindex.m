function Sq = circavg_qindex(varargin)
%%
AvgData = varargin{1};
sindexmap=varargin{2};

if issparse(AvgData)
    AvgData = full(AvgData);
end

sindexmap(sindexmap==-1)=0;

%%
sindex_nonzeros=find(sindexmap);
pixel_location=sindexmap(sindex_nonzeros);

qbin_indices=nonzeros(unique(sindexmap));

[num_pixels,bins]=histc(pixel_location,qbin_indices);

Sq_not_norm=accumarray(bins,AvgData(sindex_nonzeros));

Sq=Sq_not_norm./max(1,num_pixels);
end

