function Memory_Required_GBytes = TwoTime_Memory_Requirements(varargin)
%%
TwoTimeInfo = varargin{1};

try
    xpcs_entry = TwoTimeInfo.xpcs_entry;
catch
    xpcs_entry = '/xpcs';
end
%%
hdf5_filename=TwoTimeInfo.hdf5_filename;
qphi_bin_to_process = TwoTimeInfo.qphi_bin_to_process;
%%
try
    data_begin_todo = TwoTimeInfo.data_begin;
    data_end_todo = TwoTimeInfo.data_end;
catch
    data_begin_todo=double(h5read(hdf5_filename,[xpcs_entry,'/data_begin_todo']));
    data_end_todo=double(h5read(hdf5_filename,[xpcs_entry,'/data_end_todo']));
end

if isempty(TwoTimeInfo.qmap_filename)
    dqmap=transpose(h5read(hdf5_filename,[xpcs_entry,'/dqmap']));
else
    dqmap=transpose(h5read(TwoTimeInfo.qmap_filename,'/data/dynamicMap'));
end
%%
n2tframes = numel(double(data_begin_todo:TwoTimeInfo.stride_frames:data_end_todo));
%%
dqmap_index_qbin=zeros(size(dqmap));
for jj=1:numel(qphi_bin_to_process)
    dqmap_index_qbin=dqmap_index_qbin+(dqmap == qphi_bin_to_process(jj))*double(qphi_bin_to_process(jj));
end
%%
binpixlist = cell(1,numel(unique(nonzeros(dqmap_index_qbin))));
dqmap_bins_unique = unique(nonzeros(dqmap_index_qbin));
for jj=1:numel(unique(nonzeros(dqmap_index_qbin)))
    binpixlist{jj} = find(dqmap_index_qbin==dqmap_bins_unique(jj));
end
%%
Memory_Required_GBytes = max(cellfun(@numel,binpixlist))*numel(binpixlist)*4*n2tframes/(1024^3);

%%
TwoTime_Results_GBytes = n2tframes * n2tframes *4/(1024^3) *numel(binpixlist) ;
%%
fprintf('TwoTime under the given conditions will require ****%i GBytes**** of RAM to store the Input Arrays...\n',ceil(Memory_Required_GBytes));
fprintf('TwoTime under the given conditions will require ****%i GBytes**** of RAM to store the Output Arrays...\n',ceil(TwoTime_Results_GBytes));
end