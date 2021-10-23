function [ cir_csi ] = cir_transform( amp_csi, pha_csi )
%CIR_TRANSFORM �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��

real_csi = amp_csi .* cos(pha_csi);
image_csi = amp_csi .* sin(pha_csi);
complex_csi = complex(real_csi, image_csi);
cir = abs(ifft(complex_csi, [], 2));
x = cir(:, end-4 : end);
y = cir(:, 1:end-5);
cir_csi = [x y];
% cir_csi = cir;
end

