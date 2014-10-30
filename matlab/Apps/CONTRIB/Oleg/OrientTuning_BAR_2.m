function varargout = OrientTuning_BAR_2(varargin)
% ORIENTTUNING_BAR_2 M-file for OrientTuning_BAR_2.fig
%      ORIENTTUNING_BAR_2, by itself, creates a new ORIENTTUNING_BAR_2 or raises the existing
%      singleton*.
%
%      H = ORIENTTUNING_BAR_2 returns the handle to a new ORIENTTUNING_BAR_2 or the handle to
%      the existing singleton*.
%

%      ORIENTTUNING_BAR_2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ORIENTTUNING_BAR_2.M with the given input arguments.
%
%      ORIENTTUNING_BAR_2('Property','Value',...) creates a new ORIENTTUNING_BAR_2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OrientTuning_BAR_2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OrientTuning_BAR_2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OrientTuning_BAR_2

% Last Modified by GUIDE v2.5 12-Jun-2012 12:03:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OrientTuning_BAR_2_OpeningFcn, ...
                   'gui_OutputFcn',  @OrientTuning_BAR_2_OutputFcn, ...
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


% --- Executes just before OrientTuning_BAR_2 is made visible.
function OrientTuning_BAR_2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OrientTuning_BAR_2 (see VARARGIN)

% Choose default command line output for OrientTuning_BAR_2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes OrientTuning_BAR_2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if (length(varargin)>1)
% Here we read from the Settings structure created by the function
% GetSettings. This is used to reload saved settings from a previously
% opened instance of this Apps in the batch list.
% You must update this part to fit with how your Apps is reloaded from its
% saved data.
    Settings=varargin{2};
    set(handles.GenPropDur,'String',Settings.GenPropDurString);
    set(handles.GenPropDel,'String',Settings.GenPropDelString);
    set(handles.GenPropITI,'String',Settings.GenPropITIString);
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
    set(handles.MaxOrientStim,'String',Settings.MaxOrientStimString);
    set(handles.MinOrientStim,'String',Settings.MinOrientStimString);
    set(handles.StepOrientStim,'String',Settings.StepOrientStimString);
    set(handles.BarWidth,'String',Settings.BarWidthString);
    set(handles.SpeedOrientStim,'String',Settings.SpeedOrientStimString);
    set(handles.BarColor,'Value',Settings.BarColorValue);
    set(handles.XCenterStim,'String',Settings.XCenterStimString);
    set(handles.YCenterStim,'String',Settings.YCenterStimString);
    set(handles.DiamStim,'String',Settings.DiamStimString);
    set(handles.RandAngle,'Value',Settings.RandAngleValue);
    set(handles.ListAngles,'String',Settings.ListAnglesString);
    set(handles.DistOrientStim,'String',Settings.DistOrientStimString);
    set(handles.ExportTimeTraces,'Value',Settings.ExportTimeTracesValue);
    set(handles.ExportMovie,'Value',Settings.ExportMovieValue);
    set(handles.FrameRateExport,'String',Settings.FrameRateExportString);
    set(handles.SpatFactor,'String',Settings.SpatFactorString);
else
    StepOrientStim_Callback(hObject, eventdata, handles);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)

% Here we get the handles to the object on the Apps interface
handles=guidata(hObject);

% We extract the relevant variables from the interface object.
Settings.GenPropDurString=get(handles.GenPropDur,'String');
Settings.GenPropDelString=get(handles.GenPropDel,'String');
Settings.GenPropITIString=get(handles.GenPropITI,'String');
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
Settings.MaxOrientStimString=get(handles.MaxOrientStim,'String');
Settings.MinOrientStimString=get(handles.MinOrientStim,'String');
Settings.StepOrientStimString=get(handles.StepOrientStim,'String');
Settings.BarWidthString=get(handles.BarWidth,'String');
Settings.SpeedOrientStimString=get(handles.SpeedOrientStim,'String');
Settings.BarColorValue=get(handles.BarColor,'Value');
Settings.XCenterStimString=get(handles.XCenterStim,'String');
Settings.YCenterStimString=get(handles.YCenterStim,'String');
Settings.DiamStimString=get(handles.DiamStim,'String');
Settings.RandAngleValue=get(handles.RandAngle,'Value');
Settings.ListAnglesString=get(handles.ListAngles,'String');
Settings.DistOrientStimString=get(handles.DistOrientStim,'String');
Settings.ExportTimeTracesValue=get(handles.ExportTimeTraces,'Value');
Settings.ExportMovieValue=get(handles.ExportMovie,'Value');
Settings.FrameRateExportString=get(handles.FrameRateExport,'String');
Settings.SpatFactorString=get(handles.SpatFactor,'String');


% --- Outputs from this function are returned to the command line.
function varargout = OrientTuning_BAR_2_OutputFcn(hObject, eventdata, handles) 
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


function MaxOrientStim_Callback(hObject, eventdata, handles)
% hObject    handle to MaxOrientStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxOrientStim as text
%        str2double(get(hObject,'String')) returns contents of MaxOrientStim as a double
StepOrientStim_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function MaxOrientStim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxOrientStim (see GCBO)
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
    SetupProp.ITI=str2num(get(handles.GenPropITI,'String'));
    SetupProp.MaxOrientStim=str2num(get(handles.MaxOrientStim,'String'));
    SetupProp.MinOrientStim=str2num(get(handles.MinOrientStim,'String'));
    SetupProp.StepOrientStim=str2num(get(handles.StepOrientStim,'String'));
    SetupProp.SpeedOrientStim=str2num(get(handles.SpeedOrientStim,'String'));
    SetupProp.DiamStim=str2num(get(handles.BarWidth,'String'));
    SetupProp.DiamStim=str2num(get(handles.DiamStim,'String'));
    SetupProp.DistOrientStim=str2num(get(handles.DistOrientStim,'String'));

    % Time for one trial is the distance of the bar to travel divided by
    % its speed.
    TimeforOneTrial=SetupProp.ITI+SetupProp.DistOrientStim/SetupProp.SpeedOrientStim;
    NumberTrials=ceil(SetupProp.Duration/(TimeforOneTrial));
    set(handles.NbTrials,'String',num2str(NumberTrials));
    
    set(handles.TrialDuration,'String',num2str(TimeforOneTrial));
    set(handles.TrialFrequ,'String',num2str(1/TimeforOneTrial));

    % initialize bar set of available positions
    SetOfAngles=SetupProp.MinOrientStim:SetupProp.StepOrientStim:SetupProp.MaxOrientStim;
    SetupProp.ChosenAngles=SetOfAngles(randi(length(SetOfAngles),NumberTrials,1));

    % Convert to string
    for i=1:NumberTrials
        StringAngles{i}=num2str(SetupProp.ChosenAngles(i));
    end
    set(handles.ListAngles,'String',StringAngles);
    
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


function GenPropITI_Callback(hObject, eventdata, handles)
% hObject    handle to GenPropITI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GenPropITI as text
%        str2double(get(hObject,'String')) returns contents of GenPropITI as a double
StepOrientStim_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function GenPropITI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GenPropITI (see GCBO)
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
global SpikeMovieData;

try  
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
        
    % We turn it back on in the end
    Cleanup1=onCleanup(@()set(InterfaceObj,'Enable','on'));

    % we collect the general stimulus properties from the interface
    SetupProp.Duration=str2double(get(handles.GenPropDur,'String'));
    SetupProp.Delay=str2double(get(handles.GenPropDel,'String'));
    SetupProp.ITI=str2double(get(handles.GenPropITI,'String'));
    SetupProp.Background=str2double(get(handles.GenPropBack,'String'));
    SetupProp.Darkest=str2double(get(handles.GenPropDark,'String'));
    SetupProp.Brightest=str2double(get(handles.GenPropBrig,'String'));
    SetupProp.ScreenDist=str2double(get(handles.GenPropDistScr,'String'));
    SetupProp.ScreenX=str2double(get(handles.GenPropScreenX,'String'));
    SetupProp.ScreenY=str2double(get(handles.GenPropScreenY,'String'));
    SetupProp.ParallelPortTrig=get(handles.ParallelPortSendTrig,'Value');
    SetupProp.MaxOrientStim=str2double(get(handles.MaxOrientStim,'String'));
    SetupProp.MinOrientStim=str2double(get(handles.MinOrientStim,'String'));
    SetupProp.StepOrientStim=str2double(get(handles.StepOrientStim,'String'));
    SetupProp.SpeedOrientStim=str2double(get(handles.SpeedOrientStim,'String'));
    SetupProp.BarWidth=str2double(get(handles.BarWidth,'String'));
    SetupProp.BarColor=get(handles.BarColor,'Value');
    SetupProp.RandAngle=get(handles.RandAngle,'Value');
    SetupProp.ListAngles=get(handles.ListAngles,'String');
    SetupProp.DiamStim=str2double(get(handles.DiamStim,'String'));
    SetupProp.XCenterStim=str2double(get(handles.XCenterStim,'String'));
    SetupProp.YCenterStim=str2double(get(handles.YCenterStim,'String'));
    SetupProp.DistOrientStim=str2double(get(handles.DistOrientStim,'String'));
    SetupProp.SpatFactor=str2double(get(handles.SpatFactor,'String'));

    % For correction of the screen gamma
    if (get(handles.GammaCorrCheck,'Value')==1)
        SetupProp.GammaMatrix=load(get(handles.GammaFile,'String'));
    else
        SetupProp.GammaMatrix=[];
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
            hwlines = addline(dio,1,'in'); % !!!!!!! for input line P0.1
           % hwinfo = daqhwinfo(dio);
            %  portval = getvalue(dio);   this will read value from dio
            %  object
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
    %SetupProp.ScreenNumber
    
    [SetupProp.ScreenWindow, SetupProp.ScreenRect] = Screen('OpenWindow',SetupProp.ScreenNumber , 0,[], 32, 2);
    
    % Fill it with background
    Screen('FillRect',SetupProp.ScreenWindow,GrayIndex(SetupProp.ScreenWindow,SetupProp.Background/100));
    
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
    
    TotalDuration=SetupProp.Delay+SetupProp.Duration;
    
    % number of animation frames in loop
    SetupProp.Nframes=round(TotalDuration*SetupProp.fps);
    
    % number of frames between trials
    SetupProp.NbFrameInterTrial=round(SetupProp.ITI*SetupProp.fps);
    
    % Hide the mouse cursor
    HideCursor;
    Priority(MaxPriority(SetupProp.ScreenWindow));
    
    % Do initial flip...
    Screen('Flip', SetupProp.ScreenWindow);
    
    % Convert degrees to pixels
    SetupProp.PixelPerDegree = pi * (SetupProp.ScreenRect(3)-SetupProp.ScreenRect(1)) / atan(mon_width/v_dist/2) / 360;    
    
    % initialize bar set of available positions
    SetOfAngles=SetupProp.MinOrientStim:SetupProp.StepOrientStim:SetupProp.MaxOrientStim;
    
    % We offset the center stimulation by the required values
    SetupProp.StimCenter(1)=SetupProp.StimCenter(1)+SetupProp.PixelPerDegree*SetupProp.XCenterStim;
    SetupProp.StimCenter(2)=SetupProp.StimCenter(2)+SetupProp.PixelPerDegree*SetupProp.YCenterStim;
    
    % Convert travel angle in screen coordinates per frame
    TravelSpeed=SetupProp.SpeedOrientStim*SetupProp.PixelPerDegree/SetupProp.fps;
    
    % Number of frames before starting stimulus
    SetupProp.NberFrameOnsetDelay=round(SetupProp.fps*SetupProp.Delay);
    
    % Set Bar lenght to be bigger than screen
    SetupProp.PixelBarHeight=2*(SetupProp.ScreenRect(3)-SetupProp.ScreenRect(1));
    
    SizeStim=SetupProp.PixelPerDegree*SetupProp.DistOrientStim;
    
    % This is the scanning matrix for the bar. It is common to all angles.
    SetupProp.ScanMat=-SizeStim/2:TravelSpeed:SizeStim/2;

    % We enable blending for the aperture circle to work properly
    Screen('BlendFunction', SetupProp.ScreenWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % Create circular aperture 
    texsize=SetupProp.DiamStim*SetupProp.PixelPerDegree/2;
    mask=ones(1+SetupProp.ScreenRect(4)-SetupProp.ScreenRect(2), 1+SetupProp.ScreenRect(3)-SetupProp.ScreenRect(1), 2) * GrayIndex(SetupProp.ScreenWindow,SetupProp.Background/100);
    [x,y]=meshgrid(SetupProp.ScreenRect(1):SetupProp.ScreenRect(3),SetupProp.ScreenRect(2):SetupProp.ScreenRect(4));    
    mask(:,:,2)=255*(((x-SetupProp.StimCenter(1)).^2 + (y-SetupProp.StimCenter(2)).^2)>= (texsize)^2);
    SetupProp.MaskStim=Screen('MakeTexture', SetupProp.ScreenWindow, mask);
    
    % If asked, we repopulate the list of angles
    if SetupProp.RandAngle
        StepOrientStim_Callback(hObject, eventdata, handles);
    end
    
    % We get the set of angles from the interface
    SetupProp.ChosenAngles=zeros(length(SetupProp.ListAngles));
    StartPositions=zeros(2,length(SetupProp.ListAngles));
    
    % We setup the color of the bar
    switch SetupProp.BarColor
        case 1
            GrayLevelBar=(SetupProp.Brightest)/100;
        case 2
            GrayLevelBar=(SetupProp.Darkest)/100;
    end
    SetupProp.ColourBar=GrayIndex(SetupProp.ScreenWindow,GrayLevelBar);
    
    
    for i=1:length(SetupProp.ListAngles)
        SetupProp.ChosenAngles(i)=str2double(SetupProp.ListAngles(i));
        
        % We calculate the Start and EndPosition of the bar for all these
        % angles
        StartPositions(1,i)=(SetupProp.PixelBarHeight/2)*cos(SetupProp.ChosenAngles(i)*pi/180);
        StartPositions(2,i)=(SetupProp.PixelBarHeight/2)*sin(SetupProp.ChosenAngles(i)*pi/180);
    end

    for NumberOfScans=1:str2num(get(handles.NumberOfScans,'String'))
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
                    OutLoop(1)=PortTrig(1);
                    [mx, my, buttons]=GetMouse(SetupProp.ScreenNumber);
                    if any(buttons) % break out of loop
                        break;
                    end
                    OutLoop=(OutLoop || any(buttons));
                    InLoop=~OutLoop;
                end
        end
        
        % Play movie to screen
        
        RecordOutput=PlayMovieScreen(SetupProp);
               
        
        % We save a movie if requested
        if get(handles.ExportMovie,'Value')
            MovieFrameRate=str2double(get(handles.FrameRateExport,'String'));
            
            % We calculate what is the interval between recorded frames.
            SetupProp.FrameRecordInterval=round(SetupProp.fps/MovieFrameRate);
            numberOldMovie=length(SpikeMovieData);
            
            % We replay the movie but request a movie output. This is to avoid
            % the slowness of screen(GetImage) during the actual presentation
            [KeepFrame,SpikeMovieData(numberOldMovie+1).Movie]=PlayMovieScreen(SetupProp);
            
            SpikeMovieData(numberOldMovie+1).DataSize=size(SpikeMovieData(numberOldMovie+1).Movie);
            Xsize=SpikeMovieData(numberOldMovie+1).DataSize(1);
            Ysize=SpikeMovieData(numberOldMovie+1).DataSize(2);
            SpikeMovieData(numberOldMovie+1).Filename='';
            SpikeMovieData(numberOldMovie+1).Path='';
            SpikeMovieData(numberOldMovie+1).Label.XLabel='Time (s)';
            SpikeMovieData(numberOldMovie+1).TimeFrame=RecordOutput.VBLTimestamp(KeepFrame)-RecordOutput.VBLTimestamp(1);
            SpikeMovieData(numberOldMovie+1).TimePixel=zeros(SpikeMovieData(numberOldMovie+1).DataSize,'uint8');
            SpikeMovieData(numberOldMovie+1).Exposure=RecordOutput.VBLTimestamp(2)-RecordOutput.VBLTimestamp(1)*ones(Xsize,Ysize);
            SpikeMovieData(numberOldMovie+1).TimePixelUnits=10^-6;
            SpikeMovieData(numberOldMovie+1).Label.XLabel='Azimuth (deg)';
            SpikeMovieData(numberOldMovie+1).Label.YLabel='Altitude(deg)';
            SpikeMovieData(numberOldMovie+1).Label.ZLabel='';
            SpikeMovieData(numberOldMovie+1).Label.CLabel='Screen intensity';
            SpikeMovieData(numberOldMovie+1).Label.ListText='Stimulating Monitor';
            [SpikeMovieData(numberOldMovie+1).Xposition(:,:),SpikeMovieData(numberOldMovie+1).Yposition(:,:)] ...
                = meshgrid(1/SetupProp.PixelPerDegree*SetupProp.SpatFactor*(1:Ysize),1/SetupProp.PixelPerDegree*SetupProp.SpatFactor*(1:Xsize));
            SpikeMovieData(numberOldMovie+1).Zposition(:,:)=zeros([Xsize Ysize]);
        end
        
%         Priority(0);
%         ShowCursor
        
     %   Screen('CloseAll');
        % TTL on parallel port options
        switch SetupProp.ParallelPortTrig
            case 1
                % We do nothing
            case 2
                % We send TTL out and go on
                putvalue(SetupProp.ParallelPortTrigObject,[1 0]);
            case 3
                % We do nothing
            case 3
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
                        SpikeTraceData(CurrentNumberTrace+i).Trace=RecordOutput.RecordDiode;
                        SpikeTraceData(CurrentNumberTrace+i).Label.YLabel='Photodiode value';
                        SpikeTraceData(CurrentNumberTrace+i).Label.ListText='Photodiode value';
                end
                
                SpikeTraceData(CurrentNumberTrace+i).DataSize=size(SpikeTraceData(CurrentNumberTrace+i).Trace);
                SpikeTraceData(CurrentNumberTrace+i).Filename='';
                SpikeTraceData(CurrentNumberTrace+i).Path='';
                SpikeTraceData(CurrentNumberTrace+i).Label.XLabel='Time (s)';
            end
        end
    
    end %%% NumberOfScans
    Screen('CloseAll');
    Priority(0);
    ShowCursor

    
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
InterTrialIteration=SetupProp.NbFrameInterTrial+1;
Numberbar=0;
LineFinished=1;
RecordMovie=0;
DiodeC=GrayIndex(SetupProp.ScreenWindow,SetupProp.Background/100);

nOutputs = nargout;

if (nOutputs==1)
    % Preallocate the recording matrix for time stamp and other when no
    % movie mode is requested
    RecordOutput.VBLTimestamp=zeros(SetupProp.Nframes,1);
    RecordOutput.StimulusOnsetTime=zeros(SetupProp.Nframes,1);
    RecordOutput.FlipTimestamp=zeros(SetupProp.Nframes,1);
    RecordOutput.Missed=zeros(SetupProp.Nframes,1);
    RecordOutput.Beampos=zeros(SetupProp.Nframes,1);
    RecordOutput.RecordDiode=zeros(SetupProp.Nframes,1);
else
    % Preallocate the movie in movie output mode
    TakenFrame=1:SetupProp.FrameRecordInterval:SetupProp.Nframes;
    NumberSavedFrames=length(TakenFrame);
    
    % We get a test image to calculate the future size of the movie
    TestImage=Screen('GetImage', SetupProp.ScreenWindow,[],'backBuffer',[],1);
    TestImage = imresize(TestImage, 1/SetupProp.SpatFactor);
    SizeImage=size(TestImage);
    Movie=zeros(SizeImage(1),SizeImage(2),NumberSavedFrames,'uint8');
    FrameOutput=0;
    RecordMovie=1;
end

for i = 1:SetupProp.Nframes
    if (i>SetupProp.NberFrameOnsetDelay)
        if InterTrialIteration<SetupProp.NbFrameInterTrial
            InterTrialIteration=InterTrialIteration+1;
            Screen('FillRect',SetupProp.ScreenWindow,GrayIndex(SetupProp.ScreenWindow,SetupProp.Background/100));
            DiodeC=GrayIndex(SetupProp.ScreenWindow,SetupProp.Background/100);
        else
            Screen('FillRect',SetupProp.ScreenWindow,GrayIndex(SetupProp.ScreenWindow,SetupProp.Background/100));
            if (LineFinished)
                % We switch the Photodiode state
                if DiodeC==255
                    DiodeC=0;
                else
                    DiodeC=255;
                end
                
                % We increment the current Bar Number
                Numberbar=Numberbar+1;
                
                StartPositions(1)=(SetupProp.PixelBarHeight/2)*cos(SetupProp.ChosenAngles(Numberbar)*pi/180);
                StartPositions(2)=(SetupProp.PixelBarHeight/2)*sin(SetupProp.ChosenAngles(Numberbar)*pi/180);
                
                % Vector displacement
                V(1)=cos(pi/180*(90+SetupProp.ChosenAngles(Numberbar)));
                V(2)=sin(pi/180*(90+SetupProp.ChosenAngles(Numberbar)));
                VectorDispl=SetupProp.BarWidth*SetupProp.PixelPerDegree/2*V;
                
                CenterPositionMat=zeros(2,length(SetupProp.ScanMat));
                CenterPositionMat(1,:)=SetupProp.StimCenter(1)+SetupProp.ScanMat*cos((90+SetupProp.ChosenAngles(Numberbar))*pi/180);
                CenterPositionMat(2,:)=SetupProp.StimCenter(2)+SetupProp.ScanMat*sin((90+SetupProp.ChosenAngles(Numberbar))*pi/180);
                
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
            
            Screen('FillPoly',SetupProp.ScreenWindow,[0 0 1]*SetupProp.ColourBar,CornerList',1);
            
            Screen('DrawTexture', SetupProp.ScreenWindow, SetupProp.MaskStim,SetupProp.ScreenRect,SetupProp.ScreenRect,0);
            
            % rectangle at the corner to indicate stimulus change
            Screen('FillRect', SetupProp.ScreenWindow, DiodeC*[1 1 1], [SetupProp.ScreenRect(3)-100 0 SetupProp.ScreenRect(3) 100]);
            
            k=k+1;
            
            % If one bar stim is finished, create another one at the next
            % loop
            if k==size(CenterPositionMat,2)
                LineFinished=1;
                InterTrialIteration=0;
            end
        end
    end
    
    % Tell PTB that no further drawing commands will follow before Screen('Flip')
    Screen('DrawingFinished', SetupProp.ScreenWindow);
    
    TTLbreak=0;
    %%if turned by TTL signal
    if (SetupProp.ParallelPortTrig==4)
        PortTrig=getvalue(SetupProp.ParallelPortTrigObject);
        TTLbreak=~PortTrig(1);
    end
    % break out of loop
    [mx, my, buttons]=GetMouse(SetupProp.ScreenNumber);
    if (any(buttons) || TTLbreak)
        break;
    end
    
    % If recordMovie is selected, we output the current frame to
    % MovieObject at the requested frame rate
    % If not, we Flip screen.
    if (RecordMovie==0)       
        % Record Diode state for post-alignement
        RecordOutput.RecordDiode(i)=DiodeC;
        
        [RecordOutput.VBLTimestamp(i) RecordOutput.StimulusOnsetTime(i) RecordOutput.FlipTimestamp(i) ...
            RecordOutput.Missed(i) RecordOutput.Beampos(i)]=Screen('Flip',SetupProp.ScreenWindow);
    else
        % We don't flip when recording movie as we don't want to stimulate
        if round((i-1)/SetupProp.FrameRecordInterval)==(i-1)/SetupProp.FrameRecordInterval
            FrameOutput=FrameOutput+1;    
            Movie(:,:,FrameOutput)=imresize(Screen('GetImage', SetupProp.ScreenWindow,[],'backBuffer',[],1),1/SetupProp.SpatFactor);
        end
    end
end

if (nOutputs==1)
    varargout(1)={RecordOutput};
else
    varargout(1)={TakenFrame};
    % We rely on Copy On Write to avoid memory copy of this big matrix
    varargout(2)={Movie};
end


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



function DiamStim_Callback(hObject, eventdata, handles)
% hObject    handle to DiamStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DiamStim as text
%        str2double(get(hObject,'String')) returns contents of DiamStim as a double
StepOrientStim_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function DiamStim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DiamStim (see GCBO)
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



function NumberOfScans_Callback(hObject, eventdata, handles)
% hObject    handle to NumberOfScans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumberOfScans as text
%        str2double(get(hObject,'String')) returns contents of NumberOfScans as a double


% --- Executes during object creation, after setting all properties.
function NumberOfScans_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumberOfScans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
