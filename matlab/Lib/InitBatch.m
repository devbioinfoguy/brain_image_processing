% This function is to initialize (or re-initialize) the data that are
% shared between functions and with Apps
function InitBatch()

% SpikeBatchData is shared with all Apps
% it is a structure that gather all datas
% SpikeBatchData can be repeated along its first dimensions 
% Each element is one Apps.
global SpikeBatchData;

SpikeBatchData=struct('Path',{},'Filename',{},'Settings',{},'AppsName',{},'Label',struct('ListText',{}));

% Filename and Path store the path to the code file that is being
% used for the Apps. 

% Settings stores the Settings of each individual Apps. It is a structure
% whose elements are chosen by the GetSettings function of each Apps.

% AppsName stores the name of each individual Apps

% Label store the text values associated with various labelling text