function varargout = Offset_X_Trace(varargin)
% OFFSET_X_TRACE MATLAB code for Offset_X_Trace.fig
%      OFFSET_X_TRACE, by itself, creates a new OFFSET_X_TRACE or raises the existing
%      singleton*.
%
%      H = OFFSET_X_TRACE returns the handle to a new OFFSET_X_TRACE or the handle to
%      the existing singleton*.
%
%      OFFSET_X_TRACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OFFSET_X_TRACE.M with the given input arguments.
%
%      OFFSET_X_TRACE('Property','Value',...) creates a new OFFSET_X_TRACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Offset_X_Trace_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Offset_X_Trace_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Offset_X_Trace

% Last Modified by GUIDE v2.5 09-Apr-2012 19:14:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Offset_X_Trace_OpeningFcn, ...
                   'gui_OutputFcn',  @Offset_X_Trace_OutputFcn, ...
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


% --- Executes just before Offset_X_Trace is made visible.
function Offset_X_Trace_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Offset_X_Trace (see VARARGIN)
global SpikeTraceData;

% Choose default command line output for Offset_X_Trace
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Offset_X_Trace wait for user response (see UIRESUME)
% uiwait(handles.figure1);
NumberTraces=length(SpikeTraceData);

if ~isempty(SpikeTraceData)
    for i=1:NumberTraces
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.TraceSelector,'String',TextTrace);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.TraceSelector,'Value',intersect(1:NumberTraces,Settings.TraceSelectorValue));
    set(handles.OffsetX,'String',Settings.OffsetXString);
end
    

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');
Settings.OffsetXString=get(handles.OffsetX,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Offset_X_Trace_OutputFcn(hObject, eventdata, handles) 
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

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');

    % We turn it back on in the end
    Cleanup1=onCleanup(@()set(InterfaceObj,'Enable','on'));

    h=waitbar(0,'Adding offset to movie...');
    % We close it in the end
    Cleanup2=onCleanup(@()delete(h));
    
    TraceSel=get(handles.TraceSelector,'Value');
    
    OffsetX=str2double(get(handles.OffsetX,'String'));
    SpikeTraceData(TraceSel).XVector=SpikeTraceData(TraceSel).XVector+OffsetX;
    
    ValidateValues_Callback(hObject, eventdata, handles);
    
catch errorObj
    % If there is a problem, we display the error message
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



function OffsetX_Callback(hObject, eventdata, handles)
% hObject    handle to OffsetX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OffsetX as text
%        str2double(get(hObject,'String')) returns contents of OffsetX as a double


% --- Executes during object creation, after setting all properties.
function OffsetX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OffsetX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
