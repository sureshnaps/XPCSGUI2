function elapsed = immelapsed(varargin)
% ---
% --- IMMELAPSED read the elapsed time between images
% ---
% --- USAGE : ELAPSED = IMMELAPSED(FILENAME,STARTINDEX,ENDINDEX)
% ---
% --- Input Argument:
% --- FILENAME    : image file name
% --- STARTINDEX  : start image index number
% --- ENDINDEX    : end image index number
% ---
% --- Output Argument:
% --- ELAPSED     : vector of elapsed time between frames [sec]
% ---
% --- Zhang Jiang & Michael Sprung
% --- $Revision: 1.0 $  $Date: 2005/07/03 $
% --- $Revision: 1.1 $  $Date: 2005/12/01 $ CMOS camera uses systemtick
% --- $Revision: 1.2 $  $Date: 2006/09/10 $ can handle compressed files
% --- $Revision: 1.3 $  $Date: 2007/02/15 $ can handle corecotick
% ---


% =========================================================================
% --- prepare file name
% =========================================================================
file            = varargin{1}                                              ;
findUnderscore  = findstr(file,'_')                                        ;
findDash        = findstr(file,'-')                                        ;
findDot         = findstr(file,'.')                                        ;
% =========================================================================
% --- assign the other input parameter
% =========================================================================
immStartIndex   = varargin{2}                                              ;
immEndIndex     = varargin{3}                                              ;

if (nargin >3)
    SByte = varargin{4};
else
    SByte = [];
end
% =========================================================================
% --- check file mode (single or multi file)
% --- not perfect --> better to read first header and find switch
% =========================================================================
multi = 1                                                                  ; % assume multifile format
% =========================================================================
% =========================================================================
% --- 2) multi imm file case
% =========================================================================
% =========================================================================
if ( multi == 1 )
    
    % =====================================================================
    % --- create first & last image numbers for the multifile
    % =====================================================================
    %     firstImmIndex   = str2num(file(findUnderscore(end)+1:findDash(end)-1)) ; %#ok<ST2NM>
    %     lastImmIndex    = str2num(file(findDash(end)+1:findDot(end)-1))        ; %#ok<ST2NM>
    
    
    % =====================================================================
    % --- check if image index is out of range, error and return
    % =====================================================================
    %     if (  immStartIndex < firstImmIndex || immStartIndex > lastImmIndex ...
    %             || immEndIndex   < firstImmIndex || immEndIndex > lastImmIndex   ...
    %             || immEndIndex   < immStartIndex )
    %         error('Image index is out of range.')                              ;
    %     end
    
    
    % =====================================================================
    % --- correct image indices (basing on the total image numbers in file)
    % =====================================================================
    %     immStartIndex = immStartIndex - firstImmIndex + 1                      ;
    %     immEndIndex   = immEndIndex   - firstImmIndex + 1                      ;
    %
    
    % =====================================================================
    % --- open multi file
    % =====================================================================
    [fid,message] = fopen(file)                                            ;
    if ( fid == -1 )                                                         % return if open fails
        uiwait(msgbox(message,'File Open Error','error','modal'))          ;
        fclose(fid)                                                        ;
        return                                                             ;
    end
    
    
    % =====================================================================
    % --- check for compression
    % =====================================================================
    fseek(fid,4,'bof')                                                     ;
    compressionflag = fread(fid,1 ,'int')                                  ;
    fseek(fid,616,'bof')                                                   ;
    immversionflag  = fread(fid,1 ,'int')                                  ;
    % ---
    compression = 0                                                        ; % assume uncompressed files
    if ( compressionflag == 6 && immversionflag >= 11 )                  % condition for compressed data from Imageserver program
        compression = 1                                                    ;
    end
    
    
    % =====================================================================
    % --- uncompressed data : get the image size & start position
    % ---   compressed data : get start position of image of 'StartIndex'
    % =====================================================================
    fseek(fid,108,'bof')                                                   ;
    rows = fread(fid,1 ,'int')                                             ;
    fseek(fid,112,'bof')                                                   ;
    cols = fread(fid,1 ,'int')                                             ;
    fseek(fid,116,'bof')                                                   ;
    bytes = fread(fid,1 ,'int')                                            ;
    
    
    if ~isempty(SByte)
        imageStart = SByte(immStartIndex);
    else
        if ( compression == 0 )
            
            if ( immversionflag >= 11 )
                immSize = bytes * rows * cols + 1024                           ; % 'bytes' per pixel
            end
            imageStart = (immStartIndex-1)*immSize                             ;
            
        elseif ( compression == 1 )
            
            if ( compressionflag == 6 && immversionflag >= 11 )
                imageStart      = 0                                            ;
                for k = 1 : immStartIndex - 1
                    fseek(fid,imageStart+152,'bof')                            ;
                    dlen = fread(fid,1 ,'int')                                 ; % 'dlen' in this case contains the # of exposed pixels
                    imageStart = imageStart + 1024 + dlen * ( 4 + bytes )      ;
                end
            end
            
        end
    end
    % =====================================================================
    % --- load elapsed time & systemtick & corecotick
    % =====================================================================
    elapsed    = zeros(1,immEndIndex-immStartIndex+1)                      ;
    systemtick = zeros(1,immEndIndex-immStartIndex+1)                      ;
    corecotick = zeros(1,immEndIndex-immStartIndex+1)                      ;
    % ---
    if ~isempty(SByte)
        SByte_part = SByte(immStartIndex:immEndIndex);
        for iFrame=1:numel(SByte_part)
            fseek(fid,SByte_part(iFrame)+128,'bof')             ; % use relativ position in the file (changed by MS 20050909)
            elapsed(iFrame) = fread(fid,1,'double')                        ;
            % ---
            fseek(fid,SByte_part(iFrame)+164,'bof')             ;
            systemtick(iFrame) = fread(fid,1,'uint32=>double')             ;
            % ---
            fseek(fid,SByte_part(iFrame)+620,'bof')             ;
            corecotick(iFrame) = fread(fid,1,'uint32=>double')             ;            
        end
    else
        if ( compression == 0 )
            
            for iFrame = 1 : immEndIndex - immStartIndex + 1
                fseek(fid,imageStart+(iFrame-1)*immSize+128,'bof')             ; % use relativ position in the file (changed by MS 20050909)
                elapsed(iFrame) = fread(fid,1,'double')                        ;
                % ---
                fseek(fid,imageStart+(iFrame-1)*immSize+164,'bof')             ;
                systemtick(iFrame) = fread(fid,1,'uint32=>double')             ;
                % ---
                fseek(fid,imageStart+(iFrame-1)*immSize+620,'bof')             ;
                corecotick(iFrame) = fread(fid,1,'uint32=>double')             ;
            end
            
        elseif ( compression == 1 )
            
            for iFrame = 1 : immEndIndex - immStartIndex + 1
                fseek(fid,imageStart+128,'bof')                                ; % use relativ position in the file (changed by MS 20050909)
                elapsed(iFrame) = fread(fid,1,'double')                        ;
                %---
                fseek(fid,imageStart+152,'bof')                                ;
                dlen = fread(fid,1 ,'int')                                     ;
                % ---
                fseek(fid,imageStart+164,'bof')                                ;
                systemtick(iFrame) = fread(fid,1,'uint32=>double')             ;
                % ---
                fseek(fid,imageStart+620,'bof')                                ;
                corecotick(iFrame) = fread(fid,1,'uint32=>double')             ;
                % ---
                imageStart = imageStart + 1024 + dlen * (4+bytes)          ;
            end
            
        end
    end
    
    % =====================================================================
    % --- close multi file fid and return
    % =====================================================================
    fclose(fid)                                                            ;
    
    
end
% =========================================================================
% =========================================================================
% --- end of multi imm file case
% =========================================================================
% =========================================================================


% =========================================================================
% --- the systemtick & the corecotick can overflow
% =========================================================================
a1 = 2^32                                                                  ; % overflow value (2^32)
c1 = find(diff(systemtick) < 0)                                            ; % find positions where an overflow occured
if ( numel(c1) > 0 )
    for i = 1 : numel(c1)
        systemtick(c1(i)+1:end) = systemtick(c1(i)+1:end) + a1             ; % correct systemtick
    end
end
clear a1 c1                                                                ;

a2 = 2^31                                                                  ; % overflow value (2^31)
c2 = find(diff(corecotick) < 0)                                            ; % find positions where an overflow occured
if ( numel(c2) > 0 )
    for i = 1 : numel(c2)
        corecotick(c2(i)+1:end) = corecotick(c2(i)+1:end) + a2             ; % correct corecotick
    end
end
clear a2 c2                                                                ;


% =========================================================================
% --- convert corecotick & systemtick to a time in seconds
% =========================================================================
corecotick     = corecotick /1e06                                          ; % corecotick in [s]
processorspeed = 3.056e09                                                  ; % enter the processor speed of the data collecting computer (Peridot)
systemtick     = systemtick / processorspeed                               ; % systemtick in [s]


% =========================================================================
% --- decide if elapsed or corecotick / systemtick is used
% =========================================================================
if ( numel(find(diff(corecotick))) ==  numel(diff(corecotick)) )
    elapsed = corecotick                                                   ; % if the corecotick was monitored, than it should be used
else %%PI CCD is the only CCD so far that uses elapsed for timestamp, just found this bug
    %%that was checking for (  abs(elapsed(2) - elapsed(1)) <= 0.5, so
    %%changed that to 0.0. The idea must be that if the time stamps are
    %%messed up, then systemtick that has integer values could be used
    if (  abs(elapsed(2) - elapsed(1)) <= 0.0                           ...
            && numel(find(diff(systemtick))) ==  numel(diff(systemtick)) )
        elapsed = systemtick                                               ; % else if the systemtick was monitored, than it should be used
    end
end



% ---
% EOF
