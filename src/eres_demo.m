clc; clear; close all;
addpath('..\data\');
addpath('function\');

% 加载数据
files = dir('../data/*.00*');  
for i = 1 : length(files)
    data_raw{i} = load(files(i).name);
end
filename = files(1).name;
dot_pos = find(filename == '.');   
name = files(1).name(1:dot_pos-1);  

% 参数
fsamp = 100; dt = 1 / fsamp;% 采样率 (Hz)
N = length(data_raw{1}); time = [0:N-1] / fsamp; % 时间尺度
cfg_file = '../config/js_a2.cfg'; % 仪器响应参数文件
conversion_factor = 0.0745; % 数据采集器转换因子 (uV/count)
h = 0.05; % 阻尼5%

% 定义频率和周期参数
FC = (10^(-40/10))*(1000);
f_step = 2^(1/9);
fc_totle = fix((log10(20)-log10(FC))/log10(f_step))+1;
for j = 1:fc_totle
    FFF(j) = FC * (f_step^(j-1));
end
T = 1./FFF;

% 去除仪器响应，得到加速度
for i = 1 : 3
   [acc{i}, vel{i}, disp{i}] = remove_instrument_response_acc(data_raw{i}, conversion_factor, fsamp, cfg_file);
end

% STA/LTA截取地震事件
step_sta = 0.2; step_lta = 20; 
time_start = sta_lta(acc{3}, step_sta, step_lta, fsamp);
time_len = 80; % 地震持时


for i = 1 : 3
    % 提取地震事件
    data{i} = trans_file_cut(acc{i}, time_start, time_len, time, fsamp);
    % 计算反应谱
    res{i} = ERES(h, T, dt, data{i});
    % 加速度反应谱
    Sa{i} = res{i}(:,:,1);
    % 速度反应谱
    Sv{i} = res{i}(:,:,2);
    % 位移反应谱
    Sd{i} = res{i}(:,:,3);
end

% 绘图
figure(2);
for i = 1 : 3
    semilogx(T, Sa{i}, 'LineWidth', 2); hold on; grid on;
end
legend('E','N','U'); xlabel('Time (s)') ;ylabel('Sa (m/s^2)')
title('Acceleration response spectrum (damping 5 %)')
fig_path = fullfile('../fig',[name,'_Sa','.fig']);
png_path = fullfile('../result',[name,'_Sa','.png']);
saveas(gcf, fig_path, 'fig');
saveas(gcf, png_path, 'png');

figure(3);
for i = 1 : 3
    semilogx(T, Sv{i}, 'LineWidth', 2);hold on; grid on;
end
legend('E','N','U'); xlabel('Time (s)'); ylabel('Sv (m/s)')
title('Velocity response spectrum (damping 5 %)')
fig_path = fullfile('../fig',[name,'_Sv','.fig']);
png_path = fullfile('../result',[name,'_Sv','.png']);
saveas(gcf, fig_path, 'fig');
saveas(gcf, png_path, 'png');

figure(4);
for i = 1 : 3
    semilogx(T, Sd{i}, 'LineWidth', 2);hold on; grid on;
end
legend('E','N','U'); xlabel('Time (s)'); ylabel('Sd (m)')
title('Displacement response spectrum (damping 5 %)')
fig_path = fullfile('../fig',[name,'_Sd','.fig']);
png_path = fullfile('../result',[name,'_Sd','.png']);
saveas(gcf, fig_path, 'fig');
saveas(gcf, png_path, 'png');



