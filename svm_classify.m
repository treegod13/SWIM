%% libsvm使用流程
% 利用libsvm进行多分类算法
% 使用MATLAB和Linux平台下的工具箱进行模型训练，MATLAB平台下进行模型训练以及预测，
% Linux平台下进行数据缩放及参数寻优
%
% 注：1.Linux需登录root用户
%
% chenmz 2015.9.22
%
clc; close all; clear all

%% 第一 载入数据  MATLAB (与第二步中选取一个)
% 在MALLAB平台下，进入数据库的目录
% 用libsvmread读txt文件数据
% 数据格式固定 参考 breast.txt
% label：标签 feature：特征值
[label, feature] = libsvmread('breast.txt');

%% 第二 数据缩放  Linux （与第一步中选择一个）
% 利用Linux平台的svm-scale函数，将数据格式缩放至[0,1]区间
% 将数据（例如：hearte.txt）复制到D:\Linux\share\datasets目录下
% 输入命令如下：# svm-scale heart.txt > heart_scale.txt
% 获得heart_scale.txt文件，复制回当前MATLAB目录，读取显示
[label, feature] = libsvmread('heart_scale.txt');

%% 第三 参数寻优 交叉检验 
% 交叉检验的作用是提高训练的泛化的能力，即对训练集追求过高的精确度并不好，会产生
% 过拟合现象，因此一般使用5折的交叉检验。
% 说明：
% 利用Linux平台的grid.py文件，利用grid-search方法，找出最适合参数值：C和gamma
% 输入命令如下：# grid.py heart_scale.txt
% 获得heart_scale.txt.out及heart_scale.txt.png，复制回当前目录
% 获得Linux终端显示：2048.0 0.0001220703125 84.4444
% 即最优C值为2048，最优gamma值为0.0001220703125，精确度为84.4444
% 上值可用log2(2048)，及log2(0.0001220703125)简化表示为 2^11 及2^-13
C = 2^11;
gamma = 2^-13;
Accuracy = svmtrain(label, feature, sprintf('-g %d -c %d -v 5',gamma,C));
% Accuracy = svmtrain(label, feature,'-v 5');

%% 第四 训练模型
% 在MATLAB平台下，利用参数C和gamma训练模型
% 模型选择默认C-SVC分类器，核使用RBF核。（参数默认）
% 代入RBF核参数：C gamma
% 保存参数model:将model保存到heart.mat文件内
model = svmtrain(label, feature, sprintf('-g %d -c %d',gamma,C));
save heart model;

%% 第五 测试及预测
% 测试集同样也需进行排版
% 若训练时进行过缩放，测试集也需进行缩放
% 使用方法如下：
% 1.若测试集有标签，则计算准确率
% 2.若无测试集标签，用任意N*1的列向量代替，即为预测值。  同时accuracy无意义
load heart.mat;
[label, feature] = libsvmread('heart.txt');
[label, feature] = libsvmread('heart_scale.txt');

len = size(label, 1);
test_label = zeros(len, 1);
[pred_label, accuracy, prob_estimates] = svmpredict(label, ...
                                feature, model);
[pred_label label]

% accuracy:3*1列向量 第一个表示分类准确率 第二个表示mse（回归） 
% 第三个表示平方相关系数（回归）
