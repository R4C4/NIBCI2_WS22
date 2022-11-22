classdef FeatureExtractor
    properties
        band
        filter_order
        fs
    end
    methods
        function obj = FeatureExtractor(band, filter_order, fs)
            obj.band = band;
            obj.filter_order = filter_order;
            obj.fs = fs;
        end
        function [csp_model, bpower_csp_eeg] = extract(obj, training_set, ...
                training_labels, csp_filter_selection)
                csp_signal = [];
                num_channels = size(training_set, 1);
                csp_model = zeros(num_channels, num_channels, ...
                    size(obj.band,1));
                for k_band = 1:size(obj.band,1)
                    current_band = obj.band(k_band,:);
                    signal_conc = concatenate_epochs(training_set);  
                    h_bp = create_online_fbfilt('butter', ...
                        obj.filter_order, current_band, obj.fs);
                    signal_conc = filtfilt(h_bp.sosMatrix, ...
                                    h_bp.ScaleValues, signal_conc')';
                    bp_eeg_data = reshape(signal_conc, ...
                        size(training_set));
                    csp_filters = filter_csp(bp_eeg_data, ...
                        training_labels);
                    csp_model(:,:,k_band) = csp_filters;
                    selected_csp = csp_filters(:,csp_filter_selection);
                    csp_signal_band = selected_csp'*signal_conc;
                    csp_signal = cat(1, csp_signal, csp_signal_band);
                end
                % Reshape to be epoched data
                original_dims = size(training_set);
                csp_signal=reshape(csp_signal, ...
                                [size(csp_signal,1),original_dims(2:end)]);
                %Features x Trials
                bpower_csp_eeg = get_bandpower(csp_signal);  
        end
        function bpower_csp_eeg = extract_test(obj, test_set, ...
                csp_model, csp_sel)
            csp_signal = [];
            for k_band = 1:size(obj.band,1)
                current_band = obj.band(k_band,:);
                signal_conc = concatenate_epochs(test_set);  
                h_bp = create_online_fbfilt('butter', ...
                    obj.filter_order, current_band, obj.fs);
                signal_conc = filtfilt(h_bp.sosMatrix, ...
                                h_bp.ScaleValues, signal_conc')';
                csp_filters = csp_model(:,csp_sel,k_band);
                csp_signal_band = csp_filters'*signal_conc;
                csp_signal = cat(1, csp_signal, csp_signal_band);
            end
            % Reshape to be epoched data
            original_dims = size(test_set);
            csp_signal=reshape(csp_signal, ...
                            [size(csp_signal,1),original_dims(2:end)]);
            %Features x Trials
            bpower_csp_eeg = get_bandpower(csp_signal);
        end
    end
end