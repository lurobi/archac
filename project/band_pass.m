function WFM = band_pass(ts_data,low,high,ii_renorm)
    if nargin<4, ii_renorm=1; end

    WFM = standardize_wfm(ts_data);
    cfreqs = linspace(0,WFM.fs,length(WFM.data));
    filt_spec = zeros(1,length(WFM.data));
    filt_spec(cfreqs>low & cfreqs<high) = 1;
    
    filt_spec = fft(WFM.data) .* filt_spec;
    WFM.data = real(ifft(filt_spec));
    
    if(ii_renorm)
        WFM.data = WFM.data./(max(abs(WFM.data)));
    end
end