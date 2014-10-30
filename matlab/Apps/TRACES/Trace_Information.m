function varargout = Trace_Information(varargin)
% TRACE_INFORMATION MATLAB code for Trace_Information.fig
%      TRACE_INFORMATION, by itself, creates a new TRACE_INFORMATION or raises the existing
%      singleton*.
%
%      H = TRACE_INFORMATION returns the handle to a new TRACE_INFORMATION or the handle to
%      the existing singleton*.
%
%      TRACE_INFORMATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACE_INFORMATION.M with the given input arguments.
%
%      TRACE_INFORMATION('Property','Value',...) creates a new TRACE_INFORMATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Trace_Information_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Trace_Information_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Trace_Information

% Last Modified by GUIDE v2.5 06-Mar-2012 15:17:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Trace_Information_OpeningFcn, ...
                   'gui_OutputFcn',  @Trace_Information_OutputFcn, ...
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


% --- Executes just before Trace_Information is made visible.
function Trace_Information_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Trace_Information (see VARARGIN)
global SpikeTraceData;

% Choose default command line output for Trace_Information
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Trace_Information wait for user response (see UIRESUME)
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
    NewTraceValue=intersect(1:NumberTraces,Settings.TraceSelectorValue);
    if isempty(NewTraceValue)
        NewTraceValue=1;
    end
    set(handles.TraceSelector,'Value',NewTraceValue);
end

UpdateInfoDisplay(handles);


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');


% This function does the job, ie updating info displyed based on selected
% movie
function UpdateInfoDisplay(handles)
global SpikeTraceData;

if ~isempty(SpikeTraceData)
    SelectTrace=get(handles.TraceSelector,'Value');
    set(handles.XVectPeriod,'String',num2str(mean(diff(SpikeTraceData(SelectTrace).XVector))));
    set(handles.PointNumber,'String',num2str(max(SpikeTraceData(SelectTrace).DataSize)));
    set(handles.MemClassTrace,'String',class(SpikeTraceData(SelectTrace).Trace));
    LocalSize=whos('SpikeTraceData');
    set(handles.AllTracesMem,'String',num2str(LocalSize.bytes/8/10^6));
    set(handles.PathToFile,'String',SpikeTraceData(SelectTrace).Path);
    set(handles.FileName,'String',SpikeTraceData(SelectTrace).Filename);
    set(handles.TotalTraceDistance,'String',num2str(max(SpikeTraceData(SelectTrace).XVector)-min(SpikeTraceData(SelectTrace).XVector)));
    set(handles.XLabel,'String',SpikeTraceData(SelectTrace).Label.XLabel);
    set(handles.YLabel,'String',SpikeTraceData(SelectTrace).Label.YLabel);
end


% --- Outputs from this function are returned to the command line.
function varargout = Trace_Information_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on selection change in TraceSelector.
function TraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to TraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TraceSelector
UpdateInfoDisplay(handles);


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


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    UpdateInfoDisplay(handles);
    ValidateValues_Callback(hObject, eventdata, handles);
    set(InterfaceObj,'Enable','on');
    
catch errorObj
    set(InterfaceObj,'Enable','on');
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
end
