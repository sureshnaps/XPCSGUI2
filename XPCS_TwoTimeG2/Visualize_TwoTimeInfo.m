function Visualize_TwoTimeInfo(varargin)

TwoTimeInfo = varargin{1};
qphi_bin_to_process = varargin{2};

if (isempty(TwoTimeInfo.g2full) || isempty(TwoTimeInfo.g2partials))
    %use default of 2 partials for g2
    TwoTimeInfo = Compute_TwoTime2OneTime(TwoTimeInfo);
end

try
    framespacing = TwoTimeInfo.framespacing;
catch
    framespacing = 1.0;
end

for ii=qphi_bin_to_process%1:numel(qphi_bin_to_process)
    dqmap_qbin_tmp=TwoTimeInfo.dqmap_index_qbin;
    dqmap_qbin_tmp = (dqmap_qbin_tmp ==ii)*ii;
    
    %     dqmap_qbin_tmp = (dqmap_qbin_tmp ==qphi_bin_to_process(ii));%*qphi_bin_to_process(ii);
    
    g2full = squeeze(TwoTimeInfo.g2full(ii,:));
    
    for k=1:size(TwoTimeInfo.g2partials,2)
        g2p1{k} = squeeze(TwoTimeInfo.g2partials(ii,k,:));
    end
    %%
    markerlist = varymarker(size(TwoTimeInfo.g2partials,2));
    colorlist = varycolor(size(TwoTimeInfo.g2partials,2));
    
    figure;
    subplot(2,2,1);imagesc(TwoTimeInfo.dqmap);axis image;axis xy;colorbar;title('Full dqmap');
    xlabel('X (pixels)');ylabel('Y (pixels)');
    subplot(2,2,2);imagesc(dqmap_qbin_tmp);axis image;axis xy;colorbar;title('Selected q-bin');
    xlabel('X (pixels)');ylabel('Y (pixels)');

%     subplot(2,2,3);imagesc(TwoTimeInfo.C{ii});axis image;axis xy;colorbar;title('Two Time');
    subplot(2,2,3);imagesc(TwoTimeInfo.C{ii},'XData',[1,size(TwoTimeInfo.C{ii},1)]*framespacing,...
        'YData',[1,size(TwoTimeInfo.C{ii},1)]*framespacing);axis image;axis xy;colorbar;title('Two Time');
    xlabel('t_1 (sec)');ylabel('t_2 (sec)');
    
    subplot(2,2,4);hold off;
    semilogx((1:numel(g2full)).*framespacing,g2full,'bo-');
    for k=1:size(TwoTimeInfo.g2partials,2)
        hold on;
        semilogx((1:numel(g2p1{k})).*framespacing,g2p1{k},'marker',markerlist{k},'color',colorlist(k,:));
    end
    xlabel('dt (sec)');ylabel('g_2');
    legend show;
    tmp_legend=legend;
    tmp_legend.String{1}='Full';
    for jj=2:size(TwoTimeInfo.g2partials,2)+1
        tmp_legend.String{jj}=num2str(jj-1);
    end
    
    try
        [~,b,~]=fileparts(TwoTimeInfo.hdf5_filename);
        supertitle(b);
    catch
        %no title available to put on the plot
    end
end
