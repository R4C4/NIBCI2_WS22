function [signal_bandpower] = get_bandpower(data)
% The function returns the bandpower for each channel and each
% epoch an an array with the size channel x epoches
%data: Input data in the fromat channels x values x epochs
    signal_bandpower = squeeze(log10(var(data,0,2)));
end



