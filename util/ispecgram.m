function ts = ispecgram(spec,overlap)
    fft_size = size(spec,2);
    num_chunks = size(spec,1);
    
    nsamp_keep = floor(fft_size*(1-overlap));
    nsamp_tot = num_chunks*nsamp_keep + fft_size-nsamp_keep;
    ts   = zeros(1,nsamp_tot);
    navg = zeros(1,nsamp_tot);
    for jtime=1:num_chunks
        ts_chunk = real(ifft(spec(jtime,:)));
        jstart = (jtime-1)*nsamp_keep+1;
        jend   = jstart+fft_size-1;
        ts(jstart:jend) = ts(jstart:jend) + ts_chunk(1:fft_size);
        if(jtime<10)
            if(jtime==1) figure(); hold on; end
            plot(jstart:jend,ts_chunk)
        end
        navg(jstart:jend) = navg(jstart:jend) + 1;
    end
    
    ts = ts ./ navg;
    
end