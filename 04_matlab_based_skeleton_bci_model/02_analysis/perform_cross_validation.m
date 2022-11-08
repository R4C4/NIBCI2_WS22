function accu = perform_cross_validation(features,labels, K, N)    
    accuracy = 0;    
    for j=1:N        
        cvp=cvpartition(size(features,2),'KFold',K);        
        for i=1:K
            test_idx = test(cvp,i);
            train_idx = ~test_idx;
            X_train = features(:, train_idx)';
            Y_train = labels(train_idx);
            model_lda = lda_train(X_train,Y_train);
            
            X_test = features(:, test_idx)';
            Y_test = labels(test_idx);
            [predicted_classes, ~, ~] = lda_predict(model_lda,X_test);
            accuracy = accuracy + ...
                sum(predicted_classes==Y_test)/length(Y_test);
        end
    end
    accu = accuracy/(N*K);
end