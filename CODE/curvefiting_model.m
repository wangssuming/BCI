clear all;
close all;
date = '2017_0620';
bin = 0.001;
Read_ICMS = fullfile('F:\YY_Lab\Analysis_Data\S1_M1_ICMS_3\ICMS_neural_analysis',date);
Read_Velocity = fullfile('F:\YY_Lab\Analysis_Data\S1_M1_ICMS_3\Pressing_lever_excel');
read_files = dir([Read_ICMS '\*' num2str(bin*1000) 'ms_2.mat']);      % read data direction
read_velocity = dir([Read_Velocity '\*50*mat']);
% mkdir(fullfile('F:\YY_Lab\Analysis_Data\S1_M1_ICMS_3\Model',date));
% Write = fullfile('F:\YY_Lab\Analysis_Data\S1_M1_ICMS_3\Model',date);
load(fullfile(Read_ICMS,read_files.name));
load(fullfile(Read_Velocity,read_velocity.name));

Variable =8;
ICMS_input = log([10;20;30;40;50;60]);
Velocity_input = log(table2array(Table.Channel_1(:,18)));
for ch = 1:8
    Channel = sprintf('Channel_%d',ch);
    ICMS_output = table2array(Table_ICMS.(Channel)(:,Variable));
    Velocity_output = table2array(Table.(Channel)(:,Variable));

    [fitresult, gof] = createFit_1order(ICMS_input, ICMS_output)
    title([Channel ' ICMS r^2 = ' num2str(gof.rsquare)])
    ylabel(Table.(Channel).Properties.VariableNames(1,Variable))
    legend('ICMS parameter v.s. Neural response','Fitting curve')
    saveas(figure(1),fullfile('F:\YY_Lab\Analysis_Data\S1_M1_ICMS_3\Model',[Channel 'ICMS']))
    saveas(figure(1),fullfile('F:\YY_Lab\Analysis_Data\S1_M1_ICMS_3\Model',[Channel 'ICMS.tif']))
    text()
    close all;

    [fitresult, gof] = createFit_1order(Velocity_input, Velocity_output)
    title([Channel ' Velocity r^2 = ' num2str(gof.rsquare)])
    ylabel(Table.(Channel).Properties.VariableNames(1,Variable))
    legend('Velocity v.s. Neural response','Fitting curve')
    saveas(figure(1),fullfile('F:\YY_Lab\Analysis_Data\S1_M1_ICMS_3\Model',[Channel 'Velocity']))
    saveas(figure(1),fullfile('F:\YY_Lab\Analysis_Data\S1_M1_ICMS_3\Model',[Channel 'Velocity.tif']))
    
    close all;
end