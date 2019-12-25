clear all;
close all;
Date = '2017_All';
mkdir(fullfile('C:\Users\ASUS\Desktop\S1_M1_ICMS_3\ICMS_neural_preprocessing',Date));
Write = fullfile('C:\Users\ASUS\Desktop\S1_M1_ICMS_3\ICMS_neural_preprocessing',Date);
load('C:\Users\ASUS\Desktop\S1_M1_ICMS_3\2017_All\ICMS_neural_preprocessing_1ms');
fs = 20000;
pre_time = 0.05;
post_time = 0.05;
seg_post_time = 0.01;
Voltage_Area.Current = ICMS_data_prepro.Current;
for ch = 1:8
    Channel = sprintf('Channel_%d',ch); 
    Mean_AllTrial = [];
    for f = 1:length(ICMS_data_prepro.(Channel).AD_Segment(:,1))
        Segment = ICMS_data_prepro.(Channel).AD_Segment{f,1};
        Voltage_All = [];
        for i = 1:length(Segment(:,1))-1
%             time_1 = Segment(1,post_time*fs+1:end);
%             time_2 = Segment(i+1,post_time*fs+1:(post_time+seg_post_time)*fs+1);
            Data_1 = Segment(i+1,post_time*fs+1:end);
            Data_2 = Segment(i+1,post_time*fs+1:(post_time+seg_post_time)*fs+1);
            InvData_2 = -Data_2;
            [Min_Vol,Min_Locs] = findpeaks(InvData_2);
            if Min_Locs(1,1) == 0
               min_locs = Min_locs(1,2);
               total_vol = sum(abs(Data_2(1,1:min_locs)));
            else
               min_locs = Min_Locs(1,1);
               total_vol = sum(abs(Data_2(1,1:min_locs)));
            end
            Voltage_All(i,1) = total_vol;
        end
        Voltage_All(length(Segment(:,1)),1) = mean(Voltage_All);
        Mean = mean(Voltage_All);
        Voltage_Area.(Channel).Voltage{f,1} = Voltage_All;
        Mean_AllTrial(f,1) = Mean;
    end
    Voltage_Area.(Channel).Mean = Mean_AllTrial;
end
save(fullfile(Write,'Voltage_Area'),'Voltage_Area','-v7.3');