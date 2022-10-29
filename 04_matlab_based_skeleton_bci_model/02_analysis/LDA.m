function LDA_classified = LDA(eeg,labels, channel)
    
    size_eeg=size(eeg);
    eeg_channel=squeeze(eeg(:,channel,:));
    eeg_channel = eeg_channel';
    accuracy = 0;
    
    for j=1:10
        
        c=cvpartition(size_eeg(3),'KFold',5);
        
        for i=1:5
            X_train=eeg_channel(c.training(i),:);
            Y_train=labels(c.training(i),:);
            X_tst=eeg_channel(c.test(i),:);
            Y_tst=labels(c.test(i),:);

            model_lda = lda_train(X_train,Y_train);
            [predicted_classes, ~, ~] = lda_predict(model_lda,X_tst);
            %LDA_classified.class_prob = class_probabilities;

            accuracy = accuracy + sum(predicted_classes==Y_tst)/length(Y_tst);
        end
    end
    
    LDA_classified.accu = accuracy/50;
end