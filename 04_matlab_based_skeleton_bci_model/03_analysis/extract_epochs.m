function epoched_signal = extract_epochs(signal, eeg_times, markers)
%EXTRACT_EPOCHS uses signal label data to extract epochs
% extract_epochs(signal,labels,woi) uses the signal (channels, time)
% looks for timestamps and corresponding labels
% ouput dimensions are [channel, time, epochs]
    pre_cue_times = markers.time_stamps(markers.time_series ...
        == "pre_cue_start");
    break_start = markers.time_stamps(markers.time_series ...
        == "break_start");
    
    [~, starts] = ismembertol(pre_cue_times, eeg_times, 1e-6);
    [~, ends] = ismembertol(break_start, eeg_times, 1e-6);
    num_epochs = length(pre_cue_times);
    epoched_signal = [];
    woi_length = max(ends-starts); 
    for i=1:num_epochs
        woi=starts(i):(starts(i)+woi_length);
        epoched_signal= cat(3,epoched_signal, signal(:,woi));
    end
end

%function indices = find_indices(container_arr, search_array)
    %indices=[];
    %for i=1:length(search_array)
    %    result = find(container_arr>search_array(i),1);
    %    indices= cat(1,indices, result);
    %end
%end