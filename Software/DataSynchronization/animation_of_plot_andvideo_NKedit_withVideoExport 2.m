close all
clear all


%% Variables

Start_Time =1000; %%% seconds
End_Time = 1500;
box_dim=[60, 200, 520, 260];
play_speed = 1;
video_delay_start = 15.71; %% when you actually hit 'record' on ethovision, from LogAI file
%% make an array from data

%dFarray = table2array(dF);
plotting_time = FIP_time;
plotting_data = [aligned_data(:,1), aligned_data(:,3:4)];


%% Create video reader object as 'v'
v = VideoReader('Mouse 4_trained.mpg');
frameratevideo=v.FrameRate;
v.CurrentTime = Start_Time;


%% Create plot for Calcium dependent signal

plot_CD = subplot(2,1,1);
h = animatedline
%h = animatedline('MaximumNumPoints',2000);
[~, start_index] = min(abs(plotting_time-Start_Time));
[~, end_index] = min(abs(plotting_time-End_Time));

plot_CD.XLimMode='auto';
plot_CD.YLimMode='manual';

xlabel('Time(s)')
ylabel('dF/F')
hold on

%Create plot for video
plot_video=subplot(2,1,2);
current_frame = readFrame(v);
projection = image(current_frame);
plot_video.Visible = 'off';


%% Runtime
c_time=Start_Time;
start_playtime = tic
a=1;
real_pausetime=(1/v.FrameRate);
w = VideoWriter('trial')
open(w)

while c_time<End_Time
    c_time = v.CurrentTime;
    c_time_corrected = c_time+video_delay_start;
    
    % video
    current_frame=readFrame(v);
    projection.CData=current_frame;
   
    %dF signal plotted
    [~, time_stamp]=min(abs(plotting_time-c_time_corrected));
        addpoints(h,plotting_time(time_stamp),dFarray(time_stamp,1));
        xlim auto
        ylim auto
        drawnow
   
 
    %write video
    thisframe = getframe(gcf)
    writeVideo(w,thisframe)
    
    %pause
    time_difference=c_time-(toc(start_playtime)*play_speed)-Start_Time;
    pausetime = (real_pausetime+time_difference);
    pause(pausetime)
    

end
close(w)
