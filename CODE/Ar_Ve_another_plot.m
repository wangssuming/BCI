clear all;
close all;
bin = 0.001;        % time bin for PSTH and ISI
Date = '2017_0620';
Read = fullfile('C:\Users\ASUS\Desktop\S1_M1_ICMS_4\Combine_plx',Date);
mkdir(fullfile('C:\Users\ASUS\Desktop\S1_M1_ICMS_4\area_vel',Date));
Write = fullfile('C:\Users\ASUS\Desktop\S1_M1_ICMS_4\area_vel',Date);

File = dir([Read '\*5ms.mat']);
load([Read '\' File.name]);
pre_time_1 = 0.05;           % pre_event_time (s)
pre_time_2 = -0.015;
post_time_1 = 0.2;     
fs = 20000;             % AD freq.                                                                                                              
Low_pass = 50;
High_pass = 0.1;
order = 6;
timeseries = [];
for i = 1:(pre_time_1 + post_time_1)*fs + 1
timeseries(i) = (i - (pre_time_1*fs + 1))/fs*1000;
end
duration = Combine_DAQ_plx.Event_duration{1,1};

for ch = 1:8
    Channel = sprintf('%s_%d','Channel',ch);
    LFP_segment = [];
    event_time = Combine_DAQ_plx.Event_touch{1,1};
    AD = Combine_DAQ_plx.(Channel).AD{1,1}; 
    [AD_1,AD_2] = LFP_filter(AD,Low_pass,High_pass,order,fs);  
    [segment1,timestamp_AD1] = Segment(AD_2,pre_time_2,post_time_1,event_time,fs);
    LFP_segment = [LFP_segment;segment1];
    LFP_segment_Cal = zeros(1,length(segment1(1,:)));
    for i = 1:length(Combine_DAQ_plx.Event_touch{1,1})
        LFP_segment_Cal(1,:) = LFP_segment_Cal(1,:) + segment1(i,:);
    end
    [segment2,timestamp_AD2] = Segment(AD_2,pre_time_1,post_time_1,event_time,fs);
    Area_Ve.(Channel).Origin = segment2;
    
    LFP_segment_maxvol = max(LFP_segment_Cal(1,:));
    LFP_segment_minvol = min(LFP_segment_Cal(1,:));
    max_position = find(LFP_segment_Cal == LFP_segment_maxvol);
    min_position = find(LFP_segment_Cal == LFP_segment_minvol);
    Area_Ve.(Channel).AD_seg_maxposition = max_position;
    Area_Ve.(Channel).AD_seg_minposition = min_position;
    
    AD_Area = [];
    for trial = 1:length(Combine_DAQ_plx.Event_touch{1,1})
        ad_seg_vol_area = 0;
        ad_get_area = abs(LFP_segment(trial,:));
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
        AD_Area(trial,1) = ad_seg_vol_area;
        
    end
    Ar_Vel.(Channel).Area = AD_Area;
    Ar_Vel.(Channel).Velocity = 1./duration;
    
    figure(1);
    subplot(2,4,ch)
    scatter(Ar_Vel.(Channel).Velocity,AD_Area)
    title(Channel)
    xlabel('1/T')
    ylabel('mV')
    
    figure(2);
    subplot(2,4,ch)
    plot(timeseries(((pre_time_1 - pre_time_2)*fs + 1):(pre_time_1 + post_time_1)*fs + 1),LFP_segment_Cal)
    hold on
    plot((max_position+((0-pre_time_2)*fs))/fs*1000,LFP_segment_maxvol,'ro')
    hold on
    plot((min_position+((0-pre_time_2)*fs))/fs*1000,LFP_segment_minvol,'ro')
    title(Channel)
    xlabel('1/T')
    ylabel('mV')
end

saveas(figure(1),fullfile(Direction,'LFP_Area_to_Velocity_gain1'))
saveas(figure(2),fullfile(Direction,'LFP_TotalArea_to_Velocity_gain1'))
name1 = 'Ar_Vel';
name2 = 'Area_Ve';
save(fullfile(Write,name1),'Ar_Vel','-v7.3');
save(fullfile(Write,name2),'Area_Ve','-v7.3');


   
for tri = 1:length(Combine_DAQ_plx.Event_touch{1,1})
    for ch = 1:8
        Channel = sprintf('%s_%d','Channel',ch);
        max = Area_Ve.(Channel).AD_seg_maxposition;
        min = Area_Ve.(Channel).AD_seg_minposition;
        Trial = sprintf('%s_%d','Trial',8*(i-1)+tri);
        PlotTrial = Area_Ve.(Channel).Origin(8*(i-1)+tri,:);        
        figure(tri);
        subplot(2,4,ch)
        plot(timeseries,PlotTrial)
        hold on
        plot(timeseries(max+((pre_time_1 - pre_time_2)*fs)),PlotTrial(max+((pre_time_1 - pre_time_2)*fs)),'ro')
        hold on
        plot(timeseries(min+((pre_time_1 - pre_time_2)*fs)),PlotTrial(min+((pre_time_1 - pre_time_2)*fs)),'ro')
        title(Channel)
        xlabel('time')
        ylabel('mV')
    end
    name = sprintf('%s_%d','Trial',tri);
    saveas(figure(tri),fullfile(Write,name));
end