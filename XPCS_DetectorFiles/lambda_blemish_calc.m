%this protocol was used to generate lambda flatfield,
% collected flatfield at 90 deg with As Ka which is at 10.5 keV and close
% to 11 keV operating energy. Thresholds were set from 3-9 keV or so and it
% seemed like close to 1/2 the energy was the right value with a spread of
% +/- 0.5 keV. These are all saved in /home/8-id-i/2016-2/Flatfield201606/
% as tiff files. Qingteng and Alec used thorough analysis to discard pixels
% carefully. This was done in June 2016, note that the chip is not final
% and is a more defective chip, to be replaced in Sep 2016.

%flatfield file at 10.5 keV is saved as a matrix in
%/local/XPCSGUI2/XPCS_DetectorFiles/lambda_flatfield_AsKa.mat'

%%has the field: flatfieldflatField_Multi: [516x1556 single]
load /local/XPCSGUI2/XPCS_DetectorFiles/lambda_flatfield_AsKa.mat
flatField_Multi = flipud(flatField_Multi);

b=ones(size(flatField_Multi));

w=find(flatField_Multi(:)<0.90);
b(w)=0;
w=find(flatField_Multi(:)>1.1);
b(w)=0;

%basic boundaries between modules (6 x 2 array)
b(256:261,:)=0; %horizontal along the long sie

%vertical, along the short side
b(:,256:261)=0;
b(:,516:521)=0;
b(:,776:781)=0;
b(:,1036:1041)=0;
b(:,1296:1301)=0;

%get rid of one bad module in the temporary chip
b(1:256,1042:1295)=0;

%seems like has to be flipped, to be investigated
b=flipud(b);

%some that are found during data analysis
b(245,1232) = 0;
b(279,1436)=0;

% save /local/XPCSGUI2/XPCS_DetectorFiles/lambda_blemish_June2016_1.mat b;
