function [tag,tag_value,index] = write_MetaData_TwoTime(varargin)
%writeDX Write DataExchange example code.
%        Detailed explanation goes here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% full_hdf5_filename=varargin{1};
TwoTimeInfo=varargin{2};

if (nargin<3)
    xpcs_endpoint = '/xpcs';
elseif (nargin==3) && isempty(varargin{3})
    xpcs_endpoint = '/xpcs';
else
    xpcs_endpoint = varargin{3};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
index=0; %%%Initialize the counter
%      nBatch=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Implements - /implements
%      implements = 'measurement:TwoTime';
%      hdf5write(hdf5_filename', '/implements', implements);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%TwoTime
% /xpcs/SG_smoothed_data
% /xpcs/frameSum (normalized with its mean)
% /xpcs/pixelSum
% /xpcs/qphi_bin_to_process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
index=index+1;
tag{index}=[xpcs_endpoint,'/qphi_bin_to_process'];
tag_value{index} = TwoTimeInfo.qphi_bin_to_process;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
index=index+1;
tag{index}=[xpcs_endpoint,'/SG_smoothed_data'];
tag_value{index} = transpose(double(max(TwoTimeInfo.SG_smoothed_data,1)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
index=index+1;
tag{index}=[xpcs_endpoint,'/pixelSum'];
tag_value{index} = transpose(double(TwoTimeInfo.AvgData));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
index=index+1;
tag{index}=[xpcs_endpoint,'/frameSum'];
if size(TwoTimeInfo.I0t,1)==1
    TwoTimeInfo.I0t = transpose(double(TwoTimeInfo.I0t));
end
tag_value{index} = [(1:numel(TwoTimeInfo.I0t))',TwoTimeInfo.I0t/mean(TwoTimeInfo.I0t)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% % % % file='AA_test_covalent_PEG9k_080C_Fq1_001_0001-3072_TwoTime.hdf';
% % % % [tag,tag_value,index] = write_MetaData_TwoTime(file,TwoTimeInfo);
% % % % 
% % % % %%
% % % % 
% % % % for ii=1:numel(tag)
% % % %     if isnumeric(tag_value{ii})
% % % %         try
% % % %             h5create(file,tag{ii},size(tag_value{ii}),'Datatype',class(tag_value{ii}));
% % % %             h5write(file,tag{ii},tag_value{ii});
% % % %         catch
% % % %             h5write(file,tag{ii},tag_value{ii});
% % % %         end
% % % %     else
% % % %         writeh5str(file,tag{ii},tag_value{ii});
% % % %     end
% % % % end
% % % % 
%move this field to save_MetaData_TwoTime_hdf5 as it is easy to cutomize the
%value of N in /exchange_N
% %      index=index+1;
% %      tag{index}='/TwoTime/output_data';
% %      tag_value{index} = '/exchange';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%ANYTHING NEW GOES HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%WRITE HDF5 FILE CONTAINING THE METADATA
%%%TRY to move saving to hdf5 file to a separate function
%%%saving is done in save_MetaData_TwoTime_hdf5.m
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
