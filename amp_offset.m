function [ amp_csi ] = amp_offset( complex_csi )
%AMP_OFFSET �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��

offset = 20;
b = ones(30, 1);
raw_amp = db(abs(complex_csi), 'power');
min_amp = mean(raw_amp');
amp_csi = raw_amp - min_amp' * b' + offset;

end

