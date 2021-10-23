%% libsvmʹ������
% ����libsvm���ж�����㷨
% ʹ��MATLAB��Linuxƽ̨�µĹ��������ģ��ѵ����MATLABƽ̨�½���ģ��ѵ���Լ�Ԥ�⣬
% Linuxƽ̨�½����������ż�����Ѱ��
%
% ע��1.Linux���¼root�û�
%
% chenmz 2015.9.22
%
clc; close all; clear all

%% ��һ ��������  MATLAB (��ڶ�����ѡȡһ��)
% ��MALLABƽ̨�£��������ݿ��Ŀ¼
% ��libsvmread��txt�ļ�����
% ���ݸ�ʽ�̶� �ο� breast.txt
% label����ǩ feature������ֵ
[label, feature] = libsvmread('breast.txt');

%% �ڶ� ��������  Linux �����һ����ѡ��һ����
% ����Linuxƽ̨��svm-scale�����������ݸ�ʽ������[0,1]����
% �����ݣ����磺hearte.txt�����Ƶ�D:\Linux\share\datasetsĿ¼��
% �����������£�# svm-scale heart.txt > heart_scale.txt
% ���heart_scale.txt�ļ������ƻص�ǰMATLABĿ¼����ȡ��ʾ
[label, feature] = libsvmread('heart_scale.txt');

%% ���� ����Ѱ�� ������� 
% �����������������ѵ���ķ���������������ѵ����׷����ߵľ�ȷ�Ȳ����ã������
% ������������һ��ʹ��5�۵Ľ�����顣
% ˵����
% ����Linuxƽ̨��grid.py�ļ�������grid-search�������ҳ����ʺϲ���ֵ��C��gamma
% �����������£�# grid.py heart_scale.txt
% ���heart_scale.txt.out��heart_scale.txt.png�����ƻص�ǰĿ¼
% ���Linux�ն���ʾ��2048.0 0.0001220703125 84.4444
% ������CֵΪ2048������gammaֵΪ0.0001220703125����ȷ��Ϊ84.4444
% ��ֵ����log2(2048)����log2(0.0001220703125)�򻯱�ʾΪ 2^11 ��2^-13
C = 2^11;
gamma = 2^-13;
Accuracy = svmtrain(label, feature, sprintf('-g %d -c %d -v 5',gamma,C));
% Accuracy = svmtrain(label, feature,'-v 5');

%% ���� ѵ��ģ��
% ��MATLABƽ̨�£����ò���C��gammaѵ��ģ��
% ģ��ѡ��Ĭ��C-SVC����������ʹ��RBF�ˡ�������Ĭ�ϣ�
% ����RBF�˲�����C gamma
% �������model:��model���浽heart.mat�ļ���
model = svmtrain(label, feature, sprintf('-g %d -c %d',gamma,C));
save heart model;

%% ���� ���Լ�Ԥ��
% ���Լ�ͬ��Ҳ������Ű�
% ��ѵ��ʱ���й����ţ����Լ�Ҳ���������
% ʹ�÷������£�
% 1.�����Լ��б�ǩ�������׼ȷ��
% 2.���޲��Լ���ǩ��������N*1�����������棬��ΪԤ��ֵ��  ͬʱaccuracy������
load heart.mat;
[label, feature] = libsvmread('heart.txt');
[label, feature] = libsvmread('heart_scale.txt');

len = size(label, 1);
test_label = zeros(len, 1);
[pred_label, accuracy, prob_estimates] = svmpredict(label, ...
                                feature, model);
[pred_label label]

% accuracy:3*1������ ��һ����ʾ����׼ȷ�� �ڶ�����ʾmse���ع飩 
% ��������ʾƽ�����ϵ�����ع飩
