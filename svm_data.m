%% LIBSVM���ݸ�ʽ�Ű�
% ע����һ�����ڶ����ֿ����
% chenmz 9.22
%
clc; clear all; close all

%% ��һ����������
% for i=1:1:7
%     data = load(sprintf('%d.txt',i));  % 1.�޸��ļ���
%     a = find(data(:,1) == 6);
%     b = find(data(:,1) == 13);
%     x1 = data(a,2);
%     x2 = data(b,2);
%     m = length(x1);
%     n = length(x2);
%     len = min([m, n]);
%     X = [x1(1:len) x2(1:len)];
%     y = ones(len,1);
%     y = y * i;  % 2.�޸�labels
% end

data = load('��¥��1.txt');  % 1.�޸��ļ���
a = find(data(:,1) == 6);
b = find(data(:,1) == 13);
x1 = data(a,2);
x2 = data(b,2);
m = length(x1);
n = length(x2);
len = min([m, n]);
X = [x1(1:len) x2(1:len)];
y = zeros(len,1);
fid = fopen('D:\ZIGBEE��λ\fingerprint-svm\upstairs1.txt','w+'); 
for i=1:1:len
    fprintf(fid,'%d 1:%d 2:%d\n',y(i),X(i,1),X(i,2));
end
fclose(fid);

% data = load('all-¥��2.txt');
% y = data(:,3);
% X = data(:,1:2);
% [y X]

%% �ڶ�����ʽ�Ű� ��ӡ���ն� 
% ע�������txt�ĵ����ļ�������Ӣ��
data = load('all-¥��3.txt');
fp = fopen('D:\ZIGBEE��λ\fingerprint-svm\all-stair6.txt','w+');
len = size(data, 1);
for i=1:1:len
    fprintf(fp,'%d 1:%d 2:%d\n', data(i,1), data(i,2), data(i,3));
end
fclose(fp);

data = load('��¥��2.txt');
fp = fopen('D:\ZIGBEE��λ\fingerprint-svm\upstairs.txt','w+');
len = size(data, 1);
for i=1:1:len
    fprintf(fp,'%d 1:%d 2:%d\n', data(i,1), data(i,2), data(i,3));
end
fclose(fp);

