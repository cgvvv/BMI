clear all; clc;

data = load('monkeydata_training.mat');

win_len = 20;
avg_fr = zeros(98,8);

for neuron = 1:98
    for angle = 1:8
        mean_fr = 0;
        for trial = 1:max(length(data))
            spike_train = data.trial(trial, angle).spikes(neuron, 300-win_len:end-100);
            smooth_fr = zeros(1,length(spike_train));
            for i = win_len:length(spike_train)
                smooth_fr(i) = mean(spike_train(1, i-win_len+1:i));
            end
            mean_fr = mean_fr + mean(smooth_fr);
        end
        avg_fr(neuron,angle) = mean_fr;
    end
end

% normalise with softmax
avg_fr = exp(avg_fr*1000);
avg_fr = avg_fr./sum(avg_fr,2);
tuned_neurons = avg_fr>0.3;
