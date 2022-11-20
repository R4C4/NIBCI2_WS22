%%
clear, close all, clc
% Load Data into files
homedir = fileparts(mfilename('fullpath'));
cd(homedir)
addpath(genpath('../../'))

subject = 'chris';
trial_path = fullfile(homedir, '..', '..', '999_recorded_data', subject);
trial_data_location  = fullfile(trial_path, 'trial_data_120_real.xdf') ;
data = load_xdf(trial_data_location, 'Verbose', true);

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

d = fdesign.notch('N,F0,Q,Ap',filter_order,2*50/fs,10,1);
h_notch = design(d,'SystemObject',true);
usbAmp.time_series=filtfilt(h_notch.SOSMatrix, h_notch.ScaleValues, ...
    usbAmp.time_series')';

%Just get class labels here for plots
BCIpar = set_bciparadigm_parameters_twoclass_mi;
classes = convertCharsToStrings(BCIpar.cues.class_labels);

%Plot EEG for visual inspection
eeg_and_markers_scrollplot(usbAmp.segments.duration/BCIpar.nTrials, ...
    usbAmp, markers)

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
%plot_erds_per_cond(eeg_lapl_calibration, fs, t_lim, calib_labels, 1);
%plot_erds_per_cond(eeg_lapl_calibration, fs, t_lim, calib_labels, 2);

%% PSD
% plot_psd(eeg_lapl_calibration, classes, calib_labels, fs);
% Known bands
% alpha_band = 4-12 Hz
% beta_band = 13-30 Hz
bands_alpha = [[4, 8];[6, 10]; [8,12]];%Hz
bands_beta =  [[18 22];[24, 28];[26, 30]];%Hz

[m, n] = ndgrid(1:size(bands_alpha), 1:size(bands_beta));
bands =[bands_alpha(m(:),:),  bands_beta(n(:),:)];

% Of dim permutations x 2 x 2 (ie bands(1,:,:) is the first combination
% also [bands_alpha(1,:); bands_beta(1,:)]
bands = reshape(bands, size(bands,1), size(bands,2)/2, 2);

%% Select cut off frequencies bands
% set CSP filter number to just one

% %% Model Selection 
% Select bands with Cross Validation
model_accuracies = zeros(1, size(bands, 1));
for bidx = 1:size(bands,1)
    band_combination = squeeze(bands(bidx,:, :))';
    bpower_features = feature_extraction(calib_data, calib_labels, ...
        band_combination, filter_order, 1, fs);
    model_accuracies(bidx) = perform_cross_validation(bpower_features, ...
                                    calib_labels, 5, 10);
end
 [~, best_model_bands_idx] = max(model_accuracies);
 best_bands = squeeze(bands(bidx,:,:))';
fprintf("Found Best Performing model at Bands \n");
fprintf("%d-%d and %d-%d Hz \n",best_bands');
fprintf("With accuracy %.2f \n\n", model_accuracies(best_model_bands_idx));

% Select number of CSP filters using cross validation

%1 CSP filter means first and last, 2 filters means 2 first and 2 last
csp_filters = [1, 2];
model_accuracies = zeros(1, size(csp_filters, 2));
for k_csp = 1:length(csp_filters)
   bpower_features = feature_extraction(calib_data, calib_labels, ...
        best_bands, filter_order, csp_filters(k_csp), fs);
   model_accuracies(k_csp) = perform_cross_validation(bpower_features, ...
                                calib_labels, 5, 10);
end
[~, best_model_csp_idx] = max(model_accuracies);
best_num_csp = csp_filters(best_model_csp_idx);
fprintf("Found Best Performing csp filtering with \n");
fprintf("%d filters \n",2*best_num_csp);
fprintf("With accuracy %.2f \n\n", model_accuracies(best_model_csp_idx));

%Evaluate Model performance with Test data
X_train = feature_extraction(calib_data, calib_labels, ...
        best_bands, filter_order, best_num_csp, fs)';
X_test = feature_extraction(test_data, test_labels, ...
        best_bands, filter_order, best_num_csp, fs)';
    
%Train Model on all Calibration data
model_lda = lda_train(X_train,calib_labels);
%Evaluate Accuracy on test data
[predicted_classes, ~, ~] = lda_predict(model_lda, X_test);
total_accuracy = sum(predicted_classes==test_labels)...
    /length(test_labels);

fprintf("Performance Accuracy on test set was %.2f\n", total_accuracy);

store.csp_model_cal=123;
store.csp_filter_selection=1;
store.model_lda_cal.w=model_lda.w;
store.model_lda_cal.classlabels=model_lda.classlabels;
store.selected_fb_filters=best_bands;
store.fb_filter_order=filter_order;
store.fb_filter_type='butter';
store.fs_eeg=fs;
store.movavg_dur=0.1; %TODO:no idea what this should be

cd(homedir)
cd('../../')
save(fullfile(trial_path, 'csp_and_slda_calibration_models.mat'),'store');

    
    