%% PADS implementry
% chenmz
% 2017.5.23

%% Initialization
clear ; close all; clc
win_size = 30;

%% =================== Part 1: Dynamic data ======================
fprintf('Importing the data from CSI tools... \n');
data = read_bf_file('./sample_data/1walk');
len = length(data);

for i = 1:1:len
    complex_csi = get_scaled_csi(data{i});
    complex_csi_a(i,:) = complex_csi(1,data{i}.perm(1), :);
    complex_csi_b(i,:) = complex_csi(1,data{i}.perm(2), :);
    complex_csi_c(i,:) = complex_csi(1,data{i}.perm(3), :);
end

% Get the amplitude of each subcarriers. unit: dB.
amp_csi_a = db(abs(complex_csi_a));
amp_csi_b = db(abs(complex_csi_b));
amp_csi_c = db(abs(complex_csi_c));

% Get the phase of each subcarriers. units: rad
raw_pha_csi_a = angle(complex_csi_a);
raw_pha_csi_b = angle(complex_csi_b);
raw_pha_csi_c = angle(complex_csi_c);

% Phase sanitization
pha_csi_a = phase_sanitize(raw_pha_csi_a);
pha_csi_b = phase_sanitize(raw_pha_csi_b);
pha_csi_c = phase_sanitize(raw_pha_csi_c);

F = zeros(1, 4);
for i = win_size:win_size:len
    H = data_normalize(amp_csi_b(i-win_size+1:i, :));
    phi = data_normalize(pha_csi_b(i-win_size+1:i, :));
    H_cov = cov(H');
    phi_cov = cov(phi');
    H_eigval = eig(H_cov);
    phi_eigval = eig(phi_cov);
    F = [F; [H_eigval(end), H_eigval(end-1), ...
        phi_eigval(end), phi_eigval(end-1)]];
end
F_dynamic = F(2:end, :);
clearvars -except F_dynamic win_size

%% =================== Part 2: Static data =======================
data = read_bf_file('./sample_data/static');
len = length(data);

for i = 1:1:len
    complex_csi = get_scaled_csi(data{i});
    complex_csi_a(i,:) = complex_csi(1,data{i}.perm(1), :);
    complex_csi_b(i,:) = complex_csi(1,data{i}.perm(2), :);
    complex_csi_c(i,:) = complex_csi(1,data{i}.perm(3), :);
end

% Get the amplitude of each subcarriers. unit: dB.
amp_csi_a = db(abs(complex_csi_a));
amp_csi_b = db(abs(complex_csi_b));
amp_csi_c = db(abs(complex_csi_c));

% Get the phase of each subcarriers. units: rad
raw_pha_csi_a = angle(complex_csi_a);
raw_pha_csi_b = angle(complex_csi_b);
raw_pha_csi_c = angle(complex_csi_c);

% Phase sanitization
pha_csi_a = phase_sanitize(raw_pha_csi_a);
pha_csi_b = phase_sanitize(raw_pha_csi_b);
pha_csi_c = phase_sanitize(raw_pha_csi_c);

F = zeros(1, 4);
for i = win_size:win_size:len
    H = data_normalize(amp_csi_b(i-win_size+1:i, :));
    phi = data_normalize(pha_csi_b(i-win_size+1:i, :));
    H_cov = cov(H');
    phi_cov = cov(phi');
    H_eigval = eig(H_cov);
    phi_eigval = eig(phi_cov);
    F = [F; [H_eigval(end), H_eigval(end-1), ...
        phi_eigval(end), phi_eigval(end-1)]];
end
F_static = F(2:end, :);
clearvars -except F_static F_dynamic

%% =================== Part 3: Classify =======================

% visualize data
figure; hold on 
plot(F_static(:, 1), F_static(:, 3), 'b*')
plot(F_dynamic(:, 1), F_dynamic(:, 3), 'ro')
xlabel('Max Eigenvalue of Amplitude')
ylabel('Max Eigenvalue of Phase')
legend('Static', 'Dynamic')
hold off

%SVM classifier
X = [F_static(:, 1) F_static(:, 3); F_dynamic(:, 1) F_dynamic(:, 3)];
y = [zeros(size(F_static, 1), 1); ones(size(F_dynamic, 1), 1)];
C = 1; sigma = 0.1;

% We set the tolerance and max_passes lower here so that the code will run
% faster. However, in practice, you will want to run the training to
% convergence.
model= svmTrain(X, y, C, @(x1, x2) gaussianKernel(x1, x2, sigma)); 
visualizeBoundary(X, y, model);





















