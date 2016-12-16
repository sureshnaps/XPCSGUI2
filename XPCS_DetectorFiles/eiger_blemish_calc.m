%this protocol was used to generate eiger flatfield, started with the
%flatfeild in every master.h5 file which was saved in ~/mark/matlab/ folder
%this seems to work well for now
%all this was done in April 2014
b=transpose(h5read('A001_Aerogel_CRL_1/A001_Aerogel_CRL_1_master.h5','/entry/instrument/detector/detectorSpecific/pixel_mask'));

b=(b==0);

load ~/mark/matlab/flatfield.mat  %%has ff flatfield



w=find(ff(:)<.95);
b(w)=0;
w=find(ff(:)>1.05);
b(w)=0;

%asic boundaries
b(:,1:5)=0;
b(:,256:259)=0;
b(:,513:518)=0;
b(:,771:776)=0;
b(:,1026:1030)=0;

b(1:5,:)=0;
b(255:260,:)=0;
b(510:515,:)=0;
b(551:556,:)=0;
b(806:811,:)=0;
b(1061:1065,:)=0;

b(426,817) = 0;

% save eiger_blemish_apr03_1.mat b;
