% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear TwoTimeInfo
Num_CPU_Cores=6;
Force_CPU=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parent_data_folder='/home/8-id-e/2014-3/chathoth1410/';
result_files_folder='/home/8-id-e/2014-3/chathoth1410/results/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
wildcard_filename = dir(fullfile(parent_data_folder,'Ce70Cu20Al10Co0p0_T95p0_01/*.batchinfo'));

for ii=1:numel(wildcard_filename)
%     try
        tmpfile = fullfile(wildcard_filename(ii).folder,wildcard_filename(ii).name);
        TwoTimeInfo = [];
        TwoTimeInfo.Num_CPU_Cores=Num_CPU_Cores;
        TwoTimeInfo.Force_CPU=Force_CPU;
        TwoTimeInfo.parent_data_folder=parent_data_folder;
        TwoTimeInfo.result_files_folder=result_files_folder;
        disp(datestr(now));
        TwoTimeInfo.hdf5_filename = tmpfile;
        disp(TwoTimeInfo.hdf5_filename);        
        if (~exist('ccdimginfo','var'))
            disp('ccdimginfo structure is not defined in the workspace, Exiting');
            return;
        end
        %%
        TwoTimeInfo.qphi_bin_to_process = ccdimginfo.partition.dmeanmapindex;
        %         TwoTimeInfo.qphi_bin_to_process = 1;
        %%
        TwoTimeInfo.dark_begin=2; %starting dark frame or leave it empty
        TwoTimeInfo.dark_end=[]; %ending dark frame or leave it empty
        
        TwoTimeInfo.data_begin=[]; %starting data frame or leave it empty
        TwoTimeInfo.data_end=[]; %ending data frame or leave it empty        
        %%
        try
            TwoTimeInfo.stride_frames=ccdimginfo.xpcs.stride_frames;
        catch
            TwoTimeInfo.stride_frames=1; %% 1 means do not skip any frame
        end
        
        try
            TwoTimeInfo.frames_bin_size=ccdimginfo.xpcs.avg_frames;
        catch
            TwoTimeInfo.frames_bin_size=1; %% 1 means do not average frames in time
        end
        %         TwoTimeInfo.frames_bin_size=1; %% 1 means do not average frames in time
        %%
        TwoTimeInfo.Normalize_by_Intensity=1;
        %%
        TwoTimeInfo.Normalize_by_Smoothed_Img=1;
        %%
        TwoTimeInfo.Compute_SG_per_frame=0;
        
        TwoTimeInfo.Smoothing_Method=2; %0-Trans,1-sqmap,2-SG, 3-PixelAvg
        TwoTimeInfo.Subtract_Ref_Speckle = 0; %use this for heterodyne
        %%
        TwoTimeInfo.Num_g2partials = 3;
        %%
        %%Extract pixel in bin vs time array and do some pre-processing
        TwoTimeInfo = TwoTimeg2_batchinfo(TwoTimeInfo,ccdimginfo);
        %%
        %%Do the real twotime calculation including SG smoothing of all the
        %%bins
        TwoTimeInfo=TwoTimeg2Calc(TwoTimeInfo);
        %%
        %%compute 2time to 1time for the full range and 3 partial ranges
        TwoTimeInfo = Compute_TwoTime2OneTime(TwoTimeInfo);
        
        [a,b,~]=fileparts(TwoTimeInfo.hdf5_filename);
        outfile=fullfile(TwoTimeInfo.result_files_folder,[b,'_TwoTime.mat']);
        clear a b;
        if (exist(outfile,'file') == 2)
            [a,b,c]=fileparts(outfile);
            outfile = fullfile(a,[b,datestr(now,'_yyyymmddTHHMMSS'),c]);
        end
        disp(outfile);
        save(outfile,'TwoTimeInfo','ccdimginfo','-v7.3');
        disp(datestr(now));
%     catch
%         fprintf('Loop index %i FAILED\n',ii);
%     end
end

%%
%%to see results
%to see a previously processed data, just load the .mat file
% Visualize_TwoTimeInfo(TwoTimeInfo,[1]);
% plot_2T_g2s(TwoTimeInfo);

% setg2subplot('xlim',[1 20])
% setg2subplot('xscale','log')


