function varargout = Resample_Trace(varargin)
% RESAMPLE_TRACE This App takes as input one or more traces, and resamples
% them. This is done by upsampling by an integer factor (inserting zeros),
% then lowpassing with an FIR filter (Kaiser window), and then
% downsampling by the second given integer factor.
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Resample_Trace

% Last Modified by GUIDE v2.5 29-May-2012 18:06:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Resample_Trace_OpeningFcn, ...
                   'gui_OutputFcn',  @Resample_Trace_OutputFcn, ...
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
function Resample_Trace_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Resample_Trace (see VARARGIN)

% Choose default command line output for Resample_Trace
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
    set(handles.UpsampFactor, 'String', Settings.NumPointsString);
    set(handles.PointRank, 'String', Settings.PointRankString);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorString=get(handles.TraceSelector,'String');
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');
Settings.KeepTracesValue=get(handles.KeepTraces, 'Value');
Settings.NumPointsString=get(handles.UpsampFactor, 'String');
Settings.PointRankString=get(handles.PointRank, 'String');


% --- Outputs from this function are returned to the command line.
function varargout = Resample_Trace_OutputFcn(hObject, eventdata, handles) 
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
    keepTraces=get(handles.KeepTraces, 'Value');
    if keepTraces
        numTraces=length(SpikeTraceData);
    end
    % new sampling rate is p/q times old sampling rate
    p=str2double(get(handles.UpsampFactor, 'String'));
    q=str2double(get(handles.DownsampFactor, 'String'));
    
    % process traces and save
    for i=1:length(tracesToProcess)
        traceInd=tracesToProcess(i);
        thisTrace=double(SpikeTraceData(traceInd).Trace);
        if floor(p)~=p || floor(q)~=q
            error('Upsampling or downsampling rate is not an integer!')
        else
            newTrace=resample(thisTrace, p, q);
            newTimeInt=q/p*(SpikeTraceData(traceInd).XVector(2)-SpikeTraceData(traceInd).XVector(1));
            newXVector=newTimeInt*(1:length(newTrace));
            if keepTraces
                saveInd=numTraces+i;
                SpikeTraceData(numTraces+i)=SpikeTraceData(traceInd);
            else
                saveInd=traceInd;
            end
            SpikeTraceData(saveInd).Trace=newTrace;
            SpikeTraceData(saveInd).XVector=newXVector;
            SpikeTraceData(saveInd).DataSize=length(newTrace);
            SpikeTraceData(saveInd).Label.ListText=['resamp ', SpikeTraceData(traceInd).Label.ListText];
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



function UpsampFactor_Callback(hObject, eventdata, handles)
% hObject    handle to UpsampFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of UpsampFactor as text
%        str2double(get(hObject,'String')) returns contents of UpsampFactor as a double


% --- Executes during object creation, after setting all properties.
function UpsampFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UpsampFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DownsampFactor_Callback(hObject, eventdata, handles)
% hObject    handle to DownsampFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DownsampFactor as text
%        str2double(get(hObject,'String')) returns contents of DownsampFactor as a double


% --- Executes during object creation, after setting all properties.
function DownsampFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DownsampFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
