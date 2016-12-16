function TwoTimeInfo = Compute_TwoTime2OneTime(TwoTimeInfo)

disp('Starting 2T to 1T calculation');
two_time_to_onetime_start = tic;

qphi_bin_to_process = TwoTimeInfo.qphi_bin_to_process;

TwoTimeInfo.g2full = zeros(numel(qphi_bin_to_process),size(TwoTimeInfo.C{1},1)-1);
%%
for ii=1:numel(qphi_bin_to_process)
    try
        dim=size(TwoTimeInfo.C{ii},1);
        if isempty(TwoTimeInfo.Num_g2partials)
            TwoTimeInfo.Num_g2partials = 2;
        end
        g2partial_step_size = floor((dim+1)/max(TwoTimeInfo.Num_g2partials,2));
        
        [g2full,bing2partials]=twotime_to_onetime(TwoTimeInfo.C{ii},g2partial_step_size);
        
        TwoTimeInfo.g2full(ii,:) = g2full;
        
        if ~isfield(TwoTimeInfo,'g2partials')
            TwoTimeInfo.g2partials = NaN(numel(qphi_bin_to_process),numel(bing2partials),max(cellfun(@numel, bing2partials)));
        end
        
        for jj=1:numel(bing2partials)
            TwoTimeInfo.g2partials(ii,jj,1:numel(bing2partials{jj})) = bing2partials{jj};
        end
    catch
        fprintf('Failed: 2T---->1T for bin# %i\n',ii);
        %nothing to do
    end
end
%%
time_for_twotime_to_onetime = toc(two_time_to_onetime_start);
fprintf('Computing of 2T to 1T of all the Bins are done in %i Seconds\n',round(time_for_twotime_to_onetime));
