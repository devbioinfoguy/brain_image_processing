function varargout = Subtract_Trace_From_Trace(varargin)
% SUBTRACT_TRACE_FROM_TRACE This App subtracts a given set of traces from
% another set of given traces.
%
% result = base trace - trace to subtract
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Subtract_Trace_From_Trace

% Last Modified by GUIDE v2.5 25-May-2012 18:18:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Subtract_Trace_From_Trace_OpeningFcn, ...
                   'gui_OutputFcn',  @Subtract_Trace_From_Trace_OutputFcn, ...
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


% This function is created by GUIDE for every GUI. Just put here all
% the code that you want to be executed before the GUI is made visible. 
function Subtract_Trace_From_Trace_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Subtract_Trace_From_Trace (see VARARGIN)

% Choose default command line output for Subtract_Trace_From_Trace
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeTraceData

numberTraces=length(SpikeTraceData);

if ~isempty(SpikeTraceData)
    for i=1:numberTraces
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.TraceSelector,'String',TextTrace);
    set(handles.SubTraceSelector, 'String', TextTrace);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.TraceSelector,'Value',intersect(1:numberTraces, Settings.TraceSelectorValue));
    set(handles.SubTraceSelector,'Value',intersect(1:numberTraces, Settings.SubTraceSelectorValue));
    set(handles.KeepTraces, 'Value', Settings.KeepTracesValue);
    set(handles.KeepSubTraces, 'Value', Settings.KeepSubTracesValue);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');
Settings.KeepTracesValue=get(handles.KeepTraces, 'Value');
Settings.SubTraceSelectorValue=get(handles.SubTraceSelector,'Value');
Settings.KeepSubTracesValue=get(handles.KeepSubTraces, 'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Subtract_Trace_From_Trace_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.output;


% 'ApplyApps' is the main function of your Apps. It is launched by the
% Main interface when using batch mode. 
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SpikeTraceData;


try
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    % get parameters from interface
    baseTraces=get(handles.TraceSelector, 'Value');
    subTraces=get(handles.SubTraceSelector, 'Value');
    if length(baseTraces)~=length(subTraces)
        error('List of base traces and list of traces to subtract are not the same length')
    end
    keepSubTraces=get(handles.KeepSubTraces, 'Value');
    keepBaseTraces=get(handles.KeepTraces, 'Value');
    if keepBaseTraces && keepSubTraces
        numTraces=length(SpikeTraceData);
    end
    needToDeleteSubs=0;

    
    for i=1:length(baseTraces)
        baseTraceInd=baseTraces(i);
        subTraceInd=subTraces(i);
        if length(SpikeTraceData(baseTraceInd).Trace)~=length(SpikeTraceData(subTraceInd).Trace)
            error('Traces are not same length')
        else
            resultTrace=SpikeTraceData(baseTraceInd).Trace-SpikeTraceData(subTraceInd).Trace;
        end
        if keepBaseTraces && keepSubTraces
            SpikeTraceData(numTraces+i)=SpikeTraceData(baseTraceInd);
            saveInd=numTraces+i;
        elseif keepBaseTraces
            SpikeTraceData(subTraceInd)=SpikeTraceData(baseTraceInd);
            saveInd=subTraceInd;
        else
            saveInd=baseTraceInd;
            if ~needToDeleteSubs && ~keepSubTraces
                needToDeleteSubs=1;
            end
        end
        SpikeTraceData(saveInd).Trace=resultTrace;
        SpikeTraceData(saveInd).Label.ListText=[SpikeTraceData(baseTraceInd).Label.ListText...
            ' minus ' SpikeTraceData(subTraceInd).Label.ListText];
    end
    
    for i=1:length(subTraces)
        subTrInd=subTraces(i);
        SpikeTraceData(subTrInd)=[];
        subTraces=subTraces-1;
    end
    
    % We turn back on the interface
    set(InterfaceObj,'Enable','on');
    
    ValidateValues_Callback(hObject, eventdata, handles);
    
% In case of errors
catch errorObj
    % We turn back on the interface
    set(InterfaceObj,'Enable','on');
    
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
end


% 'ValidateValues' is executed in the end to trigger the end of your Apps and
% check all unneeded windows are closed.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% We give back control to the Main interface.
uiresume;


% This function opens the help that is written in the header of this M file.
function OpenHelp_Callback(hObject, eventdata, handles)
% hObject    handle to OpenHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CurrentMfilePath = mfilename('fullpath');
[PathToM, name, ext] = fileparts(CurrentMfilePath);
eval(['doc ',name]);



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


% --- Executes on button press in KeepTraces.
function KeepTraces_Callback(hObject, eventdata, handles)
% hObject    handle to KeepTraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KeepTraces



% --- Executes on selection change in SubTraceSelector.
function SubTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to SubTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SubTraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SubTraceSelector


% --- Executes during object creation, after setting all properties.
function SubTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SubTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in KeepSubTraces.
function KeepSubTraces_Callback(hObject, eventdata, handles)
% hObject    handle to KeepSubTraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KeepSubTraces
