function varargout=loadbatchinfo(varargin)
% ---
% --- LOADBATCHINFO Load batchinfo file.
% ---
% --- Zhang Jiang & Michael Sprung
% --- $Revision: 1.0 $  $Date: 2004/12/03 $
% --- $Revision: 1.1 $  $Date: 2005/09/26 $ by MS
% ---            --> allow to call loadbatchinfo in a batchmode
% --- $Revision: 1.2 $  $Date: 2005/12/05 $ by MS
% ---            --> allow to use already background subtracted data
% ---            --> improve the handling of beam_i & beam_i_vacuum
% --- $Revision: 1.3 $  $Date: 2009/09/08 $ by ZJ Modifed to enable multiple
%       mask regions.
% --- $Revision: 1.4 $ $Date: 2009/11/20 $ by SN Modified to read the
% ---  immfilename from the batchinfo file using a newly added field and is
% ---  based on batchinfo version number >=13. This will allow the
% ---  immfilename to be of any name type with any number of zeros for the
% ---  frame numbers. This will also work when the data collection is
% ---  terminated in between.


%==========================================================================
% --- if it already exists load ccdimginfo & go the previous stored path
%==========================================================================
ccdimginfo=[];


currentPath  = pwd                                                         ;
%==========================================================================
% --- check if batchmode is used or else open GUI dialog box
%==========================================================================
file = varargin{1}  ;
%==========================================================================
% --- open info file loading information
%==========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                close the old windows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[fid,message] = fopen(file)                                                ; % open file
if fid == -1                                                                 % return if open fails
    uiwait(msgbox(message,'File Open Error','error','modal'))              ;
    return                                                                 ;
end
%==========================================================================
% --- reset everyting (kill all previous figures related to xpcsgui and
% --- clear ccdimginfo in main xpcsgui figure and in current workspace
%==========================================================================
resetxpcsgui                                                               ;                
clear ccdimginfo                                                           ; 


%==========================================================================
% --- get info file extension
%==========================================================================
[pathstr,name,ext]            = fileparts(file)                            ;
ccdimginfo.batchinfoExtension = ext                                        ;
ccdimginfo.imgPath            = pathstr                                    ;
ccdimginfo.batchinfoFile      = file                                       ;


%==========================================================================
% --- read batchinfo file
%==========================================================================
while feof(fid) == 0
    scanline  = fgetl(fid)                                                 ;
    equal_pos = find(scanline == '=')                                      ;
    right_str = scanline(equal_pos+1:end)                                  ;
    left_str  = scanline(1:equal_pos-1)                                    ;
    left_str(findstr(left_str,' '))=''                                     ; % remove space
    eval(['ccdimginfo.',left_str,'=','''',right_str,''';'])                ;
end
fclose(fid)                                                                ; % close file


%==========================================================================
% --- process the batchinfo information
%==========================================================================


%==========================================================================
% --- new batchinfo fields as of 10/2006
%==========================================================================

% --- batchinfoversion
if ( isfield(ccdimginfo,'batchinfo_ver') == 1 )
    ccdimginfo.batchinfoversion = ccdimginfo.batchinfo_ver                 ; % rename field
    ccdimginfo = rmfield(ccdimginfo,'batchinfo_ver')                       ; % remove old field
end
if ( isfield(ccdimginfo,'batchinfoversion') == 1 )
    ccdimginfo.batchinfoversion = str2num(ccdimginfo.batchinfoversion)     ; % should be greater 10 
else
    ccdimginfo.batchinfoversion = 10                                       ; % if exists batchinfoversion is always greater 10!!!
end

% --- mode (single : 1 | multi : 2 | not determined : 0)
ccdimginfo.mode = 0                                                        ; % predefine ccdimginfo.mode
if ( isfield(ccdimginfo,'multi_img') == 1 )
    ccdimginfo.multi_img     = str2num(ccdimginfo.multi_img)               ;
    ccdimginfo.mode          = ccdimginfo.multi_img + 1                    ; % reset ccdimginfo.mode (single ~ 1; multi ~ 2) 
    ccdimginfo               = rmfield(ccdimginfo,'multi_img')             ; % remove old field
else
    if ( ccdimginfo.batchinfoversion > 10 )
        dummy = inputdlg('Please provide file storage mode (single:1|multi:2):', ...
                         'Loadbatchinfo dialog')                           ;
        ccdimginfo.mode            = str2num(dummy{:})                     ;
    end
end

% --- compression (-1 : undefined; 0 : uncompressed; 1 : compressed)
if ( isfield(ccdimginfo,'compression') == 1 )
    ccdimginfo.compression = str2num(ccdimginfo.compression)               ;
else
    if ( ccdimginfo.batchinfoversion > 10 )
        dummy = inputdlg('Please provide file compression mode (uncompressed:0|compressed:1):', ...
                         'Loadbatchinfo dialog')                           ;
        ccdimginfo.compression = str2num(dummy{:})                         ;
    else
        ccdimginfo.compression = -1                                        ; % try later to figure the 'compression' out by file analysis
    end
end


%==========================================================================
% --- some string manipulations
%==========================================================================
if ( isfield(ccdimginfo,'info_name') == 1 )
    ccdimginfo.info_name(findstr(ccdimginfo.info_name,'"')) = ''           ; % remove "
    ccdimginfo.info_name(find(ccdimginfo.info_name == ' ')) = ''           ; %#ok<FNDSB> % remove spaces
else
    ccdimginfo.info_name = name                                            ; % still available from fileparts operation    
end
if ( isfield(ccdimginfo,'parent') == 1 )
    ccdimginfo.parent(findstr(ccdimginfo.parent,'"'))       = ''           ; % remove "
    ccdimginfo.parent(find(ccdimginfo.parent == ' '))       = ''           ; %#ok<FNDSB> % remove spaces
end
if ( isfield(ccdimginfo,'child') == 1 )
    ccdimginfo.child(findstr(ccdimginfo.child,'"'))         = ''           ; % remove "
    ccdimginfo.child(find(ccdimginfo.child == ' '))         = ''           ; %#ok<FNDSB> % remove spaces
end
if ( isfield(ccdimginfo,'suffix') == 1 )
    ccdimginfo.suffix(findstr(ccdimginfo.suffix,'"'))       = ''           ; % remove "
    ccdimginfo.suffix(find(ccdimginfo.suffix == ' '))       = ''           ; %#ok<FNDSB> % remove spaces
end
if ( isfield(ccdimginfo,'topup') == 1 )
    ccdimginfo.topup(findstr(ccdimginfo.topup,'"'))         = ''           ; % remove "
    ccdimginfo.topup(find(ccdimginfo.topup == ' '))         = ''           ; %#ok<FNDSB> % remove spaces
end
if ( isfield(ccdimginfo,'name') == 1 )
    ccdimginfo.name(findstr(ccdimginfo.name,'"'))           = ''           ; % remove "
    ccdimginfo.name(find(ccdimginfo.name == ' '))           = ''           ; %#ok<FNDSB> % remove spaces
end


%==========================================================================
% --- Experimental setup information (mandatory)
%==========================================================================
% --- detector
if ( isfield(ccdimginfo,'detector') == 1 )
    ccdimginfo.detector     = str2num(ccdimginfo.detector)                 ;
else
    dummy = inputdlg('Please provide DETECTOR type (see detectorinfo):',...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.detector            = str2num(dummy{:})                     ;
end
% --- nominal exposure time
if ( isfield(ccdimginfo,'preset') == 1 )
    ccdimginfo.preset     = str2num(ccdimginfo.preset)                     ;
else
    dummy = inputdlg('Please provide the nominal exposure time:',       ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.preset            = str2num(dummy{:})                       ;
end
% --- rr : Sample - Detector distance
if ( isfield(ccdimginfo,'rr') == 1 )
    ccdimginfo.rr           = str2num(ccdimginfo.rr)                       ;
else
    dummy = inputdlg('Please provide SAMPLE-DETECTOR distance [mm]:',   ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.rr                  = str2num(dummy{:})                     ;
end
% --- geometry
if ( isfield(ccdimginfo,'geometry') == 1 )
    ccdimginfo.geometry     = str2num(ccdimginfo.geometry)                 ;
else
    dummy = inputdlg('Please provide measurement geometry:',            ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.geometry            = str2num(dummy{:})                     ;
end
% --- energy (mandatory)
if ( isfield(ccdimginfo,'energy') == 1 )
    ccdimginfo.energy     = str2num(ccdimginfo.energy)                     ;
else
    dummy = inputdlg('Please provide x-ray energy [keV]:',              ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.energy            = str2num(dummy{:})                       ;
end
% --- determine wavelength of x-ray in unit of Angstrom
PLANCK                = 6.626068E-34                                       ;
SPEEDOFLIGHT          = 299792458                                          ;
ELEMENTARYCHARGE      = 1.60217646E-19                                     ;
ccdimginfo.wavelength = 1e10 * PLANCK * SPEEDOFLIGHT                    ...
                      /(ELEMENTARYCHARGE*1000*ccdimginfo.energy)           ;
clear PLANK SPEEDOFLIGHT ELEMENTARYCHARGE


%==========================================================================
% --- CCD type & CCD positions during the measurement (mandatory)
%==========================================================================
% --- ccdx
if ( isfield(ccdimginfo,'ccdx') == 1 )
    ccdimginfo.ccdx             = str2num(ccdimginfo.ccdx)                 ;
else
    dummy = inputdlg('Please provide CCDX position:',                   ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.ccdx             = str2num(dummy{:})                        ;
end
% --- ccdz
if ( isfield(ccdimginfo,'ccdz') == 1 )
    ccdimginfo.ccdz             = str2num(ccdimginfo.ccdz)                 ;
else
    dummy = inputdlg('Please provide CCDZ position:',                   ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.ccdz             = str2num(dummy{:})                        ;
end

%==========================================================================
% --- binning 
%==========================================================================
if isfield(ccdimginfo,'swbinX')
    ccdimginfo.swbinX = str2double(ccdimginfo.swbinX);
else
    ccdimginfo.swbinX = 1;
end
if isfield(ccdimginfo,'swbinY')
    ccdimginfo.swbinY = str2double(ccdimginfo.swbinY);
else
    ccdimginfo.swbinY = 1;
end


%==========================================================================
% --- direct beam position info (mandatory)
%==========================================================================
% --- x0 (mandatory)
if ( isfield(ccdimginfo,'x0') == 1 )
    ccdimginfo.x0           = str2num(ccdimginfo.x0)                       ;
else
    dummy = inputdlg('Please provide x pixel position of direct beam:', ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.x0                  = str2num(dummy{:})                     ;
end
% --- y0 (mandatory)
if ( isfield(ccdimginfo,'y0') == 1 )
    ccdimginfo.y0           = str2num(ccdimginfo.y0)                       ;
else
    dummy = inputdlg('Please provide y pixel position of direct beam:', ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.y0                  = str2num(dummy{:})                     ;
end
% --- ccdx0 (mandatory)
if ( isfield(ccdimginfo,'ccdx0') == 1 )
    ccdimginfo.ccdx0        = str2num(ccdimginfo.ccdx0)                    ;
else
    dummy = inputdlg('Please provide CCDX0 position:',                  ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.ccdx0            = str2num(dummy{:})                        ;
end
% --- ccdz0 (mandatory)
if ( isfield(ccdimginfo,'ccdz0') == 1 )
    ccdimginfo.ccdz0        = str2num(ccdimginfo.ccdz0)                    ;
else
    dummy = inputdlg('Please provide CCDZ0 position:',                  ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.ccdz0               = str2num(dummy{:})                     ;
end


%==========================================================================
% --- incident angle & reflected beam position
% --- (mandatory in reflection geometry)
%==========================================================================
if ( ccdimginfo.geometry == 1 )
    % --- nominal angle
    if ( isfield(ccdimginfo,'nominal_angle') == 1 )
        ccdimginfo.nominal_angle = str2num(ccdimginfo.nominal_angle)       ;
    else
        dummy = inputdlg('Please provide nominal incident angle [deg]:',...
                         'Loadbatchinfo dialog')                           ;
        ccdimginfo.nominal_angle   = str2num(dummy{:})                     ;
    end
    % --- xspec
    if ( isfield(ccdimginfo,'xspec') == 1 )
        ccdimginfo.xspec = str2num(ccdimginfo.xspec)                       ;
    else
        dummy = inputdlg('Please provide x position of reflected beam:',...
                         'Loadbatchinfo dialog')                           ;
        ccdimginfo.xspec   = str2num(dummy{:})                             ;
    end
    % --- yspec
    if ( isfield(ccdimginfo,'yspec') == 1 )
        ccdimginfo.yspec = str2num(ccdimginfo.yspec)                       ;
    else
        dummy = inputdlg('Please provide y position of reflected beam:',...
                         'Loadbatchinfo dialog')                           ;
        ccdimginfo.yspec   = str2num(dummy{:})                             ;
    end
    % --- ccdxspec
    if ( isfield(ccdimginfo,'ccdxspec') == 1 )
        ccdimginfo.ccdxspec = str2num(ccdimginfo.ccdxspec)                 ;
    else
        dummy = inputdlg('Please provide CCDXSPEC position:',           ...
                         'Loadbatchinfo dialog')                           ;
        ccdimginfo.ccdxspec   = str2num(dummy{:})                          ;
    end
    % --- ccdzspec
    if ( isfield(ccdimginfo,'ccdzspec') == 1 )
        ccdimginfo.ccdzspec = str2num(ccdimginfo.ccdzspec)                 ;
    else
        dummy = inputdlg('Please provide CCDZSPEC position:',           ...
                         'Loadbatchinfo dialog')                           ;
        ccdimginfo.ccdzspec   = str2num(dummy{:})                          ;
    end
elseif ( ccdimginfo.geometry == 0 )                                          % define specular beam to be -1 for transmission geometry
    ccdimginfo.nominal_angle    = -1                                       ; % define nominal angle to be -1 for transmission geometry
    ccdimginfo.xspec            = -1                                       ;
    ccdimginfo.ccdxspec         = -1                                       ;
    ccdimginfo.yspec            = -1                                       ;
    ccdimginfo.ccdzspec         = -1                                       ;
elseif ( ccdimginfo.geometry == 2 )  %new wide angle xpcs case
    ccdimginfo.nominal_angle    = -1                                       ; % define nominal angle to be -1 for wide angle
    ccdimginfo.xspec            = -1                                       ;
    ccdimginfo.ccdxspec         = -1                                       ;
    ccdimginfo.yspec            = -1                                       ;
    ccdimginfo.ccdzspec         = -1                                       ;
end


%==========================================================================
% --- kinetic mode settings
%==========================================================================
% --- kinetics (mandatory)
if ( isfield(ccdimginfo,'kinetics') == 1 )
    ccdimginfo.kinetics     = str2num(ccdimginfo.kinetics)                 ;
else
    dummy = inputdlg('Please provide CCD mode [normal:0|kinetics:1]:',  ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.kinetics            = str2num(dummy{:})                     ;
end
if ( ccdimginfo.kinetics == 1 )
    % --- kinetics window size (mandatory in kinetics mode)
    if ( isfield(ccdimginfo,'kinwinsize') == 1 )
        ccdimginfo.kinwinsize     = str2num(ccdimginfo.kinwinsize)         ;
    else
        dummy = inputdlg('Please provide kinetic window size:',         ...
                         'Loadbatchinfo dialog')                           ;
        ccdimginfo.kinwinsize            = str2num(dummy{:})               ;
    end
    % --- slice top position (mandatory in kinetics mode)
    if ( isfield(ccdimginfo,'slicetop') == 1 )
        ccdimginfo.slicetop     = str2num(ccdimginfo.slicetop)             ;
    else
        dummy = inputdlg('Please provide slice top position:',          ...
                         'Loadbatchinfo dialog')                           ;
        ccdimginfo.slicetop            = str2num(dummy{:})                 ;
    end
else
    ccdimginfo.kinwinsize   = -1                                           ;
    ccdimginfo.slicetop     = -1                                           ;
end


%==========================================================================
% --- image size and ROI information (mandatory)
%==========================================================================
if ( isfield(ccdimginfo,'rows') == 1 )
    ccdimginfo.rows     = str2num(ccdimginfo.rows)                         ;
else
    dummy = inputdlg('Please provide the number of rows:',              ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.rows            = str2num(dummy{:})                         ;
end
if ( isfield(ccdimginfo,'cols') == 1 )
    ccdimginfo.cols     = str2num(ccdimginfo.cols)                         ;
else
    dummy = inputdlg('Please provide the number of columns:',           ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.cols            = str2num(dummy{:})                         ;
end
if ( isfield(ccdimginfo,'col_beg') == 1 )
    ccdimginfo.col_beg     = str2num(ccdimginfo.col_beg)                   ;
    if (    ccdimginfo.batchinfoversion < 11                            ... 
       && ( ccdimginfo.detector == 5 || ccdimginfo.detector == 6 ) )         % correct values for SMD or Dalsa camera
        ccdimginfo.col_beg      = ccdimginfo.col_beg + 1                   ;
    end
else
    dummy = inputdlg('Please provide the starting column:',             ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.col_beg            = str2num(dummy{:})                      ;
end
if ( isfield(ccdimginfo,'col_end') == 1 )
    ccdimginfo.col_end     = str2num(ccdimginfo.col_end)                   ;
    if (    ccdimginfo.batchinfoversion < 11                            ... 
       && ( ccdimginfo.detector == 5 || ccdimginfo.detector == 6 ) )         % correct values for SMD or Dalsa camera
        ccdimginfo.col_end      = ccdimginfo.col_end + 1                   ;
    end
else
    dummy = inputdlg('Please provide the final column:',                ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.col_end            = str2num(dummy{:})                      ;
end
if ( isfield(ccdimginfo,'row_beg') == 1 )
    ccdimginfo.row_beg     = str2num(ccdimginfo.row_beg)                   ;
    if (    ccdimginfo.batchinfoversion < 11                            ... 
       && ( ccdimginfo.detector == 5 || ccdimginfo.detector == 6 ) )         % correct values for SMD or Dalsa camera
        ccdimginfo.row_beg      = ccdimginfo.row_beg + 1                   ;
    end
else
    dummy = inputdlg('Please provide the starting row:',                ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.row_beg            = str2num(dummy{:})                      ;
end
if ( isfield(ccdimginfo,'row_end') == 1 )
    ccdimginfo.row_end     = str2num(ccdimginfo.row_end)                   ;
    if (    ccdimginfo.batchinfoversion < 11                            ... 
       && ( ccdimginfo.detector == 5 || ccdimginfo.detector == 6 ) )         % correct values for SMD or Dalsa camera
        ccdimginfo.row_end      = ccdimginfo.row_end + 1                   ;    
    end
else
    dummy = inputdlg('Please provide the final row:',                   ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.row_end            = str2num(dummy{:})                      ;
end


%==========================================================================
% --- information for the data image indices (mandatory)
%==========================================================================
if ( isfield(ccdimginfo,'ndata0') == 1 )
    ccdimginfo.ndata0     = str2num(ccdimginfo.ndata0)                     ;
else
    dummy = inputdlg('Please provide the starting data numbers:',       ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.ndata0            = str2num(dummy{:})                       ;
end
if ( isfield(ccdimginfo,'ndataend') == 1 )
    ccdimginfo.ndataend     = str2num(ccdimginfo.ndataend)                 ;
else
    dummy = inputdlg('Please provide the ending data numbers:',         ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.ndataend            = str2num(dummy{:})                     ;
end


%==========================================================================
% --- information for the dark image indices
% --- allow for special treatment of the SMD camera
%==========================================================================
if ( isfield(ccdimginfo,'ndark0') == 1 )
    ccdimginfo.ndark0           = str2num(ccdimginfo.ndark0)               ;
else
    ccdimginfo.ndark0           = 0.0 * ccdimginfo.ndata0 + 99999          ; % dummy value
end
if ( isfield(ccdimginfo,'ndarkend') == 1 )
    ccdimginfo.ndarkend         = str2num(ccdimginfo.ndarkend)             ;
else
    ccdimginfo.ndarkend         = 0.0 * ccdimginfo.ndataend + 99998        ; % dummy value ( ndarkend < ndark0 !!! )
end
if ( isfield(ccdimginfo,'dark_preset') == 1 )
    ccdimginfo.dark_preset      = str2num(ccdimginfo.dark_preset)          ;
else
    ccdimginfo.dark_preset      = ccdimginfo.preset                        ; % set dark preset to data preset
end


%==========================================================================
% --- ring current values
%==========================================================================
% --- ring current values at beginning and end of a ccdseries
if ( isfield(ccdimginfo,'ring_i_beg') == 1 )
    ccdimginfo.ring_i_beg     = str2num(ccdimginfo.ring_i_beg)             ; % ring current at beginning of ccd series
else
    dummy = inputdlg('Please provide the starting ring current:',       ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.ring_i_beg            = str2num(dummy{:})                   ;
end
if ( isfield(ccdimginfo,'ring_i_end') == 1 )
    ccdimginfo.ring_i_end     = str2num(ccdimginfo.ring_i_end)             ; % ring current at beginning of ccd series
else
    dummy = inputdlg('Please provide the final ring current:',          ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.ring_i_end            = str2num(dummy{:})                   ;
end
if ( isfield(ccdimginfo,'ring_i') == 1 )
    ccdimginfo.ring_i     = str2num(ccdimginfo.ring_i)                     ; % this is the averaged ring current value for each ccd series
else
    dummy = inputdlg('Please provide the averaged ring current:',       ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.ring_i            = str2num(dummy{:})                       ;
end


%==========================================================================
% --- here intensity & ring current values from takeflux are arranged
% --- these values are optional since takeflux is not mandatory !!!
% --- create two flags (ccdimginfo.iflux & ccdimginfo.tflux) to take
% --- care of this problem !!!
% ---
% --- incident flux measurements (if beam exists than ring exists too!)
% ---
%==========================================================================
if ( isfield(ccdimginfo,'beam_i_vacuum') == 1 )
    ccdimginfo.iflux             = 1                                       ; % set incident flux measurement flag to one
    ccdimginfo.beam_i_vacuum     = str2num(ccdimginfo.beam_i_vacuum)       ; % this is the incident flux at the beam stop
    if ( numel(ccdimginfo.beam_i_vacuum) ~= numel(ccdimginfo.preset) )       % if it was not measured for each ccd series
        ccdimginfo.beam_i_vacuum = 0.0 * ccdimginfo.preset              ...
                                 + mean(ccdimginfo.beam_i_vacuum)          ; % create vector with the averaged incident flux
    end
else
    ccdimginfo.iflux             = 0                                       ; % set incident flux measurement flag to zero
    ccdimginfo.beam_i_vacuum     = 1.0 ; % create a vector of dummy values (assume it is e * I_trans)
    %ccdimginfo.beam_i_vacuum     = 0.0*ccdimginfo.preset + exp(1)*1.0e+009 ; % create a vector of dummy values (assume it is e * I_trans)
end
% ---
if ( isfield(ccdimginfo,'ring_i_vacuum') == 1 )
    ccdimginfo.ring_i_vacuum     = str2num(ccdimginfo.ring_i_vacuum)       ;
    if ( numel(ccdimginfo.ring_i_vacuum) ~= numel(ccdimginfo.preset) )       % if it was not measured for each ccd series
        ccdimginfo.ring_i_vacuum = 0.0 * ccdimginfo.preset              ...
                                 + mean(ccdimginfo.ring_i_vacuum)          ; % create vector with the averaged ring current
    end
else
    ccdimginfo.ring_i_vacuum     =  0.0 * ccdimginfo.preset + 1.0e+002     ; % create a vector of dummy values
end
% ---
% --- transmitted flux measurements (if beam exists than ring exists too!)
% --
if ( isfield(ccdimginfo,'beam_i') == 1 )
    ccdimginfo.tflux      = 1                                              ; % set transmitted flux measurement flag to one
    ccdimginfo.beam_i     = str2num(ccdimginfo.beam_i)                     ; % this is the transmitted intensity through the sample
    if ( numel(ccdimginfo.beam_i) ~= numel(ccdimginfo.preset) )              % if it was not measured for each ccd series
        ccdimginfo.beam_i = 0.0 * ccdimginfo.preset                     ...
                          + mean(ccdimginfo.beam_i)                        ; % create vector with the averaged transmitted flux
    end
else
    ccdimginfo.tflux      = 0                                              ; % set transmitted flux measurement flag to zero
    ccdimginfo.beam_i     = 1.0            ; % set to 1 for normalization
end
% ---
if ( isfield(ccdimginfo,'ring_i_sample') == 1 )
    ccdimginfo.ring_i_sample     = str2num(ccdimginfo.ring_i_sample)       ;
    if ( numel(ccdimginfo.ring_i_sample) ~= numel(ccdimginfo.preset) )       % if it was not measured for each ccd series
        ccdimginfo.ring_i_sample = 0.0 * ccdimginfo.preset              ...
                                 + mean(ccdimginfo.ring_i_sample)          ; % this is the averaged ring current
    end
else
    ccdimginfo.ring_i_sample    = 0.0 * ccdimginfo.preset + 1.0e+002       ; % create a vector of dummy values
end


%==========================================================================
% --- information of sample position, slit settings,
% --- airgaps, CCD speed & bstop (not mandatory)
%==========================================================================
% --- samx
if ( isfield(ccdimginfo,'samx') == 1 )
    ccdimginfo.samx             = str2num(ccdimginfo.samx)                 ;
else
    dummy = inputdlg('Please provide SAMX position:',                   ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.samx             = str2num(dummy{:})                        ;
end
% --- samz
if ( isfield(ccdimginfo,'samz') == 1 )
    ccdimginfo.samz             = str2num(ccdimginfo.samz)                 ;
else
    dummy = inputdlg('Please provide SAMZ position:',                   ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.samz             = str2num(dummy{:})                        ;
end
% --- samth
if ( isfield(ccdimginfo,'samth') == 1 )
    ccdimginfo.samth        = str2num(ccdimginfo.samth)                    ;
else
    if ( isfield(ccdimginfo,'th') == 1 )                                     % for G station setup
        ccdimginfo.samth    = str2num(ccdimginfo.th)                       ;        
    else
        dummy = inputdlg('Please provide SAMTH position:',              ...
                         'Loadbatchinfo dialog')                           ;
        ccdimginfo.samth            = str2num(dummy{:})                    ;
    end
end
% --- bstop
if ( isfield(ccdimginfo,'bstop') == 1 )
    ccdimginfo.bstop        = str2num(ccdimginfo.bstop)                    ;
else
    dummy = inputdlg('Please provide BSTOP position:',                  ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.bstop            = str2num(dummy{:})                        ;
end
% --- hgap (not mandatory)
if ( isfield(ccdimginfo,'hgap') == 1 )
    ccdimginfo.hgap     = str2num(ccdimginfo.hgap)                         ;
else
    dummy = inputdlg('Please provide horizontal gap value:',            ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.hgap            = str2num(dummy{:})                         ;
end
% --- vgap (not mandatory)
if ( isfield(ccdimginfo,'vgap') == 1 )
    ccdimginfo.vgap     = str2num(ccdimginfo.vgap)                         ;
else
    dummy = inputdlg('Please provide vertical gap value:',              ...
                     'Loadbatchinfo dialog')                               ;
    ccdimginfo.vgap            = str2num(dummy{:})                         ;
end
% --- airgap (not mandatory)
% if ( isfield(ccdimginfo,'airgap') == 1 )
%     ccdimginfo.airgap     = str2num(ccdimginfo.airgap)                     ;
% else
%     dummy = inputdlg('Please provide airgap value:',                    ...
%                      'Loadbatchinfo dialog')                               ;
%     ccdimginfo.airgap            = str2num(dummy{:})                       ;
% end
% % --- ccd_speed (not mandatory)
% if ( isfield(ccdimginfo,'ccd_speed') == 1 )
%     ccdimginfo.ccd_speed     = str2num(ccdimginfo.ccd_speed)               ;
% else
%     dummy = inputdlg('Please provide CCD speed value:',                 ...
%                      'Loadbatchinfo dialog')                               ;
%     ccdimginfo.ccd_speed            = str2num(dummy{:})                    ;
% end


%==========================================================================
% --- determine the batch start and end time
%==========================================================================
start_time              = ccdimginfo.start_time                            ;
end_time                = ccdimginfo.end_time                              ;
posDoubleQuoteStartTime = findstr('"',start_time)                          ;
posDoubleQuoteEndTime   = findstr('"',end_time)                            ;
ccdimginfo.start_time   = cell(length(ccdimginfo.ndata0),1)                ;
ccdimginfo.end_time     = cell(length(ccdimginfo.ndata0),1)                ;
for iBatch = 1:length(ccdimginfo.ndata0)
    ccdimginfo.start_time{iBatch} =                                     ...
        start_time( posDoubleQuoteStartTime(2*iBatch-1) + 1             ... 
                  : posDoubleQuoteStartTime(2*iBatch)   - 1)               ;
    ccdimginfo.end_time{iBatch}   =                                     ...
        end_time  ( posDoubleQuoteEndTime  (2*iBatch-1) + 1             ...
                  : posDoubleQuoteEndTime  (2*iBatch)   - 1)               ;
end


%==========================================================================
% --- for kinetics mode, determine the first and last usable slices;
% --- & determine positions of each slice and save to ccdimginfo.sliceinfo
%==========================================================================
if ccdimginfo.kinetics == 1                                                  % kinetic mode
    ccdimginfo.firstslice = 2                                              ;
    ccdimginfo.lastslice  = floor((ccdimginfo.row_end - ccdimginfo.row_beg +1)/ccdimginfo.kinwinsize);      
    shiftOffset           = ccdimginfo.slicetop-ccdimginfo.row_end         ; % offset for the first used row (negative value!!!)
    sliceInfo             = zeros(numel(1 : ccdimginfo.lastslice),2)       ;
    for iSlice = 1 : ccdimginfo.lastslice
        sliceInfo(iSlice,1) = shiftOffset      ...
                            + (iSlice-1) * ccdimginfo.kinwinsize           ; % bottom row of slice
        sliceInfo(iSlice,2) = shiftOffset - 1  ...
                            +  iSlice    * ccdimginfo.kinwinsize           ; % top row of slice
    end
    if (ccdimginfo.lastslice >=3 )
    	ccdimginfo.lastslice = ccdimginfo.lastslice -1                     ;
    end
    clear shiftOffset j
else                                                                         % full frame or roi mode
    ccdimginfo.firstslice   = -1                                           ;
    ccdimginfo.lastslice    = -1                                           ;
    sliceInfo(1,1)= ccdimginfo.row_beg                                     ;
    sliceInfo(1,2)= ccdimginfo.row_end                                     ;
end
ccdimginfo.sliceinfo = sliceInfo                                           ;
clear sliceInfo


%==========================================================================
% --- get detector settings
%==========================================================================
[ccdimginfo] = detectorinfo(ccdimginfo)                                    ;


%==========================================================================
% --- lower-level discrimination; 0 == no lld; minus means absolute lld,
% --- plus means relative lld, etc., -12: 12 ADU, 4 : 4 x dark RMS;
%==========================================================================
if ( ccdimginfo.compression == 1) 
    ccdimginfo.lld            = 0                                          ;
end
ccdimginfo.dpl                = 4                                          ; % # of delays per multi tau level
ccdimginfo.slicedpl           = 4                                          ; % # of slice delays per multi tau level
ccdimginfo.ssn                = 0                                          ; % use smoothed symetric normalization in dynamic analysis
ccdimginfo.ssnmin             = 100                                        ; % mininum # of pixels to smooth
ccdimginfo.memory             = 750                                        ; % computer memory used to do analysis 
ccdimginfo.analysistype       = 1                                          ; % perform 0) static analysis 1) dynamic analysis
ccdimginfo.savepath           = fullfile(ccdimginfo.imgPath,'cluster_results')      ; % default path to save analysis result (subdirectory result below image file)               

% --- start of posssible code to save in general 'result' directory
dummystr                      = fileparts(ccdimginfo.imgPath)              ;
ccdimginfo.savepath           = fullfile(dummystr,'cluster_results')                ; % overwrites old default saving directory
clear dummystr                                                             ;
% --- end of posssible code to save in general 'result' directory


%==========================================================================
% --- initialize the batches, ndata0, ndataend, ndark, ndarkend
%==========================================================================
ccdimginfo.batchestodo   = 1:length(ccdimginfo.ndata0)                     ;
ccdimginfo.ndata0todo    = ccdimginfo.ndata0                               ;
ccdimginfo.ndataendtodo  = ccdimginfo.ndataend                             ;
ccdimginfo.ndark0todo    = ccdimginfo.ndark0                               ;
ccdimginfo.ndarkendtodo  = ccdimginfo.ndarkend                             ;


%==========================================================================
% --- generate file names for all the batches and store in a cell structure
%==========================================================================
%Starting with batchinfo version of 13, a variable named "datafilename" is
%added to the batchinfo. This will help avoiding the old mode of generating
%the immfilename based on the prefix and the ndata0 and ndataend which has
%problems when the batch is terminated in the middle. (SN,Nov. 2009)
if ( ( ccdimginfo.mode == 0 || ccdimginfo.mode == 2 ) && ...
     (ccdimginfo.batchinfoversion >= 13) && (isfield(ccdimginfo,'datafilename') == 1) )                        % all old data sets plus all new multi sets
        tmp = strfind(ccdimginfo.datafilename,'"');
        tmp = ccdimginfo.datafilename(tmp(1)+1 : tmp(end)-1);
        tmp = regexp(tmp,'","','split');
        ccdimginfo.imagefile = cell(length(ccdimginfo.ndata0),1)           ;        
        for iBatch = 1:length(tmp)
            ccdimginfo.imagefile{iBatch} = fullfile(ccdimginfo.imgPath,tmp{iBatch}) ;
        end
        if (ccdimginfo.compression == 0)
            ccdimginfo.darkfile=ccdimginfo.imagefile;
        end
        clear tmp;

elseif ( ( ccdimginfo.mode == 0 || ccdimginfo.mode == 2 ) && ...
         (ccdimginfo.batchinfoversion <= 12) )                        % all old data sets plus all new multi sets
    ccdimginfo.imagefile = cell(length(ccdimginfo.ndata0),1)               ;
    if ( ccdimginfo.detector ~= 5 && ccdimginfo.detector ~= 6 && ccdimginfo.detector ~= 15 )
        ccdimginfo.imagefile = cell(length(ccdimginfo.ndata0),1)           ;
        for iBatch = 1:length(ccdimginfo.ndata0)
            frameBeg = '00000'                                             ;
            frameEnd = '00000'                                             ;
            % ---
            batchStart = num2str(min(ccdimginfo.ndata0(iBatch)          ...
                                    ,ccdimginfo.ndark0(iBatch) ) )         ;
            batchEnd   = num2str(max(ccdimginfo.ndataend(iBatch)        ...
                                    ,ccdimginfo.ndarkend(iBatch) ) )       ;
            % ---
            frameBeg(5-length(num2str(batchStart))+1:end) = batchStart     ;
            frameEnd(5-length(num2str(batchEnd))+1:end)   = batchEnd       ;
            % ---
            ccdimginfo.imagefile{iBatch} = fullfile(ccdimginfo.imgPath, ...
                [ccdimginfo.name,frameBeg,'-',frameEnd,ccdimginfo.suffix]) ;
            % ---
            clear batchStart batchEnd                                      ;
        end
    else
        Dell = 0                                                           ; % switch of acquisition computer
        if (Dell == 0 )
            if ( ccdimginfo.compression == 0 )

                ccdimginfo.imagefile = cell(length(ccdimginfo.ndata0),1)           ;
                for iBatch = 1:length(ccdimginfo.ndata0)
                    frameBeg = sprintf('%04i',min(ccdimginfo.ndata0(iBatch)  ,ccdimginfo.ndark0(iBatch)   ) ) ;
                    frameEnd = sprintf('%04i',max(ccdimginfo.ndataend(iBatch),ccdimginfo.ndarkend(iBatch) ) ) ;
                    ccdimginfo.imagefile{iBatch} = fullfile(ccdimginfo.imgPath, ...
                        [ccdimginfo.name,frameBeg,'-',frameEnd,ccdimginfo.suffix]) ;
                end
                ccdimginfo.darkfile = cell(length(ccdimginfo.ndark0),1)           ;
                for iBatch = 1:length(ccdimginfo.ndark0)
                    frameBeg = sprintf('%04i',min(ccdimginfo.ndata0(iBatch)  ,ccdimginfo.ndark0(iBatch)   ) ) ;
                    frameEnd = sprintf('%04i',max(ccdimginfo.ndataend(iBatch),ccdimginfo.ndarkend(iBatch) ) ) ;
                    ccdimginfo.darkfile{iBatch} = fullfile(ccdimginfo.imgPath, ...
                        [ccdimginfo.name,frameBeg,'-',frameEnd,ccdimginfo.suffix]) ;
                end

            elseif ( ccdimginfo.compression == 1)

                ccdimginfo.imagefile = cell(length(ccdimginfo.ndata0),1)           ;
                for iBatch = 1:length(ccdimginfo.ndata0)
                    frameBeg = sprintf('%04i',ccdimginfo.ndata0(iBatch) )         ;
                    frameEnd = sprintf('%04i',ccdimginfo.ndataend(iBatch) )       ;
                    ccdimginfo.imagefile{iBatch} = fullfile(ccdimginfo.imgPath, ...
                        [ccdimginfo.name,frameBeg,'-',frameEnd,ccdimginfo.suffix]) ;
                end
                ccdimginfo.darkfile = cell(length(ccdimginfo.ndark0),1)           ;
                for iBatch = 1:length(ccdimginfo.ndark0)
                    frameBeg = sprintf('%04i',ccdimginfo.ndata0(iBatch) )         ;
                    frameEnd = sprintf('%04i',ccdimginfo.ndataend(iBatch) )       ;
                    ccdimginfo.darkfile{iBatch} = fullfile(ccdimginfo.imgPath, ...
                        [ccdimginfo.name,frameBeg,'-',frameEnd,ccdimginfo.suffix]) ;
                end

            end
        elseif ( Dell == 1 )
            ccdimginfo.imagefile = cell(length(ccdimginfo.ndata0),1)           ;
            for iBatch = 1:length(ccdimginfo.ndata0)
                frameBeg = sprintf('%04i',ccdimginfo.ndata0(iBatch))           ;
                frameEnd = sprintf('%04i',ccdimginfo.ndataend(iBatch))         ;
                ccdimginfo.imagefile{iBatch} = fullfile(ccdimginfo.imgPath, ...
                    [ccdimginfo.name,frameBeg,'-',frameEnd,ccdimginfo.suffix]) ;
            end
            ccdimginfo.darkfile = cell(length(ccdimginfo.ndark0),1)            ;
            for iBatch = 1:length(ccdimginfo.ndark0)
                frameBeg = sprintf('%04i',ccdimginfo.ndark0(iBatch))           ;
                frameEnd = sprintf('%04i',ccdimginfo.ndarkend(iBatch))         ;
                ccdimginfo.darkfile{iBatch} = fullfile(ccdimginfo.imgPath,  ...
                    [ccdimginfo.name,frameBeg,'-',frameEnd,ccdimginfo.suffix]) ;
            end
        end
        clear Dell                                                         ;
    end
elseif ( ccdimginfo.mode == 1 )                                              % all new data sets in single file storage mode
    ccdimginfo.imagefile = cell(length(ccdimginfo.ndata0),1)               ;
    if ( ccdimginfo.detector ~= 5 && ccdimginfo.detector ~= 6 )
        ccdimginfo.imagefile = cell(length(ccdimginfo.ndata0),1)           ;
        if ( strcmp(ccdimginfo.suffix,'.imm') == 1 )
            ccdimginfo.imagefile = cell(length(ccdimginfo.ndata0),1)       ;
            for iBatch = 1:length(ccdimginfo.ndata0)
                frameBeg = '00000'                                             ;
                batchStart = num2str(min(ccdimginfo.ndata0(iBatch)          ...
                    ,ccdimginfo.ndark0(iBatch) ) )         ;
                frameBeg(5-length(num2str(batchStart))+1:end) = batchStart     ;
                % ---
                ccdimginfo.imagefile{iBatch} = fullfile(ccdimginfo.imgPath, ...
                    [ccdimginfo.name,frameBeg,ccdimginfo.suffix])  ;
                % ---
                clear batchStart                                               ;
            end
        elseif ( strcmp(ccdimginfo.suffix,'.edf') == 1 )
            ccdimginfo.imagefile = cell(length(ccdimginfo.ndata0),1)       ;
            for iBatch = 1:length(ccdimginfo.ndata0)
                frameBeg = '0000'                                                                ;
                batchStart = num2str(min(ccdimginfo.ndata0(iBatch),ccdimginfo.ndark0(iBatch) ) ) ;
                frameBeg(4-length(num2str(batchStart))+1:end) = batchStart                       ;
                % ---
                ccdimginfo.imagefile{iBatch} = fullfile(ccdimginfo.imgPath, ...
                    [ccdimginfo.name,frameBeg,ccdimginfo.suffix])  ;
                % ---
                clear batchStart                                               ;
            end
        elseif ( strcmp(ccdimginfo.suffix,'.img') == 1 )
            ccdimginfo.imagefile = cell(length(ccdimginfo.ndata0),1)       ;
            for iBatch = 1:length(ccdimginfo.ndata0)
                frameBeg = sprintf('%04i',ccdimginfo.ndata0(iBatch))           ;
                ccdimginfo.imagefile{iBatch} = fullfile(ccdimginfo.imgPath, ...
                                [ccdimginfo.name,frameBeg,ccdimginfo.suffix])  ;
            end
            ccdimginfo.darkfile = cell(length(ccdimginfo.ndark0),1)            ;
            for iBatch = 1:length(ccdimginfo.ndark0)
                frameBeg = sprintf('%04i',ccdimginfo.ndark0(iBatch))           ;
                ccdimginfo.darkfile{iBatch} = fullfile(ccdimginfo.imgPath,  ...
                                [ccdimginfo.name,frameBeg,ccdimginfo.suffix])  ;
            end    
        elseif (  strcmp(ccdimginfo.suffix,'.tif') == 1                  ...
               || strcmp(ccdimginfo.suffix,'.tiff') == 1 )
            ccdimginfo.imagefile = cell(length(ccdimginfo.ndata0),1)       ;
            for iBatch = 1:length(ccdimginfo.ndata0)
                frameBeg = sprintf('%05i',ccdimginfo.ndata0(iBatch))           ;
                ccdimginfo.imagefile{iBatch} = fullfile(ccdimginfo.imgPath, ...
                                [ccdimginfo.name,frameBeg,ccdimginfo.suffix])  ;
            end
            ccdimginfo.darkfile = cell(length(ccdimginfo.ndark0),1)            ;
            for iBatch = 1:length(ccdimginfo.ndark0)
                frameBeg = sprintf('%05i',ccdimginfo.ndark0(iBatch))           ;
                ccdimginfo.darkfile{iBatch} = fullfile(ccdimginfo.imgPath,  ...
                                [ccdimginfo.name,frameBeg,ccdimginfo.suffix])  ;
            end    
        end
    else   %%%if the detector is 5,6 (that is it is SMD or Dalsa)
        ccdimginfo.imagefile = cell(length(ccdimginfo.ndata0),1)           ;
        for iBatch = 1:length(ccdimginfo.ndata0)
            frameBeg = sprintf('%04i',ccdimginfo.ndata0(iBatch))           ;
            ccdimginfo.imagefile{iBatch} = fullfile(ccdimginfo.imgPath, ...
                            [ccdimginfo.name,frameBeg,ccdimginfo.suffix])  ;
        end
        ccdimginfo.darkfile = cell(length(ccdimginfo.ndark0),1)            ;
        for iBatch = 1:length(ccdimginfo.ndark0)
            frameBeg = sprintf('%04i',ccdimginfo.ndark0(iBatch))           ;
            ccdimginfo.darkfile{iBatch} = fullfile(ccdimginfo.imgPath,  ...
                            [ccdimginfo.name,frameBeg,ccdimginfo.suffix])  ;
        end    
    end    
end


%==========================================================================
% --- check if data is stored in a compressed multifile
%==========================================================================
ccdimginfo.compressedmulti = zeros(length(ccdimginfo.ndata0),1)            ; % assume data is not stored as compressed multifile 
ccdimginfo.SBCM            = cell(length(ccdimginfo.ndata0),1)             ; % create cell to store start bytes of images 
if (  ( ccdimginfo.mode == 0 || ccdimginfo.mode == 2 )                  ...
   &&   ccdimginfo.compression == 1 )                                       % this case is clear

    ccdimginfo.compressedmulti = ones(length(ccdimginfo.ndata0),1)         ; % data is stored as compressed multifile 
    
elseif (  ( ccdimginfo.mode == 0 || ccdimginfo.mode == 2 )              ...
       &&   ccdimginfo.compression == -1 )                                   % check all undefined data sets
   
    for iBatch = 1:length(ccdimginfo.ndata0)
        ccdimginfo.compressedmulti(iBatch) =                            ...
            iscompressedmultiimm(ccdimginfo.imagefile{iBatch})             ; % mark compressed multi files
    end

end

    
    
%==========================================================================
% --- define static and dynamic q phi partition information. Default
% values are listed below. Partition methods:
% 1. from existing result file (not working yet)
% 2. evenly spaced
% 3. equal dq/q (q & q_z partition); evenly spaced for phi partiton
% 4. manually set (not working yet)
% 5. no paritions (use whole image)
%==========================================================================
% --- Define methods for sq,sphi,dq,dphi
ccdimginfo.sqMethod         = 2                                            ;
ccdimginfo.sphiMethod       = 2                                            ;
ccdimginfo.dqMethod         = 2                                            ;
ccdimginfo.dphiMethod       = 2                                            ;
% --- Define existing file name and path for method 1
ccdimginfo.sqfile           = ''                                           ;
ccdimginfo.sphifile         = ''                                           ;
ccdimginfo.dqfile           = ''                                           ;
ccdimginfo.dphifile         = ''                                           ;
% --- Define default number of partitions for method 2,3 & 5
ccdimginfo.snoq             = 90                                          ;
ccdimginfo.snophi           = 1                                            ;
ccdimginfo.dnoq             = 18                                           ;
ccdimginfo.dnophi           = 1                                            ;
% ---
if ( ccdimginfo.sqMethod   == 5 )
    ccdimginfo.snoq   = 1                                                  ;
end
if ( ccdimginfo.sphiMethod == 5 )
    ccdimginfo.snophi = 1                                                  ;
end
if ( ccdimginfo.dqMethod   == 5 )
    ccdimginfo.dnoq   = 1                                                  ;
end
if ( ccdimginfo.dqMethod   == 5 )
    ccdimginfo.dnophi = 1                                                  ;
end
% --- Define q,phi span for method 4
ccdimginfo.sqspanstr        = ''                                           ;
ccdimginfo.sphispanstr      = ''                                           ;
ccdimginfo.dqspanstr        = ''                                           ;
ccdimginfo.dphispanstr      = ''                                           ;
% --- for any partition method, generate partition q and phi points
ccdimginfo.sqspan           = []                                           ;
ccdimginfo.sphispan         = []                                           ;
ccdimginfo.dqspan           = []                                           ;
ccdimginfo.dphispan         = []                                           ;


%==========================================================================
% --- define mask information method:
% 1. no mask (use all pixles) 
% 2. new mask (not should not be defined here --> use case 3 instead)
% 3. from existing custom mask file
%==========================================================================
% % % ccdimginfo = initializemask(ccdimginfo);      % mask is defined in
% convert_batchinfo_loadhdf5MetaData.m and loadhdf5MetaData.m; no need to
% repeat here.

%==========================================================================
% --- define mask information method for nfs data sets
%==========================================================================
nfs = 0                                                                    ; % switch for nfs data sets
if ( nfs == 1 )
    % --- define ccd positions for nfs
    ccdimginfo.ccdx0 = 0                                                   ; % meaningless for nfs data
    ccdimginfo.ccdz0 = 0                                                   ; % meaningless for nfs data
    ccdimginfo.ccdx  = ccdimginfo.ccdx0                                    ; % meaningless for nfs data
    ccdimginfo.ccdz  = ccdimginfo.ccdz0                                    ; % meaningless for nfs data
    % --- define roi positions for nfs data
    ccdimginfo.row_beg = 1                                                 ; % ROI info meaningless for nfs data
    ccdimginfo.col_beg = 1                                                 ; % ROI info meaningless for nfs data
    ccdimginfo.row_end = ccdimginfo.rows                                   ; % ROI info meaningless for nfs data
    ccdimginfo.col_end = ccdimginfo.cols                                   ; % ROI info meaningless for nfs data
    % --- define MapSize
    nfsMapSize            = 512                                            ; % define the nfs MapSize : should be a power of 2 or a sum of powers of 2!
    if ( mod(nfsMapSize,2) == 1 )
        nfsMapSize = nfsMapSize + 1                                        ; % make sure nfsMapSize is an even number
    end
    % --- define beam zero
    ccdimginfo.x0    = 320                                                 ; % please choose a new center point (>=nfsMapSize/2!)
    ccdimginfo.y0    = 512                                                 ; % please choose a new center point (>=nfsMapSize/2!)
    if ( ccdimginfo.x0 < nfsMapSize/2 || ccdimginfo.y0 < nfsMapSize/2 )
        disp('Please choose a different (valid) beamzero for the nfs data')
        return
    end
    % --- assign the nfsMapSize to the main structure
    ccdimginfo.nfsMapSize = nfsMapSize                                     ; % assign the nfs MapSize to the main struture
    % --- define usermask, maskpoints & maskroi
    ccdimginfo.maskMethod = 2                                              ; % set maskMethod to 2
    ccdimginfo.maskfile   = ''                                             ; % set the maskfile to ''
    % --- initialize the usermask (1/0) mask for the nfs case
    xpixels             = ccdimginfo.col_end-ccdimginfo.col_beg+1          ;
    ypixels             = ccdimginfo.row_end-ccdimginfo.row_beg+1          ;
    ccdimginfo.usermask = single(zeros(ypixels,xpixels))                   ; % mask everything
    clear xpixels ypixels                                                  ;
    % --- define mask points around "beam zero" 
    ccdimginfo.maskpoints = {[ccdimginfo.x0-(nfsMapSize/2-1) ccdimginfo.y0-(nfsMapSize/2-1)    ;   ...
                             ccdimginfo.x0+nfsMapSize/2     ccdimginfo.y0-(nfsMapSize/2-1)    ;   ...
                             ccdimginfo.x0+nfsMapSize/2     ccdimginfo.y0+nfsMapSize/2        ;   ...
                             ccdimginfo.x0-(nfsMapSize/2-1) ccdimginfo.y0+nfsMapSize/2 ]}             ;
    % --- define mask roi as corner points of the roi defined by maskpoints
    ccdimginfo.maskroi    = [ccdimginfo.x0-(nfsMapSize/2-1) ccdimginfo.y0-(nfsMapSize/2-1)    ;   ...
                             ccdimginfo.x0+nfsMapSize/2     ccdimginfo.y0+nfsMapSize/2 ]             ;
    % --- unmasked the wanted roi for the nfs data set
    ccdimginfo.usermask(ccdimginfo.y0-(nfsMapSize/2-1):ccdimginfo.y0+nfsMapSize/2             ,   ...
                        ccdimginfo.x0-(nfsMapSize/2-1):ccdimginfo.x0+nfsMapSize/2) = 1               ; % unmasked the nfs data roi 
end
clear nfs                                                                  ;



%==========================================================================
% --- define some switches for function mainanalysis & 'showresult.m'
%==========================================================================
ccdimginfo.TWOTIMEon   = 0                                                 ; % switch for two time correlation function control ( 0 : 'off' ; 1 : 'on' )
ccdimginfo.ASCIIon     = 0                                                 ; % switch for ASCII output ( 0 : 'off' ; 1 : 'on' ) (headers to be improved)
ccdimginfo.FIT1on      = 1                                                 ; % switch for single   exponential data fitting ( 0 : 'off' ; 1 : 'on' )
ccdimginfo.FIT2on      = 1                                                 ; % switch for streched exponential data fitting ( 0 : 'off' ; 1 : 'on' ) 
ccdimginfo.CUSTOMFITon = 0                                                 ; % switch for custom data fitting ( 0 : 'off' ; 1 : 'on' ) 
ccdimginfo.PNGon       = 0                                                 ; % switch for PNG   output ( 0 : 'off' ; 1 : 'on' ) (!!! very slow !!! ~180s)
ccdimginfo.WATERFALLon = 0                                                 ; % switch to show waterfall plot( 0 : 'off' ; 1 : 'on' )
ccdimginfo.STABILITYon = 0                                                 ; % switch for stabilty control (speckle movement) ( 0 : 'off' ; 1 : 'on' )


%==========================================================================
% --- define some values & switches for the thickness normalization
% normalization options
% 0 : only I_norm_0 = I_meas / adupphot / efficiency / exposure time         % [general case]
% 1 : I_norm_1 = I_norm_0 / ( (dpix_x*dpix_y)/rr^2 )                         % [transmission mode]
% 2 : I_norm_2 = I_norm_1 / I_trans                                          % [transmission mode]
% 3a: I_norm_3 = I_norm_2 / thickness or                                     % [transmission mode]
% 3b: I_norm_3 = I_norm_2 / ( atten_length*log(I_0/I_trans) )                % [transmission mode]
% 4 : I_norm_4 = I_norm_0 / I_0                                              % [reflection mode]
%==========================================================================
ccdimginfo.normalization = 0                                               ; % switch to keep track of normalization type [0,1,2,3,4]
% ---
ccdimginfo.thicknessflag = 0                                               ; % switch to keep track if thickness value or attenuation length is used [0,1,2]
ccdimginfo.atten_length  = -1                                              ; % sample attenuation length in [mm]
ccdimginfo.thickness     = -1                                              ; % sample thickness in [mm]


%==========================================================================
% --- save ccdimginfo to figure
%==========================================================================
 
if (isempty(varargin{2}))  
    hFigXPCSMain= findall(0,'Tag','xpcsmain_Fig') ;
    setappdata(hFigXPCSMain,'ccdimginfo',ccdimginfo)                           ;
varargout{1}=[];

%==========================================================================
% --- update message window in xpcsmain figure
%==========================================================================
newstr = {['   Click pushbuttons on Control Panel to view '             ...
          ,'and change batch information, analysis and system '         ...
          ,'settings before clicking Run to start analysis.'];'';'';'';''} ;
updatemessage(newstr)                                                      ;

hPushbuttonLoad      = findall(hFigXPCSMain,'Tag','xpcsmain_PushbuttonLoad')      ;
hPushbuttonBatchinfo = findall(hFigXPCSMain,'Tag','xpcsmain_PushbuttonBatchinfo') ;
hPushbuttonAnalysis  = findall(hFigXPCSMain,'Tag','xpcsmain_PushbuttonAnalysis')  ;
hPushbuttonSystem    = findall(hFigXPCSMain,'Tag','xpcsmain_PushbuttonSystem')    ;
hPushbuttonRun       = findall(hFigXPCSMain,'Tag','xpcsmain_PushbuttonRun')       ;
hPushbuttonResult    = findall(hFigXPCSMain,'Tag','xpcsmain_PushbuttonResult')    ;
hPushbuttonRun2t     = findall(hFigXPCSMain,'Tag','xpcsmain_PushbuttonRun2t')     ;
hPushbuttonStop      = findall(hFigXPCSMain,'Tag','xpcsmain_PushbuttonStop')      ;

set(hPushbuttonLoad     ,'Enable','on')                                    ;
set(hPushbuttonBatchinfo,'Enable','on')                                    ;
set(hPushbuttonAnalysis ,'Enable','on')                                    ;
set(hPushbuttonSystem   ,'Enable','off')                                    ;
set(hPushbuttonRun      ,'Enable','off')                                    ;
set(hPushbuttonResult   ,'Enable','on')                                    ;
set(hPushbuttonRun2t    ,'Enable','off')                                    ;
set(hPushbuttonStop     ,'Enable','off')                                   ;
else
varargout{1}=ccdimginfo;
end


%==========================================================================
% --- restore to current path
%==========================================================================
function restorePath(currentPath)
path_str = ['cd ','''',currentPath,'''']                                   ;
eval(path_str)                                                             ;


% ---
% EOF
