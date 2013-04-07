function SPECGRAM = specgram(ts,fft_size,overlap,ii_plot,window)
    if (nargin==1)
        fft_size=2048; overlap=0.5; ii_plot=1; window='hamming';
    else
        if nargin<4, ii_plot=0; end
        if nargin<5, window = []; end
    end
    
    WFM = standardize_wfm(ts);

    [reshaped_ts,indexes] = gen_overlap_windows(WFM.data,fft_size,overlap);
    fft_centers = indexes(:,1) + fft_size/2;
    
    if ischar(window)
        switch(window)
            case 'hamming'
                window = hamming(fft_size,'periodic')';
            case 'none'
                window = [];
            otherwise
                error('unrecognized window name!');
        end
    end
    if ~isempty(window)
        reshaped_ts = reshaped_ts .* repmat(window,[size(reshaped_ts,1),1]);
    end
    
    SPECGRAM.data = fft(reshaped_ts,fft_size,2);
    SPECGRAM.labels = {'Time - Seconds','Frequency - Hz'};
    SPECGRAM.scales{1} = fft_centers/WFM.fs - WFM.time_ax(1);
    SPECGRAM.scales{2} = linspace(0,WFM.fs,fft_size);
    SPECGRAM.window = window;
    SPECGRAM.overlap = overlap;
    SPECGRAM.nsamp_orig = WFM.nsamp;
    SPECGRAM.fft_size = fft_size;
    
    if(ii_plot)
        ii_take = 2:ceil(SPECGRAM.fft_size/2);
        tax = SPECGRAM.scales{1};
        fax = SPECGRAM.scales{2}(ii_take);
        figure();imagesc(fax,tax,dB20(abs(SPECGRAM.data(:,ii_take))));
        xlabel(SPECGRAM.labels{2});
        ylabel(SPECGRAM.labels{1});
    end
end