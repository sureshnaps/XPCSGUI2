function BW = outsidepolygonmask(I,x,y)
% --- OUTSIDEPOLYGONMASK converts a region polygon to region mask.
% --- BW = OUTSIDEPOLYGONMASK(I,x,y) computes a binary region-of-interest 
% --- mask, BW, from a region-of-interest polygon. The size of BW is the
% --- same as the input image I.
%
% --- Pixels of BW inside  the polygon (x,y) are 1 
% --- Pixels of BW outside the polygon (x,y) are 0
%
% --- The vector x contains the x positions of the polygon pixels
% --- The vector y contains the y positions of the polygon pixels
%
% --- OUTSIDEPOLYGONMASK closes the polygon automatically
%
%       Example:
%
%       I = zeros(256,256)              ;
%       x = [ 63 186 254 190]           ;
%       y = [ 60  60 209 204]           ;
%       in = outsidepolygonmask(I,x,y)  ;
%       imagesc(in)                     ;


% =========================================================================
% --- check input
% =========================================================================
x=double(x);
y=double(y);
if length(x) ~= length(y)
    str1 = 'Function OUTSIDEPOLYGONMASK expected its last two inputs, '    ;
    str2 = 'x and y, to be vectors with the same length.'                  ;
    str  = [str1,str2]                                                     ;
    error(str)                                                             ;
end
clear str1 str2 str

% =========================================================================
% --- if no polygon is defined --> everything is TRUE
% =========================================================================
if isempty(x) 
    BW = ones(size(I))                                                     ;
    return                                                                 ;
end

% =========================================================================
% --- if needed close the polygon
% =========================================================================
if ( (x(end) ~= x(1)) || (y(end) ~= y(1)) )
    x(end+1) = x(1)                                                        ;
    y(end+1) = y(1)                                                        ;
end

% =========================================================================
% --- Scale & quantize (x,y) locations to a 5 times higher resolution grid
% =========================================================================
x = round(5*(x - 0.5) + 1)                                                 ;
y = round(5*(y - 0.5) + 1)                                                 ;

% =========================================================================
% --- Create segments
% =========================================================================
nosegments  = length(x) - 1                                                ;
xsegments   = cell(nosegments,1)                                           ;
ysegments   = cell(nosegments,1)                                           ;
for k = 1:nosegments
    [xsegments{k},ysegments{k}] = intline(x(k),x(k+1),y(k),y(k+1))         ;
end
clear nosegments                                                           ;

% =========================================================================
% --- Concatenate segment vertices.
% =========================================================================
x = cat(1,xsegments{:})                                                    ;
y = cat(1,ysegments{:})                                                    ;
clear xsegments ysegments                                                  ;

% =========================================================================
% --- Horizontal edges are located where the x-value changes
% =========================================================================
d            = diff(x)                                                     ;
edgeindices  = find(d)                                                     ;
xe           = x(edgeindices)                                              ;

% =========================================================================
% If diff is negative, the x-coordinate should be X-1 instead of X
% =========================================================================
shift     = find(d(edgeindices) < 0)                                       ; 
xe(shift) = xe(shift) - 1                                                  ;

% =========================================================================
% In order for the result to be the same no matter which direction we are
% tracing the polynomial, the y-value for a diagonal transition has to be
% biased the same way no matter what.  We'll always chooser the smaller
% y-value associated with diagonal transitions.
% =========================================================================
ye = min(y(edgeindices), y(edgeindices+1))                                 ;
clear d edgeindices shift                                                  ;

% =========================================================================
% a) Scale x values, throwing away edgelist points that are not
% on a pixel's center column. 
% b) Scale y values.
% =========================================================================
xe  = (xe+2)/5                                                             ;
idx = xe == floor(xe)                                                      ;
xe  = xe(idx)                                                              ;
ye  = ye(idx)                                                              ;
ye  = ceil((ye + 2)/5)                                                     ;
clear idx                                                                  ;

% =========================================================================
% Throw away horizontal edges that are too far left, 
% too far right, or below the image.
% =========================================================================
badindices     = find((xe < 1) | (xe > size(I,2)) | (ye > size(I,1)))      ;
xe(badindices) = []                                                        ;
ye(badindices) = []                                                        ;
clear badindices                                                           ;

% =========================================================================
% Treat horizontal edges above the top of the image as 
% they are along the upper edge.
% =========================================================================
ye = max(1,ye)                                                             ;

% =========================================================================
% Insert the edge list locations into a sparse matrix, taking
% advantage of the accumulation behavior of the SPARSE function.
% =========================================================================
S    = sparse(ye,xe,1,size(I,1),size(I,2))                                 ;
F    = full(S)                                                             ; %#ok<ACCUM>
clear S                                                                    ;

% =========================================================================
% Output mask is nonzero wherever cumulative columnwise sum is odd.
% =========================================================================
CSUM = zeros(size(F))                                                      ;
CSUM = cumsum(F,1)                                                         ;
BW   = zeros(size(F))                                                      ;
BW   = mod(CSUM,2)                                                         ;
clear F CSUM                                                               ;
BW = logical(BW);

% =========================================================================
% --- subfunction: intline
% =========================================================================
function [x,y] = intline(x1, x2, y1, y2)
%   INTLINE Integer-coordinate line drawing algorithm.
%   [X, Y] = INTLINE(X1, X2, Y1, Y2) computes an
%   approximation to the line segment joining (X1, Y1) and
%   (X2, Y2) with integer coordinates.  X1, X2, Y1, and Y2
%   should be integers.  INTLINE is reversible; that is,
%   INTLINE(X1, X2, Y1, Y2) produces the same results as
%   FLIPUD(INTLINE(X2, X1, Y2, Y1)).

dx = abs(x2 - x1);
dy = abs(y2 - y1);

% Check for degenerate case.
if ((dx == 0) & (dy == 0))
  x = x1;
  y = y1;
  return;
end

flip = 0;
if (dx >= dy)
  if (x1 > x2)
    % Always "draw" from left to right.
    t = x1; x1 = x2; x2 = t;
    t = y1; y1 = y2; y2 = t;
    flip = 1;
  end
  m = (y2 - y1)/(x2 - x1);
  x = (x1:x2).';
  y = round(y1 + m*(x - x1));
else
  if (y1 > y2)
    % Always "draw" from bottom to top.
    t = x1; x1 = x2; x2 = t;
    t = y1; y1 = y2; y2 = t;
    flip = 1;
  end
  m = (x2 - x1)/(y2 - y1);
  y = (y1:y2).';
  x = round(x1 + m*(y - y1));
end
  
if (flip)
  x = flipud(x);
  y = flipud(y);
end


% ---
% EOF