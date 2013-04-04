function WFM = log_sweep_generator(f1,f2,time_period)

    fs = 44100; % should we oversample perhaps?
    WFM.fs = fs;
    WFM.nsamp = fs*time_period;
    WFM.time_ax = linspace(0,time_period,WFM.nsamp);
    fc_vs_time = logspace(1,log10(f2-f1),WFM.nsamp) + f1;
    %fc_vs_time = linspace(f1,f2x,WFM.nsamp);
    WFM.data = sin(fc_vs_time.*(2.*pi).*WFM.time_ax);
    %WFM = standardize_wfm(WFM);
    WFM.data = sinesweep(f1,f2,time_period,WFM.fs,1,0,0);
end

function signal = sinesweep( ...
    start, ...
    finish, ...
    seconds, ...
    sample_rate, ...
    amplitude, ...
    initial_phase, ...
    dc ...
)
% sinesweep returns a single-channel sine logarithmic sweep
%     start: starting frequency in Hz
%     finish: ending frequency in Hz
%     seconds: duration of sweep in seconds
%     samplerate: samples per second
%     amplitude: amplitude
%     initial_phase: starting phase
%     dc: dc

time = 0 : 1 / sample_rate : seconds;
frequency = exp( ...
    log(start) * (1 - time / seconds) + ...
    log(finish) * (time / seconds) ...
);

phase = 0 * time;
phase(1) = initial_phase;
for i = 2:length(phase)
    phase(i) = ...
        mod(phase(i - 1) + 2 * pi * frequency(i) / sample_rate, 2 * pi);
end

signal = amplitude * sin(phase) + dc;

end