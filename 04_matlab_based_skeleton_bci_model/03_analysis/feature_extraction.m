function bpower_csp_eeg = feature_extraction(calibration_set,...
    calibration_labels, band, filter_order, csp_features, fs)  
    
    % Concatenatec CSP channels basically
    csp_signal = [];
    for k_band=1:size(band,1)
        % Filter with band
        h_bp = create_online_fbfilt('butter',filter_order, ...
                                     band(k_band,:),fs);       
        cal_signal_conc = concatenate_epochs(calibration_set);        
        cal_signal_conc = filtfilt(h_bp.sosMatrix, ...
               h_bp.ScaleValues, cal_signal_conc')';
           
        %Bring back into epoched state   
        bp_eeg_data = reshape(cal_signal_conc, size(calibration_set));
        
        csp_filters = filter_csp(bp_eeg_data, calibration_labels, ...
                                 csp_features);
        csp_signal_band = csp_filters'*cal_signal_conc;
        csp_signal = cat(1, csp_signal, csp_signal_band);
        % Features x Channels x Trials
    end
    % Reshape to be epoched data
    original_dims = size(calibration_set);
    csp_signal=reshape(csp_signal, ...
        [size(csp_signal,1),original_dims(2:end)]);
    %Features x Trials
    bpower_csp_eeg = get_bandpower(csp_signal);    
end

function concatenated_sig = concatenate_epochs(epoched_signal)
    concatenated_sig =  reshape(epoched_signal, ...
            size(epoched_signal,1), ...
            size(epoched_signal,2)*size(epoched_signal,3));
end