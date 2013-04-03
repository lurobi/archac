function WFM = white_band_generator(nsec,lowf,highf,order,fs)
% WFM = white_band_generator(nsec,lowf,highf,order,fs)
%
% Generates band-limited white noise between lowf (Hz) and highf (Hz) using
% a filter of the given order, and lasting nsec seconds, sampled at fs
% samples/second.

    if(nargin<4) order=512; end
    if(nargin<5) fs=44100; end
    
    % set up some parameters
    overlap=0.75;
    window = hamming(order,'periodic')';

    % generate pure white noise (using rand)
    white = white_generator(nsec,fs);
    
    % implement our band-pass filter as a low-pass filter which has been
    % shifted up to our mid-frequency band.
    midf = (highf+lowf)/2;
    bandwidth = highf-lowf;
    
    % make the filter
    r = bandwidth/fs;
    t = (1:order) - order/2;
    % the filter has it's own windowing as well.
    B = sinc(r*t).*r.*hamming(order,'periodic')';
    
    % you could write a loop which slides some window forward with some
    % overlap, perform ffts on the white noise, applies filtering in the
    % frequency domain, and iffts back to make our data, but that would be
    % slow(ish) in matlab.  Instead arrange our data into matrices and do
    % it all at once.
    [~,window_indexes] = gen_overlap_windows(white.data,order,overlap);
    
    % frequency-domain of unfiltered white noise.
    white_spec = specgram(white.data,order,overlap,0,window);
    % the heterodyne used to shift our filter up to our band.
    heterodyne_ts = sin((window_indexes-1)/fs * midf*2*pi);
    % time-domain multiply shifts low-pass up to band-pass
    full_filt = heterodyne_ts.*repmat(B,[size(white_spec.data,1),1]);
    % convert to frequency-domain so that we can easily apply filter
    full_filt_spec = fft(full_filt,order,2);
    % apply filter by freq-domain multiply (<=> time-domain convolve)
    white_spec.data = full_filt_spec .* white_spec.data;
    % inverse-fft to get back the filtered time-series
    white_band = ispecgram(white_spec);
    
    WFM.data = white_band;
    WFM.fs = fs;
    WFM = standardize_wfm(white_band);
end

%rads_per_samp = midf/fs*2*pi
%rads_per_period = rads_per_samp*order
%rads_per_period/(2*pi)