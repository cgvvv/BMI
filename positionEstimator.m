function [X, Y] = positionEstimator(test_data, modelParameters, win_len)

  % **********************************************************
  %
  % You can also use the following function header to keep your state
  % from the last iteration
  %
  % function [x, y, newModelParameters] = positionEstimator(test_data, modelParameters)
  %                 ^^^^^^^^^^^^^^^^^^
  % Please note that this is optional. You can still use the old function
  % declaration without returning new model parameters. 
  %
  % *********************************************************

  % - test_data:
  %     test_data(m).trialID
  %         unique trial ID
  %     test_data(m).startHandPos
  %         2x1 vector giving the [x y] position of the hand at the start
  %         of the trial
  %     test_data(m).decodedHandPos
  %         [2xN] vector giving the hand position estimated by your
  %         algorithm during the previous iterations. In this case, N is 
  %         the number of times your function has been called previously on
  %         the same data sequence.
  %     test_data(m).spikes(i,t) (m = trial id, i = neuron id, t = time)
  %     in this case, t goes from 1 to the current time in steps of 20
  %     Example:
  %         Iteration 1 (t = 320):
  %             test_data.trialID = 1;
  %             test_data.startHandPos = [0; 0]
  %             test_data.decodedHandPos = []
  %             test_data.spikes = 98x320 matrix of spiking activity
  %         Iteration 2 (t = 340):
  %             test_data.trialID = 1;
  %             test_data.startHandPos = [0; 0]
  %             test_data.decodedHandPos = [2.3; 1.5]
  %             test_data.spikes = 98x340 matrix of spiking activity
  % ... compute position at the given timestep.
  % Return Value:
  % - [x, y]:
  %     current position of the hand
    data = test_data;
    
    window_start_timestep = length(data.spikes) - 20; %fixed 20 step window
    
    spike_predicted_angle = zeros(1,1);
        
    new = NaN;

    for i=1:98
        spike_num = 0;
        for t=1:320
            if test_data.spikes(i,t) == 1
                spike_num = spike_num + 1;
            end
        end
        new(i)= spike_num;
    end
    classifier = modelParameters{end};
    angle = classifier.predict(new);
     
%     disp('predicted angle')
%     disp(angle)

    selected_neurons = modelParameters{angle}(4);
    selected_neurons = selected_neurons{1};
    selected_angle = selected_neurons(:,angle);
    indices = [find(selected_angle==1.)];
    
    num_windows = 20/win_len;
%     total_length = length(data.spikes(1, :));
    
    for window = 1:num_windows
        for idx = 1:length(indices)
            neuron = indices(idx);
            spike_train = data.spikes(neuron, :);       
            spike_sum = 0;
%             t_start = window_start_timestep + (window-1)*win_len - 80;
%             if window_start_timestep + window*win_len - 80 < length(data.spikes)-80
%                 t_end = window_start_timestep + window*win_len - 80;
%             else
%                 t_end = length(data.spikes)-80;
%             end
            
            t_start = window_start_timestep + (window-1)*win_len;
            if window_start_timestep + window*win_len < length(data.spikes)
                t_end = window_start_timestep + window*win_len;
            else
                t_end = length(data.spikes);
            end
            
            spike_sum = sum(data.spikes(neuron,t_start:t_end));
            
%             for t = window_start_timestep + (window-1)*win_len - 80 : window_start_timestep + window*win_len - 80
%                 if t < length(data.spikes)
%                     if spike_train(t)
%                         spike_sum = spike_sum + 1; 
%                     end
%                 end
%             end    
            spike_predicted_angle(1,idx) = spike_sum; % 1 means only '1 window' with 20 timesteps
        end
        
%         if window_start_timestep + win_len - 80 <= total_length
%             window_start_timestep  = window_start_timestep + win_len

    %     if  (length(test_data.spikes(1,:))-300)/win_len <= 1
    %         x_start = test_data.startHandPos(1);
    %         y_start = test_data.startHandPos(2);
    %     else
    %         last_position = test_data.decodedHandPos(:,end);
    %         x_start = last_position(1);
    %         y_start = last_position(2);
    %     end

        if length(test_data.decodedHandPos) > 0 & window == 1
            last_position = test_data.decodedHandPos(:,end);
            x_start = last_position(1);
            y_start = last_position(2);
        elseif window == 1
            x_start = test_data.startHandPos(1);
            y_start = test_data.startHandPos(2);
        else
            x_start = X;
            y_start = Y;
        end
        
        speed =  modelParameters{angle}{1}.predict(spike_predicted_angle) ;
        sin =  modelParameters{angle}{2}.predict(spike_predicted_angle) ;
        cos =  modelParameters{angle}{3}.predict(spike_predicted_angle) ;

        Xvelocity = speed*cos;
        Yvelocity = speed*sin;

        X = x_start + Xvelocity;
        Y = y_start + Yvelocity;
        
%     x = cumsum(modelParameters{angle}{1}' * smooth_fr);
%     y = cumsum(modelParameters{angle}{2}' * smooth_fr);
    
    %x = cumsum(modelParameters{angle}{1}.predict(smooth_fr'))';
    %y = cumsum(modelParameters{angle}{2}.predict(smooth_fr'))';

%     x = modelParameters{1}.predict(smooth_fr')';
%     y = modelParameters{2}.predict(smooth_fr')';

    end
end
