function laplacian_filtered = filter_laplacian(...
    signal, ...
    channel_labels)
%FILTER_LAPLACIAN spatial laplacian filter derivation for C3, Cz, C4
%   filtered_signal = filter_laplacian(signal, channel_labels)
%   Performs a small laplacian derivation of signal using the channel_labels
%   information
    c = containers.Map(channel_labels, 1:size(signal,1));
    C3 = signal(c('C3'), :) - 1/4*(signal(c('FC3'),:) + ...
         signal(c('CP3'),:) +  signal(c('C5'),:) +  signal(c('C1'),:));
    Cz = signal(c('Cz'), :) - 1/4*(signal(c('FCz'),:) + ...
         signal(c('CPz'),:) +  signal(c('C1'),:) +  signal(c('C2'),:));
    C4 = signal(c('C4'), :) - 1/4*(signal(c('FC4'),:) + ...
         signal(c('CP4'),:) +  signal(c('C2'),:) +  signal(c('C6'),:));
    
    laplacian_filtered=[C3; Cz; C4];

end

