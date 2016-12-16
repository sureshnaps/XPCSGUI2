function Iqt_out = Convert_Iqt_3d_to_cell(Iqt,dqmap_index_qbin,qphi_bin_to_process)
%converts Iqt that is saved as 3d array into a cell array to save memory
Iqt_out=cell(1,numel(unique(nonzeros(dqmap_index_qbin))));
for jj=1:size(Iqt,1)
    dqmap_index_jj=(dqmap_index_qbin == qphi_bin_to_process(jj));
    foo=squeeze(Iqt(jj,:,:));
    foo = foo(~isnan(foo));
    foo = reshape(foo,numel(find(dqmap_index_jj==1)),size(Iqt,3));
    Iqt_out{jj}=foo;
end
