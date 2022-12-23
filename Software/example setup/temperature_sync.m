%% Load and sync the data
addpath('Fipster\');
smoothing = false; % smoothing the Calcium signal
smoothing_windows = 1; % smoothing windows in second (1/cutoff in Hz)

[aligned_data, signal] = temp_sync_wrapper(smoothing, smoothing_windows);

%% Plot

time = aligned_data(:,2);
FIP = aligned_data(:,1);
T1 = aligned_data(:,3);
T2 = aligned_data(:,4);