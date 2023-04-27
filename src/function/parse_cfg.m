function [SENSITIVITY, a0, pole_num, zero_num, poles, zeros] = parse_cfg(filename)
% 打开文件
fid = fopen(filename, 'r');

% 初始化变量
SENSITIVITY = 0; % 电压灵敏度
a0 = 0; % 归一化系数
pole_num = 0; % 极点个数
zero_num = 0; % 零点个数
poles = []; % 极点
zeros = []; % 零点

% 逐行读取文件内容
while ~feof(fid)
    line = fgetl(fid);  % 读取一行
    tokens = strsplit(line, {' ', '\t'}, 'CollapseDelimiters', true);  % 拆分行内容，包括空格和制表符
    
    if isempty(tokens)
        continue;
    end
    
    % 使用 startsWith 检查关键字并提取相应的数据
    if startsWith(line, 'SENSITIVITY')
        SENSITIVITY = str2double(tokens{2});
    elseif startsWith(line, 'AO')
        a0 = str2double(tokens{2});
    elseif startsWith(line, 'POLE_NUM')
        pole_num = str2double(tokens{2});
    elseif startsWith(line, 'POLE')
        pole_index = str2double(tokens{1}(6:end));
        pole_real = str2double(tokens{2});
        pole_imag = str2double(tokens{3});
        poles(pole_index+1, 1) = complex(pole_real, pole_imag);
    elseif startsWith(line, 'ZERO_NUM')
        zero_num = str2double(tokens{2});
    elseif startsWith(line, 'ZERO')
        zero_index = str2double(tokens{1}(6:end));
        zero_real = str2double(tokens{2});
        zero_imag = str2double(tokens{3});
        zeros(zero_index+1, 1) = complex(zero_real, zero_imag);
    end
end

% 关闭文件
fclose(fid);
end
