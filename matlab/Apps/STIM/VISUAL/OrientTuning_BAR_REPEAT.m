function varargout = OrientTuning_BAR_REPEAT(varargin)
% ORIENTTUNING_BAR_REPEAT M-file for OrientTuning_BAR_REPEAT.fig
%      ORIENTTUNING_BAR_REPEAT, by itself, creates a new ORIENTTUNING_BAR_REPEAT or raises the existing
%      singleton*.
%
%      H = ORIENTTUNING_BAR_REPEAT returns the handle to a new ORIENTTUNING_BAR_REPEAT or the handle to
%      the existing singleton*.
%

%      ORIENTTUNING_BAR_REPEAT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ORIENTTUNING_BAR_REPEAT.M with the given input arguments.
%
%      ORIENTTUNING_BAR_REPEAT('Property','Value',...) creates a new ORIENTTUNING_BAR_REPEAT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OrientTuning_BAR_REPEAT_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OrientTuning_BAR_REPEAT_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OrientTuning_BAR_REPEAT

% Last Modified by GUIDE v2.5 22-Feb-2013 17:17:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OrientTuning_BAR_REPEAT_OpeningFcn, ...
                   'gui_OutputFcn',  @OrientTuning_BAR_REPEAT_OutputFcn, ...
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


% --- Executes just before OrientTuning_BAR_REPEAT is made visible.
function OrientTuning_BAR_REPEAT_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OrientTuning_BAR_REPEAT (see VARARGIN)

% Choose default command line output for OrientTuning_BAR_REPEAT
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes OrientTuning_BAR_REPEAT wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if (length(varargin)>1)
% Here we read from the Settings structure created by the function
% GetSettings. This is used to reload saved settings from a previously
% opened instance of this Apps in the batch list.
% You must update this part to fit with how your Apps is reloaded from its
% saved data.
    Settings=varargin{2};
    set(handles.PreStim,'String',Settings.PreStimString);
    set(handles.PostStimText,'String',Settings.PostStimString);
    set(handles.GenPropDur,'String',Settings.GenPropDurString);
    set(handles.GenPropBack,'String',Settings.GenPropBackString);
    set(handles.GenPropDark,'String',Settings.GenPropDarkString);
    set(handles.GenPropBrig,'String',Settings.GenPropBrigString);
    set(handles.GenPropScreenX,'String',Settings.GenPropScreenXString);
    set(handles.GenPropScreenY,'String',Settings.GenPropScreenYString);
    set(handles.GenPropDistScr,'String',Settings.GenPropDistScrString);
    set(handles.GammaCorrCheck,'Value',Settings.GammaCorrCheckValue);
    set(handles.GammaFile,'String',Settings.GammaFileString);
    set(handles.NormMode,'Value',Settings.NormModeValue);
    set(handles.DebugMode,'Value',Settings.DebugModeValue);
    set(handles.ParallelPortSendTrig,'Value',Settings.ParallelPortSendTrigValue);
    set(handles.OrientStim,'String',Settings.OrientStimString);
    set(handles.BarWidth,'String',Settings.BarWidthString);
    set(handles.SpeedOrientStim,'String',Settings.SpeedOrientStimString);
    set(handles.BarColor,'Value',Settings.BarColorValue);
    set(handles.XCenterStim,'String',Settings.XCenterStimString);
    set(handles.YCenterStim,'String',Settings.YCenterStimString);
    set(handles.BarLength,'String',Settings.BarLengthString);
    set(handles.DistOrientStim,'String',Settings.DistOrientStimString);
    set(handles.ExportTimeTraces,'Value',Settings.ExportTimeTracesValue);
else
    StepOrientStim_Callback(hObject, eventdata, handles);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)

% Here we get the handles to the object on the Apps interface
handles=guidata(hObject);

% We extract the relevant variables from the interface object.
Settings.PreStimString=get(handles.PreStim,'String');
Settings.PostStimString=get(handles.PostStimText,'String');
Settings.GenPropDurString=get(handles.GenPropDur,'String');
Settings.GenPropBackString=get(handles.GenPropBack,'String');
Settings.GenPropDarkString=get(handles.GenPropDark,'String');
Settings.GenPropBrigString=get(handles.GenPropBrig,'String');
Settings.GenPropScreenXString=get(handles.GenPropScreenX,'String');
Settings.GenPropScreenYString=get(handles.GenPropScreenY,'String');
Settings.GenPropDistScrString=get(handles.GenPropDistScr,'String');
Settings.GammaCorrCheckValue=get(handles.GammaCorrCheck,'Value');
Settings.GammaFileString=get(handles.GammaFile,'String');
Settings.NormModeValue=get(handles.NormMode,'Value');
Settings.DebugModeValue=get(handles.DebugMode,'Value');
Settings.ParallelPortSendTrigValue=get(handles.ParallelPortSendTrig,'Value');
Settings.OrientStimString=get(handles.OrientStim,'String');
Settings.BarWidthString=get(handles.BarWidth,'String');
Settings.SpeedOrientStimString=get(handles.SpeedOrientStim,'String');
Settings.BarColorValue=get(handles.BarColor,'Value');
Settings.XCenterStimString=get(handles.XCenterStim,'String');
Settings.YCenterStimString=get(handles.YCenterStim,'String');
Settings.BarLengthString=get(handles.BarLength,'String');
Settings.DistOrientStimString=get(handles.DistOrientStim,'String');
Settings.ExportTimeTracesValue=get(handles.ExportTimeTraces,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = OrientTuning_BAR_REPEAT_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function GenPropDur_Callback(hObject, eventdata, handles)
% hObject    handle to GenPropDur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GenPropDur as text
%        str2double(get(hObject,'String')) returns contents of GenPropDur as a double
StepOrientStim_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function GenPropDur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GenPropDur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function GenPropDel_Callback(hObject, eventdata, handles)
% hObject    handle to GenPropDel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GenPropDel as text
%        str2double(get(hObject,'String')) returns contents of GenPropDel as a double


% --- Executes during object creation, after setting all properties.
function GenPropDel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GenPropDel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function GenPropBack_Callback(hObject, eventdata, handles)
% hObject    handle to GenPropBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GenPropBack as text
%        str2double(get(hObject,'String')) returns contents of GenPropBack as a double


% --- Executes during object creation, after setting all properties.
function GenPropBack_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GenPropBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function GenPropBrig_Callback(hObject, eventdata, handles)
% hObject    handle to GenPropBrig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GenPropBrig as text
%        str2double(get(hObject,'String')) returns contents of GenPropBrig as a double


% --- Executes during object creation, after setting all properties.
function GenPropBrig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GenPropBrig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function GenPropStimX_Callback(hObject, eventdata, handles)
% hObject    handle to GenPropStimX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GenPropStimX as text
%        str2double(get(hObject,'String')) returns contents of GenPropStimX as a double


% --- Executes during object creation, after setting all properties.
function GenPropStimX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GenPropStimX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function GenPropDark_Callback(hObject, eventdata, handles)
% hObject    handle to GenPropDark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GenPropDark as text
%        str2double(get(hObject,'String')) returns contents of GenPropDark as a double


% --- Executes during object creation, after setting all properties.
function GenPropDark_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GenPropDark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function GenPropStimArea_Callback(hObject, eventdata, handles)
% hObject    handle to GenPropStimArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GenPropStimArea as text
%        str2double(get(hObject,'String')) returns contents of GenPropStimArea as a double


% --- Executes during object creation, after setting all properties.
function GenPropStimArea_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GenPropStimArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function GenPropStimY_Callback(hObject, eventdata, handles)
% hObject    handle to GenPropStimY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GenPropStimY as text
%        str2double(get(hObject,'String')) returns contents of GenPropStimY as a double


% --- Executes during object creation, after setting all properties.
function GenPropStimY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GenPropStimY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DotVar_Callback(hObject, eventdata, handles)
% hObject    handle to DotVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DotVar as text
%        str2double(get(hObject,'String')) returns contents of DotVar as a double


% --- Executes during object creation, after setting all properties.
function DotVar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DotVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DotNumber_Callback(hObject, eventdata, handles)
% hObject    handle to DotNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DotNumber as text
%        str2double(get(hObject,'String')) returns contents of DotNumber as a double


% --- Executes during object creation, after setting all properties.
function DotNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DotNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DotMean_Callback(hObject, eventdata, handles)
% hObject    handle to DotMean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DotMean as text
%        str2double(get(hObject,'String')) returns contents of DotMean as a double


% --- Executes during object creation, after setting all properties.
function DotMean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DotMean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GenPropScreenX_Callback(hObject, eventdata, handles)
% hObject    handle to GenPropScreenX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GenPropScreenX as text
%        str2double(get(hObject,'String')) returns contents of GenPropScreenX as a double


% --- Executes during object creation, after setting all properties.
function GenPropScreenX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GenPropScreenX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GenPropScreenY_Callback(hObject, eventdata, handles)
% hObject    handle to GenPropScreenY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GenPropScreenY as text
%        str2double(get(hObject,'String')) returns contents of GenPropScreenY as a double


% --- Executes during object creation, after setting all properties.
function GenPropScreenY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GenPropScreenY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GenPropDistScr_Callback(hObject, eventdata, handles)
% hObject    handle to GenPropDistScr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GenPropDistScr as text
%        str2double(get(hObject,'String')) returns contents of GenPropDistScr as a double
StepOrientStim_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function GenPropDistScr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GenPropDistScr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in NormMode.
function NormMode_Callback(hObject, eventdata, handles)
% hObject    handle to NormMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NormMode
set(handles.NormMode,'Value',1);
set(handles.DebugMode,'Value',0);


% --- Executes on button press in DebugMode.
function DebugMode_Callback(hObject, eventdata, handles)
% hObject    handle to DebugMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DebugMode
set(handles.NormMode,'Value',0);
set(handles.DebugMode,'Value',1);


function OrientStim_Callback(hObject, eventdata, handles)
% hObject    handle to OrientStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OrientStim as text
%        str2double(get(hObject,'String')) returns contents of OrientStim as a double
StepOrientStim_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function OrientStim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OrientStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function StepOrientStim_Callback(hObject, eventdata, handles)
% hObject    handle to StepOrientStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StepOrientStim as text
%        str2double(get(hObject,'String')) returns contents of StepOrientStim as a double

try
    SetupProp.Duration=str2num(get(handles.GenPropDur,'String'));
    SetupProp.PostStim=str2num(get(handles.PostStim,'String'));
    SetupProp.PreStim=str2num(get(handles.PreStim,'String'));
    
    SetupProp.SpeedOrientStim=str2num(get(handles.SpeedOrientStim,'String'));
    SetupProp.DistOrientStim=str2num(get(handles.DistOrientStim,'String'));
    
    % Time for one trial is the distance of the bar to travel divided by
    % its speed.
    TimeforOneTrial=SetupProp.PreStim+SetupProp.PostStim+SetupProp.DistOrientStim/SetupProp.SpeedOrientStim;
    NumberTrials=ceil(SetupProp.Duration/(TimeforOneTrial));
    set(handles.NbTrials,'String',num2str(NumberTrials));
    
    set(handles.TrialDuration,'String',num2str(TimeforOneTrial));
    set(handles.TrialFrequ,'String',num2str(1/TimeforOneTrial));
catch errorObj
    % If there is a problem, we display the error message
    % This is usefull to ensure users user proper values in all fields
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
end
    

% --- Executes during object creation, after setting all properties.
function StepOrientStim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StepOrientStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinOrientStim_Callback(hObject, eventdata, handles)
% hObject    handle to MinOrientStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinOrientStim as text
%        str2double(get(hObject,'String')) returns contents of MinOrientStim as a double
StepOrientStim_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function MinOrientStim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinOrientStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SpeedOrientStim_Callback(hObject, eventdata, handles)
% hObject    handle to SpeedOrientStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SpeedOrientStim as text
%        str2double(get(hObject,'String')) returns contents of SpeedOrientStim as a double
StepOrientStim_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function SpeedOrientStim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpeedOrientStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BarHeight_Callback(hObject, eventdata, handles)
% hObject    handle to BarHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BarHeight as text
%        str2double(get(hObject,'String')) returns contents of BarHeight as a double


% --- Executes during object creation, after setting all properties.
function BarHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BarHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BarWidth_Callback(hObject, eventdata, handles)
% hObject    handle to BarWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BarWidth as text
%        str2double(get(hObject,'String')) returns contents of BarWidth as a double
StepOrientStim_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function BarWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BarWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ScanAmplBar_Callback(hObject, eventdata, handles)
% hObject    handle to ScanAmplBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ScanAmplBar as text
%        str2double(get(hObject,'String')) returns contents of ScanAmplBar as a double


% --- Executes during object creation, after setting all properties.
function ScanAmplBar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScanAmplBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PostStim_Callback(hObject, eventdata, handles)
% hObject    handle to PostStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PostStim as text
%        str2double(get(hObject,'String')) returns contents of PostStim as a double
StepOrientStim_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function PostStim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PostStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ParallelPortSendTrig.
function ParallelPortSendTrig_Callback(hObject, eventdata, handles)
% hObject    handle to ParallelPortSendTrig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ParallelPortSendTrig


% --- Executes on button press in BarColor.
function BarColor_Callback(hObject, eventdata, handles)
% hObject    handle to BarColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BarColor


% --- Executes on button press in GammaCorrCheck.
function GammaCorrCheck_Callback(hObject, eventdata, handles)
% hObject    handle to GammaCorrCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GammaCorrCheck

if get(handles.GammaCorrCheck,'Value')
    if strcmp(get(handles.GammaFile,'String'),'...')
        ChangeGammaFile_Callback(hObject, eventdata, handles);
    end
end


% --- Executes on button press in ChangeGammaFile.
function ChangeGammaFile_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeGammaFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open file path
[filename, pathname] = uigetfile({'*.mat','MAT-files (*.mat)'},'Select gamma filename');

% Open file if exist
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
    return
    
    % Otherwise construct the fullfilename and Check and load the file
else
    % To keep the path accessible to futur request
    cd(pathname);
    
    set(handles.GammaFile,'String',fullfile(pathname,filename));
end


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeTraceData;

try  
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
        
    % We turn it back on in the end
    Cleanup1=onCleanup(@()set(InterfaceObj,'Enable','on'));

    % we collect the general stimulus properties from the interface
    SetupProp.Duration=str2double(get(handles.GenPropDur,'String'));
    SetupProp.PostStim=str2double(get(handles.PostStim,'String'));
    SetupProp.PreStim=str2double(get(handles.PreStim,'String'));
    SetupProp.Background=str2double(get(handles.GenPropBack,'String'));
    SetupProp.Darkest=str2double(get(handles.GenPropDark,'String'));
    SetupProp.Brightest=str2double(get(handles.GenPropBrig,'String'));
    SetupProp.ScreenDist=str2double(get(handles.GenPropDistScr,'String'));
    SetupProp.ScreenX=str2double(get(handles.GenPropScreenX,'String'));
    SetupProp.ScreenY=str2double(get(handles.GenPropScreenY,'String'));
    SetupProp.ParallelPortTrig=get(handles.ParallelPortSendTrig,'Value');
    SetupProp.OrientStim=str2double(get(handles.OrientStim,'String'));
    SetupProp.SpeedOrientStim=str2double(get(handles.SpeedOrientStim,'String'));
    SetupProp.BarWidth=str2double(get(handles.BarWidth,'String'));
    SetupProp.BarLength=str2double(get(handles.BarLength,'String'));
    SetupProp.BarColor=get(handles.BarColor,'Value');
    SetupProp.DiamStim=str2double(get(handles.BarLength,'String'));
    SetupProp.XCenterStim=str2double(get(handles.XCenterStim,'String'));
    SetupProp.YCenterStim=str2double(get(handles.YCenterStim,'String'));
    SetupProp.DistOrientStim=str2double(get(handles.DistOrientStim,'String'));

    % For correction of the screen gamma
    if (get(handles.GammaCorrCheck,'Value')==1)
        SetupProp.GammaMatrix=load(get(handles.GammaFile,'String'));
    else
        SetupProp.GammaMatrix=[];
    end
    
    switch SetupProp.BarColor
        case 1
            SetupProp.ColorMax=[0 0 1];
        case 2
            SetupProp.ColorMax=[0 1 0];
        case 3
            SetupProp.ColorMax=[0 1 1];
        case 4
            SetupProp.ColorMax=[1 1 1];
    end
    
    % For Parallel port triggering
    switch get(handles.ParallelPortSendTrig,'Value')
        case 1
            % We do nothing, no triggering
        case 2
            % Set the parallel port for sending out
            dio = digitalio('parallel');
            addline(dio,[5 7],0,'out');
            uddobj = daqgetfield(dio,'uddobject');
            putvalue(uddobj,[0 0]);
            SetupProp.ParallelPortTrigObject=uddobj;
        case 3
            % Set the port for receiving
            dio = digitalio('parallel');
            addline(dio,[5 7],0,'in');
            uddobj = daqgetfield(dio,'uddobject');
            SetupProp.ParallelPortTrigObject=uddobj;
        case 4
            % Set the port for receiving from NI card
            dio = digitalio('nidaq','Dev1');
            hwlines = addline(dio,0:7,0,'in'); % !!!!!!! for input line P0.1
            
            SetupProp.ParallelPortTrigObject=dio;
            
    end
    
    % If selected, we activate debug mode
    if get(handles.DebugMode,'Value')
        PsychDebugWindowConfiguration;
    else
        clear screen;
    end
    
    Screen('Preference', 'VisualDebugLevel', 1);
    AssertOpenGL;
    
    % horizontal dimension of viewable screen (cm)
    mon_width=(SetupProp.ScreenX)/10;   
    
    % viewing distance (cm)
    v_dist=(SetupProp.ScreenDist)/10;   
    
    % open the screen
    screens=Screen('Screens');
    SetupProp.ScreenNumber=max(screens);
    
    [SetupProp.ScreenWindow, SetupProp.ScreenRect] = Screen('OpenWindow', SetupProp.ScreenNumber, 0,[], 32, 2);
    
    % Fill it with background
    Screen('FillRect',SetupProp.ScreenWindow,SetupProp.ColorMax*GrayIndex(SetupProp.ScreenWindow,SetupProp.Background/100));
    
    if (~isempty(SetupProp.GammaMatrix))
        % we correct for ganmma using a spline interpolation of calibration
        % table
        Screen('LoadNormalizedGammaTable',SetupProp.ScreenWindow,SetupProp.GammaMatrix.gammaTable2*[1 1 1]);
    end
    
    % frames per second
    SetupProp.fps=Screen('FrameRate',SetupProp.ScreenWindow);
    ifi=Screen('GetFlipInterval', SetupProp.ScreenWindow);
    if SetupProp.fps==0
        SetupProp.fps=1/ifi;
    end
    
    [SetupProp.StimCenter(1), SetupProp.StimCenter(2)] = RectCenter(SetupProp.ScreenRect);
    
    TotalDuration=SetupProp.Duration;
    
    % number of animation frames in loop
    SetupProp.Nframes=round(TotalDuration*SetupProp.fps);
    
    % number of frames between trials
    SetupProp.NbFramePostStim=round(SetupProp.PostStim*SetupProp.fps);

    % Hide the mouse cursor
    HideCursor;
    Priority(MaxPriority(SetupProp.ScreenWindow));
    
    % Do initial flip...
    Screen('Flip', SetupProp.ScreenWindow);
    
    % Convert degrees to pixels
    SetupProp.PixelPerDegree = pi * (SetupProp.ScreenRect(3)-SetupProp.ScreenRect(1)) / atan(mon_width/v_dist/2) / 360;    

    % We enable blending for the aperture circle to work properly
    Screen('BlendFunction', SetupProp.ScreenWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % We offset the center stimulation by the required values
    SetupProp.StimCenter(1)=SetupProp.StimCenter(1)+SetupProp.PixelPerDegree*SetupProp.XCenterStim;
    SetupProp.StimCenter(2)=SetupProp.StimCenter(2)+SetupProp.PixelPerDegree*SetupProp.YCenterStim;
    
    % Convert travel angle in screen coordinates per frame
    TravelSpeed=SetupProp.SpeedOrientStim*SetupProp.PixelPerDegree/SetupProp.fps;
    
    % Number of frames before starting stimulus
    SetupProp.NbFramePreStim=round(SetupProp.fps*SetupProp.PreStim);
    
    % Set Bar lenght to be bigger than screen
    SetupProp.PixelBarHeight=SetupProp.PixelPerDegree*SetupProp.BarLength;
    
    SizeStim=SetupProp.PixelPerDegree*SetupProp.DistOrientStim;
    
    % This is the scanning matrix for the bar. It is common to all angles.
    SetupProp.ScanMat=-SizeStim/2:TravelSpeed:SizeStim/2;
    SetupProp.NbFrameStim=numel(SetupProp.ScanMat);

    % We calculate the Start and EndPosition of the bar for all these
    % angles
    InfiniteLoop=1;
    while InfiniteLoop
        % break out of loop
        [mx, my, buttons]=GetMouse(SetupProp.ScreenNumber);
        if any(buttons)
            InfiniteLoop=0;
            break;
        end
        % Play movie to screen
        RecordOutput=PlayMovieScreen(SetupProp);
    end
    StartPositions(1)=(SetupProp.PixelBarHeight/2)*cos(SetupProp.OrientStim*pi/180);
    StartPositions(2)=(SetupProp.PixelBarHeight/2)*sin(SetupProp.OrientStim*pi/180);
    
    
    Priority(0);
    ShowCursor
    
    Screen('CloseAll');
    
    % TTL on parallel port options
    switch SetupProp.ParallelPortTrig
        case 1
            % We do nothing
        case 2
            % We send TTL out and go on
            putvalue(SetupProp.ParallelPortTrigObject,[1 0]);
        case 3
            % We do nothing
        case 4 
            % We do nothing
    end
    
    % Save parameters for offline analysis of stimulus
    if get(handles.ExportTimeTraces,'Value')
        CurrentNumberTrace=length(SpikeTraceData);
        XTimeScreen=RecordOutput.VBLTimestamp-RecordOutput.VBLTimestamp(1);
        
        for i=1:5
            SpikeTraceData(CurrentNumberTrace+i).XVector=XTimeScreen;
            
            switch i
                case 1
                    SpikeTraceData(CurrentNumberTrace+i).Trace=RecordOutput.StimulusOnsetTime-RecordOutput.VBLTimestamp(1);
                    SpikeTraceData(CurrentNumberTrace+i).Label.YLabel='Stim Time (s)';
                    SpikeTraceData(CurrentNumberTrace+i).Label.ListText='Stimulus Onset Time';
                case 2
                    SpikeTraceData(CurrentNumberTrace+i).Trace=RecordOutput.FlipTimestamp-RecordOutput.VBLTimestamp(1);
                    SpikeTraceData(CurrentNumberTrace+i).Label.YLabel='Flip Time (s)';
                    SpikeTraceData(CurrentNumberTrace+i).Label.ListText='Flip Time Stamp';
                case 3
                    SpikeTraceData(CurrentNumberTrace+i).Trace=(RecordOutput.Missed>0);
                    SpikeTraceData(CurrentNumberTrace+i).Label.YLabel='Missed Frames';
                    SpikeTraceData(CurrentNumberTrace+i).Label.ListText='Missed Frames';
                case 4
                    SpikeTraceData(CurrentNumberTrace+i).Trace=RecordOutput.Beampos;
                    SpikeTraceData(CurrentNumberTrace+i).Label.YLabel='Beam Onset Position';
                    SpikeTraceData(CurrentNumberTrace+i).Label.ListText='Beam Onset Position';
                case 5
                    SpikeTraceData(CurrentNumberTrace+i).Trace=RecordOutput.Stimulus;
                    SpikeTraceData(CurrentNumberTrace+i).Label.YLabel='Bar angle (deg)';
                    SpikeTraceData(CurrentNumberTrace+i).Label.ListText='Stimulation angle';
            end
            
            SpikeTraceData(CurrentNumberTrace+i).DataSize=size(SpikeTraceData(CurrentNumberTrace+i).Trace);
            SpikeTraceData(CurrentNumberTrace+i).Filename='';
            SpikeTraceData(CurrentNumberTrace+i).Path='';
            SpikeTraceData(CurrentNumberTrace+i).Label.XLabel='Time (s)';
        end
    end
    
    % In case of errors
catch errorObj
    % We make sure psychophysics functions are available
    if (exist('Screen')==3)
        Priority(0);
        ShowCursor
        Screen('CloseAll');
    end
    
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
end


% This function actually does the big job, ie play the movie on the screen
function varargout=PlayMovieScreen(SetupProp)

% initialize loop variables
TrialIteration=1;
Numberbar=0;
LineFinished=1;
CurrentAngle=-1;

% Preallocate the recording matrix for time stamp and other when no
% movie mode is requested
RecordOutput.VBLTimestamp=zeros(SetupProp.Nframes,1);
RecordOutput.StimulusOnsetTime=zeros(SetupProp.Nframes,1);
RecordOutput.FlipTimestamp=zeros(SetupProp.Nframes,1);
RecordOutput.Missed=zeros(SetupProp.Nframes,1);
RecordOutput.Beampos=zeros(SetupProp.Nframes,1);
RecordOutput.Stimulus=zeros(SetupProp.Nframes,1);

% TTL on parallel port options
switch SetupProp.ParallelPortTrig
    case 1
        % We do nothing
    case 2
        % We send TTL out and go on
        putvalue(SetupProp.ParallelPortTrigObject,[0 1]);
    case 3
        InLoop=1;
        while InLoop
            PortTrig=getvalue(SetupProp.ParallelPortTrigObject);
            
            % We wait for TTL or mouse button to start
            OutLoop(1)=PortTrig(1);
            [mx, my, buttons]=GetMouse(SetupProp.ScreenNumber);
            if any(buttons) % break out of loop
                break;
            end
            OutLoop=(OutLoop || any(buttons));
            InLoop=~OutLoop;
        end
    case 4
        InLoop=1;
        while InLoop
            PortTrig=getvalue(SetupProp.ParallelPortTrigObject);
            
            % We wait for TTL or mouse button to start
            OutLoop=PortTrig(3);
            [~, ~, buttons]=GetMouse(SetupProp.ScreenNumber);
            if any(buttons) % break out of loop
                break;
            end
            if OutLoop==1 % break out of loop
                InLoop=0;
            end
            Screen('Flip',SetupProp.ScreenWindow);
        end
end

for i = 1:SetupProp.Nframes
    if TrialIteration<=SetupProp.NbFramePreStim || TrialIteration>=SetupProp.NbFramePreStim+SetupProp.NbFrameStim+1
        TrialIteration=TrialIteration+1;
        Screen('FillRect',SetupProp.ScreenWindow,SetupProp.ColorMax*GrayIndex(SetupProp.ScreenWindow,SetupProp.Background/100));
        CurrentAngle=-1;
        LineFinished=1;
    else
        Screen('FillRect',SetupProp.ScreenWindow,SetupProp.ColorMax*GrayIndex(SetupProp.ScreenWindow,SetupProp.Background/100));
        TrialIteration=TrialIteration+1;

        if (LineFinished)
            % We increment the current Bar Number
            Numberbar=Numberbar+1;
            CurrentAngle=SetupProp.OrientStim;
            StartPositions(1)=(SetupProp.PixelBarHeight/2)*cos(SetupProp.OrientStim*pi/180);
            StartPositions(2)=(SetupProp.PixelBarHeight/2)*sin(SetupProp.OrientStim*pi/180);
            
            % Vector displacement
            V(1)=cos(pi/180*(90+SetupProp.OrientStim));
            V(2)=sin(pi/180*(90+SetupProp.OrientStim));
            VectorDispl=SetupProp.BarWidth*SetupProp.PixelPerDegree/2*V;
            
            CenterPositionMat=zeros(2,length(SetupProp.ScanMat));
            CenterPositionMat(1,:)=SetupProp.StimCenter(1)+SetupProp.ScanMat*cos((90+SetupProp.OrientStim)*pi/180);
            CenterPositionMat(2,:)=SetupProp.StimCenter(2)+SetupProp.ScanMat*sin((90+SetupProp.OrientStim)*pi/180);
            
            % Indice in scanning matrix
            k=1;
            
            % We reset the line indicator to avoid creating new bar
            % before current is finished
            LineFinished=0;
        end
        
        % Draw stimulation line:
        CornerList(:,1)=CenterPositionMat(:,k)+StartPositions'+VectorDispl';
        CornerList(:,2)=CenterPositionMat(:,k)+StartPositions'-VectorDispl';
        CornerList(:,3)=CenterPositionMat(:,k)-StartPositions'-VectorDispl';
        CornerList(:,4)=CenterPositionMat(:,k)-StartPositions'+VectorDispl';
        
        Screen('FillPoly',SetupProp.ScreenWindow,SetupProp.ColorMax*GrayIndex(SetupProp.ScreenWindow,SetupProp.Brightest/100),CornerList',1);
        
        k=k+1;
    end
    
    if TrialIteration==(SetupProp.NbFramePostStim+SetupProp.NbFramePreStim+SetupProp.NbFrameStim)
        TrialIteration=1;
        LineFinished=1;
    end
            
    % Tell PTB that no further drawing commands will follow before Screen('Flip')
    Screen('DrawingFinished', SetupProp.ScreenWindow);
    
    % break out of loop
    [mx, my, buttons]=GetMouse(SetupProp.ScreenNumber);
    if any(buttons)
        break;
    end
    
    % Record Diode state for post-alignement
    RecordOutput.Stimulus(i)=CurrentAngle;
    
    [RecordOutput.VBLTimestamp(i) RecordOutput.StimulusOnsetTime(i) RecordOutput.FlipTimestamp(i) ...
        RecordOutput.Missed(i) RecordOutput.Beampos(i)]=Screen('Flip',SetupProp.ScreenWindow);
    
end

varargout(1)={RecordOutput};


% --- Executes on button press in ValidateValues.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;


% --- Executes on button press in OpenHelp.
function OpenHelp_Callback(hObject, eventdata, handles)
% hObject    handle to OpenHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CurrentMfilePath = mfilename('fullpath');
[PathToM, name, ext] = fileparts(CurrentMfilePath);
eval(['doc ',name]);


function XCenterStim_Callback(hObject, eventdata, handles)
% hObject    handle to XCenterStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XCenterStim as text
%        str2double(get(hObject,'String')) returns contents of XCenterStim as a double


% --- Executes during object creation, after setting all properties.
function XCenterStim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XCenterStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function YCenterStim_Callback(hObject, eventdata, handles)
% hObject    handle to YCenterStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YCenterStim as text
%        str2double(get(hObject,'String')) returns contents of YCenterStim as a double


% --- Executes during object creation, after setting all properties.
function YCenterStim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YCenterStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BarLength_Callback(hObject, eventdata, handles)
% hObject    handle to BarLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BarLength as text
%        str2double(get(hObject,'String')) returns contents of BarLength as a double
StepOrientStim_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function BarLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BarLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ExportTimeTraces.
function ExportTimeTraces_Callback(hObject, eventdata, handles)
% hObject    handle to ExportTimeTraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ExportTimeTraces


% --- Executes on selection change in ListAngles.
function ListAngles_Callback(hObject, eventdata, handles)
% hObject    handle to ListAngles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListAngles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListAngles


% --- Executes during object creation, after setting all properties.
function ListAngles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListAngles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RandAngle.
function RandAngle_Callback(hObject, eventdata, handles)
% hObject    handle to RandAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RandAngle


% --- Executes on button press in ExportMovie.
function ExportMovie_Callback(hObject, eventdata, handles)
% hObject    handle to ExportMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ExportMovie



function FrameRateExport_Callback(hObject, eventdata, handles)
% hObject    handle to FrameRateExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameRateExport as text
%        str2double(get(hObject,'String')) returns contents of FrameRateExport as a double


% --- Executes during object creation, after setting all properties.
function FrameRateExport_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameRateExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DistOrientStim_Callback(hObject, eventdata, handles)
% hObject    handle to DistOrientStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DistOrientStim as text
%        str2double(get(hObject,'String')) returns contents of DistOrientStim as a double
StepOrientStim_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function DistOrientStim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DistOrientStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SpatFactor_Callback(hObject, eventdata, handles)
% hObject    handle to SpatFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SpatFactor as text
%        str2double(get(hObject,'String')) returns contents of SpatFactor as a double


% --- Executes during object creation, after setting all properties.
function SpatFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpatFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PreStim_Callback(hObject, eventdata, handles)
% hObject    handle to PreStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PreStim as text
%        str2double(get(hObject,'String')) returns contents of PreStim as a double


% --- Executes during object creation, after setting all properties.
function PreStim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PreStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit55_Callback(hObject, eventdata, handles)
% hObject    handle to edit55 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit55 as text
%        str2double(get(hObject,'String')) returns contents of edit55 as a double


% --- Executes during object creation, after setting all properties.
function edit55_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit55 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit56_Callback(hObject, eventdata, handles)
% hObject    handle to edit56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit56 as text
%        str2double(get(hObject,'String')) returns contents of edit56 as a double


% --- Executes during object creation, after setting all properties.
function edit56_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
