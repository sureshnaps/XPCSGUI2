function data = read_UFXC_data(varargin)

file = varargin{1};


if (nargin == 2)
    num_frames = varargin{2};
    block_size = num_frames*(256*128);
else
    block_size = Inf;
end

block_size = floor(block_size/(256*128))*(256*128);

% file = '400Frames_U16perPixel';
% --- use multithreaded memmapfile (fast)
tic
% m = memmapfile(file, 'Offset',0, 'Repeat',block_size, 'Writable',false, ...
%     'Format','uint32');
% m = memmapfile(file,
% 'Offset',0,'Repeat',block_size,'Writable',false,'Format','uint16');
% %uint16 for old data taken in July 2015
m = memmapfile(file, 'Offset',0,'Repeat',block_size,'Writable',false,'Format','uint8'); %new data in Oct 2015
% % [~,~,endian] = computer;
% % if strcmpi(endian,'L')
% %     total=swapbytes(m.Data);
% % else
% %     total=m.Data;
% % end;

data = m.Data;

data=reshape(data,128*256,[]);

disp('File reading is done');
toc

end
