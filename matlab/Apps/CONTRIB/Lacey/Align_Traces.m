function varargout = Align_Traces(varargin)
% ALIGN_TRACES This App aligns one or more traces to points given in the
% binary alignment trace. Any point in the alignment trace with a 1 will be
% an alignment point, and all trace fragments surrounding an alignment
% point will be laid on top of one another. Useful for traces which contain
% multiple repeats of the same experiment, cue, or action.
%
% Output will save as many traces as are input; each will be of length (#
% frames before) + 1 + (# frames after), as set in the GUI.
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Align_Traces

% Last Modified by GUIDE v2.5 23-Jul-2012 12:37:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Align_Traces_OpeningFcn, ...
                   'gui_OutputFcn',  @Align_Traces_OutputFcn, ...
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
function Align_Traces_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Align_Traces (see VARARGIN)

% Choose default command line output for Align_Traces
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeTraceData

if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.TraceSelector,'String',TextTrace);
    set(handles.AlignTraceSelector, 'String', TextTrace);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.TraceSelector,'Value',Settings.TraceSelectorValue);
    set(handles.KeepTraces, 'Value', Settings.KeepTracesValue);
    set(handles.AlignTraceSelector,'Value',Settings.AlignTraceSelectorValue);
    set(handles.KeepAlignTrace, 'Value', Settings.KeepAlignTraceValue);
    set(handles.TimeBefore, 'String', Settings.TimeBeforeString);
    set(handles.TimeAfter, 'String', Settings.TimeAfterString);
    set(handles.SaveSeparately, 'Value', Settings.SaveSeparatelyValue);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorString=get(handles.TraceSelector,'String');
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');
Settings.AlignTraceSelectorValue=get(handles.AlignTraceSelector,'Value');
Settings.KeepTracesValue=get(handles.KeepTraces, 'Value');
Settings.KeepAlignTraceValue=get(handles.KeepAlignTrace, 'Value');
Settings.TimeBeforeString=get(handles.TimeBefore, 'String');
Settings.TimeAfterString=get(handles.TimeAfter, 'String');
Settings.SaveSeparatelyValue=get(handles.SaveSeparately, 'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Align_Traces_OutputFcn(hObject, eventdata, handles) 
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
    alignTraceInd=get(handles.AlignTraceSelector, 'Value');
    keepAlignTrace=get(handles.KeepAlignTrace, 'Value');
    alignTrace=SpikeTraceData(alignTraceInd).Trace;
    keepTraces=get(handles.KeepTraces, 'Value');
    if keepTraces && keepAlignTrace
        numTraces=length(SpikeTraceData);
    end
    secPerFrame=SpikeTraceData(tracesToAlign(1)).XVector(2)-SpikeTraceData(tracesToAlign(1)).XVector(1);
    timeBefore=round(1/secPerFrame*str2double(get(handles.TimeBefore, 'String')));
    timeAfter=round(1/secPerFrame*str2double(get(handles.TimeAfter, 'String')));
    
    saveSep=get(handles.SaveSeparately, 'Value');
    
    saveIndInc=1;
    alignTimePoints=SpikeTraceData(alignTraceInd).XVector(logical(alignTrace==1));
    if size(alignTimePoints,1)>1
        alignTimePoints=alignTimePoints';
    end
    for i=1:length(tracesToAlign)
        traceInd=tracesToAlign(i);
        thisTrace=SpikeTraceData(traceInd).Trace;
        thisXVec=SpikeTraceData(traceInd).XVector;
        if size(thisTrace,1)==1
            thisTrace=[zeros(1, timeBefore), thisTrace, zeros(1, timeAfter)];
        else
            thisTrace=[zeros(timeBefore, 1); thisTrace; zeros(timeAfter, 1)];
        end
        if size(thisXVec,1)==1
            thisXVec=[zeros(1, timeBefore), thisXVec, zeros(1, timeAfter)];
        else
            thisXVec=[zeros(timeBefore, 1); thisXVec; zeros(timeAfter, 1)];
        end

        alignedTrace=zeros(timeBefore+timeAfter+1, 1);

        thisInd=1;

        if ~isempty(alignTimePoints)
            for alignTime=alignTimePoints
                [~, t]=min(abs(thisXVec-alignTime));
                if ~saveSep
                    alignedTrace=alignedTrace+thisTrace((t-timeBefore):(t+timeAfter));
                else
                    if keepTraces
                        SpikeTraceData(numTraces+saveIndInc)=SpikeTraceData(traceInd);
                        saveInd=numTraces+saveIndInc;
                        saveIndInc=saveIndInc+1;
                    else
                        saveInd=traceInd;
                    end
                    SpikeTraceData(saveInd).Trace=thisTrace((t-timeBefore):(t+timeAfter));
                    SpikeTraceData(saveInd).XVector=secPerFrame*(1:length(alignedTrace));
                    SpikeTraceData(saveInd).DataSize=length(thisTrace((t-timeBefore):(t+timeBefore)));
                    SpikeTraceData(saveInd).Label.ListText=['aligned ' SpikeTraceData(traceInd).Label.ListText, ' ', num2str(thisInd)];
                    thisInd=thisInd+1;
                end
            end
        end
        if ~saveSep
            if keepTraces
                SpikeTraceData(numTraces+i)=SpikeTraceData(traceInd);
                saveInd=numTraces+i;
            else
                saveInd=traceInd;
            end
            SpikeTraceData(saveInd).Trace=alignedTrace;
            SpikeTraceData(saveInd).XVector=secPerFrame*(1:length(alignedTrace));
            SpikeTraceData(saveInd).DataSize=length(alignedTrace);
            SpikeTraceData(saveInd).Label.ListText=['aligned ' SpikeTraceData(traceInd).Label.ListText];
        end
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



% --- Executes on selection change in AlignTraceSelector.
function AlignTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to AlignTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AlignTraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AlignTraceSelector


% --- Executes during object creation, after setting all properties.
function AlignTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AlignTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in KeepAlignTrace.
function KeepAlignTrace_Callback(hObject, eventdata, handles)
% hObject    handle to KeepAlignTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KeepAlignTrace



function TimeBefore_Callback(hObject, eventdata, handles)
% hObject    handle to TimeBefore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeBefore as text
%        str2double(get(hObject,'String')) returns contents of TimeBefore as a double


% --- Executes during object creation, after setting all properties.
function TimeBefore_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeBefore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeAfter_Callback(hObject, eventdata, handles)
% hObject    handle to TimeAfter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeAfter as text
%        str2double(get(hObject,'String')) returns contents of TimeAfter as a double


% --- Executes during object creation, after setting all properties.
function TimeAfter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeAfter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveSeparately.
function SaveSeparately_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSeparately (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SaveSeparately
