%% function
% fundtion PSTH format-----------------------------------------------------
% clear Waveform;
% clear PSTH;
% clear PSTH_org;
% [PSTH_org,psth,Waveform] = PSTH(ts,waveform,pre_time,post_time,bin,event_time); 
% -------------------------------------------------------------------------
%% Setting 
pre_time = 0.1;           % pre_event_time (s)
post_time = 0.2;
bin = 0.005;        % use 5 ms for plot
%% All channel mean firing rate analysis
%% pre-processing generate:
%   PSTH.(Channel).(Unit).SPK_org{f} = PSTH_SPK;
%   PSTH.(Channel).Multi_unit{f} = Multi_unit;
%   PSTH.ALL_CH_Multi_unit = ALL_CH_Multi_unit;
% -------------------------------------------------------------------------
ALL_Ch_Multi_unit_org = -pre_time:bin:post_time;
for ch = 1:8
    Multi_unit_org = -pre_time:bin:post_time;
    Channel = sprintf('Channel_%d',ch);
    for u = 1:5
        PSTH_SPK_org = -pre_time:bin:post_time;
        PSTH_SPK = -pre_time:bin:post_time;
        Unit = sprintf('Unit_%d',u);
        if isfield(Combine_DAQ_plx.(Channel),Unit)>0
            for f = 1:length(Combine_DAQ_plx.Event_touch)
                ts = Combine_DAQ_plx.(Channel).(Unit).Raster{f,1};
                waveform = Combine_DAQ_plx.(Channel).(Unit).wave{f,1};
                event_time = Combine_DAQ_plx.Event_touch{f,1}
                clear Waveform;
                clear PSTH;
                clear PSTH_org;
                [PSTH_org,psth,Waveform] = PSTH(ts,waveform,pre_time,post_time,bin,event_time);                
                PSTH_SPK_org = [PSTH_SPK_org;PSTH_org];
                PSTH_SPK = [PSTH_SPK;psth];
                Multi_unit_org = [Multi_unit_org;PSTH_org];
                ALL_Ch_Multi_unit_org = [ALL_Ch_Multi_unit_org;PSTH_org];                
            end
            PSTH.(Channel).(Unit).SPK_org = PSTH_SPK_org;
            PSTH.(Channel).(Unit).PSTH_SPK = PSTH_SPK;
%             figure;
%             bar(PSTH_SPK(1,:),sum(PSTH_SPK(2:end,:)));
        end
    end
    PSTH.(Channel).Multi_unit_org{f} = Multi_unit_org;
    figure;
    bar(Multi_unit_org(1,:),sum(Multi_unit_org(2:end,:)));
end
PSTH.ALL_Ch_Multi_unit_org = ALL_Ch_Multi_unit_org;

%% threshold
zeroPoint = find(ALL_Ch_Multi_unit_org(1,:)<0,1,'last');
ALL_Ch_Multi_unit = sum(ALL_Ch_Multi_unit_org(2:end,:));
base_liine_SPK = mean(ALL_Ch_Multi_unit(1:zeroPoint));
std_SPK = std(ALL_Ch_Multi_unit(1:zeroPoint));
output = smoothts(ALL_Ch_Multi_unit);
output = smoothts(ALL_Ch_Multi_unit,'g',0.002,2.*std_SPK);
%% mean firing rate analysis
