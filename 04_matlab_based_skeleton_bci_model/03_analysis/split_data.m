function [train_set, train_labels, test_set, test_labels] = ...
    split_data(epoched_data, labels, ratio)
    n_max = size(epoched_data,3);
    n_train = floor(ratio*n_max);
    train_set = epoched_data(:,:,1:n_train);
    train_labels = labels(1:n_train);
    test_set = epoched_data(:,:, n_train+1:n_max);
    test_labels = labels(n_train+1:n_max);
end