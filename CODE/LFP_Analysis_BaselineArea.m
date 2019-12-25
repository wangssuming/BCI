%% Pressing_Lever_analysis.m ==================================================
% Editor: Peggy Chuang
% Date: 2017/05/05
% Description: plot the data from  SSEP_analysis_DAQ.mat and analysis the
%       result
%% Iutput data content (Neural_Signal_analysis_DAQ.mat)--------------------
% Duration 
% Neural_analysis 
%   Channel
%       a. Unit
%           - PSTH_org
%           - Waveform 
%       b. Multiunit
%       c. LFP_segment
%       d. AD_60Hz_notch
%       e. AD_bandpass
% Dynamic
%   a. Energy
%   b. Forelimb_VelocityX
%   c. Forelimb_VelocityY
%   d. Forelimb_Velocity
%% Output data content (SSEP_analysis_DAQ.mat)
% Channel
%   a. LFP_analysis
%       - Max_peak_SSEP
%       - Min_peak_SSEP
%       - magnitude_SSEP
%       - loc_SSEP
%       - Max_width_SSEP
%       - Min_width_SSEP
%       - SSEP              -- selected SSEP trial
%       ==Peak to Valley==
%       - Area_PV
%       - Square_PV
%       - Dev_PV
%       ==Baseline==
%       - Area_BL
%       - Square_BL
%       - Dev_BL
%   b. SPK_analysis
%       - Multi_Unit        -- the multi-unit of response period 
%       - BL_val
%       - RP_val
%       - BL_RP_ttest
%   c. Energey
%   d. Forelimb_VelocityX
%   e. Forelimb_VelocityY
%   f. Forelimb_Velocity
%   g. Duration
%% ========================================================================
clear all;
close all;
LFP = 0;        % 1: unfiltered LFP; else: filtered LFP
fs = 20000;
start_time_1 = 0.5;   % detect start time
start_time_2 = 0.015;
end_time_1 = 0.1;
end_time_2 = 0.2;   % detect end time
end_time_3 = 0.5;
x_duration = start_time_1:1/fs:end_time_3;
% for i = 1:(start_time_1 + end_time_3)*fs + 1
% timeseries(i) = (i - (start_time_1*fs + 1))/fs*1000;
% end
bin = 0.001;
%% ------------------------------------------------------------------------
Date = '2017_0620';
Read = fullfile('C:\Users\ASUS\Desktop\Seneory_Feedback\S1_M1_ICMS_04\Pressing_Lever_preprocessing',Date);
mkdir(fullfile('C:\Users\ASUS\Desktop\Seneory_Feedback\S1_M1_ICMS_04\Pressing_Lever_analysis',Date));
Write = fullfile('C:\Users\ASUS\Desktop\Seneory_Feedback\S1_M1_ICMS_04\Pressing_Lever_analysis',Date);
file = dir([Read '\*' num2str(bin*1000) 'ms.mat']);
load([Read '\' file.name]);
SSEP_analysis_DAQ.Energy = [];
SSEP_analysis_DAQ.Forelimb_VelocityX = [];
SSEP_analysis_DAQ.Forelimb_VelocityY = [];
SSEP_analysis_DAQ.Forelimb_Velocity = [];
SSEP_analysis_DAQ.Duration = [];
response_start = [];
response_end = [];
SPK_ttest = [];
for ch = 1:8
    Channel = sprintf('Channel_%d',ch);
    SSEP_analysis_DAQ.(Channel).LFP_analysis.Max_peak_SSEP = [];
    SSEP_analysis_DAQ.(Channel).LFP_analysis.Min_peak_SSEP = [];
    SSEP_analysis_DAQ.(Channel).LFP_analysis.magnitude_SSEP = [];
    SSEP_analysis_DAQ.(Channel).LFP_analysis.loc_SSEP = [];
    SSEP_analysis_DAQ.(Channel).LFP_analysis.Max_width_SSEP = []; 
    SSEP_analysis_DAQ.(Channel).LFP_analysis.Min_width_SSEP = [];
    SSEP_analysis_DAQ.(Channel).LFP_analysis.SSEP = [];    
    Time_1.(Channel) = [];
    Time_2.(Channel) = [];
end

%% SPK find response period
for ch = 1:8
    Channel = sprintf('Channel_%d',ch);
    psth = sum(Neural_Signal_analysis_DAQ.Neural_analysis.(Channel).Multiunit(2:end,:));    
    time_train = Neural_Signal_analysis_DAQ.Neural_analysis.(Channel).Multiunit(1,:); 
    %% plot ---------------------------------------------------------------
%     figure;
%     bar(time_train,psth)
    %% --------------------------------------------------------------------
    ind_s = find(time_train >= start_time_1,1,'first');
    ind_e = find(time_train >= end_time_2,1,'first');
    zero = find(time_train == 0);
    baseline = mean(psth(1:zero));   
    STD = std(psth(1:zero))./sqrt(length(1:zero));
    t1 = find(psth(ind_s:ind_e) >= (baseline+3*STD),1,'first');
    t2 = find(psth(ind_s:ind_e) >= (baseline+3*STD),1,'last');
    response_start = [response_start; t1 time_train(ind_s+t1-1)];
    response_end = [response_end; t2 time_train(ind_s+t2-1)];
    SSEP_analysis_DAQ.(Channel).SPK_analysis.Multi_Unit = Neural_Signal_analysis_DAQ.Neural_analysis.(Channel).Multiunit(1,t1:t2);
    baseline_val = Neural_Signal_analysis_DAQ.Neural_analysis.(Channel).Multiunit(2:end,1:zero);
    baseline_std = std(baseline_val');
    baseline_mean = mean(baseline_val,2);
    response_val = Neural_Signal_analysis_DAQ.Neural_analysis.(Channel).Multiunit(2:end,t1:t2);
    response_mean = mean(response_val,2);
    [h,p] = ttest(baseline_mean,response_mean);
    SPK_ttest = [SPK_ttest;p];
    SSEP_analysis_DAQ.(Channel).SPK_analysis.BL_val = baseline_val;
    SSEP_analysis_DAQ.(Channel).SPK_analysis.RP_val = response_val;
    SSEP_analysis_DAQ.(Channel).SPK_analysis.BL_RP_ttest = SPK_ttest;
end
S = Neural_Signal_analysis_DAQ.Dynamic.Forelimb_VelocityY;
std_VelocityY = std(S);
Trial = size(Neural_Signal_analysis_DAQ.Dynamic.Forelimb_VelocityY,1);

       
        %% SSEP analysis V.S. forlimbic dynamic
for trial = 1:Trial         
    if Neural_Signal_analysis_DAQ.Dynamic.Forelimb_VelocityY(trial) < 0 && abs(Neural_Signal_analysis_DAQ.Dynamic.Forelimb_VelocityY(trial))<3*std_VelocityY    
            SSEP_analysis_DAQ.Energy = [SSEP_analysis_DAQ.Energy; Neural_Signal_analysis_DAQ.Dynamic.Energy(trial)];
            SSEP_analysis_DAQ.Duration = [SSEP_analysis_DAQ.Duration; Neural_Signal_analysis_DAQ.Duration(trial)];
            SSEP_analysis_DAQ.Forelimb_VelocityX = [SSEP_analysis_DAQ.Forelimb_VelocityX; Neural_Signal_analysis_DAQ.Dynamic.Forelimb_VelocityX(trial)];
            SSEP_analysis_DAQ.Forelimb_VelocityY = [SSEP_analysis_DAQ.Forelimb_VelocityY; Neural_Signal_analysis_DAQ.Dynamic.Forelimb_VelocityY(trial)];
            SSEP_analysis_DAQ.Forelimb_Velocity = [SSEP_analysis_DAQ.Forelimb_Velocity; Neural_Signal_analysis_DAQ.Dynamic.Forelimb_Velocity(trial)];
        for ch = 1:8
            Channel = sprintf('Channel_%d',ch);
            if LFP == 1
                SSEP = Neural_Signal_analysis_DAQ.Neural_analysis.(Channel).LFP_segment(2:end,:);                
                x_ad = Neural_Signal_analysis_DAQ.Neural_analysis.(Channel).LFP_segment(1,:);
                figure;
                plot(x_ad,SSEP)
            else
                SSEP = Neural_Signal_analysis_DAQ.Neural_analysis.(Channel).LFP_segment(trial+1,:);  
                x_ad = Neural_Signal_analysis_DAQ.Neural_analysis.(Channel).LFP_segment(1,:);
            end
            Start = find(x_ad<start_time_1,1,'last');          % analysis from 15 ms to 50 ms
            End = find(x_ad<end_time_2,1,'last');       
%             find peak and valley
            Maxpks = [];
            Minpks = [];            
            [Maxpks,Maxlocs,MaxW,MaxP] = findpeaks(SSEP(Start:End),x_ad(Start:End),...      % find peak
                'SortStr','descend');
            [Minpks,Minlocs,MinW,MinP] = findpeaks(-SSEP(Start:End),x_ad(Start:End),...     % find valley
                'SortStr','descend');
            % save result
            SSEP_analysis_DAQ.(Channel).LFP_analysis.Max_peak_SSEP = [SSEP_analysis_DAQ.(Channel).LFP_analysis.Max_peak_SSEP; Maxpks(1)];
            SSEP_analysis_DAQ.(Channel).LFP_analysis.Min_peak_SSEP = [SSEP_analysis_DAQ.(Channel).LFP_analysis.Min_peak_SSEP; -Minpks(1)];
            SSEP_analysis_DAQ.(Channel).LFP_analysis.magnitude_SSEP = [SSEP_analysis_DAQ.(Channel).LFP_analysis.magnitude_SSEP; Maxpks(1)+Minpks(1)];
            SSEP_analysis_DAQ.(Channel).LFP_analysis.loc_SSEP = [SSEP_analysis_DAQ.(Channel).LFP_analysis.loc_SSEP;Maxlocs(1) Minlocs(1)];
            SSEP_analysis_DAQ.(Channel).LFP_analysis.Max_width_SSEP = [SSEP_analysis_DAQ.(Channel).LFP_analysis.Max_width_SSEP; MaxW(1)]; 
            SSEP_analysis_DAQ.(Channel).LFP_analysis.Min_width_SSEP = [SSEP_analysis_DAQ.(Channel).LFP_analysis.Min_width_SSEP; MinW(1)];
            SSEP_analysis_DAQ.(Channel).LFP_analysis.SSEP = [SSEP_analysis_DAQ.(Channel).LFP_analysis.SSEP;SSEP];
%             find baseline
            End_B = find(x_ad==0);      % find the timepoint of event and calculate the mean value before stimulation
            baseline = mean(SSEP(1:End_B));
            t1 = x_duration(find(SSEP(Start:End)>=baseline,1,'first'))
            trial
            t2 = x_duration(find(SSEP(Start:End)>=baseline,1,'last'));
            if isempty(t1)>0
                baseline = 0;
                t1 = x_duration(find(SSEP(Start:End)>=baseline,1,'first'))
                trial
                t2 = x_duration(find(SSEP(Start:End)>=baseline,1,'last'));
            end
            Time_1.(Channel) = [Time_1.(Channel);t1];
            Time_2.(Channel) = [Time_2.(Channel);t2];
            
%             baseline_area
            baseline_for_ar = mean(SSEP(1:(start_time_1 - end_time_1)*fs));
            Baseline_Area = sum(abs(SSEP(1,((start_time_1 + start_time_2)*fs+1):((start_time_1+end_time_2)*fs+1)) - baseline_for_ar));
            SSEP_analysis_DAQ.(Channel).LFP_analysis.Baseline_Area(trial,1) = Baseline_Area;
            SSEP_analysis_DAQ.(Channel).LFP_analysis.Baseline(trial,1) = baseline_for_ar;
            
            figure(ch);
            subplot(7,4,trial)
            plot(x_ad,SSEP)
            hold on
            line([x_ad(1,((start_time_1+start_time_2)*fs+1)) x_ad(1,((start_time_1+start_time_2)*fs+1))],[-0.005 0.005],'Color','r')
            hold on
            line([x_ad(1,((start_time_1+end_time_2)*fs+1)) x_ad(1,((start_time_1+end_time_2)*fs+1))],[-0.005 0.005],'Color','r')
            hold on
            line([-0.5 0.5],[baseline_for_ar baseline_for_ar],'Color','b')
            hold on
        % multi unit analysis V.S. forlimbic dynamic        
            if isempty(Minpks)~=1 && isempty(Maxpks)~=1     % if there exist max and min peak 
                m_u = Neural_Signal_analysis_DAQ.Neural_analysis.(Channel).Multiunit(2:end,response_start(ch,1):response_end(ch,1));     % assign the data
                unit = size(m_u,1)/Trial;       % the count of the unit
                if size(m_u(trial+(0:unit-1)*Trial,:),1)>1
                    M_U = sum(m_u(trial+(0:unit-1)*Trial,:));       % sum each unit of the trial
                else 
                    M_U = m_u(trial+(0:unit-1)*Trial,:);
                end
                SSEP_analysis_DAQ.(Channel).SPK_analysis.Multi_Unit = [SSEP_analysis_DAQ.(Channel).SPK_analysis.Multi_Unit;M_U];                                
            end            
        end
    end
end

%% LFP analysis
for ch = 1:8
    Channel = sprintf('Channel_%d',ch);
    SSEP = SSEP_analysis_DAQ.(Channel).LFP_analysis.SSEP;
    Maxlocs = SSEP_analysis_DAQ.(Channel).LFP_analysis.loc_SSEP(:,1);
    Minlocs = SSEP_analysis_DAQ.(Channel).LFP_analysis.loc_SSEP(:,2);
    x_ad = Neural_Signal_analysis_DAQ.Neural_analysis.(Channel).LFP_segment(1,:);
    [Area_sum_PV,Square_sum_PV,Area_mean_PV,Square_mean_PV,Dev_PV] = LFP_analysis(SSEP,Maxlocs,Minlocs,x_ad);
    [Area_sum_BL,Square_sum_BL,Area_mean_BL,Square_mean_BL,Dev_BL] = LFP_analysis(SSEP,Time_1.(Channel),Time_2.(Channel),x_ad);
    SSEP_analysis_DAQ.(Channel).LFP_analysis.Area_sum_PV = Area_sum_PV;
    SSEP_analysis_DAQ.(Channel).LFP_analysis.Square_sum_PV = Square_sum_PV;
    SSEP_analysis_DAQ.(Channel).LFP_analysis.Area_mean_PV = Area_mean_PV;
    SSEP_analysis_DAQ.(Channel).LFP_analysis.Square_mean_PV = Square_mean_PV;
    SSEP_analysis_DAQ.(Channel).LFP_analysis.Dev_PV = Dev_PV;
    SSEP_analysis_DAQ.(Channel).LFP_analysis.Area_sum_BL = Area_sum_BL;
    SSEP_analysis_DAQ.(Channel).LFP_analysis.Square_sum_BL = Square_sum_BL;
    SSEP_analysis_DAQ.(Channel).LFP_analysis.Area_mean_BL = Area_mean_BL;
    SSEP_analysis_DAQ.(Channel).LFP_analysis.Square_mean_BL = Square_mean_BL;
    SSEP_analysis_DAQ.(Channel).LFP_analysis.Dev_BL = Dev_BL;
end
save(fullfile(Write,['Pressing_Lever_analysis_' num2str(bin*1000) 'ms']),'SSEP_analysis_DAQ');
