function REC = play_and_record(input_data)

    WFM = standardize_wfm(input_data);
    p = audioplayer(WFM.data,WFM.fs);
    r = audiorecorder(WFM.fs,16,1);
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