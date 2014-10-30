function varargout = Cut_Traces_From_Binary(varargin)
% CUT_TRACES_FROM_BINARY This App aligns one or more traces to points given in the
% binary alignment trace. Any point in the alignment trace with a 1 will be
% an alignment point, and all trace fragments surrounding an alignment
% point will be laid on top of one another. Useful for traces which contain
% multiple repeats of the same experiment, cue, or action.
%
% Output will save as many traces as are input; each will be of length (#
% frames before) + 1 + (# frames after), as set in the GUI.
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Cut_Traces_From_Binary

% Last Modified by GUIDE v2.5 14-Jun-2012 18:35:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Cut_Traces_From_Binary_OpeningFcn, ...
                   'gui_OutputFcn',  @Cut_Traces_From_Binary_OutputFcn, ...
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
function Cut_Traces_From_Binary_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Cut_Traces_From_Binary (see VARARGIN)

% Choose default command line output for Cut_Traces_From_Binary
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeTraceData

if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.TraceSelector,'String',TextTrace);
    set(handles.OnOffTraceSelector, 'String', TextTrace);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.TraceSelector,'String',Settings.TraceSelectorString);
    set(handles.TraceSelector,'Value',Settings.TraceSelectorValue);
    set(handles.KeepTraces, 'Value', Settings.KeepTracesValue);
    set(handles.OnOffTraceSelector,'String',Settings.OnOffTraceSelectorString);
    set(handles.OnOffTraceSelector,'Value',Settings.OnOffTraceSelectorValue);
    set(handles.KeepOnOffTrace, 'Value', Settings.KeepOnOffTraceValue);
    set(handles.TimeStart, 'String', Settings.TimeStartString);
    set(handles.TimeEnd, 'String', Settings.TimeEndString);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorString=get(handles.TraceSelector,'String');
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');
Settings.KeepTracesValue=get(handles.KeepTraces, 'Value');
Settings.OnOffTraceSelectorString=get(handles.OnOffTraceSelector,'String');
Settings.OnOffTraceSelectorValue=get(handles.OnOffTraceSelector,'Value');
Settings.KeepOnOffTraceValue=get(handles.KeepOnOffTrace, 'Value');
Settings.TimeStartString=get(handles.TimeStart, 'String');
Settings.TimeEndString=get(handles.TimeEnd, 'String');



% --- Outputs from this function are returned to the command line.
function varargout = Cut_Traces_From_Binary_OutputFcn(hObject, eventdata, handles) 
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

global SpikeTraceData

try
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    % get parameters from interface
    tracesToAlign=get(handles.TraceSelector, 'Value');
    alignTraceInd=get(handles.OnOffTraceSelector, 'Value');
    keepAlignTrace=get(handles.KeepOnOffTrace, 'Value');
    alignTrace=SpikeTraceData(alignTraceInd).Trace;
    keepTraces=get(handles.KeepTraces, 'Value');
    if keepTraces && keepAlignTrace
        numTraces=length(SpikeTraceData);
    end
    secPerFrame=SpikeTraceData(tracesToAlign(1)).XVector(2)-SpikeTraceData(tracesToAlign(1)).XVector(1);
    timeStart=round(1/secPerFrame*str2double(get(handles.TimeStart, 'String')));
    timeEnd=round(1/secPerFrame*str2double(get(handles.TimeEnd, 'String')));
    
    for i=1:length(tracesToAlign)
        traceInd=tracesToAlign(i);
        thisTrace=SpikeTraceData(traceInd).Trace;
        if length(thisTrace)~=length(alignTrace)
            error('Traces are not same length')
        else
            alignPoints=find(alignTrace==1);
            if size(alignPoints,1)>1
                alignPoints=alignPoints';
            end
            alignPoints(alignPoints<timeStart)=[];
            alignPoints(alignPoints>timeEnd)=[];
            cutTrace=thisTrace(alignPoints);
        end
        if keepTraces
            SpikeTraceData(numTraces+i)=SpikeTraceData(traceInd);
            saveInd=numTraces+i;
        else
            saveInd=traceInd;
        end
        SpikeTraceData(saveInd).Trace=cutTrace;
        SpikeTraceData(saveInd).XVector=secPerFrame*(1:length(cutTrace));
        SpikeTraceData(saveInd).DataSize=length(cutTrace);
        SpikeTraceData(saveInd).Label.ListText=['cut ' SpikeTraceData(traceInd).Label.ListText];
    end
    
    if ~keepAlignTrace
        SpikeTraceData(alignTraceInd)=[];
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



% --- Executes on selection change in OnOffTraceSelector.
function OnOffTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to OnOffTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OnOffTraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OnOffTraceSelector


% --- Executes during object creation, after setting all properties.
function OnOffTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OnOffTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in KeepOnOffTrace.
function KeepOnOffTrace_Callback(hObject, eventdata, handles)
% hObject    handle to KeepOnOffTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KeepOnOffTrace



function TimeStart_Callback(hObject, eventdata, handles)
% hObject    handle to TimeStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeStart as text
%        str2double(get(hObject,'String')) returns contents of TimeStart as a double


% --- Executes during object creation, after setting all properties.
function TimeStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeEnd_Callback(hObject, eventdata, handles)
% hObject    handle to TimeEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeEnd as text
%        str2double(get(hObject,'String')) returns contents of TimeEnd as a double


% --- Executes during object creation, after setting all properties.
function TimeEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
