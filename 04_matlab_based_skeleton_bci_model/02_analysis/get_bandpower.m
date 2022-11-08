function [signal_bandpower] = get_bandpower(data)
% The function returns the bandpower (in dB) for each channel and each
% epoch an an array with the size channel x epoches
%
%data: Input data in the fromat channels x values x epoches
%frequeny_range: frequency range specified as a two-element vector
%fs: samplinbg frequency
    signal_bandpower = squeeze(20*log10(var(data,0,2)));
end



