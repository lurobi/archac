function output_data = play_and_record(input_data)

    samplerate = 44100;
    p = audioplayer(input_data,samplerate);
    r = audiorecorder(samplerate,16,1);
    record(r);
    pause(2);
    playblocking(p);
    pause(5);
    stop(r);
    output_data = getaudiodata(r);
    
    specgram(output_data,2048,0.5,1);
end