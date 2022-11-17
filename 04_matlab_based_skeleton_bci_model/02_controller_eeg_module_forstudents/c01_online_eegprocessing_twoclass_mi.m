%% ------------------------------------------------------------------------
%
%   The script "c01_online_eegprocessing_twoclass_mi.m"
%   is an example of how online processing and classification of eeg to
%   achieve closed-loop bci control can be performed.
%
%   Inputs / variables to be changed in the code:
%       The script requires to specify:
%       - the participant's name (or code), so to load the data
%       - the eeg stream name, depending on the connected amplifier
%   
%   Description: The scripts implements the pipeline for 2-class mi BCI
%   control, with filter-bank CSP and sLDA classification.
%
%   After opening the eeg inlet relative to the connected amplifier (or the
%   simulated eeg), the script loads the filter parameters, CSP models, and
%   sLDA classifier previously trained of the participant.

%   The implemented pipeline closely follows the one implemented in the offline calibration
%   script, thus including i) filtering of eeg signal in two frequency
%   bands (alpha/veta), ii) CSP filtering with corresponding model, iii)
%   extraction of logarithmic band-power features, by computing values of
%   instantaneous signal energy (sample by sample), iv) smoothing with a
%   moving average filter, v) downsampling to 16hz to reduce the frequency
%   of classifier output, vi) classifying the data with the loaded sLDA
%   model, and streaming of predicted class and class probability through
%   lab-streaming-layer.
%
%   Execution of the online controller stops in case the eeg is not
%   received for more than 5s.
%
%% ------------------------------------------------------------------------

clearvars, close all, clc

% subject = input('What is the subject code?','s');
subject = 'sample_participant';
subject_root_dir = ['../../999_recorded_data/' subject '/'];

%% add path to libraries, set homedir etc

% set homedir
homedir = fileparts(mfilename('fullpath'));
addpath(genpath('../../'))

% instantiate the library
fprintf('\n Loading the library...');
lib = lsl_loadlib();

%% LSL inlets and outlets:
%% i) resolve the stream to get the input eeg

% eeg stream properties
eeg_str_name = 'g.USBamp-1';
hostname = getComputerName; % when resolving the eeg stream, but more than
%                             one eeg amplifier is connected to the
%                             network, additional properties, like for
%                             example hostname (i.e. the pc streaming the
%                             data) or source_id may be specified

% resolve the eeg stream
fprintf('\n Resolving eeg stream...');
stream_eeg = {};
while isempty(stream_eeg)
    
    % option1: resolve the lsl stream by name with "lsl_resolve_byprop"
    stream_eeg = lsl_resolve_byprop(lib,'name',eeg_str_name);
    
    % other options: if more properties need to be specified (e.g. name,
    % hostname, source_id... etc), the command "lsl_resolve_bypred()" may
    % be used
%     stream_eeg = lsl_resolve_bypred(lib,['name=''' eeg_str_name '''']);% and sourceid=''source:local-pc-eegsimulator''');
%     stream_eeg = lsl_resolve_bypred(lib,['name=''' eeg_str_name ''' and hostname=''' upper(hostname) '''']);

end

fprintf('\n Opening an inlet for the eeg stream...');
inlet_eeg = lsl_inlet(stream_eeg{1});

[eeg_chunk,~] = inlet_eeg.pull_chunk(); % pull one eeg chunk to get the number of samples;
[n_chans,~] = size(eeg_chunk);

%% ii) open a lsl outlet to stream the classifier output (predicted class and
% probabilities)
fprintf('\n Creating the lda-class-and-probabilities stream info...');
info_classifier = lsl_streaminfo(lib,'lda-class-and-probabilities','lda-class-and-probabilities',2,0,'cf_double64','lda-class-and-probabilities');

fprintf('\n Opening the lda-class-and-probabilities outlet...');
outlet_classifier = lsl_outlet(info_classifier);

%% load participant-specific fb-frequencies, CSP models, and sLDA classifier
load(fullfile(subject_root_dir, 'csp_and_slda_calibration_models.mat'))

% the file contains:
% - csp_model_cal        > nchans x nchans x 2 (double)
% - csp_filter_selection > 1xnchans (logical), 
% - model_lda_cal        > struct with fields:
%                           - w > 2x9 (double)
%                           - classlabels > [1;2]
% - selected_fb_filters  > 2x2 matrix with selected fb frequencies in the
%                          rows (e.g. [12 14; 26 28])
% - fb_filter order, fb_filter_type > order and type of fb filters
% - fs_eeg               > eeg sampling frequency
% - movavg_dur           > duration of the moving average filter (for the
%                          instantaneous energy features)

% get csp model for each filter bank

%% create filters for each filter bank, moving average filter coefficients, and decimation filter
% fb filters

% moving average filter

% csp_filter;

% decimation filter
% you need to define a buffer to take 1 sample from 16 samples
%% main loop

% initialize the variables for the initial states of the loop (they will
% then be updated when running the code)

fprintf('\n\n eeg decoding started...')

decoding = true;
t_start_timeout = tic; t_timeout = 5;
while decoding
    
    % continuously pull eeg chunks
    [eeg_chunk,~] = inlet_eeg.pull_chunk(); % note: dimension is [channels x samples]
    
    if ~isempty(eeg_chunk) % if the chunk is empty
        
        % filter the eeg chunk
        
        % csp filter

        % get instantaneous power
  
        
        % moving avergae filter

        
        % obtatining the log of the features
  
        
        % concatenate log_bp features for fb1 and fb2
        
        % downsample to "fs_down" (so not to have the classifier output too
        % frequently)
         
        
        % logbp_feat_all_down is the output of downsmapling
        if ~isempty(logbp_feat_all_down)
            
            % lda classifier
            
            % create the chunk to be streamed (first row: predicted class, second row: probability of predicted class)
            lin_idxs = sub2ind(size(class_probs),1:length(predicted_class),predicted_class'); % variable to correctly index the matrix of class probabilities
            lda_out_chunk = [predicted_class'; class_probs(lin_idxs)];
            
            % and push it through lsl
            outlet_classifier.push_chunk(lda_out_chunk)
            
        end
        
        % reset the t_start
        t_start_timeout = tic;
        
    end
    
    % piece of code to stop execution of the controller if samples are not
    % received for more than "t_timeout" seconds
    if toc(t_start_timeout)>t_timeout
        fprintf('\n eeg samples not received for %d seconds... decoding is stopped.\n',t_timeout)
        decoding = false;
    end
    
end

%% lsl inlets/outlets clean up
close all;
clear inlet_eeg
clear outlet_classifier