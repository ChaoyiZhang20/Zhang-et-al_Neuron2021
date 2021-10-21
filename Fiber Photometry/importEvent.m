 function [event, dataArray] = importEvent(filename, startRow, endRow)
%IMPORTFILE ���ı��ļ��е���ֵ������Ϊ�����롣
%   EVENT = IMPORTEVENT(FILENAME) ��ȡ�ı��ļ� FILENAME ��Ĭ��ѡ����Χ�����ݡ�
%
%   EVENT = IMPORTEVENT(FILENAME, STARTROW, ENDROW) ��ȡ�ı��ļ�
%   FILENAME �� STARTROW �е� ENDROW ���е����ݡ�
%
% Example:
%   event = importEvent('event_201806211528.txt', 17, 56);

%% ��ʼ��������
delimiter = ','; % '\t'
if nargin<=2
    startRow = 17;
    endRow = inf;
    [filename, pathname] = uigetfile('*.*', 'Select Event csv File');
    cd(pathname)
end

%% ÿ���ı��еĸ�ʽ:
%   ��1: ˫����ֵ (%f)
%	��2: �ı� (%s)
%   ��3: ˫����ֵ (%f)
%	��4: ˫����ֵ (%f)
%   ��5: �ı� (%s)
%	��6: �ı� (%s)
%   ��7: �ı� (%s)
%	��8: �ı� (%s)
%   ��9: �ı� (%s)
%	��10: �ı� (%s)
%   ��11: �ı� (%s)
%   ��12: �ı� (%s)
% headerFormatSpec = '%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
dataFormatSpec = '%f%s%f%f%s%s%s%s%s%[^\n\r]';

%% ���ı��ļ���
[~, token, ~] = fileparts(filename);
fileID = fopen(filename, 'r');

%% ���ݸ�ʽ��ȡ�����С�
% headerArray = textscan(fileID, headerFormatSpec, 1, 'Delimiter', ...
%     delimiter, 'TextType', 'string', 'HeaderLines', startRow(1)-2, ...
%     'ReturnOnError', false, 'EndOfLine', '\r\n');

dataArray = textscan(fileID, dataFormatSpec, endRow-startRow+1, 'Delimiter', ...
    delimiter, 'TextType', 'string', 'HeaderLines', startRow-1, 'ReturnOnError', ...
    false, 'EndOfLine', '\r\n');

%% �ر��ı��ļ���
fclose(fileID);

%% �����������
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

%% ����������
filename = ['event_', token];
save(filename, '-struct', 'event')
end
