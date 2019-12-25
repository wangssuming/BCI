clear all;
close all;
Date = '2017_0621';
Read = fullfile('C:\Users\ASUS\Desktop\S1_M1_ICMS_4\Combine_plx',Date);
mkdir(fullfile('C:\Users\ASUS\Desktop\S1_M1_ICMS_4\SumTrial_Velocity',Date));
Write = fullfile('C:\Users\ASUS\Desktop\S1_M1_ICMS_4\SumTrial_Velocity',Date); 
Direction = 'C:\Users\ASUS\Desktop\S1_M1_ICMS_4\SumTrial_Velocity\2017_0621';
File = dir([Read '\*5ms.mat']);
load([Read '\' File.name]);
%% Set filter parameter 
fs = 20000;
freq1 = 50*2/fs;
freq2 = 0.1*2/fs;
N1 = 3;
N2 = 3;
%% Get touch timesynchronized by Event002
synchronize_t_touch = Combine_DAQ_plx.Event_touch{1,1};
duration = Combine_DAQ_plx.Event_duration{1,1}; % duration to velocity

figure(1);
for ch = 1:8    
    Channel = sprintf('%s_%d','Channel',ch);
    ad = Combine_DAQ_plx.(Channel).AD{1,1}; %get LFP
    ad = ad';    
    
    % filter
    [a1,b1] = butter(N1,freq1,'low'); %lowpass filtering
    ad_low = filtfilt(a1,b1,ad);
    [a2,b2] = butter(N2,freq2,'high'); %highpass filtering
    ad_high = filtfilt(a2,b2,ad_low);
%     ad_high = ad_high*gain;  % gain
    
       %% Calculate each trial
    for i = 1:length(synchronize_t_touch) 
        Trial = sprintf('%s_%d','Trial',i);
        for x = 1:5
            ad_scale = zeros(6000/(x*5),1);           
            ff = 0;           
            for f = round(synchronize_t_touch(i)*fs) - 1999:x*5:round(synchronize_t_touch(i)*fs) + 4000 - 5 
                ff = ff + 1;
                ad_scale(ff) = ad_scale(ff) + sum(ad_high(f:f + (x*5))) / (x*5);
            end
        Scale = sprintf('%s_%d','Scale',x*5);
        Multi_Entropy.Origin.(Channel).(Trial).(Scale) = ad_scale;
        end
    end
    
       %% Get diff
    for f = 1:5
        Scale = sprintf('%s_%d','Scale',x*5);
             %% Get diff 
        ad_diff_ref = Multi_Entropy.Origin.(Channel).Trial_1.(Scale);
        for i = 2:length(synchronize_t_touch)
            Trial = sprintf('%s_%d','Trial',i-1);          
            Multi_Entropy.Diff.(Channel).(Trial).(Scale) = Multi_Entropy.Origin.(Channel).(Trial).(Scale){1,1} - ad_diff_ref;
        end
             %% Get EP
        ad_ep_ref = Multi_Entropy.Diff.(Channel).Trial_1.(Scale);
        for i = 2:length(synchronize_t_touch)-1 
            Trial = sprintf('%s_%d','Trial',i-1); 
            Multi_Entropy.EP.(Channel).(Trial).(Scale) =  ad_ep_ref ./ Multi_Entropy.Diff.(Channel).(Trial).(Scale){1,1};
        end
             %% Get SEM & Minumun entropy first position 
        ad_ep_ref = Multi_Entropy.Diff.(Channel).Trial_1.(Scale);
        EP_err = zeros(6000/(f*5),length(synchronize_t_touch)-2);
        for i = 2:length(synchronize_t_touch)-1
            Trial = sprintf('%s_%d','Trial',i-1); 
            for x = 1:6000/(f*5)
                ep_error = Multi_Entropy.EP.(Channel).(Trial).(Scale){1,1};
                EP_err(x,i-1) = EP_err(x,i-1) + ep_error(x,1);
            end
        end
        Multi_Entropy.(Channel).(Scale).EP_error = EP_err;
        ep_cal_sem = zeros(6000/(f*5),1);
        for i = 1:6000/(f*5)
            ep_cal_sem(i) = ep_cal_sem(i) + std(EP_err(i,1:end))/sqrt(length(EP_err(i,1:end)));
        end
        Minimun_Entropy = f*find(min(ep_cal_sem));
        Multi_Entropy.(Channel).(Scale).EP_SEM = ep_cal_sem; 
        Multi_Entropy.(Channel).(Scale).Min_Entropy = Minimun_Entropy;
        
    end
end