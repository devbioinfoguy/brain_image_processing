function varargout = Find_Rates_Intervals(varargin)
% FIND_RATES_INTERVALS This App aligns one or more traces to points given in the
% binary alignment trace. Any point in the alignment trace with a 1 will be
% an alignment point, and all trace fragments surrounding an alignment
% point will be laid on top of one another. Useful for traces which contain
% multiple repeats of the same experiment, cue, or action.
%
% Output will save as many traces as are input; each will be of length (#
% frames before) + 1 + (# frames after), as set in the GUI.
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Find_Rates_Intervals

% Last Modified by GUIDE v2.5 25-Jul-2012 11:33:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Find_Rates_Intervals_OpeningFcn, ...
                   'gui_OutputFcn',  @Find_Rates_Intervals_OutputFcn, ...
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
function Find_Rates_Intervals_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Find_Rates_Intervals (see VARARGIN)

% Choose default command line output for Find_Rates_Intervals
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeTraceData

if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.TraceSelector,'String',TextTrace);
    set(handles.IntervalTraceSelector, 'String', TextTrace);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.TraceSelector, 'Value', intersect(Settings.TraceSelectorValue, 1:length(SpikeTraceData)));
    set(handles.KeepTraces, 'Value', Settings.KeepTracesValue);
    set(handles.IntervalTraceSelector, 'Value', intersect(Settings.IntervalTraceSelectorValue, 1:length(SpikeTraceData)));
    set(handles.KeepIntervalTrace, 'Value', Settings.KeepIntervalTraceValue);
    set(handles.StepSize, 'String', Settings.StepSizeString);
    set(handles.MinIntervalValue, 'String', Settings.MinIntervalValueString);
    set(handles.MaxIntervalValue, 'String', Settings.MaxIntervalValueString);
    set(handles.SortResults, 'Value', Settings.SortResultsValue);
    set(handles.MaxPVal, 'String', Settings.MaxPValString);
    set(handles.BeginTime, 'String', Settings.BeginTimeString);
    set(handles.EndTime, 'String', Settings.EndTimeString);
    set(handles.Timeshift, 'String', Settings.TimeshiftString);
    set(handles.RoundTraces, 'Value', Settings.RoundTracesValue);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorString=get(handles.TraceSelector,'String');
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');
Settings.KeepTracesValue=get(handles.KeepTraces, 'Value');
Settings.IntervalTraceSelectorString=get(handles.IntervalTraceSelector,'String');
Settings.IntervalTraceSelectorValue=get(handles.IntervalTraceSelector,'Value');
Settings.KeepIntervalTraceValue=get(handles.KeepIntervalTrace, 'Value');
Settings.StepSizeString=get(handles.StepSize, 'String');
Settings.MinIntervalValueString=get(handles.MinIntervalValue, 'String');
Settings.MaxIntervalValueString=get(handles.MaxIntervalValue, 'String');
Settings.SortResultsValue=get(handles.SortResults, 'Value');
Settings.MaxPValString=get(handles.MaxPVal, 'String');
Settings.BeginTimeString=get(handles.BeginTime, 'String');
Settings.EndTimeString=get(handles.EndTime, 'String');
Settings.TimeshiftString=get(handles.Timeshift, 'String');
Settings.RoundTracesValue=get(handles.RoundTraces, 'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Find_Rates_Intervals_OutputFcn(hObject, eventdata, handles) 
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
    tracesToProcess=get(handles.TraceSelector, 'Value');
    intervalTraceInd=get(handles.IntervalTraceSelector, 'Value');
    keepIntervalTrace=get(handles.KeepIntervalTrace, 'Value');
    intervalTrace=SpikeTraceData(intervalTraceInd).Trace;
    intervalXVec=SpikeTraceData(intervalTraceInd).XVector;
    keepTraces=get(handles.KeepTraces, 'Value');
    numTraces=length(SpikeTraceData);
    minIntVal=str2double(get(handles.MinIntervalValue, 'String'));
    maxIntVal=str2double(get(handles.MaxIntervalValue, 'String'));
    stepSize=str2double(get(handles.StepSize, 'String'));
    intervalLowerBounds=(minIntVal:stepSize:maxIntVal);
    
    beginTime=str2double(get(handles.BeginTime, 'String'));
    endTime=str2double(get(handles.EndTime, 'String'));
    
    maxPval=str2double(get(handles.MaxPVal, 'String'));
    roundTraces=get(handles.RoundTraces, 'Value');
    
    hWait=waitbar(0.01, 'Calculating rates and performing anova...');
    
    intervalStarts=cell(1,length(intervalLowerBounds));
    intervalEnds=cell(1,length(intervalLowerBounds));
    for intInd=1:length(intervalLowerBounds)
        intVal=intervalLowerBounds(intInd);
        indicateInterval=intervalTrace==intVal;
        if size(indicateInterval,1)==1
            indicateInterval=[0, indicateInterval, 0]; %#ok<AGROW>
        else
            indicateInterval=[0; indicateInterval; 0]; %#ok<AGROW>
        end
        if size(intervalXVec,1)==1
            intervalXVec=[0, intervalXVec, 0]; %#ok<AGROW>
        else
            intervalXVec=[0; intervalXVec; 0]; %#ok<AGROW>
        end
        intervalStarts{intInd}=intervalXVec(find(diff(indicateInterval)==1)+1);
        intervalEnds{intInd}=intervalXVec(logical(diff(indicateInterval)==-1));
    end
    
    rates=zeros(length(tracesToProcess),length(intervalLowerBounds));
    anovaPvals=zeros(length(tracesToProcess));
    for trInd=1:length(tracesToProcess)
        if mod(trInd, round(length(tracesToProcess)/10))==0
            waitbar(trInd/length(tracesToProcess), hWait);
        end
        traceInd=tracesToProcess(trInd);
        thisTrace=SpikeTraceData(traceInd).Trace;
        if roundTraces
            thisTrace=round(thisTrace/stepSize)*stepSize;
        end
        thisXVec=SpikeTraceData(traceInd).XVector;
        thisRateArray=[];
        thisIntArray=[];
        for intInd=1:length(intervalLowerBounds)
            intTime=0;
            timeshift=str2double(get(handles.Timeshift, 'String'));
            for j=1:length(intervalStarts{intInd})
                thisStart=intervalStarts{intInd}(j);
                if thisStart<endTime && thisStart>beginTime
                    thisEnd=intervalEnds{intInd}(j);
                    thisRateArray(end+1)=sum(thisTrace(and((thisXVec-timeshift)>=thisStart, (thisXVec-timeshift)<=thisEnd)))/(thisEnd-thisStart);
                    thisIntArray(end+1)=intInd;
                    rates(trInd,intInd)=rates(trInd,intInd)+sum(thisTrace(and(thisXVec>=thisStart, thisXVec<=thisEnd)));
                    intTime=intTime+thisEnd-thisStart;
                end
            end
            if intTime>0
                rates(trInd,intInd)=rates(trInd,intInd)/intTime;
            end
        end
        if maxPval<1
            anovaPvals(trInd)=anova1(thisRateArray, thisIntArray, 'off');
        end
    end 
    
    if get(handles.SortResults, 'Value')
        [~,maxIntervalInds]=max(rates, [], 2);
        [~,sortedIndices]=sort(maxIntervalInds);
        tracesToSave=tracesToProcess(sortedIndices);
        rates=rates(sortedIndices,:);
        anovaPvals=anovaPvals(sortedIndices);
    else
        tracesToSave=tracesToProcess;
    end
    aInd=0;
    for sInd=1:length(tracesToSave)
        origTraceInd=tracesToSave(sInd);
        if anovaPvals(sInd)<=maxPval
            aInd=aInd+1;
            saveInd=numTraces+aInd;
            thisRateVec=rates(sInd,:);
            SpikeTraceData(saveInd)=SpikeTraceData(origTraceInd);
            SpikeTraceData(saveInd).Trace=thisRateVec;
            SpikeTraceData(saveInd).XVector=intervalLowerBounds;
            SpikeTraceData(saveInd).DataSize=length(thisRateVec);
            SpikeTraceData(saveInd).Label.ListText=['anovasig ', num2str(maxPval), ' TS ', num2str(timeshift), ' rates ' SpikeTraceData(origTraceInd).Label.ListText, ' p=', num2str(anovaPvals(sInd))];
            SpikeTraceData(saveInd).Label.XLabel='value';
            SpikeTraceData(saveInd).Label.YLabel=['mean ', SpikeTraceData(origTraceInd).Label.YLabel];
        end
    end

    if ~keepIntervalTrace && ~keepTraces
        SpikeTraceData(intervalTraceInd, tracesToProcess)=[];
    elseif ~keepIntervalTrace
        SpikeTraceData(tracesToProcess)=[];
    elseif ~keepTraces
        SpikeTraceData(intervalTraceInd)=[];
    end
    
    close(hWait)
    
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



% --- Executes on selection change in IntervalTraceSelector.
function IntervalTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to IntervalTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns IntervalTraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from IntervalTraceSelector


% --- Executes during object creation, after setting all properties.
function IntervalTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IntervalTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in KeepIntervalTrace.
function KeepIntervalTrace_Callback(hObject, eventdata, handles)
% hObject    handle to KeepIntervalTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KeepIntervalTrace



function MinIntervalValue_Callback(hObject, eventdata, handles)
% hObject    handle to MinIntervalValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinIntervalValue as text
%        str2double(get(hObject,'String')) returns contents of MinIntervalValue as a double


% --- Executes during object creation, after setting all properties.
function MinIntervalValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinIntervalValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxIntervalValue_Callback(hObject, eventdata, handles)
% hObject    handle to MaxIntervalValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxIntervalValue as text
%        str2double(get(hObject,'String')) returns contents of MaxIntervalValue as a double


% --- Executes during object creation, after setting all properties.
function MaxIntervalValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxIntervalValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StepSize_Callback(hObject, eventdata, handles)
% hObject    handle to StepSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StepSize as text
%        str2double(get(hObject,'String')) returns contents of StepSize as a double


% --- Executes during object creation, after setting all properties.
function StepSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StepSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SortResults.
function SortResults_Callback(hObject, eventdata, handles)
% hObject    handle to SortResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SortResults



function BeginTime_Callback(hObject, eventdata, handles)
% hObject    handle to BeginTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BeginTime as text
%        str2double(get(hObject,'String')) returns contents of BeginTime as a double


% --- Executes during object creation, after setting all properties.
function BeginTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BeginTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EndTime_Callback(hObject, eventdata, handles)
% hObject    handle to EndTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EndTime as text
%        str2double(get(hObject,'String')) returns contents of EndTime as a double


% --- Executes during object creation, after setting all properties.
function EndTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EndTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxPVal_Callback(hObject, eventdata, handles)
% hObject    handle to MaxPVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxPVal as text
%        str2double(get(hObject,'String')) returns contents of MaxPVal as a double


% --- Executes during object creation, after setting all properties.
function MaxPVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxPVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Timeshift_Callback(hObject, eventdata, handles)
% hObject    handle to Timeshift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Timeshift as text
%        str2double(get(hObject,'String')) returns contents of Timeshift as a double


% --- Executes during object creation, after setting all properties.
function Timeshift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Timeshift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RoundTraces.
function RoundTraces_Callback(hObject, eventdata, handles)
% hObject    handle to RoundTraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RoundTraces
