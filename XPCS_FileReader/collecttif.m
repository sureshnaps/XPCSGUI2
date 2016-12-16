function [imgs,headers] = collecttif(immfilename,first_image,last_image)
% --- COLLECTTIF Accumulate a bunch of images into a 3-D image array
% ---
% --- USAGE : [imgs] = COLLECTTIF(FILENAME,FIRST_IMAGE_NUM,LAST_IMAGE_NUM)
% ---
% --- Input Argument:
% --- FILENAME       : image file name
% --- FIRST_IMAGE_NUM          : Starting image number in the file sequence
% --- LAST_IMAGE_NUM           : Ending image number in the file sequence
%
% --- Output Argument:
% --- imgs : 3-D arrray with the first two dimensions same as the
% dimensions of the image itself. The 3rd dimension corresponds to the
% image in the sequence.
%--- headers : Cell array with as many cell headers as the number of images

%Allocate memory
f=openfile(immfilename,first_image);
img=f.imm;
foo=whos('img');
imgs = zeros(foo.size(1),foo.size(2),(last_image - first_image +1),foo.class);
clear img foo;

ini_time = clock;
img_index=0;
str = 'Collecting Image Number: ';
fprintf('%s',str);
str3 = '1';
for ival = first_image:last_image
   f=openfile(immfilename,ival);
   img_index = img_index+1;
   str2 = num2str(img_index);
   fprintf([repmat('\b',1,length(str3)), '%s'],str2 );
   str3 = str2;

   imgs(:,:,img_index)=f.imm;
   headers{img_index}=f.header;
end
final_time = clock;
fprintf('\n');
foo=sprintf('Time to Collect Images = %f Seconds\n',etime(final_time,ini_time));
disp(foo);clear foo;
