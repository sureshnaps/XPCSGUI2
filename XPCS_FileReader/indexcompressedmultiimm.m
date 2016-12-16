function [imagestartindex,dlen] = indexcompressedmultiimm(varargin)
% ---
% --- INDEXCOMPRESSEDMULTIIMM Find all image start indices 
% --- in *.imm multifiles
% ---
% --- USAGE : IMAGESTARTINDEX = INDEXCOMPRESSEDMULTIIMM(FILENAME)
% ---
% --- Input Argument:
% --- FILENAME : image file name
% ---
% --- Output Argument:
% --- IMAGESTARTINDEX : vector containing the starting byte of each image
% ---                   or an empty array if FILENAME does not point to
% ---                   a valid compressed '*.imm' multifile
% ---
% --- Michael Sprung
% --- $Revision: 1.0 $Date: 2006/11/01 $
% ---


% =========================================================================
% --- input file preparation
% =========================================================================
file            = varargin{1}                                              ;
imagestartindex = []                                                       ; % initialize IMAGESTARTINDEX as empty array
% ---
findUnderscore  = findstr(file,'_')                                        ;
findDash        = findstr(file,'-')                                        ;
findDot         = findstr(file,'.')                                        ;


% =========================================================================
% --- open file
% =========================================================================
[fid,message] = fopen(file)                                                ;        
if ( fid == -1 )                                                             % return if open fails
    uiwait(msgbox(message,'File Open Error','error','modal'))              ;
    return                                                                 ;
end


% =========================================================================
% --- check for mode, compression & immversion
% =========================================================================
fseek(fid,0,'bof')                                                         ;
modeflag        = fread(fid,1 ,'int')                                      ;
fseek(fid,4,'bof')                                                         ;
compressionflag = fread(fid,1 ,'int')                                      ;
fseek(fid,616,'bof')                                                       ;
immversionflag  = fread(fid,1 ,'int')                                      ;
% --- check for multifile format
if ( immversionflag >= 11 && modeflag ~= 2 )
    fclose(fid)                                                            ; % not a multifile
    return                                                                 ;
elseif ( immversionflag < 11 && isempty(findDash) == 1 )
    fclose(fid)                                                            ; % not a multifile by file naming convention
    return                                                                 ;    
end
% --- check for compression
compression = 0                                                            ; % assume uncompressed files
if ( compressionflag == 65540 && isempty(findstr(file,'_ucp_')) )            % condition for SMD legacy code
    compression = 1                                                        ;
elseif ( compressionflag == 6 && immversionflag >= 11 )                      % condition for compressed data from Imageserver program
    compression = 1                                                        ;
end
if ( compression == 0 )
    fclose(fid)                                                            ; % not a compressed file
    return                                                                 ;    
end


% =========================================================================
% --- determine the start positions of all images in the multifile
% =========================================================================
firstImmIndex   = str2num(file(findUnderscore(end)+1:findDash(end)-1))     ;
if (nargin==2)
    lastImmIndex = varargin{2};
else
    lastImmIndex    = str2num(file(findDash(end)+1:findDot(end)-1))            ;
end
% ---
imagestartindex = zeros(lastImmIndex-firstImmIndex+1,1)                    ; % initialize the vector containing the image start indices 

% ---
% % if ( compressionflag == 65540 && isempty(findstr(file,'_ucp_')) )            % condition for SMD legacy code
% %     imagestartindex(1) = 0                                                 ;
% %     fseek(fid,152,'bof')                          ;
% %     dlen(1) = fread(fid,1 ,'int')                                         ; % 'dlen' in this case is the data length in bytes
% %     for k = 2 : lastImmIndex-firstImmIndex+1
% %         fseek(fid,imagestartindex(k-1)+152,'bof')                          ;
% %         dlen(k) = fread(fid,1 ,'int')                                         ; % 'dlen' in this case is the data length in bytes
% %         imagestartindex(k) = imagestartindex(k-1) + 1024 + dlen(k)         ;
% %     end
% % end

if ( compressionflag == 6 && immversionflag >= 11 )
    fseek(fid,116,'bof')                                                   ;
    bytes = fread(fid,1 ,'int')                                            ;
    % ---
    k=1;
    imagestartindex(k) = 0                                                 ;
    fseek(fid,152,'bof')                          ;
    dlen(1) = fread(fid,1 ,'int')                                         ; % 'dlen' in this case is the data length in bytes
    
    %     while(~feof(fid))
    for k = 2 : lastImmIndex-firstImmIndex+1
        %         k=k+1;
        fseek(fid,imagestartindex(k-1)+152,'bof')                          ;
        dlen(k) = fread(fid,1 ,'int')                                         ; % 'dlen' in this case contains the # of exposed pixels
        imagestartindex(k) = imagestartindex(k-1)+1024+dlen(k)*(4+bytes)      ;
    end
end


% =========================================================================
% --- close fid and return;
% =========================================================================
fclose(fid)                                                                ;
    

% ---
% EOF
