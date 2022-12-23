%% Load data
clc;
close all
clear;

% add path optional
addpath('C:\Users\NectowLab\Desktop\Fipster')
signal = FIP_signal('User input');
%% Variables

Start_Time =800; %%% seconds
End_Time = 1020;
box_dim=[60, 200, 520, 260];
play_speed = 1;
figure_size = [1280, 960];
video_delay_start = 19.62; %% (optional) when you actually hit 'record' on ethovision, from LogAI file
ttl_threshold = 1.8;
pulse = signal.logAI(find(signal.logAI(:,2)>=ttl_threshold),1);
if (max(abs(diff(pulse))) > 0.1)
    warning("Multiple TTL pulses detected. Using manually entered video_delay_start!")
else
    video_delay_start = pulse(find(diff(pulse)<=mean(abs(diff(pulse))), 1));
    disp(['Auto Video Delay: ' num2str(video_delay_start)]);
end
%% make an array from data


%dFarray = table2array(dF);
plot_time = signal.data{1,1}(:,2);
FIP_data = signal.data{1,1}(:,1);


%% Create video reader object as 'v'
%v = VideoReader('Mouse 1_RR.mpg');
[f, p] = uigetfile('*.mpg','Select the video recording');
v = VideoReader(strcat(p, f));
frameratevideo=v.FrameRate;


%% Create plot for Calcium dependent signal
figure('units','pixels','position',[0 0 figure_size(1) figure_size(2)])
v.CurrentTime = Start_Time;
plot_CD = subplot(2,1,1);
xlabel('Time(s)');
ylabel('dF/F');
FIP_curve = animatedline('Color', 'b');
%h = animatedline('MaximumNumPoints',2000);
[~, start_index] = min(abs(plot_time-Start_Time));
[~, end_index] = min(abs(plot_time-End_Time));

plot_CD.XLimMode='auto';
% legend optional
% legend('df/F', 'Location','northwest');



hold on

%Create plot for video
plot_video=subplot(2,1,2);
current_frame = readFrame(v);
projection = image(current_frame);
plot_video.Visible = 'off';


%% Runtime
c_time=Start_Time;
start_playtime = tic;
a=1;
real_pausetime=(1/v.FrameRate);
w = VideoWriter('trial');
open(w)
try

while c_time<End_Time
    c_time = v.CurrentTime;
    c_time_corrected = c_time+video_delay_start;
    
    % video
    current_frame=readFrame(v);
    projection.CData=current_frame;
   
    %dF signal plotted
    [~, time_stamp]=min(abs(plot_time-c_time_corrected));
        addpoints(FIP_curve,plot_time(time_stamp),FIP_data(time_stamp));
        xlim auto
        ylim auto
        drawnow
   
 
    %write video
    thisframe = getframe(plot_video);
    writeVideo(w,thisframe)
    
    %pause
    time_difference=c_time-(toc(start_playtime)*play_speed)-Start_Time;
    pausetime = (real_pausetime+time_difference);
    pause(pausetime)
    

end
catch 
    warning("unexpected termination");
end
close(w);
