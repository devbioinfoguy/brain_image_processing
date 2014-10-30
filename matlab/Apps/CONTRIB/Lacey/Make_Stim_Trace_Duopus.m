function varargout = Make_Stim_Trace_Duopus(varargin)
% MAKE_STIM_TRACE_DUOPUS This App aligns one or more traces to points given in the
% binary alignment trace. Any point in the alignment trace with a 1 will be
% an alignment point, and all trace fragments surrounding an alignment
% point will be laid on top of one another. Useful for traces which contain
% multiple repeats of the same experiment, cue, or action.
%
% Output will save as many traces as are input; each will be of length (#
% frames before) + 1 + (# frames after), as set in the GUI.
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Make_Stim_Trace_Duopus

% Last Modified by GUIDE v2.5 23-Jul-2012 11:10:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Make_Stim_Trace_Duopus_OpeningFcn, ...
                   'gui_OutputFcn',  @Make_Stim_Trace_Duopus_OutputFcn, ...
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
function Make_Stim_Trace_Duopus_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Make_Stim_Trace_Duopus (see VARARGIN)

% Choose default command line output for Make_Stim_Trace_Duopus
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeTraceData

if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.Ch3TraceSelector,'String',TextTrace);
    set(handles.PsychStimTraceSelector, 'String', TextTrace);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.Ch3TraceSelector,'Value',Settings.Ch3TraceSelectorValue);
    set(handles.PsychStimTraceSelector,'Value',Settings.PsychStimTraceSelectorValue);
    set(handles.KeepCh3Trace, 'Value', Settings.KeepCh3TraceValue);
    set(handles.KeepStimTrace, 'Value', Settings.KeepStimTraceValue);
    set(handles.Ch3Thresh, 'String', Settings.Ch3ThreshString);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.Ch3TraceSelectorValue=get(handles.Ch3TraceSelector,'Value');
Settings.PsychStimTraceSelectorValue=get(handles.PsychStimTraceSelector,'Value');
Settings.KeepCh3TraceValue=get(handles.KeepCh3Trace, 'Value');
Settings.KeepStimTraceValue=get(handles.KeepStimTrace, 'Value');
Settings.Ch3ThreshString=get(handles.Ch3Thresh, 'String');

% --- Outputs from this function are returned to the command line.
function varargout = Make_Stim_Trace_Duopus_OutputFcn(hObject, eventdata, handles) 
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
    ch3TraceInd=get(handles.Ch3TraceSelector, 'Value');
    ch3Trace=SpikeTraceData(ch3TraceInd).Trace;
    psychStimTraceInd=get(handles.PsychStimTraceSelector, 'Value');
    psychStimTrace=SpikeTraceData(psychStimTraceInd).Trace;
    keepStimTrace=get(handles.KeepStimTrace, 'Value');
    keepCh3Trace=get(handles.KeepCh3Trace, 'Value');
    secPerFrame=SpikeTraceData(ch3TraceInd).XVector(2)-SpikeTraceData(ch3TraceInd).XVector(1);
    approxOffsetFrames=round(1/secPerFrame*str2double(get(handles.ApproxOffset, 'String')));
    thresh=str2double(get(handles.Ch3Thresh, 'String'));
    
    newStimTrace=-45*ones(size(ch3Trace));
    while ~isempty(find(ch3Trace>thresh,1))
        beginInd=find(ch3Trace>thresh, 1, 'first');
        lastInd=find(diff(ch3Trace>thresh)==-1, 1, 'first');
        psychStimBeginInd=find(psychStimTrace>-1, 1, 'first');
        psychStimLastInd=find(diff(psychStimTrace>-1)==-1, 1, 'first');
        angleVal=psychStimTrace(psychStimBeginInd+1);
        newStimTrace(beginInd:lastInd)=angleVal;
        ch3Trace(beginInd:lastInd)=0;
        psychStimTrace(psychStimBeginInd:psychStimLastInd)=-1;
    end

    numTraces=length(SpikeTraceData);
    SpikeTraceData(numTraces+1)=SpikeTraceData(ch3TraceInd);
    SpikeTraceData(numTraces+1).Trace=newStimTrace;
    SpikeTraceData(numTraces+1).Label.YLabel='angle';
    SpikeTraceData(numTraces+1).Label.ListText=['stim ' SpikeTraceData(ch3TraceInd).Label.ListText];
    
    
    if ~keepCh3Trace && ~keepStimTrace
        SpikeTraceData([ch3TraceInd, psychStimTraceInd])=[];
    elseif ~keepCh3Trace
        SpikeTraceData(ch3TraceInd)=[];
    elseif ~keepStimTrace
        SpikeTraceData(psychStimTraceInd)=[];
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



% --- Executes on selection change in Ch3TraceSelector.
function Ch3TraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to Ch3TraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Ch3TraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Ch3TraceSelector


% --- Executes during object creation, after setting all properties.
function Ch3TraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ch3TraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in KeepCh3Trace.
function KeepCh3Trace_Callback(hObject, eventdata, handles)
% hObject    handle to KeepCh3Trace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KeepCh3Trace



% --- Executes on selection change in PsychStimTraceSelector.
function PsychStimTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to PsychStimTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PsychStimTraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PsychStimTraceSelector


% --- Executes during object creation, after setting all properties.
function PsychStimTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PsychStimTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in KeepStimTrace.
function KeepStimTrace_Callback(hObject, eventdata, handles)
% hObject    handle to KeepStimTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KeepStimTrace



function ApproxOffset_Callback(hObject, eventdata, handles)
% hObject    handle to ApproxOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ApproxOffset as text
%        str2double(get(hObject,'String')) returns contents of ApproxOffset as a double


% --- Executes during object creation, after setting all properties.
function ApproxOffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ApproxOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ch3Thresh_Callback(hObject, eventdata, handles)
% hObject    handle to Ch3Thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ch3Thresh as text
%        str2double(get(hObject,'String')) returns contents of Ch3Thresh as a double


% --- Executes during object creation, after setting all properties.
function Ch3Thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ch3Thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
