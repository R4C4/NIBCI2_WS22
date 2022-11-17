function C = filter_csp(signal_windowed,labels, num_filters)
%CALC_CSP  Calculate CSP filters from signal and labels
%   Calculates the csp filters corresponding a eeg channel signal
%   matrix (channels x time x epochs) and its corresponding labels
%   returns C = the CSP filter matrix of size channels x channels, 
%   each column is a spatial filter
TRIAL_DIM = 3;

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
C = V(:,[1:num_filters, end-num_filters+1:end]);
end

