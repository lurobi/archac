function REC = play_and_record(input_data,ntimes,spacing)
    if nargin<2, ntimes=[]; end
    if nargin<3, spacing=[]; end
    
    ii_prompt=0;
    
    WFM.fs = 44100;
    if ~isstruct(input_data) && numel(input_data) == 1
        % record ambient noise for N seconds.
        input_data = zeros(1,input_data*WFM.fs);
        ntimes=1; spacing=0;
    end
    
    prompts{1} = 'Repeat how many times?';
    if(isempty(ntimes))
        def_ans{1} = '1';
        ii_prompt = 1;
    else
        def_ans{1} = sprintf('%d',ntimes);
    end
    
    prompts{2} = 'Pause for N seconds between repeats:';
    if(isempty(spacing))
        def_ans{2} = '0';
        ii_prompt = 1;
    else
        def_ans{2} = sprintf('%f',spacing);
    end
    
    if(ii_prompt)
        out = inputdlg(prompts,'Play and Record',1,def_ans);
        if(isempty(out)), return; end
        ntimes = str2num(out{1});
        spacing = str2num(out{2});
    end
    
    WFM = standardize_wfm(input_data);
    
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
    
    nclip = numel(find(REC.data>.999));
    maxdata = max(abs(REC.data));
    if(nclip>0)
        fprintf('Warning, recording clipped %d samples!\n',nclip);
    elseif(maxdata<0.5)
        fprintf('Gain could be increased: max level=%.3f\n',maxdata);
    else
        fprintf('Recording good, max level=%.3f\n',maxdata);
    end
    
    repcor(WFM,REC);
    specgram(REC,512,0.25,1,'hamming');
    specgram(REC,4096,0.25,1,'hamming');
    
    REC.WFM = WFM;
    REC.spacing = spacing;
    REC.ntimes = ntimes;
    REC.recorded_time = now();
    
    REC = save_recording(REC);
end