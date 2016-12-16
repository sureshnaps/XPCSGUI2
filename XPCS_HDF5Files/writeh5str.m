function writeh5str(filename,dsetname,str,STR_SIZE)
% Example: writeh5str('example.h5','/DS','foo',string_size)
%This function does the following: (a) writes a fixed size string array as a
%scalar array, (b) as an optional provided arg, it writes a string of a
%bigger size, (c) in a try catch block, it deletes the dataset so that it
%can be written with a string of any arbitrary size without making the
%string of a larger size
%To check: is H5L.delete the only or the best way to delete the dataset,
%could not find a better way
%
%
%%
if (nargin == 3)
    STR_SIZE = numel(str);
end
%%
if (nargin == 4)
    if (numel(str) < STR_SIZE)
        %     warning(['Padding input ''str'' with blanks to maximum size ' num2str(STR_SIZE)]);
        str = [str,blanks(STR_SIZE - numel(str))];
    elseif (numel(str) >  STR_SIZE)
        warning(['Trimming input ''str'' down to maximum size ' num2str(STR_SIZE)]);
        str = str(1:STR_SIZE);
    end
end
%%
fid = H5F.open(filename,'H5F_ACC_RDWR','H5P_DEFAULT');
type_id = H5T.copy('H5T_C_S1');
H5T.set_size(type_id,STR_SIZE);
space_id = H5S.create('H5S_SCALAR');
%%
if H5L.exists(fid, dsetname, 'H5P_DEFAULT')
    H5L.delete(fid, dsetname, 'H5P_DEFAULT')
end
%%
try
    dset_id = H5D.create(fid,dsetname,type_id,space_id,'H5P_DEFAULT');
catch
    dset_id = H5D.open(fid,dsetname);
end
%%
H5D.write(dset_id,'H5ML_DEFAULT','H5S_ALL','H5S_ALL','H5P_DEFAULT',str)
%%
H5S.close(space_id);
H5T.close(type_id);
H5D.close(dset_id);
H5F.close(fid);
end