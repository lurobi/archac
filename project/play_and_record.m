function REC = play_and_record(input_data,ntimes,spacing)

    if nargin<2, ntimes=1; end
    if nargin<3, spacing=0; end
    
    WFM = standardize_wfm(input_data);
    WFM.fs = 44100;

    zpad = zeros(1,spacing*(1/WFM.fs));
    wfm_padded = [];
    for jtimes=1:ntimes
        wfm_padded = [wfm_padded WFM.data];
        if(jtimes < ntimes)
            wfm_padded = [wfm_padded zpad];
        end
    end
    
    p = audioplayer(wfm_padded,WFM.fs);
    r = audiorecorder(WFM.fs,24,1);
    record(r);
    pause(2);
    playblocking(p);
    pause(5);
    stop(r);
    REC.data = getaudiodata(r);
    REC.nsamp = length(REC.data);
    REC.fs   = WFM.fs;
    REC.time_ax = linspace(0,REC.nsamp/REC.fs,REC.nsamp);
end