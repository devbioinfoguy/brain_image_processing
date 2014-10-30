function varargout = Traces_Time_Multiply(varargin)
% TRACES_TIME_MULTIPLY MATLAB code for Traces_Time_Multiply.fig
%      TRACES_TIME_MULTIPLY, by itself, creates a new TRACES_TIME_MULTIPLY or raises the existing
%      singleton*.
%
%      H = TRACES_TIME_MULTIPLY returns the handle to a new TRACES_TIME_MULTIPLY or the handle to
%      the existing singleton*.
%
%      TRACES_TIME_MULTIPLY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACES_TIME_MULTIPLY.M with the given input arguments.
%
%      TRACES_TIME_MULTIPLY('Property','Value',...) creates a new TRACES_TIME_MULTIPLY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Traces_Time_Multiply_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Traces_Time_Multiply_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Traces_Time_Multiply

% Last Modified by GUIDE v2.5 02-Nov-2012 17:24:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Traces_Time_Multiply_OpeningFcn, ...
                   'gui_OutputFcn',  @Traces_Time_Multiply_OutputFcn, ...
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


% --- Executes just before Traces_Time_Multiply is made visible.
function Traces_Time_Multiply_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Traces_Time_Multiply (see VARARGIN)
global SpikeTraceData;

% Choose default command line output for Traces_Time_Multiply
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Traces_Time_Multiply wait for user response (see UIRESUME)
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
    set(handles.TimeMultFactor,'String',num2str(Settings.TimeMultFactorValue));
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
Settings.TimeMultFactorValue=str2double(get(handles.TimeMultFactor,'String'));


% --- Outputs from this function are returned to the command line.
function varargout = Traces_Time_Multiply_OutputFcn(hObject, eventdata, handles) 
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
    
    MultFactor=str2double(get(handles.TimeMultFactor,'String'));
    

    
    NumberSelTraces=length(TraceSel);
    CurrentSize=SpikeTraceData(TraceSel(1)).DataSize;
        
    % waitbar is consuming too much ressources, so I divide its acces
    dividerWaitbar=10^(floor(log10(NumberSelTraces))-1);
    
    
    
    % We check the homogeneity of siee
    for i=1:numel(TraceSel)
        TraceNumber=TraceSel(i);
                
        SpikeTraceData(TraceNumber).XVector=SpikeTraceData(TraceNumber).XVector*MultFactor;
               
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
