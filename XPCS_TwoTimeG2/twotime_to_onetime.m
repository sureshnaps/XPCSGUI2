function [g2full,g2partial]=twotime_to_onetime(varargin)
%%
%%This function takes a 2-time correlation 2-D matrix and computes a one
%%time g2 by taking the diagonal and parallel to diagonal slices. The 2-time
%%matrix is of the size Nframes x Nframes and is typically for a single bin
%%which is a single q/phi partition. By default, it requires a single input
%%which is the 2-time matrix and the output is the g2 averaged over the
%%entire t2-t1 range. Alternatively, for systems evolving with time, one
%%can provide a 2nd and 3rd argument which provides a lower and upper end
%%of perpendicular to diagonal. An optional 4th arg if set to 1 will
%%produce plots showing several plots in detail.
%%
%%Usage: [g2full,g2partial]=twotime_to_onetime(C);
%%Usage: [g2full,g2partial]=twotime_to_onetime(C,1,2*Nframes);
%%Usage: [g2full,g2partial]=twotime_to_onetime(C,any number >1,any number < 2N frames);
%%Usage: [g2full,g2partial]=twotime_to_onetime(C,any number >1,any number < 2N frames,1);
%%
%%Acknowledgments:
%%Mark Sutton's code concept.

%%
C=varargin{1}; %%two time correlation matrix
dim=size(C,1);

if (nargin > 1)
    g2partial_step_size = varargin{2};
end

%%specify a (t1+t2) perp. to diag range
% if (nargin>=2)
%     diagonal_start=varargin{2}; 
% else
%     diagonal_start=1;
% end
% 
% if (nargin>=3)
%     diagonal_end=varargin{3};
% else
%     diagonal_end=dim;
% end
% 
% if (diagonal_end <= diagonal_start)
%     disp('Specified start and end segments are inappropriate');
%     return;
% end

if (nargin ==3)
    plot_yes_no=varargin{3};
else
    plot_yes_no=0;
end
%Mark's idea: create a matrix of the size of the two time corr. matrix and
%assign each pixel a value equivalent to t1-t2 which are the diagonal and
%parallel to diagonal pixels
[z1,z2]=meshgrid(1:dim,1:dim);

h=z1-z2;
h=triu(h); %upper and lower triangular are symmetrical, so get rid of one
g=(h~=0);
C=C.*g;%get rid of the lower triangle in the two time

hh=h(g); %get the pixel indices with non-zero t1-t2
CC=C(g); %get the corr. values with non-zero t1-t2

%Mark's accumarray trick, 10 times faster than a for loop.
g2full=accumarray(hh(:),CC(:)); %sums up values of C that belong to the same pixel indices as hh
index_count=histc(h(:),min(hh):max(hh)); %count the number of pixels in each parallel to diagonal
g2full=g2full./index_count; 
%%
%for Rogers' shear cell to fix first point
% % x=(h==1);
% % y=C(x);
% % g2full(1)=mean(y(1:2:end));
% % % g2full(1)=mean(y(1:2:3));

%%
%this was the old way I was dividing 2-time into 1-time, apparently not
%that appropriate (as per Mark)
%%pick a range in the direction perp. to diagonals for cases where g2 is
%%evolving a lot
% hp=triu(z1+z2);
% gp=(hp>=diagonal_start)&(hp<=diagonal_end)&(h>=1);
% 
% if (plot_yes_no==1)
%     figure;imagesc(gp);axis xy;title('perpendicular to diagonal indices','fontweight','bold','fontsize',14);colorbar;
%     xlabel('t_1 (frames)','fontweight','bold','fontsize',14);
%     ylabel('t_2 (frames)','fontweight','bold','fontsize',14);
% end
% 
% hhp=h(gp);
% CCp=C(gp);
% 
% g2partial=accumarray(hhp(:),CCp(:));
% index_count=histc(hhp(:),min(hhp):max(hhp));
% g2partial=g2partial./index_count;
% 
% if (plot_yes_no==2)
%     figure;hold off;semilogx(g2full,'bo');title('g2 from diagonal and off-diagonal average of two time','fontweight','bold','fontsize',14);
%     xlabel('t_1-t_2 (frames)','fontweight','bold','fontsize',14);
%     ylabel('g_2-1 (frames)','fontweight','bold','fontsize',14);   
%     figure;hold on;semilogx(g2partial,'k');title('g2 from diagonal and off-diagonal average of two time','fontweight','bold','fontsize',14);
%     legend('full t1+t2', 'partial t1+t2');
% end
% return;
%%
%new way or more appropriate way of dividing 2-time into 1-time (as per
%Mark)
if (nargin == 1)
    g2partial = NaN;
    return;
end
%%
start_stop_vals=floor(linspace(0,dim,floor(dim/g2partial_step_size)+1));
diagonal_start_vals = start_stop_vals(1:end-1)+1;
diagonal_end_vals = start_stop_vals(2:end);

h_max = transpose(h(diagonal_end_vals,end)); %helps with parfor slicing
deltaT_max = min((diagonal_end_vals-diagonal_start_vals+1),h_max);
% % % %             deltaT_max = h(diagonal_end_vals,end);    
%%
for jj=find(deltaT_max) %1:numel(diagonal_start_vals)
    gp=((h>0)&(h<deltaT_max(jj))) & (z2 >= diagonal_start_vals(jj) & z2 <= diagonal_end_vals(jj));
    
    hhp=h(gp);
    CCp=C(gp);   
    
    g2partial{jj}=accumarray(hhp(:),CCp(:));
    index_count=histc(hhp(:),min(hhp):max(hhp));
    g2partial{jj}=g2partial{jj}./index_count;    
end
%%
if (plot_yes_no==1)
    figure;imagesc(h);axis xy;title('diagonal indices where pixel values are set to t1-t2','fontweight','bold','fontsize',14);colorbar;
    xlabel('t_1 (frames)','fontweight','bold','fontsize',14);
    ylabel('t_2 (frames)','fontweight','bold','fontsize',14);

    figure;imagesc(C);axis xy;title('lower triangular of two time matrix','fontweight','bold','fontsize',14);colorbar;
    xlabel('t_1 (frames)','fontweight','bold','fontsize',14);
    ylabel('t_2 (frames)','fontweight','bold','fontsize',14);
end
