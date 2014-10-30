function varargout = Correlate_Traces(varargin)
% CORRELATE_TRACES This App takes in a trace and sets it to 1 when it is
% above a sigma and 0 when it is less than or equal to the sigma.
% Sigma can be set numerically or in terms of the mean and standard
% deviation of the trace, which will be calculated individually for each
% trace processed.
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Correlate_Traces

% Last Modified by GUIDE v2.5 01-Jun-2012 15:38:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Correlate_Traces_OpeningFcn, ...
                   'gui_OutputFcn',  @Correlate_Traces_OutputFcn, ...
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
function Correlate_Traces_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Correlate_Traces (see VARARGIN)

% Choose default command line output for Correlate_Traces
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
    set(handles.UseAllTraces, 'Value', Settings.UseAllTracesValue);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorString=get(handles.TraceSelector,'String');
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Correlate_Traces_OutputFcn(hObject, eventdata, handles) 
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
global SpikeImageData

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
    
    % process traces and save
    corrImage=zeros(length(tracesToProcess));
    for i=1:length(tracesToProcess)
        corrImage(i,i)=1;
        for j=(i+1):length(tracesToProcess)
            corrImage(i,j)=corr(double(SpikeTraceData(tracesToProcess(i)).Trace),...
                double(SpikeTraceData(tracesToProcess(j)).Trace));
            corrImage(j,i)=corrImage(i,j);
        end
    end
    numImages=length(SpikeImageData);
    SpikeImageData(numImages+1).Image=corrImage;
    SpikeImageData(numImages+1).Label.ListText='trace correlations';
    SpikeImageData(numImages+1).Label.XLabel='Trace #';
    SpikeImageData(numImages+1).Label.YLabel='Trace #';
    
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
