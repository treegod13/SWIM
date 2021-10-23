function [ real_len, amp_csi_a, amp_csi_b, amp_csi_c, ...
           pha_csi_a, pha_csi_b, pha_csi_c, ...
           cir_csi_a, cir_csi_b, cir_csi_c] = get_cir( csi_origin_data )
%GET_CIR 此处显示有关此函数的摘要
%   此处显示详细说明
data = csi_origin_data;
len = length(data);

index = 0;
for i = 1:1:len
    if isempty(data{i})
        continue
    else
        index = index + 1;
    end    
    complex_csi = get_scaled_csi(data{i});
    complex_csi_a(index,:) = complex_csi(1,data{i}.perm(1), :);
    complex_csi_b(index,:) = complex_csi(1,data{i}.perm(2), :);
    complex_csi_c(index,:) = complex_csi(1,data{i}.perm(3), :);
        
    rssi(index) = get_total_rss(data{i});
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

% change NaN to 0
cir_csi_a(find(isnan(cir_csi_a)==1)) = 0; 
cir_csi_b(find(isnan(cir_csi_b)==1)) = 0; 
cir_csi_c(find(isnan(cir_csi_c)==1)) = 0; 

real_len = length(cir_csi_a);
end

