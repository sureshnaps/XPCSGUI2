function fDelays = finddelays(nframes,dpl)
% ---
% ---
mindelay=1;
if (mindelay == 0)
    imin=1                                                                 ;
else
    imin=fix(ceil(indexofdelay(max(mindelay,0),dpl)))                      ;
end
% ---
imax = fix(indexofdelay(nframes,dpl)) - 1                                  ;
if nargin == 4
    imax = min(imax,fix(indexofdelay(maxdelay,dpl)))                       ;
end
% ---
fDelays = delayofindex(imin,imax,dpl)                                      ;
end

% =========================================================================
% --- subfunction indexofdelay
% =========================================================================
function iOfDelay = indexofdelay(delay,dpl)
% ---
level    = levelofdelay(delay,dpl)                                         ; % call levelofdelay
% ---
iOfDelay = zeros(1,length(delay))                                          ; % initialize iOfDelay
% ---
iOfDelay(delay<dpl)  = delay(delay<dpl) + 1                                ;
iOfDelay(delay>=dpl) = 1 + dpl * level(delay>=dpl)                      ...
    + (delay(delay>=dpl) - dpl * 2.^(level(delay>=dpl)-1))     ...
    ./ (2.^(level(delay>=dpl)-1))                                  ;

end
% =========================================================================
% --- subfunction levelofdelay
% =========================================================================
function lOfDelay = levelofdelay(delay,dpl)
% ---
lOfDelay = zeros(1,length(delay))                                          ; % initialize lOfDelay
% ---
lOfDelay(delay<dpl)  = 0                                                   ;
lOfDelay(delay>=dpl) = ceil(log((delay(delay>=dpl)+1)./dpl)/log(2))        ;
end

% =========================================================================
% --- subfunction delayofindex
% =========================================================================
function dOfIndex = delayofindex(imin,imax,dpl)
% ---
index    = imin:imax                                                       ; % create index vector
index    = index -1                                                        ; % start index vector from zero
% ---
level    = floor(index/dpl)                                                ; % initialize level vector
dOfIndex = zeros(1,length(index))                                          ; % initialize dOfIndex vector
% ---
dOfIndex(index<dpl)  = mod(index(index<dpl),dpl)                           ;
dOfIndex(index>=dpl) = 2.^(level(index>=dpl)-1)  ...
    .* (dpl + mod(index(index>=dpl),dpl))                  ;

end
% =========================================================================
% --- subfunction delaymax
% =========================================================================
function maxdelay = delaymax(nframes,dpl)
%---
level    = levelofdelay(nframes-1,dpl)                                     ; % call levelofdelay
%---
iOfLevel = 1:dpl                                                           ; % initialize index vector
iOfLevel = (level .* dpl) + iOfLevel                                       ; % calculate indices of level
dOfIndex = delayofindex(iOfLevel(1),iOfLevel(end),dpl)                     ; % get delays of level
%---
maxdelay = max(dOfIndex(dOfIndex<nframes))                                 ; % calculate maxdelay
end

