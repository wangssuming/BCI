clear all;
close all;
Date = '2017_0710_1';
Write = fullfile('D:\Seneory_Feedback\S1_M1_ICMS_5\EMD',Date);
files = dir(fullfile(Write,'\Emd.mat'));
load(fullfile(Write,files.name))

for ch=1:8
    Channel = sprintf('Channel_%d',ch);
    for trial=1:length(fieldnames(Emd.(Channel)))
        Trial = sprintf('Trial_%d',trial);
        emd_imf = Emd.(Channel).(Trial);
        Emd_sum.(Channel)(trial,:) = sum(emd_imf(1:3,:));
    end
    
    [whitesig, whiteningMatrix, dewhiteningMatrix, E, D] = PCA_only(Emd_sum.(Channel),'numOfIC',2,'displayMode','off','firstEig',1,'lastEig',4);    
    PCA.E.(Channel) = E;
    PCA.Whitesig.(Channel) = whitesig;
end
save(fullfile(Write,'EMD_PCA'),'Emd','Emd_sum','PCA','-v7.3');