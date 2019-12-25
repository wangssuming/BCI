 Date = 'ITMS_1_0911';
 mkdir(fullfile('D:\Seneory_Feedback\ITMS_1\ITMS_redording\Plexon\Phase_1',Date));
 Write =  fullfile('D:\Seneory_Feedback\S1_M1_ICMS_8\S1_redording\Plexon\Phase_1',Date)
 s = daq.createSession('ni'); % 宣告
 s.DurationInSeconds = 1800; % 記錄時間
 addAnalogInputChannel(s,'cDAQ1Mod1',0:1,'Voltage');
 s.Rate = 20000;
 [data,time] = s.startForeground;
 plot(time,data);
 save(fullfile(Write,Date),'data','time','-v7.3');
