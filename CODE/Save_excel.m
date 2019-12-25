%% ------------------------------------------------------------------------
clear all
Date = '2017_0525';
bin = 0.001;
Read = fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Pressing_Lever_analysis',Date);
file = dir([Read '\*' num2str(bin*1000) 'ms.mat']);
load([Read '\' file(1).name]);
% -------------------------------------------------------------------------
for ch = 1:8    
    Channel = sprintf('Channel_%d',ch); 
    Max_peak_SSEP.(Channel) = [];
    Min_peak_SSEP.(Channel) = [];
    magnitude_SSEP.(Channel) = [];
    peak_latency.(Channel) = [];
    valley_latency.(Channel) = [];
    Area_sum_PV.(Channel) = [];
    Square_sum_PV.(Channel) = [];
    Area_mean_PV.(Channel) = [];
    Square_mean_PV.(Channel) = [];
    Area_sum_BL.(Channel) = [];
    Area_mean_BL.(Channel) = [];
    Square_sum_BL.(Channel) = [];
    Square_mean_BL.(Channel) = [];
    Multi_unit.(Channel) = [];
end
Forelimb_Velocity = [];
Duration = [];
% -------------------------------------------------------------------------
Forelimb_Velocity = [Forelimb_Velocity; SSEP_analysis_DAQ.Forelimb_Velocity];
Duration = [Duration; 1./SSEP_analysis_DAQ.Duration];
for ch = 1:8    
    Channel = sprintf('Channel_%d',ch);    
    Max_peak_SSEP.(Channel) = [Max_peak_SSEP.(Channel); SSEP_analysis_DAQ.(Channel).LFP_analysis.Max_peak_SSEP];
    Min_peak_SSEP.(Channel) = [Min_peak_SSEP.(Channel); SSEP_analysis_DAQ.(Channel).LFP_analysis.Min_peak_SSEP];
    magnitude_SSEP.(Channel) = [magnitude_SSEP.(Channel); SSEP_analysis_DAQ.(Channel).LFP_analysis.magnitude_SSEP];
    peak_latency.(Channel) = [peak_latency.(Channel); SSEP_analysis_DAQ.(Channel).LFP_analysis.loc_SSEP(:,1)];
    valley_latency.(Channel) = [valley_latency.(Channel); SSEP_analysis_DAQ.(Channel).LFP_analysis.loc_SSEP(:,2)];
    Area_sum_PV.(Channel) = [Area_sum_PV.(Channel); SSEP_analysis_DAQ.(Channel).LFP_analysis.Area_sum_PV];
    Square_sum_PV.(Channel) = [Square_sum_PV.(Channel); SSEP_analysis_DAQ.(Channel).LFP_analysis.Square_sum_PV];
    Area_mean_PV.(Channel) = [Area_mean_PV.(Channel); SSEP_analysis_DAQ.(Channel).LFP_analysis.Area_mean_PV];
    Square_mean_PV.(Channel) = [Square_mean_PV.(Channel); SSEP_analysis_DAQ.(Channel).LFP_analysis.Square_mean_PV];
    Area_sum_BL.(Channel) = [Area_sum_BL.(Channel); SSEP_analysis_DAQ.(Channel).LFP_analysis.Area_sum_BL];
    Square_sum_BL.(Channel) = [Square_sum_BL.(Channel); SSEP_analysis_DAQ.(Channel).LFP_analysis.Square_sum_BL];
    Area_mean_BL.(Channel) = [Area_mean_BL.(Channel); SSEP_analysis_DAQ.(Channel).LFP_analysis.Area_mean_BL];
    Square_mean_BL.(Channel) = [Square_mean_BL.(Channel); SSEP_analysis_DAQ.(Channel).LFP_analysis.Square_mean_BL];
    Multi_unit.(Channel) = [Multi_unit.(Channel); mean(SSEP_analysis_DAQ.(Channel).SPK_analysis.Multi_Unit(2:end,:),2)];   
end

% -------------------------------------------------------------------------
for ch = 1:8    
    Channel = sprintf('Channel_%d',ch); 
    T = table(Max_peak_SSEP.(Channel), Min_peak_SSEP.(Channel), ...
        magnitude_SSEP.(Channel), peak_latency.(Channel), valley_latency.(Channel),...
        Area_sum_PV.(Channel),Square_sum_PV.(Channel), Area_mean_PV.(Channel),Square_mean_PV.(Channel),...
        Area_sum_BL.(Channel),Square_sum_BL.(Channel), Area_mean_BL.(Channel),Square_mean_BL.(Channel),...
        Multi_unit.(Channel),Forelimb_Velocity,Duration,...
            'VariableNames', {'Max_peak_SSEP' 'Min_peak_SSEP' 'magnitude_SSEP' ...
            'peak_latency' 'valley_latency' 'Area_sum_PV' 'Square_sum_PV' 'Area_mean_PV'...
            'Square_mean_PV' 'Area_sum_BL' 'Square_sum_BL' 'Area_mean_BL'...
            'Square_mean_BL' 'Multi_unit' 'Forelimb_Velocity' 'Duration'})
    Name = [Channel '.xlsx'];
    writetable(T,Name,'Sheet',1,'Range','D5');
    Table.(Channel) = T;    
end
save(fullfile('D:\Peggy\Analysis_Data\S1_M1_ICMS_2\Lever_pressing_excel','All_Lever_pressing_analysis_2'),'Table')