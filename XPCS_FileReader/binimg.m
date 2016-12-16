function img = binimg(img,swbinX,swbinY)
if swbinY ~=1 || swbinX ~=1
    [rows, cols] = size(img);
    % --- remove last rows and cols if not divisible
    img = img(1:end-mod(rows,swbinY),1:end-mod(cols,swbinX));
    [rows,cols] = size(img);        % new rows and cols
    % --- bin
    img = transpose(reshape(mean(reshape(img,swbinY,[]),1),rows/swbinY,[]));
    img = transpose(reshape(mean(reshape(img,swbinX,[]),1),cols/swbinX,[]));
end