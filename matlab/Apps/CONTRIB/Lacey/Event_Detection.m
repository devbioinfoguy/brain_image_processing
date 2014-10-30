function varargout = Event_Detection(varargin)
% EVENT_DETECTION This App is designed for detecting events in a trace,
% such as a trace representing Calcium activity or voltage. It performs no
% shape matching but simply detects when the trace is above a set threshold
% (set in terms of the mean and std of each trace). It has the following
% options:
% - require trace to stay above the threshold for a certain number of
% frames or seconds
% - require trace to have an n-frame average value, over some window which
% contains the peak value, above threshold
% - require that events be some number of frames or seconds apart. This
% option will always rule in favor of the first event.
% - report event time as the time in between peak and trough time (midpoint
% rise time), or as the peak time
%
% The output is a binary trace which contains a 1 at the time of event, and
% a 0 at all other times.
%
% Note: the threshold is set in terms of the peak-to-trough value, rather
% than the absolute value of the trace. Thus, if an event occurs before the
% previous event has finished its exponential falloff, that event must
% raise the trace value by an additional threshold amount relative to the
% previous value.
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Event_Detection

% Last Modified by GUIDE v2.5 25-May-2012 16:24:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Event_Detection_OpeningFcn, ...
                   'gui_OutputFcn',  @Event_Detection_OutputFcn, ...
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
function Event_Detection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Event_Detection (see VARARGIN)

% Choose default command line output for Event_Detection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeTraceData

if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.TraceSelector,'String',TextTrace);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.TraceSelector,'String',Settings.TraceSelectorString);
    set(handles.TraceSelector,'Value',Settings.TraceSelectorValue);
    set(handles.MinTimeAboveThresh, 'String', Settings.MinTimeAboveThreshString);
    set(handles.StdDevs, 'String', Settings.StdDevsString);
    set(handles.TimeAboveUnits, 'Value', Settings.TimeAboveUnitsValue);
    set(handles.OffsetFrames, 'String', Settings.OffsetFramesString);
    set(handles.KeepTraces, 'Value', Settings.KeepTracesValue);
    set(handles.UseAllTraces, 'Value', Settings.UseAllTracesValue);
    set(handles.MinTimeBtEvents, 'String', Settings.MinTimeBtEventsString);
    set(handles.TimeBtEventsUnits, 'Value', Settings.TimeBtEventsUnitsValue);
    set(handles.NumFramesLocalAverage, 'String', Settings.NumFramesLocalAverageString);
    set(handles.ReportMidpoint, 'Value', Settings.ReportMidpointValue);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorString=get(handles.TraceSelector,'String');
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');
Settings.MinTimeAboveThreshString=get(handles.MinTimeAboveThresh, 'String');
Settings.StdDevsString=get(handles.StdDevs, 'String');
Settings.TimeAboveUnitsValue=get(handles.TimeAboveUnits, 'Value');
Settings.OffsetFramesString=get(handles.OffsetFrames, 'String');
Settings.KeepTracesValue=get(handles.KeepTraces, 'Value');
Settings.UseAllTracesValue=get(handles.UseAllTraces, 'Value');
Settings.MinTimeBtEventsString=get(handles.MinTimeBtEvents, 'String');
Settings.TimeBtEventsUnitsValue=get(handles.TimeBtEventsUnits, 'Value');
Settings.NumFramesLocalAverageString=get(handles.NumFramesLocalAverage, 'String');
Settings.ReportMidpointValue=get(handles.ReportMidpoint, 'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Event_Detection_OutputFcn(hObject, eventdata, handles) 
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
    
    h=waitbar(0.05, 'Processing...');
    % get parameters from interface
    if get(handles.UseAllTraces, 'Value')
        tracesToProcess=1:length(SpikeTraceData);
    else
        tracesToProcess=get(handles.TraceSelector, 'Value');
    end
    numStdDevs=str2double(get(handles.StdDevs, 'String'));
    minTimeAbove=str2double(get(handles.MinTimeAboveThresh, 'String'));
    numFramesLocalAverage=str2double(get(handles.NumFramesLocalAverage, 'String'));
    if get(handles.TimeAboveUnits, 'Value')==2
        minTimeAbove=minTimeAbove*...
            (SpikeTraceData(tracesToProcess(1)).XVector(2)...
            -SpikeTraceData(tracesToProcess(1)).XVector(1));
    end
    keepTraces=get(handles.KeepTraces, 'Value');
    if keepTraces
        numTraces=length(SpikeTraceData);
    end
    offsetFrames=str2double(get(handles.OffsetFrames, 'String'));
    minTimeBtEvents=str2double(get(handles.MinTimeBtEvents,'String'));
    if get(handles.TimeAboveUnits, 'Value')==2
        minTimeBtEvents=minTimeBtEvents*...
            (SpikeTraceData(tracesToProcess(1)).XVector(2)...
            -SpikeTraceData(tracesToProcess(1)).XVector(1));
    end
    

    waitbarInterval=round(length(tracesToProcess)/10);
    % find crossings of appropriate length, shift, and save
    for i=1:length(tracesToProcess)
        if mod(i,waitbarInterval)==0
            waitbar(i/length(tracesToProcess), h)
        end
        origTraceInd=tracesToProcess(i);
        thisTrace=SpikeTraceData(origTraceInd).Trace;
        thisThresh=mean(thisTrace)+std(thisTrace)*numStdDevs;
        crossings=diff(thisTrace>thisThresh);
        if minTimeAbove>1
            eventTimes=strfind(crossings(:)', [1 zeros(1, minTimeAbove-1)]);
        else
            eventTimes=find(crossings==1);
        end
        % make convolved moving avg trace
        movAvgTrace=1/numFramesLocalAverage*conv(thisTrace, ones(numFramesLocalAverage,1), 'same');
        movAvgTrace=movAvgTrace>thisThresh;
        for j=1:length(eventTimes)
           timeCrossAbove=eventTimes(j);
           % find peak
           timeCrossBelow=find(crossings(timeCrossAbove+1:min(timeCrossAbove+200, length(crossings)))...
               ==-1,1)+timeCrossAbove;
           [~, peakTime]=max(thisTrace(timeCrossAbove:timeCrossBelow));
           peakTime=peakTime+timeCrossAbove-1;
           if ~isempty(peakTime) && sum(movAvgTrace(max(peakTime-numFramesLocalAverage,1):min(peakTime+numFramesLocalAverage,length(movAvgTrace))))>0
               % find trough
               troughTime=find(thisTrace(max(timeCrossAbove-100,1):timeCrossAbove)<mean(thisTrace), 1, 'last');
               if ~isempty(troughTime)
                   troughTime=max(timeCrossAbove-100,1)+troughTime-1;
                   % make sure trough to peak is higher than thresh, else eliminate
                   if thisTrace(peakTime)-thisTrace(troughTime)<thisThresh
                       eventTimes(j)=0;
                   else
                       % report midpoint rise time as event time
                       if get(handles.ReportMidpoint, 'Value')
                           eventTimes(j)=troughTime+floor((peakTime-troughTime)/2);
                       else
                           eventTimes(j)=peakTime;
                       end
                       % eliminate it if the one before was <minTimeBtEvents
                       if j>1 && (eventTimes(j)-eventTimes(j-1)<minTimeBtEvents)
                           eventTimes(j)=0;
                       end
                   end
               else
                   eventTimes(j)=0;
               end
           else
               eventTimes(j)=0;
           end
        end
        eventTimes=eventTimes(eventTimes~=0);
        eventTimes=eventTimes-offsetFrames+1;
        eventTimes(eventTimes<1)=[];
        indicatorTrace=zeros(size(thisTrace));
        indicatorTrace(eventTimes)=1;
        if keepTraces
            saveInd=numTraces+i;
            SpikeTraceData(saveInd)=SpikeTraceData(origTraceInd);
        else
            saveInd=origTraceInd;
        end
        SpikeTraceData(saveInd).Trace=indicatorTrace;
        SpikeTraceData(saveInd).Label.YLabel='Event';
        SpikeTraceData(saveInd).Label.ListText=[SpikeTraceData(origTraceInd).Label.ListText, ' events'];
    end
    waitbar(1,h)
    delete(h)
    
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



function StdDevs_Callback(hObject, eventdata, handles)
% hObject    handle to StdDevs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StdDevs as text
%        str2double(get(hObject,'String')) returns contents of StdDevs as a double


% --- Executes during object creation, after setting all properties.
function StdDevs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StdDevs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MinTimeAboveThresh_Callback(hObject, eventdata, handles)
% hObject    handle to MinTimeAboveThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinTimeAboveThresh as text
%        str2double(get(hObject,'String')) returns contents of MinTimeAboveThresh as a double


% --- Executes during object creation, after setting all properties.
function MinTimeAboveThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinTimeAboveThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TimeAboveUnits.
function TimeAboveUnits_Callback(hObject, eventdata, handles)
% hObject    handle to TimeAboveUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TimeAboveUnits contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TimeAboveUnits


% --- Executes during object creation, after setting all properties.
function TimeAboveUnits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeAboveUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
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

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function OffsetFrames_Callback(hObject, eventdata, handles)
% hObject    handle to OffsetFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OffsetFrames as text
%        str2double(get(hObject,'String')) returns contents of OffsetFrames as a double


% --- Executes during object creation, after setting all properties.
function OffsetFrames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OffsetFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
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


% --- Executes on button press in UseAllTraces.
function UseAllTraces_Callback(hObject, eventdata, handles)
% hObject    handle to UseAllTraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UseAllTraces
if (get(handles.UseAllTraces,'Value')==1)
    set(handles.TraceSelector,'Enable','off');
else
    set(handles.TraceSelector,'Enable','on');
end



function NumFramesLocalAverage_Callback(hObject, eventdata, handles)
% hObject    handle to NumFramesLocalAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumFramesLocalAverage as text
%        str2double(get(hObject,'String')) returns contents of NumFramesLocalAverage as a double


% --- Executes during object creation, after setting all properties.
function NumFramesLocalAverage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumFramesLocalAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinTimeBtEvents_Callback(hObject, eventdata, handles)
% hObject    handle to MinTimeBtEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinTimeBtEvents as text
%        str2double(get(hObject,'String')) returns contents of MinTimeBtEvents as a double


% --- Executes during object creation, after setting all properties.
function MinTimeBtEvents_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinTimeBtEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TimeBtEventsUnits.
function TimeBtEventsUnits_Callback(hObject, eventdata, handles)
% hObject    handle to TimeBtEventsUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TimeBtEventsUnits contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TimeBtEventsUnits


% --- Executes during object creation, after setting all properties.
function TimeBtEventsUnits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeBtEventsUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ReportMidpoint.
function ReportMidpoint_Callback(hObject, eventdata, handles)
% hObject    handle to ReportMidpoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ReportMidpoint
