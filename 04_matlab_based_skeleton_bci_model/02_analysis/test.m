close all; clear all; clc;
filter_order = 4;
fs =256;
t = 0:1/fs:2;

signal = zeros(2,length(t));
signal_1 = sin(2 * pi * 7 * t);
signal(1,:) = signal_1 + 0.1*sin(2 * pi * 50 * t) + 0.2*sin(2 * pi * 47 * t) + 0.15*sin(2 * pi * 71 * t) ;
signal(2,:) = signal_1 + 0.3*rand(1,length(t))+ 0.1*rand(1,length(t));

h_bp = create_online_fbfilt('butter',filter_order,[0.3 35],fs);

signal_filt=filtfilt(h_bp.sosMatrix, h_bp.ScaleValues, signal')';


plot(signal(1,:))
hold on
plot(signal_1)
plot(signal_filt(1,:))
legend('noisy', 'orig', 'filt')

figure
plot(signal(2,:))
hold on
plot(signal_1)
plot(signal_filt(2,:))
legend('noisy', 'orig', 'filt')