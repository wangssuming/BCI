clear all;
close all;
Date = '2017_All';
mkdir(fullfile('C:\Users\ASUS\Desktop\S1_M1_ICMS_3\ICMS_neural_preprocessing_All',Date));
Write = fullfile('C:\Users\ASUS\Desktop\S1_M1_ICMS_3\ICMS_neural_preprocessing_All',Date);

load('C:\Users\ASUS\Desktop\S1_M1_ICMS_3\2017_All\ICMS_neural_preprocessing_1ms');
fs = 20000;
pre_time = 0.05;
post_time = 0.05;
seg_post_time = 0.01;

ICMS_Area_Latency.Current = ICMS_data_prepro.Current;
for ch = 1:8
    Channel = sprintf('Channel_%d',ch); 
    Mean_AllTrial = [];
    for f = 1:length(ICMS_data_prepro.(Channel).AD_Segment(:,1))
        Segment = ICMS_data_prepro.(Channel).AD_Segment{f,1};
        Voltage_All = [];
        Peak_Valley = [];
        Latency = [];

        for i = 1:length(Segment(:,1))-1
%             time_1 = Segment(1,pre_time*fs+1:end);
            Data_1 = Segment(i+1,pre_time*fs+1:end);
            Data_2 = Segment(i+1,pre_time*fs+1:(pre_time+seg_post_time)*fs+1);
            InvData_2 = -Data_2;
            
            [Max_Vol,Max_Locs] = findpeaks(Data_2);
            if Max_Locs(1,1) == 0               
               max_locs = Max_locs(1,2);
               max_vol =  Data_2(1,max_locs);     
            else
               max_locs = Max_Locs(1,1);
               max_vol =  Data_2(1,max_locs);
            end
            
            [Min_Vol,Min_Locs] = findpeaks(InvData_2);
            if Min_Locs(1,1) == 0               
               min_locs = Min_locs(1,2);
               min_vol =  Data_2(1,min_locs);
               total_vol = sum(abs(Data_2(1,1:min_locs)));
            else
               min_locs = Min_Locs(1,1);
               min_vol =  Data_2(1,min_locs);
               total_vol = sum(abs(Data_2(1,1:min_locs)));
            end
            
            Latency(i,1) = abs(max_locs - min_locs)/fs*1000;          
            Peak_Valley(i,1) = max_locs/fs*1000;
            Peak_Valley(i,2) = max_vol;
            Peak_Valley(i,3) = min_locs/fs*1000;
            Peak_Valley(i,4) = min_vol;
            Voltage_All(i,1) = total_vol;                               
        end
        
        Voltage_All(length(Segment(:,1)),1) = mean(Voltage_All);
        Mean = mean(Voltage_All);
        Mean_AllTrial(f,1) = Mean;
        ICMS_Area_Latency.Peak_Valley.(Channel).Latency{f,1} = Latency;
        ICMS_Area_Latency.Peak_Valley.(Channel).Position_Value{f,1} = Peak_Valley;
        ICMS_Area_Latency.Voltage_Area.(Channel).Voltage{f,1} = Voltage_All;        
    end
    ICMS_Area_Latency.Voltage_Area.(Channel).Mean = Mean_AllTrial;
end
save(fullfile(Write,'Voltage_Area_Peak_Valley_Latency_Varience'),'ICMS_Area_Latency','-v7.3');

for f = 1:length(ICMS_data_prepro.(Channel).AD_Segment(:,1))
    figure(f);
    title(ICMS_Area_Latency.Current(f,1))    
    for ch = 1:8  
        Channel = sprintf('Channel_%d',ch); 
        Peak_Valley_Plot = ICMS_Area_Latency.Peak_Valley.(Channel).Position_Value{f,1};
        s(ch) = subplot(2,4,ch);
        boxplot([Peak_Valley_Plot(:,1),Peak_Valley_Plot(:,3)],'Labels',{'Peak','Valley'});
        title(s(ch),Channel)
        ylabel('ms')   
    end
    name = ICMS_Area_Latency.Current(f,:);
    saveas(figure(f),fullfile(Write,name));
end
        