function [selected_neurons] = tuning_curve(training_data, scale, thres, win_len)
    data = training_data;

%     win_len = win_len;
%     avg_fr = zeros(98,8);
% 
%     for neuron = 1:98
%         for angle = 1:8
%             mean_fr = 0;
%             for trial = 1:max(length(data))
%                 spike_train = data(trial, angle).spikes(neuron, 300-win_len:end-100);
%                 smooth_fr = zeros(1,length(spike_train));
%                 for i = win_len:length(spike_train)
%                     smooth_fr(i) = mean(spike_train(1, i-win_len+1:i));
%                 end
%                 mean_fr = mean_fr + mean(smooth_fr);
%             end
%             avg_fr(neuron,angle) = mean_fr;
%         end
%     end
% 
%     % normalise with softmax
%     avg_fr = exp(avg_fr*scale);
%     avg_fr = avg_fr./sum(avg_fr,2);
%     selected_neurons = avg_fr>thres;

    spike_sum = zeros(98,8);

    for neuron = 1:98
        for angle = 1:8
            for trial = 1:max(length(data))
                spike_train = data(trial, angle).spikes(neuron, 300-win_len:end-100);
                neuron_sum = sum(spike_train);
            end
            spike_sum(neuron,angle) = neuron_sum;
        end
    end

    % normalise with softmax
    spike_sum = exp(spike_sum*scale);
    spike_sum = spike_sum./sum(spike_sum,2);
    selected_neurons = spike_sum>thres;
end
