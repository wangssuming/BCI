%% Convert .plx to .mat
% Editor : Pei Chi, Chuang
% Date : 2017/03/26
%% Data Structure (Plexon)=================================================
%       a. Channel_ch       - 1-based channel number or channel name
%           -- Unit_u       - Unit number (0- unsorted, 1-4 units a-d)
%               + FiringRateVector
%               + wave
%               + ts
%           -- AD           - Array of a/d values converted to millivolts        
%       b. ADfreq           - Digitization frequency for this channel
%       c. Event002         - Lever pressing time
%       d. Position         - [Timestamp x1 y1 x2 y2] (1-Lever; 2-Forlimb)
%% ========================================================================
clear all;
Read = 'C:\Users\ASUS\Desktop\';
date = 'S1_M1_ICMS_04_0621';
Read = [Read date '\'];
read_files = dir([Read '*.plx']);      % read data direction
bin = 0.005;                                                               % bin   - time bin (s)
mkdir(fullfile('C:\Users\ASUS\Desktop\',date));
mkdir(fullfile(fullfile('C:\Users\ASUS\Desktop\',date),[num2str(bin*1000) 'ms']));
Write = fullfile(fullfile('C:\Users\ASUS\Desktop\',date),[num2str(bin*1000) 'ms']);
Fold = read_files(1).name(1:end-7);
% mkdir(write_direction);
for n = 1:length(read_files)
    rdfile = read_files(n).name(1:end-7); % File name    
    filename = sprintf('%s%s.plx',Read,rdfile); % Giving direction
    [Plexon, Verify] = load_data(filename,bin);
    if Verify>0
        wrFile = sprintf('%s_bin%d%s',rdfile,bin*1000,'ms');
        save(fullfile(Write,wrFile),'Plexon');
    end
    clear Plexon;
end
