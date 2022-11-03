%%
clear, close all, clc
% Load Data into files
homedir = fileparts(mfilename('fullpath'));
cd(homedir)
addpath(genpath('../../'))

trial_data_location="999_recorded_data/";
filename = "trial_data_120.xdf";
data = load_xdf(trial_data_location + filename, 'Verbose', true);

%Check if this information fits with real streams
%fields: info, segments, time_series, time_stamps
usbAmp = data{1};
channels = {'FC4', 'FC1', 'FCz', 'FC2', 'FC3', 'C5', 'C3', 'C1', ...
    'Cz', 'C2', 'C4', 'C6', 'CP3', 'CPz', 'CP4', 'Pz'};
c_labels = containers.Map(channels, 1:length(channels));

markers = data{2};
%fields: info, time_series, stamps
%%
eeg_times = usbAmp.time_stamps;
fs = str2double(usbAmp.info.nominal_srate);

%%Bandpass window filter settings
filter_order = 4;
h_bp = create_online_fbfilt('butter',filter_order,[0.3 35],fs);
usbAmp.time_series = filtfilt(h_bp.sosMatrix,h_bp.ScaleValues , ...
    double(usbAmp.time_series)')';

%Just get class labels here for plots
BCIpar = set_bciparadigm_parameters_twoclass_mi;
classes = convertCharsToStrings(BCIpar.cues.class_labels);

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
%% Spatial Filtering
%[C3; Cz; C4] from data
eeg_lapl = filter_laplacian(usbAmp.time_series, c_labels);
eeg_lapl_epoched = filter_laplacian(eegdata_epoched, c_labels);
%%Split in Calibration and test data
n_max = size(eeg_lapl_epoched,3);
n_cal = floor(2/3*n_max);
calibration_set = eeg_lapl_epoched(:,:,1:n_cal);
calibration_labels = valid_labels(1:n_cal);
test_set = eeg_lapl_epoched(:,:,n_cal+1:n_max);
test_labels = valid_labels(n_cal+1:n_max);

%% ERDS-MAPS
[~, starts] = ismembertol(t_markers(1:n_cal), usbAmp.time_stamps, 1e-6);
erds_header.SampleRate = fs;
erds_header.TRIG = starts';
erds_header.Classlabel = calibration_labels;
erds_borders = [2 35];
%Turn off sig boost option if you want to see complete map
cond = [1 2];
erds_calc = calcErdsMap(eeg_lapl', erds_header, ...
                t_lim, erds_borders, 'heading',"ERDS Maps", ...
                'method', 'bp', 'alpha', 0.05, ...
                'ref', [-2 -1], 'refmethod', 'trial',...
                'cue', 0, 'class', cond, 'sig', 'boot');
plotErdsMap(erds_calc);

%% PSD
plot_psd(calibration_set, classes, calibration_labels, fs);
% Known bands
% alpha_band = 4-12 Hz
% beta_band = 13-30 Hz
% mu_rythm = 8-12 Hz
bands = [[4, 8];[6, 10];[24, 28];[26, 30]];%Hz

%% Feature Extraction (Bandpass then CSP, then Bandpower Calculation
% Of features x channels x trials
bandpower_features = feature_extraction(calibration_set,...
    calibration_labels, bands, filter_order, fs);

FEATURE_DIM = 1;
CHANNEL_DIM = 2;
TRIAL_DIM = 3;

%% Model Selection 
%Compare Between 2 Features vs 4 Features
model_accuracies = size(2, size(bandpower_features, CHANNEL_DIM));
best_bands=[[6, 10];[24, 28]]; % Band that proved most significand in ERDS
models = {1:4, [2,3]}; %Index of bands to be used for feature extraction
selected_features = {bandpower_features(models{1}, :, :), ...
                     bandpower_features(models{2}, :, :)};
for channel=1:size(bandpower_features,CHANNEL_DIM)
    model_accuracies(1, channel) = LDA(selected_features{1}, ...
        calibration_labels, channel);    
    model_accuracies(2, channel) = LDA(selected_features{2}, ...
        calibration_labels, channel);
end
%Max value of average over channels
[~, best_model_idx] = max(mean(model_accuracies,2));
selected_bands_idx = models{best_model_idx};


% Manually select bands (manual tuning) here
selected_bands = bands(selected_bands_idx,:);
best_features = selected_features{selected_bands_idx};
bandpower_features_test = feature_extraction(test_set,...
    test_labels, selected_bands, filter_order, fs);

%get accuracy of test set with best features
total_accuracy = size(1,size(bandpower_features_test,CHANNEL_DIM)); 
for channel=1:size(bandpower_features_test,CHANNEL_DIM)
    X_train=squeeze(best_features(:,channel,:))';
    X_test=squeeze(bandpower_features_test(:,channel,:))';
    %Train Model on all Calibration data
    model_lda = lda_train(X_train,calibration_labels);
    %Evaluate Accuracy on test data
    [predicted_classes, ~, ~] = lda_predict(model_lda, X_test);
    total_accuracy(channel)= sum(predicted_classes==test_labels)...
        /length(test_labels);
end
total_accuracy
    
    