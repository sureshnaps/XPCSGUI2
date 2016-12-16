%%
file='A007_GLC_7p35keV_20H20V_USID_Sq1_001_0001-0074_TwoTime.hdf5';

TwoTimeInfo= Preview_and_Download_TwoTime_hdf5(file);
TwoTimeInfo= Preview_and_Download_TwoTime_hdf5(file,TwoTimeInfo.good_qphi_bins);

TwoTimeInfo.hdf5_filename = file;
Visualize_TwoTimeInfo(TwoTimeInfo,[9]);
%%
file1='A007_GLC_7p35keV_20H20V_USID_Sq1_001_0001-0074.hdf';

TwoTimeInfoH= Preview_and_Download_TwoTime_hdf(file1,[1:18],'/xpcs_16');
TwoTimeInfoH= Preview_and_Download_TwoTime_hdf(file1,TwoTimeInfoH.good_qphi_bins,'/xpcs_16');

TwoTimeInfoH.hdf5_filename = file1;

Visualize_TwoTimeInfo(TwoTimeInfoH,[9]);