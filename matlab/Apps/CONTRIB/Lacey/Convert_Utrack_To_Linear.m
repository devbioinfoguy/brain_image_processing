function varargout = Convert_Utrack_To_Linear(varargin)
% CONVERT_UTRACK_TO_LINEAR This App aligns one or more traces to points given in the
% binary alignment trace. Any point in the alignment trace with a 1 will be
% an alignment point, and all trace fragments surrounding an alignment
% point will be laid on top of one another. Useful for traces which contain
% multiple repeats of the same experiment, cue, or action.
%
% Output will save as many traces as are input; each will be of length (#
% frames before) + 1 + (# frames after), as set in the GUI.
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Convert_Utrack_To_Linear

% Last Modified by GUIDE v2.5 03-Oct-2012 18:31:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Convert_Utrack_To_Linear_OpeningFcn, ...
                   'gui_OutputFcn',  @Convert_Utrack_To_Linear_OutputFcn, ...
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
function Convert_Utrack_To_Linear_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Convert_Utrack_To_Linear (see VARARGIN)

% Choose default command line output for Convert_Utrack_To_Linear
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeTraceData

if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.XTraceSelector,'String',TextTrace);
    set(handles.YTraceSelector, 'String', TextTrace);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.XTraceSelector,'Value',Settings.XTraceSelectorValue);
    set(handles.KeepXTrace, 'Value', Settings.KeepXTraceValue);
    set(handles.YTraceSelector,'Value',Settings.YTraceSelectorValue);
    set(handles.KeepYTrace, 'Value', Settings.KeepYTraceValue);
    set(handles.Xmin, 'String', Settings.XminString);
    set(handles.Xmax, 'String', Settings.XmaxString);
    set(handles.Ymin, 'String', Settings.YminString);
    set(handles.Ymax, 'String', Settings.YmaxString);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.XTraceSelectorValue=get(handles.XTraceSelector,'Value');
Settings.YTraceSelectorValue=get(handles.YTraceSelector,'Value');
Settings.KeepXTraceValue=get(handles.KeepXTrace, 'Value');
Settings.KeepYTraceValue=get(handles.KeepYTrace, 'Value');
Settings.XminString=get(handles.Xmin, 'String');
Settings.XmaxString=get(handles.Xmax, 'String');
Settings.SaveSeparatelyValue=get(handles.SaveSeparately, 'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Convert_Utrack_To_Linear_OutputFcn(hObject, eventdata, handles) 
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
    xTraceInd=get(handles.XTraceSelector, 'Value');
    xTrace=SpikeTraceData(xTraceInd).Trace;
    yTraceInd=get(handles.YTraceSelector, 'Value');
    yTrace=SpikeTraceData(yTraceInd).Trace;
    
    ymin=str2double(get(handles.Ymin, 'String'));
    ymax=str2double(get(handles.Ymax, 'String'));
    xmin=str2double(get(handles.Xmin, 'String'));
    xmax=str2double(get(handles.Xmax, 'String'));
    
    width=str2double(get(handles.Width, 'String'));
    
    if length(xTrace)~=length(yTrace)
        error('X and Y position traces must be the same length!')
    end
    linpos=zeros(size(xTrace));
    for t=1:length(xTrace)
        x=xTrace(t);
        y=yTrace(t);
        if x<xmin-width || x>xmax+width || y<ymin-width || y>ymax+width
            warning('x or y out of range!')
        end
        
        if x<xmin+width
            linpos(t)=xmax-xmin + y-ymin;
        elseif x>xmax-width
            if y<ymin+width
                linpos(t)=0;
            else
                linpos(t)=2*(xmax-xmin)+(ymax-ymin);
            end
        elseif y>ymax-width
            linpos(t)=xmax-xmin + x-xmin + ymax-ymin;
        elseif y<ymin+width
            linpos(t)=xmax-x;
        else
            warning('some position out of specified range')
        end
    end
    linInd=length(SpikeTraceData)+1;
    SpikeTraceData(linInd)=SpikeTraceData(xTraceInd);
    SpikeTraceData(linInd).Trace=linpos;
    SpikeTraceData(linInd).Label.ListText='linear position';
            
    if ~get(handles.KeepXTrace, 'Value') && ~get(handles.KeepYTrace, 'Value')
        SpikeTraceData([xTraceInd, yTraceInd])=[];
    elseif ~get(handles.KeepXTrace, 'Value')
        SpikeTraceData(xTraceInd)=[];
    elseif ~get(handles.KeepYTrace, 'Value')
        SpikeTraceData(yTraceInd)=[];
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



% --- Executes on selection change in XTraceSelector.
function XTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to XTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns XTraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from XTraceSelector


% --- Executes during object creation, after setting all properties.
function XTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in KeepXTrace.
function KeepXTrace_Callback(hObject, eventdata, handles)
% hObject    handle to KeepXTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KeepXTrace



% --- Executes on selection change in YTraceSelector.
function YTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to YTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns YTraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from YTraceSelector


% --- Executes during object creation, after setting all properties.
function YTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in KeepYTrace.
function KeepYTrace_Callback(hObject, eventdata, handles)
% hObject    handle to KeepYTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KeepYTrace



function Xmin_Callback(hObject, eventdata, handles)
% hObject    handle to Xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Xmin as text
%        str2double(get(hObject,'String')) returns contents of Xmin as a double


% --- Executes during object creation, after setting all properties.
function Xmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Xmax_Callback(hObject, eventdata, handles)
% hObject    handle to Xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Xmax as text
%        str2double(get(hObject,'String')) returns contents of Xmax as a double


% --- Executes during object creation, after setting all properties.
function Xmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xmax (see GCBO)
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



function Ymin_Callback(hObject, eventdata, handles)
% hObject    handle to Ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ymin as text
%        str2double(get(hObject,'String')) returns contents of Ymin as a double


% --- Executes during object creation, after setting all properties.
function Ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ymax_Callback(hObject, eventdata, handles)
% hObject    handle to Ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ymax as text
%        str2double(get(hObject,'String')) returns contents of Ymax as a double


% --- Executes during object creation, after setting all properties.
function Ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Width_Callback(hObject, eventdata, handles)
% hObject    handle to Width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Width as text
%        str2double(get(hObject,'String')) returns contents of Width as a double


% --- Executes during object creation, after setting all properties.
function Width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
