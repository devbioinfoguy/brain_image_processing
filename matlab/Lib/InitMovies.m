% This function is to initialize (or re-initialize) the data that are
% shared between functions and with Apps
function InitMovies()

% SpikeMovieData is shared with all Apps
% it is a structure that gather all datas
% SpikeMovieData can be repeated along its first dimensions 
% Each element will be one movie.
global SpikeMovieData;

SpikeMovieData=struct('Path',{},'Filename',{},'Movie',{},'DataSize',{},...
    'TimeFrame',{},'TimePixel',{},'TimePixelUnits',{},'Exposure',{},...
    'Xposition',{},'Yposition',{},'Zposition',{},'Label',struct(...
    'ListText',{},'XLabel',{},'YLabel',{},'ZLabel',{},...
    'CLabel',{}));

% Filename and Path store the path to the original file from which the data is coming from

% Movie is the actual movie data in its current state.
% Size is MxNxCxT where 
% M horizontal pixels
% N vertical pixels
% T Time frames

% DataSize store the size of Movie
% Size is 3

% TimeFrame store the time at which all frame have been acquired in
% seconds. This is the average time for each frame. 
% Size is T

% TimePixel store the time at which pixel is acquired relative to TimeFrame
% values (ie it can be negative or positive if pixel is acquired before or
% after the TimeFrame value). 
% Size is MxNxT

% For memory reduction TimePixel is usually an integer. The precise type
% will depend on the movie loader.
% TimePixelUnits store the conversion ratio to bring it into seconds.
% Size is 1

% SpikeMovieData.Exposure is an array that store the Exposure time for each pixel
% in s
% Size is MxN

% Xposition, Yposition and Zposition are space matrix. They store the
% actual position in space of all pixels.
% Size is MxN

% Label store the text values associated with various labelling text