function varargout = getimgpartitionindex(varargin)
% GETIMGPARTITIONINDEX
%
%  $Revision: 1.0 $  $Date: 2014/09/16 $ by ZJ; modified from
%       create_sqphimap and create_dqphimap

if nargin ~=1
    error('Invalid input argument.');
end
ccdimginfo = varargin{1};
ccdimginfo.partition.sindexmap = [];
ccdimginfo.partition.dindexmap = [];
ccdimginfo.partition.smeanmap = [];
ccdimginfo.partition.dmeanmap = [];
% initialize 
if (ccdimginfo.detector.kinetics.mode == 1)     % no bin used for kinetics
    rows=ccdimginfo.detector.kinetics.window_size;
    cols = ccdimginfo.bin.detector.cols; 
else            % for non-kinetics
    rows = ccdimginfo.bin.detector.rows;
    cols = ccdimginfo.bin.detector.cols;
end
ccdimginfo.partition.sindexmap = zeros(rows,cols);
ccdimginfo.partition.dindexmap = zeros(rows,cols);

% % ROI
% R1 = ccdimginfo.mask.maskroi(1,2) ;                                               % row    start of ROI
% R2 = ccdimginfo.mask.maskroi(2,2) ;                                               % row    end   of ROI
% C1 = ccdimginfo.mask.maskroi(1,1);                                               % column start of ROI%
% C2 = ccdimginfo.mask.maskroi(2,1);
[y,x] = find(ccdimginfo.mask.usermask);
R1 = min(y);
R2 = max(y);
C1 = min(x);
C2 = max(x);


% --- static
smaskinfo = ccdimginfo.partition.smaskinfo;
smap1 = smaskinfo(:,:,1); smap1(smaskinfo(:,:,3)==0) = NaN;
smap2 = smaskinfo(:,:,2); smap2(smaskinfo(:,:,3)==0) = NaN;
ccdimginfo.partition.smeanmap(:,1) = smap1(:);
ccdimginfo.partition.smeanmap(:,2) = smap2(:);
ccdimginfo.partition.smeanmapindex = find((isnan(smap1(:)))==0);

counter=1;
LL=numel(ccdimginfo.partition.smask);
y=zeros(R2-R1+1,C2-C1+1);
for i=1:LL
    if ~isempty(ccdimginfo.partition.smask{i})
        y(ccdimginfo.partition.smask{i})=counter;
        counter=counter+1;
    end
end
for i=R1:R2
    for j=C1:C2
        ccdimginfo.partition.sindexmap(i,j)=y(i-R1+1,j-C1+1);
    end
end

% --- dynamic
dmaskinfo = ccdimginfo.partition.dmaskinfo;
dmap1 = dmaskinfo(:,:,1); dmap1(dmaskinfo(:,:,3)==0) = NaN;
dmap2 = dmaskinfo(:,:,2); dmap2(dmaskinfo(:,:,3)==0) = NaN;
ccdimginfo.partition.dmeanmap(:,1) = dmap1(:);
ccdimginfo.partition.dmeanmap(:,2) = dmap2(:);
ccdimginfo.partition.dmeanmapindex = find((isnan(dmap1(:)))==0);

counter=1;
LL=numel(ccdimginfo.partition.dmask);
y=zeros(R2-R1+1,C2-C1+1);
for i=1:LL
    if ~isempty(ccdimginfo.partition.dmask{i})
        y(ccdimginfo.partition.dmask{i})=counter;
        counter=counter+1;
    end
end
for i=R1:R2
    for j=C1:C2
        ccdimginfo.partition.dindexmap(i,j)=y(i-R1+1,j-C1+1);
    end
end

% --- output
if nargout == 1
    varargout{1} = ccdimginfo;
end