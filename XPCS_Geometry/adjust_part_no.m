function [ys,yd]=adjust_part_no(no_sta,no_dyn)
              
ys=no_dyn*ceil(no_sta/no_dyn);
if(ys==0)
    ys=no_dyn;
end
yd=no_dyn;
