function plot_psd(epoched_signal, classes, labels, fs)
%PSD Estimation
    
    psd_total = [];
    for cond=1:length(classes)
       signal = mean(epoched_signal(:,:,labels == cond),3);
       psd = 20*log10(pwelch(signal',fs)');
       psd_total = cat(3, psd_total, psd);
    end

    figure
        subplot(1,3,1)
        plot_all_conds(psd_total, 1)
        title('C3')
        subplot(1,3,2)
        plot_all_conds(psd_total, 2)
        title('Cz')
        subplot(1,3,3)
        plot_all_conds(psd_total, 3)
        title('C4')   
        sgtitle('PSD of EEG channels');
        legend(classes);
        hold off
    end

function plot_all_conds(psd, channel)
    hold on
    grid on
    for i = 1:size(psd,3)
        plot(psd(channel, :, i));
    end
    ylabel('dB/Hz')
    xlabel('Frequency (Hz)')
end
