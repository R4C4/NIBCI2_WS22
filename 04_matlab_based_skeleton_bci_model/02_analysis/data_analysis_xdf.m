%%
clear, close all, clc
% Load Data into files
homedir = fileparts(mfilename('fullpath'));
cd(homedir)
addpath(genpath('../../'))

trial_data_location="999_recorded_data/";
filename = "trial_data_120_real.xdf";
data = load_xdf(trial_data_location + filename, 'Verbose', true);

%Check if this information fits with real streams
%fields: info, segments, time_series, time_stamps
usbAmp = data{1};
channels = {'FC4', 'FC1', 'FCz', 'FC2', 'FC3', 'C5', 'C3', 'C1', ...
    'Cz', 'C2', 'C4', 'C6', 'CP3', 'CPz', 'CP4', 'Pz'};
c_labels = containers.Map(channels, 1:length(channels));

markers = data{3};
%fields: info, time_series, stamps
%%
eeg_times = usbAmp.time_stamps;
fs = str2double(usbAmp.info.nominal_srate);


%%Bandpass window filter settings
filter_order = 4;
h_bp = create_online_fbfilt('butter',filter_order,[0.3 35],fs);
usbAmp.time_series = filtfilt(h_bp.sosMatrix,h_bp.ScaleValues , ...
    double(usbAmp.time_series)')';

d = fdesign.notch(filter_order, 50/(2*fs), 10);
h_notch = design(d,'SystemObject',true);
usbAmp.time_series=filtfilt(h_notch.SOSMatrix, h_notch.ScaleValues, ...
    usbAmp.time_series')';

%Just get class labels here for plots
BCIpar = set_bciparadigm_parameters_twoclass_mi;
classes = convertCharsToStrings(BCIpar.cues.class_labels);

%Plot EEG for visual inspection
%eeg_and_markers_scrollplot(usbAmp.segments.duration/BCIpar.nTrials, ...
%    usbAmp, markers)

%% Epoch data, Perform outlier rejection
% Epoched data is channel x time x trial
t_lim = [-3 5];
[t_epoch, eegdata_epoched, t_markers] =epoch_data_xdf_streams(...
    usbAmp, markers,"cue_start", t_lim); 
[reject_epoch, reject_chann] = perform_outlier_rejection(eegdata_epoched);
if ~isempty(reject_epoch)
    valid_epochs = ~ismember(1:size(eegdata_epoched,3),reject_epoch);
    eegdata_epoched = eegdata_epoched(:,:,valid_epochs);
    t_markers = t_markers(valid_epochs);
    valid_labels = BCIpar.cues.class_list(valid_epochs);
end

%%Split in Calibration and test data
[calib_data, calib_labels, test_data, test_labels] = ...
    split_data(eegdata_epoched, valid_labels, 2/3);

%% ERDS-MAPS
% Laplace Derivations to 3 x epoch_time x epoch
eeg_lapl_calibration = filter_laplacian(calib_data, c_labels);
plot_erds_per_cond(eeg_lapl_calibration, fs, t_lim, calib_labels, 1);
plot_erds_per_cond(eeg_lapl_calibration, fs, t_lim, calib_labels, 2);

%% PSD
% plot_psd(eeg_lapl_calibration, classes, calib_labels, fs);
% Known bands
% alpha_band = 4-12 Hz
% beta_band = 13-30 Hz
% mu_rythm = 8-12 Hz
bands_alpha = [[4, 8];[6, 10]; [8,12]];%Hz
bands_beta =  [[18 22];[24, 28];[26, 30]];%Hz

[m, n] = ndgrid(1:size(bands_alpha), 1:size(bands_beta));
bands =[bands_alpha(m(:),:),  bands_beta(n(:),:)];

% % Of dim permutations x 2 x 2 (ie bands(1,:,:) is the first combination
% % also [bands_alpha(1,:); bands_beta(1,:)]
% bands = reshape(bands, size(bands,1), size(bands,2)/2, 2);
% 
% %% Feature Extraction (Bandpass then CSP, then Bandpower Calculation
% % Of features x 2 x trials
% bandpower_features = feature_extraction(calibration_set,...
%     calibration_labels, bands, filter_order, fs);
% 
% FEATURE_DIM = 1;
% CHANNEL_DIM = 2;
% TRIAL_DIM = 3;
% 
% %% Model Selection 
% %Compare Between 2 Features vs 4 Features
% model_accuracies = size(2, size(bandpower_features, CHANNEL_DIM));
% best_bands=[[6, 10];[24, 28]]; % Band that proved most significand in ERDS
% models = {[2,3], [1,4], [2,4], [1,3]}; %Index of bands to be used for feature extraction
% selected_features = {bandpower_features(models{1}, :, :), ...
%                      bandpower_features(models{2}, :, :), ...
%                      bandpower_features(models{3}, :, :), ...
%                      bandpower_features(models{4}, :, :)};
% for channel=1:size(bandpower_features,CHANNEL_DIM)
%     model_accuracies(1, channel) = LDA(selected_features{1}, ...
%         calibration_labels, channel);    
%     model_accuracies(2, channel) = LDA(selected_features{2}, ...
%         calibration_labels, channel);
% end
% %Max value of average over channels
% [~, best_model_idx] = max(mean(model_accuracies,2));
% selected_bands_idx = models{best_model_idx};
% 
% 
% % Manually select bands (manual tuning) here
% selected_bands = bands(selected_bands_idx,:);
% best_features = selected_features{selected_bands_idx};
% bandpower_features_test = feature_extraction(test_set,...
%     test_labels, selected_bands, filter_order, fs);
% 
% %get accuracy of test set with best features
% total_accuracy = size(1,size(bandpower_features_test,CHANNEL_DIM)); 
% for channel=1:size(bandpower_features_test,CHANNEL_DIM)
%     X_train=squeeze(best_features(:,channel,:))';
%     X_test=squeeze(bandpower_features_test(:,channel,:))';
%     %Train Model on all Calibration data
%     model_lda = lda_train(X_train,calibration_labels);
%     %Evaluate Accuracy on test data
%     [predicted_classes, ~, ~] = lda_predict(model_lda, X_test);
%     total_accuracy(channel)= sum(predicted_classes==test_labels)...
%         /length(test_labels);
% end
% total_accuracy
    
    