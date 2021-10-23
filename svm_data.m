%% LIBSVM数据格式排版
% 注：第一步及第二步分开完成
% chenmz 9.22
%
clc; clear all; close all

%% 第一步整理数据
% for i=1:1:7
%     data = load(sprintf('%d.txt',i));  % 1.修改文件名
%     a = find(data(:,1) == 6);
%     b = find(data(:,1) == 13);
%     x1 = data(a,2);
%     x2 = data(b,2);
%     m = length(x1);
%     n = length(x2);
%     len = min([m, n]);
%     X = [x1(1:len) x2(1:len)];
%     y = ones(len,1);
%     y = y * i;  % 2.修改labels
% end

data = load('上楼梯1.txt');  % 1.修改文件名
a = find(data(:,1) == 6);
b = find(data(:,1) == 13);
x1 = data(a,2);
x2 = data(b,2);
m = length(x1);
n = length(x2);
len = min([m, n]);
X = [x1(1:len) x2(1:len)];
y = zeros(len,1);
fid = fopen('D:\ZIGBEE定位\fingerprint-svm\upstairs1.txt','w+'); 
for i=1:1:len
    fprintf(fid,'%d 1:%d 2:%d\n',y(i),X(i,1),X(i,2));
end
fclose(fid);

% data = load('all-楼梯2.txt');
% y = data(:,3);
% X = data(:,1:2);
% [y X]

%% 第二步格式排版 打印至终端 
% 注：保存的txt文档，文件名需用英文
data = load('all-楼梯3.txt');
fp = fopen('D:\ZIGBEE定位\fingerprint-svm\all-stair6.txt','w+');
len = size(data, 1);
for i=1:1:len
    fprintf(fp,'%d 1:%d 2:%d\n', data(i,1), data(i,2), data(i,3));
end
fclose(fp);

data = load('上楼梯2.txt');
fp = fopen('D:\ZIGBEE定位\fingerprint-svm\upstairs.txt','w+');
len = size(data, 1);
for i=1:1:len
    fprintf(fp,'%d 1:%d 2:%d\n', data(i,1), data(i,2), data(i,3));
end
fclose(fp);

