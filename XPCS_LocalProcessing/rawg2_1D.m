function [dt,G2,IP,IF,Istd] = rawg2_1D( IQTT, dpl, framespacing, Use_GPU )
% function [dt,g2,g2norm,IQTT_mean] = rawg2_1D( IQTT, dpl, framespacing )

% --- RAWG2   calculate the autocorrelation function in a multi-tau way
% ---
% --- structure of IQTT for a partition
% --- for full frame mode : [xpixel,ypixel, frame]
% ---
% ---    - only IQTT is needed as a parameter
% ---    - the other parameter are optional
% ---      and the routine can use standard values
% ---
% ---
% --- Revision 2005/09/16 - include the possiblity of a display output
% --- for xpcsgui
% --- by MS


% =========================================================================
% --- get parameters from input tensor
% =========================================================================
nframes  = size(IQTT,2)                                                    ; % get the number of full frames
% =========================================================================
% --- check input parameter

% =========================================================================
% ---
if (nargin <4)
    Use_GPU = 0;
end

if (nargin == 1)
    dpl = 4 ; % if the delays per level (dpl) is not defined use dpl == 4
    framespacing = 1;
end

if (Use_GPU)
    IQTT = gpuArray(IQTT);
end


Istd = (mean(IQTT,2).^2);

% =========================================================================
% --- create delays and time vector
% =========================================================================
% ---
framedelays = finddelays(nframes,dpl)                                    ;
% ---
dt = framedelays * framespacing                                        ; % for the framedelays
% ---

% =========================================================================
% --- initialize g2 tensor, create message string/switch
% =========================================================================
if isa(IQTT,'gpuArray')
    [G2,IP,IF] = deal(gpuArray(ones(size(IQTT,1),length(framedelays)))); % Any g2 structure should be initialized as ones !!!
else
    [G2,IP,IF] = deal(ones(size(IQTT,1),length(framedelays))); % Any g2 structure should be initialized as ones !!!
end
% =========================================================================
% --- main loop
% =========================================================================
% warning off MATLAB:DivideByZero                                            ; % due to use of 'mean'
oldlevel   = 0                                                             ;
for k=1:length(framedelays)
    % --- create delay, level & tau
    % ---
    thisdelay = framedelays(k)                                             ;
    
    level  = levelofdelay(thisdelay, dpl)                              ; % find the level of the actual delay
    
    if (level < 2)
        tau = thisdelay                                                    ;
    else
        tau = int32(thisdelay / 2.^(level-1))                              ; % due to the ongoing data averaging the tau is not equal to the delay
    end
    % ---
    % --- frame calculation routine
    % ---
    % ---
    if (level > oldlevel && level > 1)                                   % check: if the new delay is on a higher level than the data tensor can be averaged
        if ( mod(size(IQTT,2),2) == 0)                                   % check if the number of frames is even or odd
            lasteven = size(IQTT,2)                                    ;
            lastodd  = lasteven -1                                     ;
        else
            lasteven = size(IQTT,2) - 1                                ;
            lastodd  = lasteven -1                                     ;
        end
        % ---
        IQTT(:,1:lasteven/2)     = ( IQTT(:,1:2:lastodd )   ...
            + IQTT(:,2:2:lasteven)) / 2 ; % average the data tensor
        IQTT(:,lasteven/2+1:end) = []                              ; % clear the useless part of the tensor
        %         clear lasteven lastodd                                         ;
        % ---
    end
    % ---
    t = 1 : (size(IQTT,2)-tau)                                         ; % create time vector
    
    G2(:,k) = mean(IQTT(:,t) .* IQTT(:,t+tau),2) ; % calculate: <I(q,t) * I(q,t+tau)>_t
    IP(:,k) = mean(IQTT(:,t),2); % calculate: <I(q,t)>_t_left
    IF(:,k) = mean(IQTT(:,t+tau),2); % calculate: <I(q,t+tau)>_t_right
    
    % ---
    oldlevel = level                                                   ; % redefine old level
    % ---
    % ---
end

if isa(IQTT,'gpuArray')
    G2 = gather(G2);
    IP = gather(IP);
    IF = gather(IF);
    Istd = gather(Istd);
end
% =========================================================================
% --- end of main loop
% =========================================================================
end


% % % rawg2.i in yorick
% % %       g2(..,k) = (imgs(..,:-offset) * imgs(..,offset+1:))(..,avg)
% % %       left(..,k) = imgs(..,avg::-offset)
% % %       right(..,k) = imgs(..,avg:offset+1:)


