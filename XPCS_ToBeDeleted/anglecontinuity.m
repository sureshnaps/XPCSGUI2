function [newphi] = anglecontinuity(phi)
% ---
% --- [phi] = anglecontinuity(phi) 
% ---
% --- this function adds +- 2pi to a map of phi values so that phi is
% --- continuous
% ---
% --- by MS 20070412
% ---
newphi                 = phi                                               ;

if ( numel(newphi) > 1 )
    sortedphi              = sort(newphi(:))                               ;
    dphi                   = diff(sortedphi)                               ;
    [dphimax,dphimaxindex] = max(dphi)                                     ;

    gapsizemin = 2 * pi / 1800                                             ; % min 0.2 deg gap size 
    if ( dphimax > 2 * pi - abs(max(newphi)-min(newphi)) + gapsizemin )
        phigap = sortedphi(dphimaxindex)                                   ;
        if ( phigap > 0 )
            newphi(newphi >  phigap) = newphi(newphi >  phigap) - 2*pi     ; 
        else % phigap <= 0 
            newphi(newphi <= phigap) = newphi(newphi <= phigap) + 2*pi     ; 
        end
    end
    clear phi sortedphi dphi dphimax dphimaxindex phigap                   ;
end

% ---
% EOF