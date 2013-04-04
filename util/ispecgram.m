function ts = ispecgram(SG)
    
    num_chunks = size(SG.data,1);
    
    nsamp_keep = round(SG.fft_size*(1-SG.overlap));
    nsamp_tot = num_chunks*nsamp_keep + SG.fft_size-nsamp_keep;
    window = SG.window;
    if(isempty(window))
        window = ones(1,SG.fft_size);
    end
    
    ts   = zeros(1,nsamp_tot);
    navg = zeros(1,nsamp_tot);
    iidbg=0;
    if(iidbg) figure();hold on; end
    for jtime=1:num_chunks
        ts_chunk = real(ifft(SG.data(jtime,:)))./window;
        jstart = (jtime-1)*nsamp_keep+1;
        jend   = jstart+SG.fft_size-1;
        ts(jstart:jend) = ts(jstart:jend) + ts_chunk(1:SG.fft_size);
        navg(jstart:jend) = navg(jstart:jend) + 1;
        if(iidbg) plot(jstart:jend,ts_chunk); end
    end
    %navg = SG.fft_size/nsamp_keep;
    ts = ts ./ navg;
end