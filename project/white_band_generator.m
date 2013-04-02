function WFM = white_band_generator(nsec,lowf,highf,order,fs)
    if(nargin<5) fs=44100; end
    
    overlap=0.75;

    white = white_generator(nsec,fs);
    
    midf = (highf+lowf)/2;
    bandwidth = highf-lowf;
    r = bandwidth/fs;
    t = (1:order) - order/2;
    B = sinc(r*t).*r.*hamming(order,'periodic')';
    heterodyne = sin(t*(midf/fs)*2*pi);
    
    white_spec = specgram(white,order,overlap,0,'none');
    nffts = size(1,white_spec);
    nsamp_new = round(order*(1-overlap));
    starts = 0:nsamp_new:nffts*nsamp_new;
    indexes = repmat(1:fft_size,[nffts, 1]);
    starts = repmat(starts',[1,fft_size]);
    indexes = indexes+starts;
    
    
    white_band_spec = white_spec.*repmat(H,[size(white_spec,1),1]);
    white_band = ispecgram(white_band_spec,0.75);
    WFM.data = white_band;
    WFM.fs = fs;
    WFM = standardize_wfm(white_band);
end

%rads_per_samp = midf/fs*2*pi
%rads_per_period = rads_per_samp*order
%rads_per_period/(2*pi)