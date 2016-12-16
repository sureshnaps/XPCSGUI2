function good_slice_list_per_frame = kinetics_slice_list(ccdimginfo)
%returns the good slices list in each frame and over the entire frames as a
%2-D matrix

num_good_slices_per_frame = (ccdimginfo.detector.kinetics.last_usable_slice - ccdimginfo.detector.kinetics.first_usable_slice+1);
num_frames = ccdimginfo.xpcs.data_end_todo - ccdimginfo.xpcs.data_begin_todo+1;
%%
good_slices=[ccdimginfo.detector.kinetics.first_usable_slice:ccdimginfo.detector.kinetics.last_usable_slice];

%%
good_slice_list=cell(1,num_frames);
good_slice_list{1}=good_slices;

for jj=2:num_frames
    tmp=[good_slices(end)+3:good_slices(end)+num_good_slices_per_frame+2];
    good_slices=tmp;
    good_slice_list{jj}=tmp;
end

good_slice_list_per_frame = reshape(cell2mat(good_slice_list),num_good_slices_per_frame,[]);

end