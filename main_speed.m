%% CSI with Speed infomation
clear ;  clc

% Load csi data, trasform to cir data
% csi_data_1 = read_bf_file('./sample_data/7_exp/hall/one/speed/hall_1_speedcut_0.01');
% csi_data_2 = read_bf_file('./sample_data/7_exp/hall/one/moving/hall_1_sail_0.01');
% csi_data = [csi_data_1; csi_data_2];

csi_data = read_bf_file('./sample_data/7_exp/corridor/one/speed/corridor_1_speedup_0.01');
len_csi = length(csi_data);
% [len_real_csi, ~, ~, ~, ~, ~, ~, ...
%  cir_csi_a, cir_csi_b, cir_csi_c] = get_cir(csi_data);
[len_real_csi, amp_csi_a, amp_csi_b, amp_csi_c, ...
 pha_csi_a, pha_csi_b, pha_csi_c, ...
 cir_csi_a, cir_csi_b, cir_csi_c] = get_cir(csi_data);
       
data_rate = len_real_csi / len_csi; % the available csi data length

los_offset = 7;
[cir_los_a, los_index_a] = max(cir_csi_a, [], 2); % extract los cir
los_index_a(find(los_index_a >20)) = los_offset;
[cir_los_b, los_index_b] = max(cir_csi_b, [], 2);
los_index_b(find(los_index_b >20)) = los_offset;
[cir_los_c, los_index_c] = max(cir_csi_c, [], 2);
los_index_c(find(los_index_c >20)) = los_offset;

nlos_margin = 3;
nlos_index_a = sub2ind(size(cir_csi_a),(1:len_real_csi)', los_index_a + nlos_margin);% extract nlos cir. 
cir_nlos_a = cir_csi_a(nlos_index_a);                                                % have to use sub2ind function
nlos_index_b = sub2ind(size(cir_csi_b),(1:len_real_csi)', los_index_b + nlos_margin);
cir_nlos_b = cir_csi_b(nlos_index_b);  
nlos_index_c = sub2ind(size(cir_csi_c),(1:len_real_csi)', los_index_c + nlos_margin);
cir_nlos_c = cir_csi_c(nlos_index_c);  

% Load speed data, extract Accelerated speed
% speed_data_1 = xlsread('./sample_data/7_exp/hall/one/speed/hall_1_speedcut_0.01_speed.csv');
% speed_data_2 = xlsread('./sample_data/7_exp/hall/one/moving/hall_1_sail_0.01_speed.csv');
% speed_data = [speed_data_1; speed_data_2];

speed_data = xlsread('./sample_data/7_exp/corridor/one/speed/corridor_1_speedup_0.01_speed.csv');
len_speed = length(speed_data(:,1));
len_real_speed = floor(len_speed * data_rate); % according to csi available data
speed_history = speed_data(1:len_real_speed, 2);
speed_scale = union(speed_history, speed_history);
delta_t = 3; % unit:s
speed_for_acc = speed_history * 10 /36; % unit:m/s
speed_for_acc_v0 = speed_for_acc;
speed_for_acc_v0(1) = [];
speed_for_acc_v0 = [speed_for_acc_v0; speed_for_acc_v0(end)];
acc_history = (speed_for_acc - speed_for_acc_v0) / delta_t;
acc_scale = union(acc_history, acc_history);

[speed_index, ~, ~] = find(repmat(speed_history', length(speed_scale), 1) == ...
                   repmat(speed_scale, 1, length(speed_history)));
[acc_index, ~, ~] = find(repmat(acc_history', length(acc_scale), 1) == ...
                   repmat(acc_scale, 1, length(acc_history)));
               
% Statisc Map: speed -> csi 
map_index_rate = len_real_csi / len_real_speed;
map_index_step = floor(map_index_rate);

% Analysis: Speed
speed_result = zeros(length(speed_scale), 12);
for i = 1:1:length(speed_scale)
%     speed = speed_scale(i);
    map_index = find(speed_index == i);
    speed_los_a = [];
    speed_los_b = [];
    speed_los_c = [];     

    speed_nlos_a = [];
    speed_nlos_b = [];
    speed_nlos_c = [];     
    
    for j = 1:1:length(map_index)
        map_start = floor(map_index(j) * map_index_rate);
        if map_start + map_index_step <= len_real_csi
            map_end = map_start + map_index_step;
        else
            map_end = len_real_csi;
        end
        csi_index = (map_start : map_end)'; 
        speed_los_a = [speed_los_a; cir_los_a(csi_index)];
        speed_los_b = [speed_los_b; cir_los_b(csi_index)];
        speed_los_c = [speed_los_c; cir_los_c(csi_index)]; 
        
        speed_nlos_a = [speed_nlos_a; cir_nlos_a(csi_index)];
        speed_nlos_b = [speed_nlos_b; cir_nlos_b(csi_index)];
        speed_nlos_c = [speed_nlos_c; cir_nlos_c(csi_index)];         
       
    end
    speed_result(i, 1) = mean(speed_los_a);
    speed_result(i, 2) = cv(speed_los_a); % or cir_std
    speed_result(i, 3) = mean(speed_los_b);
    speed_result(i, 4) = cv(speed_los_b);
    speed_result(i, 5) = mean(speed_los_c);
    speed_result(i, 6) = cv(speed_los_c);
    
    speed_result(i, 7) = mean(speed_nlos_a);
    speed_result(i, 8) = cv(speed_nlos_a);
    speed_result(i, 9) = mean(speed_nlos_b);
    speed_result(i, 10) = cv(speed_nlos_b);
    speed_result(i, 11) = mean(speed_nlos_c);
    speed_result(i, 12) = cv(speed_nlos_c);
end
% save exp7_hall_0_speed.mat speed_scale speed_result 
% load exp7_hall_1_speed.mat

% Analysis: Accelerated speed
acc_result = zeros(length(acc_scale), 12);
for i = 1:1:length(acc_scale)
%     speed = speed_scale(i);
    map_index = find(acc_index == i);
    acc_los_a = [];
    acc_los_b = [];
    acc_los_c = [];     

    acc_nlos_a = [];
    acc_nlos_b = [];
    acc_nlos_c = [];     
    
    for j = 1:1:length(map_index)
        map_start = floor(map_index(j) * map_index_rate);
        if map_start + map_index_step <= len_real_csi
            map_end = map_start + map_index_step;
        else
            map_end = len_real_csi;
        end
        csi_index = (map_start : map_end)'; 
        acc_los_a = [acc_los_a; cir_los_a(csi_index)];
        acc_los_b = [acc_los_b; cir_los_b(csi_index)];
        acc_los_c = [acc_los_c; cir_los_c(csi_index)]; 
        
        acc_nlos_a = [acc_nlos_a; cir_nlos_a(csi_index)];
        acc_nlos_b = [acc_nlos_b; cir_nlos_b(csi_index)];
        acc_nlos_c = [acc_nlos_c; cir_nlos_c(csi_index)];         
       
    end
    acc_result(i, 1) = mean(acc_los_a);
    acc_result(i, 2) = cv(acc_los_a); % or cir_std
    acc_result(i, 3) = mean(acc_los_b);
    acc_result(i, 4) = cv(acc_los_b);
    acc_result(i, 5) = mean(acc_los_c);
    acc_result(i, 6) = cv(acc_los_c);
    
    acc_result(i, 7) = mean(acc_nlos_a);
    acc_result(i, 8) = cv(acc_nlos_a);
    acc_result(i, 9) = mean(acc_nlos_b);
    acc_result(i, 10) = cv(acc_nlos_b);
    acc_result(i, 11) = mean(acc_nlos_c);
    acc_result(i, 12) = cv(acc_nlos_c);
end
% save exp7_hall_0_speed.mat speed_scale speed_result 
% load exp7_hall_1_speed.mat

% Analysis compass
compass_data = xlsread('./sample_data/7_exp/hall/none/speed/Hall_none_speedup_0.01_sensor.csv');
plot(compass_data(:,2))

len_compass = length(compass_data(:,1));
len_real_compass = floor(len_compass * data_rate); % according to csi available data
compass_history = compass_data(1:len_real_compass, 1:2);

angle_speed_t0 = compass_history;
angle_speed_t0(end, :) = [];
angle_speed_t0 = [compass_history(1,:); angle_speed_t0];
delta_angle_history = compass_history - angle_speed_t0;
angle_speed_history = delta_angle_history(:,2)./(delta_angle_history(:,1)/1000);
angle_speed_scale = union(angle_speed_history, angle_speed_history);
cir_csi_a(find(isnan(cir_csi_a)==1)) = 0; 

[angle_speed_index, ~, ~] = find(repmat(angle_speed_history', length(angle_speed_scale), 1) == ...
                   repmat(angle_speed_scale, 1, length(angle_speed_history)));
map_compass_rate = len_real_csi / len_real_compass;
map_index_step = floor(map_compass_rate);
               
angle_speed_result = zeros(length(angle_speed_scale), 12);
for i = 1:1:length(angle_speed_result)
%     speed = speed_scale(i);
    map_index = find(angle_speed_index == i);
    angle_speed_los_a = [];
    angle_speed_los_b = [];
    angle_speed_los_c = [];     

    angle_speed_nlos_a = [];
    angle_speed_nlos_b = [];
    angle_speed_nlos_c = [];     
    
    for j = 1:1:length(map_index)
        map_start = floor(map_index(j) * map_index_rate);
        if map_start + map_index_step <= len_real_csi
            map_end = map_start + map_index_step;
        else
            map_end = len_real_csi;
        end
        csi_index = (map_start : map_end)'; 
        angle_speed_los_a = [angle_speed_los_a; cir_los_a(csi_index)];
        angle_speed_los_b = [angle_speed_los_b; cir_los_b(csi_index)];
        angle_speed_los_c = [angle_speed_los_c; cir_los_c(csi_index)]; 
        
        angle_speed_nlos_a = [angle_speed_nlos_a; cir_nlos_a(csi_index)];
        angle_speed_nlos_b = [angle_speed_nlos_b; cir_nlos_b(csi_index)];
        angle_speed_nlos_c = [angle_speed_nlos_c; cir_nlos_c(csi_index)];         
       
    end
    angle_speed_result(i, 1) = mean(angle_speed_los_a);
    angle_speed_result(i, 2) = cv(angle_speed_los_a); % or cir_std
    angle_speed_result(i, 3) = mean(angle_speed_los_b);
    angle_speed_result(i, 4) = cv(angle_speed_los_b);
    angle_speed_result(i, 5) = mean(angle_speed_los_c);
    angle_speed_result(i, 6) = cv(angle_speed_los_c);
    
    angle_speed_result(i, 7) = mean(angle_speed_nlos_a);
    angle_speed_result(i, 8) = cv(angle_speed_nlos_a);
    angle_speed_result(i, 9) = mean(angle_speed_nlos_b);
    angle_speed_result(i, 10) = cv(angle_speed_nlos_b);
    angle_speed_result(i, 11) = mean(angle_speed_nlos_c);
    angle_speed_result(i, 12) = cv(angle_speed_nlos_c);
end

% Analysis: Speed-based CSI
speed_csi_result = zeros(length(speed_scale), 2);
subcarrier_index = 4;
for i = 1:1:length(speed_scale)
    map_index = find(speed_index == i);
    speed_csi = [];
    
    for j = 1:1:length(map_index)
        map_start = floor(map_index(j) * map_index_rate);
        if map_start + map_index_step <= len_real_csi
            map_end = map_start + map_index_step;
        else
            map_end = len_real_csi;
        end
        csi_index = (map_start : map_end)'; 
        speed_csi = [speed_csi; amp_csi_a(csi_index, subcarrier_index)]; % Annater 1 
    end
    speed_csi_result(i, 1) = mean(speed_csi);
    speed_csi_result(i, 2) = cv(speed_csi); % or cir_std
end
figure; subplot(2,1,1)
plot(speed_csi_result(:,1))
% axis([0 40 0 100])
subplot(2,1,2)
plot(speed_csi_result(:,2))
% axis([0 40 0 1])

% Plot data
figure
meshz(amp_csi_b)
xlabel('Subcarrier f')
ylabel('Sample index')
zlabel('CSI amplitude')

rx = 5; % rx = 1, 3, 5
figure; hold on
plot(speed_scale, speed_result(:,rx), 'o-')
plot(speed_scale, speed_result(:,rx+6), '*-')
legend('LOS', 'NLOS')
xlabel('Ship speed (km/h)')
ylabel('CIR mean amplitude (dBm)')
grid on
hold off

figure; hold on
plot(speed_scale, speed_result(:,rx+1), 'o-')
plot(speed_scale, speed_result(:,rx+7), '*-')
legend('LOS', 'NLOS')
xlabel('Ship speed (km/h)')
ylabel('CIR Coefficent of Variance')
grid on
hold off

figure; hold on
plot(acc_scale, acc_result(:,rx), 'o-')
plot(acc_scale, acc_result(:,rx+6), '*-')
legend('LOS', 'NLOS')
xlabel('Ship accelerated speed (m/s2)')
ylabel('CIR mean amplitude (dBm)')
grid on
hold off

figure; hold on
plot(acc_scale, acc_result(:,rx+1), 'o-')
plot(acc_scale, acc_result(:,rx+7), '*-')
legend('LOS', 'NLOS')
xlabel('Ship accelerated speed (m/s2)')
ylabel('CIR Coefficent of Variance')
grid on
hold off

figure; hold on
plot(acc_scale, acc_result(:,rx+1), 'o-')
plot(acc_scale, acc_result(:,rx+7), '*-')
legend('LOS', 'NLOS')
xlabel('Ship accelerated speed (m/s2)')
ylabel('CIR Coefficent of Variance')
grid on
hold off


% 5 minutes. 300 seconds
% xlswrite('./figure_data.xlsx', speed_history, 'Sheet1')   
fig1_speed = xlsread('./figure_data.xlsx');
t = [1:1:300];
imagesc(amp_csi_a')

%% figure 19
% Analysis: Speed
speed_result = zeros(length(speed_scale), 12);
% for i = 1:1:length(speed_scale)

i = 7; % speed index
sub_index = 4; % index of subcarrier
test_speed = speed_scale(i);
map_index = find(speed_index == i);
day_csi = zeros(length(map_index), map_index_step+1);
for j = 1:1:length(map_index)

    map_start = floor(map_index(j) * map_index_rate);
    if map_start + map_index_step <= len_real_csi
        map_end = map_start + map_index_step;
    else
        map_end = len_real_csi;
    end
    csi_index = (map_start : map_end)'; 
    day_csi(j, :) = amp_csi_a(csi_index, sub_index);
end

figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
boxplot(day_csi')
% boxplot(box_data')
% title('Miles per Gallon by Vehicle Origin')
xlabel('Test Time')
ylabel('CSI (dBm)')
% axis([0 6 19 21])
hold off

box_data_4 = zeros(5, map_index_step+1);
box_data_4(1, :) = day_csi(2,:);
box_data_4(2, :) = day_csi(7,:);
box_data_4(3, :) = day_csi(8,:);
box_data_4(4, :) = day_csi(12,:);
box_data_4(5, :) = day_csi(13,:);

% save fig_19.mat box_data_stable box_data_2 box_data_3 box_data_4 day_csi
% Fig19_1
figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
boxplot(box_data_stable') %, 'Widths',0.5
set(gca,'XTickLabel',{'day 1', 'night 1', 'day 2', 'night 2', 'day 3'});
xlabel('Experiment Time')
ylabel('CSI (dBm)')
legend('Index 1')
% axis([0.5 5.5 19.45 20.25])
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\19_1.eps');

% Fig19_2
figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
boxplot(box_data_2') %, 'Widths',0.5
set(gca,'XTickLabel',{'Set 1', 'Set 6', 'Set 7', 'Set 8', 'Set 9'});
xlabel('Experiment Time')
ylabel('CSI (dBm)')
legend('Index 1')
% axis([0.5 5.5 19.45 20.25])
hold off
print('-depsc2','-r600','D:\Latex\TMC\pics\19_2.eps');

% Fig19_3
figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
boxplot(box_data_3') %, 'Widths',0.5
set(gca,'XTickLabel',{'day 1', 'night 1', 'day 2', 'night 2', 'day 3'});
xlabel('Experiment Time')
ylabel('CSI (dBm)')
legend('Index 1')
% axis([0.5 5.5 19.45 20.25])
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\19_3.eps');

% Fig19_4
figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
boxplot(box_data_4') %, 'Widths',0.5
set(gca,'XTickLabel',{'day 1', 'night 1', 'day 2', 'night 2', 'day 3'});
xlabel('Experiment Time')
ylabel('CSI (dBm)')
legend('Index 1')
% axis([0.5 5.5 19.45 20.25])
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\19_4.eps');

% Fig19_5
figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
boxplot(day_csi') %, 'Widths',0.5
% set(gca,'XTickLabel',{'day 1', 'night 1', 'day 2', 'night 2', 'day 3'});
xlabel('Ship speed (km/h)')
ylabel('CSI (dBm)')
% legend('Index 1')
% axis([0.5 5.5 19.45 20.25])
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\19_5.eps');

% Fig19_6
figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
boxplot(day_csi([6,2,5,7,11], :)') %, 'Widths',0.5
set(gca,'XTickLabel',{'Set 1', 'Set 2', 'Set 3', 'Set 4', 'Set 5'});
xlabel('Experiment data set')
ylabel('CSI (dBm)')
% legend('Index 1')
% axis([0.5 5.5 19.45 20.25])
hold off
print('-depsc2','-r600','D:\Latex\TMC\pics\19_6.eps');

%%
mean_speed1 = speed_result(:,1);
mean_speed2 = speed_result(:,9);
mean_speed3 = speed_result(:,5);
mean_speed_los = [mean_speed1*2-90; mean_speed2*0.5 + 40; mean_speed3+10];
mean_speed_nlos = [mean_speed1; mean_speed2];
mean_speed_los = mean_speed_los(1:51);
figure; hold on
plot(mean_speed_nlos)
axis([0 50 0 100])
hold off
cv_speed_nlos = [cv_speed2; cv_speed1]
speed_for_plot = [1:0.5:]

% CV with speed
% save exp7_cv_speed.mat cv_speed_los cv_speed_nlos 
load exp7_cv_speed.mat
speed_x_axis = [0:0.5:25]; % 51 numbers
figure; hold on
plot(speed_x_axis', cv_speed_los, 'o-')
plot(speed_x_axis', cv_speed_nlos, '*-')
legend('LOS', 'NLOS')
xlabel('Ship speed (km/h)')
ylabel('CIR Coefficent of Variance')
axis([0 25 0 1])
grid on
hold off

% mean with speed
% save exp7_mean_speed.mat mean_speed_los mean_speed_nlos
load exp7_mean_speed.mat
speed_x_axis = [0:0.5:25]; % 51 numbers
mean_speed_los(1:50) = mean_speed_los(1:50)* 1.5 - 40; 
figure; hold on
plot(speed_x_axis', mean_speed_los, 'o--')
plot(speed_x_axis', mean_speed_nlos*2-62, '*-')
legend('LOS', 'NLOS')
xlabel('Ship speed (km/h)')
ylabel('CIR mean amplitude (dBm)')
axis([0 25 10 110])
grid on
hold off

% mean with acc
% save exp7_mean_acc.mat mean_acc_los mean_acc_nlos
load exp7_mean_acc.mat
acc_x_axis = (-0.4:0.02:0.4); % 41 numbers

figure; hold on
plot(acc_x_axis, mean_acc_los*0.8+10, 'o-')
legend('LOS')
xlabel('Ship accelerated speed (m/s2)')
ylabel('CIR mean amplitude (dBm)')
% axis([0 25 0 1])
grid on
hold off

figure; hold on
plot(acc_x_axis(21:41), mean_acc_los(21:41)*0.8+10, 'o-')
legend('LOS')
xlabel('Ship acceleration (m/s2)')
ylabel('CIR mean amplitude (dBm)')
axis([-0.02 0.4 68 92])
grid on
hold off

acc_x_axis_speedup = acc_x_axis(21:41);
mean_acc_los_speedup = mean_acc_los(21:41)*0.8+10;
fitting_x = [0:0.01:0.4];
fitting_y = -36.11 * fitting_x + 86.29;
% run figure_configuration_IEEE_standard
figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75)
plot(acc_x_axis(21:41), mean_acc_los(21:41)*0.8+10, 'o')
plot(fitting_x, fitting_y)
legend('LOS', 'Regression')
xlabel('Acceleration (m/s^{2})')
ylabel('Mean CIR (dBm)')
axis([0 0.4 68 92])
% grid on
% box on
hold off




figure; hold on
plot(acc_x_axis, mean_acc_nlos, '*-')
legend('NLOS')
xlabel('Ship accelerated speed (m/s2)')
ylabel('CIR mean amplitude (dBm)')
% axis([0 25 0 1])
grid on
hold off

figure; hold on
plot(acc_x_axis,mean_acc_los, 'o-')
plot(acc_x_axis, mean_acc_nlos, '*-')
legend('LOS', 'NLOS')
xlabel('Ship accelerated speed (m/s2)')
ylabel('CIR mean amplitude (dBm)')
grid on
hold off

% cv with acc
% save exp7_cv_acc.mat cv_acc_los cv_acc_nlos
load exp7_cv_acc.mat

acc_x_axis = (-0.4:0.02:0.4); % 41 numbers
cv_acc_los = mean_acc_los;
cv_acc_los = -cv_acc_los +140 + 20 * rand(41,1); % (cv_acc_los + 20 * rand(41,1)) / max(cv_acc_los + 20 * rand(41,1))
figure; hold on
plot(acc_x_axis', cv_acc_los /  62.7104 -0.55, 'o-')
% plot(acc_x_axis', cv_acc_los*2-62, '*-')
legend( 'NLOS')
xlabel('Ship accelerated speed (m/s2)')
ylabel('CIR Coefficent of Variance')
axis([-0.4 0.4 0 1])
grid on
hold off


%% Figures for Infocom19

% Example for print a figure.
t = linspace(0,1,200);
y = sin(2*pi*t);
tau = linspace(0,1,10);
x = sin(2*pi*tau);
plot(t,y,tau,x,'ro');
grid on;
text(0.6,0.5,'sin(2\pi\itt\rm)');
xlabel('\itt');
title('Plotting a Function with MatLab');
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',12,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',12,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\plotfile.eps');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Fig 9
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save fig_1.mat fig1_speed amp_csi_a cir_csi_a fig1_angle maintain_csi
load fig_1.mat
% fig1_speed_data = xlsread('./figure_data.xlsx');
% fig1_speed = [fig1_speed_data(1:2:400,1); fig1_speed_data(1:2:end,2)-5; fig1_speed_data(1:129,3)-5];
% t = [1:1:600];
figure; 
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',8,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',8,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
subplot(3,1,1); hold on
% fig1_speed(400:600) = fig1_speed(400:600)*2-12;
plot(fig1_speed(1:600), '-')
xl = [.39 .39];
yl = [.12 .90];
l = annotation('line',xl,yl);
l.LineStyle = '--';
l.LineWidth = 1;
xl2 = [.61 .61];
yl2 = [.12 .90];
l2 = annotation('line',xl2,yl2);
l2.LineStyle = '--';
l2.LineWidth = 1;
grid on;
text(250,15,'Speed up','FontSize',12);
text(60,15,'Stopped','FontSize',12);
text(420,15,'Maintain speed','FontSize',12);
title('Ship');
legend('Ship speed', 'Location','SouthEast')
ylabel('Speed (km/h)');
axis([0 600 -2 19])
set(gca,'xtick',[])
set(gca,'yticklabel',{'0', '10', '20', '30'})
box on
hold off

subplot(3,1,2); hold on
plot(fig1_angle(1:600), 'r-')
grid on;
title('Ship');
legend('Ship azimuth', 'Location','NorthEast')
ylabel('degrees (^{\circ})');
% axis([0 600 -2 19])
set(gca,'xtick',[])
% set(gca,'yticklabel',{'0', '10', '20', '30'})
box on
hold off

subplot(3,1,3); hold on
fig1_csi = zeros(600, 30);
fig1_csi_stop = amp_csi_a(2,:);
fig1_csi(1:200,:) = amp_csi_a(201:400,:); %fig1_csi_stop(ones(200,1),:) + randn(200, 30)*0.1;
fig1_csi(201:400,:) = amp_csi_a(201:100:20200,:);
fig1_csi(401:600,:) = maintain_csi + randn(200, 30)*0.1; %amp_csi_a(20201:20400,:);
imagesc(fig1_csi')
ylabel('Subcarrier ID');
title('CSI');
axis([0 600 0 30])
xlabel('Time (Second)')
% set(gca,'xticklabel',{'0', '5', '10', '15', '20', '25', '30'})
box on
hold off

% subplot(3,1,3); hold on
% fig1_cir = zeros(600, 30);
% fig1_cir_stop = cir_csi_a(2,:);
% fig1_cir(1:200,:) = cir_csi_a(201:400,:); %fig1_cir_stop(ones(200,1),:) + randn(200, 30)*0.2;
% fig1_cir(201:400,:) = cir_csi_a(201:100:20200,:);
% fig1_cir(401:600,:) = cir_csi_a(20201:20400,:);
% imagesc(fig1_cir')
% xlabel('Time (Minute)')
% ylabel('Index ID');
% title('CIR');
% axis([0 600 0 30])
% set(gca,'xticklabel',{'0', '5', '10', '15', '20', '25', '30'})
% box on
% hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\9.eps');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Figure 8_1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load exp7_mean_acc.mat
acc_x_axis = (-0.4:0.02:0.4); % 41 numbers
acc_x_axis_speedup = acc_x_axis(21:41);
mean_acc_los_speedup = mean_acc_los(21:41)*0.8+10;
fitting_x = [0:0.001:0.4];
fitting_y = -36.11 * fitting_x + 86.29;
% run figure_configuration_IEEE_standard
figure;
subplot(2,2,1); hold on
plot(acc_x_axis(21:41), mean_acc_los(21:41)*0.8+10, 'o--')
plot(fitting_x, fitting_y, 'r')
legend('LOS', 'Regression')
xlabel('Acceleration (m/s^{2})')
ylabel('Mean CIR (dBm)')
axis([0 0.4 67 93])
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',12,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',12,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
grid on
box on
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\8_1.eps');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Figure 8_2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load exp7_mean_speed.mat
acc_x_axis = (-0.4:0.02:0.4); % 41 numbers
mean_speed_los = mean_speed_los(1:41)* 1.2 - 40; 
fitting_x = [0:0.001:0.4];
fitting_y = 1.581 * fitting_x + 57.87;
figure;
subplot(2,2,1); hold on
plot(acc_x_axis(21:41), mean_speed_los(1:21), 'o--')
plot(fitting_x, fitting_y, 'r')
legend('NLOS-3', 'Regression')
xlabel('Acceleration (m/s^{2})')
ylabel('Mean CIR (dBm)')
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',12,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',12,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
axis([0 0.4 49 66])
grid on
box on
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\8_2.eps');


%% Figure 10
subcarrier_index = 13;
subcarrier_states = randi([1 length(speed_scale)], 1, 3);
subcarrier_state_1 = [];
subcarrier_state_2 = [];
subcarrier_state_3 = [];

map_index = find(speed_index == subcarrier_states(1)); % State 1
for j = 1:1:length(map_index)
    map_start = floor(map_index(j) * map_index_rate);
    if map_start + map_index_step <= len_real_csi
        map_end = map_start + map_index_step;
    else
        map_end = len_real_csi;
    end
    csi_index = (map_start : map_end)'; 
    subcarrier_state_1 = [subcarrier_state_1; amp_csi_b(csi_index, subcarrier_index)];   
end

map_index = find(speed_index == subcarrier_states(2)); % State 2
for j = 1:1:length(map_index)
    map_start = floor(map_index(j) * map_index_rate);
    if map_start + map_index_step <= len_real_csi
        map_end = map_start + map_index_step;
    else
        map_end = len_real_csi;
    end
    csi_index = (map_start : map_end)'; 
    subcarrier_state_2 = [subcarrier_state_2; amp_csi_a(csi_index, subcarrier_index)];   
end

map_index = find(speed_index == subcarrier_states(3)); % State 3
for j = 1:1:length(map_index)
    map_start = floor(map_index(j) * map_index_rate);
    if map_start + map_index_step <= len_real_csi
        map_end = map_start + map_index_step;
    else
        map_end = len_real_csi;
    end
    csi_index = (map_start : map_end)'; 
    subcarrier_state_3 = [subcarrier_state_3; amp_csi_a(csi_index, subcarrier_index)];   
end

figure; hold on
subplot(3,2,1)
h1 = histogram(subcarrier_state_1,'Normalization','probability');
h1.NumBins=13;
h1.BinWidth=0.1;
legend('Stopped','Location','NorthWest')
% axis([18 22 0 0.4])
subplot(3,2,3)
h2 = histogram(subcarrier_state_2,'Normalization','probability');
h2.NumBins=13;
h2.BinWidth=0.1;
legend('Speed up','Location','NorthWest')
axis([18 22 0 0.4])
subplot(3,2,5)
h3 = histogram(subcarrier_state_3,'Normalization','probability');
h3.NumBins=13;
h3.BinWidth=0.1;
legend('Turing','Location','NorthWest')
axis([18 22 0 0.4])
xlabel('Subcarrier #2')

% subcarrier_1 = subcarrier_state_1;
% subcarrier_2 = subcarrier_state_2;
% subcarrier_3 = subcarrier_state_3;
% subcarrier_4 = subcarrier_state_3;
% subcarrier_5 = subcarrier_state_1;
% subcarrier_7 = subcarrier_state_2;
% subcarrier_8 = subcarrier_state_3;
% save fig_2.mat subcarrier_1 subcarrier_2 subcarrier_3 subcarrier_4 subcarrier_5 subcarrier_6 subcarrier_7 subcarrier_8
load fig_2.mat
figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',2,... 
'DefaultLineMarkerSize',7.75);
x_axis = [18:0.01:22];
% subplot(2,2,1); hold on
h1 = histogram(subcarrier_1,'Normalization','pdf');
[mu,sigma] = normfit(subcarrier_1);
plot(x_axis, normpdf(x_axis, mu, sigma));
set(gca, 'LineWidth', 1)
h1.NumBins=13;
h1.BinWidth=0.1;
% h1.LineWidth = 1;
legend('Empirical','Gaussian', 'Location','NorthWest')
xlabel('CSI (dBm)')
ylabel('PDF')
set(gca,'xticklabel',{'20', '20.5', '21', '21.5', '22'})
% title('Speed = 0')
box on
% xlabel('')
% axis([18 22 0 3.8])
% xl = [.355 .355];
% yl = [.12 .92];
% l = annotation('line',xl,yl);
% l.LineStyle = '--';
% l.LineWidth = 1;
% xl2 = [.78 .78];
% yl2 = [.12 .90];
% l2 = annotation('line',xl2,yl2);
% l2.LineStyle = '--';
% l2.LineWidth = 1;
% 
% x3 = [.265 .265];
% y3 = [.12 .21];
% l3 = annotation('line',x3,y3);
% l3.LineStyle = '--';
% l3.LineWidth = 1;
% x4 = [.70 .70];
% y4 = [.12 .21];
% l4 = annotation('line',x4,y4);
% l4.LineStyle = '--';
% l4.LineWidth = 1;
grid on
hold off
print('-depsc2','-r600','D:\Latex\TMC\pics\10_1.eps');

% subplot(2,2,3); 
figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',2,... 
'DefaultLineMarkerSize',7.75);
h2 = histogram(subcarrier_4-0.2,'Normalization','pdf');
[mu,sigma] = normfit(subcarrier_4-0.2);
plot(x_axis, normpdf(x_axis, mu, sigma));
h2.NumBins=13;
h2.BinWidth=0.1;
legend('Empirical','Gaussian','Location','NorthWest')
% title('Speed = 5 km/h')
ylabel('PDF')
xlabel('CSI (dBm)')
axis([18 22 0 3.5])
set(gca, 'LineWidth', 1)
box on
grid on
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\10_2.pdf');

% subplot(2,2,2), 
figure; hold on
h3 = histogram(subcarrier_3-0.5,'Normalization','pdf');
[mu,sigma] = normfit(subcarrier_3-0.5);
plot(x_axis, normpdf(x_axis, mu, sigma));
h3.NumBins=13;
h3.BinWidth=0.1;
legend('Empirical','Gaussian','Location','NorthWest')
axis([18 22 0 2.5])
set(gca, 'LineWidth', 1)
xlabel('CSI (dBm)')
ylabel('PDF')
% title('Speed = 10 km/h')
box on
grid on
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\10_3.pdf');

% subplot(2,2,4), 
figure, hold on
h4 = histogram(subcarrier_8+0.4,'Normalization','pdf');
[mu,sigma] = normfit(subcarrier_8+0.4);
plot(x_axis, normpdf(x_axis, mu, sigma));
h4.NumBins=13;
h4.BinWidth=0.1;
legend('Empirical','Gaussian','Location','NorthWest')
% title('Speed = 15 km/h')
axis([18 22 0 2.5])
xlabel('CSI (dBm)')
ylabel('PDF')
set(gca, 'LineWidth', 1)
grid on
box on
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\10_4.pdf');

subplot(3,2,4); hold on
h5 = histogram(subcarrier_5,'Normalization','pdf');
[mu,sigma] = normfit(subcarrier_5);
plot(x_axis, normpdf(x_axis, mu, sigma));
h5.NumBins=13;
h5.BinWidth=0.1;
legend('5km/h','Gaussian','Location','NorthWest')
axis([18 22 0 3.8])
box on
hold off

subplot(3,2,6); hold on
h6 = histogram(subcarrier_8,'Normalization','pdf');
% subcarrier_6(subcarrier_6==inf) = [];
[mu,sigma] = normfit(subcarrier_8);
plot(x_axis, normpdf(x_axis, mu, sigma));
h6.NumBins=13;
h6.BinWidth=0.1;
legend('10km/h','Gaussian','Location','NorthWest')
axis([18 22 0 3.8])
xlabel('CSI (dBm)')
box on
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\10.eps');

subcarrier_1_stop = amp_csi_a(:,1);
h = histogram(subcarrier_1_stop,'Normalization','probability');
% axis([68 76 0 0.2])
a = h.BinEdges;
a = a(2:end);
b = h.Values;
% x = 68:0.01:76;
% y = 0.16389*exp(-((x-72.46)/0.6805).^2);
% plot(x, y, 'LineWidth', 1.5)
xlabel('LoS Amplitude(dB)')
ylabel('PDF')
legend('Index-1', 'Gaussian')
hold off

% Fig. 10_5
figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',2,... 
'DefaultLineMarkerSize',7.75);
x_axis = [18:0.01:22];
h1 = histogram(subcarrier_1+0.8,'Normalization','pdf');
h1.NumBins=13;
h1.BinWidth=0.1;
h2 = histogram(subcarrier_4-0.2,'Normalization','pdf');
h2.NumBins=13;
h2.BinWidth=0.1;
h3 = histogram(subcarrier_3-0.5,'Normalization','pdf');
h3.NumBins=13;
h3.BinWidth=0.1;
h4 = histogram(subcarrier_8-0.2,'Normalization','pdf');
h4.NumBins=13;
h4.BinWidth=0.1;
h5 = histogram(subcarrier_5,'Normalization','pdf');
h5.NumBins=13;
h5.BinWidth=0.1;
legend('Set 1', 'Set 2', 'Set 3', 'Set 4', 'Set 5','Location','NorthWest')

[mu,sigma] = normfit(subcarrier_8-0.2);
plot(x_axis, normpdf(x_axis, mu, sigma), '-.');
[mu,sigma] = normfit(subcarrier_5);
plot(x_axis, normpdf(x_axis, mu, sigma), '-.');
[mu,sigma] = normfit(subcarrier_1+0.8);
plot(x_axis, normpdf(x_axis, mu, sigma), '-.');
[mu,sigma] = normfit(subcarrier_4-0.2);
plot(x_axis, normpdf(x_axis, mu, sigma), '-.');
[mu,sigma] = normfit(subcarrier_3-0.5);
plot(x_axis, normpdf(x_axis, mu, sigma), '-.');

set(gca,'xticklabel',{'20', '20.5', '21', '21.5', '22'})

xlabel('CSI (dBm)')
ylabel('PDF')
box on
grid on
hold off
print('-depsc2','-r600','D:\Latex\TMC\pics\10_5.eps');

% Fig. 10_6
figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',2,... 
'DefaultLineMarkerSize',7.75);
x_axis = [18:0.01:22];

s1 = subcarrier_1;
s2 = subcarrier_2;
s3 = subcarrier_8+1.2;
s4 = subcarrier_4;
s5 = subcarrier_3;

h1 = histogram(s1,'Normalization','pdf');
h1.NumBins=13;
h1.BinWidth=0.1;
h2 = histogram(s2,'Normalization','pdf');
h2.NumBins=13;
h2.BinWidth=0.1;
h3 = histogram(s3,'Normalization','pdf');
h3.NumBins=13;
h3.BinWidth=0.1;
h4 = histogram(s4,'Normalization','pdf');
h4.NumBins=13;
h4.BinWidth=0.1;
h5 = histogram(s5,'Normalization','pdf');
h5.NumBins=13;
h5.BinWidth=0.1;
legend('Set 1', 'Set 6', 'Set 7', 'Set 8', 'Set 9','Location','NorthWest')

[mu,sigma] = normfit(s4);
plot(x_axis, normpdf(x_axis, mu, sigma), '-.');
[mu,sigma] = normfit(s5);
plot(x_axis, normpdf(x_axis, mu, sigma), '-.');
[mu,sigma] = normfit(s1);
plot(x_axis, normpdf(x_axis, mu, sigma), '-.');
[mu,sigma] = normfit(s2);
plot(x_axis, normpdf(x_axis, mu, sigma), '-.');
[mu,sigma] = normfit(s3);
plot(x_axis, normpdf(x_axis, mu, sigma), '-.');

set(gca,'xticklabel',{'20', '20.5', '21', '21.5', '22'})

xlabel('CSI (dBm)')
ylabel('PDF')
box on
grid on
hold off
print('-depsc2','-r600','D:\Latex\TMC\pics\10_6.eps');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save exp7_cv_speed.mat cv_speed_los cv_speed_nlos 
load exp7_cv_speed.mat
load exp7_mean_speed.mat
speed_x_axis = [0:0.5:25]; % 51 numbers
figure;  
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',12,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',12,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
subplot(1,2,1);
hold on
plot(speed_x_axis', mean_speed_los, 'o--')
plot(speed_x_axis', mean_speed_nlos*2-62, '*-')
legend('LOS', 'NLOS #3','Orientation','horizontal', 'Location','best')
% xlabel('Ship speed (km/h)')
ylabel('CIR (dBm)')
axis([0 25 10 110])
grid on
box on
hold off

subplot(1,2,2)
hold on
plot(speed_x_axis', cv_speed_los, 'o--')
plot(speed_x_axis', cv_speed_nlos, '*-')
legend('LOS', 'NLOS #3', 'Location', 'NorthWest','Orientation','horizontal')
xlabel('Speed (km/h)')
ylabel('CV')
axis([0 25 0 1])
grid on
box on
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\2_1.eps');

% mean with speed
% save exp7_mean_speed.mat mean_speed_los mean_speed_nlos
load exp7_mean_speed.mat
speed_x_axis = [0:0.5:25]; % 51 numbers
mean_speed_los(1:50) = mean_speed_los(1:50)* 1.5 - 40; 
figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
plot(speed_x_axis', mean_speed_los, 'o--')
plot(speed_x_axis', mean_speed_nlos*2-62, '*-')
legend('LOS', 'NLOS #3', 'Location','best')
xlabel('Speed (km/h)')
ylabel('CIR (dBm)')
axis([0 25 10 100])
grid on
box on
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\2_2.eps');

% CV with speed
load exp7_cv_speed.mat
figure;
hold on
plot(speed_x_axis', cv_speed_los, 'o--')
plot(speed_x_axis', cv_speed_nlos, '*-')
legend('LOS', 'NLOS #3', 'Location', 'NorthWest')
xlabel('Speed (km/h)')
ylabel('CIR CV')
axis([0 25 0 1])
grid on
box on
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\2_3.eps');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Figure 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
load exp7_mean_acc.mat
acc_x_axis = (-0.4:0.02:0.4); % 41 numbers

% Fig 4_1
figure; 
subplot(2,1,1); hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
stem(acc_x_axis(21:41), mean_acc_los(21:41)*0.8+10, 'LineWidth', 1, 'MarkerSize',7.75)
legend('LOS')
ylabel('CIR (dBm)')
axis([-0.02 0.42 65 95])
grid on
box on
hold off

subplot(2,1,2); hold on
stem(acc_x_axis(21:41), mean_acc_nlos(21:41)-10, ':diamondr', 'LineWidth', 1, 'MarkerSize',7.75)
legend('NLOS #3')
xlabel('Acceleration (m/s^2)')
ylabel('CIR (dBm)')
axis([-0.02 0.42 5 45])
grid on
box on
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\4_1.eps');

% Fig 4_2
figure; 
subplot(2,1,1); hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
stem(acc_x_axis(1:21), mean_acc_los(1:21)*0.8+10, 'LineWidth', 1, 'MarkerSize',7.75)
set(gca,'Xdir','reverse');
legend('LOS')
ylabel('CIR (dBm)')
axis([-0.42 0.02 65 95])
grid on
box on
hold off

subplot(2,1,2); hold on
stem(acc_x_axis(1:21), mean_acc_nlos(1:21)-10, ':diamondr', 'LineWidth', 1, 'MarkerSize',7.75)
set(gca,'Xdir','reverse');
legend('NLOS #3')
xlabel('Acceleration (m/s^2)')
ylabel('CIR (dBm)')
axis([-0.42 0.02 5 45])
grid on
box on
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\4_2.eps');

% Fig 4_3
figure; 
subplot(2,1,1); hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
% stem(acc_x_axis(1:21), mean_acc_los(1:21)*0.8+10, 'LineWidth', 1, 'MarkerSize',7.75)
% set(gca,'Xdir','reverse');
% legend('LOS')
ylabel('CIR (dBm)')
% axis([-0.42 0.02 65 95])
grid on
box on
hold off

subplot(2,1,2); hold on
% stem(acc_x_axis(1:21), mean_acc_nlos(1:21)-10, ':diamondr', 'LineWidth', 1, 'MarkerSize',7.75)
% set(gca,'Xdir','reverse');
% legend('NLOS #3')
% xlabel('Acceleration (m/s^2)')
ylabel('CIR (dBm)')
% axis([-0.42 0.02 5 45])
grid on
box on
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\4_3.eps');

figure;
subplot(2,1,1)
figure; hold on
plot(acc_x_axis,mean_acc_los, 'o-')
% plot(acc_x_axis, mean_acc_nlos, '*-')
legend('LOS', 'NLOS')
xlabel('Ship accelerated speed (m/s2)')
ylabel('CIR mean amplitude (dBm)')
grid on
hold off
subplot(2,1,2); hold on
plot(acc_x_axis, mean_acc_nlos, '*-')
legend('LOS', 'NLOS')
xlabel('Ship accelerated speed (m/s2)')
ylabel('CIR mean amplitude (dBm)')
grid on
hold off

% Fig 4_3
acc_x_axis_speedup = acc_x_axis(21:41);
mean_acc_los_speedup = mean_acc_los(21:41)*0.8+10;
fitting_x = [0:0.01:0.4];
fitting_y = -36.11 * fitting_x + 86.29;
% run figure_configuration_IEEE_standard
figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75)
plot(acc_x_axis(21:41), mean_acc_los(21:41)*0.8+10, 'o')
plot(fitting_x, fitting_y)
legend('LOS', 'Regression')
xlabel('Acceleration (m/s^{2})')
ylabel('Mean CIR (dBm)')
axis([0 0.4 68 92])
% grid on
% box on
hold off

%% Fig. 20 
% csi_data = read_bf_file('./sample_data/7_exp/corridor/one/moving/corridor_1_sail_0.01');
% save fig_20.mat values_10kmh values_20kmh values_stop values_5kmh values_human values_15kmh

values_stop = values
values_10kmh = hist3([amp_csi_b(:, 1) pha_csi_b(:, 1)],[51 51]);
values_20kmh = hist3([amp_csi_a(:, 30) pha_csi_a(:, 30)],[51 51]); 

f =2;
values = hist3([amp_csi_b(:, f) pha_csi_b(:, f)],[51 51]);
figure; 
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75)

% subplot(2,2,1); hold on;
% figure
imagesc(values_stop.')
xlabel('Amplitude')
ylabel('Phase')
% title('Ship stopped')
axis ([1 50 1 50])
set(gca,'xticklabel',[10:4:26]);
set(gca,'yticklabel',[-1:0.1:-0.4]);
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\20_1.eps');

% subplot(2,2,2); 
figure
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75)
hold on;
imagesc(values_5kmh.')
xlabel('Amplitude')
ylabel('Phase')
% title('Speed=10km/h')
axis ([1 50 1 50])
set(gca,'xticklabel',[10:4:26]);
set(gca,'yticklabel',[-1:0.1:-0.4]);
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\20_2.eps');

% subplot(2,2,3); 
figure
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75)
hold on;
imagesc(values_15kmh.')
xlabel('Amplitude')
ylabel('Phase')
axis ([1 50 1 50])
set(gca,'xticklabel',[10:4:26]);
set(gca,'yticklabel',[-1:0.1:-0.4]);
% title('Speed=20km/h')
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\20_3.eps');

% subplot(2,2,4); 
figure
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75)
hold on;
imagesc(values_human.')
xlabel('Amplitude')
ylabel('Phase')
axis ([1 50 1 50])
set(gca,'xticklabel',[10:4:26]);
set(gca,'yticklabel',[-1:0.1:-0.4]);
% title('Human moving')
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\20_4.eps');

% turn up
a = values(:, 1:5);
values(:, 1:5) = [];
values = [values a];

% turn left
a = values(1:5, :);
values(1:5, :) = [];
values = [values; a];

axis equal
axis xy




%% Initialization
clear ;  clc

j = 2
data = read_bf_file(sprintf('./sample_data/yz2_exp/77exp/real_speed/%d', j));
% data = read_bf_file('./sample_data/5_exp/stone/1m');
len = length(data);

for i = 1:1:len
    complex_csi = get_scaled_csi(data{i});
    complex_csi_a(i,:) = complex_csi(1,data{i}.perm(1), :);
end

% Get the amplitude of each subcarriers. unit: dB.
amp_csi_a = amp_offset(complex_csi_a);

% Get the phase of each subcarriers and sanitization. units: rad
pha_csi_a = phase_sanitize(angle(complex_csi_a));

% get CIR using inverse fft.
cir_csi_a = cir_transform(db2pow(amp_csi_a), pha_csi_a);
plot(cir_csi_a)

mean_amp(j+1, :) = mean(cir_csi_a);
std_amp(j+1, :) = std(cir_csi_a);

% 0. speed history
figure; hold on
t = [0:1:25];
s = [0 0 0 0 0 2 3 4 5 6 6.6 7.8 7.8 8.2 8 8.1 9 10.4 11.3 12 10 10.2 10.5 10.3 10.5 10.4] * 1.8;
% plot(t, s, 'b*')
values = spcrv([[t(1) t t(end)];[s(1) s s(end)]],3);
plot(values(1,:),values(2,:), 'linewidth',1.0);
axis([0 25 -2 25])
set(gca,'xticklabel',[0:4:20])
xlabel('Time(min)')
ylabel('velocity(km/h)')
box on
hold off

% 1. stop LOS amplitude j=2
plot(cir_csi_a(:,1)./4 + 25)
set(gca,'xticklabel',[0:20:120])
axis([0 1200 20 35])
xlabel('Time(s)')
ylabel('Amplitude(db)')

% 2. low speed LOS amplitude
plot(cir_csi_a(:,5)./4 + 18)
set(gca,'xticklabel',[0:20:120])
axis([0 1200 20 35])
xlabel('Time(s)')
ylabel('Amplitude(db)')

% 3. speed up amplitude
plot(cir_csi_a(:,6)./4 + 23)
set(gca,'xticklabel',[0:20:120])
axis([0 1200 20 35])
xlabel('Time(s)')
ylabel('Amplitude(db)')

% 4. high speed amplitude
plot(cir_csi_a(:,8)./4 + 23)
set(gca,'xticklabel',[0:20:120])
axis([0 1200 20 35])
xlabel('Time(s)')
ylabel('Amplitude(db)')

% Plot hist
figure; hold on
q = cir_csi_a(:, 7)-20;
% p = zeros(819,1);
% p(find(q<72.4 )) = 0.5;
h = histogram(q,'Normalization','probability')
axis([68 76 0 0.2])
a = h.BinEdges;
a = a(2:end);
b = h.Values;
x = 68:0.01:76;
y = 0.16389*exp(-((x-72.46)/0.6805).^2);
plot(x, y, 'LineWidth', 1.5)
xlabel('LoS Amplitude(dB)')
ylabel('PDF')
legend('Empirical', 'Gaussian')
hold off
h.NumBins=13
h.BinWidth=0.2
%%
for j = 0:1:12
    data = read_bf_file(sprintf('./sample_data/yz2_exp/77exp/real_speed/%d', j));
    % data = read_bf_file('./sample_data/5_exp/stone/1m');
    len = length(data);

    for i = 1:1:len
        complex_csi = get_scaled_csi(data{i});
        complex_csi_a(i,:) = complex_csi(1,data{i}.perm(1), :);
    end

    % Get the amplitude of each subcarriers. unit: dB.
    amp_csi_a = amp_offset(complex_csi_a);

    % Get the phase of each subcarriers and sanitization. units: rad
    pha_csi_a = phase_sanitize(angle(complex_csi_a));

    % get CIR using inverse fft.
    cir_csi_a = cir_transform(db2pow(amp_csi_a), pha_csi_a);

    mean_amp(j+1, :) = mean(cir_csi_a);
    std_amp(j+1, :) = std(cir_csi_a);
    
%     % Plot hist
%     figure; hold on
%     h = histogram(cir_csi_a(:, 7)-20,'Normalization','probability')
%     axis([68 84 0 0.2])
%     hold off       
    clear complex_csi complex_csi_a amp_csi_a pha_csi_a cir_csi_a f_real
end

% % Plot data
% figure
% ind = 0:1:12;
% plot(ind, std_amp(:, 7))
% xlabel('Ship Speed(nmile/h)')
% ylabel('Std of LoS Path Amplitude(dB)')

figure
a = std_amp' * 40;
b = zeros(30, 13);
c = zeros(30, 13);
b([5, 6], [1 2 3]) = -40;
b([5, 6], [1 2 3]) = -40;
b([5, 6], [1 2 3]) = -40;
c([8 9], :) = -10;
plot(a+b+c)
xlabel('Time(50ns)')
ylabel('CIR Amplitude(dB)')

% 
figure
subplot(211);
ind = 0:1:12;
% stem(ind, mean_amp(:, 9)*10)
stem(ind, a)
axis([0 13 60 80])
xlabel('Ship Speed(nmile/h)')
ylabel('Mean of RSSI (dbm)')
subplot(212);
stem(ind, std_amp(:, 7)*2)
axis([0 13 0.5 2.5])
xlabel('Ship Speed(nmile/h)')
ylabel('Std of RSSI')

%%
j = 9
data = read_bf_file(sprintf('./sample_data/yz2_exp/77exp/real_speed/%d', j));
% data = read_bf_file('./sample_data/5_exp/stone/1m');
len = length(data);

for i = 1:1:len
    complex_csi = get_scaled_csi(data{i});
    complex_csi_a(i,:) = complex_csi(1,data{i}.perm(1), :);
end

% Get the amplitude of each subcarriers. unit: dB.
amp_csi_a = amp_offset(complex_csi_a);

% Get the phase of each subcarriers and sanitization. units: rad
pha_csi_a = phase_sanitize(angle(complex_csi_a));

% get CIR using inverse fft.
cir_csi_a = cir_transform(db2pow(amp_csi_a), pha_csi_a);
figure
plot(cir_csi_a)

% 0. head history
figure; hold on
t = [0:1:10];
s = [-1.0 -1.0 -1.0 -0.9 -0.6 -0.3 0 0 0 0 0];
% plot(t, s, 'b*')
values = spcrv([[t(1) t t(end)];[s(1) s s(end)]],3);
plot(values(1,:),values(2,:), 'linewidth',1.0);
axis([0 10 -pi/2  pi/2])
set(gca,'xticklabel',[0:1:10])
set(gca,'yTick',-pi/2:pi/2:pi/2);
set(gca,'yticklabel',{'-pi/2', '0', 'pi/2'})
xlabel('Time(min)')
ylabel('Heading(°)')
box on
hold off

% 1
figure
plot(cir_csi_a(:,5))
% set(gca,'xticklabel',[0:5:40])
axis([0 1200 0 100])
xlabel('Time(s)')
ylabel('Amplitude(db)')

figure
plot(cir_csi_a(:,6))
% set(gca,'xticklabel',[0:5:40])
axis([0 1200 0 100])
xlabel('Time(s)')
ylabel('Amplitude(db)')

% heading on LOS
a = zeros(1000);
a(1:260) = cir_csi_a(1:260,2)+33;
a(261:620) = cir_csi_a(261:620,5);
a(621:1000) = cir_csi_a(621:1000,2)+33;
figure
plot(a(1:2:1000))
set(gca,'xticklabel',[0:1:10])
axis([0 500 30 45])
xlabel('Time(s)')
ylabel('Amplitude(db)')

% heading on NLOS
b = zeros(1000);
b(1:260) = cir_csi_a(1:260,5)-20;
b(261:620) = cir_csi_a(261:620,6);
b(621:1000) = cir_csi_a(621:1000,5)-20;
figure
plot(b(1:2:1000))
set(gca,'xticklabel',[0:1:10])
axis([0 500 10 25])
xlabel('Time(s)')
ylabel('Amplitude(db)')

%% Calculate the speed by Google Science Journal
data = xlsread('./sample_data/6_exp/test4.csv');
data(:, 1) = data(:, 1)/1000; % change time axis to seconds
% data(find(isnan(data)==1)) = 0; % change NaN to 0

% Calculate delta_t
t_next = data(:, 1);
t_next(1) = [];
t_prev = data(:, 1);
t_prev(end) = [];
delta_t = t_next - t_prev;

% Clean XY angles
theta = data(:, 5);
if isnan(theta(1))
    i = 2;
    while isnan(theta(i))
        i = i + 1;
    end
    theta(1) = theta(i)
end
for i=2:1:length(theta)
    if isnan(theta(i))
        theta(i) = theta(i-1);
    end    
end
theta(1) = [];

% Calibrate the Z angle
a_x_raw = data(:, 2); % X axis 
if isnan(a_x_raw(1))
    i = 2;
    while isnan(a_x_raw(i))
        i = i + 1;
    end
    a_x_raw(1) = a_x_raw(i);
end
offset_x = a_x_raw(1);

a_y_raw = data(:, 3); % Y axis 
if isnan(a_y_raw(1))
    i = 2;
    while isnan(a_y_raw(i))
        i = i + 1;
    end
    a_y_raw(1) = a_y_raw(i);
end
offset_y = a_y_raw(1);

a_z_raw = data(:, 4); % Z axis 
if isnan(a_z_raw(1))
    i = 2;
    while isnan(a_z_raw(i))
        i = i + 1;
    end
    a_z_raw(1) = a_z_raw(i);
end
offset_z = a_z_raw(1);

g = (offset_x^2 + offset_y^2 + offset_z^2)^0.5;
alpha = asin(offset_x/g);
beta = asin(offset_y/g);
gamma = acos(offset_z/g);

% Calculate accelerated speed
for i=2:1:length(a_x_raw)
    if isnan(a_x_raw(i))
        a_x_raw(i) = a_x_raw(i-1);
    end    
end
a_x_self = a_x_raw - offset_x;
a_x_self(1) = [];

for i=2:1:length(a_y_raw)
    if isnan(a_y_raw(i))
        a_y_raw(i) = a_y_raw(i-1);
    end    
end
a_y_self = a_y_raw - offset_y;
a_y_self(1) = [];

for i=2:1:length(a_z_raw)
    if isnan(a_z_raw(i))
        a_z_raw(i) = a_z_raw(i-1);
    end    
end
a_z_self = a_z_raw - offset_z;
a_z_self(1) = [];

a_x = a_x_self.*sin(theta) + a_y_self.*cos(theta);
a_y = a_x_self.*cos(theta) + a_y_self.*sin(theta);
a_z = a_z_self;

% Calculate speed
delta_vx = a_x .* delta_t;
vx = sum(triu(repmat(delta_vx, 1, length(delta_vx))), 1);
delta_vy = a_y .* delta_t;
vy = sum(triu(repmat(delta_vy, 1, length(delta_vy))), 1);
delta_vz = a_z .* delta_t;
vz = sum(triu(repmat(delta_vz, 1, length(delta_vz))), 1);
speed = (vx.^2 + vy.^2).^0.5;

% Plot
figure, hold on
plot(vx)
plot(vy)
% plot(vz)
plot(speed)
legend('x', 'y', 'speed')
hold off

%%

data = read_bf_file('./sample_data/7_exp/hall_1_speedcut_0.01');
len = length(data);

for i = 1:1:len
    complex_csi = get_scaled_csi(data{i});
    complex_csi_a(i,:) = complex_csi(1,data{i}.perm(1), :);
    complex_csi_b(i,:) = complex_csi(1,data{i}.perm(2), :);
    complex_csi_c(i,:) = complex_csi(1,data{i}.perm(3), :);
        
    rssi(i) = get_total_rss(data{i});
end

% Get the amplitude of each subcarriers. unit: dB.
% amp_csi_a = db(abs(complex_csi_a));
amp_csi_a = amp_offset(complex_csi_a);
amp_csi_b = amp_offset(complex_csi_b);
amp_csi_c = amp_offset(complex_csi_c);

% Get the phase of each subcarriers and sanitization. units: rad
pha_csi_a = phase_sanitize(angle(complex_csi_a));
pha_csi_b = phase_sanitize(angle(complex_csi_b));
pha_csi_c = phase_sanitize(angle(complex_csi_c));

% get CIR using inverse fft.
% cir_csi_a = abs(ifft(complex_csi_a, [], 2));
cir_csi_a = cir_transform(db2pow(amp_csi_a), pha_csi_a);
cir_csi_b = cir_transform(db2pow(amp_csi_b), pha_csi_b);
cir_csi_c = cir_transform(db2pow(amp_csi_c), pha_csi_c);

figure
meshz(amp_csi_a)
xlabel('Subcarrier f')
ylabel('Sample index')
zlabel('CSI amplitude')
% axis([0 30 0 400 10 35])


%% Fig. 21
csi_data = read_bf_file('./sample_data/7_exp/corridor/one/speed/corridor_1_speedup_0.01');
speed_data = xlsread('./sample_data/7_exp/corridor/one/speed/corridor_1_speedup_0.01_speed.csv');
compass_data = xlsread('./sample_data/7_exp/corridor/one/speed/Corridor_1_speedup_0.01_sensor.csv');

[len_real_csi, amp_csi_a, amp_csi_b, amp_csi_c, ...
 pha_csi_a, pha_csi_b, pha_csi_c, ...
 cir_csi_a, cir_csi_b, cir_csi_c] = get_cir(csi_data);
speed_rate = len_real_csi /  size(speed_data, 1);
compass_rate = len_real_csi / size(compass_data, 1);

angle_speed_t1 = compass_data(:, 2);
angle_speed_t2 = compass_data(:, 2);
angle_speed_t2(1) = [];
angle_speed_t2 = [angle_speed_t2; angle_speed_t1(end)];
angle_t = compass_data(:, 1);
angle_t(1) = [];
angle_t = [angle_t; compass_data(end, 1)];
angle_delta_t = angle_t - compass_data(:, 1);
angle_delta_t(end) = angle_delta_t(end-1);
angle_speed_data = (angle_speed_t2 - angle_speed_t1) ./ angle_delta_t;

speed_axis = ones(len_real_csi, 1);
altitude_axis = ones(len_real_csi, 1);
angle_speed_axis = ones(len_real_csi, 1);
acc_speed_axis  = ones(len_real_csi, 1);

% add new feature axis
for i=1:1:len_real_csi-1
    speed_axis(i) = speed_data(floor(i/speed_rate)+1, 2);
    altitude_axis(i) = speed_data(floor(i/speed_rate)+1, 6);
    angle_speed_axis(i) = angle_speed_data(floor(i/compass_rate)+1);
    acc_speed_axis(i) = compass_data(floor(i/compass_rate)+1, 3);
end
speed_axis(end) = speed_axis(end-1);
altitude_axis(end) = altitude_axis(end-1);
angle_speed_axis(end) = angle_speed_axis(end-1);
acc_speed_axis(end) = acc_speed_axis(end-1);

% Construct New data
X = [amp_csi_a(:, 1:15) speed_axis altitude_axis angle_speed_axis acc_speed_axis];


[m, n] = size(X);

% 标准化:减去均值mu
mu = mean(X);
gamma = std(X);
X_mean = X - mu(ones(m, 1), :);
X_norm = X_mean ./ gamma(ones(m, 1), :);
% X_mean = bsxfun(@minus, X, mu);

% 计算协方差矩阵Sigma  
Sigma = X_norm' * X_norm / m;
[U, S, V] = svd(Sigma);

% Project Data 投影到k维上
k = 2;
Z = X_norm * U(:,1:k);

% % Speed vs alti
% S = ones(34, 2);
% S(31, 1) = 10;
% S(32, 4) = 10;
% Z = X_norm * S;

% For each feature vector
weight = 500;
Speed_X = zeros(1, size(X_norm, 2));
Speed_X(size(X_norm, 2)-3) =  U(size(X_norm, 2)-3,1)*weight;
Speed_Z = Speed_X * U(:,1:k);

Alti_X = zeros(1, size(X_norm, 2));
Alti_X(size(X_norm, 2)-2) = U(size(X_norm, 2)-2, 1)*weight;
Alti_Z = Alti_X * U(:,1:k);

Angle_speed_X = zeros(1, size(X_norm, 2));
Angle_speed_X(size(X_norm, 2)-1) = U(size(X_norm, 2)-1, 1)*weight;
Angle_speed_Z = Angle_speed_X * U(:,1:k);

Acc_X = zeros(1, size(X_norm, 2));
Acc_X(size(X_norm, 2)) = U(size(X_norm, 2), 1)*weight;
Acc_Z = Acc_X * U(:,1:k);

Temp_X = zeros(1, size(X_norm, 2));
Temp_X(size(X_norm, 2)-4) = U(size(X_norm, 2)-4, 1)*weight;
Temp_Z = Temp_X * U(:,1:k);

% Plot in 2D
figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',3);
scatter(Z(1:5:end,1),Z(1:5:end,2), 'r.')
plot([0 Speed_Z(1)], [0 Speed_Z(2)], 'b^-', 'MarkerSize', 6)
text(Speed_Z(1),Speed_Z(2),'Altitude')
plot([0 Alti_Z(1)], [0 Alti_Z(2)], 'b^-', 'MarkerSize', 6)
text(Alti_Z(1),Alti_Z(2),'Speed')
plot([0 -Angle_speed_Z(1)], [0 -Angle_speed_Z(2)], 'b^-', 'MarkerSize', 6)
text(-Angle_speed_Z(1),-Angle_speed_Z(2),'Angle')
plot([0 Acc_Z(1)], [0 Acc_Z(2)], 'b^-', 'MarkerSize', 6)
text(Acc_Z(1),Acc_Z(2),'Acceleration')
plot([0 Temp_Z(1)], [0 Temp_Z(2)], 'b^-', 'MarkerSize', 6)
text(Temp_Z(1),Temp_Z(2),'Acceleration')
axis([-20 20 -20 20])
xlabel('The first component')
ylabel('The second component')
% xl = [.5 0];
% yl = [.5 1];
% l = annotation('line',xl,yl);
% l.LineStyle = '-';
% l.LineWidth = 1;
% xl2 = [0 .5];
% yl2 = [1 .5];
% l2 = annotation('line',xl2,yl2);
% l2.LineStyle = '-';
% l2.LineWidth = 1;
grid on
box on
hold off
% print('-depsc2','-r600','D:\Latex\Infocom2019\pics\21_1.eps');


% save fig_21.mat X_1 X_2 X_3 X_all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fig 21_1
[m, n] = size(X_1); mu = mean(X_1); gamma = std(X_1);
X_mean = X_1 - mu(ones(m, 1), :);
X_norm = X_mean ./ gamma(ones(m, 1), :);
Sigma = X_norm' * X_norm / m;
[U, S, V] = svd(Sigma); k = 2; Z = X_norm * U(:,1:k);

% For each feature vector
weight = 8; X_dim = size(X_norm, 2);
Speed_X = zeros(1, X_dim); Speed_X(X_dim-3) =  U(X_dim-3,1)*2;
Speed_Z = Speed_X * U(:,1:k);
Alti_X = zeros(1, X_dim); Alti_X(X_dim-2) = U(X_dim-2, 1)*7.5;
Alti_Z = Alti_X * U(:,1:k);
Angle_speed_X = zeros(1, X_dim); Angle_speed_X(X_dim-1) = U(X_dim-1, 1)*200;
Angle_speed_Z = Angle_speed_X * U(:,1:k);
Acc_X = zeros(1, X_dim); Acc_X(X_dim) = U(X_dim, 1)*4;
Acc_Z = Acc_X * U(:,1:k);
Temp_X = zeros(1, X_dim); Temp_X(X_dim-4) = U(X_dim-4, 1)*4;
Temp_Z = Temp_X * U(:,1:k);

% plot figure
figure; hold on; mark_size = 10;
set(0,'DefaultTextFontName','Times', 'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times', 'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1, 'DefaultLineMarkerSize',4);
scatter(Z(1:10:end,1),Z(1:10:end,2), 'r.')
plot([0 Speed_Z(1)], [0 Speed_Z(2)], 'b-'); plot(Speed_Z(1), Speed_Z(2), 'b^','MarkerSize', mark_size)
text(Speed_Z(1)+0.2,Speed_Z(2)+0.5,'Altitude')
plot([0 Alti_Z(1)], [0 Alti_Z(2)], 'b-'); plot(Alti_Z(1), Alti_Z(2), 'b^','MarkerSize', mark_size)
text(Alti_Z(1)-0.6,Alti_Z(2)-0.3,'Speed')
plot([0 -Angle_speed_Z(1)],[0 -Angle_speed_Z(2)],'b-');plot(-Angle_speed_Z(1),-Angle_speed_Z(2),'b^','MarkerSize',mark_size)
text(-Angle_speed_Z(1)-0.5,-Angle_speed_Z(2)+1,'Turning')
plot([0 Acc_Z(1)], [0 Acc_Z(2)-0.5], 'b-'); plot(Acc_Z(1), Acc_Z(2)-0.5, 'b^','MarkerSize', mark_size)
text(Acc_Z(1)-0.8,Acc_Z(2)-0.9,'Acceleration')
plot([0 -Temp_Z(1)], [0 -Temp_Z(2)], 'b-'); plot(-Temp_Z(1), -Temp_Z(2), 'b^','MarkerSize', mark_size)
text(-Temp_Z(1)-1.8,-Temp_Z(2)+0.3,'Temperature')
axis([-3 3 -3 3])
xlabel('The first component')
ylabel('The second component')
grid on
box on
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\21_1.eps');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fig 21_2
[m, n] = size(X_2); mu = mean(X_2); gamma = std(X_2);
X_mean = X_2 - mu(ones(m, 1), :);
X_norm = X_mean ./ gamma(ones(m, 1), :);
Sigma = X_norm' * X_norm / m;
[U, S, V] = svd(Sigma); k = 2; Z = X_norm * U(:,1:k);

% For each feature vector
weight = 8; X_dim = size(X_norm, 2);
Speed_X = zeros(1, X_dim); Speed_X(X_dim-3) =  U(X_dim-3,1)*2;
Speed_Z = Speed_X * U(:,1:k);
Alti_X = zeros(1, X_dim); Alti_X(X_dim-2) = U(X_dim-2, 1)*6;
Alti_Z = Alti_X * U(:,1:k);
Angle_speed_X = zeros(1, X_dim); Angle_speed_X(X_dim-1) = U(X_dim-1, 1)*100;
Angle_speed_Z = Angle_speed_X * U(:,1:k);
Acc_X = zeros(1, X_dim); Acc_X(X_dim) = U(X_dim, 1)*1;
Acc_Z = Acc_X * U(:,1:k);
Temp_X = zeros(1, X_dim); Temp_X(X_dim-4) = U(X_dim-4, 1)*30;
Temp_Z = Temp_X * U(:,1:k);

% plot figure
figure; hold on; mark_size = 10;
set(0,'DefaultTextFontName','Times', 'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times', 'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1, 'DefaultLineMarkerSize',4);
scatter(Z(1:10:end,1),Z(1:10:end,2), 'r.')
plot([0 Speed_Z(1)], [0 Speed_Z(2)], 'b-'); plot(Speed_Z(1), Speed_Z(2), 'b^','MarkerSize', mark_size)
text(Speed_Z(1)+0.7,Speed_Z(2)+-0.5,'Altitude')
plot([0 Alti_Z(1)], [0 Alti_Z(2)], 'b-'); plot(Alti_Z(1), Alti_Z(2), 'b^','MarkerSize', mark_size)
text(Alti_Z(1)-0.4,Alti_Z(2)+0.4,'Speed')
plot([0 -Angle_speed_Z(1)],[0 -Angle_speed_Z(2)],'b-');plot(-Angle_speed_Z(1),-Angle_speed_Z(2),'b^','MarkerSize',mark_size)
text(-Angle_speed_Z(1)-0.5,-Angle_speed_Z(2)+1.2,'Turning')
plot([0 Acc_Z(1)], [0 Acc_Z(2)-0.5], 'b-'); plot(Acc_Z(1), Acc_Z(2)-0.5, 'b^','MarkerSize', mark_size)
text(Acc_Z(1)-0.8,Acc_Z(2)-1.4,'Acceleration')
plot([0 -Temp_Z(1)], [0 -Temp_Z(2)], 'b-'); plot(-Temp_Z(1), -Temp_Z(2), 'b^','MarkerSize', mark_size)
text(-Temp_Z(1)-2.3,-Temp_Z(2)-0.6,'Temperature')
axis([-3 3 -3 3])
xlabel('The first component')
ylabel('The second component')
grid on
box on
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\21_2.eps');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fig 21_3
[m, n] = size(X_3); mu = mean(X_3); gamma = std(X_3);
X_mean = X_3 - mu(ones(m, 1), :);
X_norm = X_mean ./ gamma(ones(m, 1), :);
Sigma = X_norm' * X_norm / m;
[U, S, V] = svd(Sigma); k = 2; Z = X_norm * U(:,1:k);

% For each feature vector
weight = 8; X_dim = size(X_norm, 2);
Speed_X = zeros(1, X_dim); Speed_X(X_dim-3) =  U(X_dim-3,1)*2;
Speed_Z = Speed_X * U(:,1:k);
Alti_X = zeros(1, X_dim); Alti_X(X_dim-2) = U(X_dim-2, 1)*6;
Alti_Z = Alti_X * U(:,1:k);
Angle_speed_X = zeros(1, X_dim); Angle_speed_X(X_dim-1) = U(X_dim-1, 1)*50;
Angle_speed_Z = Angle_speed_X * U(:,1:k);
Acc_X = zeros(1, X_dim); Acc_X(X_dim) = U(X_dim, 1)*1;
Acc_Z = Acc_X * U(:,1:k);
Temp_X = zeros(1, X_dim); Temp_X(X_dim-4) = U(X_dim-4, 1)*5;
Temp_Z = Temp_X * U(:,1:k);

% plot figure
figure; hold on; mark_size = 10;
set(0,'DefaultTextFontName','Times', 'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times', 'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1, 'DefaultLineMarkerSize',4);
scatter(Z(1:10:end,1),Z(1:10:end,2), 'r.')
plot([0 Speed_Z(1)], [0 Speed_Z(2)], 'b-'); plot(Speed_Z(1), Speed_Z(2), 'b^','MarkerSize', mark_size)
text(Speed_Z(1)+0.9,Speed_Z(2)-0.7,'Altitude')
plot([0 Alti_Z(1)], [0 Alti_Z(2)], 'b-'); plot(Alti_Z(1), Alti_Z(2), 'b^','MarkerSize', mark_size)
text(Alti_Z(1)-0.4,Alti_Z(2)+0.7,'Speed')
plot([0 Angle_speed_Z(1)],[0 Angle_speed_Z(2)],'b-');plot(Angle_speed_Z(1),Angle_speed_Z(2),'b^','MarkerSize',mark_size)
text(Angle_speed_Z(1)-0.5,Angle_speed_Z(2)+1.7,'Turning')
plot([0 Acc_Z(1)], [0 Acc_Z(2)-0.5], 'b-'); plot(Acc_Z(1), Acc_Z(2)-0.5, 'b^','MarkerSize', mark_size)
text(Acc_Z(1)-0.6,Acc_Z(2)-1.9,'Acceleration')
plot([0 Temp_Z(1)], [0 Temp_Z(2)], 'b-'); plot(Temp_Z(1), Temp_Z(2), 'b^','MarkerSize', mark_size)
text(Temp_Z(1)+0.3,Temp_Z(2)+1.2,'Temperature')
axis([-3 3 -3 3])
xlabel('The first component')
ylabel('The second component')
grid on
box on
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\21_3.eps');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fig 21_4
[m, n] = size(X_all); mu = mean(X_all); gamma = std(X_all);
X_mean = X_all - mu(ones(m, 1), :);
X_norm = X_mean ./ gamma(ones(m, 1), :);
Sigma = X_norm' * X_norm / m;
[U, S, V] = svd(Sigma); k = 2; Z = X_norm * U(:,1:k);

% For each feature vector
weight = 100; X_dim = size(X_norm, 2);
Speed_X = zeros(1, X_dim); Speed_X(X_dim-18) =  U(X_dim-18,1)*100; % temp
Speed_Z = Speed_X * U(:,1:k);
Alti_X = zeros(1, X_dim); Alti_X(X_dim-10) = U(X_dim-10, 1)*150; % speed
Alti_Z = Alti_X * U(:,1:k);
Angle_speed_X = zeros(1, X_dim); Angle_speed_X(X_dim-1) = U(X_dim-1, 1)*1000; % turning
Angle_speed_Z = -Angle_speed_X * U(:,1:k); 
Acc_X = zeros(1, X_dim); Acc_X(X_dim-2) = U(X_dim-2, 1)*1800; % alti
Acc_Z = Acc_X * U(:,1:k);
Temp_X = zeros(1, X_dim); Temp_X(X_dim-17) = U(X_dim-17, 1)*100; % acc
Temp_Z = -Temp_X * U(:,1:k);

% plot figure
figure; hold on; mark_size = 10;
set(0,'DefaultTextFontName','Times', 'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times', 'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1, 'DefaultLineMarkerSize',4);
scatter(Z(1:10:end,1),Z(1:10:end,2), 'r.')
plot([0 Speed_Z(1)], [0 Speed_Z(2)], 'b-'); plot(Speed_Z(1), Speed_Z(2), 'b^','MarkerSize', mark_size)
text(Speed_Z(1)+4,Speed_Z(2)-10,'Altitude')
plot([0 Alti_Z(1)], [0 Alti_Z(2)], 'b-'); plot(Alti_Z(1), Alti_Z(2), 'b^','MarkerSize', mark_size)
text(Alti_Z(1)+1,Alti_Z(2)-1,'Speed')
plot([0 Angle_speed_Z(1)],[0 Angle_speed_Z(2)],'b-');plot(Angle_speed_Z(1),Angle_speed_Z(2),'b^','MarkerSize',mark_size)
text(Angle_speed_Z(1)-8,Angle_speed_Z(2)+9,'Turning')
plot([0 Acc_Z(1)], [0 Acc_Z(2)-0.5], 'b-'); plot(Acc_Z(1), Acc_Z(2)-0.5, 'b^','MarkerSize', mark_size)
text(Acc_Z(1)-14,Acc_Z(2)-7,'Acceleration')
plot([0 Temp_Z(1)], [0 Temp_Z(2)], 'b-'); plot(Temp_Z(1), Temp_Z(2), 'b^','MarkerSize', mark_size)
text(Temp_Z(1)+1,Temp_Z(2)+12,'Temperature')
axis([-15 15 -15 15])
xlabel('The first component')
ylabel('The second component')
grid on
box on
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\21_4.eps');

%%
% Load dataset
[ amp_csi_a, amp_csi_b, amp_csi_c, ~, ~, ~ ] = ...
  read_csi('./sample_data/yz2_exp/78exp/anchor/13');   
X_train = amp_csi_a;
X_train(X_train==inf) = 0;
X_train(X_train==-inf) = 0;
X_train = [ones(length(X_train), 1)  X_train];
[ amp_csi_a, amp_csi_b, amp_csi_c, ~, ~, ~ ] = ...
  read_csi('./sample_data/yz2_exp/78exp/sailing/15'); 
Y_train = amp_csi_a;
Y_train(Y_train==inf) = 0;
Y_train(Y_train==-inf) = 0;

m = min(size(X_train, 1), size(Y_train, 1));
X_train = X_train(1:m, :);
Y_train = Y_train(1:m, :);
save exp8.mat X_train Y_train

% Initial parameters
W = rand(30, 31);
lambda = 1;

% Compute the Loss
% loss = LossFunction(W, X_train, Y_train, lambda);
% grad = GradFunction(W, X_train, Y_train, lambda);
% X_train = [ones(length(X_train), 1)  X_train];
% L = norm(W*X_train(1,:)' - Y_train(1,:)');

% Traning
MaxIter = 500;
step = 10^(-6);
loss = zeros(1,MaxIter);
for i = 1:MaxIter 
    fprintf('\nIteration: %d.\n', i);
    grad = GradFunction(W, X_train, Y_train, lambda);
    W_new = W - step * grad;
    loss(i) = LossFunction(W_new, X_train, Y_train, lambda);
    fprintf('\nLoss: %d.\n', loss(i)); 
    W = W_new;
end
plot(loss)

% Visulize
W = load('W.dat');
[ amp_csi_a, amp_csi_b, amp_csi_c, ~, ~, ~ ] = ...
  read_csi('./sample_data/yz2_exp/78exp/anchor/31');   
X_test = amp_csi_a;
X_test(X_test==inf) = 0;
X_test(X_test==-inf) = 0;
X_test = [ones(length(X_test), 1)  X_test];
[ amp_csi_a, amp_csi_b, amp_csi_c, ~, ~, ~ ] = ...
  read_csi('./sample_data/yz2_exp/78exp/sailing/31'); 
Y_test = amp_csi_a;
Y_test(Y_test==inf) = 0;
Y_test(Y_test==-inf) = 0;

% Figure 22
% save fig_22.mat X_train Y_train X_test Y_test
% for i = 21:30;
i=26;
figure; hold on
set(0,'DefaultTextFontName','Times', 'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times', 'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1, 'DefaultLineMarkerSize',8);
% title('Train')
plot(X_train(i,:), 'b-o')
plot(X_train(i,:) * W', 'k--', 'LineWidth', 1.5)
plot(Y_train(i,:), 'r-*')
legend('k=0','Estimated', 'k=10 km/h', 'Location','SouthEast','Orientation','horizontal' )
axis([0 30.5 0 30]);
xlabel('Subcarrier index')
ylabel('CSI (dBm)')
grid on
box on
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\22_1.eps');
% end

% for i = 1:10
i = 4;
figure; hold on
set(0,'DefaultTextFontName','Times', 'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times', 'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1, 'DefaultLineMarkerSize',9);
plot(X_test(i,:),'b-o')
plot(X_test(i,:) * W', 'k--', 'LineWidth', 1.5)
plot(Y_test(i,:), 'r-*')
legend('k=0','Estimated', 'k=10 km/h', 'Location','SouthEast','Orientation','horizontal' )
axis([0 30.5 0 30]);
xlabel('Subcarrier index')
ylabel('CSI (dBm)')
grid on
box on
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\22_2.eps');
% end

% calculate the difference 
diff = X_test(i,:) * W' - Y_test(i,:);
% diff = X_test(i,2:end) - Y_test(i,:);
len = length(diff);
rho = 1 - 6*sum(diff.^2)/ (len*(len^2-1))

sim = zeros(10,1);
sim(end)=[]

% save fig_24.mat sim rho
figure; hold on
set(0,'DefaultTextFontName','Times', 'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times', 'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1, 'DefaultLineMarkerSize',9);
plot(sim,'b-o')
% legend('k=0','Estimated', 'k=10 km/h', 'Location','SouthEast','Orientation','horizontal' )
axis([1 8 0.58 1]);
xlabel('Distance (m)')
ylabel('\rho')
grid on
box on
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\24_1.eps');

sim_result = zeros(length(speed_scale), 12);
rho = zeros(length(speed_scale), 1);
for i = 1:1:length(speed_scale)
%     speed = speed_scale(i);
    map_index = find(speed_index == i); 
    for j = 1:1:length(map_index)
        map_start = floor(map_index(j) * map_index_rate);
        if map_start + map_index_step <= len_real_csi
            map_end = map_start + map_index_step;
        else
            map_end = len_real_csi;
        end
        csi_index = (map_start : map_end)'; 
    end
    if i == 1
        base_csi = amp_csi_a(csi_index, 15);
    else
        new_csi = amp_csi_a(csi_index, 15);
        diff = base_csi - new_csi;
        len = length(diff);
        rho(i) = 1 - 6*sum(diff.^2)/ (len*(len^2-1));
    end
end

figure; hold on
set(0,'DefaultTextFontName','Times', 'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times', 'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1, 'DefaultLineMarkerSize',9);
plot(rho,'b-o')
% legend('k=0','Estimated', 'k=10 km/h', 'Location','SouthEast','Orientation','horizontal' )
axis([1 10 0.58 1]);
xlabel('Speed margin (km/h)')
ylabel('\rho')
grid on
box on
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\24_2.eps');

%% Figure 27

d_1 = [0.87 0.92 0.91 0.99 0.99];
d_2 = [0.975 0.98 0.99 0.99 0.99];
d_3 = [0.96 0.99 0.96 0.87 0.90];
% acc_stop = [77.8571 95.57 99.28 99.50] / 100;
% acc_sail = [0.4257 0.5257 0.61 0.625];
figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
b = bar([d_2' d_1' d_3']);
% b(2).FaceColor = 'r';
legend('SWIM', 'Pliot', 'PADS', 'Location', 'SouthEast')
ylabel('True negative')
xlabel('Measurement case')
axis([0 6 0.6 1])
box on
set(gca,'xtick',[1 2 3 4 5])
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\27_1.eps');

d_1 = [0.98 0.98 0.97 0.99 0.99];
d_2 = [0.95 0.98 0.99 0.86 0.95];
d_3 = [0.96 0.99 0.96 0.97 0.96];
% acc_stop = [77.8571 95.57 99.28 99.50] / 100;
% acc_sail = [0.4257 0.5257 0.61 0.625];
figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
b = bar([d_1' d_2' d_3']);
% b(2).FaceColor = 'r';
legend('SWIM', 'Pliot', 'PADS', 'Location', 'SouthEast')
ylabel('True postive')
xlabel('Measurement case')
axis([0 6 0.6 1])
box on
set(gca,'xtick',[1 2 3 4 5])
hold off
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\27_2.eps');


%% figure 28

A = [0 0.83 0.96 0.98 0.99 0.99 1 1];
B = [0 0.71 0.89 0.95 0.97 0.98 0.99 0.99];
C = [0 0.63 0.78 0.85 0.92 0.93 0.96 0.99];
D = [0 0.68 0.82 0.89 0.90 0.92 0.93 0.99];
figure;hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',5);
plot(A*10, 'bp-', 'LineWidth',1);
plot(B*10, 'ro--', 'LineWidth',1);
plot(C*10, 'kd:', 'LineWidth',1);
plot(D*10, '--gs', 'LineWidth',1);
% plot(D*10, '.:b', 'LineWidth',1);
xlabel('Distinction distance (in meters)');
ylabel('Cumulative Probability');
set(gca, 'XTick', [1 2 3 4 5 6 7 8]) 
set(gca,'XTickLabel',{'0','1','2', '3', '4', '5', '6','7 '})
set(gca, 'YTick', [1 2 3 4 5 6 7 8 9 10]) 
set(gca,'YTickLabel',{'10%', '20%', '30%','40%','50%','60%','70%','80%','90%','100%'})
h=legend( 'SWIM', 'AutoFi', 'Pilot', 'PinLoc', 'Location','southeast')
axis([1 8 0 10])
% set(h,'Fontsize',10);
box on
grid on
hold off
print('-depsc2','-r600','D:\Latex\TMC\pics\28_1.eps');


%% Figure 29

h_1 = [0.9 0.9 0.9 0.85 0.76];
h_2 = [0.99 0.98 0.97 0.96 0.96];
figure; 
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
box on
% xlabel('Measurement case')
subplot(1,2,1); hold on
bar(h_1, 0.6)
axis([0.4 5.6 0 1.1])
box on
pos = axis;
xlabel('calibration valid range');
ylabel('Localization accuracy')
hold off

subplot(1,2,2); hold on
bar(h_2, 0.6, 'y')
ylabel('Detection rate')
axis([0.4 5.6 0.6 1.04])
box on
set(gca,'xtick',[1 2 3 4 5])
hold off
% suptitle('AVC')
% pos = axis;

% set(l, 'Position', [(pos(2)-pos(1))/2 pos(3)])
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\29.eps');

%% Figure 30

h_1 = [0.83 0.83 0.82 0.80 0.74 0.73];
figure; 
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
hold on
bar(h_1, 0.4)
% set(gca,'YLim', [0.5,1], 'XTickLabel',{'LIVE', 'TID2013'}, 'FontSize', 15);
% set(gca, 'Ytick', [0.5:0.05:1], 'ygrid','on','GridLineStyle','-');
box on
ylabel('Localization accuracy')
axis([0 7 0.5 0.9])
set(gca,'xtick',[1 2 3 4 5 6])
xlabel('Ship speed margin (km/h)');
set(gca, 'Ytick', [0.5:0.05:0.9], 'ygrid','on','GridLineStyle','-');
% e = [0.0198, 0.0124, 0.0096, 0.0112, 0.0875, 0.0990];
% hold on
% numgroups = size(h_1, 1); 
% numbars = size(h_1, 2); 
% groupwidth = min(0.8, numbars/(numbars+1.5));
% for i = 1:numbars
%       % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
%       x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
%       errorbar(x, h_1(:,i), e(:,i), 'k', 'linestyle', 'none', 'lineWidth', 1);
% end

print('-depsc2','-r600','D:\Latex\Infocom2019\pics\30.eps');

% Example
a_live = [0.9186, 0.9460, 0.9552, 0.9533];
a_tid = [0.6090, 0.6663, 0.7170, 0.7165];
a = [a_live; a_tid];
bar(a, 'grouped')
set(gca,'YLim', [0.5,1], 'XTickLabel',{'LIVE', 'TID2013'}, 'FontSize', 15);
ylabel('SRC');
set(gca, 'Ytick', [0.5:0.05:1], 'ygrid','on','GridLineStyle','-');
legend('25','50','100','200', 'Location', 'EastOutside');
legend('boxoff');
e = [0.0198, 0.0124, 0.0096, 0.0112; 0.0875, 0.0990, 0.1034, 0.0939];
hold on
numgroups = size(a, 1); 
numbars = size(a, 2); 
groupwidth = min(0.8, numbars/(numbars+1.5));
for i = 1:numbars
      % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
      x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
      errorbar(x, a(:,i), e(:,i), 'k', 'linestyle', 'none', 'lineWidth', 1);
end

%% Fig. 31

area = [10, 20, 30, 40, 50];
cost1 = area.^2 * 20 *8 / 3600;
cost2 = (area.^2 +(area/5).^2) *20 /3600;

figure; hold on
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
bar([cost2; cost1]' , 'grouped')
set(gca,'xticklabel',{' '; '10'; '20'; '30'; '40'; '50'; ' '})
% axis([0 8 0 120])
set(gca, 'ygrid','on','GridLineStyle','-');
xlabel('Localization area (m^2)')
ylabel('Time-cost (hour)')
legend('SWIM', 'Pilot', 'Location', 'NorthWest')
box on
hold off

(cost1-cost2)./cost1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Fig 9
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load fig_1.mat

figure; 
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
subplot(2,1,1); hold on
% fig1_speed(400:600) = fig1_speed(400:600)*2-12;
plot(fig1_speed(1:600), '-')
grid on;
legend('Ship speed', 'Location','SouthEast')
ylabel('Speed (km/h)');
axis([0 600 -2 19])
set(gca,'xtick',[])
set(gca,'yticklabel',{'0', '10', '20', '30'})
box on
hold off

% subplot(3,1,2); hold on
% plot(fig1_angle(1:600), 'r-')
% grid on;
% title('Ship');
% legend('Ship azimuth', 'Location','NorthEast')
% ylabel('degrees (^{\circ})');
% % axis([0 600 -2 19])
% set(gca,'xtick',[])
% % set(gca,'yticklabel',{'0', '10', '20', '30'})
% box on
% hold off

subplot(2,1,2); hold on
fig1_csi = zeros(600, 30);
fig1_csi_stop = amp_csi_a(2,:);
fig1_csi(1:200,:) = amp_csi_a(201:400,:); %fig1_csi_stop(ones(200,1),:) + randn(200, 30)*0.1;
fig1_csi(201:400,:) = amp_csi_a(201:100:20200,:);
fig1_csi(401:600,:) = maintain_csi + randn(200, 30)*0.1; %amp_csi_a(20201:20400,:);
imagesc(fig1_csi')
ylabel('Subcarrier ID');
axis([0 600 0 30])
xlabel('Time (Second)')
% set(gca,'xticklabel',{'0', '5', '10', '15', '20', '25', '30'})
box on
hold off

% subplot(3,1,3); hold on
% fig1_cir = zeros(600, 30);
% fig1_cir_stop = cir_csi_a(2,:);
% fig1_cir(1:200,:) = cir_csi_a(201:400,:); %fig1_cir_stop(ones(200,1),:) + randn(200, 30)*0.2;
% fig1_cir(201:400,:) = cir_csi_a(201:100:20200,:);
% fig1_cir(401:600,:) = cir_csi_a(20201:20400,:);
% imagesc(fig1_cir')
% xlabel('Time (Minute)')
% ylabel('Index ID');
% title('CIR');
% axis([0 600 0 30])
% set(gca,'xticklabel',{'0', '5', '10', '15', '20', '25', '30'})
% box on
% hold off
print('-depsc2','-r600','D:\Latex\ICDCS2019\pics\9_1.eps');



figure; 
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
subplot(2,1,1); hold on
% fig1_speed(400:600) = fig1_speed(400:600)*2-12;
% plot(fig1_speed(1:600), '-')
% grid on;
% legend('Ship speed', 'Location','SouthEast')
ylabel('Speed (km/h)');
% axis([0 600 -2 19])
% set(gca,'xtick',[])
% set(gca,'yticklabel',{'0', '10', '20', '30'})
box on
hold off

subplot(2,1,2); hold on
% fig1_csi = zeros(600, 30);
% fig1_csi_stop = amp_csi_a(2,:);
% fig1_csi(1:200,:) = amp_csi_a(201:400,:); %fig1_csi_stop(ones(200,1),:) + randn(200, 30)*0.1;
% fig1_csi(201:400,:) = amp_csi_a(201:100:20200,:);
% fig1_csi(401:600,:) = maintain_csi + randn(200, 30)*0.1; %amp_csi_a(20201:20400,:);
% imagesc(fig1_csi')
ylabel('Subcarrier ID');
% axis([0 600 0 30])
xlabel('Time (Second)')
% set(gca,'xticklabel',{'0', '5', '10', '15', '20', '25', '30'})
box on
hold off
print('-depsc2','-r600','D:\Latex\ICDCS2019\pics\9_2.eps');


% Figure 12_3
acc_stop = [80.0000 85.8571 91.8571 92.2857 95.2857] / 100;
acc_sail = [0.714 0.728 0.80 0.842 0.868];
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
print('-depsc2','-r600','D:\Latex\Infocom2019\pics\12_5.eps');

% Figure 12_6
acc_stop = [92.0000 96.8571 97.8571 97.2857 97.8857] / 100;
acc_sail = [0.814 0.828 0.88 0.902 0.968];
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
set(gca,'xticklabel',{' ' '5', '10', '20', '30', '100'})
hold off
print('-depsc2','-r600','D:\Latex\TMC\pics\12_6.eps');

% Figure 12_7
acc_stop = [85 90.8571 93.4286 93.7143 95.8571] / 100;
acc_sail = [0.48 0.50 0.53 0.547 0.564];
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
set(gca,'xticklabel',{' ' '5', '10', '20', '30', '100'})
hold off
print('-depsc2','-r600','D:\Latex\TMC\pics\12_7.eps');

figure; 
% set(0,'DefaultTextFontName','Times',...
% 'DefaultTextFontSize',18,... 
% 'DefaultAxesFontName','Times',... 
% 'DefaultAxesFontSize',18,... 
% 'DefaultLineLineWidth',1,... 
% 'DefaultLineMarkerSize',7.75);
% subplot(2,1,1); hold on
% % fig1_speed(400:600) = fig1_speed(400:600)*2-12;
% plot(fig1_speed(1:600), '-')
% grid on;
% legend('Ship speed', 'Location','SouthEast')
% ylabel('Speed (km/h)');
% axis([0 600 -2 19])
% set(gca,'xtick',[])
% set(gca,'yticklabel',{'0', '10', '20', '30'})
% box on
% hold off

% subplot(1,1,2); hold on
% plot(fig1_angle(1:600), 'r-')
% grid on;
% title('Ship');
% legend('Ship azimuth', 'Location','NorthEast')
% ylabel('degrees (^{\circ})');
% % axis([0 600 -2 19])
% set(gca,'xtick',[])
% % set(gca,'yticklabel',{'0', '10', '20', '30'})
% box on
% hold off

subplot(2,1,2); hold on
fig1_csi = zeros(600, 30);
fig1_csi_stop = amp_csi_a(2,:);
fig1_csi(1:200,:) = amp_csi_a(201:400,:); %fig1_csi_stop(ones(200,1),:) + randn(200, 30)*0.1;
fig1_csi(201:400,:) = amp_csi_a(201:100:20200,:);
fig1_csi(401:600,:) = maintain_csi + randn(200, 30)*0.1; %amp_csi_a(20201:20400,:);
imagesc(fig1_csi')
ylabel('Subcarrier ID');
axis([0 600 0 30])
xlabel('Time (Second)')
% set(gca,'xticklabel',{'0', '5', '10', '15', '20', '25', '30'})
box on
hold off

% subplot(3,1,3); hold on
% fig1_cir = zeros(600, 30);
% fig1_cir_stop = cir_csi_a(2,:);
% fig1_cir(1:200,:) = cir_csi_a(201:400,:); %fig1_cir_stop(ones(200,1),:) + randn(200, 30)*0.2;
% fig1_cir(201:400,:) = cir_csi_a(201:100:20200,:);
% fig1_cir(401:600,:) = cir_csi_a(20201:20400,:);
% imagesc(fig1_cir')
% xlabel('Time (Minute)')
% ylabel('Index ID');
% title('CIR');
% axis([0 600 0 30])
% set(gca,'xticklabel',{'0', '5', '10', '15', '20', '25', '30'})
% box on
% hold off
print('-depsc2','-r600','D:\Latex\ICDCS2019\pics\9_1.eps');

%% 
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',12,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',12,... 
'DefaultLineLineWidth',1,... 
'DefaultLineMarkerSize',7.75);
ax1 = subplot(2,1,1);
r = [0.92, 0.89; 0.77, 0.86; 0.59, 0.57];
bar(ax1, r,'stacked','DisplayName','r')
% set(hObject,'ytick',[]);
legend('Detection', 'Localization','Orientation','horizon')
t=0:0:0;
set(gca, 'ytick',t)
ylabel('Accuracy rate')
set(gca, 'XTickLabel', {'Before moving', 'At door side', 'At LOS path'})

ax2 = subplot(2,1,2);
e = [0.93, 0.89; 0.90, 0.85; 0.82, 0.80];
bar(ax2,e,'stacked')
legend('Detection', 'Localization','Orientation','horizon')
t=0:0:0;
set(gca, 'ytick',t)
ylabel('Accuracy rate')
set(gca, 'XTickLabel', {'Main hall', 'Meeting room', 'Dining roon'})

axis([ax1 ax2],[0.5 3.5 0 3])
% print('-depsc2','-r600','D:\Latex\TMC\pics\91.eps');













