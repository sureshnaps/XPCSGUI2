function [sliceimg,ccdimginfo] = Compute_IMM_SumImages(varargin)

global ccdimginfo
ccdimginfo = varargin{1};

PI_CCD_NumFrames2Average = 100;
Sparse_CCD_NumFrames2Average = 200;

%%
% fname = ccdimginfo.xpcs.input_file_local{1};
%
% if isempty(regexp(ccdimginfo.xpcs.compression{1},'ENABLED','once'))
%     dk=collectimg(fname,ccdimginfo.xpcs.dark_begin_todo,ccdimginfo.xpcs.dark_end_todo);
%     dkavg=mean(dk,3);
%     clear dk;
% else
%     dkavg=0;
% end
%
%
% data = collectimg(fname,ccdimginfo.xpcs.data_begin_todo,min(ccdimginfo.xpcs.data_end_todo,...
%     ccdimginfo.xpcs.data_begin_todo+100));
% dataavg=mean(data,3);
% clear data;
%
% img=dataavg-dkavg;
% img(img<=0)=0;

%%
selectedBatch  = ccdimginfo.batchestodo(1)                             ;

try
    stride_frames = ccdimginfo.xpcs.stride_frames;
catch
    stride_frames = 1;
end

if (nargin == 2)
    dataIndex = varargin{2};
else
    dataIndex = ccdimginfo.xpcs.data_begin_todo(selectedBatch):stride_frames:ccdimginfo.xpcs.data_end_todo(selectedBatch);
end

if (nargin == 3)
    darkIndex = varargin{3};
else
    darkIndex = ccdimginfo.xpcs.dark_begin_todo(selectedBatch):ccdimginfo.xpcs.dark_end_todo(selectedBatch);
end

%%
if ( ~isempty(regexp(ccdimginfo.detector.manufacturer{1},'Princeton', 'once')) )
    dataIndexToDisplay = dataIndex(1:min(PI_CCD_NumFrames2Average,length(dataIndex)))             ; % 50 data images
    darkIndexToDisplay = darkIndex(1:min(50,length(darkIndex)))             ; % 10 dark images
else
    dataIndexToDisplay = dataIndex(1:min(Sparse_CCD_NumFrames2Average,length(dataIndex)))            ; % 100 data images for SMD camera
    darkIndexToDisplay = darkIndex(1:min(100,length(darkIndex)))            ; % 100 dark images for Sparse cameras
end

%%
% --- try to find starting positions in compressedmulti files
if ( ~isempty(regexp(ccdimginfo.xpcs.compression{1},'ENABLED', 'once')) )
    % =============================================================
    t1 = clock                                                     ;
    newstr = {'   Index compressed multifile!';' '}                ;
    updatemessage(newstr)                                          ;
    pause(0.001)                                                   ;
    % =============================================================
    SByte = indexcompressedmultiimm(ccdimginfo.xpcs.input_file_local{selectedBatch},dataIndexToDisplay(end)) ; % try to get starting byte position of indices
    % =============================================================
    t2 = clock                                                     ;
    t  = etime(t2,t1)                                              ;
    newstr = {['   Finish indexing compressed multifile in '    ...
        ,num2str(t),' seconds.']}                            ;
    updatemessage(newstr)                                          ;
    clear t t1 t2                                                  ;
    pause(0.001)                                                   ;
    % =============================================================
    %         end
else
    SByte = []                                                          ;
end

%%
% --- get data images from image file
sumData = 0                                                            ;
for iDataIndexToDisplay = dataIndexToDisplay
    if ( ~isempty(SByte) == 1 )
        f = openfile(ccdimginfo.xpcs.input_file_local{selectedBatch}            ...
            ,dataIndexToDisplay(iDataIndexToDisplay)        ...
            ,SByte(dataIndexToDisplay(iDataIndexToDisplay)  ...
            -ccdimginfo.xpcs.data_begin(selectedBatch)+1))        ; % load image file with pointer
    else
        f = openfile(ccdimginfo.xpcs.input_file_local{selectedBatch},uint32(iDataIndexToDisplay));
    end
    sumData = single(f.imm) + sumData                                  ;
end

%%
% --- get dark images from image file
sumDark = zeros(size(sumData))                                         ;
foo = regexp(ccdimginfo.xpcs.compression,'ENABLED', 'once');
if isempty(foo{1})
    for iDarkIndexToDisplay = darkIndexToDisplay
        f = openfile(ccdimginfo.xpcs.input_file_local{selectedBatch},uint32(iDarkIndexToDisplay))          ;
        sumDark = single(f.imm) + sumDark                                  ;
    end
end

%%
% --- calculate true data image by subtracting dark;
% --- set negative values to zero
if ( ~isempty(darkIndexToDisplay) )
    trueData = sumData/length(dataIndexToDisplay)                   ...
        - sumDark/length(darkIndexToDisplay)                      ;
else
    trueData = sumData/length(dataIndexToDisplay)                      ;
end
%%
%adjust the image size to a single slice if the mode is kinetics
%currently binning is not supported in the kinetics mode
if (ccdimginfo.detector.kinetics.mode == 1)
    sliceimg = trueData(ccdimginfo.detector.kinetics.sliceinfo(ccdimginfo.detector.kinetics.first_usable_slice,1):...
        ccdimginfo.detector.kinetics.sliceinfo(ccdimginfo.detector.kinetics.first_usable_slice,2),:);
else
    % --- bin pixels
    trueData = binimg(trueData,ccdimginfo.bin.swbinX,ccdimginfo.bin.swbinY);
    sliceimg=trueData;
end
%%
% --- save trueData to ccdimginfo.testimg for defining mask and partitions
ccdimginfo.xpcs.testimg = sliceimg; %used for all subsequent purpose, mask, etc
ccdimginfo.xpcs.fullimg = trueData;
end
