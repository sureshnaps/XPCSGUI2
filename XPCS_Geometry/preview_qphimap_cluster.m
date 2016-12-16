function preview_qphimap_cluster(hdf5_filename)

if (exist(hdf5_filename,'file') == 2) %means full path is provided
    %nothing to do
else
    hdf5_filename = fullfile('/home/8-id-i/partitionMapLibrary/2016-3/',hdf5_filename);
end
    [~,~,foo_ext]=fileparts(hdf5_filename);

if isempty(foo_ext)
    hdf5_filename=strcat(hdf5_filename,'.h5');
end
clear foo_ext;


dqmap=h5read(hdf5_filename,'/data/dynamicMap');
sqmap=h5read(hdf5_filename,'/data/staticMap');

ccdx0=h5read(hdf5_filename,'/data/ccdx0');
ccdz0=h5read(hdf5_filename,'/data/ccdz0');

ccdx=h5read(hdf5_filename,'/data/ccdx');
ccdz=h5read(hdf5_filename,'/data/ccdz');

snoq=h5read(hdf5_filename,'/data/snoq');
snophi=h5read(hdf5_filename,'/data/snophi');

dnoq=h5read(hdf5_filename,'/data/dnoq');
dnophi=h5read(hdf5_filename,'/data/dnophi');

sqval=h5read(hdf5_filename,'/data/sqval');
sphival=h5read(hdf5_filename,'/data/sphival');

dqval=h5read(hdf5_filename,'/data/dqval');
dphival=h5read(hdf5_filename,'/data/dphival');

figure(65535);
subplot(2,1,1);
imagesc(dqmap');axis image;axis xy;colorbar;title('dynamic qphi Map');
subplot(2,1,2);
imagesc(sqmap');axis image;axis xy;colorbar;title('static qphi Map');

num_pix_bin = histc(dqmap(:),nonzeros(unique(dqmap)));

disp('dynamic q-values are:');
a_tmp = [dqval,num_pix_bin];
format longg;
disp(array2table(a_tmp,'VariableNames',{'dynamic_q_values','Num_Pixels_in_bin'}));

fprintf('CCD positions are: ccdx=%f,ccdz=%f,ccdx0=%f,ccdz0=%f\n',ccdx,ccdz,ccdx0,ccdz);

end
