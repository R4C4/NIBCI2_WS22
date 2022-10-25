function LDA_classified = LDA(eeg,labels)
    
    eeg=eeg(1,:,:);
    size_eeg=size(eeg);
    eeg=reshape(eeg,size_eeg(2),size_eeg(3))';
    accuracy = 0;
    
    for j=1:10
        
        c=cvpartition(size_eeg(3),'KFold',5);
        
        for i=1:5
            X_train=eeg(c.training(i),:);
            Y_train=labels(c.training(i),:);
            X_tst=eeg(c.test(i),:);
            Y_tst=labels(c.test(i),:);

            model_lda = lda_train(X_train,Y_train);
            [predicted_classes, linear_scores, class_probabilities] = lda_predict(model_lda,X_tst);
            LDA_classified.class_prob = class_probabilities;

            accuracy = accuracy + sum(predicted_classes==Y_tst)/length(Y_tst);
        end
    end
    
    LDA_classified.accu = accuracy/50;
end