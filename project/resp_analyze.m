function resp_analyze(REC)

    resp_raw = real(repcor(REC,REC.WFM,0));
    [pk_ind,~,heights] = peak_find(dB20(abs(real(resp_raw))));
    [~,jpk_max_raw] = max(heights);
    peak_ind_raw = pk_ind(jpk_max_raw);
    
    nsamp_smooth = round(0.002*REC.fs);
    [tmp_resp,smooth_ind] = gen_overlap_windows(resp_raw,nsamp_smooth,0.5);
    time_ax_smooth = mean(smooth_ind,2)/REC.fs - REC.time_ax(1);
    resp_envelope = dB10(mean(tmp_resp.^2,2));
    
    [pk_ind,~,heights] = peak_find(resp_envelope');
    [~,jpk_max_env] = max(heights);
    peak_ind_env = pk_ind(jpk_max_env);
    peak_t = time_ax_smooth(peak_ind_env);
    
    
    nsamp_vsmooth = round(0.2*REC.fs);
    [tmp_resp,vsmooth_ind] = gen_overlap_windows(resp_raw,nsamp_vsmooth,0.9);
    time_ax_vsmooth = mean(vsmooth_ind,2)/REC.fs - REC.time_ax(1);
    resp_vsmooth = dB10(mean(tmp_resp.^2,2));
    
    noise_level = median(resp_vsmooth)+5;
    %noise_level = median(resp_envelope(pk_ind));
    %resp_envelope = resp_envelope-noise_level;
    
    
    figure();plot(time_ax_smooth,resp_envelope);
    hold on;
    plot(time_ax_vsmooth,resp_vsmooth,'g');
    
    plot(time_ax_smooth(peak_ind_env),resp_envelope(peak_ind_env),'bo');
    %plot(time_ax_smooth(noise_peaks),resp_envelope(noise_peaks),'ro');
    plot(time_ax_smooth([1 end]),[1 1].*noise_level,'r--');
    ylabel('RMS - dB');
    xlabel('Time - Seconds')
    
    data_r = reverse(resp_raw); %./( 10^((1/20)*noise_level) );
    cum_rms = cumsum(data_r.^2) ./ ((0:(length(data_r)-1))/REC.fs);
    figure(); plot(reverse(REC.time_ax),dB20(cum_rms));
    
    
    [~,vs_peak] = max(resp_vsmooth);
    below_noise = find(resp_vsmooth(vs_peak:end) < noise_level);
    revb_end_t = time_ax_vsmooth(below_noise(1)+vs_peak-1);
    time_ax = REC.time_ax - REC.time_ax(1);
    ii_rvb_only = revb_end_t>=time_ax & peak_t<=time_ax;
    
    r = resp_raw(ii_rvb_only);
    t = (0:(length(r)-1))/REC.fs;
    s = cumsum(reverse(r.^2));
    figure();plot(reverse(t),dB10(s));
end