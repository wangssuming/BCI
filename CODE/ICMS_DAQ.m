clear all;
close all;
% Number='S1_M1_ICMS_2_0430';
% mkdir(fullfile('C:\Users\NSE916\Desktop\S1_M1_ICMS_project\MatlabClientDevelopKit',Number));
% Write = fullfile('C:\Users\NSE916\Desktop\S1_M1_ICMS_project\MatlabClientDevelopKit',Number);
 
s_1 = daq.createSession('ni');      % water reward zone voltage record
s_2 = daq.createSession('ni');      % generate TTL to water giver
s_3 = daq.createSession('ni');      % generate TLL to stimulator 
addAnalogInputChannel(s_1,'Dev1',0,'Voltage');
addDigitalChannel(s_2,'Dev1', 'Port0/Line0', 'OutputOnly');     % water giver
addDigitalChannel(s_3,'Dev1', 'Port0/Line1', 'OutputOnly');     % stimulator
s_1.Rate = 10000;
distance_setting = 200;
display('Complete Callibration!')
true_positive = 0;
false_positive = 0;
trial=0;
while 1
    clear Position
    %% Plexon connection
    m=mexPlexOnline(9, -1); % PL_InitClient
    pause(0.5);
    
    %% ICMS zone
    n = 0;      % reset the stimulation time
    while n<1
        [d, t, w] = mexPlexOnline(17,m);
        [nCoords, nDim, nVTMode, Position] = mexPlexOnline(18, t); % PL_VTInterpret
        lever_position = Position(:,4:5)          %lever position¡±?????????
        forelimb_position = Position(:,2:3)
        distance = sqrt((lever_position(:,1)-forelimb_position(:,1)).^2+(lever_position(:,2)-forelimb_position(:,2)).^2);

        Lever_position_randx=[];
        Lever_position_randy=[];       
        Lever_position_randx = randi([lever_position(1,1) - 70,lever_position(1,1) + 110],1,1);
        Lever_position_randy = randi([lever_position(1,2) - 320,lever_position(1,2) + 100],1,1); 
              %%?¢X¡±???¢X?????(?????e???@?b?P?????@?b)
        min_distance = min(distance);
         pause(10)
        tic     % Start the counter
 
            %% start stimulation,
            n = 0;
        if (max(Position(:,3))>Lever_position_randx - 40 & max(Position(:,3))<Lever_position_randx + 40 & max(Position(:,2))<Lever_position_randy + 40 & max(Position(:,2))>Lever_position_randy - 40)                       
            %%?¢X¡±???¢X?????(?H?¡Ò?????????????m?n?????????o?d??)
            outputSingleScan(s_3,[1]);        % generate TTL to stimulator
            pause(0.0002);
            outputSingleScan(s_3,[0]);        % delay time 4.8ms
            disp('Stimulate!!')
            n = n+1;       % stimulate one time
            ICMS_success = 1;       
            pause(1)
        else 
            ICMS_success = 0;
            pause(1)
        end
    end
    display('Complete ICMS')
    %% Water reward zone
    s_1.DurationInSeconds=1;
    [data,time] = s_1.startForeground;
    Base_line = mean(data);
    STD = std(data);
%     plot(diff(data))
    %% Water reward    
    while (toc<7)  % rat turn back to water reward zone in 2 s after start the counter
        s_1.DurationInSeconds=1;
        [data,time] = s_1.startForeground;
        Base_line = mean(data);
        STD = std(data);
        %figure;
       % plot(data)
        if(diff(data)>Base_line+30.*STD)|(diff(data)<Base_line-30.*STD) & (ICMS_success == 1)   % the rat is in water reward zone and complete ICMS
            outputSingleScan(s_2,[1]);
            pause(0.0002);
            outputSingleScan(s_2,[0]); % delay time 4.8ms
            display('Water Reward!') 
            t = toc
            true_positive = true_positive+1;
            break;
        end        
    end
    trial = trial+1;
    toc    
end

