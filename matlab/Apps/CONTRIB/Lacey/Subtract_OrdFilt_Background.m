function varargout = Subtract_OrdFilt_Background(varargin)
% SUBTRACT_ORDFILT_BACKGROUND This App uses MATLAB's ordfilt2 function to
% replace each element in the trace with the point of rank "order" in a
% surrounding window of size "domain".
%
% For example, if order=6 and domain=11, then the filter will replace each
% original point with the 6th largest value in a window of 11 points 
% surrounding the original point.
%
% If "order" is about half of "domain", this is like a median filter of
% "domain" number of points. This provides a measure of the median local
% background in the trace, and can be used with "Subtract_Trace_From_Trace"
% to subtract the background from a trace.
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Subtract_OrdFilt_Background

% Last Modified by GUIDE v2.5 20-Jun-2012 15:10:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Subtract_OrdFilt_Background_OpeningFcn, ...
                   'gui_OutputFcn',  @Subtract_OrdFilt_Background_OutputFcn, ...
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
function Subtract_OrdFilt_Background_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Subtract_OrdFilt_Background (see VARARGIN)

% Choose default command line output for Subtract_OrdFilt_Background
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
    set(handles.KeepTraces, 'Value', Settings.KeepTracesValue);
    set(handles.UseAllTraces, 'Value', Settings.UseAllTracesValue);
    set(handles.NumPoints, 'String', Settings.NumPointsString);
    set(handles.PointRank, 'String', Settings.PointRankString);
    set(handles.SaveOrdfiltTraces, 'Value', Settings.SaveOrdfiltTracesValue);
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
Settings.UseAllTracesValue=get(handles.UseAllTraces, 'Value');
Settings.SaveOrdfiltTracesValue=get(handles.SaveOrdfiltTraces, 'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Subtract_OrdFilt_Background_OutputFcn(hObject, eventdata, handles) 
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
    if get(handles.UseAllTraces, 'Value')
        tracesToProcess=1:length(SpikeTraceData);
    else
        tracesToProcess=get(handles.TraceSelector, 'Value');
    end
    saveOrdTraces=get(handles.SaveOrdfiltTraces, 'Value');
    keepTraces=get(handles.KeepTraces, 'Value');
    numTraces=length(SpikeTraceData);
    numPoints=str2double(get(handles.NumPoints, 'String'));
    pointRank=str2double(get(handles.PointRank, 'String'));
    
    for i=1:length(tracesToProcess)
        traceInd=tracesToProcess(i);
        thisTrace=double(SpikeTraceData(traceInd).Trace);
        backgroundTrace=ordfilt2(thisTrace, pointRank, ones(numPoints,1));
        if keepTraces
            saveInd=numTraces+i;
            saveOrdInd=numTraces+i+length(tracesToProcess);
            SpikeTraceData(numTraces+i)=SpikeTraceData(traceInd);
        else
            saveInd=traceInd;
            saveOrdInd=numTraces+i;
        end
        SpikeTraceData(saveInd).Trace=thisTrace-backgroundTrace;
        SpikeTraceData(saveInd).Label.ListText=['bgSub ', SpikeTraceData(saveInd).Label.ListText];
        if saveOrdTraces
            SpikeTraceData(saveOrdInd)=SpikeTraceData(traceInd);
            SpikeTraceData(saveOrdInd).Trace=backgroundTrace;
            SpikeTraceData(saveOrdInd).Label.ListText=['ordfilt ', SpikeTraceData(traceInd).Label.ListText];
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



function NumPoints_Callback(hObject, eventdata, handles)
% hObject    handle to NumPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumPoints as text
%        str2double(get(hObject,'String')) returns contents of NumPoints as a double


% --- Executes during object creation, after setting all properties.
function NumPoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PointRank_Callback(hObject, eventdata, handles)
% hObject    handle to PointRank (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PointRank as text
%        str2double(get(hObject,'String')) returns contents of PointRank as a double


% --- Executes during object creation, after setting all properties.
function PointRank_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PointRank (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveOrdfiltTraces.
function SaveOrdfiltTraces_Callback(hObject, eventdata, handles)
% hObject    handle to SaveOrdfiltTraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SaveOrdfiltTraces
