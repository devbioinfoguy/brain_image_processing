% This function is to initialize (or re-initialize) the data that are
% shared between functions and with and between Apps
function InitGUI()

% SpikeGui store all the variables and handles that are relevant to the
% main interface and meant to be shared with the others
global SpikeGui;

SpikeGui=struct('MAINhandle',{},'currentPath',{},'CurrentAppFolder',{},...
    'CurrentNumberInMovie',{},'hDataDisplay',{},'SubAxes',{},'TitleHandle',{},...
    'ImageHandle',{},'TraceHandle',{},'currentTime',{},'MaxTime',{},'MinTime',{},'TimerData',{});

% MAINhandle is the handle to the main interface of SpikeExtractor
% We never have to reinitialize as it is set up at the start and stay good

% CurrentAppFolder stores the location of the current Apps folder. This
% variable can change while the user is navigating the tree of Apps.
% Variable is relative to the folder of SpikeExtractor.fig

% CurrentNumberInMovie is an array that store the current displayed frame
% of all selected movies
% Data is an array the size of number of movies in memory

% hDataDisplay is the handle to the current figure where the data is
% displayed

% SubAxes is an array of handles to all the selected axes (movies and traces) on the current
% figure

% MainTitleHandle is a handle that point to the main title on the figure.

% TitleHandle is an array of handles that point to the title displayed on
% each individual axes. 

% ImageHandle is an array of handles that point to the image windows displayed on
% hDataDisplay

% TraceHandle is an array of handles to all the lines that show time on traces

% currentTime stores the current displayed time

% MaxTime stores the maximum time of all data (movies and traces)

% MaxTime stores the minimum time of all data (movies and traces)

% TimerData stores the timer that control the playback of the data on the
% figure. It ensures constant frame rate replay