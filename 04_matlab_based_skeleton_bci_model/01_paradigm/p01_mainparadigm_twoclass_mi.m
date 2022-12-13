%% ------------------------------------------------------------------------
%
%   Description: The script "p01_mainparadigm_twoclass_mi.m" displays the
%   BCI paradigm to the participant.
%k
%   Paradigm: A simple cue-based, 2-class (hand vs. foot), mi paradigm is
%   implemented.
%
%   Timings and appearence: The timings (pre-cue, cue, mi.s..) and
%   appearence of visual elements (fixation cross, images, etc) are set
%   through the "set_bciparadigm_parameters_twoclass_mi.m" function, and
%   saved in the structure called "BCI".
%   
%   Calibration vs. feedback: The paradigm can run in ts specified by acting
%   on the flag "feedbackrun".
%   
%   NOTE on the feedback: The paradigm runs independently of the underlying
%   eeg. Therefore, if feedback is required, another controller module
%   is required. The role of the controller module is to continously read,
%   process, classify the data, and stream the class labels and
%   probability. 
%
%% ------------------------------------------------------------------------
clear, clc
%clear, close all, clc

homedir = fileparts(mfilename('fullpath'));
addpath(genpath('../../'))

%% flags:
global feedbackrun
feedbackrun = true; %false; 

%% call the function to set the BCI paradigm settings

BCIpar = set_bciparadigm_parameters_twoclass_mi;
cd(homedir)

%% lab streaming layer (lsl) streams: create inlets and outlets

% instantiate the library
fprintf('\n Loading the library...');
lib = lsl_loadlib();

% create the marker stream
fprintf('\n Creating a marker stream...');
lslinfo_marker = lsl_streaminfo(lib,'markers_from_paradigm','marker',1,0,'cf_string','source:local-pc-paradigm');

fprintf('\n Opening the marker outlet...');
outlet_marker = lsl_outlet(lslinfo_marker);

% in case it is a feedback run, wait for the controller streams to be ready
if feedbackrun
    %resolve the lda classification
    fprintf('\n Resolving lda classification...');
    stream_predict_class = {};
    eeg_predict_str_name = 'lda-class-and-probabilities';

    while isempty(stream_predict_class)
        disp(stream_predict_class)
        % resolve the lsl stream by name with "lsl_resolve_byprop"
        stream_predict_class = lsl_resolve_byprop(lib,'name',eeg_predict_str_name); 
    end
    fprintf('\n Opening an inlet for the lda classification and probability...');
    inlet_classification_result = lsl_inlet(stream_predict_class{1});

end
%% paradigm ready to start:
% display message that the paradigm is ready, and ask to press a button to
% confirm
fprintf('\n -----------------------------------------------------------\n')
fprintf('\n      Paradigm is ready to start! Please:                     ')
fprintf('\n          i) UPDATE the streams in the LabRecorder            ')
fprintf('\n         ii) LINK the eeg stream                              ')
fprintf('\n        iii) LINK the paradigm stream                         ')
fprintf('\n         iv) LINK classifier output stream (if )   ')
fprintf('\n          v) SELECT the experiment block                      ')
fprintf('\n         vi) SELECT the experiment number                     ')
fprintf('\n        vii) START the LabRecorder                            ')
fprintf('\n      ... and press a key to continue!                        ')
fprintf('\n -----------------------------------------------------------\n')

pause; clc

%% section running the paradigm

% i) pre-run
% open the figure ....
set(BCIpar.sfDisplay.hfig,'Visible','on')

% send "start of run" marker
outlet_marker.push_sample({'start_of_run'});
fprintf('\n \n Start of run...')
% wait for the duration specified in preloadscript
pause(BCIpar.times.time_pre_run)
% ii) for loop running trials
for k_trial = 1:BCIpar.nTrials
    
% display current trial and timings in the command window
    fprintf("\n\n Start of trial %d% ",k_trial);
% get current trial parameters, reset flags and timer

    t_start = tic;
    trialrunning=true;
    while trialrunning  
        
        % Here you need to check the timings, present stimuli on the screen
        % and send the markers         
        % How check the timings? By using tic & toc functions you are able
        % to implement correct timing for state (Please see BCIpar.times)
        % strategy: the paradigm constantly checks the elapsed time sinces
        % the beginning of the trial, and changes state (pre-cue, cue,
        % mi... etc) accordingly
        % Example:
        % t_start = tic;
        % t = toc(t_start);

        % stimuli presentation 
        % First, you load all of your needed pictures in 
        % set_bciparadigm_parameters_twoclass_mi.m function
        % Then based on the state of experiment you show different pics. 
        % Example:
        % display fixation cross
        %set(BCIpar.sfDisplay.hCross_horizontal, 'Visible', 'on');
        %set(BCIpar.sfDisplay.hCross_vertical, 'Visible', 'on');
        % drawnow limitrate;       
        % sending the markers
        % In order to analyze the data after the measurement, we need to
        % know the onset of each state.
        % LSL library is used to send the markers to the stream
        % Example:
        %marker_text = 'start_of_trial';
        %outlet_marker.push_sample({marker_text});
        
        % % display confirmation in the command window and change the flag for marker sent
        %set(BCIpar.sfDisplay.hMainAxes, 'Visible', 'on');
        push_marker('pre_cue_start', t_start, outlet_marker);
        set(BCIpar.sfDisplay.hCross_horizontal, 'Visible', 'on');
        set(BCIpar.sfDisplay.hCross_vertical, 'Visible', 'on');
        pause(BCIpar.times.time_pre_cue);
        push_marker('cue_start', t_start, outlet_marker);
         if BCIpar.cues.class_list(k_trial)==1
             set(BCIpar.sfDisplay.himage_class1_start, 'Visible', 'on');
         else
             set(BCIpar.sfDisplay.himage_class2_start, 'Visible', 'on');
         end
       
         pause(BCIpar.times.time_cue)
         set(BCIpar.sfDisplay.hCross_horizontal, 'Visible', 'off');
         set(BCIpar.sfDisplay.hCross_vertical, 'Visible', 'off');
         
         mi_start = tic;
         push_marker('mi_start', t_start, outlet_marker);
         if BCIpar.cues.class_list(k_trial)==1
            set(BCIpar.sfDisplay.himage_class1_start, 'Visible', 'off');
            set(BCIpar.sfDisplay.himage_class1_execute, 'Visible', 'on');
            %set(BCIpar.sfDisplay.haxes_class1_execute, 'Visible', 'on');
         else
            set(BCIpar.sfDisplay.himage_class2_start, 'Visible', 'off');
            set(BCIpar.sfDisplay.himage_class2_execute, 'Visible', 'on');
            %set(BCIpar.sfDisplay.haxes_class2_execute, 'Visible', 'on');
         end
        
        % Motor Imagery Start
        % with Feedbackrun
        if feedbackrun
            while toc(mi_start) < BCIpar.times.time_mi
            
                classes_and_prob = inlet_classification_result.pull_sample();
                set(BCIpar.sfDisplay.himage_class1_execute, 'Visible', 'off');
                set(BCIpar.sfDisplay.himage_class2_execute, 'Visible', 'off');
                % get sample with probability and class here here
                classified_class = classes_and_prob(1);       
                probability = classes_and_prob(2);
                probability(isnan(probability)) = 0;
                display(probability)
                barcolor = 'r';

                updateMIImage(BCIpar, classified_class(end), ...
                    BCIpar.cues.class_list(k_trial));
                if BCIpar.cues.class_list(k_trial) == classified_class(end)
                    barcolor = 'g';                   
                end
                set(BCIpar.sfDisplay.haxes_barplot, 'Visible', 'on');
                rect_handle = rectangle(BCIpar.sfDisplay.haxes_barplot, ...
                    'Position', [0 0 0.1 probability(end)], ...
                    'FaceColor', barcolor);
                pause(0.5)
                delete(rect_handle)
            end
            set(BCIpar.sfDisplay.haxes_barplot, 'Visible', 'off');
            deactivateClassImages(BCIpar)
        end
        
        % using else leads to annoying warning
        if ~feedbackrun
            pause(BCIpar.times.time_mi);
        end

        if BCIpar.cues.class_list(k_trial)==1
            set(BCIpar.sfDisplay.himage_class1_execute, 'Visible', 'off');
        else
            set(BCIpar.sfDisplay.himage_class2_execute, 'Visible', 'off');
        end
        push_marker('break_start', t_start, outlet_marker);
        %Todo Set to random time between min and and max
        pause(BCIpar.times.time_break_min)
        push_marker('break_end', t_start,  outlet_marker);
        trialrunning=false;
    end
end

% iii) post-run
pause(BCIpar.times.time_post_run)
close(BCIpar.sfDisplay.hfig); % closing figure
outlet_marker.push_sample({'end of run'});
fprintf('\n \n ... end of run! \n')
%% lsl outlets cleanup
clear outlet_marker

function deactivateClassImages(BCIpar)
    set(BCIpar.sfDisplay.himage_class1_correct, 'Visible', 'Off');
    set(BCIpar.sfDisplay.himage_class2_correct, 'Visible', 'Off');
    set(BCIpar.sfDisplay.himage_class1_wrong, 'Visible', 'Off');
    set(BCIpar.sfDisplay.himage_class2_wrong, 'Visible', 'Off');
end

function updateMIImage(BCIpar, predicted, trueclass)
    deactivateClassImages(BCIpar)
    if(trueclass == 1)
        if(trueclass == predicted)
            set(BCIpar.sfDisplay.himage_class1_correct, 'Visible', 'On');
        else
           set(BCIpar.sfDisplay.himage_class1_wrong, 'Visible', 'On'); 
        end
    else
        if(trueclass == predicted)
            set(BCIpar.sfDisplay.himage_class2_correct, 'Visible', 'On');
        else
            set(BCIpar.sfDisplay.himage_class2_wrong, 'Visible', 'On');
        end
    end
end

function push_marker(text,t_start, lsl_outlet)
    marker_text = text;
    lsl_outlet.push_sample({marker_text});
    fprintf(sprintf("\n t=%5.9f s marker=%s \n", ...
        toc(t_start), marker_text));
end