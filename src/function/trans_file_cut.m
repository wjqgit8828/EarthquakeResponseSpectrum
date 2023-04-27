function [data01] = trans_file_cut(x01, time_start, time_len, time, fsamp)
% Cuts the seismic data around the start time of the earthquake event and
% applies bandpass filter for signal enhancement
% INPUTS:
%   x01: seismic data (1D array)
%   time_start: start time of the earthquake event in seconds
%   time_len: length of the earthquake event in seconds
%   time: time vector for the seismic data
%   fsamp: sampling frequency in Hz
% OUTPUT:
%   data01: filtered and cut seismic data (1D array)

% Remove the mean from the data
time_span = time_start - 5; % set the start time of the cut interval to 5 seconds before the event start time
[~, ind01] = min(abs(time - time_span)); % find the index of the time_span in the time vector
mean_x1 = mean(x01(1:ind01)); % compute the mean of the data before the start time
x01 = x01 - mean_x1 * ones(size(x01)); % remove the mean from the data

% Cut the data around the event start time and calculate the velocity
s_start = time_span;
s_end = s_start + time_len;
x001 = x01((s_start*fsamp):(s_end*fsamp))'; % extract the data between the start time and end time
[line, row] = size(x001); % get the dimensions of the data
x_a01 = zeros(line, row);
x_a01(2:end) = diff(x001(1:end)) / (1/fsamp); % calculate the velocity of the data

% Apply a bandpass filter for signal enhancement
hd = butterworth_bandpass(); % get the filter coefficients
[bzl, azl] = tf(hd);
data01 = filter(bzl, azl, x001); % apply the filter

end
