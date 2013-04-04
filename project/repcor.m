function repout = repcor(WFM,REC)

    WFM = standardize_wfm(WFM);
    REC = standardize_wfm(REC);
    
    % there should probably be some normalization here... not sure what the
    % correct levels should be.
    samps_good = max(WFM.nsamp,REC.nsamp);
    samps_needed = 2*samps_good;
    wfm_spec = fft(WFM.data,samps_needed);
    rec_spec = fft(REC.data,samps_needed);
    repout = ifft(rec_spec.*conj(wfm_spec),samps_needed);
    repout = repout(1:samps_good);
    time_ax = 0:(1/REC.fs):REC.duration-1/REC.fs;
    [~,peak_ind] = max(dB10(repout));
    time_ax = time_ax - time_ax(peak_ind);
    figure();plot(time_ax,dB20(repout));
    
end