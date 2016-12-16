
function [flatfield] = getflatfield(ccdimginfo)
% 
% this routine load the flatfield file 
% if a camera needs a flat field correction
%
% Michael Sprung
% $Revision: 1.0 $  $Date: 2005/09/18 $
% 

% % % =========================================================================
% % % --- Detector 1 : Direct Detection CCD in slow mode
% % % =========================================================================
% % if ( ccdimginfo.detector == 1 )
% %     % ---
% %     flatfield = []                                                         ;
% %     % ---
% % end
% % 
% % 
% % % =========================================================================
% % % --- Detector 2 : Direct Detection CCD in fast mode
% % % =========================================================================
% % if ( ccdimginfo.detector == 2 )
% %     % ---
% %     flatfield = []                                                         ;
% %     % ---
% % end
% % 
% % 
% % % =========================================================================
% % % --- Detector 3 : Capillary Tapered Phosphor CCD 1st Harmonic
% % % =========================================================================
% % if ( ccdimginfo.detector == 3 )
% %     % ---
% %     load('flatfield_phos.mat')                                             ;
% %     flatfield(:,:) = img(ccdimginfo.row_beg:ccdimginfo.row_end,         ...
% %                          ccdimginfo.col_beg:ccdimginfo.col_end)            ; % reduce the flatfield to ROI size
% %     % ---
% % end
% %    
% % 
% % % =========================================================================
% % % --- Detector 4 : Capillary Tapered Phosphor CCD 3rd Harmonic
% % % =========================================================================
% % if ( ccdimginfo.detector == 4 )
% %     % ---
% %     load('flatfield_phos.mat')                                             ;
% %     flatfield(:,:) = img(ccdimginfo.row_beg:ccdimginfo.row_end,         ...
% %                          ccdimginfo.col_beg:ccdimginfo.col_end)            ; % reduce the flatfield to ROI size
% %     % ---
% % end



% =========================================================================
% --- Detector 5 : DALSA
% =========================================================================
if ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'DALSA', 'once')) )
    % ---
    flatfield = []                                                         ;
    % ---
end


% =========================================================================
% --- Detector 6 : SMD CCD 1st Harmonic four times gain
% =========================================================================
if ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'SMD', 'once')) )
    % ---
    flatfield = []                                                         ; % MS 032008 new chip
%     load('flatfield_smd.mat')                                              ;
%     flatfield(:,:) = img(ccdimginfo.row_beg:ccdimginfo.row_end,         ...
%                          ccdimginfo.col_beg:ccdimginfo.col_end)            ; % reduce the flatfield to ROI size
    % ---
end


% =========================================================================
% --- Detector 7 : Other #2 (to be determined)
% =========================================================================
% if ( ccdimginfo.detector == 7 )
%     % ---
% 
%     % ---
% end
% 
% 
% % =========================================================================
% % --- Detector 8 : PI-LCX 1300x1340
% % =========================================================================
% if ( ccdimginfo.detector == 8 )
%     % ---
%     flatfield = []                                                         ;
%     % ---
% end


% =========================================================================
% --- Detector 9 : CMOS
% =========================================================================
% if ( ccdimginfo.detector == 9 )
%     % ---
%     flatfield = []                                                         ;
%     % ---
% end
% 
% 
% % =========================================================================
% % --- Detector 10 : CMOS at 47deg .tilt
% % =========================================================================
% if ( ccdimginfo.detector == 10 )
%     % ---
%     flatfield = []                                                         ;
%     % ---
% end
% 
% 
% % =========================================================================
% % --- Detector 11 : Coolsnap
% % =========================================================================
% if ( ccdimginfo.detector == 11 )
%     % ---
%     flatfield = []                                                         ;
%     % ---
% end
% 
% 
% % =========================================================================
% % --- Detector 12 : Brookhaven IMG detector
% % =========================================================================
% if ( ccdimginfo.detector == 11 )
%     % ---
%     flatfield = []                                                         ;
%     % ---
% end
% 
% % =========================================================================
% % --- Detector 13 : PI-CNM 1300x1340
% % =========================================================================
% if ( ccdimginfo.detector == 13 )
%     % ---
%     flatfield = []                                                         ;
%     % ---
% end
% 

% =========================================================================
% --- Detector 14 : APS PILATUS DP00221
% =========================================================================
% if ( ccdimginfo.detector == 14 )
%     % ---
%     load('flatfield_pilatus_050407_150x2E5kev.mat')                        ;
%     flatfield(:,:) = img(ccdimginfo.row_beg:ccdimginfo.row_end,         ...
%                          ccdimginfo.col_beg:ccdimginfo.col_end)            ; % reduce the flatfield to ROI size
%     % ---
% end


% =========================================================================
% --- Detector 15 Fast CCD (new)
% =========================================================================
% if ( ccdimginfo.detector == 15 )
%     % ---
%     %load('flatfield_fccd_20090716_FeKa_B50VG8.mat');
%     %load('flatfield_fccd_20100719_FeKa_B50VG8_10msec.mat'); %%last used FCCD flatfield file for Larry till May 2011
%     if (ccdimginfo.preset < 0.019)
%     	%load('fccdFlatField10ms.mat');
%     	load('flatField_40V_10ms_1108.mat');
%     elseif (ccdimginfo.preset < 0.049)
%     	load('flatField_40V_20ms_1108.mat');
%     elseif (ccdimginfo.preset < 0.099)
%     	load('flatField_40V_50ms_1108.mat');
%     elseif (ccdimginfo.preset < 0.19)
%     	load('flatField_40V_100ms_1108.mat');
%     elseif (ccdimginfo.preset < 0.49)
%     	load('flatField_40V_200ms_1108.mat');
%     elseif (ccdimginfo.preset < 0.59)
%     	load('flatField_40V_500ms_1108.mat');
%     else
%     	load('flatField_40V_100ms_1108.mat');
%     end
%     %load('flatfield_fccd_20100719_FeKa_B50VG8_50msec.mat');
%     flatfield(:,:) = img(ccdimginfo.row_beg:ccdimginfo.row_end,         ...
%                          ccdimginfo.col_beg:ccdimginfo.col_end)            ; % reduce the flatfield to ROI size
%     % ---
% end

% =========================================================================
% --- Detector 25 : Lambda
% =========================================================================
if ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'LAMBDA', 'once')) )
    % ---
%     flatfield = ones(ccdimginfo.detector.rows,ccdimginfo.detector.cols);
    foo = load('Flatfield_AsKa_Th5p5keV.mat');
    flatfield = foo.flatfield;
    % ---
end


% =========================================================================
% --- clear variables
% =========================================================================
clear ccdimginfo                                                           ;


% ---
% EOF
