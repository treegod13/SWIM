function [ cv ] = cv( cir )
%CIR_STD �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
% cir_max = max(cir);
% cir_min = min(cir);
% cir_norm = (cir - cir_min) / (cir_max - cir_min);
s = std(cir);
m = mean(cir);
cv = s/m;

end

