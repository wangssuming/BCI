
x = log([100; 10; 20; 30; 40; 50; 60; 70; 80; 90]);
Table = Table_ICMS;
% x  = log(table2array(Table.Channel_1(:,16)));
% delete = find(x<-6);
% x(delete) = [];
ind = 10;
for ch = 1:8
    ss_output = [];
    Channel = sprintf('Channel_%d',ch);
    y = table2array(Table.(Channel)(:,ind));
%     y(delete) = [];
    [fitresult, gof] = createFit_1order(x, y)
    title([Channel ' R^2 = ' num2str(gof.rsquare)])
    saveas(figure(1),fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Model',['ploynomial_1_order_' Channel]))
    saveas(figure(1),fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Model',['ploynomial_1_order_' Channel '.tif']))
    close all;
    if ch == 1
        Channel_1_input = y;
    elseif ch == 2
        Channel_2_input = y;
    elseif ch == 3
        Channel_3_input = y;
    elseif ch == 4
        Channel_4_input = y;
    elseif ch == 5
        Channel_5_input = y;
    elseif ch == 6
        Channel_6_input = y;
    elseif ch == 7
        Channel_7_input = y;
    elseif ch == 8
        Channel_8_input = y;
    end
end