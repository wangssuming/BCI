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
Date = 'S1_M1_ICMS_04_0621'
Read = 'C:\Users\ASUS\Desktop\2017_0621';
mkdir(fullfile('C:\Users\ASUS\Desktop\2017_0621',Date));
Write = fullfile('C:\Users\ASUS\Desktop\2017_0621',Date);
files_plx = dir(fullfile(Read,'\*.plx'));
files_mat = dir(fullfile(Read,'\*.mat'));
bin = 0.001;            % 5 ms
Position = [];
Event = [];
%% load the DAQ data ======================================================
load(fullfile(Read,files_mat.name))

Val_ttl = data(:,2);
Val_touch = data(:,1);
baseline_ttl = mean(Val_ttl);
baseline_touch = mean(Val_touch(round(rand(1000,1)*1000),:));
STD_ttl = std(Val_ttl);
STD_touch = std(Val_touch);
ttl = find(diff(Val_ttl)>baseline_ttl+3.*STD_ttl);      % find the continuous pressing TTL  
                                                        % baseline_ttl+3.*STD_ttl howto get this parameter
delete = find(diff(ttl)<45000);      % delete pressing interval less than 4.5s
ttl(delete+1) = [];
touch = find(abs(diff(Val_touch)) >= 0.03);     % why 0.03
% delete = find(diff(touch)<45000);
% touch(delete+1) = [];
t = 1;
while(length(ttl)~=length(touch))
    if t > length(ttl)    % if t>length(ttl)???
        touch(t:end) = [];
    elseif (abs(ttl(t)-touch(t))>10000)
        touch(t) = [];    
    else
        t = t+1
    end
end
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
    [~, ts, sv] = plx_event_ts(filename, 257);       % ensure what are ts, sv, nCoords  % event ts
    [nCoords, nDim, nVTMode, c] = plx_vt_interpret(ts, sv);  % ensure nDim, nVTMode, c
    c(:,1) = c(:,1)-c(1,1);                         % correct time
    c(find(c(:,1)<0),:) = [];
    %% neural proccess
    for ch = 1:16                                % channel 1:16
        Channel = sprintf('%s_%d','Channel',ch)
        [~, AD_n, ~, ~, ~] = plx_ad_v(filename, ch-1); % read LFP amplitude  % why ch-1???
        if(AD_n>0)   % what is AD_n
            [ADfreq, ~, AD_ts, ADfn, ad] = plx_ad_v(filename, ch-1);
            for u = 1:6                
                Unit = sprintf('%s_%d','Unit',u-1);   % why u-1??? u=0 is unsorted unit???
                [n, ts] = plx_ts(filename,ch,u-1);      % read spike timestemp  % ts: spike ts         
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
    [n, Event002, sv] = plx_event_ts(filename, 2);   % why 2???
    Event_touch = [];        
    if (End+1)<=size(ttl,1)
        delta_time = Event002(2)-time(ttl(End+1))+300*(f-1);        % find the shift time
        T = duration_ttl(:,2)-300*(f-1)+delta_time;     % ttl synchronize with event002
        % understand the relationship between val_touch, val_ttl, and Event002
        for i = 1:length(duration_ttl)
            I = find(T<=Event002(i+1),1,'last');
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
            line([(Event_touch(:,3)-duration_ttl(End+1:I,1)) (Event_touch(:,3)-duration_ttl(End+1:I,1))],[12 17],'Color','b')
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
name = sprintf('%s_%dms',Date,bin*1000);
save(fullfile(Write,name),'Combine_DAQ_plx','-v7.3');
