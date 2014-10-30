function varargout = Trigger_Stimulator(varargin)
% TRIGGER_STIMULATOR M-file for Trigger_Stimulator.fig
%      TRIGGER_STIMULATOR, by itself, creates a new TRIGGER_STIMULATOR or raises the existing
%      singleton*.
%
%      H = TRIGGER_STIMULATOR returns the handle to a new TRIGGER_STIMULATOR or the handle to
%      the existing singleton*.
%

%      TRIGGER_STIMULATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRIGGER_STIMULATOR.M with the given input arguments.
%
%      TRIGGER_STIMULATOR('Property','Value',...) creates a new TRIGGER_STIMULATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Trigger_Stimulator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Trigger_Stimulator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Trigger_Stimulator

% Last Modified by GUIDE v2.5 14-May-2013 13:52:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Trigger_Stimulator_OpeningFcn, ...
                   'gui_OutputFcn',  @Trigger_Stimulator_OutputFcn, ...
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


% --- Executes just before Trigger_Stimulator is made visible.
function Trigger_Stimulator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Trigger_Stimulator (see VARARGIN)

% Choose default command line output for Trigger_Stimulator
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Trigger_Stimulator wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if (length(varargin)>1)
% Here we read from the Settings structure created by the function
% GetSettings. This is used to reload saved settings from a previously
% opened instance of this Apps in the batch list.
% You must update this part to fit with how your Apps is reloaded from its
% saved data.
    Settings=varargin{2};
    set(handles.PreStim,'String',Settings.PreStimString);
    set(handles.PostStim,'String',Settings.PostStimString);
    set(handles.GenPropDur,'String',Settings.GenPropDurString);
    set(handles.StimDur,'String',Settings.StimDurString);
    set(handles.TrigSettings,'Value',Settings.TrigSettingsValue);
    CalcNbTrials(handles);
end

CalcNbTrials(handles);


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)

% Here we get the handles to the object on the Apps interface
handles=guidata(hObject);

% We extract the relevant variables from the interface object.
Settings.PreStimString=get(handles.PreStim,'String');
Settings.PostStimString=get(handles.PostStim,'String');
Settings.TrigSettingsValue=get(handles.TrigSettings,'Value');
Settings.StimDurString=get(handles.StimDur,'String');
Settings.GenPropDurString=get(handles.GenPropDur,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Trigger_Stimulator_OutputFcn(hObject, eventdata, handles) 
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
CalcNbTrials( handles);


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


function CalcNbTrials(handles)
% hObject    handle to StepOrientStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StepOrientStim as text
%        str2double(get(hObject,'String')) returns contents of StepOrientStim as a double

try
    Duration=str2num(get(handles.GenPropDur,'String'));
    PostStim=str2num(get(handles.PostStim,'String'));
    PreStim=str2num(get(handles.PreStim,'String'));
    StimDur=str2num(get(handles.StimDur,'String'));

    % Time for one trial is the distance of the bar to travel divided by
    % its speed.
    TimeforOneTrial=PreStim+PostStim+StimDur;
    NumberTrials=floor(Duration/(TimeforOneTrial));
    set(handles.NbTrials,'String',num2str(NumberTrials));
catch errorObj
    % If there is a problem, we display the error message
    % This is usefull to ensure users user proper values in all fields
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
end
    

function PostStim_Callback(hObject, eventdata, handles)
% hObject    handle to PostStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PostStim as text
%        str2double(get(hObject,'String')) returns contents of PostStim as a double
CalcNbTrials(handles);


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


% --- Executes on button press in TrigSettings.
function TrigSettings_Callback(hObject, eventdata, handles)
% hObject    handle to TrigSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TrigSettings


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try  
    set(handles.TrialsDone,'String','0');

    % we collect the general stimulus properties from the interface
    Duration=str2double(get(handles.GenPropDur,'String'));
    PostStim=str2double(get(handles.PostStim,'String'));
    PreStim=str2double(get(handles.PreStim,'String'));
    StimDur=str2double(get(handles.StimDur,'String'));

    ParallelPortTrig=get(handles.TrigSettings,'Value');
    set(handles.StopStim,'Enable','on');
    set(handles.StopStim,'Value',1);

    % For input triggering
    switch get(handles.TrigSettings,'Value')
        case 1
            % We do nothing, no triggering
        case 2
            % Set the parallel port for sending out
            dio = digitalio('parallel');
            addline(dio,[5 7],0,'out');
            uddobj = daqgetfield(dio,'uddobject');
            putvalue(uddobj,[0 0]);
            TrigObject=uddobj;
        case 3
            % Set the port for receiving
            dio = digitalio('parallel');
            addline(dio,[5 7],0,'in');
            uddobj = daqgetfield(dio,'uddobject');
            TrigObject=uddobj;
        case 4
            % Set the port for receiving from NI card
            dio = digitalio('nidaq','Dev1');
            addline(dio,2,0,'in'); % !!!!!!! for input line P0.1
            TrigObject=dio;
        case 5
            % Set the port for receiving from NI card
            dio = digitalio('nidaq','Dev1');
            addline(dio,0,1,'out'); % !!!!!!! for input line P0.1
            addline(dio,2,0,'in'); % !!!!!!! for input line P0.1
            TrigObject=dio;
        case 6
            % Set the port for receiving from NI card
            dio = digitalio('nidaq','Dev1');
            addline(dio,0,1,'out'); % !!!!!!! for input line P0.1
            TrigObject=dio;
    end
    
    % TTL on parallel port options
    switch ParallelPortTrig
        case 1
            % We do nothing
        case 2
%             We send TTL out and go on
            putvalue(TrigObject,[0 1]);
        case 3
            InLoop=1;
            
            set(handles.TriggWait,'Value',1);
            drawnow;
            
            while InLoop
                PortTrig=getvalue(TrigObject);
                
                % We wait for TTL
                OutLoop(1)=PortTrig(1);
                StopButton=get(handles.StopStim,'Value');

                InLoop=~(OutLoop || ~StopButton);
            end
            
            set(handles.TriggWait,'Value',0);
            drawnow;
            
        case 4
            InLoop=1;
            
            set(handles.TriggWait,'Value',1);
            drawnow;
            
            while InLoop
                PortTrig=getvalue(TrigObject);
                
                % We wait for TTL 
                OutLoop=PortTrig(1);
                StopButton=get(handles.StopStim,'Value');
                
                InLoop=~(OutLoop || ~StopButton);
            end
            
            set(handles.TriggWait,'Value',0);
            drawnow;
            
        case 5
            InLoop=1;
            
            set(handles.TriggWait,'Value',1);
            drawnow;
            
            while InLoop
                PortTrig=getvalue(TrigObject.Line(2));
                
                % We wait for TTL
                OutLoop=PortTrig(1);
                StopButton=get(handles.StopStim,'Value');
                
                InLoop=~(OutLoop || ~StopButton);
            end
            
            set(handles.TriggWait,'Value',0);
            drawnow;
        case 6
            % We do nothing
            
    end
    TotalTrialDuration=PreStim+PostStim+StimDur;
    
    currrentTimer=tic;
    StopButton=get(handles.StopStim,'Value');
    
    InLoop=toc(currrentTimer)<Duration && StopButton==1;
    CurrentState=0;
    CurrentTrialNb=0;

    while InLoop
        LocalTime=toc(currrentTimer);
        TimeTrial=rem(LocalTime,TotalTrialDuration);
        if TimeTrial<PreStim
            if CurrentState
                set(handles.StimTag,'Value',0);
                CurrentState=0;
                                
                % TTL on parallel port options
                switch ParallelPortTrig
                    case 1
                        % We do nothing
                    case 2
                        % We do nothing
                    case 3
                        % We do nothing
                    case 4
                        % We do nothing
                    case 5
                        putvalue(TrigObject.Line(1),0);
                    case 6
                        putvalue(TrigObject.Line(1),0);
                end
            end
        elseif TimeTrial<(StimDur+PreStim)
            if ~CurrentState
                set(handles.StimTag,'Value',1);
                CurrentState=1;
                CurrentTrialNb=CurrentTrialNb+1;
                set(handles.TrialsDone,'String',num2str(CurrentTrialNb));
                
                % TTL on parallel port options
                switch ParallelPortTrig
                    case 1
                        % We do nothing
                    case 2
                        % We do nothing
                    case 3
                        % We do nothing
                    case 4
                        % We do nothing
                    case 5
                        putvalue(TrigObject.Line(1),1);
                    case 6
                        putvalue(TrigObject.Line(1),1);
                end
                
            end
        else
            if CurrentState
                set(handles.StimTag,'Value',0);
                                
                % TTL on parallel port options
                switch ParallelPortTrig
                    case 1
                        % We do nothing
                    case 2
                        % We do nothing
                    case 3
                        % We do nothing
                    case 4
                        % We do nothing
                    case 5
                        putvalue(TrigObject.Line(1),0);
                    case 6
                        putvalue(TrigObject.Line(1),0);
                end
            end
        end
        
        StopButton=get(handles.StopStim,'Value');
        InLoop=toc(currrentTimer)<Duration && StopButton==1;
        drawnow;
    end
    
    set(handles.StopStim,'Enable','off');
    set(handles.StimTag,'Value',0);
    set(handles.StopStim,'Value',0);
    
    % In case of errors
catch errorObj
    set(handles.StopStim,'Enable','off');
    set(handles.StimTag,'Value',0);
    set(handles.StopStim,'Value',0);
    
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
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


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function StimDur_Callback(hObject, eventdata, handles)
% hObject    handle to StimDur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StimDur as text
%        str2double(get(hObject,'String')) returns contents of StimDur as a double
CalcNbTrials(handles);


% --- Executes during object creation, after setting all properties.
function StimDur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StimDur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in StopStim.
function StopStim_Callback(hObject, eventdata, handles)
% hObject    handle to StopStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StopStim


% --- Executes on button press in StimTag.
function StimTag_Callback(hObject, eventdata, handles)
% hObject    handle to StimTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StimTag


% --- Executes on button press in TriggWait.
function TriggWait_Callback(hObject, eventdata, handles)
% hObject    handle to TriggWait (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TriggWait
