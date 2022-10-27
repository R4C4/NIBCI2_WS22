function C = filter_csp(channel_signal,labels)
%CALC_CSP  Calculate CSP filters from signal and labels
%   Calculates the csp filters corresponding a eeg channel signal
%   matrix (channels x time x epochs) and its corresponding labels
%   returns C = the CSP filter matrix of size channels x channels, 
%   each column is a spatial filter
TRIAL_DIM = 3;
%Extract Band Power -> 1.5 - 2.5 seconds after cue presentation

%Calculate the spatial covariance fo each epoch
cov_epochs = zeros(size(channel_signal,1), size(channel_signal,1), epochs);
for k_epoch=1:size(channel_signal,TRIAL_DIM)
    nominator =  channel_signal(:,:,k_epoch)*channel_signal(:,:,k_epoch)';
    cov_epochs(:,:,epoch_idx) = nominator/trace(nominator);
end
avg_cov_class_1 = mean(cov_epochs(:,:,labels==1),TRIAL_DIM);
avg_cov_class_2 = mean(cov_epochs(:,:,labels==2),TRIAL_DIM);
[V,d] = eig(avg_cov_class_1,avg_cov_class_1+avg_cov_class_2,...
    'qz', 'vector');
[~, s_ind] = sort(d, 'descend');
C = V(:,s_ind);
end

