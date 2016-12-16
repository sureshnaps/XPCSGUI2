function SG = qparallel_avg_SG(varargin)
%%
hdf5_filename=varargin{1};
AvgData = varargin{2};

sqmap=transpose(h5read(hdf5_filename,'/xpcs/sqmap'));
sqmap(sqmap==-1)=0;

%%
R=sqmap;
w=find(sqmap);
rr=R(w);
%
radius_bin_step=0;
bins=min(rr)+radius_bin_step:max(1,radius_bin_step):max(rr)-radius_bin_step;

[h,b]=histc(rr,bins);

c=accumarray(b+1,AvgData(w)');

Sq=c(2:end)./max(1,h(1:end));


SG=zeros(size(AvgData));
SG(w)=interp1(double(bins),double(Sq),double(rr));
end

