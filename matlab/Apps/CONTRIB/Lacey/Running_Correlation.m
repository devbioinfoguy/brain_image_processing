function varargout = Running_Correlation(varargin)
% RUNNING_CORRELATION 
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Running_Correlation

% Last Modified by GUIDE v2.5 05-Jul-2012 13:22:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Running_Correlation_OpeningFcn, ...
                   'gui_OutputFcn',  @Running_Correlation_OutputFcn, ...
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
function Running_Correlation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Running_Correlation (see VARARGIN)

% Choose default command line output for Running_Correlation
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeTraceData

numberTraces=length(SpikeTraceData);

if ~isempty(SpikeTraceData)
    for i=1:numberTraces
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.TraceSelector1,'String',TextTrace);
    set(handles.TraceSelector2, 'String', TextTrace);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.TraceSelector1,'Value',intersect(1:numberTraces, Settings.TraceSelector1Value));
    set(handles.TraceSelector2,'Value',intersect(1:numberTraces, Settings.TraceSelector2Value));
    set(handles.WindowSize, 'String', Settings.WindowSizeString);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelector1Value=get(handles.TraceSelector1,'Value');
Settings.TraceSelector2Value=get(handles.TraceSelector2,'Value');
Settings.WindowSizeString=get(handles.WindowSize, 'String');


% --- Outputs from this function are returned to the command line.
function varargout = Running_Correlation_OutputFcn(hObject, eventdata, handles) 
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
    traces1=get(handles.TraceSelector1, 'Value');
    traces2=get(handles.TraceSelector2, 'Value');
    
    numTraces2=length(traces2);
    if length(traces1)~=numTraces2 && numTraces2>1
        error('Must select same number of traces, or many traces and one trace')
    end
    winSize=str2double(get(handles.WindowSize, 'String'));
    numTraces=length(SpikeTraceData);
    
    traceInd2=traces2(1);
    for i=1:length(traces1)
        traceInd1=traces1(i);
        if numTraces2>1
            traceInd2=traces2(i);
        end
        trace1=SpikeTraceData(traceInd1).Trace;
        trace2=SpikeTraceData(traceInd2).Trace;
        
        if length(trace1)~=length(trace2)
            error('traces not same length')
        end
        
        winSizeFrames=winSize*(1/(SpikeTraceData(traceInd1).XVector(2)-SpikeTraceData(traceInd1).XVector(1)));
        
        thisCorr=zeros(size(trace1));
        for winStart=1:(length(trace1)-winSizeFrames)
            thisCorrMat=corrcoef(trace1(winStart+(1:winSizeFrames)), trace2(winStart+(1:winSizeFrames)));
            thisCorr(winStart)=thisCorrMat(1,2);
        end
        
        SpikeTraceData(numTraces+i)=SpikeTraceData(traceInd1);
        SpikeTraceData(numTraces+i).Trace=thisCorr;
        SpikeTraceData(numTraces+i).Label.ListText=['corr ', SpikeTraceData(traceInd1).Label.ListText,...
            ' with ', SpikeTraceData(traceInd2).Label.ListText];
        SpikeTraceData(numTraces+i).Label.YLabel=['correlation, window of ', num2str(winSize) ,' s'];
        
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



% --- Executes on selection change in TraceSelector1.
function TraceSelector1_Callback(hObject, eventdata, handles)
% hObject    handle to TraceSelector1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TraceSelector1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TraceSelector1


% --- Executes during object creation, after setting all properties.
function TraceSelector1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TraceSelector1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TraceSelector2.
function TraceSelector2_Callback(hObject, eventdata, handles)
% hObject    handle to TraceSelector2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TraceSelector2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TraceSelector2


% --- Executes during object creation, after setting all properties.
function TraceSelector2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TraceSelector2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function WindowSize_Callback(hObject, eventdata, handles)
% hObject    handle to WindowSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WindowSize as text
%        str2double(get(hObject,'String')) returns contents of WindowSize as a double


% --- Executes during object creation, after setting all properties.
function WindowSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WindowSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
