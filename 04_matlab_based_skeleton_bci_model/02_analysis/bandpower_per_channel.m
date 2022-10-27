function [signal_bandpower] = bandpower_per_channel(data,frequeny_range, fs)
% The function returns the bandpower (in dB) for each channel and each
% epoch an an array with the size channel x epoches
%
%data: Input data in the fromat channels x values x epoches
%frequeny_range: frequency range specified as a two-element vector
%fs: samplinbg frequency

data_dimension = size(data);
channels = data_dimension(1);
epoches = data_dimension(3);
signal_bandpower = zeros(channels, epoches);
for channel = 1:channels
    for epoche = 1:epoches
        signal_bandpower(channel, epoche) = 20*log10(bandpower(data(channel,:,epoche), fs, frequeny_range));
    end
end 
end



