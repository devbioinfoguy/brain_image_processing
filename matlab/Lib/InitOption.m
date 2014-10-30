% This function is to initialize (or re-initialize) the display options 
% That are used to generate the display as well as other things
function InitOption()

% SpikeOption store all the display option that can be User-specific and
% are possibly meant to be saved for later used
global SpikeOption;

% Please look into SpikeE_Options.fig to see the meaning of these
% variables. When the choice are Yes or No, Yes is 1 and No is 2
SpikeOption.DisplayTraceTimeBar=1;
SpikeOption.DisplayMovie3D=2;

% Default option on Image and Movie display is to have X and Y of the same
% scale
SpikeOption.DisplayImageXYRatio=2;
SpikeOption.DisplayMovieXYRatio=2;

SpikeOption.DisplayMovieAxis=1;
SpikeOption.DisplayImageAxis=1;
SpikeOption.DisplayTraceAxis=1;
SpikeOption.DisplayMovieTitle=1;
SpikeOption.DisplayImageTitle=1;
SpikeOption.DisplayTraceTitle=1;
SpikeOption.RelativeHeightTrace=3;
SpikeOption.LinkAxis=1;