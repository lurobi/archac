function spec_out = specgram(ts,fft_size,overlap,ii_plot,wname)
    if nargin<4, ii_plot=0; end
    if nargin<5, wname = 'none'; end
    
    if isempty(wname), wname = 'none'; end
    
    WFM = standardize_wfm(ts);

    if(overlap<=1)
        nsamp_overlap = round(fft_size*overlap);
    else
        nsamp_overlap = overlap;
    end
    nsamp_overlap = max(0,nsamp_overlap);
    nsamp_overlap = min(fft_size-1,nsamp_overlap);

    nsamp_new = fft_size - nsamp_overlap;
    
    nffts = 1+ceil((WFM.nsamp-fft_size)/nsamp_new);
    % pad the end of the time series with zeros so we have an integer
    % number of ffts to run.
    ts_pad = zeros(1,fft_size+(nffts-1)*nsamp_new);
    ts_pad(1:WFM.nsamp) = WFM.data;
    
    starts = 0:nsamp_new:WFM.nsamp;
    starts = starts(1:nffts);
    
    indexes = repmat(1:fft_size,[nffts, 1]);
    starts = repmat(starts',[1,fft_size]);
    indexes = indexes+starts;
    
    blocked = ts_pad(indexes);
    if ~strcmp(wname,'none')
        switch(wname)
            case 'hamming'
                window = hamming(fft_size,'periodic')';
            otherwise
                error('unrecognized window name!');
        end
        window = repmat(window,[nffts,1]);
        blocked = blocked .* window;
    end
    spec_out = fft(blocked,fft_size,2);
    
    
    if(ii_plot)
        fax = linspace(0,WFM.fs,fft_size)/1000;
        tax = (starts(:,1) + fft_size/2)/WFM.fs;
        ii_take = 2:ceil(fft_size/2);
        figure();imagesc(fax(ii_take),tax,20*log10(abs(spec_out(:,ii_take))));
        xlabel('Frequency - kHz');
        ylabel('Time - Seconds');
    end
end