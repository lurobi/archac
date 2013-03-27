function WFM = sweep_generator(f1,f2,time_period)

    f2x = f1+(f2-f1)/2; % why is this necessary!???
    fs = 44100; % should we oversample perhaps?
    WFM.fs = fs;
    WFM.nsamp = fs*time_period;
    WFM.time_ax = linspace(0,time_period,WFM.nsamp);
    %fc_vs_time = logspace(log10(f1),log10(f2x),WFM.nsamp);
    fc_vs_time = linspace(f1,f2x,WFM.nsamp);
    WFM.data = cos(fc_vs_time.*(2.*pi).*WFM.time_ax);
    %WFM = standardize_wfm(WFM);
end