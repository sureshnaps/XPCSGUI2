function viewresultinfo = Process_img_StaticCalc(img,ccdimginfo)
disp('Computing Static results');
tic;
pixelSum=mean(img,2);
if (ccdimginfo.detector.kinetics.mode == 0) %full frame mode
    pixelSum=reshape(pixelSum,ccdimginfo.detector.rows,ccdimginfo.detector.cols);
else %kinetics mode where ever applicable
    pixelSum=reshape(pixelSum,ccdimginfo.detector.kinetics.window_size,ccdimginfo.detector.cols);
end
pixelSum = full(pixelSum);

Sq=circavg_qindex(pixelSum,ccdimginfo.partition.sindexmap);

%compute stability plot, showing S(q) over 10 time segments
partial_size = ccdimginfo.xpcs.static_mean_window_size;
num_partials = floor((double(ccdimginfo.xpcs.data_end_todo - ccdimginfo.xpcs.data_begin_todo +1))./double(partial_size));
%exclude NaN values of Sq
num_real_sqs = numel(nonzeros(~isnan(ccdimginfo.partition.smeanmap(:,1))));
Sqt=zeros(num_real_sqs,1,num_partials);

for kk=1:num_partials
    Ipartials = mean(img(:,(kk-1)*floor(size(img,2)/num_partials)+1:kk*floor(size(img,2)/num_partials)),2);
    Ipartials = full(Ipartials);
    Sqt(:,1,kk)=circavg_qindex(Ipartials,ccdimginfo.partition.sindexmap);
end

frameSum = full(mean(img,1));
if size(frameSum,1)==1
    frameSum = transpose(frameSum);
end

try %calculate norm factor for SAXS
    normalization_factor = normalize_partition_mean_ccdimginfo(ccdimginfo);
catch
    normalization_factor = 1.0;
end

%%
viewresultinfo.result.aIt{1}=pixelSum;
viewresultinfo.result.Iqphi{1}=Sq./normalization_factor;
viewresultinfo.result.Iqphit{1}=Sqt./normalization_factor;
viewresultinfo.result.staticQs{1}=ccdimginfo.partition.smeanmap(:,1);
viewresultinfo.result.staticPHIs{1}=ccdimginfo.partition.smeanmap(:,2);

viewresultinfo.result.totalIntensity{1}=frameSum;
viewresultinfo.result.framespacing{1}=1;

viewresultinfo.result.timeStamps = ccdimginfo.xpcs.timeStamps;
%%
toc;
disp('Done Computing Static results');
end