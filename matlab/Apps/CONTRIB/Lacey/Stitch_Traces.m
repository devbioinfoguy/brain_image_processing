function varargout = Stitch_Traces(varargin)
% STITCH_TRACES MATLAB code for Stitch_Traces.fig
%      STITCH_TRACES, by itself, creates a new STITCH_TRACES or raises the existing
%      singleton*.
%
%      H = STITCH_TRACES returns the handle to a new STITCH_TRACES or the handle to
%      the existing singleton*.
%
%      STITCH_TRACES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STITCH_TRACES.M with the given input arguments.
%
%      STITCH_TRACES('Property','Value',...) creates a new STITCH_TRACES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Stitch_Traces_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Stitch_Traces_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Stitch_Traces

% Last Modified by GUIDE v2.5 13-Jun-2012 10:29:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Stitch_Traces_OpeningFcn, ...
                   'gui_OutputFcn',  @Stitch_Traces_OutputFcn, ...
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


% --- Executes just before Stitch_Traces is made visible.
function Stitch_Traces_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Stitch_Traces (see VARARGIN)
global SpikeTraceData;

% Choose default command line output for Stitch_Traces
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Stitch_Traces wait for user response (see UIRESUME)
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
    set(handles.OutputTrace,'Value',Settings.OutputTraceValue);  
else
    set(handles.TraceSelector,'Value',[]);
end
    

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Stitch_Traces_OutputFcn(hObject, eventdata, handles) 
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
    
    traceSel=get(handles.TraceSelector,'Value');
    
    if ~isempty(traceSel)
        
        h=waitbar(0,'Stitching Traces...');
        % We close it in the end
        Cleanup2=onCleanup(@()delete(h));
        
        numTraces=length(SpikeTraceData);
        SpikeTraceData(numTraces+1)=SpikeTraceData(traceSel(1));
        totalTraceLength=0;
        for tr=traceSel
            totalTraceLength=totalTraceLength+length(SpikeTraceData(tr).Trace);
        end
        SpikeTraceData(numTraces+1).Trace=zeros(1,totalTraceLength);
        timeInc=SpikeTraceData(tr).XVector(2)-SpikeTraceData(tr).XVector(1);
        SpikeTraceData(numTraces+1).XVector=timeInc*(1:totalTraceLength);
        SpikeTraceData(numTraces+1).DataSize=[1,totalTraceLength];
        SpikeTraceData(numTraces+1).Label.ListText='stitched trace';
        
        currentInd=1;
        for traceInd=traceSel
            thisTrace=SpikeTraceData(traceInd).Trace;
            SpikeTraceData(numTraces+1).Trace(currentInd:(currentInd+length(thisTrace)-1))=thisTrace;
            currentInd=currentInd+length(thisTrace);
        end
        
        % Deleting old traces if required
        if (get(handles.OutputTrace,'Value')==1)
            SpikeTraceData(traceSel)=[];
        end
    end
    
    ValidateValues_Callback(hObject, eventdata, handles);
    
catch errorObj
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
end

% --- Executes on selection change in traceSelector.
function TraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to traceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns traceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from traceSelector


% --- Executes during object creation, after setting all properties.
function TraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to traceSelector (see GCBO)
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


% --- Executes on selection change in OutputTrace.
function OutputTrace_Callback(hObject, eventdata, handles)
% hObject    handle to OutputTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OutputTrace contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OutputTrace


% --- Executes during object creation, after setting all properties.
function OutputTrace_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OutputTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
