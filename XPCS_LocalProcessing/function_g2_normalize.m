function [g2,g2err] = function_g2_normalize(G2,IP,IF,ccdimginfo)

%%
% whos G2 IP IF

if (ccdimginfo.detector.kinetics.mode == 0) %full frame mode
    G2=reshape(G2,ccdimginfo.detector.rows,ccdimginfo.detector.cols,[]);
    IP=reshape(IP,ccdimginfo.detector.rows,ccdimginfo.detector.cols,[]);
    IF=reshape(IF,ccdimginfo.detector.rows,ccdimginfo.detector.cols,[]);
else
    G2=reshape(G2,ccdimginfo.detector.kinetics.window_size,ccdimginfo.detector.cols,[]);
    IP=reshape(IP,ccdimginfo.detector.kinetics.window_size,ccdimginfo.detector.cols,[]);
    IF=reshape(IF,ccdimginfo.detector.kinetics.window_size,ccdimginfo.detector.cols,[]);
end
%%
sindexmap = ccdimginfo.partition.sindexmap;
qbin_indices=nonzeros(unique(sindexmap));

sindex_nonzeros=find(sindexmap);
pixel_location=sindexmap(sindex_nonzeros);

[num_pixels,bins]=histc(pixel_location,qbin_indices);

[G2q,IPq,IFq]=deal(ones(numel(qbin_indices),size(G2,3)));
clear qbin_indices pixel_location;
%%
%average all the G2,IP and IF values over the pixels within each static bin
parfor jj=1:size(G2,3)
    
    AvgData= G2(:,:,jj);
    a=accumarray(bins,AvgData(sindex_nonzeros));
    G2q(:,jj)=a./max(1,num_pixels);
    
    AvgData= IP(:,:,jj);
    a=accumarray(bins,AvgData(sindex_nonzeros));
    IPq(:,jj)=a./max(1,num_pixels);
    
    AvgData= IF(:,:,jj);
    a=accumarray(bins,AvgData(sindex_nonzeros));
    IFq(:,jj)=a./max(1,num_pixels);
    
end
%compute symm normalization (reduce one variable)
Isymmq = IPq .* IFq;

%%
%exclude NaN values of dq
num_real_dqs = numel(nonzeros(~isnan(ccdimginfo.partition.dmeanmap(:,1))));
[g2,g2err]=deal(ones(num_real_dqs,size(G2q,2)));
%%
%compute error bars using var (g2 per pixel) over the dynamic partition.
%This is correct for a dynamic g2 but not for a static g2 where the error
%bars are too high than the real error bar values
dindexmap = ccdimginfo.partition.dindexmap;
g2_per_pixel=G2./(IP .* IF);

for ii=1:size(G2,3)
    g2_per_pixel_tmp = g2_per_pixel(:,:,ii);
    for jj=1:num_real_dqs
        tmpg2err = g2_per_pixel_tmp(dindexmap==jj);
        g2err(jj,ii) = std(tmpg2err(~isnan(tmpg2err))) * (1/sqrt(max(numel(tmpg2err(~isnan(tmpg2err))),1)));
%         g2err(jj,ii) = std(tmpg2err(~isnan(tmpg2err))) * (1/sqrt(max(numel(tmpg2err),1)));        
    end
end
%%
%find the static bins within each dynamic bin, collect them into a cell
%array for norm during the next step which can be parallelized if
%necessary, it seems very fast as is
dbin=cell(1,numel(unique(nonzeros(dindexmap))));
for ii=1:numel(unique(nonzeros(dindexmap))) % loop over dynamic bins
        dbin{ii}=unique(sort(sindexmap(dindexmap==ii)));       
end
%%
%loop over the dynamic bins and average (G2 ./ Isymm) within each static
%bin and then do an average over the static bins to get the ultimate dynamic bin g2
for ii=1:numel(dbin)
    tmpG2q=G2q(dbin{ii},:);
    tmpIsymmq=Isymmq(dbin{ii},:);
    g2(ii,:) = mean((tmpG2q ./ tmpIsymmq),1);
end
%%
g2=reshape(g2,[size(g2,1),1,size(g2,2)]);
g2err=reshape(g2err,[size(g2err,1),1,size(g2err,2)]);
%%

