% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear TwoTimeInfo
Num_CPU_Cores=4;
Force_CPU=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parent_data_folder='/net/wolf/data/xpcs8/2016-2/ludwig201608/';
hdf5_files_folder='/net/wolf/data/xpcs8/2016-2/ludwig201608/cluster_results/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
tmpfile = dir('A016_Sapphire_oxford0_0p32deg_sam4_Sq12_0001-3188_Sq1.hdf')
for ii=1:1%numel(tmpfile)
    try
        TwoTimeInfo = [];
        TwoTimeInfo.Num_CPU_Cores=Num_CPU_Cores;
        TwoTimeInfo.Force_CPU=Force_CPU;
        TwoTimeInfo.parent_data_folder=parent_data_folder;
        TwoTimeInfo.hdf5_files_folder=hdf5_files_folder;
        
        datestr(now)
        TwoTimeInfo.hdf5_filename = tmpfile(ii).name;
        disp(TwoTimeInfo.hdf5_filename)
        TwoTimeInfo.hdf5_filename = fullfile(TwoTimeInfo.hdf5_files_folder,TwoTimeInfo.hdf5_filename);
        disp(TwoTimeInfo.hdf5_filename)
        %if qmap is specified, code will use that. Leave this as empty string
%         TwoTimeInfo.qmap_filename = '/net/s8iddata/export/8-id-i/partitionMapLibrary/2016-2/jonghun_qmap_201608_silica_Fq0p0019_delq2em4_110phis3deg.h5';
        TwoTimeInfo.qmap_filename = '';
        
        %/xpcs is the default for analysis, which is the last analysis performed
        TwoTimeInfo.xpcs_entry = '/xpcs';
        
        %show the selected dqmap bins
        TwoTimeInfo = Preview_TwoTime_dqmap(TwoTimeInfo,0); %2nd arg as 1 will display
        %%
        if isempty(TwoTimeInfo.qmap_filename)
            qlist=nonzeros(unique(h5read(TwoTimeInfo.hdf5_filename,[TwoTimeInfo.xpcs_entry,'/dqmap'])));
            qlist(qlist==-1)=0;
            TwoTimeInfo.dqval = h5read(TwoTimeInfo.hdf5_filename,[[TwoTimeInfo.xpcs_entry,'/dqlist']]);
        else
            qlist=nonzeros(unique(h5read(TwoTimeInfo.qmap_filename,'/data/dynamicMap')));
            qlist(qlist==-1)=0;
            TwoTimeInfo.dqval = qlist;
        end
        TwoTimeInfo.qphi_bin_to_process=double(qlist);
        %use above OR use below
%         TwoTimeInfo.qphi_bin_to_process=[1:55];
        %%
        TwoTimeInfo.dark_begin=[]; %starting dark frame or leave it empty
        TwoTimeInfo.dark_end=[]; %ending dark frame or leave it empty
        
        TwoTimeInfo.data_begin=[]; %starting data frame or leave it empty
        TwoTimeInfo.data_end=[]; %ending data frame or leave it empty        
        %%
        try
            TwoTimeInfo.stride_frames=double(h5read(TwoTimeInfo.hdf5_filename,[TwoTimeInfo.xpcs_entry,'/stride_frames']));
        catch
            TwoTimeInfo.stride_frames=1; %% 1 means do not skip any frame
        end
        
        try
            TwoTimeInfo.frames_bin_size=double(h5read(TwoTimeInfo.hdf5_filename,[TwoTimeInfo.xpcs_entry,'/avg_frames']));
        catch
            TwoTimeInfo.frames_bin_size=1; %% 1 means do not average frames in time
        end
        TwoTimeInfo.frames_bin_size=1; %% 1 means do not average frames in time
        %%
        TwoTimeInfo.Normalize_by_Intensity=1;
        %%
        TwoTimeInfo.Normalize_by_Smoothed_Img=1;
        %%
        TwoTimeInfo.Compute_SG_per_frame=0;
        
        TwoTimeInfo.Smoothing_Method=3; %0-Trans,1-sqmap,2-SG, 3-PixelAvg
        TwoTimeInfo.Subtract_Ref_Speckle = 0; %use this for heterodyne
        %%
        TwoTimeInfo.Num_g2partials = 10;
        %%
        %use this line to check memory usage prior to calculations
        TwoTime_Memory_Requirements(TwoTimeInfo);
        
        %%
        %%Extract pixel in bin vs time array and do some pre-processing
        TwoTimeInfo = TwoTimeg2(TwoTimeInfo);
        %%
        %%Do the real twotime calculation including SG smoothing of all the
        %%bins
        TwoTimeInfo=TwoTimeg2Calc(TwoTimeInfo);
        %%
        %%compute 2time to 1time for the full range and 3 partial ranges
        TwoTimeInfo = Compute_TwoTime2OneTime(TwoTimeInfo);
        
        [a,b,~]=fileparts(TwoTimeInfo.hdf5_filename);
        outfile=fullfile(a,[b,'_TwoTime.hdf5']);
        clear a b;
        disp(outfile);
        compress=1;
        save_TwoTime_hdf5(outfile,'/TwoTimeInfo',TwoTimeInfo,compress);
        disp(datestr(now));
    catch
        fprintf('Loop index %i FAILED\n',ii);
    end
end

%%
%%to see results
% TwoTimeInfo = Preview_and_Download_TwoTime_hdf5('D0103_Lapo3p25v3_quiescent_Sq0_001_0001-0522_TwoTime.hdf5',[1:18]);
%TwoTimeInfo = Preview_and_Download_TwoTime_hdf5('A006_SiO2_phi45_0p24deg_sam2_Sq123_0001-4198_TwoTime.hdf5',[1:10]);
% Visualize_TwoTimeInfo(TwoTimeInfo,[1:3]);
% plot_2T_g2s(TwoTimeInfo);

% setg2subplot('xlim',[1 20])
% setg2subplot('xscale','log')


