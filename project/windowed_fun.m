function [windowed_data,windowed_ax] = windowed_fun(fun,data,window_size,ovl,orig_ax)
    if(nargin<5) orig_ax=1:length(data); end
    [~,indexes] = gen_overlap_windows(data,window_size,ovl);
    windowed_data = fun(data(indexes));
    windowed_ax = interp1(1:length(data),orig_ax,mean(indexes,2));
end