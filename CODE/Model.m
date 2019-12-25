
%% ========================================================================
clear all;
close all;
date = '2017_0420';
bin = 0.001;
Read_ICMS = fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\ICMS_neural_analysis',date);
Read_Velocity = fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Lever_pressing_excel');
read_files = dir([Read_ICMS '\*' num2str(bin*1000) 'ms.mat']);      % read data direction
read_velocity = dir([Read_Velocity '\*mat']);
mkdir(fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\ICMS_tf_model_data_gen',date));
Write = fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\ICMS_tf_model_data_gen',date);
load(fullfile(Read_ICMS,read_files.name));
load(fullfile(Read_Velocity,read_velocity.name));
for ch = [3 4 7 8]
    Channel = sprintf('Channel_%d',ch);
    p_ICMS_eta.(Channel) = [];
    p_Velocity_eta.(Channel) = [];
end
Variable = Table_ICMS.(Channel).Properties.VariableNames;
ICMS_input = [100;10;20;30;40;50;60;70;80;90];
Velocity_input = table2array(Table.Channel_1(:,12));
for ch = [3 4 7 8]
    Channel = sprintf('Channel_%d',ch);
    for i = 1:size(Table_ICMS.Channel_1,2)
        V = table2array(Table.(Channel).Properties.VariableNames(1,i));
        ICMS_neural = table2array(Table_ICMS.(Channel)(:,i));
        Velocity_neural = table2array(Table.(Channel)(:,i));
        %% eta squared
        b_ICMS = [ICMS_input ICMS_neural];      % compare two vector
        [p_value tb_ICMS] = anova1(b_ICMS); % ANOVA test to measure the relation
        saveas(figure(1),fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Model',['tb_ICMS_' Channel '_' V]))
        saveas(figure(2),fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Model',['errorbar_ICMS_' Channel '_' V]))
        saveas(figure(1),fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Model',['tb_ICMS_' Channel '_' V '.tif']))
        saveas(figure(2),fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Model',['errorbar_ICMS_' Channel '_' V '.tif']))
        close all;
        SST = double(tb_ICMS{4,2});    % 總變異
        SSE = double(tb_ICMS{3,2});    % 誤差
        SSB = double(tb_ICMS{2,2});    % 組間變異
        eta = SSB/SST;
        p_ICMS_eta.(Channel) = [p_ICMS_eta.(Channel); SSB/(SSB+SSE)];
        plot(b_ICMS(:,1),b_ICMS(:,2),'ro','MarkerSize',10,'LineWidth',3)
        xlabel('ICMS current (uA)','fontsize',20)
        xlabel(V,'fontsize',20)
        title(Channel,'fontsize',30)
        saveas(figure(1),fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Model',['scatter_ICMS_' Channel '_' V]))
        saveas(figure(1),fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Model',['scatter_ICMS_' Channel '_' V '.tif']))
        
        b_Velocity = [Velocity_input Velocity_neural];       % compare two vector
        [p_value tb_Velocity] = anova1(b_Velocity); % ANOVA test to measure the relation
        close all;
        SST = double(tb_Velocity{4,2});    % 總變異
        SSE = double(tb_Velocity{3,2});   % 誤差
        SSB = double(tb_Velocity{2,2});    % 組間變異
        eta = SSB/SST;
        p_Velocity_eta.(Channel) = [p_Velocity_eta.(Channel); SSB/(SSB+SSE)];
        plot(b_Velocity(:,1),b_Velocity(:,2),'ro','MarkerSize',10,'LineWidth',3)
        xlabel('Velocity (unit/s)','fontsize',20)
        xlabel(V,'fontsize',20)
        title(Channel,'fontsize',30)
        saveas(figure(1),fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Model',['scatter_Velocity_' Channel '_' V]))
        saveas(figure(1),fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Model',['scatter_Velocity_' Channel '_' V '.tif']))
        close all;
        %% transfer
        p = polyfit(ICMS_neural,ICMS_input,3)
        p2 = polyfit(Velocity_neural,Velocity_input,3)
        syms x
        f= p(1)*(x^3) + p(2)*(x^2) + p(3)*(x^1) + p(4)*(x^0)
        D = collect(laplace(f))
        syms x2
        f2= p2(1)*(x2^3) + p2(2)*(x2^2) + p2(3)*(x2^1) + p2(4)*(x2^0)
        N = collect(laplace(f2))

        H = collect(N/D)
    end
end

P_Velocity_eta = [];
P_ICMS_eta = [];
for ch = [3 4 7 8]
    Channel = sprintf('Channel_%d',ch);
    P_Velocity_eta = [P_Velocity_eta p_Velocity_eta.(Channel)];
    P_ICMS_eta = [P_ICMS_eta p_ICMS_eta.(Channel)];
end
h(1) = figure('units','normalized','position',[0 0 1 1])
boxplot(P_Velocity_eta','Labels',Variable)
set(h(1), 'DefaultTextFontSize', 30);
ylabel('eta squared','fontsize',30)
title('Velocity eta squared','fontsize',40)
strmin = [num2str(mean(P_Velocity_eta,2))];
text([1 2 3 4 5 6 7 8 9 10 11 12 13],mean(P_Velocity_eta,2),strmin,'HorizontalAlignment','center','fontsize',20);
saveas(h(1),fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Model','P_Velocity_eta'))
saveas(h(1),fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Model','P_Velocity_eta.tif'))

h(2) = figure('units','normalized','position',[0 0 1 1])
boxplot(P_ICMS_eta','Labels',Variable)
ylabel('eta squared','fontsize',30)
title('ICMS eta squared','fontsize',40)
strmin = [num2str(mean(P_ICMS_eta,2))];
text([1 2 3 4 5 6 7 8 9 10 11 12 13],mean(P_ICMS_eta,2),strmin,'HorizontalAlignment','center','fontsize',20);
saveas(h(2),fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Model','P_ICMS_eta'))
saveas(h(2),fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Model','P_ICMS_eta.tif'))








