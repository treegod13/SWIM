%% CSI process
% chenmz
% 2017.5.3

%% Initialization
clear ; close all; clc

%% =================== Part 1: Import data =======================
fprintf('Importing the data from CSI tools... \n');
data = read_bf_file('./sample_data/20210927/sailing/P_36mm_Los_2.4m_D_2m_T_3s_Time_1500.dat');
% data = read_bf_file('./sample_data/4_exp/none');
len = length(data);

%% =================== Part 2: Process data ======================
% Get the CSI values (H) from Antenna A, B, C.

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

% Write to csv file.
xlswrite('./sample_data/csi_dynamic.csv',amp_csi_a)


%% =================== Part 3: Plot data =========================
fprintf('Plotting Data ...\n')

% mesh the amplitude of CSI measurement
figure
meshz(amp_csi_b)
xlabel('Subcarrier f')
ylabel('Sample index')
zlabel('CSI amplitude')
% axis([0 30 0 400 10 35])

% mesh the phase of CSI measurement
figure
meshz(pha_csi_a)
xlabel('Subcarrier f')
ylabel('Sample index')
zlabel('CSI phase')
% axis([0 30 0 400 0 30])

% mesh the CIR
figure
meshz(cir_csi_b)
xlabel('Time(50ns)')
ylabel('Sample index')
zlabel('CIR amplitude')
% axis([0 30 0 400 10 35])

% Plot RSSI values flag=1:rssi flag=0:csi
plot_rssi(rssi, 0)
% for j = 1:1:30
%     plot_rssi(amp_csi_a(:,j), 0)
% end

% Plot the phase and amplitude data
figure
f = 10;
polar(pha_csi_a(:, f), amp_csi_a(:, f), 'b.')

figure
plot(amp_csi_a(f,:))
xlabel('Subcarrier f')
ylabel('CSI Amplitude')

figure
plot(pha_csi_a(f,:))
xlabel('Subcarrier f')
ylabel('CSI Phase')

% Plot a sample of CIR 
figure
set(0,'DefaultTextFontName','Times',...
'DefaultTextFontSize',18,... 
'DefaultAxesFontName','Times',... 
'DefaultAxesFontSize',18,... 
'DefaultLineLineWidth',2,... 
'DefaultLineMarkerSize',7.75);
stem(cir_csi_b(3000, :), 'LineWidth', 1, 'MarkerSize', 7.75)
xlabel('Time(50ns)')
ylabel('CIR Amplitude(dB)')

% statistial data
mean_amp = mean(cir_csi_a)
% max_amp = max(amp_csi_a)
std_amp = std(cir_csi_a)

figure, hold on
for i = 1:1:size(cir_csi_a, 1)
    plot(cir_csi_a(i,:))
end
hold off

% Dynamic plot CSI values amplitude.
amp_csi(:,:,1) = amp_csi_a;
amp_csi(:,:,2) = amp_csi_b;
amp_csi(:,:,3) = amp_csi_c;
size = 1;
period = 0.01;
plot_csi_amp(amp_csi, size, period);

% Dynamic plot CSI values phase.
pha_csi(:,:,1) = pha_csi_a;
pha_csi(:,:,2) = pha_csi_b;
pha_csi(:,:,3) = pha_csi_c;
size = 1;
period = 0.01;
plot_csi_pha(pha_csi, size, period);

% Dynamic plot CIR values.
cir_csi(:,:,1) = cir_csi_a;
cir_csi(:,:,2) = cir_csi_b;
cir_csi(:,:,3) = cir_csi_c;
size = 1;
period = 0.01;
plot_csi_amp(cir_csi, size, period);


%% =================== Part 3: Cluster data ======================

% ========================Link A Compex vaulue of CFR======================
f = 10;

figure
hold on
xlabel('Re(H(f))')
ylabel('Im(H(f))')
plot(real(complex_csi_a(:, f)), imag(complex_csi_a(:, f)), 'k.')
hold off

% 核心平滑密度估计 求实部和虚部的概率密度分布
xi = -25:0.1:25;
f_real = ksdensity(real(complex_csi_a(:, f)),xi);
figure; hold on
plot(xi,f_real)
xlabel('Re(H(f))')
ylabel('PDF')
hold off

f_imag = ksdensity(imag(complex_csi_a(:, f)), xi);
figure; hold on
plot(xi,f_imag)
xlabel('Im(H(f))')
ylabel('PDF')
hold off

figure
f = 4;
gridx1 = -25:.1:25;
gridx2 = -25:.1:25;
[x1,x2] = meshgrid(gridx1, gridx2);
x1 = x1(:);
x2 = x2(:);
xi = [x1 x2];
X = [real(complex_csi_a(:, f)) imag(complex_csi_a(:, f))];
ksdensity(X,xi);
xlabel('Re(H(f))')
ylabel('Im(H(f))')
zlabel('PDF')

% 基于频率统计，求实部、虚部、联合概率密度分布
plot_complex(real(complex_csi_a(:, f)), imag(complex_csi_a(:, f)), 50)

% ================== PDF of Amlitude and Phase of CFR======================
% Link A 
% for f=1:1:30
% 幅度的概率密度函数
f = 10;
xi = 0:0.1:40;
f_amp = ksdensity(amp_csi_a(:, f),xi);
figure; hold on
plot(xi,f_amp)
xlabel('Amplitude of H(f)')
ylabel('PDF')
axis([5 30 0 1])
hold off

% 相位的概率密度函数
yi = -2:0.01:2;
f_pha = ksdensity(pha_csi_a(:, f),yi);
figure; hold on
plot(yi,f_pha)
xlabel('Phase of H(f)')
ylabel('PDF')
axis([-2 -1 0 20])
hold off

% 幅度和相位的联合概率密度函数
gridx1 = 15:0.1:30;
gridx2 = -2:0.1:-1;
[x1,x2] = meshgrid(gridx1, gridx2);
x1 = x1(:);
x2 = x2(:);
zi = [x1 x2];
X = [amp_csi_a(:, f) pha_csi_a(:, f)];
figure
ksdensity(X, zi);
xlabel('Amplitude of H(f)')
ylabel('Phase of H(f)')
zlabel('PDF')

% f=10子载波 和 f=20子载波 幅度的联合概率密度分布
f1 = 10;
f2 = 20;
xi = 0:0.1:40;
f_amp = ksdensity(amp_csi_a(:, f1),xi);
figure; hold on
plot(xi,f_amp)
xlabel('Amplitude of H(f)')
ylabel('PDF')
hold off

xi = 0:0.1:40;
f_amp = ksdensity(amp_csi_a(:, f2),xi);
figure; hold on
plot(xi,f_amp)
xlabel('Amplitude of H(f)')
ylabel('PDF')
hold off

gridx1 = 0:.01:40;
gridx2 = 0:.01:40;
[x1,x2] = meshgrid(gridx1, gridx2);
x1 = x1(:);
x2 = x2(:);
xi = [x1 x2];
X = [amp_csi_a(:, f1) amp_csi_a(:, f2)];
ksdensity(X, xi);
xlabel('Re(H(f))')
ylabel('Im(H(f))')
zlabel('PDF')


% Link A and Link B -- KDE 
gridx1 = 0:.1:40;
gridx2 = 0:.1:40;
[x1,x2] = meshgrid(gridx1, gridx2);
x1 = x1(:);
x2 = x2(:);
xi = [x1 x2];
X = [amp_csi_a(:, f) amp_csi_b(:, f)];
ksdensity(X, xi);
xlabel('Re(H(f))')
ylabel('Im(H(f))')
zlabel('PDF')

% Link A and Link B
plot_complex(amp_csi_a(:, f), amp_csi_b(:, f), 100);


%% randon plot 50 CSI of a link
index = 1:30;
n = floor(len * rand(1));
figure;hold on
for i = n:1:n+10
    plot(index, cir_csi_a(i,:),'b','MarkerSize',10);
%     plot(index, amp_csi_b(i,:),'k','MarkerSize',10);
%     plot(index, amp_csi_c(i,:),'r','MarkerSize',10);
    xlabel('Subcarrier f')
    ylabel('CIR of H(f)')
%     h_leg = legend('Antenna A', 'Antenna B', 'Antenna C');
%     set(h_leg,'position',[0.69 0.118 0.209 0.135])
%     title('Antenna A')
%     axis([0 30 0 40])    
end
hold off

%% ================== Part 3: Feature Extraction ================
% normalized CFR amplitude and phase

win_size = 2;
F = zeros(1, 4);
for i = win_size:1:len
    H = data_normalize(amp_csi_a(i-win_size+1:i, :));
    phi = data_normalize(pha_csi_a(i-win_size+1:i, :));
    H_cov = cov(H');
    phi_cov = cov(phi');
    H_eigval = eig(H_cov);
    phi_eigval = eig(phi_cov);
    F = [F; [H_eigval(end), H_eigval(end-1), ...
        phi_eigval(end), phi_eigval(end-1)]];
end
F_static = F(2:end, :);
plot(F(:, 1), F(:, 3), 'b.')
save classify.mat F_static F_dynamic

figure; hold on 
plot(F_static(:, 1), F_static(:, 3), 'b.')
plot(F_dynamic(:, 1), F_dynamic(:, 3), 'r.')
xlabel('Max Eigenvalue of Amplitude')
ylabel('Max Eigenvalue of Phase')
legend('Static', 'Dynamic')
hold off

%% SVM --16 locations

num = 20;
C = 10; sigma = 0.1;
X_train = zeros(1, 180);
X_test = zeros(1, 180);
y_train = zeros(1,1);
y_test = zeros(1,1);
for i=1:1:16
    [ amp_csi_a, amp_csi_b, amp_csi_c, ...
      pha_csi_a, pha_csi_b, pha_csi_c ] = ...
      read_csi(sprintf('./sample_data/locations/%d', i));
    X_train = [X_train; amp_csi_a(1:end-num,:) amp_csi_b(1:end-num,:) amp_csi_c(1:end-num,:)...
               pha_csi_a(1:end-num,:) pha_csi_b(1:end-num,:) pha_csi_c(1:end-num,:)];
    y_train = [y_train; i * ones(length(amp_csi_a(1:end-num,:)), 1)];
    
    X_test = [X_test; amp_csi_a(end-num+1:end,:) amp_csi_b(end-num+1:end,:) amp_csi_c(end-num+1:end,:)...
               pha_csi_a(end-num+1:end,:) pha_csi_b(end-num+1:end,:) pha_csi_c(end-num+1:end,:)];
    y_test = [y_test; i * ones(size(amp_csi_a(end-num+1:end,:), 1), 1)];
    
end
X_train(1, :) = [];
y_train(1, :) = [];
X_test(1, :) = [];
y_test(1, :) = [];

fp = fopen('D:\ZIGBEE定位\CSI\matlab\sample_data\train.data','w+');
len = size(X_train, 1);
for i=1:1:len
    fprintf(fp,'%d ', y_train(i));
    for j = 1:1:size(X_train, 2)
        fprintf(fp,'%d:%d ', j, X_train(i,j));
    end
    fprintf(fp,'\n');    
end
fclose(fp);

fp = fopen('D:\ZIGBEE定位\CSI\matlab\sample_data\test.data','w+');
len = size(X_test, 1);
for i=1:1:len
    fprintf(fp,'%d ', y_test(i));
    for j = 1:1:size(X_test, 2)
        fprintf(fp,'%d:%d ', j, X_test(i,j));
    end
    fprintf(fp,'\n');    
end
fclose(fp);

%% CIR
fx = 6;
figure
subplot(211);
plot(amp_csi_a(fx,:))
xlabel('Subcarrier Index')
ylabel('CFR Amplitude(dB)')
subplot(212);
cir = ifft(complex_csi_a(fx,:));
stem(abs(cir))
xlabel('Time(50ns)')
ylabel('CIR Amplitude(dB)')

% 
figure
cir = ifft(complex_csi_a(1,:));
stem(abs(cir))
xlabel('Time(17ns)')
ylabel('CIR Amplitude(dB)')

% /4_exp/none
figure;hold on
cir = ifft(complex_csi_b(5,:));
stem(abs(cir))
x = 0:0.01:30;
y = 6.045*exp(-((x-8.001)/1.952).^2);
plot(x,y)
xlabel('Time(50ns)')
ylabel('CIR Amplitude(dB)')
legend('CIR', 'Rician')
hold off

% /4_exp/none
figure;hold on
cir = ifft(complex_csi_b(4,:));
stem(abs(cir))
x = 0:0.01:30;
y = 10.22*exp(-((x-7.227)/0.6404).^2);
plot(x,y)
xlabel('Time(50ns)')
ylabel('CIR Amplitude(dB)')
legend('CIR', 'Rician')
hold off

% Plot a sample of CIR vs CFR
fx = 6;
figure;
subplot(211);hold on
plot(amp_csi_b(fx,:))
plot(amp_csi_b(fx+10,:))
plot(amp_csi_b(fx+30,:))
plot(amp_csi_b(fx+40,:))
plot(amp_csi_b(fx+50,:))
hold off
xlabel('Subcarrier Index')
ylabel('CFR Amplitude(dB)')
subplot(212);hold on
cir = ifft(complex_csi_b(fx,:));
% stem(abs(cir), 'b')
cir = ifft(complex_csi_b(fx+10,:));
stem(abs(cir), 'b')
cir = ifft(complex_csi_b(fx+30,:));
% stem(abs(cir), 'b')
cir = ifft(complex_csi_b(fx+40,:));
% stem(abs(cir), 'b')
cir = ifft(complex_csi_b(fx+50,:));
% stem(abs(cir), 'b')
x = 0:0.01:30;
y = 1.617*exp(-((300*x-2432 )/1123 ).^2);
plot(x,y)
xlabel('Time(50ns)')
ylabel('CIR Amplitude(dB)')
legend('CIR', 'Rician')
hold off

%
figure
ind = 15:1:30;
subplot(211);
plot(amp_csi_b(ind,:)')
xlabel('Subcarrier Index')
ylabel('CFR Amplitude(dB)')
subplot(212);
ind = [5 6 7 8 9  11  13  15] ;
plot(cir_csi_a(ind,:)')
xlabel('Time(50ns)')
ylabel('CIR Amplitude(dB)')

% 
ind = 1:1:30
cir = cir_csi_b(1:300, :);
figure
plot(mean(cir,1))
%
d = abs(cir);
custpdf = @(x, A, sigma) x./(sigma^2).*exp(-(A^2+x.^2)./(2*sigma^2)).*besseli(A.*x,sigma^2);
[phat,pci] = mle(x,'pdf',custpdf,'start',[1,1])

r = makedist('Rician','s',8,'sigma',5);
rng default % For reproducibility
x = random(r,1000,1);
[phat,pci] = mle(cir,'pdf',@(x,s,sigma) pdf('rician',x,s,4),'start',10)

A=8 ;
sigma=5;
x=0:.01:30;
y = x./(sigma^2).*exp(-(A^2+x.^2)./(2*sigma^2)).*besseli(A.*x,sigma^2)
figure
plot(x,y,'r-')
grid on
xlabel('r/σ'),ylabel('p(r)')
hold on


  