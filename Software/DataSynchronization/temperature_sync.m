%% load FIP signal

signal = FIP_signal('User input');


%% load temperature data

[file, path] = uigetfile('*.csv','Select the temperate csv data');
warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')
temp = readtable(strcat(path, file));
time = temp.Time_s_;
primary_temperature =  temp.TunnelExhaustTemperature_Celsius_;
secondary_temperature = temp.ChamberTemperature_Celsius_; 


%% Synchronize temperate data with FIP

FIP_time = signal.data{1,1}(:,2);
aligned_primary_temperature = pchip(time, primary_temperature, FIP_time);
aligned_secondary_temperature = pchip(time, secondary_temperature, FIP_time);
aligned_data = cat(2, signal.data{1,1}, aligned_primary_temperature, aligned_secondary_temperature);

%%
yyaxis left
plot(FIP_time, aligned_data(:,1), 'b-');
yyaxis right
plot(FIP_time, aligned_data(:,3), 'r-');hold on;
plot(FIP_time, aligned_data(:,4), 'g-');hold off;
legend('F', 'Primary Temperature', 'Secondary Temperature')
xlim([0,3000])