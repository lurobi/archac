function WFM = white_generator(nseconds,fs)
    if(nargin<2) fs = 44100; end
    WFM.fs = fs;
    WFM.nsamp = round(nseconds*fs);
    WFM.data = rand([1,WFM.nsamp]) - 0.5;
    WFM = standardize_wfm(WFM);
end