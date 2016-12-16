function TwoTimeInfo = TwoTimeg2Calc(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TwoTimeInfo=varargin{1};

qphi_bin_to_process = TwoTimeInfo.qphi_bin_to_process;
dqmap_index_qbin = TwoTimeInfo.dqmap_index_qbin;
data_bin_size = TwoTimeInfo.frames_bin_size;
Normalize_by_Intensity = TwoTimeInfo.Normalize_by_Intensity;
Normalize_by_Smoothed_Img = TwoTimeInfo.Normalize_by_Smoothed_Img;
Smoothing_Method = TwoTimeInfo.Smoothing_Method;
Subtract_Ref_Speckle = TwoTimeInfo.Subtract_Ref_Speckle;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (TwoTimeInfo.Compute_SG_per_frame == 0)
    %%calculate Savitzky-Golay Smoothed data of the summed image
    fprintf('Calculating a Smoothed Speckle Pattern for Normalization..\n');
    
    if (Smoothing_Method == 0) %%use circavg, transmission geometry
        fprintf('Using Circular average and interpolation for Smoothing..\n');
        SG_smoothed_data = circavg_SG(TwoTimeInfo.hdf5_filename,TwoTimeInfo.AvgData);
        
    elseif (Smoothing_Method == 1) %%use bin avg, reflection geometry
        fprintf('Using static qmap bin average and interpolation for Smoothing..\n');
        SG_smoothed_data = qparallel_avg_SG(TwoTimeInfo.hdf5_filename,TwoTimeInfo.AvgData);
        
    elseif (Smoothing_Method == 2) %%use Savitzky-Golay, wide angle case
        fprintf('Using Savitzky-Golay method for Smoothing..\n');
        SG_smoothed_data=SGsmooth(TwoTimeInfo.AvgData,[21,21],'conv2');

    elseif (Smoothing_Method == 3) %%use average of the pixels in the q-bin per frame to normalize 
        fprintf('Using Average of the pixels in the q-bin per frame for Smoothing..\n');
        SG_smoothed_data=cellfun(@(x)mean(x,1),TwoTimeInfo.Iqt,'UniformOutput',false);
        SG_smoothed_data = cell2mat(SG_smoothed_data(:));        
    else
        disp('No appropriate Speckle Smoothing Method provided');
        return;
    end
    
    TwoTimeInfo.SG_smoothed_data = SG_smoothed_data;
    clear SG_smoothed_data;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
full_twotime_calc_start=tic;
for kk=1:numel(TwoTimeInfo.Iqt)
    
    Iqt_temp=TwoTimeInfo.Iqt{kk};
    %run through the multiple q-bins
    if ~islogical(dqmap_index_qbin)
        temp_dqmap_index_qbin=(dqmap_index_qbin == qphi_bin_to_process(kk));
    else
        %nothing to do
    end
    
    %%Normalize by Smoothed data from the sum of all frames for all modes
    %%other than the pixel avg per frame smoothing mode
    if ( (Normalize_by_Smoothed_Img == 1) && (Smoothing_Method ~= 3) )
        if (ismatrix(TwoTimeInfo.SG_smoothed_data))
            SG_Pixel_Array = max(1,TwoTimeInfo.SG_smoothed_data(temp_dqmap_index_qbin));
        elseif (ndims(TwoTimeInfo.SG_smoothed_data)==3)
            b=squeeze(num2cell(TwoTimeInfo.SG_smoothed_data,[1 2]));
            c=cellfun(@(x)x(temp_dqmap_index_qbin),b,'UniformOutput',0);
            SG_Pixel_Array=max(1,reshape(cell2mat(c),[],size(TwoTimeInfo.SG_smoothed_data,3)));            
            %one line way of above
            %%SG_Pixel_Array = max(cell2mat(arrayfun(@(x) feval(@(y,z)y(z),TwoTimeInfo.SG_smoothed_data(:,:,x),temp_dqmap_index_qbin),1:size(TwoTimeInfo.SG_smoothed_data,3),'UniformOutput',0)),1);
        end
        Iqt_temp=bsxfun(@rdivide,Iqt_temp,SG_Pixel_Array);
        
    elseif ( (Normalize_by_Smoothed_Img == 1) && (Smoothing_Method == 3) )
        %use average of the pixels in the q-bin per frame to normalize   
        SG_Time_Array = TwoTimeInfo.SG_smoothed_data(kk,:);
        Iqt_temp = bsxfun(@rdivide,Iqt_temp,SG_Time_Array);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (data_bin_size > 1) %%average specified frames by reshaping
        Iqt_temp = Iqt_bin_data(Iqt_temp,data_bin_size);
        I0t = Iqt_bin_data(TwoTimeInfo.I0t,data_bin_size);
    else
        I0t = TwoTimeInfo.I0t;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (Subtract_Ref_Speckle == 1) %removes residual speckle contrast from static
        Iqt_temp = bsxfun(@minus,Iqt_temp,mean(Iqt_temp,2));
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%Normalize each pixel intnsity Iqt by (I0t/I0) to account for variations
    %%in the scattered intensity over time. I0 is to preserve the scale of each
    %%image around a norm of unity
    if (Normalize_by_Intensity == 1)
        Iqt_temp=bsxfun(@rdivide,Iqt_temp,(I0t/mean(I0t)));
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %     if (Subtract_Ref_Speckle ~= 1)
% %         %%Get the fluctuations about zero
% %         Iqt_temp = Iqt_temp;% -1;
% %     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%Start Computing 2-Time g2
    fprintf('Start 2-time calculation: Bin# %i of a total of %i\n',kk,numel(TwoTimeInfo.Iqt));
    tic;
    TwoTimeInfo.C{kk} = twotimeLargeArrayCPUorGPU(Iqt_temp,TwoTimeInfo.Force_CPU); %%splits large arrays and computes two time g2
    time_for_twotime = toc;
    fprintf('Done 2-time calculation: Bin# %i of a total of %i took %i Seconds\n',kk,numel(TwoTimeInfo.Iqt),time_for_twotime);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
time_for_full_twotime_calc=toc(full_twotime_calc_start);
fprintf('Complete 2-time calculation of a total of %i Bin(s) took %i Seconds\n',numel(TwoTimeInfo.Iqt),round(time_for_full_twotime_calc));

end
