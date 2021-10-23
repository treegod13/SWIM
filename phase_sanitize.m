function [ pha_clean ] = phase_sanitize( pha )
%PHASE_SANITIZATION �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵�� 
%   ����һ��link����λֵ

%% PinLoc
% F = 30;
% pha = unwrap(pha, [], 2);
% a = (pha(:, F) - pha(:, 1)) / ( 2 * pi *  F);
% sum_f = zeros(size(pha, 1), 1);
% for f = 1:1:F
%     sum_f = sum_f + pha(:, f);
% end
% b = sum_f / F;
% 
% f_index = 1:1:30;
% B = repmat(b, 1, 30);
% pha_clean = pha - a * f_index - B;

%% PADS
F = 30;
pha = unwrap(pha, [], 2);
a = (pha(:, F) - pha(:, 1)) / F;
sum_f = zeros(size(pha, 1), 1);
for f = 1:1:F
    sum_f = sum_f + pha(:, f);
end
b = sum_f / F;

f_index = -15:1:15;
% f_index = [-28:2:-2, -1, 1:2:27, 28];
f_index(f_index==0)=[];
B = repmat(b, 1, 30);
pha_clean = pha - a * f_index - B;

end

