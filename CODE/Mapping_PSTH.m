Date = '2017_0816';
mkdir(fullfile('D:\Seneory_Feedback\Mapping\Analysis',Date))
Write = fullfile('D:\Seneory_Feedback\Mapping\Analysis',Date);
Read_1 = 'D:\Seneory_Feedback\Mapping\Blackrock\2017_0816\datafile009.ns5';
Read_2 = 'D:\Seneory_Feedback\Mapping\Blackrock\2017_0816\datafile009.nev';
Read_3 = 'D:\Seneory_Feedback\Mapping\Blackrock\2017_0816\datafile009.ns6';
openNSx(Read_1)
openNSx(Read_3)
openNEV(Read_2)
Event_time = find(diff(NS6.Data)<-4000);
Event_time = [Event_time;double(NS6.Data(find(diff(NS6.Data)<-4000)))]';
delete = find(diff(Event_time(:,1))<5000);
Event_time(delete+1,:) = [];
Delay = calcTimeDelay(NS5,NS6);

for ch = 2:2:16
    Temp_A = [];
    Temp_time = [];
    trial = find(NEV.Data.Spikes.Electrode(1,:) == ch);
    Temp_A = [Temp_A;double(NEV.Data.Spikes.Waveform(:,trial))];
    Temp_time = [Temp_time;double(NEV.Data.Spikes.TimeStamp(1,trial))];
    Temp_time = [Temp_time;Temp_A];
    Channel = sprintf('Channel_%d',ch);
    Spike_waveform.(Channel).waveform = Temp_time;
end

for ch = 2:2:16
    Channel = sprintf('Channel_%d',ch);
    SPK = Spike_waveform.(Channel).waveform(2:end,:);
    time_train = Spike_waveform.(Channel).waveform(1,:);
    Raster = zeros(2,2);
    sum_PSTH = [];
    for trial = 1:length(Event_time)
        Trial = sprintf('Trial_%d',trial);
        ind_1 = find(time_train >= Event_time(trial,1) - (0.5*30000),1,'first');
        ind_2 = find(time_train <= Event_time(trial,1) + (0.5*30000),1,'last');
        Seg_time = time_train(ind_1:ind_2) - time_train(1,ind_1);
        Seg_SPK = SPK(:,ind_1:ind_2);
        Spike_count = [];
        for time = 0:0.005*30000:0.995*30000
            if isempty(Seg_SPK) ~= 1
                count = length(find(Seg_time(1,:)>=time & Seg_time(1,:)<=time+(0.005*30000)));
                Spike_count = [Spike_count;count];
            else
                Spike_count = zeros(1,length(time_train));
            end
        end
        raster = time_train(ind_1:ind_2) - Event_time(trial);
        Raster(trial,1:length(raster)) = raster;
        Spike_waveform.(Channel).(Trial).Waveform = [time_train(ind_1:ind_2);Seg_SPK];
        Spike_waveform.(Channel).(Trial).PSTH = Spike_count;
        sum_PSTH = [sum_PSTH;Spike_count'];
        figure;
        Spike_count = Spike_count';
        Time_Train = -497.5:5:497.5;
        bar(Time_Train,Spike_count,'FaceColor',[0 .9 .9],'EdgeColor',[0 .5 .5],'LineWidth',1.5)
        title([Channel Trial],'fontsize',20,'fontweight','bold')
        ylabel('Spike (count/time bin)','fontsize',16,'fontweight','bold')
        xlabel('Time (s)')
    end
    Time_Train = -497.5:5:497.5;
    Spike_waveform.(Channel).sum_PSTH = sum_PSTH;
    Spike_waveform.(Channel).Raster = Raster;
    figure;
    subplot(2,1,1)
    bar(Time_Train,sum(sum_PSTH)','FaceColor',[0 .9 .9],'EdgeColor',[0 .5 .5],'LineWidth',1.5)
    title(['Spike count' Channel],'fontsize',20,'fontweight','bold')
    ylabel('Spike (count/time bin)','fontsize',16,'fontweight','bold')
    xlabel('Time (s)')
    subplot(2,1,2)
    for i = 1:size(Raster,1)
        title(['Raster' Channel],'fontsize',20,'fontweight','bold')
        line([Raster(i,:)'./30000 Raster(i,:)'/30000],[0+i 1+i],'Color','k')
        hold on
        xlim([-0.5 0.5])
    end
end