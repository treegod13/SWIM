function plot_complex( x, y, N )
%PLOT_COMPLEX Summary of this function goes here
%   Detailed explanation goes here
% դ������ N

% x�ĸ����ܶȷֲ�
hx=(max(x)-min(x))/N;
X=linspace(min(x),max(x)+hx,N+2);
num=length(x);%% ����������
Z_x(N+1)=0;
for i=1:N+1
    q=find(x>=X(i)&x<X(i+1));
    Z_x(i)=length(q)./ num;
end
figure; hold on
plot(X(1:N+1),Z_x)
xlabel('Re(H(f))')
ylabel('PDF')
hold off

% y�ĸ����ܶȷֲ�
hy=(max(y)-min(y))/N;
Y=linspace(min(y),max(y)+hy,N+2);
Z_y(N+1)=0;
for i=1:N+1
    q=find(x>=X(i)&x<X(i+1));
    Z_y(i)=length(q)./ num;
end
figure; hold on
plot(X(1:N+1),Z_y)
xlabel('Im(H(f))')
ylabel('PDF')
hold off

% ���ϸ��ʷֲ�
ZZ(N+1,N+1)=0;
for i=1:N+1
     q = find(x>=X(i) & x<X(i+1));
     for j=1:N+1;
         yy = y(q);
         yt=find(yy>=Y(j) & yy<Y(j+1));
         ZZ(i,j)=length(yt)./ num;%% ���ϸ����ܶȺ���
     end
end
figure; 
mesh(X(1:N+1),Y(1:N+1),ZZ);
xlabel('Re(H(f))')
ylabel('Im(H(f))')
% xlabel('Link A')
% ylabel('Link B')
zlabel('PDF')
% view(-4,46)
% hold off

end

