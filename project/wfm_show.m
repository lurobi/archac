function wfm_show(WFM,name)
if(nargin<2) name=''; end
WFM = standardize_wfm(WFM);
WFM.data = WFM.data/max(abs(WFM.data));
figure();
subplot(211)
SPEC = specgram(WFM,4096,.75,0,'hamming');
ii_take = 2:ceil(SPEC.fft_size/2);
tax = SPEC.scales{1};
fax = SPEC.scales{2}(ii_take)/1000;
db_data = dB20(abs(SPEC.data(:,ii_take)));
clims = [-50 0] + max(db_data(:));
imagesc(fax,tax,db_data);
set(gca,'Clim',clims);
xlabel('Frequency - kHz');
ylabel(SPEC.labels{1});
h = title(name);
set(h,'FontWeight','bold')
SPEC2 = specgram(WFM,1024,0.25,0,'hamming');
ii_take = 2:ceil(SPEC2.fft_size/2);
tax = SPEC2.scales{1};
fax = SPEC2.scales{2}(ii_take)/1000;
linavg_spec = dB10(mean(SPEC2.data(:,ii_take).^2,1));
hold on
plot(fax,-1*(linavg_spec-max(linavg_spec(:))),'m')


%colorbar();

subplot(212)
plot(WFM.time_ax,WFM.data);
set(gca,'Xlim',[0 1]);
set(gca,'Ylim',[-1.2, 1.2]);
xlabel('Time - Seconds');
ylabel('Amplitude');

 pos = [ 4.1875    2.5521    5.75    2.25];
 pos = [5.2813    2.9583    5.8333    3.1354]
 set(gcf,'Units','Inches','Position',pos);

end