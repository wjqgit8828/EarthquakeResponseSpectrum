function time_start = sta_lta(data, step_sta, step_lta, fsamp)
% STA/LTA method for earthquake event detection
% INPUTS:
%   data: seismic data (1D array)
%   step_sta: length of the short-term window in seconds
%   step_lta: length of the long-term window in seconds
%   fsamp: sampling frequency in Hz
% OUTPUT:
%   time_start: start time of the earthquake event in seconds

% Centering the data around 0 mean
x = data - mean(data);
N = length(x);t = [0:N-1] / fsamp;
% Compute the CF function (short-term average minus long-term average squared)
n_sta = round(step_sta * fsamp); % number of samples for short-term average
n_lta = round(step_lta * fsamp); % number of samples for long-term average
cf = zeros(size(x));
for i = n_lta+1:length(x)
    cf(i) = sum(x(i-n_sta+1:i).^2) - sum(x(i-n_lta+1:i).^2) / n_lta;
end

% Calculate the STA/LTA ratio and search for the event start time
sta = movmean(cf, n_sta); % short-term average
lta = movmean(cf, n_lta); % long-term average
ratio = sta ./ lta; % STA/LTA ratio
threshold = 0.6 * max(ratio); % threshold for detecting an event
for i = n_lta+1:length(x)
    if ratio(i) > threshold
        % Check for a continuous period of time during which the ratio remains high
        ind = find(ratio(i+1:i+20) >= threshold);
        len = length(ind) / 20; % length of continuous period
        if len > 0.5
            time_start = i / fsamp; % event start time
            break
        end
    end
end

% Plot the results
figure
subplot(2, 1, 1)
plot(t, ratio)
xlabel('Time (s)')
ylabel('STA/LTA ratio')
title('Event Detection Using STA/LTA Ratio Method')
subplot(2, 1, 2)
plot(t, data)
xlabel('Time (s)')
ylabel('Amplitude')
title('Seismic Data')
hold on
plot([time_start, time_start], ylim, 'r--')
legend('Data', 'Event Start Time')

end
