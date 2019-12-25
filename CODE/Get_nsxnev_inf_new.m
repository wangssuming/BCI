Date = '2017_0802';
mkdir(fullfile('D:\Seneory_Feedback\Mapping\Analysis',Date))
Write = fullfile('D:\Seneory_Feedback\Mapping\Analysis',Date);
Read_1 = 'D:\Seneory_Feedback\Mapping\Blackrock\2017_0802\datafile006.ns5';
Read_2 = 'D:\Seneory_Feedback\Mapping\Blackrock\2017_0802\datafile006.nev';
Read_3 = 'D:\Seneory_Feedback\Mapping\Blackrock\2017_0802\datafile006.ns6';
openNSx(Read_1)
openNSx(Read_3)
openNEV(Read_2)
resample = 30;
fs = 30000;

for ch = 1:1:8
    Temp_A = [];
    Temp_time = [];
    trial = find(NEV.Data.Spikes.Electrode(1,:) == ch);
    Temp_A = [Temp_A;double(NEV.Data.Spikes.Waveform(:,trial))'];
    Temp_time = [Temp_time;double(NEV.Data.Spikes.TimeStamp(1,trial))'];
    Temp_time = [Temp_time;Temp_A];
    Channel = sprintf('Channel_%d',ch);
    Spike_waveform.(Channel).waveform = Temp_time;
end

for ch = 2:2:16
    Channel = sprintf('Channel_%d',ch);
    SPK = Spike_waveform.(Channel).waveform;
    Spike_count = [];
    time_train = 0:1:29;
    for time = 0:fs:29*fs
        if isempty(SPK) ~= 1
            count = length(find(SPK(1,:)>=time & SPK(1,:)<=time+fs));
            Spike_count = [Spike_count;count];
        else
            Spike_count = zeros(1,length(time_train));
        end
    end
    Spike_waveform.(Channel).Spike_count = Spike_count;
    figure(ch);
    Spike_count = Spike_count';      
    bar(time_train,Spike_count,'FaceColor',[0 .9 .9],'EdgeColor',[0 .5 .5],'LineWidth',1.5)
    title(Channel,'fontsize',20,'fontweight','bold')
    ylabel('Spike (count/time bin)','fontsize',16,'fontweight','bold')
    xlabel('Time (s)')
end

figure;
plot(NEV.Data.Spikes.Waveform(:,1:end));
