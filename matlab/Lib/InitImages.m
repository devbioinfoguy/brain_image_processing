% This function is to initialize (or re-initialize) the data that are
% shared between functions and with Apps
function InitImages()

% SpikeImageData is shared with all Apps
% it is a structure that gather all datas
% SpikeImageData can be repeated along its first dimensions 
% Each element will be one Image.
global SpikeImageData;

SpikeImageData=struct('Path',{},'Filename',{},'Image',{},...
    'DataSize',{},'Xposition',{},'Yposition',{},'Zposition',{},'Label',struct(...
    'ListText',{},'XLabel',{},'YLabel',{},'ZLabel',{},...
    'CLabel',{}), 'ID', {});

% Filename and Path store the path to the original file from which the data is coming from

% Image is the actual image data. Size is MxN where 
% M horizontal pixels
% N vertical pixels

% DataSize store the size of Image
% Size is 2

% Xposition, Yposition and Zposition are position matrix. They store the
% actual X and Y axis value for all pixels. Z is optional. X and Y can be
% space variables or any other variable that is relevant to the picture X
% and Y axis. The XLabel and YLabel has to match what is in these axis.
% Size is MxN

% Label store the text values associated with various labelling text