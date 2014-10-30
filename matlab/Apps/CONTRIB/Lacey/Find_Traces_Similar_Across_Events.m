function varargout = Find_Traces_Similar_Across_Events(varargin)
% FIND_TRACES_SIMILAR_ACROSS_EVENTS This App aligns one or more traces to points given in the
% binary alignment trace. Any point in the alignment trace with a 1 will be
% an alignment point, and all trace fragments surrounding an alignment
% point will be laid on top of one another. Useful for traces which contain
% multiple repeats of the same experiment, cue, or action.
%
% Output will save as many traces as are input; each will be of length (#
% frames before) + 1 + (# frames after), as set in the GUI.
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Find_Traces_Similar_Across_Events

% Last Modified by GUIDE v2.5 12-Jun-2012 22:07:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Find_Traces_Similar_Across_Events_OpeningFcn, ...
                   'gui_OutputFcn',  @Find_Traces_Similar_Across_Events_OutputFcn, ...
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
function Find_Traces_Similar_Across_Events_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Find_Traces_Similar_Across_Events (see VARARGIN)

% Choose default command line output for Find_Traces_Similar_Across_Events
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
    set(handles.TraceSelector,'String',Settings.TraceSelectorString);
    set(handles.TraceSelector,'Value',Settings.TraceSelectorValue);
    set(handles.KeepTraces, 'Value', Settings.KeepTracesValue);
    set(handles.UseAllTraces, 'Value', Settings.UseAllTracesValue);
    set(handles.NumPoints, 'String', Settings.NumPointsString);
    set(handles.PointRank, 'String', Settings.PointRankString);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorString=get(handles.TraceSelector,'String');
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');
Settings.KeepTracesValue=get(handles.KeepTraces, 'Value');
Settings.NumPointsString=get(handles.NumPoints, 'String');
Settings.PointRankString=get(handles.PointRank, 'String');


% --- Outputs from this function are returned to the command line.
function varargout = Find_Traces_Similar_Across_Events_OutputFcn(hObject, eventdata, handles) 
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
global sortedInds
global avgCorrs
global maxNumToKeep
global tracesToCheck
global thisTraceSegment
global alignTraceMat

try
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    % get parameters from interface
    tracesToCheck=get(handles.TraceSelector, 'Value');
    eventTraceInd=get(handles.AlignTraceSelector, 'Value');
    keepEventTrace=get(handles.KeepAlignTrace, 'Value');
    eventTrace=SpikeTraceData(eventTraceInd).Trace;
    keepTraces=get(handles.KeepTraces, 'Value');
    if keepTraces && keepEventTrace
        numTraces=length(SpikeTraceData);
    end
    secPerFrame=SpikeTraceData(tracesToCheck(1)).XVector(2)-SpikeTraceData(tracesToCheck(1)).XVector(1);
    timeBefore=round(1/secPerFrame*str2double(get(handles.TimeBefore, 'String')));
    timeAfter=round(1/secPerFrame*str2double(get(handles.TimeAfter, 'String')));
    
    avgCorrs=zeros(1,length(tracesToCheck));
    for i=1:length(tracesToCheck)
        traceInd=tracesToCheck(i);
        thisTrace=SpikeTraceData(traceInd).Trace;
        if length(thisTrace)~=length(eventTrace)
            error('Traces are not same length')
        else
            if size(thisTrace,1)==1
                thisTrace=[zeros(1, timeBefore), thisTrace, zeros(1, timeAfter)];
            else
                thisTrace=[zeros(timeBefore, 1); thisTrace; zeros(timeAfter, 1)];
            end
            alignPoints=find(eventTrace==1);
            if size(alignPoints,1)>1
                alignPoints=alignPoints';
            end
            alignTraceMat=zeros(timeBefore+timeAfter+1,length(alignPoints));
            nonZeroEventInd=1;
            for eventInd=1:length(alignPoints)
                thisEventTime=alignPoints(eventInd);
                thisTraceSegment=thisTrace(thisEventTime:(thisEventTime+timeAfter+timeBefore));
                if sum(abs(thisTraceSegment))>0
                    alignTraceMat(:,nonZeroEventInd)=thisTraceSegment;
                    nonZeroEventInd=nonZeroEventInd+1;
                end
            end
            alignTraceMat=alignTraceMat(:,1:(nonZeroEventInd-1));
            if nonZeroEventInd>1
                thisCorrMat=corr(alignTraceMat);
                avgCorrs(i)=(sum(thisCorrMat(:))-sum(diag(thisCorrMat)))/(2*size(thisCorrMat,1));
            else
                avgCorrs(i)=0;
            end
        end
    end
    [sortedCorrVals, sortedInds]=sort(avgCorrs, 'descend');
    maxNumToKeep=ceil(length(tracesToCheck)*str2double(get(handles.PercentToKeep, 'String'))/100);
    sortedInds=sortedInds(1:maxNumToKeep);
    sortedCorrVals=sortedCorrVals(1:maxNumToKeep);
    sortedInds(sortedCorrVals<str2double(get(handles.MinimumCorrelation, 'String')))=[];
    
    if keepTraces
        tracesToReSave=tracesToCheck(sortedInds);
        for i=1:length(tracesToReSave)
            traceInd=tracesToReSave(i);
            SpikeTraceData(numTraces+i)=SpikeTraceData(traceInd);
            SpikeTraceData(numTraces+i).Label.ListText=['C ' SpikeTraceData(traceInd).Label.ListText];
        end
    else
        tracesToDelete=tracesToCheck;
        tracesToDelete(sortedInds)=[];
        SpikeTraceData(tracesToDelete)=[];
    end

    if ~keepEventTrace
        SpikeTraceData(eventTraceInd)=[];
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



function MinimumCorrelation_Callback(hObject, eventdata, handles)
% hObject    handle to MinimumCorrelation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinimumCorrelation as text
%        str2double(get(hObject,'String')) returns contents of MinimumCorrelation as a double


% --- Executes during object creation, after setting all properties.
function MinimumCorrelation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinimumCorrelation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PercentToKeep_Callback(hObject, eventdata, handles)
% hObject    handle to PercentToKeep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PercentToKeep as text
%        str2double(get(hObject,'String')) returns contents of PercentToKeep as a double


% --- Executes during object creation, after setting all properties.
function PercentToKeep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PercentToKeep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
