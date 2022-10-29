function [signal_bandpower] = get_bandpower(data)
% The function returns the bandpower (in dB) for each channel and each
% epoch an an array with the size channel x epoches
%
%data: Input data in the fromat channels x values x epoches
%frequeny_range: frequency range specified as a two-element vector
%fs: samplinbg frequency
    signal_bandpower = zeros(size(data,1), size(data,3));
    for k_epoch=1:size(data, 3)
        trial_k = squeeze(data(:,:,k_epoch));
        signal_bandpower(:,k_epoch) = 20*log10(mean(trial_k.^2, 2));
    end
end



