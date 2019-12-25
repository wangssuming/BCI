clear all;
close all;
Date = '2017_0616';
Read = fullfile('C:\Users\ASUS\Desktop\S1_M1_ICMS_4\Combine_plx',Date);
mkdir(fullfile('C:\Users\ASUS\Desktop\S1_M1_ICMS_4\SumTrial_Velocity',Date));
Write = fullfile('C:\Users\ASUS\Desktop\S1_M1_ICMS_4\SumTrial_Velocity',Date); 
Direction = 'C:\Users\ASUS\Desktop\S1_M1_ICMS_4\SumTrial_Velocity\2017_0616';
File = dir([Read '\*5ms.mat']);
load([Read '\' File.name]);

fs = 20000;
freq1 = 50*2/fs;
freq2 = 0.1*2/fs;
N1 = 3;
N2 = 3;

timeseries = zeros(5001,1);
for i =1:5001
    timeseries(i) = timeseries(i) + (i/fs);
end
synchronize_t_touch = Combine_DAQ_plx.Event_touch{1,1};
duration = Combine_DAQ_plx.Event_duration{1,1};

figure(1);
for ch = 1:8    
    ad_seg_vol = zeros(5001,1);
    AD_Area = zeros(length(synchronize_t_touch),1);
    Channel = sprintf('%s_%d','Channel',ch);
    ad = Combine_DAQ_plx.(Channel).AD{1,1};
    ad = ad';    
    
    [a1,b1] = butter(N1,freq1,'low'); %lowpass filtering
    ad_low = filtfilt(a1,b1,ad);
    [a2,b2] = butter(N2,freq2,'high'); %highpass filtering
    ad_high = filtfilt(a2,b2,ad_low);
%      ad_high = ad_high;
      
    for i = 1:length(synchronize_t_touch)
        ff = 0;
        ad_d = detrend(ad_high(round(synchronize_t_touch(i)*fs) - 1000:round(synchronize_t_touch(i)*fs) + 4000));
        Trial = sprintf('%s_%d','Trial',i);
        SumTrial_V.(Channel).(Trial).Origin = ad_d;
        for f = 1301:5001
            ff = ff + 1;
            ad_seg_vol(ff) = ad_seg_vol(ff) + ad_d(f);
        end
        ad_seg_vol(find(ad_seg_vol == 0)) = [];
    end
    SumTrial_V.(Channel).AD_seg_vol = ad_seg_vol;
    ad_seg_maxvol = max(ad_seg_vol);
    ad_seg_minvol = min(ad_seg_vol);
    max_position = 1300+find(ad_seg_vol==ad_seg_maxvol);
    min_position = 1300+find(ad_seg_vol==ad_seg_minvol);
    
    SumTrial_V.(Channel).AD_seg_maxvol = max(ad_seg_vol);
    SumTrial_V.(Channel).AD_seg_minvol = min(ad_seg_vol);
    SumTrial_V.(Channel).AD_seg_maxposition = max_position;
    SumTrial_V.(Channel).AD_seg_minposition = min_position;
    
    for trial = 1:length(synchronize_t_touch)
        ad_seg_vol_area = 0;
        Trial = sprintf('%s_%d','Trial',trial);
        ad_get_area = abs(SumTrial_V.(Channel).(Trial).Origin);
        if max_position > min_position
           for tr = min_position:max_position
               ad_seg_vol_area = ad_seg_vol_area + ad_get_area(tr);
           end
        end
        if max_position < min_position
           for tr = max_position:min_position
               ad_seg_vol_area = ad_seg_vol_area + ad_get_area(tr);
           end
        end
        AD_Area(trial) = AD_Area(trial) + ad_seg_vol_area;
        
    end
    Area_Velocity.(Channel).Area = AD_Area;
    Area_Velocity.(Channel).Velocity = 1./duration;
    
    subplot(2,4,ch)
    scatter(Area_Velocity.(Channel).Velocity,AD_Area)
    title(Channel)
    xlabel('1/T')
    ylabel('mV')
end
saveas(figure(1),fullfile(Direction,'LFP_Area_to_Velocity_gain1.png'))
name1 = 'Area_Velocity';
name2 = 'SumTrial_V';
save(fullfile(Write,name1),'Area_Velocity','-v7.3');
save(fullfile(Write,name2),'SumTrial_V','-v7.3');

for ch = 1:8
    Channel = sprintf('%s_%d','Channel',ch);
    max = SumTrial_V.(Channel).AD_seg_maxposition;
    min = SumTrial_V.(Channel).AD_seg_minposition;
    for tri = 1:8
        Trial = sprintf('%s_%d','Trial',tri);
        PlotTrial = SumTrial_V.(Channel).(Trial).Origin;        
        figure(ch+1);
        subplot(2,4,tri)
        plot(timeseries,PlotTrial)
        hold on
        plot(max/fs,PlotTrial(max),'ro')
        hold on
        plot(min/fs,PlotTrial(min),'ro')
        title(tri)
        xlabel('time')
        ylabel('mV')
     end
     for tri = 9:16
         Trial = sprintf('%s_%d','Trial',tri);
         PlotTrial = SumTrial_V.(Channel).(Trial).Origin;
         figure(ch+9);
         subplot(2,4,tri-8) 
         plot(timeseries,PlotTrial)
         hold on
         plot(max/fs,PlotTrial(max),'ro')
         hold on
         plot(min/fs,PlotTrial(min),'ro')
         title(tri)
         xlabel('time')
         ylabel('mV')
     end
     for tri = 17:18
         Trial = sprintf('%s_%d','Trial',tri);
         PlotTrial = SumTrial_V.(Channel).(Trial).Origin;
         figure(ch+17);
         subplot(2,1,tri-16)
         plot(timeseries,PlotTrial)
         hold on
         plot(max/fs,PlotTrial(max),'ro')
         hold on
         plot(min/fs,PlotTrial(min),'ro')       
         title(tri)
         xlabel('time')
         ylabel('mV')
     end
end

for i = 1:3
    for n = 1:8
        name = sprintf('%s_%d_%d','Channel',n,i);
        saveas(figure((n*i)+1),fullfile(Direction,name));
    end
end
    





    
    
