function varargout=getqpartition(varargin)
% GETQPARTITION Create the q phi partitions for dynamic and static analysis
%
%   Output Argument:
%      static mask information
%            ccdimginfo.partition.smask     : cell structure containing valid indices of each q phi section
%            ccdinginfo.parititon.smaskinfo :
%
%      dynamic mask information
%            ccdimginfo.partition.dmask     : cell structure containing valid indices of each q phi section
%            ccdinginfo.partition.dmaskinfo :
%
% Michael Sprung
% $Revision: 1.0 $  $Date: 2004/12/21 $
% $Revision: 1.1 $  $Date: 2004/10/31 $ improve speed
% $Revision: 1.2 $  $Date: 2004/11/22 $ try to index only pixels that are unmasked by ccdimginfo.usermask
% Carefull!!! The indexing is done with respect to the minimum rectangle
% defined by ccdimginfo.maskroi!!!
% $Revision: 1.3 $  $Date: 2014/09/11 $ by ZJ independent of main XPCSGUI
%       figure

if nargin ~=1
    error('Invalid input.');
end
ccdimginfo = varargin{1};


% =========================================================================
% --- assign some application data parameters
% =========================================================================
A           = ccdimginfo.mask.maskroi(1,2);      % row    start of ROI
B           = ccdimginfo.mask.maskroi(2,2);      % row    end   of ROI
C           = ccdimginfo.mask.maskroi(1,1);      % column start of ROI
D           = ccdimginfo.mask.maskroi(2,1);      % column end   of ROI
% --- collect values
npartition = length(ccdimginfo.partition.name);
name = ccdimginfo.partition.name;
snpt = ccdimginfo.partition.snpt;
dnpt = ccdimginfo.partition.dnpt;
sspan = ccdimginfo.partition.sspan;
dspan = ccdimginfo.partition.dspan;

% =========================================================================
% --- start some data preparation (e.g. take only ROI)
% =========================================================================
if ( ~isempty(regexp(ccdimginfo.detector.blemish_status{1},'ENABLED','once')) )
    blemish = getblemish(ccdimginfo);
    ccdimginfo.mask.usermask = ccdimginfo.mask.usermask .* blemish;
    clear blemish;
end
usermaskROI = ccdimginfo.mask.usermask(A:B,C:D);
unmasked_ind    = find(usermaskROI); % get indices of unmasked pixels in ROI
map = cell(1,npartition);
map_ROI = cell(1,npartition);
map_unmasked = cell(1,npartition);
for ii = 1:npartition
    map{ii} = ccdimginfo.maps.(name{ii});    
    map_ROI{ii} = map{ii}(A:B,C:D);
    map_unmasked{ii} = map_ROI{ii}(unmasked_ind);  % get map values of unmasked pixels in ROI
end
clear usermaskROI;
% --- check for 2pi discontinuity and correct it
for ii=1:npartition
    if strcmpi(name{ii},'phi')
        map_unmasked{ii} = anglecontinuity(map_unmasked{ii});
    end
end
% --- sort the map values of unmasked pixels and store indices as pixel vector
% And get map indices with respect to the ROI
map_value = cell(1,npartition);
map_unmaskedindex = cell(1,npartition);
map_index = cell(1,npartition);
for ii = 1:npartition      
    [map_value{ii},map_unmaskedindex{ii}] = sort(map_unmasked{ii}(:)); 
    map_index{ii} = unmasked_ind(map_unmaskedindex{ii});
end
clear unmasked_ind map_unmaskedindex
% --- initionalize
spartitionmap  = zeros(size(map_ROI{1}));
spartitionmask = zeros(size(map_ROI{1}));
dpartitionmap  = spartitionmap;
dpartitionmask = spartitionmask;

% =========================================================================
% --- check bounderies to prevent rounding errors
% =========================================================================
for ii = 1:npartition
    sspan{ii}(1) = min(sspan{ii}(1),map_value{ii}(1));
    sspan{ii}(end) = min(sspan{ii}(end),map_value{ii}(end));
    dspan{ii}(1) = min(dspan{ii}(1),map_value{ii}(1));
    dspan{ii}(end) = min(dspan{ii}(end),map_value{ii}(end));
end

% =========================================================================
% --- initialization
% =========================================================================
spartition  = cell(snpt); % initialize cell array to store pixel indices for each sq value
all_s1      = zeros(snpt); % initialize averated map values for map name 1
all_s2      = zeros(snpt); % initialize averaged map values for map name 2
all_snop    = zeros(snpt); % initialize all_snop for number of points in partition

dpartition  = cell(dnpt); % initialize cell array to store pixel indices for each s map value
all_d1      = zeros(dnpt); % initialize averated map values for map name 1
all_d2      = zeros(dnpt); % initialize averaged map values for map name 2
all_dnop    = zeros(dnpt); % initialize all_snop for number of points in partition

% =========================================================================
% --- finding indices of pixels belonging to a certain map1 or map2 partition
% =========================================================================
[~,bins1] = histc(map_value{1},sspan{1});
[~,bins2] = histc(map_value{2},sspan{2});
[~,bind1] = histc(map_value{1},dspan{1});
[~,bind2] = histc(map_value{2},dspan{2});
% ---
validSQ   = cell(snpt(1),1);
for n = 1:snpt(1)
    if n ~= snpt(1)
        dummySQ    = map_index{1}(bins1==n);
        validSQ{n} = sort(dummySQ);
    else
        dummySQ1   = map_index{1}(bins1==n);
        dummySQ2   = map_index{1}(bins1==n+1);
        dummySQ    = [dummySQ1;dummySQ2];
        validSQ{n} = sort(dummySQ);   
    end
end
% ---
validSPHI = cell(snpt(2),1);
for m = 1:snpt(2)
    if m ~= snpt(2)
        dummySPHI    = map_index{2}(bins2==m);
        validSPHI{m} = sort(dummySPHI);
    else
        dummySPHI1   = map_index{2}(bins2==m);
        dummySPHI2   = map_index{2}(bins2==m+1);
        dummySPHI    = [dummySPHI1;dummySPHI2];
        validSPHI{m} = sort(dummySPHI);
    end
end
clear dummySQ dummySQ1 dummySQ2 dummySPHI dummySPHI1 dummySPHI2;
% ---
validDQ   = cell(dnpt(1),1);
for n = 1:dnpt(1)
    if n ~= dnpt(1)
        dummyDQ    = map_index{1}(bind1==n);
        validDQ{n} = sort(dummyDQ);
    else
        dummyDQ1   = map_index{1}(bind1==n);
        dummyDQ2   = map_index{1}(bind1==n+1);
        dummyDQ    = [dummyDQ1;dummyDQ2];
        validDQ{n} = sort(dummyDQ);
    end
end
% ---
validDPHI = cell(dnpt(2),1);
for m = 1:dnpt(2)
    if m ~= dnpt(2)
        dummyDPHI    = map_index{2}(bind2==m);
        validDPHI{m} = sort(dummyDPHI);
    else
        dummyDPHI1   = map_index{2}(bind2==m);
        dummyDPHI2   = map_index{2}(bind2==m+1);
        dummyDPHI    = [dummyDPHI1;dummyDPHI2];
        validDPHI{m} = sort(dummyDPHI);
    end
end
clear dummyDQ dummyDQ1 dummyDQ2 dummyDPHI dummyDPHI1 dummyDPHI2;
clear bins1 bins2 bind1 bind2;


% =========================================================================
% --- finding indices in q & phi partititons
% =========================================================================

% --- static case
fast = zeros(snpt);
for n = 1:snpt(1)
    for m = 1:snpt(2)
        if ( numel(validSQ{n}) <= numel(validSPHI{m}) )
           fast(n,m) = 1;
        end
    end
end
for n = 1:snpt(1)
    indexSQ = validSQ{n};
    for m = 1:snpt(2)
        indexSPHI    = validSPHI{m};
        if ( fast(n,m) == 1 )
            indexSQPHI   = indexSQ  (myismember(indexSQ,indexSPHI));
        else
            indexSQPHI   = indexSPHI(myismember(indexSPHI,indexSQ));
        end
        % ---
        spartition{n,m} = indexSQPHI;
        % ---
        spartitionmap(indexSQPHI) = (n-1)*(snpt(2))+m; % set all pixels of a static partition to a unique number
        % ---
        all_snop(n,m) = length(indexSQPHI); % store number of points of each sq dependent complete mask
        if ( all_snop(n,m) ~= 0 )
            all_s1(n,m)   = sum(map_ROI{1}(indexSQPHI)) / all_snop(n,m); % store actual  sq value in all_sq 
            all_s2(n,m) = sum(map_ROI{2}(indexSQPHI)) / all_snop(n,m); % store actual  sphi value in all_sphi
        else
            all_s1  (n,m) = (sspan{1}(n)   + sspan{1}(n+1)  ) / 2;
            all_s2(n,m) = (sspan{2}(m) + sspan{2}(m+1)) / 2;
        end
    end
end
clear sspan validSQ validSPHI;
clear indexSQ indexSPHI indexSQPHI n m fast;

% --- dynamic case
fast = zeros(dnpt);
for n = 1:dnpt(1)
    for m = 1:dnpt(2)
        if ( numel(validDQ{n}) <= numel(validDPHI{m}) )
            fast(n,m) = 1;
        end
    end
end
for n = 1:dnpt(1)
    indexDQ = validDQ{n};
    for m = 1:dnpt(2)
        indexDPHI    = validDPHI{m};
        if ( fast(n,m) == 1 )
            indexDQPHI   = indexDQ  (myismember(indexDQ,indexDPHI));
        else
            indexDQPHI   = indexDPHI(myismember(indexDPHI,indexDQ));
        end
        % ---
        dpartition{n,m} = indexDQPHI;
        % ---
        dpartitionmap(indexDQPHI) = (n-1)*(dnpt(2))+m; % set all pixels of a dynamic partition to a unique number
        % ---
        all_dnop(n,m) = length(indexDQPHI); % store number of points of each sq dependent complete mask
        if ( all_dnop(n,m) ~= 0 )
            all_d1(n,m)   = sum(map_ROI{1}(indexDQPHI)) / all_dnop(n,m); % store actual  sq value in all_sq
            all_d2(n,m) = sum(map_ROI{2}(indexDQPHI)) / all_dnop(n,m); % store actual  sphi value in all_sphi
        else
            all_d1  (n,m) = (dspan{1}(n)   + dspan{1}(n+1)  ) / 2;
            all_d2(n,m) = (dspan{2}(m) + dspan{2}(m+1)) / 2;
        end
    end
end
clear dspan validDQ validDPHI;
clear indexDQ indexDPHI indexDQPHI n m fast;

% =========================================================================
% --- create partition mask index
% =========================================================================

% --- static case
sdiff1 = diff(spartitionmap,1,1);
sdiff2 = diff(spartitionmap,1,2);
% ---
spartitionmask(1:end-1,:)         = sdiff1;
spartitionmask(:,1:end-1)         = spartitionmask(:,1:end-1) + sdiff2;
if ( ccdimginfo.detector.kinetics.mode == 0 )
    spartitionmask(2:end,:)       = spartitionmask(2:end,:)   + sdiff1;
    spartitionmask(:,2:end)       = spartitionmask(:,2:end)   + sdiff2;
end
spartitionmask(spartitionmask~=0) = 1;
spartitionmaskindex               = find(spartitionmask); % indices of pixel on a static partition border
% ---
clear spartitionmap spartitionmask sdiff1 sdiff2;

% --- dynamic case
ddiff1 = diff(dpartitionmap,1,1);
ddiff2 = diff(dpartitionmap,1,2);
% ---
dpartitionmask(1:end-1,:)         = ddiff1;
dpartitionmask(:,1:end-1)         = dpartitionmask(:,1:end-1) + ddiff2;
if ( ccdimginfo.detector.kinetics.mode == 0 )
    dpartitionmask(2:end,:)       = dpartitionmask(2:end,:)   + ddiff1;
    dpartitionmask(:,2:end)       = dpartitionmask(:,2:end)   + ddiff2;
end
dpartitionmask(dpartitionmask~=0) = 1;
dpartitionmaskindex               = find(dpartitionmask); % indices of pixel on a dynamic partition border
% ---
clear dpartitionmap dpartitionmask ddiff1 ddiff2;


% =========================================================================
% --- fill info tensor
% =========================================================================

% --- static case
all_smap(:,:,1) = all_s1; % assign (static) q    to info tensor
all_smap(:,:,2) = all_s2; % assign (static) phi  to info tensor
all_smap(:,:,3) = all_snop; % assign (static) nop  to info tensor

% --- dynamic case
all_dmap(:,:,1) = all_d1; % assign (dynamic) q    to info tensor
all_dmap(:,:,2) = all_d2; % assign (dynamic) phi  to info tensor
all_dmap(:,:,3) = all_dnop; % assign (dynamic) nop  to info tensor

% =========================================================================
% --- create output structures of the mask information
% =========================================================================

% --- static case
ccdimginfo.partition.smask                  = spartition;
ccdimginfo.partition.spartitionmaskindex    = spartitionmaskindex;
ccdimginfo.partition.smaskinfo              = all_smap;

% --- dynamic case
ccdimginfo.partition.dmask                  = dpartition;
ccdimginfo.partition.dpartitionmaskindex    = dpartitionmaskindex;
ccdimginfo.partition.dmaskinfo              = all_dmap;


% =========================================================================
% --- output
% =========================================================================
if (nargout == 1)
    varargout{1}=ccdimginfo;
end


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
