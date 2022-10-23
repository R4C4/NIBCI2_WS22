function filtered_signal = filter_bandpass(signal,order, Wn, varargin)
%BANDPASS Filters the signal using a butterworth bandpass
%   Uses a butterworth Bandpass to filter a signall from both sides
    opts = cell2struct(varargin(2:2:end),varargin(1:2:end),2);
    b= butter(order,Wn,'bandpass');
    if isfield(opts,'Display')&& opts.display
        figure
        freqz(b)
    end
    % Zero phase filter, operates along first dimension
    % So need to transpose the signal first
    filtered_signal = filtfilt(b,1,signal')';
end

