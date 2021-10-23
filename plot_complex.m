function plot_complex( x, y, N )
%PLOT_COMPLEX Summary of this function goes here
%   Detailed explanation goes here
% 栅格数量 N

% x的概率密度分布
hx=(max(x)-min(x))/N;
X=linspace(min(x),max(x)+hx,N+2);
num=length(x);%% 样本点数量
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

% y的概率密度分布
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

% 联合概率分布
ZZ(N+1,N+1)=0;
for i=1:N+1
     q = find(x>=X(i) & x<X(i+1));
     for j=1:N+1;
         yy = y(q);
         yt=find(yy>=Y(j) & yy<Y(j+1));
         ZZ(i,j)=length(yt)./ num;%% 联合概率密度函数
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

