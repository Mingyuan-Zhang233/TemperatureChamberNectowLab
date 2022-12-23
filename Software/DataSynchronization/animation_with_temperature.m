%% Variables

Start_Time =1000; %%% seconds
End_Time = 1500;
box_dim=[60, 200, 520, 260];
play_speed = 1;
video_delay_start = 19.62; %% when you actually hit 'record' on ethovision, from LogAI file
%% make an array from data

%dFarray = table2array(dF);
plot_time = FIP_time;
FIP_data = aligned_data(:,1);
T1_data = aligned_data(:,3);
T2_data = aligned_data(:,4);


%% Create video reader object as 'v'
v = VideoReader('Data/Mouse 1_RR/Mouse 1_RR.mpg');
frameratevideo=v.FrameRate;
v.CurrentTime = Start_Time;


%% Create plot for Calcium dependent signal

plot_CD = subplot(2,1,1);
FIP_curve = animatedline;
T1_curve = animatedline;
T2_curve = animatedline;
%h = animatedline('MaximumNumPoints',2000);
[~, start_index] = min(abs(plot_time-Start_Time));
[~, end_index] = min(abs(plot_time-End_Time));

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
start_playtime = tic;
a=1;
real_pausetime=(1/v.FrameRate);
w = VideoWriter('trial');
open(w)

while c_time<End_Time
    c_time = v.CurrentTime;
    c_time_corrected = c_time+video_delay_start;
    
    % video
    current_frame=readFrame(v);
    projection.CData=current_frame;
   
    %dF signal plotted
    [~, time_stamp]=min(abs(plot_time-c_time_corrected));
        addpoints(FIP_curve,plot_time(time_stamp),FIP_data(time_stamp));
        addpoints(T1_curve,plot_time(time_stamp),T1_data(time_stamp));
        addpoints(T2_curve,plot_time(time_stamp),T2_data(time_stamp));
        legend('F', 'Temperature 1',  'Temperature 2');
        xlim auto
        ylim auto
        drawnow
   
 
    %write video
    thisframe = getframe(gcf);
    writeVideo(w,thisframe)
    
    %pause
    time_difference=c_time-(toc(start_playtime)*play_speed)-Start_Time;
    pausetime = (real_pausetime+time_difference);
    pause(pausetime)
    

end
close(w);
