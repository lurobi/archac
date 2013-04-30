function wfm_compare(WFM,fig,name,color)
    if(nargin<2), fig=figure(); else figure(fig); end
    if(nargin<3), name = []; end
    if(nargin<4), color='b'; end

    WFM = standardize_wfm(WFM);

    % normalize the waveform
    WFM.data = WFM.data/max(abs(WFM.data));
    papr = dB10(max(WFM.data.^2)/mean(WFM.data.^2));
    resp = repcor(WFM,WFM,0);
    % normalize to peak of 1 (0 dB)
    %resp = resp/max(abs(resp));
    resp_dB = dB10(resp.^2);
    %resp_dB = resp_dB - max(resp_dB);
    
    white_sample = rand(size(WFM.data))*2 - 1;
    tone_sample = sweep_generator(1000,1000,WFM.duration);
    white_resp=repcor(WFM,white_sample,0);
    tone_resp=repcor(WFM,white_sample,0);
    white_rej_rms = dB10(mean(white_resp.^2));
    white_rej_max = dB10(max(white_resp.^2));
    tone_rej_rms = dB10(mean(tone_resp.^2));
    tone_rej_max = dB10(max(tone_resp.^2));
    
    fprintf('%s waveform total energy: %.2f dB. PAPR=%.2f dB\n',name,dB10(sum(WFM.data.^2)),papr);
    fprintf('%s autocor total energy:  %.2f dB\n',name,dB10(sum(resp.^2)));
    fprintf('%s rejects white noise at %.0f dB (%.0f dB peak)\n',name,white_rej_rms,white_rej_max);
    %fprintf('%s rejects 1kHz tone at   %.0f dB (%.0f dB peak)\n',name,tone_rej_rms,tone_rej_max);
    
    hold on;
    plot(WFM.time_ax,resp_dB,'Color',color,'DisplayName',name);
    xlabel('Time - Seconds');
    ylabel('Autocorrelation Response - dB');

end