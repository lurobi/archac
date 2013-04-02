function WFM = pink_generator(nseconds,fs)
    if nargin<2, fs = 44100; end

    nsamp = nseconds*fs;
    white = rand([1,nsamp])-0.5;
    pink = cumsum(white);
    
    % pink is our pink noise, but it's DC component is likely to wonder.
    % This can limit our output dynamic range.  filter out any offsets on
    % the order of a tenth of a second
    window_size = fs/10;
    overlap = 0.75;
    nsamp_new = floor(window_size*(1-overlap));
    nchunk = ceil(nsamp/nsamp_new);
    filt_x = zeros(1,nchunk+2);
    filt_y = zeros(1,nchunk+2);
    filt_x(1) = 1;
    filt_y(1) = pink(1);
    for jchunk=1:nchunk
        jpt1 = (jchunk-1)*nsamp_new + 1;
        jpt2 = min(nsamp,jpt1+window_size-1);
        filt_y(jchunk+1) = mean(pink(jpt1:jpt2));
        filt_x(jchunk+1) = mean([jpt1,jpt2]);
    end
    filt_x(end) = nsamp;
    filt_y(end) = pink(end);
    filt = interp1(filt_x,filt_y,1:nsamp);
    pink = pink - filt;
    
    pink = pink - mean(pink);
    pink = pink / max(abs(pink));
    
    WFM.data = pink;
    WFM.fs = fs;
    WFM = standardize_wfm(WFM);
end