
clear, close, clc

%% EEG settings
fs_eeg = 256;
n_eeg_chans = 16;
replay_real_eeg = true; % flag to decide whether to replay previously recorded eeg or generate "fake" one

%% Add libraries and toolboxes to the path
toolbox_path = '../../99_library_and_toolboxes';
current_path = pwd;

addpath(genpath(toolbox_path));
lib = lsl_loadlib();

%% Generate the EEG to stream (or load it)

% eeg parameters
nsamples_eegchunk = 16;
loop_fs = round(fs_eeg / nsamples_eegchunk); % frequency for the "pushing chunk" loop

if replay_real_eeg && exist('sampledata_eegreal.mat')
    load('sampledata_eegreal.mat')
    eeg_looping = eegdata_sample;
else
    % generate eeg
    load([toolbox_path '/custom_functions_library/eeg_spectrum_params.mat'])
    eeg_duration = 20;
    eeg_looping = generate_sample_eeg(eeg_duration, n_eeg_chans, fs_eeg, eeg_spectrum_params);
    
end
nsamples = size(eeg_looping,2);

%% Create streams
disp('Creating a new EEG stream...');
info_eeg = lsl_streaminfo(lib,'g.USBamp-1','EEG',n_eeg_chans,fs_eeg,'cf_float32','source:local-pc-eegsimulator');

disp('Opening the EEG outlet...');
eeg_outlet = lsl_outlet(info_eeg);

pause(3)

%% stream eeg
disp('Now streaming...')
loop_iter = 0;
eeg_iter = 0;
to = tic;
t_start = toc(to);
while true

    t = toc(to);
    t_diff = t - (t_start + loop_iter * 1/loop_fs);
    
    if t_diff >= 0

        loop_iter = loop_iter + 1;
        eeg_iter = eeg_iter + 1;
        
        if eeg_iter*nsamples_eegchunk >= nsamples
            eeg_iter = 1;
        end
        
        i1_eeg = (eeg_iter - 1) * nsamples_eegchunk + 1;
        i2_eeg = eeg_iter * nsamples_eegchunk;

        eegfake_chunk = eeg_looping(:,i1_eeg:i2_eeg); % stream random numbers
        eeg_outlet.push_chunk(eegfake_chunk);

        size(eegfake_chunk)
        
        t2(loop_iter) = toc(to); % t2 saved for debugging
        
    end
    
end

close all; clear eeg_outlet