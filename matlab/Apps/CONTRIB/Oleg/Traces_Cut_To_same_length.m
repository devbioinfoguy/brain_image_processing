function varargout = Traces_Cut_To_same_length(varargin)
% TRACES_CUT_TO_SAME_LENGTH MATLAB code for Traces_Cut_To_same_length.fig
%      TRACES_CUT_TO_SAME_LENGTH, by itself, creates a new TRACES_CUT_TO_SAME_LENGTH or raises the existing
%      singleton*.
%
%      H = TRACES_CUT_TO_SAME_LENGTH returns the handle to a new TRACES_CUT_TO_SAME_LENGTH or the handle to
%      the existing singleton*.
%
%      TRACES_CUT_TO_SAME_LENGTH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACES_CUT_TO_SAME_LENGTH.M with the given input arguments.
%
%      TRACES_CUT_TO_SAME_LENGTH('Property','Value',...) creates a new TRACES_CUT_TO_SAME_LENGTH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Traces_Cut_To_same_length_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Traces_Cut_To_same_length_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Traces_Cut_To_same_length

% Last Modified by GUIDE v2.5 02-Nov-2012 18:29:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Traces_Cut_To_same_length_OpeningFcn, ...
                   'gui_OutputFcn',  @Traces_Cut_To_same_length_OutputFcn, ...
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


% --- Executes just before Traces_Cut_To_same_length is made visible.
function Traces_Cut_To_same_length_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Traces_Cut_To_same_length (see VARARGIN)
global SpikeTraceData;

% Choose default command line output for Traces_Cut_To_same_length
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Traces_Cut_To_same_length wait for user response (see UIRESUME)
% uiwait(handles.figure1);
NumberTraces=length(SpikeTraceData);

if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.TraceSelector,'String',TextTrace);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.TraceSelector,'Value',intersect(1:NumberTraces,Settings.TraceSelectorValue));
    set(handles.SelectAllTraces,'Value',Settings.SelectAllTracesValue);
else
    set(handles.TraceSelector,'Value',[]);
end

SelectAllTraces_Callback(hObject, eventdata, handles);


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');
Settings.SelectAllTracesValue=get(handles.SelectAllTraces,'Value');
Settings.TracesValue=get(handles.SelectAllTraces,'Value');



% --- Outputs from this function are returned to the command line.
function varargout = Traces_Cut_To_same_length_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ValidateValues.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeTraceData;
global SpikeImageData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
        % We turn it back on in the end
    Cleanup1=onCleanup(@()set(InterfaceObj,'Enable','on'));

    h=waitbar(0,'Creating iamge...');
    
    % We close it in the end
    Cleanup2=onCleanup(@()delete(h));
    
    if (get(handles.SelectAllTraces,'Value')==1)
        TraceSel=1:length(SpikeTraceData);
    else
        TraceSel=get(handles.TraceSelector,'Value');
    end
    
    NumberSelTraces=length(TraceSel);
    CurrentSize=SpikeTraceData(TraceSel(1)).DataSize;
        
    % waitbar is consuming too much ressources, so I divide its access
    dividerWaitbar=10^(floor(log10(NumberSelTraces))-1);
    
    % Need to cut traces from max time of the beginning to minimum time of
    % end. Finding start and end time. Also finding the minimum time step.
    MaxStartTime=SpikeTraceData(TraceSel(1)).XVector(1);
    MinEndTime=SpikeTraceData(TraceSel(1)).XVector(end);
    MinTimeStep=SpikeTraceData(TraceSel(1)).XVector(2)-SpikeTraceData(TraceSel(1)).XVector(1);
    for i=1:numel(TraceSel)
        TraceNumber=TraceSel(i);
        EndTime=SpikeTraceData(TraceNumber).XVector(end);
        StartTime=SpikeTraceData(TraceNumber).XVector(1);
        TimeStep=SpikeTraceData(TraceNumber).XVector(2)-SpikeTraceData(TraceNumber).XVector(1);
        if(EndTime<MinEndTime)
           MinEndTime=EndTime;
        end
        if(StartTime>MaxStartTime)
           MaxStartTime=StartTime;
        end
        if(TimeStep<MinTimeStep)
           MinTimeStep=TimeStep;
        end
    end
    
    NewTimeVector=MaxStartTime:MinTimeStep:MinEndTime;
    
    for i=1:numel(TraceSel)
        TraceNumber=TraceSel(i);
                
        yi = interp1(SpikeTraceData(TraceNumber).XVector,SpikeTraceData(TraceNumber).Trace,NewTimeVector,'linear');
        
        SpikeTraceData(TraceNumber).XVector=NewTimeVector;
        SpikeTraceData(TraceNumber).Trace=yi';
               
        if (round(i/dividerWaitbar)==i/dividerWaitbar)
            waitbar(i/NumberSelTraces,h);
        end
    end
    
    ValidateValues_Callback(hObject, eventdata, handles);
    
catch errorObj
    % If there is a problem, we display the error message and bring back
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
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


% --- Executes during object creation, after setting all properties.
function ValidateValues_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in SelectAllTraces.
function SelectAllTraces_Callback(hObject, eventdata, handles)
% hObject    handle to SelectAllTraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SelectAllTraces
if (get(handles.SelectAllTraces,'Value')==1)
    set(handles.TraceSelector,'Enable','off');
else
    set(handles.TraceSelector,'Enable','on');
end


% --- Executes on selection change in NormalizationMode.
function NormalizationMode_Callback(hObject, eventdata, handles)
% hObject    handle to NormalizationMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NormalizationMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NormalizationMode
if (get(handles.NormalizationMode,'Value')==1)
    set(handles.TimeMultFactor,'Enable','on');
else
    set(handles.TimeMultFactor,'Enable','off');
end



% --- Executes during object creation, after setting all properties.
function NormalizationMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NormalizationMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeMultFactor_Callback(hObject, eventdata, handles)
% hObject    handle to TimeMultFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeMultFactor as text
%        str2double(get(hObject,'String')) returns contents of TimeMultFactor as a double


% --- Executes during object creation, after setting all properties.
function TimeMultFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeMultFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
