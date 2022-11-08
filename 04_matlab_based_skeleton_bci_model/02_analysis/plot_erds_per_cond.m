function plot_erds_per_cond(eeg_lapl_epoched_data,fs, t_lim, labels, ...
    condition)
cond_indices = find(labels==condition);

%Find new marker times. t_lim was used for the epoch splitting.
% meaning the first sample is at t_lim(1) time (i.e -3s)
offset = abs(t_lim(1)*fs); 
starts = offset+1:size(eeg_lapl_epoched_data,2): ...
    size(eeg_lapl_epoched_data,2)*length(cond_indices);

%Concatenate epochs to one long data stream per channel
eeg_lapl = eeg_lapl_epoched_data(:,:,cond_indices);
eeg_lapl = reshape(eeg_lapl, size(eeg_lapl,1), ...
                             size(eeg_lapl,2)*size(eeg_lapl,3));

erds_header.SampleRate = fs;
erds_header.TRIG = starts';
erds_header.Classlabel = labels(cond_indices);
erds_borders = [2 35];

erds_calc = calcErdsMap(eeg_lapl', erds_header, ...
                t_lim, erds_borders, 'heading',"ERDS Maps", ...
                'method', 'bp', 'alpha', 0.05, ...
                'ref', [-3 -2], 'refmethod', 'trial',...
                'cue', 0, 'class', condition, 'sig', 'boot');
plotErdsMap(erds_calc);
end