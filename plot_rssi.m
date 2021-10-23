function plot_rssi( rssi, flag )
%PLOT_RSSI Summary of this function goes here
%   Detailed explanation goes here

if flag == 0
    figure;
    plot(rssi);
    xlabel('Time (ms)')
    ylabel('RSSI (dBm)')
    legend('RSSI values');
else
    figure;
    plot(rssi);
    xlabel('Time (ms)')
    ylabel('CSI (dBm)')
    legend('CSI values');
end
end

