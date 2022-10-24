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


%ERDS-MAPS
[~, starts] = ismembertol(t_markers, usbAmp.time_stamps, 1e-6);
erds_header.SampleRate = fs;
erds_header.TRIG = starts';
erds_header.Classlabel = valid_labels;
erds_borders = [2 40];

%Turn off sig boost option if you want to see complete map
cond = [1 2];
erds_calc = calcErdsMap(eeg_lapl', erds_header, ...
                t_lim, erds_borders, 'heading',"ERDS Maps", ...
                'method', 'bp', 'alpha', 0.05, ...
                'ref', [-2 -1], 'refmethod', 'trial',...
                'cue', 0, 'class', cond, 'sig', 'boot');

plotErdsMap(erds_calc);

plot_psd(eeg_lapl_epoched, classes, valid_labels, fs);
