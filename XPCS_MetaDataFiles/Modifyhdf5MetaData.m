function Modifyhdf5MetaData(ccdimginfo)
% file=ccdimginfo.fullpath_info_name;
% file=cellstr(file);
% file=file{1};
% 
% warning('OFF','MATLAB:imagesci:hdf5dataset:datatypeOutOfRange');
% try
%     h5write(file,'/xpcs/data_begin_todo',ccdimginfo.xpcs.data_begin_todo);
%     h5write(file,'/xpcs/data_end_todo',ccdimginfo.xpcs.data_end_todo);
%     h5write(file,'/xpcs/static_mean_window_size',uint64(max(floor((ccdimginfo.xpcs.data_end_todo(1)-ccdimginfo.xpcs.data_begin_todo(1)+1)/10),2)));
%     h5write(file,'/xpcs/dynamic_mean_window_size',uint64(max(floor((ccdimginfo.xpcs.data_end_todo(1)-ccdimginfo.xpcs.data_begin_todo(1)+1)/10),2)));    
% catch
% end
% 
% try
%     h5write(file,'/xpcs/dark_begin_todo',ccdimginfo.xpcs.dark_begin_todo);
%     h5write(file,'/xpcs/dark_end_todo',ccdimginfo.xpcs.dark_end_todo);
% catch
% end
% 
% end