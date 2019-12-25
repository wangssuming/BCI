clear all
close all
Date = '2017_0802';
file = 'datafile005';
mkdir(fullfile('D:\Seneory_Feedback\Mapping\Analysis',Date,'\',file))
Write = fullfile('D:\Seneory_Feedback\Mapping\Analysis',Date,'\',file);
Read_1 = ['D:\Seneory_Feedback\Mapping\Blackrock\' Date '\' file '.ns5'];
Read_2 = ['D:\Seneory_Feedback\Mapping\Blackrock\' Date '\' file '.nev'];
Read_3 = ['D:\Seneory_Feedback\Mapping\Blackrock\' Date '\' file '.ns6'];
openNSx(Read_1)
openNSx(Read_3)
openNEV(Read_2)
resample = 30;
fs = 30000;

for ch = 1:1:8
    Temp_A = [];
    Temp_time = [];
    trial = find(NEV.Data.Spikes.Electrode(1,:) == ch);
    Temp_A = [Temp_A;double(NEV.Data.Spikes.Waveform(:,trial))];
    Temp_time = [Temp_time;double(NEV.Data.Spikes.TimeStamp(1,trial))];
    Temp_time = [Temp_time;Temp_A];
    Channel = sprintf('Channel_%d',ch);
    Spike_waveform.(Channel).waveform = Temp_time;
end

for ch = 1:1:8
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
    saveas(figure(ch),fullfile(Write,['SPK_' Channel]))
end

for ch = 1:1:8
    Channel = sprintf('Channel_%d',ch);
    if sum(Spike_waveform.(Channel).Spike_count) > 15
        count = 0;
        Sti = [];
        rand_time = 10*fs+1:20*fs;
        for i = 1:resample        
            r = randi([1 length(rand_time)-fs],1,1);
            start = rand_time(1,r);
            count = length(find(SPK(1,:)>=start & SPK(1,:)<=start+fs));
            Sti = [Sti;count];
        end
        Spike_waveform.(Channel).Rand_StiSpike_count = Sti;
        
        count = 0;
        Con = [];
        rand_time = [1:10*fs-fs;20*fs+1:30*fs-fs];
        for i = 1:resample        
            r = randi([1 length(rand_time)],1,1);
            start = rand_time(1,r);
            count = length(find(SPK(1,:)>=start & SPK(1,:)<=start+fs));
            Con = [Con;count];
        end
        Spike_waveform.(Channel).Rand_ConSpike_count = Con;

%         diff = Sti - Con;
%         SD = sqrt(sum((diff - mean(diff)).^2)/(resample-1));
%         t = mean(diff)/(SD/sqrt(resample));
        [h,p] = ttest(Sti,Con);
        Spike_waveform.ttest_h(ch,1) = h;
        Spike_waveform.ttest_p(ch,1) = p;
        clear h p
        figure(ch+8);
        boxplot([Con(:,1),Sti(:,1)],'Labels',{'Control','Stimulate'});
        title(Channel)
        saveas(figure(ch+8),fullfile(Write,['Ttest_' Channel]))
    else
        Spike_waveform.ttest_h(ch,1) = -1;
        Spike_waveform.ttest_p(ch,1) = -1;
    end
    
end
save(fullfile(Write,'Mapping_analysis'),'Spike_waveform');
% Sti = Spike_waveform.sum_stimulate;
% Con = Spike_waveform.sum_control;
% n = length(find(Sti ~= 0));
% diff = Sti - Con;
% SD = sum((diff - mean(diff)).^2)/(n-1);
% t = mean(diff)/(SD/sqrt(n));

