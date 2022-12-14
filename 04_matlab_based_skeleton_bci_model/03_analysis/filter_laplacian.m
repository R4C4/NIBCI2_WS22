function laplacian_filtered = filter_laplacian(signal, c_labels)
%FILTER_LAPLACIAN spatial laplacian filter derivation for C3, Cz, C4
%   filtered_signal = filter_laplacian(signal, channel_labels)
%   Performs a small laplacian derivation of signal using the channel_labels
%   information
    c3_near = [c_labels('FC3'), c_labels('C1'), c_labels('C5'), ...
        c_labels('CP3')];
    cz_near = [c_labels('FCz'), c_labels('C1'), c_labels('C2'), ...
        c_labels('CPz')];
    c4_near = [c_labels('FC4'), c_labels('C2'), c_labels('C6'), ...
        c_labels('CP4')];
    laplacian_filtered = [...
        compute_laplacian_derivation(signal,c_labels('C3'), c3_near);...
        compute_laplacian_derivation(signal,c_labels('Cz'), cz_near);...
        compute_laplacian_derivation(signal,c_labels('C4'), c4_near);];

end

