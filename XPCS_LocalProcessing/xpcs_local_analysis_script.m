%%

% clear all
close all


% for n=2:2
    
    tic;
    %%
    %file='A003_DirectBeam'; %ccdx and ccdz were at -160.65 and -99.0
    % file='A003_DirectBeam'; %ccdz was moved by +3 mm
    % file='A004_DirectBeam'; %ccdx was also moved by 3 mm, ccdz was moved by +3 mm
    %%
    %file='Trial_sync';
    num_frames = Inf; %use Inf (without quotes) to read the entire frames
    
%     file=sprintf('A004_Latex34_025C_Xm169_Zm99_60umV_100K_%03i',n);
    
    %%
%     ccdx= -169.0; %user can change this setting
%     ccdz= -99.0; %user can change this setting
    
%     ccdz= -89.0; %user can change this setting
    
    %
    img = read_UFXC_data(file,num_frames);
    
    tic;
    img=sparse(double(img));
    disp('converting to sparse took..');
    toc;
    whos img
    %%
    ccdimginfo=[];
    global ccdimginfo
    warning('off','MATLAB:Figure:Pointer');
    %%
    create_ccdimginfo_UFXC;
    %%
    % [~,ccdimginfo]=Compute_IMM_SumImages(ccdimginfo);
    ccdimginfo.xpcs.testimg = mean(img,2);
    ccdimginfo.xpcs.testimg = reshape(ccdimginfo.xpcs.testimg,[ccdimginfo.detector.rows,...
        ccdimginfo.detector.cols]);
    % figure;imagesc(ccdimginfo.xpcs.testimg);axis image;axis xy;colorbar;
    
    %%
    ccdimginfo = getimgmap(ccdimginfo); %maps structure with no display
    %% mask
    % getimgmask(ccdimginfo.xpcs.testimg,ccdimginfo);
    
    oldmask = load('lurio_UFXC_mask_2.mat');
    usermask=oldmask.usermask;
    %%
    %user blemish 2015 October
    %take 1 pixel border out
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%this block is saved in lurio_UFXC_mask_1.mat
%     usermask(1,:)=0;
%     usermask(end,:)=0;
%     usermask(:,1)=0;
%     usermask(:,end)=0;
%     
%     usermask(9,151)=0;
%     usermask(50,174)=0;
%     usermask(62,80)=0;
%     usermask(67,143)=0;
%     usermask(79,63)=0;
%     usermask(89,146)=0;
%     usermask(104,59)=0;
%     usermask(105,42)=0;
%     usermask(111,107)=0;
%     usermask(127,255)=0;
%     usermask(128,128)=0;
%     usermask(89,146)=0;
%     usermask(19,237)=0;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%
    ccdimginfo.mask.usermask = usermask;
    clear oldmask;
    %%
    img=bsxfun(@times,img,double(usermask(:)));
    %%
    % calculate the q-partitions based on the below parameters
    ccdimginfo.partition.name = {'q','phi'};
    ccdimginfo.partition.snpt = [9, 1];
    ccdimginfo.partition.dnpt = [1, 1];
    ccdimginfo.partition.smethod = [1, 1]; %1-linear,2-log
    ccdimginfo.partition.dmethod = [1, 1]; %1-linear,2-log
    %%%%%%%%%%%%%%
    ccdimginfo.analysistype=1; %dynamics
    ccdimginfo = getimgpartition(ccdimginfo); %partition structure
    ccdimginfo = getimgpartitionindex(ccdimginfo); %integer partition map
%      showmaskpartition
%     return
    %%
    ccdimginfo.xpcs.static_mean_window_size = floor(size(img,2)/10);
    ccdimginfo.xpcs.data_begin_todo = 1;
    ccdimginfo.xpcs.data_end_todo = size(img,2);
    ccdimginfo.xpcs.timeStamps = [1:size(img,2)];
    %%
    disp('Computing Static results');
    viewresultinfo = Process_img_StaticCalc(img,ccdimginfo);
    %%
    disp('Start computing G2,IP,IF');
    tic;
    dpl=1; %default changed from 4 to 1 as per Larry for Alpha samples
    framespacing = 1/11840;
    Use_GPU=0;
    
    if (Use_GPU)
        disp('Using GPU for correlation');
    end
    
    [viewresultinfo.result.delay{1},viewresultinfo.result.G2{1},viewresultinfo.result.IP{1},...
        viewresultinfo.result.IF{1}]=rawg2_1D(img,dpl,framespacing,Use_GPU);
    if (size(viewresultinfo.result.delay{1},1)==1)
        viewresultinfo.result.delay{1}=transpose(viewresultinfo.result.delay{1});
    end
    disp('Done computing G2,IP,IF');
    toc;
    %%
    disp('Start Normalizing g2');
    % tic;
    [viewresultinfo.result.g2avg{1},viewresultinfo.result.g2avgErr{1}] = function_g2_normalize(viewresultinfo.result.G2{1},...
        viewresultinfo.result.IP{1},viewresultinfo.result.IF{1},ccdimginfo);
    
    viewresultinfo.result.dynamicQs{1}=ccdimginfo.partition.dmeanmap(:,1);
    viewresultinfo.result.dynamicPHIs{1}=ccdimginfo.partition.dmeanmap(:,2);
    disp('Done Normalizing g2');
    % toc;
    %%
    viewresultinfo.result = fit_hadoop_g2s(viewresultinfo.result);
    disp('Done Fitting g2');
    %%
    % disp('Bringing up VIEWRESULT Window');
    % viewresult(viewresultinfo);
    
    %%
    [~,foo,~]=fileparts(file);
    foo=strcat(foo,'.mat');
    disp(foo);
    save(foo,'ccdimginfo','viewresultinfo','-v7.3');
    viewresult(foo);
    %%
    toc;
    
% end
