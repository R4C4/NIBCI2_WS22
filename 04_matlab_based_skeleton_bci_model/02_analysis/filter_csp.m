function C = filter_csp(signal_windowed,labels, csp_idx)
%CALC_CSP  Calculate CSP filters from signal and labels
%   Calculates the csp filters corresponding a eeg channel signal
%   matrix (channels x time x epochs) and its corresponding labels
%   returns C = the CSP filter matrix of size channels x channels, 
%   each column is a spatial filter
TRIAL_DIM = 3;
%Use data of 1.5 - 2.5 seconds after cue presentation
% win_start = round(window(1)*fs);
% win_end = round(window(2)*fs);
% window = (cue_start + win_start):(cue_start+win_end);
% signal_windowed = channel_signal(:,:,:);

%Calculate the spatial covariance fo each epoch
cov_epochs = zeros(size(signal_windowed,1), size(signal_windowed,1),...
    size(signal_windowed,TRIAL_DIM));
for k_epoch=1:size(signal_windowed,TRIAL_DIM)
    nominator = signal_windowed(:,:,k_epoch)* ...
                signal_windowed(:,:,k_epoch)';
    cov_epochs(:,:,k_epoch) = nominator/trace(nominator);
end
avg_cov_class_1 = mean(cov_epochs(:,:,labels==1),TRIAL_DIM);
avg_cov_class_2 = mean(cov_epochs(:,:,labels==2),TRIAL_DIM);
[V,d] = eig(avg_cov_class_1,avg_cov_class_1+avg_cov_class_2,...
    'qz', 'vector');
[~, s_ind] = sort(d, 'descend');
V = V(:,s_ind);
C = V(:,[1:csp_idx, end-csp_idx+1:end]);

end

