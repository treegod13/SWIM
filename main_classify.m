%% CSI process
% chenmz
% 2017.5.3

%% Initialization
clear ; close all; clc

%% Stopped state evaluation
% Extract CSI from 35 locations data 
fprintf('\n ####Now begin Pilot test - stopped state.### \n \n');
location_num = 35;
X_train = zeros(1, 180);
X_test = zeros(1, 180);
y_train = zeros(1,1);
y_test = zeros(1,1);
for i=1:1:location_num
    fprintf('Reading csi from location: %d \n', i);
    [ amp_csi_a, amp_csi_b, amp_csi_c, ...
      pha_csi_a, pha_csi_b, pha_csi_c ] = ...
      read_csi(sprintf('./sample_data/yz2_exp/78exp/sailing/%d', i));
  
    len_data = size(amp_csi_a, 1);
    test_len = floor(len_data/5);
    data_index = randperm(len_data);
    test_index = data_index(1:test_len);
    train_index = data_index(test_len+1:end);
    
    X_test = [X_test; amp_csi_a(test_index,:) pha_csi_a(test_index,:) amp_csi_b(test_index,:) ...
               pha_csi_b(test_index,:) amp_csi_c(test_index,:) pha_csi_c(test_index,:)];
    y_test = [y_test; i * ones(test_len, 1)];
    
    X_train = [X_train; amp_csi_a(train_index,:) pha_csi_a(train_index,:) amp_csi_b(train_index,:)...
               pha_csi_b(train_index,:) amp_csi_c(train_index,:) pha_csi_c(train_index,:)];
    y_train = [y_train; i * ones(len_data - test_len, 1)];    
end
X_train(1, :) = [];
y_train(1, :) = [];
X_test(1, :) = [];
y_test(1, :) = [];
X_train(isinf(X_train)==1) = 0; 
X_test(isinf(X_test)==1) = 0; 

% Sample Experiments
exp_sample_results = zeros(5,1);
sample_number = [20, 40, 60, 80, 100];
for i=1:1:length(sample_number)
    sam = sample_number(i);
    fprintf('Now test accuracy of sample number: %d \n', sample_number(i));
    y_train_sample = zeros(1, 1);   
    X_train_sample = zeros(1, 180);
    y_test_sample = zeros(1, 1); 
    X_test_sample = zeros(1, 180);
    for l = 1:1:location_num
        location_index = find(y_train == l);
        sample_index = location_index(randperm(length(location_index)));
        test_location_index = find(y_test == l);
        test_sample_index = test_location_index(randperm(length(test_location_index)));
        y_train_sample = [y_train_sample; y_train(sample_index(1:sample_number(i)))];
        X_train_sample = [X_train_sample; X_train(sample_index(1:sample_number(i)), :)];
        y_test_sample = [y_test_sample; y_test(test_sample_index(1:sample_number(1)))];
        X_test_sample = [X_test_sample; X_test(test_sample_index(1:sample_number(1)), :)];
        
    end
    y_train_sample(1) = [];
    X_train_sample(1,:) = [];
    y_test_sample(1) = [];
    X_test_sample(1,:) = [];
    
    fprintf('Now prepare SVM... \n');
    fp = fopen('D:\ZIGBEE定位\CSI\matlab\sample_data\svm_train','w+');
    len = size(X_train_sample, 1);
    for k=1:1:len
        fprintf(fp,'%d ', y_train_sample(k));
        for j = 1:1:size(X_train_sample, 2)
            fprintf(fp,'%d:%d ', j, X_train_sample(k,j));
        end
        fprintf(fp,'\n');    
    end
    fclose(fp);
    
    fp = fopen('D:\ZIGBEE定位\CSI\matlab\sample_data\svm_test','w+');
    len = size(X_test_sample, 1);
    for k=1:1:len
        fprintf(fp,'%d ', y_test_sample(k));
        for j = 1:1:size(X_test_sample, 2)
            fprintf(fp,'%d:%d ', j, X_test_sample(k,j));
        end
        fprintf(fp,'\n');    
    end
    fclose(fp);
        
    fprintf('Now train the SVM model... \n');
    [train_label, train_feature] = libsvmread('./sample_data/svm_train');
    C = 512.0; gamma = 0.0001220703125;
    model = svmtrain(train_label, train_feature, sprintf('-g %d -c %d -q',gamma,C));  % train model
    
    fprintf('The Accuracy is: \n');   
    [test_label, test_feature] = libsvmread('./sample_data/svm_test');    
    [pred_label, accuracy, prob_estimates] = svmpredict(test_label, ...
                                test_feature, model);
    exp_sample_results(i) = accuracy(1);           
    
    
end

% Link Experiments
exp_link_results = zeros(3,1);
link_number = [1, 2, 3];
sample_number = 500;
test_number = 20;

for i=1:1:length(link_number)
    fprintf('Now test accuracy of link number: %d \n', link_number(i));
    y_train_sample = zeros(1, 1);   
    X_train_sample = zeros(1, link_number(i)*60);
    y_test_sample = zeros(1, 1); 
    X_test_sample = zeros(1, link_number(i)*60);
    for l = 1:1:location_num
        location_index = find(y_train == l);
        sample_index = location_index(randperm(length(location_index)));
        test_location_index = find(y_test == l);
        test_sample_index = test_location_index(randperm(length(test_location_index)));
        y_train_sample = [y_train_sample; y_train(sample_index(1:sample_number))];
        X_train_sample = [X_train_sample; X_train(sample_index(1:sample_number), 1:link_number(i)*60)];
        y_test_sample = [y_test_sample; y_test(test_sample_index(1:test_number))];
        X_test_sample = [X_test_sample; X_test(test_sample_index(1:test_number), 1:link_number(i)*60)];
        
    end
    y_train_sample(1) = [];
    X_train_sample(1,:) = [];
    y_test_sample(1) = [];
    X_test_sample(1,:) = [];
    
    fprintf('Now prepare SVM... \n');
    fp = fopen('D:\ZIGBEE定位\CSI\matlab\sample_data\svm_train','w+');
    len = size(X_train_sample, 1);
    for k=1:1:len
        fprintf(fp,'%d ', y_train_sample(k));
        for j = 1:1:size(X_train_sample, 2)
            fprintf(fp,'%d:%d ', j, X_train_sample(k,j));
        end
        fprintf(fp,'\n');    
    end
    fclose(fp);
    
    fp = fopen('D:\ZIGBEE定位\CSI\matlab\sample_data\svm_test','w+');
    len = size(X_test_sample, 1);
    for k=1:1:len
        fprintf(fp,'%d ', y_test_sample(k));
        for j = 1:1:size(X_test_sample, 2)
            fprintf(fp,'%d:%d ', j, X_test_sample(k,j));
        end
        fprintf(fp,'\n');    
    end
    fclose(fp);
        
    fprintf('Now train the SVM model... \n');
    [train_label, train_feature] = libsvmread('./sample_data/svm_train');
    C = 512.0; gamma = 0.0001220703125;
    model = svmtrain(train_label, train_feature, sprintf('-g %d -c %d -q',gamma,C));  % train model
    
    fprintf('The Accuracy is: \n');   
    [test_label, test_feature] = libsvmread('./sample_data/svm_test');    
    [pred_label, accuracy, prob_estimates] = svmpredict(test_label, ...
                                test_feature, model);
    exp_link_results(i) = accuracy(1);           
    
    
end




%% Stop-Sail Evaluation
fprintf('\n ####Now begin Pilot test - stopped - sailing state.### \n \n');
location_num = 35;
X_train = zeros(1, 180);
X_test = zeros(1, 180);
y_train = zeros(1,1);
y_test = zeros(1,1);
for i=1:1:location_num
    fprintf('Reading stopped csi from location: %d \n', i);
    [ amp_csi_a, amp_csi_b, amp_csi_c, ...
      pha_csi_a, pha_csi_b, pha_csi_c ] = ...
      read_csi(sprintf('./sample_data/yz2_exp/78exp/anchor/%d', i));   
    X_train = [X_train; amp_csi_a amp_csi_b amp_csi_c...
               pha_csi_a pha_csi_b pha_csi_c];
    y_train = [y_train; i * ones(size(amp_csi_a,1), 1)];    
end

for i=1:1:location_num
    fprintf('Read sailing csi from location: %d \n', i);
    [ amp_csi_a, amp_csi_b, amp_csi_c, ...
      pha_csi_a, pha_csi_b, pha_csi_c ] = ...
      read_csi(sprintf('./sample_data/yz2_exp/78exp/sailing/%d', i));
    X_test = [X_test; amp_csi_a amp_csi_b amp_csi_c...
               pha_csi_a pha_csi_b pha_csi_c];
    y_test = [y_test; i * ones(size(amp_csi_a,1), 1)];       
end

X_train(1, :) = [];
y_train(1, :) = [];
X_test(1, :) = [];
y_test(1, :) = [];
X_train(isinf(X_train)==1) = 0; 
X_test(isinf(X_test)==1) = 0; 

% Sample Experiments
exp_sample_results = zeros(5,1);
sample_number = [20, 40, 60, 80, 100];
for i=1:1:length(sample_number)
    sam = sample_number(i);
    fprintf('Now test accuracy of sample number: %d \n', sample_number(i));
    y_train_sample = zeros(1, 1);   
    X_train_sample = zeros(1, 180);
    y_test_sample = zeros(1, 1); 
    X_test_sample = zeros(1, 180);
    for l = 1:1:location_num
        location_index = find(y_train == l);
        sample_index = location_index(randperm(length(location_index)));
        test_location_index = find(y_test == l);
        test_sample_index = test_location_index(randperm(length(test_location_index)));
        y_train_sample = [y_train_sample; y_train(sample_index(1:sample_number(i)))];
        X_train_sample = [X_train_sample; X_train(sample_index(1:sample_number(i)), :)];
        y_test_sample = [y_test_sample; y_test(test_sample_index(1:sample_number(1)))];
        X_test_sample = [X_test_sample; X_test(test_sample_index(1:sample_number(1)), :)];        
    end
    y_train_sample(1) = [];
    X_train_sample(1,:) = [];
    y_test_sample(1) = [];
    X_test_sample(1,:) = [];
    
    fprintf('Now prepare the SVM... \n');
    fp = fopen('D:\ZIGBEE定位\CSI\matlab\sample_data\svm_train','w+');
    len = size(X_train_sample, 1);
    for k=1:1:len
        fprintf(fp,'%d ', y_train_sample(k));
        for j = 1:1:size(X_train_sample, 2)
            fprintf(fp,'%d:%d ', j, X_train_sample(k,j));
        end
        fprintf(fp,'\n');    
    end
    fclose(fp);
    
    fp = fopen('D:\ZIGBEE定位\CSI\matlab\sample_data\svm_test','w+');
    len = size(X_test_sample, 1);
    for k=1:1:len
        fprintf(fp,'%d ', y_test_sample(k));
        for j = 1:1:size(X_test_sample, 2)
            fprintf(fp,'%d:%d ', j, X_test_sample(k,j));
        end
        fprintf(fp,'\n');    
    end
    fclose(fp);
        
    fprintf('Now train the SVM model... \n');
    [train_label, train_feature] = libsvmread('./sample_data/svm_train');
    C = 512.0; gamma = 0.0001220703125;
    model = svmtrain(train_label, train_feature, sprintf('-g %d -c %d -q',gamma,C));  % train model
    
    fprintf('The Accuracy is: \n');   
    [test_label, test_feature] = libsvmread('./sample_data/svm_test');    
    [pred_label, accuracy, prob_estimates] = svmpredict(test_label, ...
                                test_feature, model);
    exp_sample_results(i) = accuracy(1);             
    
end



%%

% fprintf('\n Now prepare for SVM. \n \n'); % Write into LibSVM file
% fp = fopen('D:\ZIGBEE定位\CSI\matlab\sample_data\svm.data','w+');
% len = size(X_train, 1);
% for i=1:1:len
%     fprintf(fp,'%d ', y_train(i));
%     for j = 1:1:size(X_train, 2)
%         fprintf(fp,'%d:%d ', j, X_train(i,j));
%     end
%     fprintf(fp,'\n');    
% end
% fclose(fp);

% SVM test
[label, feature] = libsvmread('D:\Linux\share\datasets\2exp');

% C = 512.0; gamma = 0.0001220703125;
C = 1.0; gamma = 0.07;
% Accuracy = svmtrain(label, feature, sprintf('-g %d -c %d -v 5',gamma,C));
model = svmtrain(label, feature, sprintf('-g %d -c %d',gamma,C));  % train model

% test
% test_label = zeros(len, 1);
[pred_label, accuracy, prob_estimates] = svmpredict(test_label, ...
                                test_feature, model);



fp = fopen('D:\ZIGBEE定位\CSI\matlab\sample_data\2test.data','w+');
len = size(X_test, 1);
for i=1:1:len
    fprintf(fp,'%d ', y_test(i));
    for j = 1:1:size(X_test, 2)
        fprintf(fp,'%d:%d ', j, X_test(i,j));
    end
    fprintf(fp,'\n');    
end
fclose(fp);

% For a whole dataset
X = zeros(1, 180);
y = zeros(1,1);
for i=1:1:30
    [ amp_csi_a, amp_csi_b, amp_csi_c, ...
      pha_csi_a, pha_csi_b, pha_csi_c ] = ...
      read_csi(sprintf('./sample_data/2_exp/%d', i));
    X = [X; amp_csi_a amp_csi_b amp_csi_c ...
               pha_csi_a pha_csi_b pha_csi_c];
    y = [y; i * ones(size(amp_csi_a, 1), 1)];
end
X(find(X==-Inf)) = 0;
X(1, :) = [];
y(1, :) = [];

fp = fopen('D:\ZIGBEE定位\CSI\matlab\sample_data\2exp','w+');
len = size(X, 1);
for i=1:1:len
    fprintf(fp,'%d ', y(i));
    for j = 1:1:size(X, 2)
        fprintf(fp,'%d:%d ', j, X(i,j));
    end
    fprintf(fp,'\n');    
end
fclose(fp);
save exp2_svm X y 

% % For a whole dataset ---RSSI
% X = zeros(1, 3);
% y = zeros(1,1);
% for i=1:1:16
%     data = read_bf_file(sprintf('./sample_data/locations/%d', i));
%     len = length(data);    
%     for j = 1:1:len
%         rssi(j,:) = [data{j}.rssi_a data{j}.rssi_b data{j}.rssi_c];
%     end
%     X = [X; rssi];
%     y = [y; i * ones(size(rssi, 1), 1)];
% end
% X(1, :) = [];
% y(1, :) = [];
% 
% fp = fopen('D:\ZIGBEE定位\CSI\matlab\sample_data\positions-rssi','w+');
% len = size(X, 1);
% for i=1:1:len
%     fprintf(fp,'%d ', y(i));
%     for j = 1:1:size(X, 2)
%         fprintf(fp,'%d:%d ', j, X(i,j));
%     end
%     fprintf(fp,'\n');    
% end
% fclose(fp);
% 

%% SVM

[label, feature] = libsvmread('D:\Linux\share\datasets\2exp');

% random select test sets
ran = randperm(length(label));
index = ran(1:500);
test_feature = feature(index, :);
test_label = label(index, :);
feature(index, :) = [];
label(index, :) = [];

% train model
% C = 512.0; gamma = 0.0001220703125;
C = 1.0; gamma = 0.07;
Accuracy = svmtrain(label, feature, sprintf('-g %d -c %d -v 5',gamma,C));
% model = svmtrain(label, feature, sprintf('-g %d -c %d',gamma,C));

% test
% test_label = zeros(len, 1);
[pred_label, accuracy, prob_estimates] = svmpredict(test_label, ...
                                test_feature, model);
results_1 = [pred_label test_label];

for k = 1:1:16
   ind = find(results_1(:,2)==k); 
   sum = length(ind);
   wro = length(find(results_1(ind,1)==k));
   accy1(k) = wro/sum;
end

[label, feature] = libsvmread('D:\Linux\share\datasets\positions-rssi');

% random select test sets
ran = randperm(length(label));
index = ran(1:500);
test_feature = feature(index, :);
test_label = label(index, :);
feature(index, :) = [];
label(index, :) = [];

% train model
C = 8.0; gamma = 0.125;
% Accuracy = svmtrain(label, feature, sprintf('-g %d -c %d -v 5',gamma,C));
model = svmtrain(label, feature, sprintf('-g %d -c %d',gamma,C));

% test
% test_label = zeros(len, 1);
[pred_label, accuracy, prob_estimates] = svmpredict(test_label, ...
                                test_feature, model);
results_2 = [pred_label test_label];

for k = 1:1:16
   ind = find(results_2(:,2)==k); 
   sum = length(ind);
   wro = length(find(results_2(ind,1)==k));
   accy2(k) = wro/sum;
end


figure; hold on
b = bar([accy1' accy2'], 1);
axis([0 17 0 1])
ylabel('Precision')
xlabel('Position index')
legend('CSI', 'RSSI')
hold off

%% Using CNN

% For a whole dataset
X = zeros(1, 60, 60, 3);
y = zeros(1,1);
for i=1:1:16
    [ amp_csi_a, amp_csi_b, amp_csi_c, ...
      pha_csi_a, pha_csi_b, pha_csi_c ] = ...
      read_csi(sprintf('./sample_data/3_exp/man2/%d', i));

    n = floor(size(amp_csi_a, 1)/60);   
    
    t1 = [amp_csi_a, pha_csi_a];
    t1_eff = t1(1:60*n, :, :);
    f1 = reshape(t1_eff', 60, 60, n);
    
    t2 = [amp_csi_b, pha_csi_b];
    t2_eff = t2(1:60*n, :, :);
    f2 = reshape(t2_eff', 60, 60, n);   
    
    t3 = [amp_csi_c, pha_csi_c];
    t3_eff = t3(1:60*n, :, :);
    f3 = reshape(t3_eff', 60, 60, n);
    
    F(:,:,:,1) = f1;
    F(:,:,:,2) = f2;
    F(:,:,:,3) = f3;

    F = permute(F,[3,1,2,4]);
    X = cat(1,X,F);
    
    y = [y; (i-1) * ones(n, 1)];
    clear F
end
X = X(2:end,:,:,:);
y(1, :) = [];
% X(find(X==-Inf)) = 0;
X(X==-Inf) = 0;
save exp2_man2 X y

%% Figure 12

% Figure 12_1
acc_stop = [77.8571 95.57 99.28 99.50] / 100;
acc_sail = [0.4257 0.5257 0.61 0.625];
figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
b = bar([acc_stop' acc_sail']);
% b(2).FaceColor = 'r';
legend('Stopped', 'Sailing', 'Location', 'SouthEast')
ylabel('Location Distinction Accuracy')
xlabel('Number of Links')
% axis([0 4.2 0 1])
box on
set(gca,'xtick',[1 2 3 4])
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\12_1.eps');

% Figure 12_2
acc_stop = [81.14 95.57 97.4286 99.4286] / 100;
acc_sail = [0.4371 0.5314 0.6245 0.6928];
figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
b = bar([acc_stop' acc_sail']);
% b(2).FaceColor = 'r';
legend('Stopped', 'Sailing', 'Location', 'SouthEast')
ylabel('Location Distinction Accuracy')
xlabel('Number of Links')
% axis([0 4.2 0 1])
box on
set(gca,'xtick',[1 2 3 4])
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\12_2.eps');

% Figure 12_3
acc_stop = [80.0000 85.8571 91.8571 92.2857 95.2857] / 100;
acc_sail = [0.414 0.428 0.50 0.542 0.568];
figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
b = bar([acc_stop' acc_sail']);
% b(2).FaceColor = 'r';
legend('Stopped', 'Sailing', 'Location', 'SouthEast')
ylabel('Location Distinction Accuracy')
xlabel('Number of Samples')
% axis([0 4.2 0 1])
box on
set(gca,'xticklabel',{' ' '20', '40', '60', '80', '100'})
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\12_3.eps');

% Figure 12_4
acc_stop = [90.8571 93.4286 93.7143 95.8571 96.8571] / 100;
acc_sail = [0.498 0.50 0.52 0.537 0.564];
figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
b = bar([acc_stop' acc_sail']);
% b(2).FaceColor = 'r';
legend('Stopped', 'Sailing', 'Location', 'SouthEast')
ylabel('Location Distinction Accuracy')
xlabel('Number of Samples')
% axis([0 4.2 0 1])
box on
set(gca,'xticklabel',{' ' '20', '40', '60', '80', '100'})
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\12_4.eps');

%%
% Map function
[ amp_csi_a, amp_csi_b, amp_csi_c, ...
  pha_csi_a, pha_csi_b, pha_csi_c ] = ...
  read_csi(sprintf('./sample_data/yz2_exp/78exp/anchor/%d', 13));  
% X_map_a = [ones(length(amp_csi_a), 1) amp_csi_a];
% X_map_b = [ones(length(amp_csi_a), 1) amp_csi_b];
% X_map_c = [ones(length(amp_csi_a), 1) amp_csi_c];
training_set = 500;
X_map_a = amp_csi_a(1:training_set, :);
X_map_b = amp_csi_b(1:training_set, :);
X_map_c = amp_csi_c(1:training_set, :);
X_map_a(isinf(X_map_a)==1) = 0; 
X_map_b(isinf(X_map_b)==1) = 0; 
X_map_c(isinf(X_map_c)==1) = 0; 

[ amp_csi_a, amp_csi_b, amp_csi_c, ...
  pha_csi_a, pha_csi_b, pha_csi_c ] = ...
  read_csi(sprintf('./sample_data/yz2_exp/78exp/sailing/%d', 13));   
Y_map_a = amp_csi_a(1:training_set, :);  
Y_map_b = amp_csi_b(1:training_set, :);  
Y_map_c = amp_csi_c(1:training_set, :);  
Y_map_a(isinf(Y_map_a)==1) = 0; 
Y_map_b(isinf(Y_map_b)==1) = 0; 
Y_map_c(isinf(Y_map_c)==1) = 0; 


% Y_map(isinf(Y_map)==1) = 0; 
% X_map(X_map==inf) = 0;
% X_map(X_map==-inf) = 0;
% Y_map(Y_map==inf) = 0;
% Y_map(Y_map==-inf) = 0;

save exp8.mat X_map_a X_map_b X_map_c Y_map_a Y_map_b Y_map_c

load W

% Load training dataset
fprintf('\n ####Now begin test - stopped - sailing state.### \n \n');
% location_sample = [7, 8, 9, 12, 13, 14, 17, 18, 19];
location_sample = [5, 21];
X_train = zeros(1, 90);
X_test = zeros(1, 90);
y_train = zeros(1,1);
y_test = zeros(1,1);

for i=1:1:length(location_sample)
    fprintf('Reading stopped csi from location: %d \n', location_sample(i));
    [ amp_csi_a, amp_csi_b, amp_csi_c, ...
      pha_csi_a, pha_csi_b, pha_csi_c ] = ...
      read_csi(sprintf('./sample_data/yz2_exp/78exp/anchor/%d', location_sample(i)));
    bias = ones(size(amp_csi_a,1), 1);
    X_train = [X_train; amp_csi_a*W_1 amp_csi_b*W_2 amp_csi_c*W_3];
    y_train = [y_train; location_sample(i) * ones(size(amp_csi_a,1), 1)];    
end

for i=1:1:length(location_sample)
    fprintf('Read sailing csi from location: %d \n', location_sample(i));
    [ amp_csi_a, amp_csi_b, amp_csi_c, ...
      pha_csi_a, pha_csi_b, pha_csi_c ] = ...
      read_csi(sprintf('./sample_data/yz2_exp/78exp/sailing/%d', location_sample(i)));
    X_test = [X_test; amp_csi_a amp_csi_b amp_csi_c];
    y_test = [y_test; location_sample(i) * ones(size(amp_csi_a,1), 1)];       
end

X_train(1, :) = [];
y_train(1, :) = [];
X_test(1, :) = [];
y_test(1, :) = [];
X_train(isinf(X_train)==1) = 0; 
X_test(isinf(X_test)==1) = 0; 
X_train(isnan(X_train)==1) = 0;
X_test(isinf(X_test)==1) = 0; 



% SVM classification
fprintf('Now prepare the SVM... \n');
fp = fopen('D:\ZIGBEE定位\CSI\matlab\sample_data\svm_train','w+');
len = size(X_train, 1);
for k=1:1:len
    fprintf(fp,'%d ', y_train(k));
    for j = 1:1:size(X_train, 2)
        fprintf(fp,'%d:%d ', j, X_train(k,j));
    end
    fprintf(fp,'\n');    
end
fclose(fp);

fp = fopen('D:\ZIGBEE定位\CSI\matlab\sample_data\svm_test','w+');
len = size(X_test, 1);
for k=1:1:len
    fprintf(fp,'%d ', y_test(k));
    for j = 1:1:size(X_test, 2)
        fprintf(fp,'%d:%d ', j, X_test(k,j));
    end
    fprintf(fp,'\n');    
end
fclose(fp);

fprintf('Now train the SVM model... \n');
[train_label, train_feature] = libsvmread('./sample_data/svm_train');
C = 512.0; gamma = 0.0001220703125;
model = svmtrain(train_label, train_feature, sprintf('-g %d -c %d -q',gamma,C));  % train model

fprintf('The Accuracy is: \n');   
[test_label, test_feature] = libsvmread('./sample_data/svm_test');    
[pred_label, accuracy, prob_estimates] = svmpredict(test_label, ...
                            test_feature, model);
                        
                        


% Sample Experiments
exp_sample_results = zeros(5,1);
sample_number = [20, 40, 60, 80, 100];
for i=1:1:length(sample_number)
    sam = sample_number(i);
    fprintf('Now test accuracy of sample number: %d \n', sample_number(i));
    y_train_sample = zeros(1, 1);   
    X_train_sample = zeros(1, 180);
    y_test_sample = zeros(1, 1); 
    X_test_sample = zeros(1, 180);
    for l = 1:1:location_num
        location_index = find(y_train == l);
        sample_index = location_index(randperm(length(location_index)));
        test_location_index = find(y_test == l);
        test_sample_index = test_location_index(randperm(length(test_location_index)));
        y_train_sample = [y_train_sample; y_train(sample_index(1:sample_number(i)))];
        X_train_sample = [X_train_sample; X_train(sample_index(1:sample_number(i)), :)];
        y_test_sample = [y_test_sample; y_test(test_sample_index(1:sample_number(1)))];
        X_test_sample = [X_test_sample; X_test(test_sample_index(1:sample_number(1)), :)];        
    end
    y_train_sample(1) = [];
    X_train_sample(1,:) = [];
    y_test_sample(1) = [];
    X_test_sample(1,:) = [];
    
    fprintf('Now prepare the SVM... \n');
    fp = fopen('D:\ZIGBEE定位\CSI\matlab\sample_data\svm_train','w+');
    len = size(X_train_sample, 1);
    for k=1:1:len
        fprintf(fp,'%d ', y_train_sample(k));
        for j = 1:1:size(X_train_sample, 2)
            fprintf(fp,'%d:%d ', j, X_train_sample(k,j));
        end
        fprintf(fp,'\n');    
    end
    fclose(fp);
    
    fp = fopen('D:\ZIGBEE定位\CSI\matlab\sample_data\svm_test','w+');
    len = size(X_test_sample, 1);
    for k=1:1:len
        fprintf(fp,'%d ', y_test_sample(k));
        for j = 1:1:size(X_test_sample, 2)
            fprintf(fp,'%d:%d ', j, X_test_sample(k,j));
        end
        fprintf(fp,'\n');    
    end
    fclose(fp);
        
    fprintf('Now train the SVM model... \n');
    [train_label, train_feature] = libsvmread('./sample_data/svm_train');
    C = 512.0; gamma = 0.0001220703125;
    model = svmtrain(train_label, train_feature, sprintf('-g %d -c %d -q',gamma,C));  % train model
    
    fprintf('The Accuracy is: \n');   
    [test_label, test_feature] = libsvmread('./sample_data/svm_test');    
    [pred_label, accuracy, prob_estimates] = svmpredict(test_label, ...
                                test_feature, model);
    exp_sample_results(i) = accuracy(1);             
    
end















  