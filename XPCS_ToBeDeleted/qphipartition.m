function varargout=qphipartition
% Create the q phi partitions for dynamic and static analysis
%
%
%   Output Argument:
%      static mask information
%            ccdimginfo.smask     : cell structure containing valid indices of each q phi section
%            ccdinginfo.smaskinfo :
%
%      dynamic mask information
%            ccdimginfo.dmask     : cell structure containing valid indices of each q phi section
%            ccdinginfo.dmaskinfo :
%
% Michael Sprung
% $Revision: 1.0 $  $Date: 2004/12/21 $
% $Revision: 1.1 $  $Date: 2004/10/31 $ improve speed
% $Revision: 1.2 $  $Date: 2004/11/22 $ try to index only pixels that are unmasked by ccdimginfo.usermask
% Carefull!!! The indexing is done with respect to the minimum rectangle
% defined by ccdimginfo.maskroi!!!

% =========================================================================
% --- get application data
% =========================================================================
hFigXPCSMain = findall(0,'Tag','xpcsmain_Fig')                             ;
ccdimginfo   = getappdata(hFigXPCSMain,'ccdimginfo')                       ;


% =========================================================================
% --- assign some application data parameters
% =========================================================================
here=1;
A           = ccdimginfo.maskroi(1,2)  ;                                     % row    start of ROI
B           = ccdimginfo.maskroi(2,2) ;                                      % row    end   of ROI
C           = ccdimginfo.maskroi(1,1) ;                                      % column start of ROI
D           = ccdimginfo.maskroi(2,1) ;                                      % column end   of ROI
here=1;
% ---
sqspan      = ccdimginfo.sqspan                                            ; % get vector of   q values at the partition limits
sphispan    = ccdimginfo.sphispan                                          ; % get vector of phi values at the partition limits
dqspan      = ccdimginfo.dqspan                                            ; % get vector of   q values at the partition limits
dphispan    = ccdimginfo.dphispan                                          ; % get vector of phi values at the partition limits
% ---
q_matrix    = ccdimginfo.qmap                                              ; 
phi_matrix  = ccdimginfo.phimap                                            ; 


% =========================================================================
% --- start some data preparation (e.g. take only ROI)
% =========================================================================
if ( ~isempty(regexp(ccdimginfo.detector.blemish_status{1},'ENABLED','once')) )
    blemish = getblemish(ccdimginfo)                                       ;
    ccdimginfo.usermask = ccdimginfo.usermask .* blemish                   ;
    clear blemish                                                          ;
end
usermaskROI = ccdimginfo.usermask(A:B,C:D)                                 ;
q_ROI       = q_matrix  (A:B,C:D)                                          ;
phi_ROI     = phi_matrix(A:B,C:D)                                          ;
clear A B C D q_matrix phi_matrix                                          ;
% ---
unmasked    = find(usermaskROI)                                            ; % get indices   of unmasked pixels in ROI
qunmasked   = q_ROI  (unmasked)                                            ; % get qvalues   of unmasked pixels in ROI
phiunmasked = phi_ROI(unmasked)                                            ; % get phivalues of unmasked pixels in ROI
clear usermaskROI                                                          ;
% --- check for 2pi discontinuity and correct it
if ( ccdimginfo.geometry == 0 )                                              % transmission geometry
    phiunmasked = anglecontinuity(phiunmasked)                             ;
end
% ---
[qvalue,qunmaskedindex]     = sort(qunmasked(:))                           ; % sort the qvalues   of unmasked pixels and store indices as pixel vector 
[phivalue,phiunmaskedindex] = sort(phiunmasked(:))                         ; % sort the phivalues of unmasked pixels and store indices as pixel vector 
clear qunmasked phiunmasked                                                ;
% ---
qindex   = unmasked(qunmaskedindex)                                        ; % get q   indices with respect to the ROI 
phiindex = unmasked(phiunmaskedindex)                                      ; % get phi indices with respect to the ROI
clear unmasked qunmaskedindex phiunmaskedindex                             ;
% ---
spartitionmap  = zeros(size(q_ROI))                                        ;
spartitionmask = zeros(size(q_ROI))                                        ;
if ( ccdimginfo.analysistype == 1 )
    dpartitionmap  = zeros(size(q_ROI))                                    ;
    dpartitionmask = zeros(size(q_ROI))                                    ;
end


% =========================================================================
% --- check bounderies to prevent rounding errors
% =========================================================================
sqspan(1)     = min(sqspan(1)  ,qvalue(1))                                 ;
sqspan(end)   = min(sqspan(end),qvalue(end))                               ;
sphispan(1)   = min(sphispan(1)  ,phivalue(1))                             ;
sphispan(end) = min(sphispan(end),phivalue(end))                           ;
if ( ccdimginfo.analysistype == 1 )
    dqspan(1)     = min(dqspan(1)  ,qvalue(1))                             ;
    dqspan(end)   = min(dqspan(end),qvalue(end))                           ;
    dphispan(1)   = min(dphispan(1)  ,phivalue(1))                         ;
    dphispan(end) = min(dphispan(end),phivalue(end))                       ;
end


% =========================================================================
% --- initialization
% =========================================================================

% --- static case
sqphipartition = cell (length(sqspan)-1,length(sphispan)-1)                ; % initialize cell array to store pixel indices for each sq value
for n = 1 : length(sqspan) - 1
    for m = 1 : length(sphispan) - 1
        sqphipartition{n,m} = []                                           ; % start with empty aarays
    end
end
all_sq       = zeros(length(sqspan)-1,length(sphispan)-1)                  ; % initialize all_sq
all_sphi     = zeros(length(sqspan)-1,length(sphispan)-1)                  ; % initialize all_sphi
all_snop     = zeros(length(sqspan)-1,length(sphispan)-1)                  ; % initialize all_snop
all_sQPHI    = zeros(length(sqspan)-1,length(sphispan)-1,3)                ; % initialize static mask info tensor

% --- dynamic initialization
if ( ccdimginfo.analysistype == 1 )
    dqphipartition = cell (length(dqspan)-1,length(dphispan)-1)            ; % initialize cell array to store sparse masks for each dq value
    for n = 1 : length(dqspan) - 1
        for m = 1 : length(dphispan) - 1
            dqphipartition{n,m} = []                                       ;
        end
    end
    all_dq       = zeros(length(dqspan)-1,length(dphispan)-1)              ; % initialize all_dq
    all_dphi     = zeros(length(dqspan)-1,length(dphispan)-1)              ; % initialize all_dphi
    all_dnop     = zeros(length(dqspan)-1,length(dphispan)-1)              ; % initialize all_dnop
    all_dQPHI    = zeros(length(dqspan)-1,length(dphispan)-1,3)            ; % initialize dynamic mask info tensor
end


% =========================================================================
% --- finding indices of pixels belonging to a certain q or phi partition
% =========================================================================
[nsq,binsq]     = histc(qvalue,sqspan)                                     ;
[nsphi,binsphi] = histc(phivalue,sphispan)                                 ;
clear nsq nsphi                                                            ;
if ( ccdimginfo.analysistype == 1 )
    [ndq,bindq]     = histc(qvalue,dqspan)                                 ;
    [ndphi,bindphi] = histc(phivalue,dphispan)                             ;
    clear ndq ndphi                                                        ;
end
% ---
validSQ   = cell(numel(sqspan)-1  ,1)                                      ;
for n = 1 : numel(sqspan) - 1
    if ( n ~= numel(sqspan) - 1 )
        dummySQ    = qindex(binsq==n)                                      ;
        validSQ{n} = sort(dummySQ)                                         ;
    else
        dummySQ1   = qindex(binsq==n)                                      ;
        dummySQ2   = qindex(binsq==n+1)                                    ;
        dummySQ    = [dummySQ1;dummySQ2]                                   ;
        validSQ{n} = sort(dummySQ)                                         ;        
    end
end
% ---
validSPHI = cell(numel(sphispan)-1  ,1)                                    ;
for m = 1 : numel(sphispan) - 1
    if ( m ~= numel(sphispan) - 1 )
        dummySPHI    = phiindex(binsphi==m)                                ;
        validSPHI{m} = sort(dummySPHI)                                     ;    
    else
        dummySPHI1   = phiindex(binsphi==m)                                ;
        dummySPHI2   = phiindex(binsphi==m+1)                              ;
        dummySPHI    = [dummySPHI1;dummySPHI2]                             ;
        validSPHI{m} = sort(dummySPHI)                                     ;        
    end
end
clear dummySQ dummySQ1 dummySQ2 dummySPHI dummySPHI1 dummySPHI2            ;
% ---
if ( ccdimginfo.analysistype == 1 )
    validDQ   = cell(numel(dqspan)-1  ,1)                                  ;
    for n = 1 : numel(dqspan) - 1
        if ( n ~= numel(dqspan) - 1 )
            dummyDQ    = qindex(bindq==n)                                  ;
            validDQ{n} = sort(dummyDQ)                                     ;
        else
            dummyDQ1   = qindex(bindq==n)                                  ;
            dummyDQ2   = qindex(bindq==n+1)                                ;
            dummyDQ    = [dummyDQ1;dummyDQ2]                               ;
            validDQ{n} = sort(dummyDQ)                                     ;        
        end
    end
    % ---
    validDPHI = cell(numel(dphispan)-1  ,1)                                ;
    for m = 1 : numel(dphispan) - 1
        if ( m ~= numel(dphispan) - 1 )
            dummyDPHI    = phiindex(bindphi==m)                            ;
            validDPHI{m} = sort(dummyDPHI)                                 ;    
        else
            dummyDPHI1   = phiindex(bindphi==m)                            ;
            dummyDPHI2   = phiindex(bindphi==m+1)                          ;
            dummyDPHI    = [dummyDPHI1;dummyDPHI2]                         ;
            validDPHI{m} = sort(dummyDPHI)                                 ;        
        end
    end
    clear dummyDQ dummyDQ1 dummyDQ2 dummyDPHI dummyDPHI1 dummyDPHI2        ;
end
clear binsq binsphi bindq bindphi                                          ;


% =========================================================================
% --- finding indices in q & phi partititons
% =========================================================================

% --- static case
fast = zeros(length(sqspan)-1,length(sphispan)-1)                          ;
for n = 1 : length(sqspan) - 1
    for m = 1 : length(sphispan) - 1
        if ( numel(validSQ{n}) <= numel(validSPHI{m}) )
           fast(n,m) = 1                                                   ;
        end
    end
end
for n = 1 : length(sqspan) - 1
    indexSQ = validSQ{n}                                                   ;
    for m = 1 : length(sphispan) - 1
        indexSPHI    = validSPHI{m}                                        ;
        if ( fast(n,m) == 1 )
            indexSQPHI   = indexSQ  (myismember(indexSQ,indexSPHI))        ;
        else
            indexSQPHI   = indexSPHI(myismember(indexSPHI,indexSQ))        ;
        end
        % ---
        sqphipartition{n,m} = indexSQPHI                                   ;
        % ---
        spartitionmap(indexSQPHI) = (n-1)*(length(sphispan)-1)+m           ; % set all pixels of a static partition to a unique number
        % ---
        all_snop(n,m) = length(indexSQPHI)                                 ; % store number of points of each sq dependent complete mask
        if ( all_snop(n,m) ~= 0 )
            all_sq(n,m)   = sum(q_ROI  (indexSQPHI)) / all_snop(n,m)       ; % store actual  sq value in all_sq 
            all_sphi(n,m) = sum(phi_ROI(indexSQPHI)) / all_snop(n,m)       ; % store actual  sphi value in all_sphi
        else
            all_sq  (n,m) = (sqspan(n)   + sqspan(n+1)  ) / 2              ;
            all_sphi(n,m) = (sphispan(m) + sphispan(m+1)) / 2              ;
        end
    end
end
clear sqspan sphispan validSQ validSPHI                                    ;
clear indexSQ indexSPHI indexSQPHI n m fast                                ;

% --- dynamic case
if ( ccdimginfo.analysistype == 1 )
    fast = zeros(length(dqspan)-1,length(dphispan)-1)                      ;
    for n = 1 : length(dqspan) - 1
        for m = 1 : length(dphispan) - 1
            if ( numel(validDQ{n}) <= numel(validDPHI{m}) )
                fast(n,m) = 1                                              ;
            end
        end
    end
    for n = 1 : length(dqspan) - 1
        indexDQ = validDQ{n}                                               ;
        for m = 1 : length(dphispan) - 1
            indexDPHI    = validDPHI{m}                                    ;
            if ( fast(n,m) == 1 )
                indexDQPHI   = indexDQ  (myismember(indexDQ,indexDPHI))    ;
            else
                indexDQPHI   = indexDPHI(myismember(indexDPHI,indexDQ))    ;
            end
            % ---
            dqphipartition{n,m} = indexDQPHI                               ;
            % ---
            dpartitionmap(indexDQPHI) = (n-1)*(length(dphispan)-1)+m       ; % set all pixels of a dynamic partition to a unique number
            % ---
            all_dnop(n,m) = length(indexDQPHI)                             ; % store number of points of each sq dependent complete mask
            if ( all_dnop(n,m) ~= 0 )
                all_dq(n,m)   = sum(q_ROI  (indexDQPHI)) / all_dnop(n,m)   ; % store actual  sq value in all_sq 
                all_dphi(n,m) = sum(phi_ROI(indexDQPHI)) / all_dnop(n,m)   ; % store actual  sphi value in all_sphi
            else
                all_dq  (n,m) = (dqspan(n)   + dqspan(n+1)  ) / 2          ;
                all_dphi(n,m) = (dphispan(m) + dphispan(m+1)) / 2          ;
            end
        end
    end
    clear dqspan dphispan validDQ validDPHI                                ;
    clear indexDQ indexDPHI indexDQPHI n m fast                            ;
end


% =========================================================================
% --- create partition mask index
% =========================================================================

% --- static case
sdiff1 = diff(spartitionmap,1,1)                                           ;
sdiff2 = diff(spartitionmap,1,2)                                           ;
% ---
spartitionmask(1:end-1,:)         = sdiff1                                 ;
spartitionmask(:,1:end-1)         = spartitionmask(:,1:end-1) + sdiff2     ;
if ( ccdimginfo.detector.kinetics.mode == 0 )
    spartitionmask(2:end,:)       = spartitionmask(2:end,:)   + sdiff1     ;
    spartitionmask(:,2:end)       = spartitionmask(:,2:end)   + sdiff2     ;
end
spartitionmask(spartitionmask~=0) = 1                                      ;
spartitionmaskindex               = find(spartitionmask)                   ; % indices of pixel on a static partition border
% ---
clear spartitionmap spartitionmask sdiff1 sdiff2                           ;

% --- dynamic case
if ( ccdimginfo.analysistype == 1 )
    ddiff1 = diff(dpartitionmap,1,1)                                       ;
    ddiff2 = diff(dpartitionmap,1,2)                                       ;
    % ---
    dpartitionmask(1:end-1,:)         = ddiff1                             ;
    dpartitionmask(:,1:end-1)         = dpartitionmask(:,1:end-1) + ddiff2 ;
    if ( ccdimginfo.detector.kinetics.mode == 0 )
        dpartitionmask(2:end,:)       = dpartitionmask(2:end,:)   + ddiff1 ;
        dpartitionmask(:,2:end)       = dpartitionmask(:,2:end)   + ddiff2 ;
    end
    dpartitionmask(dpartitionmask~=0) = 1                                  ;
    dpartitionmaskindex               = find(dpartitionmask)               ; % indices of pixel on a dynamic partition border
    % ---
    clear dpartitionmap dpartitionmask ddiff1 ddiff2                       ;
end


% =========================================================================
% --- fill info tensor
% =========================================================================

% --- static case
all_sQPHI(:,:,1) = all_sq                                                  ; % assign (static) q    to info tensor
all_sQPHI(:,:,2) = all_sphi                                                ; % assign (static) phi  to info tensor
all_sQPHI(:,:,3) = all_snop                                                ; % assign (static) nop  to info tensor

% --- dynamic case
if ( ccdimginfo.analysistype == 1 )
    all_dQPHI(:,:,1) = all_dq                                              ; % assign (dynamic) q    to info tensor
    all_dQPHI(:,:,2) = all_dphi                                            ; % assign (dynamic) phi  to info tensor
    all_dQPHI(:,:,3) = all_dnop                                            ; % assign (dynamic) nop  to info tensor
end


% =========================================================================
% --- create output structures of the mask information
% =========================================================================

% --- static case
ccdimginfo.smask               = sqphipartition                            ;
ccdimginfo.spartitionmaskindex = spartitionmaskindex                       ;
ccdimginfo.smaskinfo           = all_sQPHI                                 ;
clear sqphipartition all_sq all_sphi all_snop                              ;
clear all_sQPHI spartitionmaskindex                                        ;

% --- dynamic case
if ( ccdimginfo.analysistype == 1 )
    ccdimginfo.dmask               = dqphipartition                        ;
    ccdimginfo.dpartitionmaskindex = dpartitionmaskindex                   ;
    ccdimginfo.dmaskinfo           = all_dQPHI                             ;
    clear dqphipartition all_dq all_dphi all_dnop                          ;
    clear all_dQPHI dpartitionmaskindex                                    ;
end


% =========================================================================
% --- save ccdimginfo to figure & clear left over variables
% =========================================================================
if (nargout == 1)
    varargout{1}=ccdimginfo;
end
setappdata(hFigXPCSMain,'ccdimginfo',ccdimginfo)                           ;
clear q_ROI phi_ROI qvalue qindex phivalue phiindex                        ;
clear hFigXPCSMain                                              ;
% =========================================================================
% --- finish saving ccdimginfo to figure & clear left over variables
% =========================================================================

% whos

% =========================================================================
% --- subfunction myismember
% =========================================================================
function [tf] = myismember(a,s)
% ---
% --- MYISMEMBER True for set member.
% --- MYISMEMBER(A,S) for the array A returns an array tf of the same 
% --- size as A containing 1 where the elements of A are in the set S 
% --- and 0 otherwise.
% --- The arrays a & s have to be REAL & ALREADY presorted 
% --- MYISMEMBER works much faster if numel(a) < numel(s)
% ---

if nargin < 2
    error('MATLAB:MYISMEMBER', 'Not enough input arguments.')              ;
elseif nargin > 2
    error('MATLAB:MYISMEMBER', 'Too many input arguments.')                ;
end

numelA = numel(a)                                                          ;
numelS = numel(s)                                                          ;

tf = false(size(a))                                                        ;
if numelA == 0 || numelS <= 1
    if (numelA == 0 || numelS == 0)
        return
    elseif numelS == 1
        tf = (a == s)                                                      ;
        return
    end
else
    tf = ismembc(a,s)                                                      ;
end


% ---
% EOF
