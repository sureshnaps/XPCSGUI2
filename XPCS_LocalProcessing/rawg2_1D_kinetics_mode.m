function [dt,G2,IP,IF,Istd] = rawg2_1D_kinetics_mode(img, dpl, framespacing, ccdimginfo)
% %computes the good slice list over the entire time series frames

good_slice_list_per_frame = kinetics_slice_list(ccdimginfo);
%extracts good slice img over the entire frames
sliceimg = cell(1,size(good_slice_list_per_frame,2));
for ii=1:size(good_slice_list_per_frame,2)
    sliceimg{ii} = img(:,good_slice_list_per_frame(:,ii));
end
%computes slice spacing in time for the delay vector
slice_spacing = ccdimginfo.detector.exposure_time;

%initializes and computes slice correlations as a sum
[sliceG2avg,sliceIPavg,sliceIFavg] = deal(zeros(size(sliceimg{1},1),size(sliceimg{1},2)-1));
framedata = cell(1,size(good_slice_list_per_frame,2));

parfor ii=1:numel(sliceimg)
    [~,sliceG2,sliceIP,sliceIF] = rawg2_1D(sliceimg{ii},size(good_slice_list_per_frame,1),slice_spacing);
    framedata{ii} = mean(sliceimg{ii},2);
    sliceG2avg = sliceG2avg + sliceG2;
    sliceIPavg = sliceIPavg + sliceIP;
    sliceIFavg = sliceIFavg + sliceIF;
end

%average slice correlations
sliceG2avg = sliceG2avg ./numel(sliceimg);
sliceIPavg = sliceIPavg ./numel(sliceimg);
sliceIFavg = sliceIFavg ./numel(sliceimg);

%%
%compute the extra (bonus) slide dt between last slice of one frame and the
%first slice of the next frame (time spacing of framespacing minus exptime
%per slice times number of slices per frame but one less
last = good_slice_list_per_frame(1,2:end)';
first = good_slice_list_per_frame(end,1:end-1)';

bonusG2avg = mean((img(:,last) .* img(:,first)),2);
bonusIFavg = mean(img(:,first),2);
bonusIPavg = mean(img(:,last),2);

bonus_spacing = framespacing - (slice_spacing * double(ccdimginfo.detector.rows/ccdimginfo.detector.kinetics.window_size -1));
%%
%per frame slice averaged data for inter-frame correlations
framedata = cell2mat(framedata);
%compute inter-frame correlations
[framedt,frameG2,frameIP,frameIF] = rawg2_1D(framedata,dpl,framespacing);

%update result fields by concatenating slice and frame correlations
slicedt = ( 1:size(good_slice_list_per_frame,1) -1 )*slice_spacing;

dt = [slicedt,bonus_spacing,framedt];
G2 = [sliceG2avg,bonusG2avg,frameG2];
IP = [sliceIPavg,bonusIPavg,frameIP];
IF = [sliceIFavg,bonusIFavg,frameIF];

Istd = (mean(img,2).^2);
end