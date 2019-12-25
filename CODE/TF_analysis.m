clear all;
close all

Date = '2017_0708';
Read = fullfile('D:\Seneory_Feedback\S1_M1_ICMS_5\EMD',Date);
mkdir(fullfile('D:\Seneory_Feedback\S1_M1_ICMS_5\TF_analysis',Date));
Write = fullfile('D:\Seneory_Feedback\S1_M1_ICMS_5\TF_analysis',Date);
File = dir([Read '\EMD_PCA.mat']);
load([Read '\' File.name]);
%% Initial conditions setting
temp_count = 1;
fs = 20000;                      % Samplingrates after downsample. (Hz) % relative to "dsm" 
nfft_f = 50000;                 % Nfft points used in spectrogra, TF yaxis, 1025:1
windows = 800;                  % Window used in spectrogram default []= Hamming, TF xaxis
noverlap = 700;                  % Overlap used in spectrogram

%% TF analysis
for trial = 1:length(fieldnames(ICA))-1
    For_delta_mean = [];
    For_theta_mean = [];
    For_alpha_mean = [];
    For_gamma_mean = [];
    For_mu_mean = [];
    For_beta_mean = [];
    Trial = sprintf('Trial_%d',trial);
    xch = ICA.(Trial);             % Input (A*unit)
    %% down sample
    down_s = 1:20000/fs:size(xch,2);
    xch = xch(:,down_s);
    for component = 1:size(xch,1)
        [Ssig,Fsig,Tsig,psig1] = spectrogram(xch(component,:),windows,noverlap,nfft_f,fs,'yaxis');
        t_spectro = ICA.Timestamp;
        f_spectro = 0:fs/nfft_f:fs/2;
    %%  轉 100 % 用
    % Input = psd
    % t_spectro and f_spectro re Def
        imagesc(t_spectro,f_spectro,psig1);
        view(0,-90);   
        set(gca, 'xlim', [-0.5 0.5], 'ygrid', 'on');
        title('T-F Analysis', 'FontName', 'Arial', 'FontSize', 18);
        xlabel('Time (s)', 'FontName', 'Arial', 'FontSize', 14);
        ylabel('Frequency (Hz)', 'FontName', 'Arial', 'FontSize', 14);        
        handl = colorbar;
        set(handl, 'FontName', 'Arial', 'FontSize', 14);
        title(['Trial ' num2str(trial) ' Component ' num2str(component)],'fontsize',26)
        ylim([0 500]);
        saveas(figure(1),fullfile(Write,['TF_' Trial 'Component_' num2str(component)]))
        saveas(figure(1),fullfile(Write,['TF_' Trial 'Component_' num2str(component) '.tif']))
        close all;

    %% Z-score
    % Input = psd
    % t_spectro and f_spectro re Def
%         yyaxis right
        zs_sig=zscore(psig1);
        imagesc(t_spectro,f_spectro,zs_sig);
        line([0,0],[0,50],'LineWidth',3);
        view(0,-90);   
        set(gca, 'xlim', [-0.5 0.5]);
        title('Z scores Analysis', 'FontName', 'Arial', 'FontSize', 18);
        xlabel('Time (s)', 'FontName', 'Arial', 'FontSize', 14);
        ylabel('Frequency (Hz)', 'FontName', 'Arial', 'FontSize', 14);
        handl = colorbar;
        set(handl, 'FontName', 'Arial', 'FontSize', 14);
        title(['Trial' num2str(trial) 'Component' num2str(component)])
        ylim([0 500]);
        saveas(figure(1),fullfile(Write,['Zscore_' Trial 'Component_' num2str(component)]))
        saveas(figure(1),fullfile(Write,['Zscore_' Trial 'Component_' num2str(component) '.tif']))
        close all;

    %% Plot band-related Z-score
        t = -0.5:0.1/16:0.5;               % time區間
        %% Calculate mean and zscore for all
%         Inputm=mean(zs_sig(:));
%         Input=zs_sig-Inputm;
%         zs_sig=Input;
        %% Divide different band  z-score used
        hold on
        Start = find(Fsig<=0,1,'last');
        End = find(Fsig<=4,1,'last');
        for_delta = zs_sig(Start:End,:);       % 0~4 Hz change
        for_delta_mean = mean(for_delta,1);
        err_for_delta = std(for_delta,1)/sqrt(size(for_delta,1)); % +- 20%, change
%         c1 = polyfit(t, for_delta,9);
%         d1 = polyval(c1, t, 1);
        Start = find(Fsig<=4,1,'last')+1;
        End = find(Fsig<=7,1,'last');
        for_theta = zs_sig(Start:End,:);       % 4~7 Hz change
        for_theta_mean = mean(for_theta,1);
        err_for_theta = std(for_theta,1)/sqrt(size(for_theta,1)); % +- 20%
%         c2 = polyfit(t, for_delta,9);
%         d2 = polyval(c2, t, 1);
        Start = find(Fsig<=7,1,'last')+1;
        End = find(Fsig<=15,1,'last');
        for_alpha = zs_sig(Start:End,:);       % 7~15 Hz change
        for_alpha_mean = mean(for_alpha,1);
        err_for_alpha = std(for_alpha,1)/sqrt(size(for_alpha,1)); % +- 20%
%         c3 = polyfit(t, for_alpha,9);
%         d3 = polyval(c3, t, 1);
        Start = find(Fsig<=15,1,'last')+1;
        End = find(Fsig<=32,1,'last');
        for_beta = zs_sig(Start:End,:);       % 15~32 Hz change
        for_beta_mean = mean(for_beta,1);
        err_for_beta = std(for_beta,1)/sqrt(size(for_beta,1)); % +- 20%
%         c4 = polyfit(t, for_beta,9);
%         d4 = polyval(c4, t, 1);
        Start = find(Fsig<=32,1,'last')+1;
        End = find(Fsig<=51,1,'last');
        for_gamma = zs_sig(Start:End,:);       % 32~51 Hz change
        for_gamma_mean = mean(for_gamma,1);
        err_for_gamma = std(for_gamma,1)/sqrt(size(for_gamma,1)); % +- 20%
%         c5 = polyfit(t, for_gamma,9);
%         d5 = polyval(c5, t, 1);
        Start = find(Fsig<=8,1,'last')+1;
        End = find(Fsig<=12,1,'last');
        for_mu = zs_sig(Start:End,:);           % 8~12 Hz change
        for_mu_mean = mean(for_mu,1);
        err_for_mu = std(for_mu,1)/sqrt(size(for_mu,1)); % +- 20%
%         c6 = polyfit(t, for_mu,9);
%         d6 = polyval(c6, t, 1);


        h1=errorbar(t,for_delta_mean,err_for_delta);
        set(h1,'Linewidth',1,'marker', 'o');
        hold on
        h2=errorbar(t,for_theta_mean,err_for_theta);
        set(h2,'Linewidth',1,'marker', '+');
        hold on
        h3=errorbar(t,for_alpha_mean,err_for_alpha);
        set(h3,'Linewidth',1,'marker', 'pentagram')
        hold on
        h4=errorbar(t,for_beta_mean,err_for_beta);
        set(h4,'Linewidth',1);
        hold on
        h5=errorbar(t,for_gamma_mean,err_for_gamma);
        set(h5,'Linewidth',1,'marker', '.');
        hold on
        h6=errorbar(t,for_mu_mean,err_for_mu);
        set(h6,'Linewidth',1,'marker', '*');
        hold on

        line([0,0],[-999,2000],'LineWidth',0.05,'Color','r');
        hold off
        box off
        legend('Delta (<4 Hz)','Theta (4 - 7 Hz)','Alpha (7 - 15 Hz)'...
            ,'Beta (15 - 32 Hz)','Gamma (32+ Hz)','Mu (8 - 12 Hz)');
        % legend('Delta (<4 Hz)','Theta (4 - 7 Hz)','Beta (15 - 32 Hz)');
        set(gca, 'xlim', [-0.5 0.5], 'ylim', [-1.5 50],  'ygrid', 'on');
        set(gcf,'units','normalized','position',[0 0 1 1])
        xlabel('Time (s)', 'FontName', 'Arial', 'FontSize', 14);
        ylabel('Z scores', 'FontName', 'Arial', 'FontSize', 14);
        title(['Trial' num2str(trial) ' Component ' num2str(component)])
        saveas(figure(1),fullfile(Write,['Zscore_band_' Trial 'Component_' num2str(component)]))
        saveas(figure(1),fullfile(Write,['Zscore_band_' Trial 'Component_' num2str(component) '.tif']))
        close all;
        For_delta_mean = [For_delta_mean; for_delta_mean];
        For_theta_mean = [For_theta_mean; for_theta_mean];
        For_alpha_mean = [For_alpha_mean; for_alpha_mean];
        For_beta_mean = [For_beta_mean;for_beta_mean];
        For_gamma_mean = [For_gamma_mean; for_gamma_mean];
        For_mu_mean = [For_mu_mean; for_mu_mean];
    end
    plot(t,For_delta_mean)
    hold on
    err_for_delta = std(For_delta_mean)./sqrt(size(For_delta_mean,1));
    errorbar(t,mean(For_delta_mean),err_for_delta,'LineWidth',2);
    title(['Trial' num2str(trial) ' Delta Band '],'fontsize',20)
    xlim([-0.5 0.5])
    xlabel('time (s)')
    ylabel('Z-score')
    line([0 0],[-5 35],'LineWidth',0.05,'Color','r')
    saveas(figure(1),fullfile(Write,['Delta_Band_' Trial]))
    saveas(figure(1),fullfile(Write,['Delta_Band_' Trial '.tif']))
    close all;
    
    plot(t,For_theta_mean)
    hold on
    err_for_delta = std(For_theta_mean)./sqrt(size(For_theta_mean,1));
    errorbar(t,mean(For_theta_mean),err_for_delta,'LineWidth',2);
    title(['Trial' num2str(trial) ' Theta Band '],'fontsize',20)
    xlim([-0.5 0.5])
    xlabel('time (s)')
    ylabel('Z-score')
    line([0 0],[-5 35],'LineWidth',0.05,'Color','r')
    saveas(figure(1),fullfile(Write,['Theta_Band_' Trial ]))
    saveas(figure(1),fullfile(Write,['Theta_Band_' Trial  '.tif']))
    close all;
    
    plot(t,For_alpha_mean)
    hold on
    err_for_delta = std(For_alpha_mean)./sqrt(size(For_alpha_mean,1));
    errorbar(t,mean(For_alpha_mean),err_for_delta,'LineWidth',2);
    title(['Trial' num2str(trial) ' Alpha Band '],'fontsize',20)
    xlim([-0.1 0.1])
    xlabel('time (s)')
    ylabel('Z-score')
    line([0 0],[-5 35],'LineWidth',0.05,'Color','r')
    saveas(figure(1),fullfile(Write,['Alpha_Band_' Trial]))
    saveas(figure(1),fullfile(Write,['Alpha_Band_' Trial '.tif']))
    close all;
   
    plot(t,For_beta_mean)
    hold on
    err_for_delta = std(For_beta_mean)./sqrt(size(For_beta_mean,1));
    errorbar(t,mean(For_beta_mean),err_for_delta,'LineWidth',2);
    title(['Trial ' num2str(trial) ' Beta Band '],'fontsize',20)
    xlim([-0.5 0.5])
    xlabel('time (s)')
    ylabel('Z-score')
    line([0 0],[-5 35],'LineWidth',0.05,'Color','r')
    saveas(figure(1),fullfile(Write,['Beta_Band_' Trial ]))
    saveas(figure(1),fullfile(Write,['Beta_Band_' Trial '.tif']))
    close all;
   
    plot(t,For_gamma_mean)
    hold on
    err_for_delta = std(For_gamma_mean)./sqrt(size(For_gamma_mean,1));
    errorbar(t,mean(For_gamma_mean),err_for_delta,'LineWidth',2);
    title(['Trial' num2str(trial) ' Gamma Band '],'fontsize',20)
    xlim([-0.5 0.5])
    xlabel('time (s)')
    ylabel('Z-score')
    line([0 0],[-5 35],'LineWidth',0.05,'Color','r')
    saveas(figure(1),fullfile(Write,['Gamma_Band_' Trial]))
    saveas(figure(1),fullfile(Write,['Gamma_Band_' Trial '.tif']))
    close all;
    
    plot(t,For_mu_mean)
    hold on
    err_for_delta = std(For_mu_mean)./sqrt(size(For_mu_mean,1));
    errorbar(t,mean(For_mu_mean),err_for_delta,'LineWidth',2);
    title(['Trial' num2str(trial) ' Mu Band '],'fontsize',20)
    xlim([-0.5 0.5])
    xlabel('time (s)')
    ylabel('Z-score')
    line([0 0],[-5 35],'LineWidth',0.05,'Color','r')
    saveas(figure(1),fullfile(Write,['Mu_Band_' Trial]))
    saveas(figure(1),fullfile(Write,['Mu_Band_' Trial '.tif']))
    close all;
end
