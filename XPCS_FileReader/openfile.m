function out = openfile(varargin)
% ---
% --- OPENFILE File opening function for different data file formats
% ---
% --- This function uses the file extension to separate between different
% --- file formats.
% ---
% --- OUT = OPENFILE(FILENAME,INDEX,{IMAGESTARTBYTE})
% ---
% --- DATA FILE NAMING CONVENTION :
% --- File names of single images CANNOT contain 'dashes'. The file name
% --- index should be written after an 'underscore' directly before the
% --- 'dot'.
% --- File names of multi image files should use a 'dash' to separate the
% --- first index number from the last index number. The first index
% --- number should be written after the last 'underscore' directly before
% --- the 'dot'.
% ---
% --- Input Argument(s):
% --- 1) FILENAME      : image file name
% ---
% --- Mandatory for multifiles:
% --- 2) INDEX         : image index number
% ---
% --- Optinal          :
% --- a) for compressed '*.imm' multifiles
% --- IMAGESTARTBYTE   : previously by INDEXCOMPRESSEDMULTIIMM determined
% ---                    starting byte positition of image #index
% --- b) to be continued
% ---
% ---
% --- Output Argument:
% --- out : structure containing header and image
% ---
% --- out.header : cell structure containing the header name & header value
% --- out.imm    : contains the image in single format
% ---
% ---  Michael Sprung
% ---  $Revision: 1.0 $  $Date: 2006/09/06 $
% ---


% =========================================================================
% --- prepare file name
% =========================================================================
file               = varargin{1}                                           ;
[~,name,ext] = fileparts(file)                                       ;
findDash           = findstr(name,'-')                                     ;


% =========================================================================
% --- check file mode (single or multi file)
% --- not perfect --> better to read first header and find switch
% =========================================================================
multi = 1                                                                  ; % assume multifile format
if ( isempty(findDash) == 1 )                                                % file name does not contain dashes --> single images
    multi = 0                                                              ;
end


% =========================================================================
% --- check if input provides the (mandotory) Index for multifiles 
% =========================================================================
Index = []                                                                 ;
if ( multi == 1 )
    if ( nargin > 1 )
        Index = varargin{2}                                                ;
    else
        Index = str2num(cell2mat(inputdlg(                              ...
                        'Please provide index number of image to open'  ...
                       ,'Openfile dialog')))                               ;
    end
else
    if ( nargin > 1 )
        Index = varargin{2}                                                ;
    end    
end


% =========================================================================
% --- call the right open routine for the input file
% =========================================================================
if ( multi == 0 )                                                           % single file case --> only file name needed
    % ---
    switch ext
        case {'.imm'}
            if ( nargin == 1 )
                out = opensingleimm(file)                                  ; % for a direct call to a single IMM file
            elseif ( nargin == 2 )
                out = opensingleimm(file,Index)                            ; % for a call to the index single IMM file of a batch
            end
        case {'.tif','.tiff'}
            if ( nargin == 1 )
                out = opensingletif(file)                                  ; % for a direct call to a single EDF file
            elseif ( nargin == 2 )
                out = opensingletif(file,Index)                            ; % for a call to the index single EDF file of a batch
            end
    end
    % ---
elseif ( multi == 1 )                                                        % multifile case --> file name & image index needed
    % ---
    switch ext
        case {'.imm'}
            if ( nargin <= 2 )
                out = openmultiimm(file,Index)                             ; % for a multi IMM file
            elseif ( nargin == 3 )
                ImageStartByte = varargin{3}                               ;
                out = openmultiimm(file,Index,ImageStartByte)              ; % for a multi IMM file                
            end
%         case {'.tif','.tiff'}
%             disp('This is a multi Tiff file')
    end
    % ---
end


% ---
% EOF
