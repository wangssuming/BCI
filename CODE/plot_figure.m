current = [100 10 20 30 40 50 60 70 80 90];
for ch = 1:8
    Channel = sprintf('Channel_%d',ch);
    for i = 1:length(current)
        h(1) = figure;
        yyaxis left
        M_unit = mean(ICMS_data_prepro.(Channel).Multi_unit_PSTH{i,:}(2:end,:));
        time_train = ICMS_data_prepro.(Channel).Multi_unit_PSTH{i,:}(1,:);
        bar(time_train,M_unit,'FaceColor',[0 .9 .9],'EdgeColor',[0 .5 .5],'LineWidth',1.5)
        title(Channel,'fontsize',20,'fontweight','bold')
        ylabel('Spike (count/time bin)','fontsize',16,'fontweight','bold')

        yyaxis right
        SSEP = ICMS_data_prepro.(Channel).SSEP{i,:}(2,:);
        time_train = ICMS_data_prepro.(Channel).SSEP{i,:}(1,:);
        plot(time_train,SSEP,'r','LineWidth',2)
        ylabel('Voltage (mV)','fontsize',16,'fontweight','bold')
        ax = gca;
        ax.YColor = 'r';
        saveas(h(1),fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Model\ICMS_SSEP_PSTH',[Channel '_' num2str(current(i)) 'uA']));
        saveas(h(1),fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Model\ICMS_SSEP_PSTH', [Channel '_' num2str(current(i)) 'uA.tif']));  
        close all;
        
         
    end
    h(2) = figure;
    boxplot([SSEP_analysis_ICMS.(Channel).LFP_analysis.Max_peak_SSEP,SSEP_analysis_ICMS.(Channel).LFP_analysis.Min_peak_SSEP],'Labels',{'Peak latency', 'Valley latency'})
    title(Channel,'fontsize',20,'fontweight','bold')
    ylabel('period (s)')
    saveas(h(2),fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Model\ICMS_SSEP_PSTH',[Channel '_Latency_' num2str(current(i)) 'uA']));
    saveas(h(2),fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Model\ICMS_SSEP_PSTH', [Channel '_Latency_' num2str(current(i)) 'uA.tif'])); 
end

