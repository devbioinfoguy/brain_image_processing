function varargout = Replay_Search(varargin)
% REPLAY_SEARCH This App aligns one or more traces to points given in the
% binary alignment trace. Any point in the alignment trace with a 1 will be
% an alignment point, and all trace fragments surrounding an alignment
% point will be laid on top of one another. Useful for traces which contain
% multiple repeats of the same experiment, cue, or action.
%
% Output will save as many traces as are input; each will be of length (#
% frames before) + 1 + (# frames after), as set in the GUI.
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Replay_Search

% Last Modified by GUIDE v2.5 22-Oct-2012 12:35:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Replay_Search_OpeningFcn, ...
                   'gui_OutputFcn',  @Replay_Search_OutputFcn, ...
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
function Replay_Search_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Replay_Search (see VARARGIN)

% Choose default command line output for Replay_Search
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeTraceData

if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.TraceSelector,'String',TextTrace);
    set(handles.LocationsTraceSelector,'String',TextTrace);
    set(handles.IndicesTraceSelector, 'String', TextTrace);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.TraceSelector,'Value',Settings.TraceSelectorValue);
    set(handles.LocationsTraceSelector,'Value',Settings.LocationsTraceSelectorValue);
    set(handles.IndicesTraceSelector,'Value',Settings.IndicesTraceSelectorValue);
    set(handles.Timebins, 'String', Settings.TimebinsString);
    set(handles.TimeAfter, 'String', Settings.TimeAfterString);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');
Settings.LocationsTraceSelectorValue=get(handles.LocationsTraceSelector,'Value');
Settings.IndicesTraceSelectorValue=get(handles.IndicesTraceSelector,'Value');
Settings.TimebinsString=get(handles.Timebins, 'String');
Settings.TimeAfterString=get(handles.TimeAfter, 'String');


% --- Outputs from this function are returned to the command line.
function varargout = Replay_Search_OutputFcn(hObject, eventdata, handles) 
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
global concertedEvents concertedEventsCells otherActiveCells concertedEventTimes

try
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    placeInds=SpikeTraceData(get(handles.IndicesTraceSelector, 'Value')).Trace;
    placeLocs=SpikeTraceData(get(handles.LocationsTraceSelector, 'Value')).Trace;
    placeLocs=round(placeLocs-min(placeLocs)+1);
    
    eventTraces=get(handles.TraceSelector, 'Value');
    traceLength=length(SpikeTraceData(eventTraces(1)).Trace);
    eventMat=zeros(length(eventTraces), traceLength);
    matInd=0;
    for trInd=eventTraces(placeInds)
        matInd=matInd+1;
        thisTrace=SpikeTraceData(trInd).Trace;
        if length(thisTrace)~= traceLength
            error('Traces not same length!')
        end
        eventMat(matInd, :)=thisTrace;
    end
    
    nonPlaceInds=1:length(eventTraces);
    nonPlaceInds(placeInds)=[];
    nonPlaceEventMat=zeros(length(eventTraces), traceLength);
    matInd=0;
    for trInd=eventTraces(nonPlaceInds)
        matInd=matInd+1;
        thisTrace=SpikeTraceData(trInd).Trace;
        if length(thisTrace)~= traceLength
            error('Traces not same length!')
        end
        nonPlaceEventMat(matInd, :)=thisTrace;
    end
    
    distThresh=(max(placeLocs)-min(placeLocs))
    bins=str2double(get(handles.Timebins, 'String'));
    concertedEvents={};
    concertedEventsCells={};
    otherActiveCells={};
    concertedEventTimes={};
    concInd=1;
    for t=1:(traceLength-bins+1)
        theseEvents=eventMat(:,t:(t+bins-1));
        activeCells=find(sum(theseEvents,2));
        if length(activeCells)>2
            activeCellLocs=placeLocs(activeCells);
            if size(activeCellLocs,1)>1
                activeCellLocs=activeCellLocs';
            end
            distances=squareform(pdist(activeCellLocs'));
            [r,c]=ind2sub(size(distances), find(distances<distThresh));
            if ~isempty(r)
                moreEvents=eventMat(:,t:(t+2*bins-1));
                activeCells=find(sum(theseEvents,2));
                activeCellLocs=placeLocs(activeCells);
                if size(activeCellLocs,1)>1
                    activeCellLocs=activeCellLocs';
                end
                thisEventImage=zeros(max(placeLocs), length(t:(t+2*bins-1)));
                for cellInd=1:length(activeCells)
                    thisEventImage(activeCellLocs(cellInd), logical(moreEvents(activeCells(cellInd),:)))=1;
                end
                concertedEvents{end+1}=thisEventImage;
                concertedEventTimes{end+1}=t;
                concertedEventsCells{end+1}=activeCells;
                otherActiveCells{end+1}=find(sum(nonPlaceEventMat(:,t:(t+2*bins-1)),2));
            end
        end
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



function Timebins_Callback(hObject, eventdata, handles)
% hObject    handle to Timebins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Timebins as text
%        str2double(get(hObject,'String')) returns contents of Timebins as a double


% --- Executes during object creation, after setting all properties.
function Timebins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Timebins (see GCBO)
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


% --- Executes on selection change in IndicesTraceSelector.
function IndicesTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to IndicesTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns IndicesTraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from IndicesTraceSelector


% --- Executes during object creation, after setting all properties.
function IndicesTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IndicesTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in LocationsTraceSelector.
function LocationsTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to LocationsTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LocationsTraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LocationsTraceSelector


% --- Executes during object creation, after setting all properties.
function LocationsTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LocationsTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
