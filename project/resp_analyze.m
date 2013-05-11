function resp_analyze(REC,fig)
    if nargin<2, ii_new_fig=1; else ii_new_fig=0; end
    if ii_new_fig, figure(); else figure(fig); end
    
    time_ax = REC.time_ax - REC.time_ax(1);
    if ~isfield(REC,'name')
        REC.name = 'UNK';
        REC.room = 'UNK';
    end

    if any(REC.WFM.data>0)
        resp_raw = real(repcor(REC,REC.WFM,0));
        resp_raw = resp_raw/max(abs(resp_raw));
    else
        % assume this was a clap track.
        resp_raw = REC.data';
    end
    resp_raw_dB = dB20(abs(real(resp_raw)));
    [pk_ind,~,heights] = peak_find(resp_raw_dB);
    [~,jpk_max_raw] = max(heights);
    peak_ind_raw = pk_ind(jpk_max_raw);
    peak_level_raw = dB20(abs(real(resp_raw(peak_ind_raw))));
    peak_t_raw = time_ax(peak_ind_raw);
        
    nsamp_smooth = round(0.001*REC.fs);
    [tmp_resp,smooth_ind] = gen_overlap_windows(resp_raw,nsamp_smooth,0);
    time_ax_smooth = mean(smooth_ind,2)/REC.fs;
    resp_envelope = dB10(max(tmp_resp.^2,[],2));
    
    [pk_ind,~,heights] = peak_find(resp_envelope');
    [~,jpt_coarse_peak] = max(resp_envelope);
    jpts_near = numel(find((time_ax_smooth-time_ax_smooth(1))<0.25));
    %peak_t = time_ax_smooth(jpt_coarse_peak);
    
    
    ii_near = find(pk_ind > (jpt_coarse_peak-jpts_near) & pk_ind < (jpt_coarse_peak+jpts_near));
    [~,jpk_max_env] = max(heights(ii_near));
    peak_ind_env = pk_ind(ii_near(jpk_max_env));
    %peak_ind_env = jpt_coarse_peak;
    peak_level = resp_envelope(peak_ind_env);
    orig_peak_t = time_ax_smooth(peak_ind_env);

    new_peak_t = 0;
    time_ax = time_ax - orig_peak_t + new_peak_t;
    time_ax_smooth = time_ax_smooth - orig_peak_t + new_peak_t;
    
    nsamp_vsmooth = round(0.1*REC.fs);
    [tmp_resp,vsmooth_ind] = gen_overlap_windows(resp_raw,nsamp_vsmooth,0.9);
    time_ax_vsmooth = mean(vsmooth_ind,2)/REC.fs - orig_peak_t;
    ii_background = time_ax_smooth>3 & time_ax_smooth<6;
    resp_vsmooth = dB10(mean(tmp_resp.^2,2));
    
    noise_level = median(resp_envelope(ii_background));
    %noise_level = median(dB10(resp_raw(ii_background).^2))+5;
    %noise_level = median(resp_envelope(pk_ind));
    %resp_envelope = resp_envelope-noise_level;
    
    
    subplot(211); hold on; ax1 = gca;
    c = color_from_name(REC.name);
    if(ii_new_fig)
        set(gcf,'Name',sprintf('%s in %s',REC.name,REC.room));
        title(sprintf('%s in %s',REC.name,REC.room));
        set(get(gca,'Title'),'Interpreter','None')
        plot(time_ax,resp_raw_dB,'Color',0.75*[1 1 1],'Tag','details');
        plot(time_ax_smooth,resp_envelope,'Color',0.5*[1 1 1],'Tag','details');
        
    else
        title(sprintf('Response in %s',REC.room));
        set(get(gca,'Title'),'Interpreter','None')
        set(gcf,'Name',sprintf('Response in %s',REC.room));
        delete(findall(ax1,'Tag','details'));
    end

    hold on;
    plot(time_ax_vsmooth,resp_vsmooth,'Color',c,'LineWidth',2.5);
    
    plot(time_ax_smooth(peak_ind_env),resp_envelope(peak_ind_env),'o', ...
        'MarkerFaceColor',c,'Color',c);
    %plot(time_ax_smooth(noise_peaks),resp_envelope(noise_peaks),'ro');
    h = plot(time_ax_smooth([1 end]),[1 1].*noise_level,'--','Color',c);
    set(h,'ButtonDownFcn',@on_click_noise);
    setappdata(h,'resp_name',REC.name);
    ylabel('Energy - dB');
    xlabel('Time - Seconds')
    
    data_r = reverse(resp_raw); %./( 10^((1/20)*noise_level) );
    cum_rms = cumsum(data_r.^2) ./ ((0:(length(data_r)-1))/REC.fs);
    
    subplot(212);ax2 = gca; hold on;
    RESP.resp_raw = resp_raw;
    RESP.time_ax  = time_ax;
    RESP.resp_vsmooth = resp_vsmooth;
    RESP.time_ax_vsmooth = time_ax_vsmooth;
    RESP.orig_peak_t = orig_peak_t;
    RESP.new_peak_t = new_peak_t;
    RESP.noise_level = noise_level;
    RESP.peak_level = peak_level;
    RESP.fs = REC.fs;
    RESP.name = REC.name;
    
    all_names = getappdata(gcf,'all_names');
    if isempty(all_names), all_names{1}=REC.name; else all_names{end+1}=REC.name; end
    setappdata(gcf,'all_names',all_names);
    
    setappdata(gcf,RESP.name,RESP);
    
    integrate_resp(RESP.name);
    
end
function integrate_resp(name,~)
    ax1 = subplot(211);
    ax2 = subplot(212);
    set([ax1 ax2],'Color',[1 1 1]);

    RESP = getappdata(gcf,name);
    short_name = short_from_name(RESP.name);
    c=color_from_name(RESP.name);
    plot_defs = {'Tag',RESP.name,'Color',c};
    delete(findall(ax1,'Tag',RESP.name));
    delete(findall(ax2,'Tag',RESP.name));
    
    vs_peak = round(interp1(RESP.time_ax_vsmooth,1:length(RESP.time_ax_vsmooth),RESP.new_peak_t));
    below_noise = find(RESP.resp_vsmooth(vs_peak:end) < RESP.noise_level);
    revb_end_t = RESP.time_ax_vsmooth(below_noise(1)+vs_peak-1);
    ii_rvb_only = RESP.new_peak_t<=RESP.time_ax & RESP.time_ax<=revb_end_t;
    
    plot(ax1,[1 1].*RESP.new_peak_t,[0 RESP.peak_level+20],'--',plot_defs{:});
    plot(ax1,[1 1].*revb_end_t,[0 RESP.peak_level+20],'--',plot_defs{:});
    
    r = RESP.resp_raw(ii_rvb_only);
    t = (0:(length(r)-1))/RESP.fs;
    s = reverse(cumsum(reverse(r.^2)));
    s_dB = dB10(s);
    
    plot_reverb_ts(RESP,ii_rvb_only);
    
    plot(t,s_dB,plot_defs{:});
    xlabel('Time - Seconds');
    ylabel('Integrated Energy - dB')
    
    
    integrated_peak = s_dB(1);
    jpt_integrated_5down = find(s_dB<integrated_peak-5,1,'first');
    jpt_integrated_35down = find(s_dB<integrated_peak-35,1,'first');
    T60 = 2*(jpt_integrated_35down-jpt_integrated_5down)/RESP.fs;
    T60 = calc_T60(s_dB,RESP.fs);
    
    T60_line = interp1([0,T60],[0,-60]+integrated_peak,t);
    ea_energy = median(T60_line-s_dB);
    
    plot(ax2,[0 T60],[0, -60]+integrated_peak-ea_energy,'r--','LineWidth',2,plot_defs{:});
    text_defs = {'EdgeColor','k','FontWeight','bold','HorizontalAlignment','left','Color',c};
    text(T60,integrated_peak-60,sprintf('%s:%.2f',short_name,T60),...
        'Tag',RESP.name,text_defs{:});
    %plot(ax2,[0 T45*1.25],[0 -60]+integrated_peak,'g--','LineWidth',2);
    %plot(ax2,[0 T60],[0 -60]+integrated_peak,'m--','LineWidth',2);

    RESP.revb_end_t = revb_end_t;
    RESP.T60 = T60;
    
    setappdata(gcf,name,RESP);
    %set(gcf,'Color','none');
    %set([ax1,ax2],'Color',[1 1 1]*.6);
    
    all_names = getappdata(gcf,'all_names');
    max_T60 = RESP.T60;
    max_revb = RESP.revb_end_t;
    for jname=1:length(all_names)
        jRESP = getappdata(gcf,all_names{jname});
        max_T60 = max(max_T60,jRESP.T60);
        max_revb = max(max_revb,jRESP.revb_end_t);
    end
    
    if false
        subplot(313); ax3 =gca; hold on;
        offset=0;
        switch(short_name)
            case 'sweep'
                offset=2;
            case 'm-seq'
                offset=4;
            case 'white'
                offset=6;
        end
        ii_take = (RESP.new_peak_t-0.25)<=RESP.time_ax & RESP.time_ax<=(revb_end_t+0.25);
        resp_ts = RESP.resp_raw(ii_take)/max(abs(RESP.resp_raw(ii_take)));
        plot(RESP.time_ax(ii_take),resp_ts+offset,plot_defs{:});
    end
    
    
    %R = standardize_wfm(resp_ts);
    %R.time_ax = RESP.time_ax(ii_take);
    %R.fs = RESP.fs;
    %specgram(R,256,0.9,1,'hamming');
    
    if length(all_names)>1
        set(ax1,'Xlim',[-.25, max_revb*2],'Ylim',[-20, +80]+RESP.noise_level);
        set(ax2,'Xlim',[0, max_T60*1.1],'Ylim',[-80, +20]+integrated_peak);
    else
        set(ax1,'Xlim',[-1, 6],'Ylim',[-20, +80]+RESP.noise_level);
        set(ax2,'Xlim',[0, 4],'Ylim',[-80, +20]+integrated_peak);
    end
    
end

function on_click_noise(a,b)
    ax2 = get(a,'Parent');
    %fprintf('on_click_noise: %s\n',get(gcf,'SelectionType'));
    set(gca,'ButtonDownFcn',@(~,~) on_click_ax(a));
end

function on_click_ax(a)
    set(gca,'ButtonDownFcn',[]);
    cp = get(gca,'CurrentPoint');
    y_val = cp(1,2);
    %fprintf('on_click_ax: %s\n',get(gcf,'SelectionType'));
    set(a,'YData',[y_val y_val]);
    name = getappdata(a,'resp_name');
    RESP=getappdata(gcf,name);
    RESP.noise_level = y_val;
    setappdata(gcf,name,RESP);
    integrate_resp(name);
end

function n = short_from_name(n)
    if(strfind(n,'sweep'))
        n='sweep';
    elseif(strfind(n,'wn'))
        n='white';
    elseif(strfind(n,'ml'))
        n='m-seq';
    else
        n='';
    end
end

function c = color_from_name(n)
    if(strfind(n,'sweep'))
        c=[0 0 1];
    elseif(strfind(n,'wn'))
        c=[1 0 0];
    elseif(strfind(n,'ml'))
        c=[0 1 0];
    else
        fprintf('No color for %s\n',n);
        c=rand(1,3);
    end
end

function T60 = calc_T60(s_dB,fs)

    gap_s = 0.1; % seconds
    ngap = round(gap_s*fs);
    starts = 1:(length(s_dB)-ngap);
    stops  = starts+ngap;
    median_fall = median(s_dB(starts) - s_dB(stops));
    T60 = 60/(median_fall/gap_s);
end

function plot_reverb_ts(RESP,ii_rvb_only)
    fig=gcf;
    c = color_from_name(RESP.name);
    short_name = short_from_name(RESP.name);
    f = findall(0,'Name','Time-series Impulses');
    if(isempty(f)) f = figure(); set(f,'Name','Time-series Impulses'); end
    figure(f);
    jpt_on = find(ii_rvb_only,1,'first');
    jpt_off = find(ii_rvb_only,1,'last');
    jpt_on = jpt_on - round(0.25*RESP.fs);
    t = RESP.time_ax(jpt_on:jpt_off);
    r = RESP.resp_raw(jpt_on:jpt_off);
    %r = r/max(abs(r));
    %[shaped,inds] = gen_overlap_windows(r.^2,440,.75);
    %t2 = mean(inds,2).*RESP.fs + t(1);
    %env = sqrt(mean(shaped,2));
    %plot(t2,env,'Color',c,'DisplayName',short_name);
    %plot(t2,-env,'Color',c,'DisplayName',short_name);
    switch(short_name)
        case 'm-seq'
            subplot(313)
        case 'sweep'
            subplot(311)
        case 'white'
            subplot(312)
    end
    cla();
    plot(t,r,'Color',c,'DisplayName',short_name);
    figure(fig); 
end