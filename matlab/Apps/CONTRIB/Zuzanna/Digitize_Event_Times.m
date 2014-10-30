function varargout = Digitize_Event_Times(varargin)
% DIGITIZE_EVENT_TIMES M-file for Digitize_Event_Times.fig
%      DIGITIZE_EVENT_TIMES, by itself, creates a new DIGITIZE_EVENT_TIMES or raises the existing
%      singleton*.
%
%      H = DIGITIZE_EVENT_TIMES returns the handle to a new DIGITIZE_EVENT_TIMES or the handle to
%      the existing singleton*.
%
%      DIGITIZE_EVENT_TIMES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIGITIZE_EVENT_TIMES.M with the given input arguments.
%
%      DIGITIZE_EVENT_TIMES('Property','Value',...) creates a new DIGITIZE_EVENT_TIMES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Digitize_Event_Times_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Digitize_Event_Times_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Digitize_Event_Times

% Last Modified by GUIDE v2.5 30-Apr-2012 16:24:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Digitize_Event_Times_OpeningFcn, ...
                   'gui_OutputFcn',  @Digitize_Event_Times_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Digitize_Event_Times is made visible.
function Digitize_Event_Times_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Digitize_Event_Times (see VARARGIN)

% Choose default command line output for Digitize_Event_Times
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Digitize_Event_Times wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global SpikeTraceData;


if (length(varargin)>1)
    Settings=varargin{2};
    %     set(handles.TraceSelectorOld,'String',Settings.TraceSelectorString);
%     set(handles.TraceSelectorOld,'Value',Settings.TraceSelectorValue);
    set(handles.Binsize,'String',Settings.BinsizeString);
       
end

TextTrace{1}='All Traces';
if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i+1}=['Trace ',num2str(i)];
    end
    set(handles.TraceSelector,'String',TextTrace);
end


% --- Outputs from this function are returned to the command line.
function varargout = Digitize_Event_Times_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorString=get(handles.TraceSelector,'String');
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');
Settings.BinsizeString=get(handles.Binsize,'String');



% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeTraceData;

if (get(handles.TraceSelector,'Value')==1)
    TracesToApply=1:length(SpikeTraceData);
else
    TracesToApply=get(handles.TraceSelector,'Value')-1;
end

%%%%%%%%%%%%%

binsize=str2double(get(handles.Binsize,'String'))/1000; %convert binsize to sec

BeginTrace=length(SpikeTraceData)+1;
n=0; %new trace counter

h=waitbar(0,'Digitizing...');
for k=TracesToApply

binned_events=Digitize(SpikeTraceData(k).XVector,binsize,handles);

%MODIF:
SpikeTraceData(BeginTrace+n).XVector=0:binsize:binsize*(length(binned_events)-1);
SpikeTraceData(BeginTrace+n).Trace=binned_events;
SpikeTraceData(BeginTrace+n).DataSize=length(binned_events);

name='binned events';
SpikeTraceData(BeginTrace+n).Label.ListText=name;
SpikeTraceData(BeginTrace+n).Label.YLabel='nb of events';
SpikeTraceData(BeginTrace+n).Label.XLabel=SpikeTraceData(k).Label.XLabel;
SpikeTraceData(BeginTrace+n).Filename=SpikeTraceData(k).Filename;
SpikeTraceData(BeginTrace+n).Path=SpikeTraceData(k).Path;


n=n+1;
waitbar(k/length(TracesToApply));
 
end

close(h);
ValidateValues_Callback(hObject, eventdata, handles);


% this function does the big job, ie creating a vector containing in each
% bin (of binsize seconds) the number of events (based on XVector of event times, ie 'events')

function binned_events=Digitize(events,binsize,handles)

last_time=events(end);
start_time=events(1);
bin_nb = floor((last_time-start_time+1)/binsize)+1;

binned_events=zeros(bin_nb,1);

bins_with_event = floor(events/binsize);
first_bin_with_event=floor(start_time/binsize);

if bins_with_event(1)<0
 
   for k=1:length(bins_with_event)
    binned_events(bins_with_event(k)-first_bin_with_event+1)=binned_events(bins_with_event(k)-first_bin_with_event+1)+1;
end; 
    
else

for k=1:length(bins_with_event)
    binned_events(bins_with_event(k)+1)=binned_events(bins_with_event(k)+1)+1;
end;

end;



% --- Executes on button press in ValidateValues.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;



function Binsize_Callback(hObject, eventdata, handles)
% hObject    handle to Binsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Binsize as text
%        str2double(get(hObject,'String')) returns contents of Binsize as a double


% --- Executes during object creation, after setting all properties.
function Binsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Binsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in TraceSelector.
function TraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to TraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TraceSelector


% --- Executes during object creation, after setting all properties.
function TraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on TraceSelector and none of its controls.
function TraceSelector_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to TraceSelector (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
