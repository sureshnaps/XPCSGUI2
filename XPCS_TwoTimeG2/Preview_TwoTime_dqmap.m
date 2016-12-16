function TwoTimeInfo = Preview_TwoTime_dqmap(varargin)

TwoTimeInfo = varargin{1};

if (nargin > 1 )
    plot_yes_no=varargin{2};
else
    plot_yes_no = 0;
end

try
    xpcs_entry = TwoTimeInfo.xpcs_entry;
catch
    xpcs_entry = '/xpcs';
end

fprintf('Reading qmap and selecting q-bin pixel indices...\n\n');
try
    dqmap=transpose(h5read(TwoTimeInfo.qmap_filename,'/data/dynamicMap'));
    sqmap=transpose(h5read(TwoTimeInfo.qmap_filename,'/data/staticMap'));
    dqmap(dqmap==-1)=0;
    sqmap(sqmap==-1)=0;
catch
    dqmap=transpose(h5read(TwoTimeInfo.hdf5_filename,[xpcs_entry,'/dqmap']));
    sqmap=transpose(h5read(TwoTimeInfo.hdf5_filename,[xpcs_entry,'/sqmap']));
    dqmap(dqmap==-1)=0;
    sqmap(sqmap==-1)=0;    
end

TwoTimeInfo.dqmap = dqmap;

%%get logical map of all the pixels
dqmap_index_all= (dqmap > 0);

try
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%get logical map of all the pixels in the q-bin (typically 10K-75K pixels)
    % dqmap_index_qbin=(dqmap == qphi_bin_to_process);
    %skipped using logical map as it does not allow multiple bin extraction
    dqmap_index_qbin=zeros(size(dqmap));
    for jj=1:numel(TwoTimeInfo.qphi_bin_to_process)
        dqmap_index_qbin=dqmap_index_qbin+(dqmap == TwoTimeInfo.qphi_bin_to_process(jj)) ...
            *TwoTimeInfo.qphi_bin_to_process(jj);
    end
catch
    dqmap_index_qbin = zeros(size(dqmap));
end

TwoTimeInfo.dqmap_index_qbin = dqmap_index_qbin;

if (plot_yes_no==1)
    try
        %read the summed image from the result file (just for plotting purpose)
        result_location = deblank(h5read(TwoTimeInfo.hdf5_filename,[xpcs_entry,'/output_data']));
        Summed_Image = transpose(h5read(TwoTimeInfo.hdf5_filename,[result_location,'/pixelSum']));
        IntensityVSTime = h5read(TwoTimeInfo.hdf5_filename,[result_location,'/frameSum']);
    catch %just to get going
        Summed_Image = NaN(100,100);
        IntensityVSTime = Nan(1,100);
    end
    
    figure;
    subplot(2,2,1);imagesc(TwoTimeInfo.dqmap);axis image;axis xy;colorbar;title('Full dqmap');
    subplot(2,2,2);imagesc(TwoTimeInfo.dqmap_index_qbin);axis image;axis xy;colorbar;title('Selected q-bins');
    subplot(2,2,3);imagesc(Summed_Image);axis image;axis xy;colorbar;title('Time Averaged Image');
    subplot(2,2,4);plot(IntensityVSTime(:,1),IntensityVSTime(:,2));xlabel('Frame #');ylabel('Intensity');
end

