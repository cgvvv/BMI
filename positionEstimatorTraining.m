function [modelParameters] = positionEstimatorTraining(training_data, scale, thres, win_len)
  % Arguments:
  
  % - training_data:
  %     training_data(n,k)              (n = trial id,  k = reaching angle)
  %     training_data(n,k).trialId      unique number of the trial
  %     training_data(n,k).spikes(i,t)  (i = neuron id, t = time)
  %     training_data(n,k).handPos(d,t) (d = dimension [1-3], t = time)
  
  % ... train your model
  
  % Return Value:
  
  % - modelParameters:
  %     single structure containing all the learned parameters of your
  %     model and which can be used by the "positionEstimator" function.
  
    data = training_data;
    selected_neurons = tuning_curve(data, scale, thres, win_len);  % neuron*angle

    % data = modify_data(training_data);


    win_len = 50;
    modelParameters = {};
    
    X_all = ones(300000*8, 98);  % for classification
    y_all = ones(300000*8,1);
    total_length = 1;
    for angle = 1:8
        start = 1;
        
        selected_angle = selected_neurons(:,angle);
        indices = find(selected_angle==1.);
        disp('indices')
        disp(indices)
        disp('number of selected neurons:')
        disp(length(indices))
        disp('angle')
        disp(angle)

        X = ones(30000 * 8, 98);
        y = ones(30000 * 8, 2);

        for trial = 1:max(size(training_data))
            for neuron = 1:98
                spike_train = data(trial, angle).spikes(neuron, 300-win_len:end-100);
                smooth_fr = zeros(1, length(spike_train));
                for i = win_len:length(spike_train)
                    smooth_fr(i) = mean(spike_train(1, i-win_len+1:i));
                end
                smooth_fr = smooth_fr(win_len:end)';
                X(start:start+length(smooth_fr)-1, neuron) = smooth_fr;
            end
            y_prev = data(trial, angle).handPos(1:2, 299:end-100)';
            y_now = data(trial, angle).handPos(1:2, 300:end-99)';
            y(start:start+length(smooth_fr)-1, :) = y_now - y_prev;
        %     y(start:start+length(smooth_fr)-1, :) = data(trial, angle).handPos(1:2, 300:end-99)';

            start = start + length(smooth_fr);
        end
        % end
        X = X(1:start-1, :);
        y = y(1:start-1, :);
        
%         X_all(1+(start-1)*(angle-1):(start-1)*angle,:) = X;
%         y_all(1+(start-1)*(angle-1):(start-1)*angle,:) = y_all(1+(start-1)*(angle-1):(start-1)*angle,:)*angle;
        
        X_all(total_length:total_length+start-2,:) = X;
        y_all(total_length:total_length+start-2,:) = y_all(total_length:total_length+start-2,1) * angle;
        total_length = total_length + start-1;

%         X_all(total_length:total_length+1,:) = X(1:2,:);
%         y_all(total_length:total_length+1,:) = y_all(total_length:total_length+1,1) * angle;
%         total_length = total_length + 2;
        
        
        X = X(:,indices);

    %     [beta,Sigma,E,CovB,logL] = mvregress(y, X);
        %     [b1,bint1,r1,rint1,stats1] = regress(y(:,1), X);
        %     [b2,bint2,r2,rint2,stats2] = regress(y(:,2), X);


        disp('training model 1')
        tic;
%         [b1,bint1,r1,rint1,stats1] = regress(y(:,1), X);
    % %     model1 = fitrgp(X,y(:,1));
        model1 = fitlm(X, y(:,1));
%         model1 = fitrkernel(X, y(:,1));
        toc
        disp('complete')

        disp('training model 2')
        tic;
%         [b2,bint2,r2,rint2,stats2] = regress(y(:,2), X);
    % %     model2 = fitrgp(X,y(:,2));
        model2 = fitlm(X,y(:,2));
%         model2 = fitrkernel(X, y(:,2));
        toc
        disp('complete')

        %     model1 = fitsrsvm(X,y(:,1),'KernelFunction','gaussian','KernelScale','auto',...
        %     'Standardize',true);
        %     model2 = fitrsvm(X,y(:,2),'KernelFunction','gaussian','KernelScale','auto',...
        %     'Standardize',true);

        modelParameters{angle} = {model1, model2, [selected_neurons]};
    %     modelParameters = {, selected_neurons,angle};
%         modelParameters{angle} = {b1,b2,selected_neurons};
        
    end
    
    tic;
    X_all = X_all(1:total_length-1,:);
    y_all = y_all(1:total_length-1,:);
    classifier = fitcecoc(X_all,y_all);
    modelParameters{end+1} = classifier;
    toc
end
