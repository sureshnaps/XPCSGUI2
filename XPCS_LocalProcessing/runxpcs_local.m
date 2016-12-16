function varargout = runxpcs_local(varargin)

if (nargin < 2)
    error('Correct Usage: runxpcs_local(metadatafilename,params');
end

batchinfoname=varargin{1}; %hdf or batchinfo file
XPCSparams = varargin{2};
if (nargin > 2)
    endpoint = varargin{3};
else
    endpoint = '';
end
%%
[img,ccdimginfo] = create_IMM_dataMatrix(batchinfoname,XPCSparams,endpoint);
whos img;

evalin('base','global ccdimginfo'); %%to make it global in base workspace
%%
if (ccdimginfo.detector.kinetics.mode == 1)
    %reshapes img into slices
    img = reshape(img,ccdimginfo.detector.rows,ccdimginfo.detector.cols,[]);
    img=permute(reshape(permute(img,[2,1,3]),ccdimginfo.detector.cols,ccdimginfo.detector.kinetics.window_size,[]),[2,1,3]);
    img = squeeze(reshape(img,1,[],size(img,3)));
    
    %apply mask for kinetics mode here as mask is of the size of a slice
    if (verLessThan('matlab','9.1.0')) %before R2016b
        img = bsxfun(@times,img,ccdimginfo.mask.usermask(:));
    else %from R2016b, bsxfun is not needed, can be operated directly
        img = img .* ccdimginfo.mask.usermask(:);
    end
end
%%
if (ccdimginfo.detector.kinetics.mode == 0) %full frame mode
    viewresultinfo = Process_img_StaticCalc(img,ccdimginfo);
    
else %kinetics mode where ever applicable
    %computes the good slice list over the entire time series frames
    good_slice_list_per_frame = kinetics_slice_list(ccdimginfo);    
    %pick only the good slices data
    viewresultinfo = Process_img_StaticCalc( img(:,good_slice_list_per_frame(:)),ccdimginfo);
end
%%
disp('Start computing G2,IP,IF');
tic;
try
    dpl = ccdimginfo.xpcs.dpl;
catch
    dpl=4;
end

%%
%find frame spacing from time stamps or exposure time, as deemed appropriate
framespacing = compute_framespacing(ccdimginfo);
viewresultinfo.result.framespacing{1} = framespacing;
%%
if (ccdimginfo.detector.kinetics.mode == 0) %full frame mode
    [viewresultinfo.result.delay{1},viewresultinfo.result.G2{1},viewresultinfo.result.IP{1},...
        viewresultinfo.result.IF{1}]=rawg2_1D(img,dpl,framespacing);
    
else %kinetics mode where ever applicable
    [viewresultinfo.result.delay{1},viewresultinfo.result.G2{1},viewresultinfo.result.IP{1},...
        viewresultinfo.result.IF{1}]= rawg2_1D_kinetics_mode(img, dpl, framespacing, ccdimginfo);
end

if (size(viewresultinfo.result.delay{1},1)==1)
    viewresultinfo.result.delay{1}=transpose(viewresultinfo.result.delay{1});
end

disp('Done computing G2,IP,IF');
toc;
%%
disp('Start Normalizing g2');
tic;
[viewresultinfo.result.g2avg{1},viewresultinfo.result.g2avgErr{1}] = function_g2_normalize(viewresultinfo.result.G2{1},...
    viewresultinfo.result.IP{1},viewresultinfo.result.IF{1},ccdimginfo);

viewresultinfo.result.dynamicQs{1}=ccdimginfo.partition.dmeanmap(:,1);
viewresultinfo.result.dynamicPHIs{1}=ccdimginfo.partition.dmeanmap(:,2);
toc;
disp('Done Normalizing g2');
%%
%fit g2s
disp('Start Fitting g2s');
% tic;
viewresultinfo.result = fit_hadoop_g2s(viewresultinfo.result);
disp('Done Fitting g2s');
% toc;
%%
matfile_viewresultinfo.result = Local_cluster_result_reshape(ccdimginfo,viewresultinfo.result);
%%
if (nargout >= 1)
    varargout{1}=matfile_viewresultinfo;
end
if (nargout >= 2)
    varargout{2}=ccdimginfo;
end
if (nargout >= 3)
    varargout{3}=img;
end
%%
force_save_to_matfile = 0;
try
    if H5F.is_hdf5(batchinfoname) && (force_save_to_matfile == 0)%is a hdf file
        force_save_to_matfile = 0;
        disp('Saving Calculated results to the HDF5 file');
        save_XPCS_results_hdf5(batchinfoname,endpoint,viewresultinfo.result);
        disp('Saving Fit results to the HDF5 file');
        result_group_location = h5read(batchinfoname,[endpoint,'/output_data']);
        save_g2fit_hdf5(batchinfoname,result_group_location,viewresultinfo.result);
        viewresult(batchinfoname);
    end
catch    
    disp('Error in saving results to HDF5 file, possibly an existing group..');
    disp('Instead SAVING to a .mat file..');
    force_save_to_matfile = 1;
end
%%
try
    if ( ~H5F.is_hdf5(batchinfoname) || (force_save_to_matfile) ) %is NOT a hdf file or hdf failed, save to .mat file
        [savepath,savefile,~] = fileparts(ccdimginfo.fullpath_info_name); % define filename for binary output
        savefull = fullfile(savepath,[savefile,'.mat']);
        if (exist(savefull,'file') == 2)
            savefull = fullfile(savepath,[savefile,datestr(now,'_yyyymmddTHHMMSS'),'.mat']);
        end
        viewresultinfo = matfile_viewresultinfo;
        save(savefull,'viewresultinfo','ccdimginfo','-v7.3');
        viewresult(savefull);
    end
catch    
    disp('Error in saving results to .mat file..');
    disp('Bringing up VIEWRESULT Window');
    viewresult(viewresultinfo);    
end

%%
% disp('Bringing up VIEWRESULT Window');
% viewresult(viewresultinfo);
