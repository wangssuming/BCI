%% combin_DAQ_plx.m =======================================================
% Editor: Peggy
% Date: 2017/04/30
%% Combine_DAQ_plx.mat ====================================================
% Channel
%   a. Unit
%       - wave 
%       - Raster
%   b. AD
% Event_ttl
% Event_touch
% Event_duration
% Position
% Note: cell content: {file.plx,1}
%% ========================================================================
clear all;
close all;
Date = '2017_0622'
Read = fullfile('D:\Seneory_Feedback\S1_M1_ICMS_4\S1_redording\Plexon\Phase_1',Date);
mkdir(fullfile('D:\Seneory_Feedback\S1_M1_ICMS_4\S1_recording\combin_DAQ_plx',Date));
Write = fullfile('D:\Seneory_Feedback\S1_M1_ICMS_4\S1_recording\combin_DAQ_plx',Date);
files_plx = dir(fullfile(Read,'\*.plx'));
files_mat = dir(fullfile(Read,'\*.mat'));
Position = [];
Event = [];
%% load the DAQ data ======================================================
load(fullfile(Read,files_mat.name))

Val_ttl = data(:,2);
Val_touch = data(:,1);
baseline_ttl = mean(Val_ttl);
% baseline_touch = mean(Val_touch(round(rand(1000,1)*1000),:)); % why random?
STD_ttl = std(Val_ttl);
STD_touch = std(Val_touch);
ttl = find(diff(Val_ttl)>baseline_ttl+3.*STD_ttl);      % find the continuous pressing TTL
delete = find(diff(ttl)<45000);      % delete pressing interval less than 4.5s
ttl(delete+1) = [];

for i = 1:length(ttl)
    Val_touch_1 = Val_touch(ttl(i)-3500:ttl(i));
    Touch(i,1) = ttl(i) - 3500 + find(Val_touch_1 == max(Val_touch_1),1,'last');    
end

for i = 1:length(ttl)
    Val_touch_1 = Val_touch(ttl(i)-4000:ttl(i));
    if length(find(Val_touch_1 == min(Val_touch_1)))<4001 & find(Val_touch_1 == min(Val_touch_1)) >= 1000 
        Min_touch_locs = find(Val_touch_1 == min(Val_touch_1));
        Touch(i,1) = ttl(i) - 4000 + find(max(Val_touch_1(Min_touch_locs-1000:Min_touch_locs))); 
    elseif Min_touch_locs < 1000
        s
        Touch(i,1) = ttl(i) - 4000 + find(max(Val_touch_1(1:Min_touch_locs))); 
    else
        Touch(i,1) = 0;
    end
end

% [Touch_pks,Touch_locs] = findpeaks(-1.*Val_touch);
% Touch_pks = -1.*Touch_pks;
% 
% touch(1,1) = Touch_locs(find(find(Touch_pks == min(Touch_pks(find(Touch_locs(:,1)<ttl(1,1)))))<ttl(1,1),1,'last'),1);
% for t = 2:length(ttl(:,1))
%     touch(t,1) = Touch_locs(find(find(Touch_pks == min(Touch_pks(find(Touch_locs(:,1)<ttl(t,1) & Touch_locs(:,1)>ttl(t,1)-45000))))<ttl(t,1),1,'last'),1);
% % touch(t,1) = Touch_locs(find(min(Touch_pks(find(Touch_locs(:,1)<ttl(t,1) & Touch_locs(:,1)>ttl(t-1,1)),1))),1);
% end

figure;
plot(data(:,1));
hold on
plot_data = [];

for i = 1:length(ttl)
    if Touch(i) ~= 0
       plot_data(i,1) = Val_touch(Touch(i),1);
    else
        plot_data(i,1) = 0;
    end
end
scatter(Touch,plot_data)
% Data = [];
% for i = 1:length(Touch_locs_3)
%     Data(i,1) = data(Touch_locs_4(i,1),1);
%     plot(Touch_locs_3(i),touch_pks_3(i),'dr','MarkerFaceColor','r');
%     hold on
% end
% hold on
% 
% 
% figure;
% plot(data(:,1));
% hold on
% Data = [];
% for i = 1:length(touch)
%     Data(i,1) = data(touch(i,1),1);
%     plot(touch(i),Data(i),'dr','MarkerFaceColor','r');
%     hold on
% end
hold on
plot(data(:,2));
hold on
line([ttl(:,1) ttl(:,1)],[-2 0],'Color','g')
hold on
Event002_1 = Event002.*10000;
line([Event002_1(:,1) Event002_1(:,1)],[10.5 12],'Color','g')
hold on

close all
% delete = find(diff(touch)<45000);
% touch(delete+1) = [];
% t = 1;
% while(length(ttl)~=length(touch))       % find the touch timepoint before each ttl
%     if t > length(ttl)      % if we find the last touch timepoint, we delete the rest timestamps 
%         touch(t:end) = [];
%     elseif (ttl(t)-touch(t)>20000)     % delete the time when its timestamp was more than 2s
%         touch(t) = [];    
%     else        % reserve the timestamp that we define as touching timepoint
%         t = t+1
%     end
% end

% for i = 1:length(ttl)
%     Data_1(i,1) = data(ttl(i,1),1);
%     plot(ttl(i),Data(i),'dr','MarkerFaceColor','b');
%     hold on
% end

Combine_DAQ_plx.DAQ.Val_ttl = Val_ttl;
Combine_DAQ_plx.DAQ.Val_touch = Val_touch;
Combine_DAQ_plx.DAQ.ttl = ttl;
Combine_DAQ_plx.DAQ.touch = touch;
Combine_DAQ_plx.DAQ.time = time;
duration_ttl = [time(ttl)-time(touch) time(ttl)];
%% ------------------------------------------------------------------------
End = 0;
for f = 1:size(files_plx,1)
    filename = fullfile(Read,files_plx(f).name);  
    [~, ts, sv] = plx_event_ts(filename, 257);
    [nCoords, nDim, nVTMode, c] = plx_vt_interpret(ts, sv);
    c(:,1) = c(:,1)-c(1,1);                         % correct time
    c(find(c(:,1)<0),:) = [];
    %% neural proccess
    for ch = 1:8                                % channel 1:16
        Channel = sprintf('%s_%d','Channel',ch)
        [~, AD_n, ~, ~, ~] = plx_ad_v(filename, ch-1); % read LFP amplitude
        if(AD_n>0)
            [ADfreq, ~, AD_ts, ADfn, ad] = plx_ad_v(filename, ch-1);
            for u = 1:6                
                Unit = sprintf('%s_%d','Unit',u-1);
                [n, ts] = plx_ts(filename,ch,u-1);      % read spike timestemp           
                if(n>0)
                    [n, npw, ts, wave] = plx_waves_v(filename, ch, u-1);
                    Combine_DAQ_plx.(Channel).(Unit).wave{f,1}= wave;
                    Combine_DAQ_plx.(Channel).(Unit).Raster{f,1}= ts;
                end
            end        
        Combine_DAQ_plx.(Channel).AD{f,1} = ad';
        end
    end
    %% Event proccess
    [n, Event002, sv] = plx_event_ts(filename, 2);
    Event_touch = [];        
    if (End+1)<=size(ttl,1)
        delta_time = Event002(1)-time(ttl(1))+300*(f-1);        % find the shift time
        T = duration_ttl(:,2)-300*(f-1)+delta_time;     % ttl synchronize with event002
        
        for i = 1:length(Event002)
            I = find(T<=Event002(i),1,'last');
            Event_touch = [Event_touch;duration_ttl(I,1) T(I) Event002(i)];     % [duration synchronized_ttl Plexon_ttl]
            Event_touch(find(diff(Event_touch(:,2))==0)+1,:)=[];
            Event_touch(find(Event_touch(:,2)<0),:)=[];
        end
        if isempty(Event_touch)<1
            h(1) = figure;
            line([T T],[0 5],'Color','g')
            hold on;
            line([Event_touch(:,3) Event_touch(:,3)],[6 11],'Color','r')
            hold on;
            line([(Event_touch(:,3)-duration_ttl(1:I,1)) (Event_touch(:,3)-duration_ttl(1:I,1))],[12 17],'Color','b')
            legend('Plexon TTL','DAQ TTL','DAQ touch')
            saveas(h(1),fullfile(Write,files_plx(f).name(1:end-4)));
            saveas(h(1),fullfile(Write,[files_plx(f).name(1:end-4) '.tif']));
        end
        End = I;        % the last point in the .plx file

        Combine_DAQ_plx.Event_ttl{f,1} = Event_touch(:,3);
        Combine_DAQ_plx.Event_touch{f,1} = Event_touch(:,3)-Event_touch(:,1);       % calculate the touch time point in plexon system
        Combine_DAQ_plx.Event_duration{f,1} = Event_touch(:,1);
        Combine_DAQ_plx.Position{f,1} = c;
    end
end
name = sprintf('%s_%dms',Date);
save(fullfile(Write,name),'Combine_DAQ_plx','-v7.3');
