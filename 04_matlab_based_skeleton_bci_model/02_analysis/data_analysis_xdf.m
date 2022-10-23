%%
clear, close all, clc
% Load Data into files
homedir = fileparts(mfilename('fullpath'));
cd(homedir)
addpath(genpath('../../'))

trial_data_location="999_recorded_data/";
filename = "trial_data.xdf";
data = load_xdf(trial_data_location + filename, 'Verbose', true);

%Check if this information fits with real streams
usbAmp = data{1};
channels = ["FC4", "FC1", "FCz", "FC2", "FC3", "C5", "C3", "C1", ...
    "Cz", "C2", "C4", "C6", "CP3", "CPz", "CP4", "Pz"];
channel_labels = containers.Map(channels, 1:length(channels));
%fields: info, segments, time_series, time_stamps
markers = data{2};
%fields: info, time_series, stamps
%%
eeg_data = double(usbAmp.time_series);
eeg_times = usbAmp.time_stamps;
fs = str2double(usbAmp.info.nominal_srate);

%Bandpass window filter settings
Wn = [0.3/(fs/2) 35/(fs/2)];%Hz
filter_order = 4;

eeg_data = filter_bandpass(eeg_data,filter_order, Wn);

%Different approach, choose theoretical epoch size
%BCIpar = set_bciparadigm_parameters_twoclass_mi;
%wlength = (BCIpar.times.time_mi + BCIpar.times.time_cue  ...
%    + BCIpar.times.time_pre_cue)*fs;

epoched_data = extract_epochs(eeg_data, eeg_times, markers);

[reject_epoch, reject_chann] = perform_outlier_rejection(epoched_data);

if ~isempty(reject_epoch)
    valid_epochs = ~ismember(1:size(epoched_data,3),reject_epoch);
    epoched_data = epoched_data(:,:,valid_epochs);
end

%[C3; Cz; C4] from data
eeg_lapl = filter_laplacian(epoched_data, channel_labels);
