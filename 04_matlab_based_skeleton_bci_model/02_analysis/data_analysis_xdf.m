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

%Bandpass window filter settings
filter_order = 4;
%Wn = [0.3/(2*fs) 35/(2*fs)];
%eeg_data = filter_bandpass(eeg_data,filter_order, Wn);

h_bp = create_online_fbfilt('butter',filter_order,[0.3 35],fs);
usbAmp.time_series = filtfilt(h_bp.sosMatrix,h_bp.ScaleValues , ...
    double(usbAmp.time_series)')';

%Different approach, choose theoretical epoch size
BCIpar = set_bciparadigm_parameters_twoclass_mi;
classes = convertCharsToStrings(BCIpar.cues.class_labels);
%wlength = (BCIpar.times.time_mi + BCIpar.times.time_cue  ...
%    + BCIpar.times.time_pre_cue)*fs;

%epoched_data = extract_epochs(eeg_data, eeg_times, markers);
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

%[C3; Cz; C4] from data
eeg_lapl = filter_laplacian(usbAmp.time_series, c_labels);
eeg_lapl_epoched = filter_laplacian(eegdata_epoched, c_labels);

n_max = size(eeg_lapl_epoched,3);
n_cal = floor(2/3*n_max);
calibration_set = eeg_lapl_epoched(:,:,1:n_cal);
calibration_labels = valid_labels(1:n_cal);
test_set = eeg_lapl_epoched(:,:,n_cal+1:n_max);
test_labels = valid_labels(n_cal+1:n_max);


%ERDS-MAPS
[~, starts] = ismembertol(t_markers(1:n_cal), usbAmp.time_stamps, 1e-6);
erds_header.SampleRate = fs;
erds_header.TRIG = starts';
erds_header.Classlabel = calibration_labels;
erds_borders = [2 40];

%Turn off sig boost option if you want to see complete map
cond = [1 2];
erds_calc = calcErdsMap(eeg_lapl', erds_header, ...
                t_lim, erds_borders, 'heading',"ERDS Maps", ...
                'method', 'bp', 'alpha', 0.05, ...
                'ref', [-2 -1], 'refmethod', 'trial',...
                'cue', 0, 'class', cond, 'sig', 'boot');

plotErdsMap(erds_calc);
plot_psd(calibration_set, classes, calibration_labels, fs);


%Get band power
% alpha_band = 4-12 Hz
% beta_band = 13-30 Hz
% mu_rythm = 8-12 Hz

band = [[4, 8];[6, 10];[24, 28];[26, 30]];%Hz
bpower_csp_eeg_calibration = feature_extraction(calibration_set,...
    calibration_labels, band, filter_order, fs);

%Accuracies with 4 Features
for channel=1:size(bpower_csp_eeg_calibration,2)
    channel_accuracy_4(channel) = ... 
        LDA(bpower_csp_eeg_calibration,calibration_labels, channel);
    
    channel_accuracy_2(channel) = LDA(bpower_csp_eeg_calibration([2,3], :,:), ...
        calibration_labels, channel);

end
mean_accuracy_4=mean(channel_accuracy_4);
mean_accuracy_2=mean(channel_accuracy_2);

%are 4 or 2 features better for the accuracy
if mean_accuracy_2 > mean_accuracy_4
    best_band=[[6, 10];[24, 28]];
    bpower_csp_eeg_calibration=bpower_csp_eeg_calibration([2,3], :,:);
else
    best_band=band;
end

bpower_csp_eeg_test = feature_extraction(test_set,...
    test_labels, best_band, filter_order, fs);

%get accuracy of test set with best features
for channel=1:size(bpower_csp_eeg_test,2)
    X_train=squeeze(bpower_csp_eeg_calibration(:,channel,:));
    X_train = X_train';
    Y_train=calibration_labels;
    X_test=squeeze(bpower_csp_eeg_test(:,channel,:));
    X_test = X_test';
    Y_test=test_labels;
    model_lda = lda_train(X_train,Y_train);
    [predicted_classes, ~, ~] = lda_predict(model_lda,X_test);
    accuracy=sum(predicted_classes==Y_test)/length(Y_test);
end

    
    