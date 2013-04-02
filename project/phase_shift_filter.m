function TS_SHIFT = phase_shift_filter(ts)

    TS = standardize_wfm(ts);
    max_delay_sec = 10; % seconds
    nfft = 1024;
    overlap=.75;
    
    spec = specgram(TS.data,nfft,overlap,0);
    nsec_shift = linspace(0,max_delay_sec,nfft/2);
    nsec_shift = [nsec_shift reverse(nsec_shift)];
    nsamp_shift = round(nsec_shift/(nfft*(1-overlap)/TS.fs));
    
    out_spec_size = size(spec);
    out_spec_size(1) = out_spec_size(1) + max(nsamp_shift);
    out_spec = zeros(out_spec_size);
    
    for jtime=1:size(spec,1);
        for jfreq=1:nfft
            ji = jtime+nsamp_shift(jfreq);
            out_spec(ji,jfreq) = spec(jtime,jfreq);
            %out_spec(ji,jfreq+nfft/2) = -out_spec(ji,jfreq);
        end
    end
    %out_spec(:,1+nfft/2:nfft) = reverse(out_spec(:,1:nfft/2));
    ts_out = ispecgram(out_spec,overlap);
    TS_SHIFT = standardize_wfm(ts_out);
end