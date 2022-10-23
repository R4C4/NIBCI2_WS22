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
channel_labels = ["FC4", "FC1", "FCz", "FC2", "FC3", "C5", "C3", "C1",...
    "Cz", "C2", "C4", "C6", "CP3", "CPz", "CP4", "Pz"];
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
%[C3; Cz; C4] from data
eeg_lapl = filter_laplacian(eeg_data, channel_labels);