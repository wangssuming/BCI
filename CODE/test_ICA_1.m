[icasig, A, W] = fastica(newSSEP_2,'numOfIC',3,'displayMode','off','firstEig',1,'lastEig',3); % fast ICA
%    fasticag(newSSEP_2); 
   
   if length(icasig(:,1))==3
    rejectICA=[];
    R1=[];
    for i=1:3
        tmp=corrcoef(icasig(i,:),SSEP(2,:));
        R1(i)=tmp(2);
    end
    rejectICA=find(abs(R1)>0.5);

    R2=[];
    for i=1:3
        tmp=corrcoef(icasig(i,:),SSEP(4,:));
        R2(i)=tmp(2);
    end
    rejectICA=[rejectICA find(abs(R2)>0.5)];
    rejectICA=unique(rejectICA);

    A2=A;
    icasig2=icasig;
    %%% reconstruct the signal
    A2(:,rejectICA)=[];
    icasig2(rejectICA,:)=[];
    
    newSSEP_3=(A2*icasig2);
    
    for ch=1:8
        Channel = sprintf('Channel_%d',ch);
        figure(1)
        subplot(2,1,1)
        plot(timestamp,SSEP(ch,:))
        subplot(2,1,2)
        plot(timestamp,newSSEP_3(ch,:)) 
        set(gcf,'units','normalized','position',[0 0 .5 1])
        saveas(figure(1),fullfile(Write, [Channel Trial '.tif'])); 
        close all;
    end
    
   end
    