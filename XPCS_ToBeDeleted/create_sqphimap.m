function [sqphimap,sq,sphi,sq_index]=create_sqphimap(ccdimginfo)
%%%%
%%%new function added to the cluster to make q/phi partitions. This code is
%%%taken from xpcsgui/save_local_results so that this takes care of
%%%geometry and all that.
%%%
sqphi_map=calculate_sqphimap(ccdimginfo);


sq=sqphi_map(:,:,1);sq=sq(:);
sphi=sqphi_map(:,:,2);sphi=sphi(:);
sq_index=find((isnan(sq(:)))==0);
% sq=sq(sq_index);
% sphi=sphi(sq_index);

counter=1;
LL=numel(ccdimginfo.partition.smask);
R1 = ccdimginfo.mask.maskroi(1,2) ;                                               % row    start of ROI
R2 = ccdimginfo.mask.maskroi(2,2) ;                                               % row    end   of ROI
C1 = ccdimginfo.mask.maskroi(1,1);                                               % column start of ROI%
C2 = ccdimginfo.mask.maskroi(2,1);
%%setting to 65535 (-1 in signed) means cluster _will not_ compute correlations of those
%%pixels
%%setting to 0 means cluster will compute correlations of those
%%pixels but is not saved anywhere unless the save tensor option is
%%enabled
y=zeros(R2-R1+1,C2-C1+1)+65535;
for i=1:LL
    if ~isempty(ccdimginfo.partition.smask{i})
        y(ccdimginfo.partition.smask{i})=counter;
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

sqphimap=zeros(ccdimginfo.detector.rows,ccdimginfo.detector.cols)+65535;

for i=R1:R2
    for j=C1:C2
        sqphimap(i,j)=y(i-R1+1,j-C1+1);
    end
end;

sqphimap(1:3,1:3)=0;%%no need to have zeros and -1 for masked pixels in hadoop as opposed to in MPI code
end

function sqphi_map=calculate_sqphimap(ccdimginfo)

% =========================================================================
R1 = ccdimginfo.mask.maskroi(1,2)                                               ; % row    start of ROI
R2 = ccdimginfo.mask.maskroi(2,2)                                               ; % row    end   of ROI
C1 = ccdimginfo.mask.maskroi(1,1)                                               ; % column start of ROI
C2 = ccdimginfo.mask.maskroi(2,1)                                               ; % column end   of ROI
% =========================================================================
% --- Static averages
% =========================================================================
if ( ccdimginfo.partition.snpt(1) >= 1 )
    % ---
    % =====================================================================
    % --- prepare data for I(q) figure
    % =====================================================================
    usermask = ccdimginfo.mask.usermask(R1:R2,C1:C2)                            ;
    qmap     = ccdimginfo.maps.qr    (R1:R2,C1:C2)                            ;
    phimap   = ccdimginfo.maps.qz  (R1:R2,C1:C2)                            ;
    % ---
    % ---
    info = zeros(ccdimginfo.partition.snpt(1),ccdimginfo.partition.snpt(2),3)                      ; % initialize info
    for n = 1 : ccdimginfo.partition.snpt(1)
        for m = 1 : ccdimginfo.partition.snpt(2)
            if ( numel(usermask(usermask(ccdimginfo.partition.smask{n,m})>0)) ~= 0)    % look for good pixels in static q phi partition
                Unm   = usermask(ccdimginfo.partition.smask{n,m})                    ;
                Qnm   = qmap    (ccdimginfo.partition.smask{n,m})                    ;
                Phinm = phimap  (ccdimginfo.partition.smask{n,m})                    ;
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
                    meanPhinm = mean(Phinm)                                ; % reflection geometry
                end
                % ---
                info(n,m,1) = mean (Qnm)                                   ;
                info(n,m,2) = meanPhinm                                    ;
                info(n,m,3) = numel(Unm)                                   ;
                % ---
                % ---
                clear Unm Qnm Phinm Inm meanPhinm                          ;
            else
                info(n,m,1) = NaN                                            ;
                info(n,m,2) = NaN                                            ;
                info(n,m,3) = NaN                                            ;
                %                 Iqphi(n,m)  = NaN                                            ; % set the value of Iqphi to NaN if no pixels are in static q phi partition
            end
        end
    end
    % ---
    clear xdummy ydummy Iqphidummy                                         ;
    clear usermask qmap phimap                                             ;
    % =====================================================================
    % --- create strings for the legend
    % --- calculate axis limits
    % =====================================================================
    clear meanphi phipix                                               ;
    % ---
    clear mindummy maxdummy                                            ;
    % =====================================================================
    % =======Added SN for saving to ccdimginfo structure=======================
    %     ccdimginfo.result.staticQs{nBatch}={};
    %     ccdimginfo.result.staticPHIs{nBatch}={};
    %
    %     ccdimginfo.result.staticQs{nBatch}=info(:,:,1);
    %     ccdimginfo.result.staticPHIs{nBatch}=info(:,:,2);
    % =========================================================================
    %     clear info Iqphi x y i n m                                             ;
end
% =========================================================================
sqphi_map=info;
end
