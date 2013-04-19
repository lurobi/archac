function architectural_ac_hw8()

    prob6();
end

function prob2()

    levs     = [ 45 50 50 53 55 51  51 ];
    hours    = [ 6  1  1  4  5  5   2  ];
    dn_pen   = [ 10 10 0  0  0  0   10 ];
    cnel_pen = [ 10 10 0  0  0  4.8 10 ];
    
    L_dn   = 10*log10(sum((hours.*10.^(0.1*(levs+dn_pen))))/24);
    fprintf('L_dn = %.2f\n',L_dn);
    L_cnel = 10*log10(sum((hours.*10.^(0.1*(levs+cnel_pen))))/24);
    fprintf('L_cnel = %.2f\n',L_cnel);
end

function prob2b()

    levs(1:6) = 45;
    levs(7:8) = 50;
    levs(9:12) = 53;
    levs(13:17) = 55;
    levs(18:24) = 51;
    dn_pen(1:7) = 10;
    dn_pen(8:22) = 0;
    dn_pen(23:24) = 10;
    cnel_pen =dn_pen;
    cnel_pen(18:22) = 4.8;
    L_dn   = 10*log10(sum((10.^(0.1*(levs+dn_pen))))/24);
    fprintf('L_dn = %.2f\n',L_dn);
    L_cnel = 10*log10(sum((10.^(0.1*(levs+cnel_pen))))/24);
    fprintf('L_cnel = %.2f\n',L_cnel);
end

function prob3()
    ti = [ 0.6 0.9 3.3 1.2 1.5];
    Li = [ 101 98  94  85  75 ];
    cl=90;
    er=5;
    Ti = 8./2.^((Li-cl)./er);
    fprintf('Ti = ');disp(Ti);
    fprintf('ti/Ti= '); disp(ti./Ti);
    fprintf('D = %.2f\n',sum(ti./Ti));
end

function prob4()
    r = 3;
    L_spreading = -10*log10(1/(4*pi*r^2));
    Wi = [18 50 75 107 83] * 1e-4;
    SL = [ 72 73 78 63 58 ];
    Lp = SL - L_spreading;
    fprintf('Lp = ');disp(Lp);
    SNR = Lp - 45;
    fprintf('SNR = ');disp(SNR);
    fprintf('AI  = ');disp(sum(SNR.*Wi));
end

function prob5()

    f_mod = [0.63 0.8 1 1.25 1.6 2.0 2.5 3.15 4 5 6.3 8 10 12.5];

    f_oct  = [125 250 500 1000 2000 4000 8000];
    T60 = [2.0 2.0 2.0 1.4 1.0 0.7 0.5];
    SNR = [  0   5  10  10  10  10  10];
    Wi  = [ 0.13 0.14 0.11 0.12 0.19 0.17 0.14];
    
    function m = mod_fac(jmod,joct)
        a = (2*pi*f_mod(jmod)*T60(joct)/13.8)^2;
        b = 10^(-0.1*SNR(joct));
        m = 1/(sqrt(1+a) * (1+b));
    end

    figure();
    hold on;
    set(gca,'Xscale','log');
    xlabel('Modulation Frequency (f_m) - Hz');
    ylabel('Modulation Reduction, m');
    Lsn_app_avg = 0;
    for joct=1:length(f_oct)
        for jmod=1:length(f_mod)
            m = mod_fac(jmod,joct);
            Lsn_app = 10*log10(m/(1-m));
            Lsn_app = max(Lsn_app,-15);
            Lsn_app = min(Lsn_app,+15);
            Lsn_app_avg = Lsn_app_avg + Lsn_app*Wi(joct);
            mod_fac_curves(jmod,joct) = m;
            Lsn_app_curves(jmod,joct) = Lsn_app*Wi(joct);
        end
        plot(f_mod,mod_fac_curves(:,joct));
        %plot(f_mod,Lsn_app_curves(:,joct));
    end
    STI = (Lsn_app_avg+15)/30;
    fprintf('STI = %.4f\n',STI);
end


function rating = nc_rate(rating_name,meas)
    out = csvread([rating_name '_Data.csv']);
    fc = out(1,:);
    nc_curves = out(2:end,:);
    % meas is assumed 31.5 to 4K.  Make sure we use the same frequencies
    % for our nc curves!
    ii_octaves_keep=(fc>=31.5 & fc<=4000);
    nc_curves = nc_curves(:,ii_octaves_keep);
    fc = fc(ii_octaves_keep);
    if(fc(1)>31.5) meas=meas(2:end); end
    ncurves = size(nc_curves,1);
    jhi=[]; jlow=[];
    figure(); hold on;
    plot(fc,meas); h=[];
    for jcurve=1:ncurves
        delete(h);
        h = plot(fc,nc_curves(jcurve,:)','k--');
        [min_exceed,joct] = min(nc_curves(jcurve,:)-meas);
        if(min_exceed>0)
            jhi=jcurve;
            jlow=jcurve-1;
            break;
        end
    end
    
    jcurve_interp = interp1(nc_curves([jlow jhi],joct),[jlow jhi],meas(joct));
    switch(rating_name)
        case{'NC','NCB','PNC'}
            curve0=15; step=5;
        case{'NR'}
            curve0=0; step=10;
    end
    curve_name = (jcurve_interp-1)*step + curve0;
    fprintf('%3s Rating: %.0f (from %d octave)\n',rating_name,curve_name,fc(joct));
end

function rc_rate(fc,meas)
    PSIL = meas(fc==500) + meas(fc==1000) + meas(fc==2000);
    PSIL = PSIL/3;
    RC = PSIL -5*((1:length(fc)) - find(fc==1000));
    ii_lf = fc<=500;
    ii_hf = fc>=1000;
    RC(ii_lf) = RC(ii_lf) + 5;
    RC(ii_hf) = RC(ii_hf) + 3;
    if all((RC-meas)>0)
        mods = 'N';
    else
        mods = '';
        if any(RC(ii_lf)-meas(ii_lf) < 0)
            mods = [ mods 'R'];
        end
        if any(RC(ii_hf)-meas(ii_hf) < 0)
            mods = [ mods 'H'];
        end
    end
    figure(); plot(fc,meas); hold on; %set(gca,'XScale','log');
    plot(fc,RC,'k--');
    fprintf('  RC Rating %.0f-%s\n',PSIL,mods);
end

function prob6()
    fc_meas = [31.5 63 125 250 500 1000 2000 4000];
    meas = [55 53 57 46 39 31 29 22];
    rc_rate(fc_meas,meas);
    nc_rate('NC',meas);
    nc_rate('NCB',meas);
    nc_rate('NR',meas);
    nc_rate('PNC',meas);
    
end