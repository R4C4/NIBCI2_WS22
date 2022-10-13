function BCIpar = set_bciparadigm_parameters_twoclass_mi

global feedbackrun

%% Settings for:

%% i) paradigm timings (all timings are expressed in seconds)
BCIpar.times.time_pre_run   = 3;
BCIpar.times.time_pre_cue   = 2.5;
BCIpar.times.time_cue       = 1.5;
BCIpar.times.time_mi        = 5;
BCIpar.times.time_break_min = 2;
BCIpar.times.time_break_max = 3;
BCIpar.times.time_post_run  = 5;

%% ii) number of trials and class info (half of trials is class1, half of trials is class2, in randomised orded)

% number of trials
BCIpar.nTrials = 20; % total number of trials (half will be class 1, half class 2)

% class info
class1_label = 'hand';
class2_label = 'foot';

% create class cues
class1_cues = 1 * ones(ceil(BCIpar.nTrials/2), 1);
class2_cues = 2 * ones(ceil(BCIpar.nTrials/2), 1);
class_list = cat(1, class1_cues, class2_cues);
class_list = class_list(randperm(length(class_list)));

% "store" everything in the BCIpar structure
BCIpar.cues.class_list = class_list;
BCIpar.cues.class_labels{1} = class1_label;
BCIpar.cues.class_labels{2} = class2_label;

%% iii) settings for the paradigm figure

% size, color, and position of elements in the figure
BCIpar.sfDisplay.crossSize = 0.20;
BCIpar.sfDisplay.crossColor = 'k';
BCIpar.sfDisplay.lineWidth = 5;

% If present display the window on the second screen
monitor_positions = get(groot, 'MonitorPositions');
if size(monitor_positions, 1) == 2
    BCIpar.sfDisplay.screensize = monitor_positions(2,:);
else
    BCIpar.sfDisplay.screensize = monitor_positions(1,:);
end

aspect_ratio_heigth_over_width = BCIpar.sfDisplay.screensize(3)/BCIpar.sfDisplay.screensize(4);

BCIpar.sfDisplay.hfig = figure('Color', [0.6 0.6 0.6],...
    'position', BCIpar.sfDisplay.screensize,...
    'MenuBar', 'none',...
    'ToolBar', 'none',...
    'Visible', 'off');

BCIpar.sfDisplay.hMainAxes = axes('Color', 'none',...
    'xlim', [-1.1 1.1],...
    'ylim', [-1.1 1.1],...
    'Visible', 'off',...
    'Position', [0, 0, 1, 1]);

% Fixation Cross
BCIpar.sfDisplay.hCross_horizontal = line(BCIpar.sfDisplay.crossSize*[-1 1], [0, 0],...
    'Color', BCIpar.sfDisplay.crossColor,...
    'LineWidth', BCIpar.sfDisplay.lineWidth,...
    'Visible', 'off');

BCIpar.sfDisplay.hCross_vertical = line([0, 0], BCIpar.sfDisplay.crossSize*[-1 1]*aspect_ratio_heigth_over_width,...
    'Color', BCIpar.sfDisplay.crossColor,...
    'LineWidth', BCIpar.sfDisplay.lineWidth,...
    'Visible', 'off');

% Make sure we are in the directory of the running function
runningdir = fileparts(mfilename('fullpath'));
cd(runningdir)

% Include pictures:
% BCIpar.sfDisplay.class1_start = imread([]); % upload the stimulus image 
% BCIpar.sfDisplay.haxes_class1_start = axes(...
%     'Color', 'none',...
%     'xlim', [-1/2 1/2],...
%     'ylim', [-1/2 1/2],...
%     'Visible', 'off',...
%     'Position', [0, 0, 1, 1.5],...
%     'YDir', 'reverse');
% BCIpar.sfDisplay.himage_class1_start = image('CData', BCIpar.sfDisplay.class1_start,...
%     'Visible','off',...
%     'XData',[-0.05 0.05],...
%     'YData',[-0.05 0.05]);


if feedbackrun

% you need to create the feedback pics here.
    
end

end