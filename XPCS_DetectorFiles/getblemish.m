function [blemish] = getblemish(ccdimginfo)
%
% modify ccdimginfo.usermask to incoorporate blemish files
%
% Michael Sprung
% $Revision: 1.0 $  $Date: 2005/09/14 $
%

% dummydate = ccdimginfo.start_time{1}                                       ;
% dummychar = [4 5 6 7 8 9 10 20 21 22 23 24]                                ;
% batchdate = datenum(datestr(datevec(dummydate(dummychar),'mmm dd yyyy')))  ;
% clear dummydate dummychar                                                  ;

% =========================================================================
% --- Detector 5 : DALSA
% =========================================================================
% if ( ccdimginfo.detector == 5 )
if ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'DALSA', 'once')) )
    % ---
    b = ones(ccdimginfo.detector.SensorSizeRows                             ...
        ,ccdimginfo.detector.SensorSizeCols,'single')                       ;
    % ---
    b(      :      ,    1 :    4 ) = 0                                     ;
    b(      :      ,  254 :  256 ) = 0                                     ;
    b(      :      ,  257 :  260 ) = 0                                     ;
    b(      :      ,  510 :  512 ) = 0                                     ;
    b(      :      ,  513 :  516 ) = 0                                     ;
    b(      :      ,  766 :  768 ) = 0                                     ;
    b(      :      ,  769 :  772 ) = 0                                     ;
    b(      :      , 1023 : 1024 ) = 0                                     ;
    % ---
end


% =========================================================================
% --- Detector 6 : SMD CCD 1st Harmonic four times gain
% =========================================================================
% if ( ccdimginfo.detector == 6 )
if ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'SMD', 'once')) )
    % ---
    b = ones(ccdimginfo.detector.SensorSizeRows                             ...
        ,ccdimginfo.detector.SensorSizeCols,'single')                       ;
    
    %     chip_change_date_1 = datenum(datestr(datevec('2010-07-21','yyyy-mm-dd')))     ; % SN 08032010
    
    % ---
    b(      :      ,    1 :    4 ) = 0                                     ;
    b(      :      ,  254 :  256 ) = 0                                     ;
    b(      :      ,  257 :  260 ) = 0                                     ;
    b(      :      ,  510 :  512 ) = 0                                     ;
    b(      :      ,  513 :  516 ) = 0                                     ;
    b(      :      ,  766 :  768 ) = 0                                     ;
    b(      :      ,  769 :  772 ) = 0                                     ;
    b(      :      , 1023 : 1024 ) = 0                                     ;
    % ---
    
    b(:,517:end)=0; %mask the two right panels
    
    %     if ( batchdate < chip_change_date_1 )
    %         %%%new chip changed on 07/21/2010 by Tim Madden
    %         b(    1 :    8 ,      :      ) = 0                                     ; % MS 031408 from lead tape
    %         % --- The 3 polygons below are added SN 06122008
    %         b(18:38,920:960) = 0;
    %         b(78:108,920:970) = 0;
    %         b(18:123,970:1024) = 0;
    %         %%%new chip changed on 07/21/2010 by Tim Madden
    %         % --- The 3 polygons above are added SN 06122008
    %     end
    % --- polygon # 1 is replaced by
    %     b(    1 :  109 ,    1 :  67 ) = 0                                      ; % MS 032008 new chip
    % --- polygon # 2 is replaced by
    %     b(    1 :   45 ,  909 :1024 ) = 0                                      ; % MS 032008 new chip
    %     b(   45 :   68 ,  909 :1024 ) = 0                                      ; % MS 032008 new chip
    %     b(   68 :   88 ,  942 :1024 ) = 0                                      ; % MS 032008 new chip
    %     b(   88 :  131 ,  978 :1024 ) = 0                                      ; % MS 032008 new chip
    % --- polygon # 3 is replaced by
    %     b(  721 : 738 ,  436 :  462 ) = 0                                      ; % MS 032008 new chip
    % --- polygon # 4 (17ms data has rms >5) is replaced by
    %     b(  967 :  999 ,  936 : 949 ) = 0                                      ;
    % --- polygon # 5 (200ms data has rms >5) is replaced by
    %     b(  496 :  608 ,  909 : 936 ) = 0                                      ;
    % --- polygon # 6 (200ms data has rms >5) is replaced by
    %     b(  755 :  777 ,  695 :1024 ) = 0                                      ;
    % --- polygon # 7 (200ms data has rms >5) is replaced by
    %     b(    1 :   73 ,  736 : 962 ) = 0                                      ;
    %     b(   73 :  126 ,  738 : 957 ) = 0                                      ;
    %     b(  126 :  175 ,  752 : 957 ) = 0                                      ;
    %     b(  176 :  280 ,  777 : 957 ) = 0                                      ;
    % --- polygon # 8 (200ms data has rms >5) is replaced by
    %     b(  955 : 1008 ,  763 : 963 ) = 0                                      ;
    %     b(  764 :  954 ,  763 : 950 ) = 0                                      ;
end

% =========================================================================
% --- Detector 8 : PI-LCX 1300x1340
% =========================================================================
% if ( ccdimginfo.detector == 8 )
% if ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'Princeton', 'once')) )
% %     % ---
%     b = ones(ccdimginfo.detector.SensorSizeRows                             ...
%             ,ccdimginfo.detector.SensorSizeCols,'single')                       ;
% %     % ---
% %     damagedate1 = datenum(datestr(datevec('2008-06-24','yyyy-mm-dd')))     ; % SN & MS 06242008
% %     if ( batchdate > damagedate1 )
%         b(1030:end,709)        = 0				           ; %SN and MS 06242008
%         b(200:end,1215:1217)   = 0				           ;
%         b(400:end,965:967)     = 0					   ;
%         b(1070:1090,1135)      = 0					   ;
%         b(1:800,1330:end)      = 0					   ;
%         b(801:end,1338:end)    = 0					   ;
%         b(1081:1082,1176:1180) = 0					   ;
%         b(1082:1084,1182:1183) = 0					   ;
%         b(867:872,961:964)     = 0					   ;
% %     end
%     % ---
% end
% =========================================================================
% --- Detector 13 : PI-CNM 1300x1340
% =========================================================================
% if ( ccdimginfo.detector == 13 )
if ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'Princeton', 'once')) )
    % ---
    b = ones(ccdimginfo.detector.SensorSizeRows                             ...
        ,ccdimginfo.detector.SensorSizeCols,'single')                       ;
    % ---
    %3 or 4 major vertical streaks on Nov 8, 2015 at 21:32:44 hrs
    % % % % %     dataset: 2015-3/green201511/E002_PS_65K_OTS_100nm_125C_F1_001
    b(:,431:433)=0; %bad
    b(:,703:704)=0; %bad
    %to be safe, let us get adjacent cols also out
    b(:,430:434)=0; %bad
    b(:,702:705)=0; %bad
    
end


% =========================================================================
% --- Detector 14 : APS PILATUS DP00221
% =========================================================================
% if ( ccdimginfo.detector == 14 )
%     % ---
%     b = ones(ccdimginfo.detector.SensorSizeRows                             ...
%             ,ccdimginfo.detector.SensorSizeCols,'single')                       ;
%     % ---
%     b( 50: 52, 11: 13)   = 0		                     		           ;
%     b(147:149,188:190)   = 0		                    		           ;
%     b( 96: 99,241:244)   = 0		                    		           ;
%     b(106:108,372:374)   = 0			                    	           ;
%     b( 95: 98,425:428)   = 0				                               ;
%     % ---
% end


% =========================================================================
% --- Detector 15 : APS Detector Pool Fast CCD
% =========================================================================
% if ( ccdimginfo.detector == 15 )
if ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'xxxxxLBL', 'once')) )
    % ---
    b = ones(ccdimginfo.detector.SensorSizeRows                             ...
        ,ccdimginfo.detector.SensorSizeCols,'single')                       ;
    b(:,1:10) = 0; % taps 1 and 96
    b(:,471:480) = 0; % taps 48 and 49
    b(1:10,:) = 0; % top rows
    b(end-9:end,:) = 0; % bottom rows
    b(1:247,331:340) = 0; % dead tap - tap 34
    b(1:247,418:419) = 0; % 2 bright columns
    b(1:24,416:420) = 0; % some bright pixels - see long exposures dark near 2 bright colsa above
    b(14:15, 407:409) = 0; % cool T - rounded up to a 2X3 block
    b(14:15, 417:419) = 0; % cool T - rounded up to a 2X3 block
    b(14:15, 427:429) = 0; % cool T - rounded up to a 2X3 block
    b(13:16,398:399) = 0; % cool
    b(13:17,407:409) = 0; % cool
    b(13:17,427:429) = 0; % cool
    b(13:16,437:439) = 0; % cool
    b(14:15,448:449) = 0; % cool
    b(14:15,468:469) = 0; % cool
    b(13:17,411:415) = 0; % cool
    b(14,398:399) = 0; % cool
    b(166:168, 196:197) = 0; % hot pixels - not sure why
    b(169:171, 198:199) = 0; % hot pixels - not sure why
    b(166:167, 195) = 0; % hot pixels - not sure why - see long exposures
    b(169:170, 197) = 0; % hot pixels - not sure why - see long exposures
    b(472:474, 356:358) = 0; % hot pixels - not sure why
    b(452:454,141:142)=0; % hot - not sure why
    b(455:457,144)=0; % hot - not sure why
    b(166:167,186) = 0; % see 100 ms, att 0 data
    b(169:170,188:189) = 0; % see 100 ms, att 0 data
    b(166:167,206) = 0; % see 100 ms, att 0 data
    b(169:170,208:209) = 0; % see 100 ms, att 0 data
    b(395,56:57) = 0; % see 100 ms, att 0 data
    b(398:399,59) = 0; % see 100 ms, att 0 data
    
    % bad 1/6 because of noise pickup on fcric
    %     b(1:247,321:end) = 0;
    
    % >= 60 V
    b(394:396, 56:57) = 0;
    b(474:475, 68:69) = 0;
    b(249:250, 143) = 0;
    b(254:255, 279:280) = 0;
    b(257:258, 282) = 0;
    b(280:285, 198:200) = 0;  % maybe a zinger
    % >= 80 V
    b(395,58)=0;
    b(384:385, 286:287) = 0;
    b(387:388, 288:289) = 0;
    
    b(32, 415:417)=0;% hot pixels x:415~417 32
end

% =========================================================================
% --- Detector 20 : ANL-LBL FCCD-2 frame transfer (NB3, came to APS in Oct 2015)
% =========================================================================
% % % if ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'LBL', 'once')) )
% % %     if (ccdimginfo.detector.adu_per_photon > 10) %%kludge for FCCD or certainly not Eiger
% % %         % ---
% % %     b = ones(ccdimginfo.detector.SensorSizeRows                             ...
% % %             ,ccdimginfo.detector.SensorSizeCols,'single')                       ;
% % % % % %         % ---
% % %
% % %
% % %         if (ccdimginfo.detector.rows == 962)
% % %             b(1:480,431:440)=0;
% % %             b(1:480,731:740)=0;
% % %             b(1:480,951:960)=0;
% % %
% % %             b(481:end,641:650)=0;
% % %             b(481:end,691:700)=0;
% % %             b(481:end,741:750)=0;
% % %
% % %             b(481:end,321:330)=0; %%slightly bad
% % %         elseif (ccdimginfo.detector.rows == 92) %as of Aug 2014
% % % %             b(1:45,121:130)=0;
% % %         end
% % %
% % %     end
% % % end
% =========================================================================
% --- Detector 20 : ANL-LBL FCCD-2 frame transfer (NB2 original detector)
% =========================================================================
if ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'LBL', 'once')) )
    if (ccdimginfo.detector.adu_per_photon > 10) %%kludge for FCCD or certainly not Eiger
        % ---
        b = ones(ccdimginfo.detector.SensorSizeRows                             ...
            ,ccdimginfo.detector.SensorSizeCols,'single')                       ;
        % ---
        
        
        if (ccdimginfo.detector.rows == 962)
            b(1:480,121:130)=0;
            b(1:480,721:730)=0;
            b(481:962,441:450)=0;
            b(481:962,462:470)=0;
            b(417:418,620:634)=0;
            b(419:421,637:655)=0;
            b(961:962,1:960)=0;
            b(1,1:960)=0;
            b(960,1:960)=0;
                       
            b(481:962,81:90)=0;
                                 
            b(1:481,101:105)=0;
            
            b(1:481,131:133)=0;
            b(1:481,141:145)=0;
            
            
            %%%temp blemish regions
            %       b(1:480,321:480)=0;
            %       b(1:480,721:810)=0;
            b(1:480,831:840)=0;
            
            
            
            %       b(481:962,801:810)=0; %add 1 strip
            %
            %       b(1:480,111:120)=0; %add 2nd strip
            %       b(1:480,101:110)=0; %add 3rd strip
            %%
            % bad=find(a>2);from RM data set
            fccd2_random_bad_pixels=load('fccd2_random_blemishpixels.mat');
            b(fccd2_random_bad_pixels.bad)=0;
            
        elseif (ccdimginfo.detector.rows == 92) %as of Aug 2014
            b(1:45,121:130)=0;
            b(1:45,721:730)=0;
            b(91:92,1:960)=0;
            b(46:92,441:450)=0;
            b(46:92,461:470)=0;
            b(46:92,771:780)=0;
            
            
            
            
            b(1:45,831:840)=0;
        end
        
    end
end

% =========================================================================
% --- Detector 25 : Lambda
% =========================================================================
if ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'LAMBDA', 'once')) )
    
    foo = load('Blemish_Th5p5keV.mat');
    b=foo.b;    
end

% =========================================================================
% --- Detector 30 : Eiger
% =========================================================================
if ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'LBL', 'once')) )
    if (ccdimginfo.detector.adu_per_photon < 10) %%kludge for Eiger or certainly not FCCD
        % ---
        %     b = ones(ccdimginfo.detector.SensorSizeRows                             ...
        %             ,ccdimginfo.detector.SensorSizeCols,'single')                       ;
        
        %         b=transpose(h5read('series_29_master.h5','/entry/instrument/detector/detectorSpecific/pixel_mask'));
        %         b=(b==0);
        
        %this flatfield matfile is saved in DetectorFiles directory in XPCSGUI2
        foo=load('eiger_blemish_apr03_1.mat');
        b=foo.b;
        
        %more blemish regions found during Mark on March 4, 2015
        b(491,154)=0;
        % ---
        % ---
    end
end


% =========================================================================
% --- Detector 40 : VIPIC
% =========================================================================
if ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'VIPIC', 'once')) )
    % ---
    b = ones(ccdimginfo.detector.SensorSizeRows                             ...
        ,ccdimginfo.detector.SensorSizeCols,'single')                       ;
    % ---
    
end


% =========================================================================
% --- Detector 50 : VOXTEL
% =========================================================================
if ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'VOXTEL', 'once')) )
    % ---
    b = ones(ccdimginfo.detector.SensorSizeRows                             ...
        ,ccdimginfo.detector.SensorSizeCols,'single')                       ;
    % ---
    % zeros
    b(1,12)=0;
    b(1,34)=0;
    b(3,9)=0;
    b(6:7,4)=0;
    
    %hot
    b(28,2)=0;
    b(30,4)=0;
    b(32,1)=0;
    b(28,47:48)=0;
    b(28,47:48)=0;
    b(31,47)=0;
    b(33,31)=0;
    b(36,45:48)=0;
    b(37,48)=0;
    b(37:39,42)=0;
    b(45:46,44)=0;
    
    %zeros
    b(22,42)=0;
    b(31,24)=0;
    b(32,36)=0;
    b(33,31)=0;
    b(34,21)=0;
    b(36,31)=0;
    b(36,34:36)=0;
    b(37:38,26)=0;
    b(37:38,28)=0;
    b(37,38)=0;
    b(38,34)=0;
    b(40,26)=0;
    b(40,28)=0;
    b(40,30)=0;
    b(40,32)=0;
    b(40,32)=0;
    b(40,38:39)=0;
    b(41,21)=0;
    b(41,31)=0;
    b(41,35)=0;
    b(42,30)=0;
    b(43,24)=0;
    b(43,40)=0;
    b(44:46,25)=0;
    b(44,36)=0;
    b(45,11)=0;
    b(45,20)=0;
    b(45,31)=0;
    b(45,33)=0;
    b(45,37)=0;
    b(45,39)=0;
    b(46,12)=0; %maybe?
    b(46,13)=0;
    b(46,25)=0;
    b(46,30)=0;
    b(46,35)=0;
    b(46,40)=0;
end
% =========================================================================
% --- Reduce to ROI size and if needed to a slice size
% =========================================================================
if ( ccdimginfo.detector.kinetics.mode == 0 )                                              % full frame mode
    blemish = b(ccdimginfo.detector.y_begin+1:ccdimginfo.detector.y_end+1,                  ...
        ccdimginfo.detector.x_begin+1:ccdimginfo.detector.x_end+1)                     ; % take only ROI
    clear b                                                                ;
else                                                                         % kinetics mode
    dummy(:,:) = b(ccdimginfo.detector.y_begin+1:ccdimginfo.detector.y_end+1,         ...
        ccdimginfo.detector.x_begin+1:ccdimginfo.detector.x_end+1)            ; % take only ROI
    [~,j]      = find(dummy == 0)                                          ; % find all zeros in dummy
    dummy(:,j) = 0                                                         ; % set all values of columns containing a zero to zero
    blemish(:,:)     = dummy(1 : ccdimginfo.detector.kinetics.window_size,:)                  ;
    clear b dummy i j                                                      ;
end

% =========================================================================
% --- blemish for binning
% =========================================================================
blemish = blemish_binimg(blemish,ccdimginfo.bin.swbinX,ccdimginfo.bin.swbinY);
blemish(blemish~=ccdimginfo.bin.swbinX*ccdimginfo.bin.swbinY) = 0;

end

function blemish = blemish_binimg(blemish,swbinX,swbinY)
if swbinY ~=1 || swbinX ~=1
    [rows, cols] = size(blemish);
    % --- remove last rows and cols if not divisible
    blemish = blemish(1:end-mod(rows,swbinY),1:end-mod(cols,swbinX));
    [rows,cols] = size(blemish);        % new rows and cols
    % --- bin
    blemish = transpose(reshape(sum(reshape(blemish,swbinY,[]),1),rows/swbinY,[]));
    blemish = transpose(reshape(sum(reshape(blemish,swbinX,[]),1),cols/swbinX,[]));
end

end

