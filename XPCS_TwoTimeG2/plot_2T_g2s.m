function plot_2T_g2s(TwoTimeInfo)
%function stolen from viewresult.m
dt{1}=[1:size(TwoTimeInfo.g2full,2)]';
x{1} = TwoTimeInfo.dqval;
g2avg{1} = TwoTimeInfo.g2full;
g2avgErr{1} = NaN*TwoTimeInfo.g2full;
% g2avgFIT1 = NaN*TwoTimeInfo.g2full;
% g2avgFIT2 = NaN*TwoTimeInfo.g2full;
% tauFIT1 = NaN *TwoTimeInfo.qphi_bin_to_process;
% tauFIT2 = NaN *TwoTimeInfo.qphi_bin_to_process;

[~,udata.filename,~] = fileparts(TwoTimeInfo.hdf5_filename);
title_label_str0 = 'q=';

%%
udata.settings.G2Panel = 9;
udata.settings.G2PanelRow = 3;
udata.settings.G2PanelCol = 3;
udata.settings.DynamicFigPos = [100 50 960 720];
udata.settings.DynamicNumberOfG2Figures = Inf;
udata.settings.Batch = 1;

%%
for ii=1:length(udata.settings.Batch)
    for jj=1:min(udata.settings.G2Panel*udata.settings.DynamicNumberOfG2Figures,length(x{ii}))
        if mod(jj-1,udata.settings.G2Panel) == 0
            set(figure(figure_handle_check(6000)),...
                'position',udata.settings.DynamicFigPos,...
                'Name',['G2 - ',udata.filename,' - Batch #',num2str(udata.settings.Batch(ii))],...
                'Tag','viewresult_Fig_G2',...
                'PaperOrientation','landscape',...
                'PaperPositionMode','manual',...
                'PaperSize',[11 8.5],...
                'PaperType','usletter',...
                'PaperPosition',[0.25 0.25 10.5 7.75]);
            
            supertitle([udata.filename,' - Batch #',num2str(udata.settings.Batch(ii))]);
        end
        subplot(udata.settings.G2PanelRow,udata.settings.G2PanelCol,mod(jj-1,udata.settings.G2Panel)+1);
        hold on;
        herr = errorbar(dt{ii},g2avg{ii}(jj,:),g2avgErr{ii}(jj,:),'o-','color','k');
        %         if udata.settings.DynamicG2XScale == 2
        %             %errorbarlogx;
        %             set(gca,'xscale','log');
        %         end
        %         tag_g2errorbars(herr,udata.settings.DynamicG2PlotErrorbars);
        title_label_str = [title_label_str0,num2str(x{ii}(jj))];
        %         if udata.settings.DynamicFitting == 1 || udata.settings.DynamicFitting == 3
        %            title_label_str = [title_label_str,' (',num2str(tauFIT1{ii}(jj),'%.2f'),'s)'];
        %             plot(dt{ii},g2avgFIT1{ii}(jj,:),'b-');
        %         end
        %         if udata.settings.DynamicFitting == 2 || udata.settings.DynamicFitting == 3
        %             title_label_str = [title_label_str,' (',num2str(tauFIT2{ii}(jj),'%.2f'),'s)'];
        %             plot(dt{ii},g2avgFIT2{ii}(jj,:),'r-');
        %         end
        
        hold off; box on;
        set(gca,'xminortick','on');
        xlims = (get(gca,'xlim'));
        set(gca,'xlim',[0,max(dt{1})]);
        %         if udata.settings.DynamicG2XScale == 2
        %             xlim_min = 10.^floor(log10(dt{ii}(1)));
        %             xlim_max = 10.^ceil(log10(dt{ii}(end)));
        %             set(gca,'xlim',[xlim_min,xlim_max]);
        %             set(gca,'xtick',10.^(floor(log10(xlims(1))):floor(log10(xlims(2)))));
        %         end
        title(title_label_str);
        xlabel('dt (s)');
        ylabel('g_2');
    end
end

function hfig = figure_handle_check(fign)
intn = 10^floor(log10(fign));
startn = floor(fign/intn)*intn+1;
endn = startn-1+intn;
if verLessThan('Matlab','8.4')
    h = findall(0,'type','figure');
    h = h(h<=endn & h>=startn);
else
    h = get(findall(0,'type','figure'),'number');
    if ~isempty(h)      % extract figure numbers
        if iscell(h)
            h = cell2mat(h);
        end
        h = h(h<=endn & h>=startn);
    end
end
hfig = startn;
if isempty(h)
    return;
else
    while(~isempty(find(h==hfig)))
        hfig = hfig+1;
    end
    if hfig > endn
        error('Returned figure handle exceeds the range.');
    end
end


