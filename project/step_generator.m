function WFM = step_generator(f1,f2,t_cw,n_cw,time_period)

    bw = abs(f2-f1);
    t_cw_tot = t_cw*n_cw;
    t_fm_tot = time_period-t_cw_tot;
    t_fm = t_fm_tot/(n_cw+1); % start and end on FM.
    fm_Hz_per_sec = (f2-f1)/t_fm_tot;
    
    
    fs = 44100; % should we oversample perhaps?
    dt = 1/fs;
    WFM.fs = fs;
    WFM.nsamp = fs*time_period;
    WFM.time_ax = linspace(0,time_period,WFM.nsamp);
    %fc_vs_time = logspace(log10(f1),log10(f2x),WFM.nsamp);
    fc_vs_time = NaN(size(WFM.time_ax));
    
    ii_fm_or_cw = 0;
    fc_vs_time(1) = f1;
    counter = dt;
    for jt = 2:length(fc_vs_time);
        if ii_fm_or_cw == 0 % fm
            t_per = t_fm;
            fc_vs_time(jt) = fc_vs_time(jt-1) + fm_Hz_per_sec*dt;
        elseif ii_fm_or_cw == 1
            t_per = t_cw;
            fc_vs_time(jt) = fc_vs_time(jt-1);
        else
            error('logic error');
        end
        counter = counter + dt;
        if counter >= t_per
            counter = 0;
            ii_fm_or_cw = mod(ii_fm_or_cw+1,2);
        end
    end
    %figure();plot(fc_vs_time+diff([f1 fc_vs_time]));
    %true_freq = (fc_vs_time-diff([0 fc_vs_time])*fs).*WFM.time_ax.*(2.*pi);
    %WFM.data = sin(true_freq);
       
    valprev = 0 + 1i;
    WFM.data(1) = 0;
    nt = length(fc_vs_time);
    dt = 1/fs;
    
    for jt = 2:length(fc_vs_time)
        df = diff(fc_vs_time([jt jt-1]));
        
        valprev = exp(1i*((fc_vs_time(jt)*2*pi) - dt*df*2*pi + angle(valprev) ));
        WFM.data(jt) = real(valprev);
    end
    specgram(WFM);
    hold on;
    plot(fc_vs_time,WFM.time_ax,'w--');
    figure();plot(WFM.data(1:100))
 
%     WFM = standardize_wfm(WFM);
end