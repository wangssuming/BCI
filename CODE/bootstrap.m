load('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Lever_pressing_excel\All_Lever_pressing_analysis_2.mat')
close all;
variable_select = 10;
for ch = [3 4 7 8]
    Channel = sprintf('Channel_%d',ch);
    neural_response = table2array(Table.(Channel)(:,variable_select));
    c = length(neural_response);
    bootstrap.(Channel) = [];
    [bootstat,bootsam] = bootstrp(1000,@mean,neural_response);
    figure
    h(1) = histogram(bootstat)
    bootstrap.(Channel) = bootstat;
    title(Channel,'fontsize',30)
    xlabel('Area to baseline','fontsize',20)
    ylabel('Count','fontsize',20)
    saveas(h(1),fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Model\bootstrap_leverPressing',['Bootsrap_' Channel]))
    saveas(h(1),fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Model\bootstrap_leverPressing',['Bootsrap_' Channel '.tif']))
end
