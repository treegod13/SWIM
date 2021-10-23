function [ cv ] = cv( cir )
%CIR_STD 此处显示有关此函数的摘要
%   此处显示详细说明
% cir_max = max(cir);
% cir_min = min(cir);
% cir_norm = (cir - cir_min) / (cir_max - cir_min);
s = std(cir);
m = mean(cir);
cv = s/m;

end

