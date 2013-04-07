function WFM = white_band_generator2(nsec,lowf,highf,order,fs)
% WFM = white_band_generator(nsec,lowf,highf,order,fs)
%
% Generates band-limited white noise between lowf (Hz) and highf (Hz) using
% a filter of the given order, and lasting nsec seconds, sampled at fs
% samples/second.

    if(nargin<4) order=128; end
    if(nargin<5) fs=44100; end
    
    figure(); hold on; axa = gca;
    figure(); hold on; axb = gca;
    
    % set up some parameters
    overlap=0.75;
    window = hamming(order,'periodic')';
    window = ones(1,order);

    % generate pure white noise (using rand)
    white = white_generator(nsec,fs);
    
    % implement our band-pass filter as a low-pass filter which has been
    % shifted up to our mid-frequency band.
    midf = (highf+lowf)/2;
    bandwidth = highf-lowf;
    % make the filter
    r = bandwidth/fs;
    t = (1:order) - order/2 - 0.5;
    % the filter has it's own windowing as well.
    lpass_ts = sinc(r*t).*r; %.*hamming(order,'periodic')';
    %B = fir1(order-2,[lowf highf]/(fs/2));

    % you could write a loop which slides some window forward with some
    % overlap, perform ffts on the white noise, applies filtering in the
    % frequency domain, and iffts back to make our data, but that would be
    % slow(ish) in matlab.  Instead arrange our data into matrices and do
    % it all at once.
    [~,chunk_indexes] = gen_overlap_windows(white.data,order,overlap);
    nchunks = size(chunk_indexes,1);
    WFM.data = zeros(1,chunk_indexes(end));
    window = hamming(order,'periodic')';
    cfreqs = linspace(0,fs-1/fs,order) + 1/fs/2; % in Hz
    periods = (1./cfreqs); % in seconds
    nnew_pts = round((1-overlap)*order);
    phase_per_step = (1/fs*nnew_pts) ./ periods .* (2*pi); % in radians
    for jchunk=1:nchunks
        wspec = fft(window.* white.data(chunk_indexes(jchunk,:)));
        %heterodyne_ts = cos((chunk_indexes(jchunk,:))/fs * midf*2*pi);
        heterodyne_ts = cos((1:order)/fs * midf*2*pi);
        bpass_ts = heterodyne_ts .* lpass_ts;
        bpass_ts = lpass_ts;
        bpass_spec = fft(bpass_ts,order);
        % apply the correct phase adjustment to the filter for this time
        % step.
        plot(axb,real(ifft(bpass_spec)),'r');
        bpass_spec = bpass_spec .* exp(1j.*phase_per_step.*jchunk);
        plot(axb,real(ifft(bpass_spec)));
        
        filt_spec = wspec .* bpass_spec;
        tmp = real(ifft(filt_spec));
        plot(axa,chunk_indexes(jchunk,:),tmp);
        WFM.data(chunk_indexes(jchunk,:)) = tmp;
    end
    
    % frequency-domain of unfiltered white noise.
    white_spec = specgram(white.data,order,overlap,0,window);
    % the heterodyne used to shift our filter up to our band.
    heterodyne_ts = sin((chunk_indexes-1)/fs * midf*2*pi);
    % time-domain multiply shifts low-pass up to band-pass
    full_filt = heterodyne_ts.*repmat(lpass_ts,[size(white_spec.data,1),1]);
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