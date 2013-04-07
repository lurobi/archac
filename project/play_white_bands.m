function play_white_bands(nsec)

    WHITE = white_generator(nsec);
    
    bands = [0    128;
             128  256;
             256  512;
             512  1024;
             1024 2048;
             2048 4096;
             4096 8192;
             8192 16384;
             16384 44100/2;];
     nbands = size(bands,1);
     time_ind = zeros(nbands,2);
     time_ind(1,1) = 1;
     
     spacing_sec = 1;
     all_ts = zeros(1,nbands*WHITE.fs);
     band_replicas = {};
     for jband = 1:nbands
         band_replicas{jband} = band_pass(WHITE,bands(jband,1),bands(jband,2),1);
         time_ind(jband,2) = time_ind(jband,1) + band_replicas{jband}.nsamp -1;
         if(jband<nbands)
             time_ind(jband+1,1) = time_ind(jband,2)+spacing_sec*WHITE.fs;
         end
         all_ts(time_ind(jband,1):time_ind(jband,2)) = band_replicas{jband}.data;
     end
     
     ALL_BANDS = standardize_wfm(all_ts);
     ALL_REC = play_and_record(ALL_BANDS,1,0);
     ALL_REC.WFM = ALL_BANDS;
     all_resp = repcor(ALL_BANDS,ALL_REC,0);
     [~,joff] = max(all_resp);
     fs = WHITE.fs;
     for jband = 1:nbands
         start_ind = joff+time_ind(jband,1)-round(0.25*fs);
         stop_ind  = joff+time_ind(jband,2)+round(spacing_sec*fs);
         band_rec{jband} = standardize_wfm(ALL_REC.data(start_ind:stop_ind));
         band_rec{jband}.WFM = band_replicas{jband};
         resp(jband,:) = repcor(band_replicas{jband},band_rec{jband},1);
         set(gcf,'Name',sprintf('Band %.0f to %.0f',bands(jband,1),bands(jband,2)));
     end
     
     figure();imagesc(dB20(resp));
end