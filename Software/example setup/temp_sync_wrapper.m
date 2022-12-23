function [aligned_data, signal] = temp_sync_wrapper(smoothing, smoothness)
%% load FIP signal
addpath('Fipster\');
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

% optional: smoothing Calcium curve
FIP_Calcium = signal.data{1,1}(:,1);
time_span = FIP_time(end) - FIP_time(1); % the entire time span, this is NOT smoothing span


%smoothing window size
window = smoothness; % smoothing in second


frac = window/time_span;
disp(['Smoothing cutoff frequency: ' num2str(1/window) 'Hz']);
FIP_Calcium_smoothed = smooth(FIP_Calcium, frac);


if (smoothing)
    aligned_data = [FIP_Calcium_smoothed, FIP_time, aligned_primary_temperature, aligned_secondary_temperature];
else
    aligned_data = cat(2, signal.data{1,1}, aligned_primary_temperature, aligned_secondary_temperature);
end

end