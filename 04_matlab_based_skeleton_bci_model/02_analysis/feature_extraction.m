function bpower_csp_eeg = feature_extraction(calibration_set,...
    calibration_labels, band, filter_order, fs)
    
    csp_filters = filter_csp(calibration_set, calibration_labels);
    eeg_lapl_epoched_dims=size(calibration_set);
    bpower_csp_eeg=zeros(size(band,1),eeg_lapl_epoched_dims(1),...
        eeg_lapl_epoched_dims(3));

    for k_band=1:size(band,1)

        b= butter(filter_order, band(k_band,:)/(2*fs),'bandpass');
        eeg_lapl_filt_bp = zeros(size(calibration_set));
        eeg_lapl_csp=zeros(size(calibration_set));

        for k_epochs=1:size(calibration_set,3)    
            eeg_lapl_filt_bp(:,:,k_epochs) = ...
                filtfilt(b, 1,calibration_set(:,:,k_epochs)')';
            eeg_lapl_csp(:,:,k_epochs) = ...
                csp_filters'*eeg_lapl_filt_bp(:,:,k_epochs);

        end
        % Features x Channels x Trials
        bpower_csp_eeg(k_band,:,:) = get_bandpower(eeg_lapl_csp);
    end
end