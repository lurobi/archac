function [reshaped_data,indexes] = gen_overlap_windows(data,window_size,ovl)

    nsamp = numel(data);
    
    if(ovl<=1)
        nsamp_overlap = round(window_size*ovl);
    else
        nsamp_overlap = ovl;
    end
    nsamp_overlap = max(0,nsamp_overlap);
    nsamp_overlap = min(window_size-1,nsamp_overlap);

    nsamp_new = window_size - nsamp_overlap;
    
    nwindows = 1+ceil((nsamp-window_size)/nsamp_new);
    
    starts = 0:nsamp_new:nsamp;
    starts = starts(1:nwindows);
    
    indexes = repmat(1:window_size,[nwindows, 1]);
    starts = repmat(starts',[1,window_size]);
    indexes = indexes+starts;
    
    zpad_data = zeros(1,indexes(end));
    zpad_data(1:nsamp) = data;
    
    reshaped_data = zpad_data(indexes);
end