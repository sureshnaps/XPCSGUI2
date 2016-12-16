function [dqphimap,dq,dphi,dq_index]=create_dqphimap(ccdimginfo)
%%%%
%%%new function added to the cluster to make q/phi partitions. This code is
%%%taken from xpcsgui/save_local_results so that this takes care of
%%%geometry and all that.
%%%
dqphi_map=calculate_dqphimap(ccdimginfo);
dq=dqphi_map(:,:,1);dq=dq(:);
dphi=dqphi_map(:,:,2);dphi=dphi(:);
dq_index=find((isnan(dq(:)))==0);
% dq=dq(dq_index);
% dphi=dphi(dq_index);

counter=1;
LL=numel(ccdimginfo.dmask);
R1 = ccdimginfo.maskroi(1,2) ;                                               % row    start of ROI
R2 = ccdimginfo.maskroi(2,2) ;                                               % row    end   of ROI
C1 = ccdimginfo.maskroi(1,1);                                               % column start of ROI%
C2 = ccdimginfo.maskroi(2,1);
%%setting to 65535 (-1 in signed) means cluster _will not_ compute correlations of those
%%pixels
%%setting to 0 means cluster will compute correlations of those
%%pixels but is not saved anywhere unless the save tensor option is
%%enabled
y=zeros(R2-R1+1,C2-C1+1)+65535;
for i=1:LL
    if ~isempty(ccdimginfo.dmask{i})
        y(ccdimginfo.dmask{i})=counter;
        counter=counter+1;
    end
end

if (ccdimginfo.detector.kinetics.mode == 1)
    ccdimginfo.detector.rows=ccdimginfo.detector.kinetics.window_size;
end

try
    ccdimginfo.detector.rows = ccdimginfo.bin.detector.rows;
catch
    %do nothing
end

try
    ccdimginfo.detector.cols = ccdimginfo.bin.detector.cols;
catch
    %do nothing
end

dqphimap=zeros(ccdimginfo.detector.rows,ccdimginfo.detector.cols)+65535;

for i=R1:R2
    for j=C1:C2
        dqphimap(i,j)=y(i-R1+1,j-C1+1);
    end
end;

dqphimap(1:3,1:3)=0;%%no need to have zeros and -1 for masked pixels in hadoop as opposed to in MPI code
end

function dqphi_map=calculate_dqphimap(ccdimginfo)
% =========================================================================
R1 = ccdimginfo.maskroi(1,2)                                               ; % row    start of ROI
R2 = ccdimginfo.maskroi(2,2)                                               ; % row    end   of ROI
C1 = ccdimginfo.maskroi(1,1)                                               ; % column start of ROI
C2 = ccdimginfo.maskroi(2,1)                                               ; % column end   of ROI
% =========================================================================
usermask = ccdimginfo.usermask(R1:R2,C1:C2)                            ;
qmap     = ccdimginfo.qmap    (R1:R2,C1:C2)                            ;
phimap   = ccdimginfo.phimap  (R1:R2,C1:C2)                            ;
% ---
% usermask(ccdimginfo.result.NEPhoton{nBatch}) = 0                       ; % mask pixel which did not receive enough photons
qmap  (usermask==0) = -1000                                            ; % set   q values of masked pixels to -1000
phimap(usermask==0) = -1000                                            ; % set phi values of masked pixels to -1000
% ---
corr_info = zeros(ccdimginfo.dnoq,ccdimginfo.dnophi,3)                 ; % initialize corr_info
for n = 1 : ccdimginfo.dnoq
    for m = 1 : ccdimginfo.dnophi
        if ( numel(usermask(usermask(ccdimginfo.dmask{n,m})>0)) ~= 0)    % look for good pixels in dynamic q phi partition
            Unm   = usermask(ccdimginfo.dmask{n,m})                    ;
            Qnm   = qmap    (ccdimginfo.dmask{n,m})                    ;
            Phinm = phimap  (ccdimginfo.dmask{n,m})                    ;
            % ---
            Inm   = find(Unm > 0)                                      ; % find indices of unmasked pixels in partition
            Unm   = Unm(Inm)                                           ;
            Qnm   = Qnm(Inm)                                           ;
            Phinm = Phinm(Inm)                                         ;
            % --- check for anglecontinuity
            if ( ccdimginfo.geometry == 0 )                              % transmission geometry
                Phinm = anglecontinuity(Phinm)                         ;
                meanPhinm = mean(Phinm)                                ;
                if ( meanPhinm >   pi )
                    meanPhinm = meanPhinm - 2*pi                       ;
                end
                if ( meanPhinm <= -pi )
                    meanPhinm = meanPhinm + 2*pi                       ;
                end
            else
                meanPhinm = mean(Phinm)                                ;
            end
            % ---
            corr_info(n,m,1) = mean (Qnm)                              ;
            corr_info(n,m,2) = meanPhinm                               ;
%             if (ccdimginfo.geometry == 0 )
%                 corr_info(n,m,2) = 1 / 100                          ...
%                     * round(100*180/pi*corr_info(n,m,2))  ; % convert to degree (two digits after the dot)
%             end
            corr_info(n,m,3) = numel(Unm)                              ;
            % ---
            clear Unm Qnm Phinm Inm meanPhinm                          ;
        else
            corr_info(n,m,1) = NaN                                       ;
            corr_info(n,m,2) = NaN                                       ;
            corr_info(n,m,3) = NaN                                       ;
        end
    end
end
clear qmap phimap
dqphi_map=corr_info;
end
