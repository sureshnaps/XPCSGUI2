
for n=2:71
    fprintf('Working on file number %i\n',n);
   file=sprintf('A070_Alpha_RIT_M09_025C_Xm206_Zm99_60umV_100K_%03i',n);
       %file = sprintf('A058_Latex34p_005C_Xm169_Zm99_60umV_100K_%03i',n);

% %     file = sprintf('A036_Latex34p_Lens_Xm169_Zm99_%03i',n);
    
    %check if file is even there
    disp('waiting for file to be ready');
    while (exist(file,'file') ~= 2)
        pause(1.0);
    end
    disp('file is partially ready');
    %%%%    
    a=dir(file);
    fprintf('waiting for %s to be ready of the full size\n',file);
    while (a.bytes < 3276767232)
        pause(1.0);
        a=dir(file);
    end
    %%%%

    
    ccdx= -206; %user can change this setting
    ccdz= -99.0; %user can change this setting
    tic;
    xpcs_local_analysis_script;
    disp('Total computation took...');
    toc;
end