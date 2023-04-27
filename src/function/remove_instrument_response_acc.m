function [acc, vel, disp] = remove_instrument_response_acc(data, conversion_factor, fsamp, cfg_file)
% 该函数用于去除加速度观测数据中的仪器响应，得到真实加速度、速度和位移

% 从配置文件解析仪器响应
[sensitivity, a0, pole_num, zero_num, poles, zeros] = parse_cfg(cfg_file);

% 将观测数据转换为加速度（单位：m/s²）
data = data * conversion_factor * 1e-6; % 转换为伏 (V)
data = data / sensitivity; % 转换为加速度（m/s²） 

% 创建传递函数模型
sys = zpk(zeros, poles, a0);

% 计算仪器响应
N = length(data);
nfft = 2 ^ nextpow2(N); % 计算下一个最接近的2的幂次
f = linspace(0, fsamp / 2, nfft / 2 + 1);
[mag, phase] = bode(sys, 2 * pi * f);
mag1 = squeeze(mag);

% 去除仪器响应
data_fft = fft(data, nfft);
mag1 = [1; mag1(2:end)]; % 修复大小不一致的问题
data_fft(1:(nfft / 2) + 1) = data_fft(1:(nfft / 2) + 1) ./ mag1;
data_fft((nfft / 2) + 2:end) = conj(data_fft((nfft / 2):-1:2));

% 得到真实加速度值（单位：m/s²）
true_acceleration = real(ifft(data_fft, nfft));
true_acceleration = true_acceleration(1:N); % 修剪信号长度

% 对真实加速度进行基线校正
true_acceleration = true_acceleration - mean(true_acceleration);
true_acceleration = detrend(true_acceleration);

% 高通滤波器设置
f1 = 0.1; % 有效频率范围的下限 (Hz)
f2 = 10;  % 有效频率范围的上限 (Hz)  
nyquist_freq = fsamp / 2;
fc = (10^(-40/10))*(1000); % 截止频率 (Hz)
[b, a] = butter(4, [f1 f2] / nyquist_freq, 'bandpass');

% 计算速度值（单位：m/s）
cumulative_acc = cumsum(true_acceleration) / fsamp;
true_velocity = filtfilt(b, a, cumulative_acc);

% 计算位移值（单位：m）
cumulative_vel = cumsum(true_velocity) / fsamp;
true_displacement = filtfilt(b, a, cumulative_vel);


% 返回加速度、速度和位移结果
acc = true_acceleration;
vel = true_velocity;
disp = true_displacement;

end
