function filtered_signal = filter_bandpass(signal,order, Wn)
%BANDPASS Filters the signal using a butterworth bandpass
%   Uses a butterworth Bandpass to filter a signall from both sides
    b= butter(order,Wn,'bandpass');
    % Zero phase filter, operates along first dimension
    % So need to transpose the signal first
    filtered_signal = filtfilt(b,1,signal')';
end