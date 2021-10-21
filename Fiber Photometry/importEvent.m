 function [event, dataArray] = importEvent(filename, startRow, endRow)
%IMPORTFILE 将文本文件中的数值数据作为矩阵导入。
%   EVENT = IMPORTEVENT(FILENAME) 读取文本文件 FILENAME 中默认选定范围的数据。
%
%   EVENT = IMPORTEVENT(FILENAME, STARTROW, ENDROW) 读取文本文件
%   FILENAME 的 STARTROW 行到 ENDROW 行中的数据。
%
% Example:
%   event = importEvent('event_201806211528.txt', 17, 56);

%% 初始化变量。
delimiter = ','; % '\t'
if nargin<=2
    startRow = 17;
    endRow = inf;
    [filename, pathname] = uigetfile('*.*', 'Select Event csv File');
    cd(pathname)
end

%% 每个文本行的格式:
%   列1: 双精度值 (%f)
%	列2: 文本 (%s)
%   列3: 双精度值 (%f)
%	列4: 双精度值 (%f)
%   列5: 文本 (%s)
%	列6: 文本 (%s)
%   列7: 文本 (%s)
%	列8: 文本 (%s)
%   列9: 文本 (%s)
%	列10: 文本 (%s)
%   列11: 文本 (%s)
%   列12: 文本 (%s)
% headerFormatSpec = '%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
dataFormatSpec = '%f%s%f%f%s%s%s%s%s%[^\n\r]';

%% 打开文本文件。
[~, token, ~] = fileparts(filename);
fileID = fopen(filename, 'r');

%% 根据格式读取数据列。
% headerArray = textscan(fileID, headerFormatSpec, 1, 'Delimiter', ...
%     delimiter, 'TextType', 'string', 'HeaderLines', startRow(1)-2, ...
%     'ReturnOnError', false, 'EndOfLine', '\r\n');

dataArray = textscan(fileID, dataFormatSpec, endRow-startRow+1, 'Delimiter', ...
    delimiter, 'TextType', 'string', 'HeaderLines', startRow-1, 'ReturnOnError', ...
    false, 'EndOfLine', '\r\n');

%% 关闭文本文件。
fclose(fileID);

%% 创建输出变量
event.Time = dataArray{:, 1};
% event.Time = round(event.Time * 10); % ~
event.Subject = dataArray{:, 5};
event.FPS = dataArray{:, 4};
event.Behavior = dataArray{:, 6};
event.Modifier1 = dataArray{:,8};
event.Comment = dataArray{:, 7};
event.Status = dataArray{:, 9};
event.Length = dataArray{:, 3}(1);
event.Length = event.Length;

%% 保存输出结果
filename = ['event_', token];
save(filename, '-struct', 'event')
end
