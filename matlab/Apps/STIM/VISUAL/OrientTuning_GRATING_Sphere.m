function varargout = OrientTuning_GRATING_Sphere(varargin)
% ORIENTTUNING_GRATING_SPHERE M-file for OrientTuning_GRATING_Sphere.fig
%      ORIENTTUNING_GRATING_SPHERE, by itself, creates a new ORIENTTUNING_GRATING_SPHERE or raises the existing
%      singleton*.
%
%      H = ORIENTTUNING_GRATING_SPHERE returns the handle to a new ORIENTTUNING_GRATING_SPHERE or the handle to
%      the existing singleton*.
%

%      ORIENTTUNING_GRATING_SPHERE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ORIENTTUNING_GRATING_SPHERE.M with the given input arguments.
%
%      ORIENTTUNING_GRATING_SPHERE('Property','Value',...) creates a new ORIENTTUNING_GRATING_SPHERE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OrientTuning_GRATING_Sphere_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OrientTuning_GRATING_Sphere_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OrientTuning_GRATING_Sphere

% Last Modified by GUIDE v2.5 31-Jan-2013 13:13:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OrientTuning_GRATING_Sphere_OpeningFcn, ...
                   'gui_OutputFcn',  @OrientTuning_GRATING_Sphere_OutputFcn, ...
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


% --- Executes just before OrientTuning_GRATING_Sphere is made visible.
function OrientTuning_GRATING_Sphere_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OrientTuning_GRATING_Sphere (see VARARGIN)

% Choose default command line output for OrientTuning_GRATING_Sphere
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes OrientTuning_GRATING_Sphere wait for user response (see UIRESUME)
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
    set(handles.SpatialFreq,'String',Settings.SpatialFreqString);
    set(handles.TempFreq,'String',Settings.TempFreqString);
    set(handles.TimeStim,'String',Settings.TimeStimString);
    set(handles.XCenterStim,'String',Settings.XCenterStimString);
    set(handles.YCenterStim,'String',Settings.YCenterStimString);
    set(handles.RandAngle,'Value',Settings.RandAngleValue);
    set(handles.ListAngles,'String',Settings.ListAnglesString);
    set(handles.ExportTimeTraces,'Value',Settings.ExportTimeTracesValue);
    set(handles.GuaranteedN,'String',Settings.GuaranteedNString);
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
Settings.SpatialFreqString=get(handles.SpatialFreq,'String');
Settings.TimeStimString=get(handles.TimeStim,'String');
Settings.XCenterStimString=get(handles.XCenterStim,'String');
Settings.YCenterStimString=get(handles.YCenterStim,'String');
Settings.RandAngleValue=get(handles.RandAngle,'Value');
Settings.ListAnglesString=get(handles.ListAngles,'String');
Settings.ExportTimeTracesValue=get(handles.ExportTimeTraces,'Value');
Settings.TempFreqString=get(handles.TempFreq,'String');
Settings.GuaranteedNString=get(handles.GuaranteedN,'String');


% --- Outputs from this function are returned to the command line.
function varargout = OrientTuning_GRATING_Sphere_OutputFcn(hObject, eventdata, handles) 
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
    
    
    SetupProp.Duration=str2num(get(handles.GenPropDur,'String'));
    SetupProp.ITI=str2num(get(handles.GenPropITI,'String'));
    SetupProp.TimeStim=str2num(get(handles.TimeStim,'String'));
    
    TimeforOneTrial=SetupProp.ITI+SetupProp.TimeStim;
    NumberTrials=ceil(SetupProp.Duration/(TimeforOneTrial));
    set(handles.NbTrials,'String',num2str(NumberTrials));
    
    % initialize bar set of available positions
    SetOfAngles=SetupProp.MinOrientStim:SetupProp.StepOrientStim:SetupProp.MaxOrientStim;
    NumberAngles=numel(SetOfAngles);
    NumberRepetition=floor(NumberTrials/NumberAngles);
    if NumberRepetition>1
        AllPresentedAngles=repmat(SetOfAngles,1,NumberRepetition);
    else
        AllPresentedAngles=[];
    end
    AllPresentedAngles=[AllPresentedAngles SetOfAngles(randi(length(SetOfAngles),NumberTrials-numel(AllPresentedAngles),1))];
    SetupProp.ChosenAngles=AllPresentedAngles(randperm(numel(AllPresentedAngles)));
    set(handles.GuaranteedN,'String',num2str(NumberRepetition));
    
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



function TempFreq_Callback(hObject, eventdata, handles)
% hObject    handle to TempFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TempFreq as text
%        str2double(get(hObject,'String')) returns contents of TempFreq as a double
StepOrientStim_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function TempFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TempFreq (see GCBO)
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



function SpatialFreq_Callback(hObject, eventdata, handles)
% hObject    handle to SpatialFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SpatialFreq as text
%        str2double(get(hObject,'String')) returns contents of SpatialFreq as a double
StepOrientStim_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function SpatialFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpatialFreq (see GCBO)
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
    SetupProp.TempFreq=str2double(get(handles.TempFreq,'String'));
    SetupProp.SpatialFreq=str2double(get(handles.SpatialFreq,'String'));
    SetupProp.RandAngle=get(handles.RandAngle,'Value');
    SetupProp.ListAngles=get(handles.ListAngles,'String');
    SetupProp.XCenterStim=str2double(get(handles.XCenterStim,'String'));
    SetupProp.YCenterStim=str2double(get(handles.YCenterStim,'String'));
    SetupProp.TimeStim=str2double(get(handles.TimeStim,'String'));
    
    % For correction of the screen gamma
    if (get(handles.GammaCorrCheck,'Value')==1)
        SetupProp.GammaMatrix=load(get(handles.GammaFile,'String'));
    else
        SetupProp.GammaMatrix=[];
    end
    
    % If selected, we activate debug mode
    if get(handles.DebugMode,'Value')
        PsychDebugWindowConfiguration;
    else
        clear screen;
    end
    
    Screen('Preference', 'VisualDebugLevel', 1);
    AssertOpenGL;
    
    % open the screen
    screens=Screen('Screens');
    SetupProp.ScreenNumber=max(screens);
%     res=NearestResolution(SetupProp.ScreenNumber,320,240,50);
%     
%     SetResolution(SetupProp.ScreenNumber,res);
%     
    [SetupProp.ScreenWindow, SetupProp.ScreenRect] = Screen('OpenWindow', SetupProp.ScreenNumber, 0,[], 32, 2);
    
    % Fill it with background
    Screen('FillRect',SetupProp.ScreenWindow,[0 0 1]*GrayIndex(SetupProp.ScreenWindow,SetupProp.Background/100));
    
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
        
    TotalDuration=SetupProp.Delay+SetupProp.Duration;
    
    % number of animation frames in loop
    SetupProp.Nframes=round(TotalDuration*SetupProp.fps);
    SetupProp.NframeStim=round(SetupProp.TimeStim*SetupProp.fps);
    
    % number of frames between trials
    SetupProp.NbFrameInterTrial=round(SetupProp.ITI*SetupProp.fps);
    
    % Hide the mouse cursor
    HideCursor;
    Priority(MaxPriority(SetupProp.ScreenWindow));
    
    % Do initial flip...
    Screen('Flip', SetupProp.ScreenWindow);
        
    % Calculate parameters of the grating:
    
    % We convert pixels in mm
    XFactor=SetupProp.ScreenX/(SetupProp.ScreenRect(3)-SetupProp.ScreenRect(1));
    YFactor=SetupProp.ScreenY/(SetupProp.ScreenRect(4)-SetupProp.ScreenRect(2));
    [SetupProp.XScreen,SetupProp.YScreen]=meshgrid(XFactor*((SetupProp.ScreenRect(1):SetupProp.ScreenRect(3)))-SetupProp.XCenterStim,...
        YFactor*((SetupProp.ScreenRect(2):SetupProp.ScreenRect(4)))-SetupProp.YCenterStim);
    
    
    % Compute actual cosine grating:
    SetupProp.white=GrayIndex(SetupProp.ScreenWindow,SetupProp.Brightest/100);
    SetupProp.black=GrayIndex(SetupProp.ScreenWindow,SetupProp.Darkest/100);
    SetupProp.backg=GrayIndex(SetupProp.ScreenWindow,SetupProp.Background/100);

    % Number of frames before starting stimulus
    SetupProp.NberFrameOnsetDelay=round(SetupProp.fps*SetupProp.Delay);
    
    % If asked, we repopulate the list of angles
    if SetupProp.RandAngle
        StepOrientStim_Callback(hObject, eventdata, handles);
    end
    
    % We get the set of angles from the interface
    SetupProp.ChosenAngles=zeros(length(SetupProp.ListAngles));
    
    for i=1:length(SetupProp.ListAngles)
        SetupProp.ChosenAngles(i)=str2double(SetupProp.ListAngles(i));
    end
    
    % Play movie to screen
    RecordOutput=PlayMovieScreen(SetupProp);
    
    Priority(0);
    ShowCursor
    
    Screen('CloseAll');
    
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
InterTrialIteration=SetupProp.NbFrameInterTrial+1;
Numberbar=0;
LineFinished=1;
RecordMovie=0;
CurrentAngle=-1;

nOutputs = nargout;
ScreenSize=size(SetupProp.XScreen);
grating=zeros([ScreenSize 3]);

% We precalculate the spatial components of gratings
% These equations are extracted from Marshell 2011 and calculate a
% grating projected on a sphere
Background=(SetupProp.white-SetupProp.black)/2;

for i=1:numel(SetupProp.ChosenAngles)
    % We first turn the coordinate system with the rotation angle
    Angle=SetupProp.ChosenAngles(i)*pi/180;
    
    
    if ~isfield(SetupProp,['A',num2str(SetupProp.ChosenAngles(i))])
        Y=SetupProp.XScreen*cos(Angle)-SetupProp.YScreen*sin(Angle);
        Z=SetupProp.YScreen*cos(Angle)+SetupProp.XScreen*sin(Angle);
        
        Fs=SetupProp.SpatialFreq*180/pi;
        SpacePhase=2*pi*Fs*(pi/2-acos(Z./sqrt(SetupProp.ScreenDist^2+Y.^2+Z.^2)));
        SpacePhaseCos=((SetupProp.white-SetupProp.black)/2)*cos(SpacePhase);
        SpacePhaseSin=((SetupProp.white-SetupProp.black)/2)*sin(SpacePhase);
        %     if ~isfield(SetupProp,['cos',num2str(SetupProp.ChosenAngles(i))])
        for k=1:SetupProp.NframeStim
            TimePh=2*pi*SetupProp.TempFreq*(k-1)/SetupProp.fps;
            grating(:,:,3)=Background+SpacePhaseCos.*cos(TimePh)+SpacePhaseSin.*sin(TimePh);
            
            SetupProp.(['A',num2str(SetupProp.ChosenAngles(i))]){k}=Screen('MakeTexture', SetupProp.ScreenWindow, grating);
            %             SetupProp.(['cos',num2str(SetupProp.ChosenAngles(i))])=((SetupProp.white-SetupProp.black)/2)*cos(SpacePhase);
            %             SetupProp.(['sin',num2str(SetupProp.ChosenAngles(i))])=((SetupProp.white-SetupProp.black)/2)*sin(SpacePhase);
        end
    end
end

if (nOutputs==1)
    % Preallocate the recording matrix for time stamp and other when no
    % movie mode is requested
    RecordOutput.VBLTimestamp=zeros(SetupProp.Nframes,1);
    RecordOutput.StimulusOnsetTime=zeros(SetupProp.Nframes,1);
    RecordOutput.FlipTimestamp=zeros(SetupProp.Nframes,1);
    RecordOutput.Missed=zeros(SetupProp.Nframes,1);
    RecordOutput.Beampos=zeros(SetupProp.Nframes,1);
    RecordOutput.Stimulus=zeros(SetupProp.Nframes,1);
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

% For Parallel port triggering
switch SetupProp.ParallelPortTrig
    case 1
        % We do nothing, no triggering
    case 2
        % Set the parallel port for sending out
        dio = digitalio('parallel');
        addline(dio,[5 7],0,'out');
        uddobj = daqgetfield(dio,'uddobject');
        SetupProp.ParallelPortTrigObject=uddobj;
        putvalue(SetupProp.ParallelPortTrigObject,[0 1]);
    case 3
        % Set the port for receiving
        dio = digitalio('parallel');
        addline(dio,[5 7],0,'in');
        uddobj = daqgetfield(dio,'uddobject');
        SetupProp.ParallelPortTrigObject=uddobj;
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
            Screen('FillRect',SetupProp.ScreenWindow,[1 1 1]*GrayIndex(SetupProp.ScreenWindow,SetupProp.Background/100),[1;1;10;10]);
            Screen('Flip',SetupProp.ScreenWindow);
        end
    case 4
        % Set the port for receiving from NI card
        dio = digitalio('nidaq','Dev1');
        hwlines = addline(dio,1,0,'in'); % !!!!!!! for input line P0.1

        SetupProp.ParallelPortTrigObject=dio;
        InLoop=1;
        while InLoop
            PortTrig=getvalue(SetupProp.ParallelPortTrigObject);
            
            % We wait for TTL or mouse button to start
            OutLoop(1)=PortTrig(1);
%             [mx, my, buttons]=GetMouse(SetupProp.ScreenNumber);
%             if any(buttons) % break out of loop
%                 break;
%             end
%             OutLoop=(OutLoop || any(buttons));
            InLoop=~OutLoop;
            Screen('FillRect',SetupProp.ScreenWindow,[1 1 1]*GrayIndex(SetupProp.ScreenWindow,SetupProp.Background/100),[1;1;10;10]);
            Screen('Flip',SetupProp.ScreenWindow);
        end
end

for i = 1:SetupProp.Nframes
    
    if (i>SetupProp.NberFrameOnsetDelay)
        if InterTrialIteration<SetupProp.NbFrameInterTrial
            InterTrialIteration=InterTrialIteration+1;
            Screen('FillRect',SetupProp.ScreenWindow,[0 0 1]*GrayIndex(SetupProp.ScreenWindow,SetupProp.Background/100));
            CurrentAngle=-1;
        else
            %             Screen('FillRect',SetupProp.ScreenWindow,[0 0 1]*GrayIndex(SetupProp.ScreenWindow,0/100));
            if (LineFinished)
                % We increment the current grating Number
                Numberbar=Numberbar+1;
                CurrentAngle=SetupProp.ChosenAngles(Numberbar);
                CurrentAngleStr=['A',num2str(CurrentAngle)];
                %                 SpacePhaseCos=SetupProp.(['cos',num2str(CurrentAngle)]);
                %                 SpacePhaseSin=SetupProp.(['sin',num2str(CurrentAngle)]);
                
                % Indice in scanning matrix
                k=1;
                
                % We reset the line indicator to avoid creating new bar
                % before current is finished
                LineFinished=0;
            end
            
            %             TimePh=2*pi*SetupProp.TempFreq*(k-1)/SetupProp.fps;
            
            % Equation from Marshel 2011 is broken using trigonometry to
            % reduce computation for on the fly calculation.
            %             grating(:,:,3)=Background+SpacePhaseCos.*cos(TimePh)+SpacePhaseSin.*sin(TimePh);
            %             SetupProp.Grating=Screen('MakeTexture', SetupProp.ScreenWindow, grating);
            %             Screen('DrawTexture',SetupProp.ScreenWindow,SetupProp.Grating);
            Screen('DrawTexture',SetupProp.ScreenWindow,SetupProp.(CurrentAngleStr){k});
            
            
            %             Screen('BlendFunction', SetupProp.ScreenWindow, GL_ONE, GL_ZERO);
            %
            %             Screen('DrawTexture',SetupProp.ScreenWindow, SpacePhaseCos, SetupProp.ScreenRect, SetupProp.ScreenRect, 0,[],cos(2*pi*Time*SetupProp.TempFreq));
            %             Screen('BlendFunction', SetupProp.ScreenWindow, GL_SRC_ALPHA, GL_DST_ALPHA);
            %
            %             Screen('DrawTexture',SetupProp.ScreenWindow, SpacePhaseSin, SetupProp.ScreenRect, SetupProp.ScreenRect, 0,[],sin(2*pi*Time*SetupProp.TempFreq));
            %             %             Screen('DrawTexture',SetupProp.ScreenWindow, ConstantBackground, SetupProp.ScreenRect, SetupProp.ScreenRect, 0,[]);
            %
            %             %             Screen('DrawTexture',SetupProp.ScreenWindow, ConstantBackground, SetupProp.ScreenRect, SetupProp.ScreenRect, 0,[],1);
            %             Screen('BlendFunction', SetupProp.ScreenWindow, GL_ONE, GL_ZERO);
            
            k=k+1;
            
            % If one grating stim is finished, create another one at the next
            % loop
            if k==SetupProp.NframeStim
                LineFinished=1;
                InterTrialIteration=0;
            end
        end
    end
    
    % Tell PTB that no further drawing commands will follow before Screen('Flip')
    %     Screen('DrawingFinished', SetupProp.ScreenWindow);
    
    % break out of loop
    [mx, my, buttons]=GetMouse(SetupProp.ScreenNumber);
    if any(buttons)
        break;
    end
    
    % If recordMovie is selected, we output the current frame to
    % MovieObject at the requested frame rate
    % If not, we Flip screen.
    if (RecordMovie==0)
        % Record Diode state for post-alignement
        RecordOutput.Stimulus(i)=CurrentAngle;
        
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


function TimeStim_Callback(hObject, eventdata, handles)
% hObject    handle to TimeStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeStim as text
%        str2double(get(hObject,'String')) returns contents of TimeStim as a double


% --- Executes during object creation, after setting all properties.
function TimeStim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MeasureEyeCenter.
function MeasureEyeCenter_Callback(hObject, eventdata, handles)
% hObject    handle to MeasureEyeCenter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% We start by creating a figure of the size of the screen
h=figure;
screen_size = get(0, 'ScreenSize');
set(h, 'Position', [1 1 screen_size(3) screen_size(4)] );
LocalAxe=axes;
[X,Y]=ginput(1);

set(h,'Units','pixels');
set(LocalAxe,'Units','pixels');

AxesPos=get(LocalAxe,'Position');
PositionFig=get(h,'Position');

close(h);
X=AxesPos(3)*X+AxesPos(1)+PositionFig(1)-2;
Y=AxesPos(4)*Y+AxesPos(2)+PositionFig(2)-2;

% We refer to the top not the bottom of screen
Y=screen_size(4)-Y;

X=(X/screen_size(3))*str2num(get(handles.GenPropScreenX,'String'));
Y=(Y/screen_size(4))*str2num(get(handles.GenPropScreenY,'String'));

set(handles.XCenterStim,'String',num2str(X));
set(handles.YCenterStim,'String',num2str(Y));
