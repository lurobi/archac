function WFM = tone_seq_generator(low,high,duration,seq)
    
    fs = 44100;
    time_ax = 0:1/fs:duration;
    norm_freqs = double(seq - min(seq));
    norm_freqs = norm_freqs/max(norm_freqs);
    norm_freqs = norm_freqs*(high-low) + low;
    
    all_tones=[];
    nrampup = round(duration*0.2*fs);
    nrampdown = round(duration*0.2*fs);
    wstart=0.5+sin(linspace(-pi/2,pi/2,nrampup))/2;
    wend=0.5+sin(linspace(pi/2,-pi/2,nrampdown))/2;
    window = ones(1,length(time_ax));
    window(1:nrampup)=wstart;
    window(end-nrampdown+1:end)=wend;
    for jtone=1:length(seq)
        this_tone = window.*cos(2*pi*norm_freqs(jtone).*time_ax);
        all_tones = [all_tones this_tone];
    end
    
    WFM = standardize_wfm(all_tones);
end