function group_name_next_suffix = hdf5_find_group_suffix(varargin)
full_hdf5_filename=varargin{1};
group_name=varargin{2};


groups=h5info(full_hdf5_filename);

if (numel(groups.Groups) >= 1)
    for ii=1:numel(groups.Groups)
        group_exchange(ii) = ~isempty(regexp(groups.Groups(ii).Name,group_name,'once')); %#ok<AGROW>
    end

foo=find(group_exchange == 1);
group_name_next_suffix = numel(foo);
else
    group_name_next_suffix=0;
end
