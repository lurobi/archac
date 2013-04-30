function WFM = standardize_wfm(input_wfm)

if(~isstruct(input_wfm))
    WFM.data(1,:) = input_wfm;
else
    WFM = input_wfm;
end


tmp_data(1,:) = WFM.data;
WFM.data = tmp_data;

if(~isfield(WFM,'fs'))
    WFM.fs = 44100; % assume...
end

if(~isfield(WFM,'nsamp'))
    WFM.nsamp = length(WFM.data);
end

if(~isfield(WFM,'duration'))
    WFM.duration = length(WFM.data)/WFM.fs;
end

if(~isfield(WFM,'time_ax'))
    WFM.time_ax = linspace(0,WFM.duration,WFM.nsamp);
end

if(length(WFM.data) ~= WFM.nsamp)
    % fix previous bug!
    WFM.nsamp = length(WFM.data);
    t0 = WFM.time_ax(1);
    WFM.time_ax = 0:1/WFM.fs:((WFM.nsamp-1)/WFM.fs);
    WFM.time_ax = WFM.time_ax+t0;
    WFM.duration = (WFM.nsamp-1)/WFM.fs;
    
end

end