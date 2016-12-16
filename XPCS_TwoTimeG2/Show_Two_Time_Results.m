function varargout = Show_Two_Time_Results(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TwoTimeInfo=varargin{1};

C=TwoTimeInfo.C;
AvgData = TwoTimeInfo.AvgData;
SG_smoothed_data = TwoTimeInfo.SG_smoothed_data;
Iqt = TwoTimeInfo.Iqt;
dqmap_index_qbin = TwoTimeInfo.dqmap_index_qbin;
I0t = TwoTimeInfo.I0t;
frames_bin_size = TwoTimeInfo.frames_bin_size;
stride_frames = TwoTimeInfo.stride_frames;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(130);
imagesc(dqmap_index_qbin);axis xy;colorbar;
title('Pixels in the processed q-bin','fontsize',12,'fontweight','bold');
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure(131);
% imagesc(squeeze(Iqt(1,:,:)));axis xy;colorbar;
% xlabel('Frames','fontsize',12,'fontweight','bold');
% ylabel('Pixels in the bin','fontsize',12,'fontweight','bold');
% title('Intensity in pixels in the bin vs Time','fontsize',12,'fontweight','bold');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Two time plots
%%
for k=1:numel(C)
    g2{k}=twotime_to_onetime(C{k});
    deltaframes=[1:numel(g2{k})];
    deltaframes = deltaframes*stride_frames;
    deltaframes = deltaframes*frames_bin_size;
    deltaframes = transpose(deltaframes);    
end
TwoTimeInfo.g2=g2;
TwoTimeInfo.deltaframes=deltaframes;
%%
for k=1:min(4,numel(C)) %restrict to 4 for now, no specific reason
    figure(132+k-1);
    imagesc(C{k});axis xy;colorbar;
    xlabel('t_1 (frames)','fontsize',12,'fontweight','bold');
    ylabel('t_2 (frames)','fontsize',12,'fontweight','bold');
    title('Two Time Correlation','fontsize',12,'fontweight','bold');
end    

for k=1:numel(C)
    figure(235);
    if k==1
        hold off;
    else
        hold on;
    end
    plot(TwoTimeInfo.deltaframes,TwoTimeInfo.g2{k},'bo');grid on;
    ylim([0,.2]);
    title('g_2','fontsize',12,'fontweight','bold');
    xlabel('Delta T (frames)','fontsize',12,'fontweight','bold');
    ylabel('g_2 - 1','fontsize',12,'fontweight','bold');
    set(gca,'xscale','log');
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure(133);
% imagesc(AvgData,[0, max(AvgData(:)/10)]);axis xy;colorbar;
% title('Average of all the frames','fontsize',12,'fontweight','bold');
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(334);
imagesc(SG_smoothed_data,[0, max(AvgData(:)/10)]);axis xy;colorbar;
title('Smoothed Average of all the frames','fontsize',12,'fontweight','bold');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(136);hold off;plot(I0t/mean(I0t),'ko');grid on;
% hold on;
% plot(mean(squeeze(Iqt(1,:,:)),1),'rx');
% legend('Total Intensity','Intensity in the q-bin');
title('Total Intensity in a Frame vs Frames','fontsize',12,'fontweight','bold');
xlabel('Frame #','fontsize',12,'fontweight','bold');
ylabel('Total Intensity in a Frame','fontsize',12,'fontweight','bold');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargout ==1)
    varargout{1}=TwoTimeInfo;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

