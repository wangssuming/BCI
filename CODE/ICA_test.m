Date = '2017_0710_4';
mkdir(fullfile('C:\Users\ASUS\Desktop\Seneory_Feedback\S1_M1_ICMS_5\ICA_2',Date))
Write = fullfile('C:\Users\ASUS\Desktop\Seneory_Feedback\S1_M1_ICMS_5\ICA_2',Date);
Read = fullfile('C:\Users\ASUS\Desktop\Seneory_Feedback\S1_M1_ICMS_5\Pressing_lever_preprocessing',Date);
File = dir([Read '\*.mat']);
load([Read '\' File.name]);
timestamp=Neural_Signal_analysis_DAQ.Neural_analysis.Channel_1.LFP_segment(1,:);
for trial=1:length(Neural_Signal_analysis_DAQ.Duration)
    Trial = sprintf('Trial_%d',trial);
    SSEP = [];

    for ch=1:8
        if ch ~= 4 & ch~= 2

           Channel = sprintf('Channel_%d',ch);
           SSEP = [SSEP;Neural_Signal_analysis_DAQ.Neural_analysis.(Channel).LFP_segment(trial+1,:)];         
        end
    end

%     fasticag(SSEP);
    if isempty(SSEP) == 0
%         [icasig, A, W] = fastica(SSEPwh,'numOfIC',2,'displayMode','off','firstEig',1,'lastEig',4); % fast ICA
          [wIC,A,W,IC] = wICA(SSEP,'fastica',1,1,20000,2);
    end
    saveas(figure(1),fullfile(Write, [Channel Trial '_3.tif']));
    close all;
    
%     if length(wIC(:,1))==2
    rejectICA=[];
    R1=[];
    for i=1:length(wIC(:,1))
        Channel_1 = sprintf('Channel_%d',2);
        SSEP_1 = Neural_Signal_analysis_DAQ.Neural_analysis.(Channel_1).LFP_segment(trial+1,:);
        tmp=corrcoef(wIC(i,:),SSEP_1);
        R1(i)=tmp(2);
    end
    rejectICA=find(abs(R1)>0.5);

    R2=[];
    for i=1:length(wIC(:,1))
        Channel_2 = sprintf('Channel_%d',4);
        SSEP_2 = Neural_Signal_analysis_DAQ.Neural_analysis.(Channel_2).LFP_segment(trial+1,:);
        tmp=corrcoef(wIC(i,:),SSEP_2);
        R2(i)=tmp(2);
    end
    rejectICA=[rejectICA find(abs(R2)>0.5)];
    rejectICA=unique(rejectICA);

    A2=A;
    icasig2=wIC;
%     %%% reconstruct the signal
    A2(:,rejectICA)=[];
    icasig2(rejectICA,:)=[];
    
    newSSEP=(A2*icasig2);
%     if length(wIC(:,1))==3
        
    for ch=1:length(newSSEP(:,1))
        Channel = sprintf('Component_%d',ch);
        ICA.(Trial)(ch,:) = newSSEP(ch,:);
        figure(1)
        subplot(2,1,1)
        plot(timestamp,SSEP(ch,:))
        subplot(2,1,2)
        plot(timestamp,newSSEP(ch,:)) 
        set(gcf,'units','normalized','position',[0 0 .5 1])
        saveas(figure(1),fullfile(Write, [Channel Trial '_2.tif'])); 
        close all;
    end
%     elseif length(wIC(:,1))~=3
%         fprintf(1,'It fail.\n')
%     end
end
% end
ICA.Timestamp = timestamp;
save(fullfile(Write,'ICA'),'ICA','-v7.3');