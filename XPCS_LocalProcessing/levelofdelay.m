function lOfDelay = levelofdelay(delay,dpl)
% ---
lOfDelay = zeros(1,length(delay))                                          ; % initialize lOfDelay
% ---
lOfDelay(delay<dpl)  = 0                                                   ;
lOfDelay(delay>=dpl) = ceil(log((delay(delay>=dpl)+1)./dpl)/log(2))        ;
end