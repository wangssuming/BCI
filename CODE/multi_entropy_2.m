for ch = 1:8
    Channel = sprintf('Channel_%d',ch);
    for f = 2:length(Neural_analysis.(Channel).LFP_segment(:,1))
        N = Neural_analysis.(Channel).LFP_segment(f,:);
        trial = sprintf('trial_%d',f);    
        scale=20;
        x_time = 1:scale:length(N);
        D.(trial).(Channel) = [];
    for j = 2:(length(N)/scale-1)
        mean_jx_1 = mean(N(x_time(j-1):x_time(j)));
        max_jx_1 = max(N(x_time(j-1):x_time(j))-mean_jx_1);
        D.(trial).(Channel) = [D.(trial).(Channel); max_jx_1];
    end
    end
    for k=2:length(Neural_analysis.(Channel).LFP_segment(:,1))
        trial = sprintf('trial_%d',k);
        k = sprintf('k_%d',k);
        E.(k).(Channel)=[];
        [ref]=D.trial_2.(Channel);
        E.(k).(Channel)=[E.(k).(Channel);log(ref./D.(trial).(Channel))];
%         E_mean_25.(k).(Channel)=[];
%         E_mean_25.(k).(Channel)=[E_mean_25.(k).(Channel);mean(E.(k).(Channel))];
    end
end
% A=[];
% for k=2:length(Neural_Signal_analysis_DAQ.Neural_analysis.(Channel).LFP_segment(:,1))
%         trial = sprintf('trial_%d',k);
%         k = sprintf('k_%d',k);
% for ch = 1:8
%     Channel = sprintf('Channel_%d',ch);
% A = [A;s_mean_5.(k).(Channel) s_mean_10.(k).(Channel) s_mean_15.(k).(Channel) s_mean_20.(k).(Channel) s_mean_25.(k).(Channel)];
% %save mean_25 s_mean_25;
% end
% end
% A=[scale;A];
% scale=[5 10 15 20 25];
% scatter(A(1,:),A(10,:));
% 
for ch=1:8
    Channel = sprintf('Channel_%d',ch);
    SaveArray = [];
    for trial = 1:length(Neural_analysis.(Channel).LFP_segment(:,1))-1
        Trial = sprintf('k_%d',trial+1);
        SaveArray(trial,:) = E.(Trial).(Channel);
    end
    Entropy_Array.(Channel) = SaveArray;
end

for ch=1:8
    Channel = sprintf('Channel_%d',ch);
    SE.(Channel)=[];
    SE.(Channel)=std(Entropy_Array.(Channel))./sqrt(length(Entropy_Array.(Channel)(:,1)));
end
time=Neural_analysis.(Channel).LFP_segment(1,:);
 for x = 1:(length(x_time)-3)
        time_sacle(x) = time(x_time(x));
 end
time_scale=num2cell(time_sacle)
 
 for ch=1:8
    Channel = sprintf('Channel_%d',ch);   
    figure(ch);
    boxplot(Entropy_Array.(Channel)(:,41:101),time_scale(41:101));
    title('entropy scale 20')  
    %saveas(ch,sprintf('Channel_%d',ch))
end
