% This function is to initialize (or re-initialize) the data that are
% shared between functions and with Apps
function InitTraces()

% SpikeTraceData is shared with all Apps
% it is a structure that gather all datas
% SpikeTraceData can be repeated along its first dimensions 
% Each element will be one Trace.
global SpikeTraceData;

SpikeTraceData=struct('Path',{},'Filename',{},'Trace',{},...
    'DataSize',{},'XVector',{},'Label',struct('ListText',{},'XLabel',{},'YLabel',{}), 'ID', {});

% Filename and Path store the path to the original file from which the data is coming from

% Trace is the actual data in its current state. Size is T where 
% T is number of values in Trace. T can be along time or along any other
% dimension of interest. Please note that Matlab is not very conservative
% on the line object, ie Trace can 1xN or Nx1. Any Apps should work in both
% configuration.

% DataSize store the size of Trace
% Size is often 2 (ie [1 T] or [T 1]

% XVector store the X values corresponding to the trace value. It is often
% time but can also be any other interesting dimension. Make sure that the
% XLabel match your dimension.
% Size is [1 T] or [T 1]

% Label store the text values associated with various labelling text
