function plot_csi_amp( amp_csi, N, T )
%PLOTDATA Summary of this function goes here
%   Detailed explanation goes here
%   N: 窗口大小
%   T: 延时

% clean data
amp_csi(amp_csi == -Inf) = 0;

index = 1:30;
amp_csi_a = amp_csi(:,:,1);
amp_csi_b = amp_csi(:,:,2);
amp_csi_c = amp_csi(:,:,3);
len = size(amp_csi, 1);
max_axis = 10 * ceil(max(max(max(amp_csi)))/10);
min_axis = 10 * floor(min(min(min(amp_csi)))/10);

figure;
for i = 1:1:len
    plot(index, amp_csi_a(i,:),'b','MarkerSize',10);
    hold on
    plot(index, amp_csi_b(i,:),'k','MarkerSize',10);
    plot(index, amp_csi_c(i,:),'r','MarkerSize',10);
    xlabel('Subcarrier f')
    ylabel('Amplitude of H(f)')
    h_leg = legend('Antenna A', 'Antenna B', 'Antenna C');
    set(h_leg,'position',[0.69 0.118 0.209 0.135])
%     title('Antenna A')
    axis([0 30 min_axis max_axis])
    if i > N
        plot(index, amp_csi_a(i-N,:),'w','MarkerSize',10);
        plot(index, amp_csi_b(i-N,:),'w','MarkerSize',10);
        plot(index, amp_csi_c(i-N,:),'w','MarkerSize',10);
        for j = 0:1:N-1
            plot(index, amp_csi_a(i-j,:),'b','MarkerSize',10);
            plot(index, amp_csi_b(i-j,:),'k','MarkerSize',10);
            plot(index, amp_csi_c(i-j,:),'r','MarkerSize',10);
        end
    end    
    pause(T);
    hold off
end

% 
% figure;
% for i = 1:1:len
%     % 绘图保留历史数据，则保留；不保留则注释
% %     hold on
%     plot(index, amp_csi_a(i,:),'b','MarkerSize',10);
%     % 绘图保留历史数据，则注释；不保留则保留
%     hold on
%     plot(index, amp_csi_b(i,:),'k','MarkerSize',10);
%     plot(index, amp_csi_c(i,:),'r','MarkerSize',10);
%     xlabel('Subcarrier f')
%     ylabel('Amplitude of H(f)')
%     h_leg = legend('Antenna A', 'Antenna B', 'Antenna C');
%     set(h_leg,'position',[0.69 0.118 0.209 0.135])
%     title('Antenna A')
%     axis([0 30 0 40])
%     pause(T);
%     hold off
% end

% 
% % Plot the Antenna A CSI amplitude.
% figure;
% hold on
% for i = 1:1:len
%     plot(index, amp_csi_a(i,:),'b','MarkerSize',10);
% end
% xlabel('Subcarrier f')
% ylabel('Amplitude of H(f)')
% title('Antenna A')
% hold off
% 
% % Plot the Antenna B CSI amplitude.
% figure;
% hold on
% for i = 1:1:len
%     plot(index, amp_csi_b(i,:),'r','MarkerSize',10);
% end
% xlabel('Subcarrier f')
% ylabel('Amplitude of H(f)')
% title('Antenna B')
% % hold off
% 
% % Plot the Antenna C CSI amplitude.
% figure;
% hold on
% for i = 1:1:len
%     plot(index, amp_csi_c(i,:),'g','MarkerSize',10);
% end
% xlabel('Subcarrier f')
% ylabel('Amplitude of H(f)')
% title('Antenna C')
% hold off

end

