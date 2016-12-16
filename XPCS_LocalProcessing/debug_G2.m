% matfile('~/debug_G2.mat')
% load ~/debug_G2.mat

%%
delay_point=1;
which_q=2;

G2=viewresultinfo.result.G2{1};
IF=viewresultinfo.result.IF{1};
IP=viewresultinfo.result.IP{1};

G2=reshape(G2,ccdimginfo.detector.rows,ccdimginfo.detector.cols,[]);
IF=reshape(IF,ccdimginfo.detector.rows,ccdimginfo.detector.cols,[]);
IP=reshape(IP,ccdimginfo.detector.rows,ccdimginfo.detector.cols,[]);

%%

usermask=ccdimginfo.mask.usermask;

G2_1=G2(:,:,delay_point).*usermask;
IF_1=IF(:,:,delay_point).*usermask;
IP_1=IP(:,:,delay_point).*usermask;
% figure;imagesc(G2_1);axis xy;axis image;title('G2_{1}');colorbar;
% figure;imagesc(IF_1);axis xy;axis image;title('IF_{1}');colorbar;
% figure;imagesc(IP_1);axis xy;axis image;title('IP_{1}');colorbar;

dqmap=ccdimginfo.partition.dindexmap;
dqmap(dqmap ~= which_q)=0;
dqmap=logical(dqmap);

G2_1=G2_1 .* dqmap;
IF_1=IF_1 .* dqmap;
IP_1=IP_1 .* dqmap;

figure(4);imagesc(G2_1);axis xy;axis image;title('G2_{1}');colorbar;
figure(5);imagesc(IF_1);axis xy;axis image;title('IF_{1}');colorbar;
figure(6);imagesc(IP_1);axis xy;axis image;title('IP_{1}');colorbar;

g2symm_1=G2_1./(IF_1 .* IP_1);
figure(7);imagesc(g2symm_1);axis xy;axis image;title('g2symm_{1}');colorbar;

Istd=mean(img,2).^2;
Istd=reshape(Istd,ccdimginfo.detector.rows,ccdimginfo.detector.cols);
Istd = Istd .* dqmap;
figure(8);imagesc(Istd);axis xy;axis image;title('Istd');colorbar;

%%
%create a water fall plot
img_q = img(dqmap,:);
figure(18);imagesc(img_q);axis xy;title('Waterfall plot');colorbar;
xlabel('frames');ylabel('pixel location');

%%

g2_1_std=G2_1./(Istd);
figure(9);imagesc(g2_1_std);axis xy;axis image;title('g2_{1}std');colorbar;

g2_1_std=G2_1(dqmap)./(Istd(dqmap));
mean(g2_1_std)


%%
for ii=1:floor(ccdimginfo.partition.snpt(1)/ccdimginfo.partition.dnpt(1))
    x(ii)=G2_1./(IF_1 .* IP_1);
end


