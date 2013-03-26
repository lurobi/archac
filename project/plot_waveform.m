function plot_waveform(WFM)

   WFM = standardize_wfm(WFM);
   
   WFM.data = WFM.data - mean(WFM.data);
   
   figure();
   plot(WFM.time_ax,WFM.data);
   xlabel('Time - Seconds');
   ylabel('Sound Pressure - Counts');
   title('Time Series');
   
   figure();
   full_spec = 20*log10(abs(fft(WFM.data)));
   spec_ax   = linspace(0,WFM.fs,WFM.nsamp);
   ii_take   = 2:WFM.nsamp;
   %full_spec = full_spec - max(full_spec);
   plot(spec_ax(ii_take),full_spec(ii_take));
   xlabel('Frequency - Hz');
   ylabel('Energy Level - Counts (dB)');
   title('Full Resolution Spectrum')
   
   figure();
   time_extended = [WFM.data, zeros(1,WFM.nsamp-1)];
   auto_spec = fft(time_extended) .* conj(fft(time_extended));
   auto_corr = ifft(auto_spec);
   auto_spec = auto_spec(1:WFM.nsamp);
   auto_corr = auto_corr(1:WFM.nsamp);
   subplot(211);
   plot(WFM.time_ax,auto_corr);
   xlabel('Delay - Seconds');
   ylabel('Auto-Correlation - Counts');
   subplot(212);
   ii_take = 2:WFM.nsamp;
   spec_ax   = linspace(0,WFM.fs,WFM.nsamp);
   spec_level = 20*log10(abs(auto_spec(ii_take)));
   plot(spec_ax(ii_take),spec_level);
   
    
end