%% Intro
%   This file can be use to start a fiber photometry recording using
%   FIPSTER. Please refer to the Github for details on how to build your
%   own camera-based fiber photometry setup.
%
%   EXAMPLE_RECORDING is part of FIPSTER, FIPSTER is made by Johannes de
%   Jong, j.w.dejong@berkeley.edu
%
%   May 10th, 2019


%% Start
close all force
clear all force


%% Acquisition object
% This will build the acquisition object. The acquisition object is
% described in the file FIP_aquisition. To inspect the object, double click
% on it in the MATLAB workspace.

addpath('Fipster\')
acquisition = FIP_acquisition;


%% Set variables
% This will set the aquisition settings for a 2-channel recording
% (presumably 405nm and 477nm). The TOTAL framerate will be 20Hz (so 10Hz
% per channel). Change the filename parameter to set your own filename. To
% get an overview of the cameras available on your system, navigate to
% acquisition.cam_settings.options. Generally you want one with high light
% sensitivity and low resolution.

filename = '2022-10-05_Pdyn-GCamp6s_Soma Targeted_Mouse5_LL_38C';
acquisition.filename = filename;
acquisition.aq_settings.rate = 20;
acquisition.aq_settings.channels = 2;
acquisition.aq_settings.backup_cycle = 200;
acquisition.cam_settings.in_use = 3;
acquisition.plt_settings.type = '-';
acquisition.plt_settings.smooth = 1;
acquisition.plt_settings.live_feed = false;


%% Calibration
% You only have to run this cell once.
acquisition.calibrate;


%% Start

vent_time = 10; % The ventilation will activate after this many seconds
pyrunfile(strcat('Start_Temp_Service.py', 32, num2str(vent_time)));
acquisition.start_acquisition;

% to make it work properly, add "pyrunfile('Start_Temp.py')" before the acquisition loop
% and  "pyrunfile(strcat('Stop_Temp.py', 32, obj.filename)" after the cquisition loop
% 32 is the magic number for whitespace for strcat to work. 
