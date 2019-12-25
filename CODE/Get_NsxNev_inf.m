Date = '2017_0816';
mkdir(fullfile('D:\Seneory_Feedback\Mapping\Analysis',Date))
Write = fullfile('D:\Seneory_Feedback\Mapping\Analysis',Date);
Read_1 = 'D:\Seneory_Feedback\Mapping\Blackrock\2017_0816\datafile009.ns5';
Read_2 = 'D:\Seneory_Feedback\Mapping\Blackrock\2017_0816\datafile009.nev';
Read_3 = 'D:\Seneory_Feedback\Mapping\Blackrock\2017_0816\datafile009.ns6';
openNSx(Read_1)
openNSx(Read_3)
openNEV(Read_2)
for ch = 2:2:16
    Temp_A = [];
    Temp_time = [];
    for trial = 1:length(NEV.Data.Spikes.Electrode)
        if NEV.Data.Spikes.Electrode(1,trial) == ch
            Temp_A = [Temp_A;double(NEV.Data.Spikes.Waveform(:,trial)')];
            Temp_time = [Temp_time;double(NEV.Data.Spikes.TimeStamp(1,trial))]
        end
    end
    Temp_A = Temp_A';
    Temp_time =  Temp_time';
    Temp_time = [Temp_time;Temp_A];
    Channel = sprintf('Channel_%d',ch);
    Spike_waveform.(Channel) = Temp_time;
    Spike_count = [];
    time_train = 0:1:30;
    for time = 0:30000:900000
        if isempty(Temp_time) ~= 1
            count = length(find(Temp_time(1,:)>=time & Temp_time(1,:)<=time+30000));
            Spike_count = [Spike_count;count];
        else
            Spike_count = zeros(1,length(time_train));
        end
    end
    figure(ch);
    Spike_count = Spike_count';      
    bar(time_train,Spike_count,'FaceColor',[0 .9 .9],'EdgeColor',[0 .5 .5],'LineWidth',1.5)
    title(Channel,'fontsize',20,'fontweight','bold')
    ylabel('Spike (count/time bin)','fontsize',16,'fontweight','bold')
    xlabel('Time (s)')
end