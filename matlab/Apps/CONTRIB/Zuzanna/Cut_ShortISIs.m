function varargout = Cut_ShortISIs(varargin)
% CUT_SHORTISIS M-file for Cut_ShortISIs.fig
%      CUT_SHORTISIS, by itself, creates a new CUT_SHORTISIS or raises the existing
%      singleton*.
%
%      H = CUT_SHORTISIS returns the handle to a new CUT_SHORTISIS or the handle to
%      the existing singleton*.
%
%      CUT_SHORTISIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CUT_SHORTISIS.M with the given input arguments.
%
%      CUT_SHORTISIS('Property','Value',...) creates a new CUT_SHORTISIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Cut_ShortISIs_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Cut_ShortISIs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Cut_ShortISIs

% Last Modified by GUIDE v2.5 07-May-2012 12:18:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Cut_ShortISIs_OpeningFcn, ...
                   'gui_OutputFcn',  @Cut_ShortISIs_OutputFcn, ...
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


% --- Executes just before Cut_ShortISIs is made visible.
function Cut_ShortISIs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Cut_ShortISIs (see VARARGIN)

% Choose default command line output for Cut_ShortISIs
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Cut_ShortISIs wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global SpikeTraceData;

if (length(varargin)>1)
    Settings=varargin{2};
%     set(handles.TraceSelector,'String',Settings.TraceSelectorString);
%     set(handles.TraceSelector,'Value',Settings.TraceSelectorValue);
    set(handles.MinISI,'String',Settings.MinISIString);
    set(handles.Extract,'Value',Settings.ExtractValue);
end

TextTrace{1}='No Traces';
if ~isempty(SpikeTraceData)
    TextTrace{1}='All Traces';
    for i=1:length(SpikeTraceData)
        TextTrace{i+1}=['Trace ',num2str(i)];
    end
    set(handles.TraceSelector,'String',TextTrace);
end
% --- Outputs from this function are returned to the command line.
function varargout = Cut_ShortISIs_OutputFcn(hObject, eventdata, handles) 
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
Settings.MinISIString=get(handles.MinISI,'String');
Settings.ExtractValue=get(handles.Extract,'Value');



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

min_isi=str2double(get(handles.MinISI,'String'))/1000 %convert from ms to s
 
BeginTrace=length(SpikeTraceData)+1;
n=0; %new trace counter

h=waitbar(0,'Cutting short ISIs...');
for k=TracesToApply
    
    [times_def, times_bursts] = cutshortisis(SpikeTraceData(k).XVector,min_isi, handles);
    
    SpikeTraceData(BeginTrace+n).XVector=times_def;
    SpikeTraceData(BeginTrace+n).Trace=ones(size(times_def));
    SpikeTraceData(BeginTrace+n).DataSize=length(times_def);
    
    name='threshold crossings, min isis only';
    SpikeTraceData(BeginTrace+n).Label.ListText=name;
    SpikeTraceData(BeginTrace+n).Label.YLabel='detections';
    SpikeTraceData(BeginTrace+n).Label.XLabel=SpikeTraceData(k).Label.XLabel;
    SpikeTraceData(BeginTrace+n).Filename=SpikeTraceData(k).Filename;
    SpikeTraceData(BeginTrace+n).Path=SpikeTraceData(k).Path;
 
    
    n=n+1;
    if (get(handles.Extract,'Value')==1)
        %store times_bursts in a Trace. todo
        
        SpikeTraceData(BeginTrace+n).XVector=times_bursts;
        SpikeTraceData(BeginTrace+n).Trace=ones(size(times_bursts));
        SpikeTraceData(BeginTrace+n).DataSize=length(times_bursts);
        
        name='burst onsets';
        SpikeTraceData(BeginTrace+n).Label.ListText=name;
        SpikeTraceData(BeginTrace+n).Label.YLabel='detections';
        SpikeTraceData(BeginTrace+n).Label.XLabel=SpikeTraceData(k).Label.XLabel;
        SpikeTraceData(BeginTrace+n).Filename=SpikeTraceData(k).Filename;
        SpikeTraceData(BeginTrace+n).Path=SpikeTraceData(k).Path;

        
        n=n+1;
    end;
    
    waitbar(k/length(TracesToApply));
    
end

close(h);

set(handles.Det_Nb,'String',int2str(SpikeTraceData(BeginTrace+n-1).DataSize));
% ValidateValues_Callback(hObject, eventdata, handles);


% this function does the big job, ie keeping only the events which times
% are at least min_isi apart, and writing them in a new vector of events

function [times_def, times_bursts] = cutshortisis(times,win, handles)

%CUTSHORTISIS 
%  remove from vector of event times times all events that are closer
%  to the preceding one than win ms

% return remaining events in vector times_def
% return times of bursts (=first in a group of events closer apart than win
% ms) in times_bursts

isis = diff(times);

times_def = [];
times_bursts = [];

times_def(end+1)=times(1); 

rem=0; % local counter for removed events, needed to identify true onset of a burst of multiple short ISIs

for n=1:length(isis)
  
  if isis(n)>win
  times_def(end+1) = times(n+1);
  rem=0; %reset counter of short ISIs
  end
  
  if isis(n)<=win
  times_bursts(end+1) = times(n-rem);
  rem=rem+1;
  end
  
end

times_bursts=unique(times_bursts); 



% --- Executes on button press in ValidateValues.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;



function MinISI_Callback(hObject, eventdata, handles)
% hObject    handle to MinISI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinISI as text
%        str2double(get(hObject,'String')) returns contents of MinISI as a double


% --- Executes during object creation, after setting all properties.
function MinISI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinISI (see GCBO)
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

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on button press in Extract.
function Extract_Callback(hObject, eventdata, handles)
% hObject    handle to Extract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Extract



function Det_Nb_Callback(hObject, eventdata, handles)
% hObject    handle to Det_Nb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Det_Nb as text
%        str2double(get(hObject,'String')) returns contents of Det_Nb as a double


% --- Executes during object creation, after setting all properties.
function Det_Nb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Det_Nb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
