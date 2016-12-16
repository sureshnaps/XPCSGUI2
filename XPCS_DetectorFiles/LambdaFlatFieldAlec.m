
% close all
% clear all
% 
% load('data');

%b=getblemish(ccdimginfo);
foo = load('Blemish_Th5p5keVDev0p12.mat');
b=foo.bp;


% looking at fluorescence from tiff seems like module at bottom is bad
% rather than top
b(262:end,1042:1295)=0; b(1:255,1042:1295)=1; % over-ride bad module assignment in blemish file

% pxels from getblemish
%manuall add a few
b(245,1232) = 0;
b(279,1436)=0;
b(280,1437)=0;
b(269,1498)=0;
b(266,1498)=0;
b(267,1499:1500)=0;
b(270:271,1496)=0;
b(272,1497:1499)=0;
b(271,1500)=0;
b(268:270,1501)=0;
b(226,634)=0;
b(237,421)=0;
b(134,710)=0;
b(133,711)=0;
b(103,726)=0;
b(64:68,881:884)=0;
b(428,245)=0;
b(340:344,402:407)=0;
b(321:325,405:409)=0;
b(376,434)=0;
b(487,484)=0;
b(488,485)=0;
b(164:173,1526:1530)=0;
b(469:475,1435:1439)=0;
b(427:431,968:973)=0;
b(147,1184)=0;
b(100:101,984)=0;
b(266,1497)=0;
b(267,1496)=0;

% addl pixels seen in As 5.5 keV threshold data = need to add to blemish
% file (never mind - part of bad module anyway)
b(233,1092)=0;
b(245,1130)=0;
% hot pixels? - NiKa TH 3.75 and As 5.5 - makes bottom module look like a
% problem?
b(389:391,1295)=0;
b(369,1289)=0;
% hot pixels? - AsKa TH 5.5
b(509:510,1116:1117)=0;
% moderately hot pixels - AsKa 5p5
b(262,1132)=0;
b(452,1288)=0;
% moderately cold pixels - AsKa 5p5
b(338,1126)=0;
% large RMS - AsKa 5.5
b(434,1198)=0;
b(267,1496)=0;
b(266,1497)=0;
b(25,1523)=0;
% latex spikes
b(100:101,984)=0;

% hot and cold (mostly hot) pixels identified from long flat field exposures (5 sec exposures)
b(5:23,1265:1295)=0;
b(1:255,1276)=0;
b(1:255,1292)=0;
b(44,1266)=0;
b(43,1288)=0;
b(1:255,1292)=0;
b(96,1288)=0;
b(99,1282)=0;
b(100,1288)=0;
b(125,1294)=0;
b(139,1282)=0;
b(183,1288)=0;
b(197,1282)=0;
b(202,1282)=0;
b(247,1266)=0;
b(251,1280)=0;
b(249,1292)=0;
b(1:255,1042)=0;

b(266:272,1496:1501)=0;
b(435,1377)=0;
b(133,709:710)=0;
b(132,710)=0;
b(187,1009)=0;
b(358:360,1539:1542)=0;
b(277:280,1434:1436)=0;
b(277,1433)=0;
b(280,1437)=0;
b(187,1010)=0;
b(6,1043)=0;
b(1:7,1044:1047)=0;
b(1,1049)=0;
b(2,1050:1051)=0;
b(8,1052)=0;
b(2,1057)=0;
b(2,1054)=0;
b(4,1060)=0;
b(5,1073)=0;
b(2,1075)=0;
b(7,1076)=0;
b(1,1083)=0;
b(1,1090)=0;
b(227,634)=0;
b(191,405)=0;
b(246,4)=0;
b(335,4)=0;
b(368,16)=0;
b(483,255)=0;
b(450,266)=0;
b(488:489,483:484)=0;
b(481,787:788)=0;
b(377:381,914:917)=0;
b(206,1282)=0;
b(182,1282)=0;
b(173,1288)=0;
b(140,1266)=0;
b(102:104,724:726)=0;
b(311,28)=0;
b(315,29)=0;
b(167,522)=0;
b(199:200,522)=0;
b(340,522)=0;
b(490,783)=0;
b(3,1032)=0;
b(1,1057:1058)=0;
b(15,498)=0;
b(171,608)=0;
b(3,1043)=0;
b(96,510)=0;
b(489,783)=0;
b(487,168)=0;
b(140,312)=0;
b(3,1101)=0;
b(408,1398)=0;
b(342,275)=0;
b(191,907)=0;
% high rms
b(123,1266)=0;
b(171,1266)=0;
b(245,1272)=0;
b(138,1282)=0;
b(120,1288)=0;
b(144,1288)=0;
b(76,1270)=0;
b(72,1282)=0;

findingBlemishYN=0;
writingBlemishYN=1;
plotZoomYN = 1; % plot each module separately - easier to identify problems

froot='/home/8-id-i/2016-2/Flatfield201606/AsKa_test_5sec_Th5p5_01_';
%froot='/home/8-id-i/2016-2/Flatfield201606/AsKa_test_5sec_Th9p00_01_';
%froot='/home/8-id-i/2016-2/Flatfield201606/NiKa_test_5sec_Th3p75_01_';

rows=516;
cols=1556;

ndata0=1;
ndataend = 100;
nframes = ndataend-ndata0+1;

% plot to show layout of modules and region between modules
figure; %1
imagesc(b, [0 1]);
colormap('gray');
axis image; axis xy; colorbar
title('LAMBDA MODULES ID AND BLEMISH')
ylabel('ROW (pix)')
xlabel('COL (pix)')
for k=1:6
    %text(128+(k-1)*258, 384, sprintf('%d',k), 'FontSize', 18, 'FontWeight', 'Bold')
    %text(128+(k-1)*258, 128, sprintf('%d',k+6), 'FontSize', 18, 'FontWeight', 'Bold')
end

nz=b~=0;

% loop over data frames to generate flat field
str = 'Collecting data frames for flat field ... ';
fprintf('%s\n',str);
for l = ndata0:ndata0+nframes-1
    FNAME=sprintf('%s%04d.tiff', froot, l);
    %f=flatdata(:,:,l);
    img=imread(FNAME);
    img=cast(img, 'double');
    img=img .* b;
    if l == ndata0
        img0=img;
        imgSum = 0;
        i_avg_frame=zeros(1,nframes, 'double');
        i_rms_frame=zeros(1,nframes, 'double');
        A1 = zeros(size(img0));
        A2 = zeros(size(img0));
        m=1;
    end
    
    imgSum = imgSum + sum(img(nz));
    A1 = A1 + (img - img0);
    A2 = A2 + (img - img0).^2;
    i_avg_frame(m)=mean(img(nz));
    i_rms_frame(m)=std(img(nz));
    m = m+1;
end
str = 'Finished collecting data frames for flat field ... ';
fprintf('%s\n',str);

i_avg = mean(i_avg_frame);
i_rms = mean(i_rms_frame);

IMG=(A1/double(nframes))+img0;
IMG_var=(A2-(A1.^2/double(nframes)))/double(nframes-1);
IMG_rms=sqrt(IMG_var);

minImg = min(IMG(IMG>0));
maxImg = max(IMG(:));
minImgR = min(IMG_rms(IMG_rms>0));
maxImgR = max(IMG_rms(:));
figure;imagesc(IMG, [minImg maxImg]);axis image; axis xy;colorbar;title('IMG');
figure;imagesc(IMG_rms, [minImgR maxImgR]); axis image; axis xy;colorbar;title('IMG_rms', 'interpreter', 'none')
%%

% % determine distribution of intensity values and sigma so can play with
% % thresholds for determining outliers
% edgesHi = i_avg + i_avg/20/2:i_avg/20:max(IMG(nz));
% edgesLo = i_avg - i_avg/20/2:-i_avg/20:0;
% edgesLo = fliplr(edgesLo);
% if edgesLo == 0
%     edgesLo = edgesLo(2:end);
% end
% edges=[edgesLo edgesHi];
% [N, edges] = histcounts(IMG(nz), edges);
% cens = edges(1:end-1) + diff(edges)/2;
% % restrict fit to vicinity of histogram peak
% idx=find(cens>i_avg+4*sqrt(i_avg), 1);
% if length(idx) > 4
%     xdat = cens(1:idx-1);
%     ydat = N(1:idx-1);
% else
%     xdat = cens;
%     ydat = N;
% end
% xdat = double(xdat');
% ydat = double(ydat');
% 
% % make a guess for width
% ymax = max(ydat);
% fooIdx=find(ydat==ymax);
% foo=ydat(1:fooIdx);
% yhalf = find(foo < ymax/2, 1, 'last'); % index of half amplitude point
% xwid = (xdat(ydat==ymax)-xdat(yhalf))/(2.35/2);
% fo = fitoptions('gauss1', 'Lower', [0 0 0], ...
%     'StartPoint', [max(ydat) xdat(ydat==ymax) xwid]);
% fit1 = fit(xdat, ydat, 'gauss1', fo);
% fitcoeff = coeffvalues(fit1);
% figure;
% plot(fit1,cens,N, 'bo-')
% hold on
% xlabel('PHOTONS/PIXEL/FRAME')
% ylabel('EVENTS')
% xlim([0 fitcoeff(2)+4*fitcoeff(3)])
% strText = sprintf('Mean = %.3f ph/pixel/frame', fitcoeff(2));
% text(0.05, 0.95*fitcoeff(1), strText);
% strText = sprintf('Sigma = %.3f ph/pixel/frame', fitcoeff(3));
% text(0.05, 0.9*fitcoeff(1), strText);
% 
% figure;
% subplot(2,1,1)
% imagesc(IMG, [fitcoeff(2)-ndev*fitcoeff(3) fitcoeff(2)+ndev*fitcoeff(3)])
% colormap(flipud(colormap('gray')))
% axis image; axis xy; colorbar
% xlabel('COLUMN (pix)')
% ylabel('ROW (pix)')
% strText = sprintf('IMG w/ scale=Mean+/-%d*sigma', ndev);
% title(strText, 'interpreter', 'none')
% %
% subplot(2,1,2)
% imgMin = max([mean(IMG_rms(nz)) - 2*std(IMG_rms(nz)) 0]);
% imgMax = mean(IMG_rms(nz)) + 2*std(IMG_rms(nz));
% imagesc(IMG_rms, [imgMin imgMax])
% colormap(flipud(colormap('gray')))
% axis image; axis xy; colorbar
% xlabel('COLUMN (pix)')
% ylabel('ROW (pix)')
% title('IMG_rms', 'interpreter', 'none')

%%

% %
% % assess potential problems
% % key: 0=OK, 1=module gap, 2=zeros in image, 3=anomolous low val,
% % 4=anomolous hi val
% problemsID = zeros(size(IMG));
% problemsID(b==0)=1; % module gap
% problemsID(b==1 & IMG==0) = 2; % zeros in image aside from module gap
% allowedDev = ndev*fitcoeff(3); % num of standard deviations from mean for a problem to be ID'ed
% problemsID(b==1 & IMG > 0 & IMG < fitcoeff(2)-allowedDev) = 3; % vals below ndev sig of mean
% problemsID(b==1 & IMG > 0 & IMG > fitcoeff(2)+allowedDev) = 4; % vals above ndev sig of mean
% 
% % plot assessment of problem areas
% figure;
% imagesc(problemsID)
% map=[1 1 1; 0 0 0; 0 0 1; 0 1 0; 1 0 0]; % white (OK), black (inter-module), blue (0's), green (low), red (high, hot)
% colormap(map)
% axis image; axis xy;
% %colorbar
% colorbar('Ticks',[0,1,2,3,4],...
%          'TickLabels',{'OK','Inter-mod','No resp. (0)','< Avg-n*Sig','> Avg+n*Sig'})
% xlabel('COLUMN (pix)')
% ylabel('ROW (pix)')
% title('problemsID', 'interpreter', 'none')
% caxis([-0.5 4.5]);
% 
% % bar graphs of counts of the types of problems (2, 3, or 4) that were
% % id'ed
% probCts = zeros(12,3);
% l = 1;
% for k=259:-258:1
%     for m=[1 259 519 779 1039 1299]
%         if l == 1 || l==6 || l==7 || l==12
%             foo=problemsID(k:k+258-1,m:m+258-1);
%         else
%             foo=problemsID(k:k+258-1,m:m+260-1);
%         end
%         for n=[2 3 4] % 'error' codes to search for
%             probCts(l, n-1) = probCts(l, n-1) + sum(foo(:)==n);
%         end
%         l=l+1;
%     end
% end
% figure;
% bar(probCts)
% xlabel('MODULE #')
% ylabel('OCCURRENCES')
% legend('No response','Low response','Hi response', 'Location', 'Northwest')
% 
% % bar graphs of counts of the types of problems (2, 3, or 4) that were
% % id'ed but normalized by number of nominally active pixels in each module
% % (256*256 = 65536)
% probCts = zeros(12,3);
% l = 1;
% for k=259:-258:1
%     for m=[1 259 519 779 1039 1299]
%         if l == 1 || l==6 || l==7 || l==12
%             foo=problemsID(k:k+258-1,m:m+258-1);
%         else
%             foo=problemsID(k:k+258-1,m:m+260-1);
%         end
%         for n=[2 3 4] % 'error' codes to search for
%             probCts(l, n-1) = probCts(l, n-1) + sum(foo(:)==n);
%         end
%         l=l+1;
%     end
% end
% figure;
% probCtsNorm =100*probCts/(256^2);
% bar(probCtsNorm)
% xlabel('MODULE #')
% ylabel('DEFECT DENSITY (%)')
% legend('No response','Low response','Hi response', 'Location', 'Northwest')
% ylim([0 0.2])
% 
% % sort the 0's descending qty by module number
% zeroResp = probCts(:,1);
% modIndex = 1:12;
% modIndex = modIndex';
% [zeroRespDesc, I] = sort(zeroResp, 'descend');
% modOrderDesc = modIndex(I);
% 
% if writingBlemishYN == 1
%     % create a blemish file to itemize problems
%     fileID = fopen(blemFile, 'w');
%     % 
% %     fprintf(fileID, '%% pixels between modules\n');
% %     [I,J]=find(problemsID == 1);
% %     foo = [I'; J'];
% %     fprintf(fileID, 'b[%d, %d] = 0;\n', foo);
%     % header info
%     fprintf(fileID, '%% blemish info obtained by processing %s\n', name);
%     fprintf(fileID, '%% mean=%.3f ph/pix/frame, sigma=%.3f ph/pix/frame\n', ...
%         fitcoeff(2), fitcoeff(3));
%     %
%     fprintf(fileID, '%% pixels exhibiting no response (0)\n');
%     [I,J]=find(problemsID == 2);
%     foo = [I'; J'];
%     fprintf(fileID, 'b[%d, %d] = 0;\n', foo);
%     %
%     fprintf(fileID, '%% pixels exhibiting low response (response<mean-%d*sigma))\n',ndev);
%     [I,J]=find(problemsID == 3);
%     foo = [I'; J'];
%     fprintf(fileID, 'b[%d, %d] = 0;\n', foo);
%     %
%     fprintf(fileID, '%% pixels exhibiting high response (response>mean+%d*sigma))\n',ndev);
%     [I,J]=find(problemsID == 4);
%     foo = [I'; J'];
%     fprintf(fileID, 'b[%d, %d] = 0;\n', foo);
%     %
%     fclose(fileID);
% end
% 
% % plot a zoom of each module
% if plotZoomYN == 1
%     l=1;
%     for k=259:-258:1
%         for m=[1 259 519 779 1039 1299]
%             figure;
%             if l == 1 || l==6 || l==7 || l==12
%                 imagesc(problemsID(k:k+258-1,m:m+258-1), ...
%                     'XData', [m m+258-1], ...
%                     'YData', [k k+258-1])
%             else
%                 imagesc(problemsID(k:k+258-1,m:m+260-1), ...
%                     'XData', [m m+260-1], ...
%                     'YData', [k k+258-1])
%             end
%             colormap(map)
%             axis image; axis xy;
%             %colorbar
%             colorbar('Ticks',[0,1,2,3,4],...
%                 'TickLabels',{'OK','Inter-module','No response (0)','< Mean-n*Sigma','> Mean+n*Sigma'})
%             xlabel('COLUMN (pix)')
%             ylabel('ROW (pix)')
%             strText=sprintf('Module #%d zoom in - problemsID()', l);
%             title(strText, 'interpreter', 'none')
%             caxis([-0.5 4.5]);
%             l = l + 1;
%         end
%     end
% end
% 
% % end of finding blemishes

% second half - see how well can flatten with updated blemish list
iAvg=mean(IMG(b==1));
foo=iAvg*ones(size(IMG));
flatField = foo./IMG;

flatField(flatField==Inf)=1; % 1's for blemishes, modules etc.
flatFieldZero=flatField .* b; % 0s at blemishes etc.


figure;
subplot(2,1,1)
imagesc(flatField, [.97 1.03])
%colormap(flipud(colormap('gray')))
colorbar
axis image; axis xy;
xlabel('COLUMN (pix)')
ylabel('ROW (pix)')
title('flatField', 'interpreter', 'none')

subplot(2,1,2)
imagesc(flatFieldZero, [.97 1.03])
%colormap(flipud(colormap('gray')))
colorbar
axis image; axis xy;
xlabel('COLUMN (pix)')
ylabel('ROW (pix)')
title('flatFieldZero', 'interpreter', 'none')