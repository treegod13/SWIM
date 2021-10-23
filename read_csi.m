function [ amp_csi_a, amp_csi_b, amp_csi_c, ...
           pha_csi_a, pha_csi_b, pha_csi_c ] = read_csi( addr )
%READ_CSI 此处显示有关此函数的摘要
%   此处显示详细说明
data = read_bf_file(addr);
len = length(data);
for i = 1:1:len
    complex_csi = get_scaled_csi(data{i});
    complex_csi_a(i,:) = complex_csi(1,data{i}.perm(1), :);
    complex_csi_b(i,:) = complex_csi(1,data{i}.perm(2), :);
    complex_csi_c(i,:) = complex_csi(1,data{i}.perm(3), :);
        
    rssi(i) = get_total_rss(data{i});
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

end

