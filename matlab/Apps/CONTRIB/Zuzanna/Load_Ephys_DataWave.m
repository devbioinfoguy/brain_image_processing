function varargout = Load_Ephys_DataWave(varargin)
% LOAD_EPHYS_DATAWAVE MATLAB code for Load_Ephys_DataWave.fig
%      LOAD_EPHYS_DATAWAVE, by itself, creates a new LOAD_EPHYS_DATAWAVE or raises the existing
%      singleton*.
%
%      H = LOAD_EPHYS_DATAWAVE returns the handle to a new LOAD_EPHYS_DATAWAVE or the handle to
%      the existing singleton*.
%
%      LOAD_EPHYS_DATAWAVE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOAD_EPHYS_DATAWAVE.M with the given input arguments.
%
%      LOAD_EPHYS_DATAWAVE('Property','Value',...) creates a new LOAD_EPHYS_DATAWAVE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Load_Ephys_DataWave_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Load_Ephys_DataWave_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Load_Ephys_DataWave

% Last Modified by GUIDE v2.5 01-Mar-2012 15:19:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Load_Ephys_DataWave_OpeningFcn, ...
    'gui_OutputFcn',  @Load_Ephys_DataWave_OutputFcn, ...
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


% --- Executes just before Load_Ephys_DataWave is made visible.
function Load_Ephys_DataWave_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Load_Ephys_DataWave (see VARARGIN)

% Choose default command line output for Load_Ephys_DataWave
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Load_Ephys_DataWave wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.FilenameShow,'String',Settings.FilenameShowString);
    set(handles.StartEp,'String',Settings.StartEpString);
    set(handles.EndEp,'String',Settings.EndEpString);
    set(handles.ChanNb,'String',Settings.ChanNbString);
    set(handles.HeaderLines,'String',Settings.HeaderLinesString);
    set(handles.TimeUnit,'String',Settings.TimeUnitString);
    set(handles.LoadBehSelect,'Value',Settings.LoadBehSelectValue);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.FilenameShowString=get(handles.FilenameShow,'String');
Settings.StartEpString=get(handles.StartEp,'String');
Settings.EndEpString=get(handles.EndEp,'String');
Settings.ChanNbString=get(handles.ChanNb,'String');
Settings.HeaderLinesString=get(handles.HeaderLines,'String');
Settings.TimeUnitString=get(handles.TimeUnit,'String');
Settings.LoadBehSelectValue=get(handles.LoadBehSelect,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Load_Ephys_DataWave_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ValidateValues.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeTraceData;

if (1==get(handles.LoadBehSelect,'Value'))
    InitTraces();
    BeginTrace=1;
else
    BeginTrace=length(SpikeTraceData)+1;
end

[pathstr, name, ext] = fileparts(get(handles.FilenameShow,'String'));

SpikeTraceData(BeginTrace).Path=pathstr;
SpikeTraceData(BeginTrace).Filename=[name ext];

EphysLoader_Datawave(BeginTrace,handles);
ValidateValues_Callback(hObject, eventdata, handles);


% this function does the big job, ie loading the data from files and
% creating the associated matrix
function EphysLoader_Datawave(BeginTrace,handles)
global SpikeTraceData;
global savefile_epstart;
global savefile_eplast;
global savefile;

h=waitbar(0,'Reading file');

fileInLoading=fullfile(SpikeTraceData(BeginTrace).Path,SpikeTraceData(BeginTrace).Filename);


chan=str2num(get(handles.ChanNb,'String'));
first_ep=str2num(get(handles.StartEp,'String'));
last_ep=str2num(get(handles.EndEp,'String'));
timeunit=str2num(get(handles.TimeUnit,'String'));

[savepath,savefile,ext]=fileparts(fileInLoading)
savefile=[savepath '\' savefile]
savefile_epstart=first_ep;
savefile_eplast=last_ep;

file_id = fopen(fileInLoading);
tline = fgetl(file_id);

n=1; %counter for loaded episodes

%data format
switch chan
    case 2
        format = '%n %n';
    case 3
        format = '%n %n %n';
    case 4
        format = '%n %n %n %n';
    case 5
        format = '%n %n %n %n %n';
    case 6
        format = '%n %n %n %n %n %n';
end

while ischar(tline)
    
    if n==1
        data = textscan(file_id, format, 'Delimiter', '\t', 'HeaderLines',11);
    else
        data = textscan(file_id, format, 'Delimiter', '\t', 'HeaderLines',12);
    end
    
    if n>= first_ep && n<= last_ep
        
        i = BeginTrace+(chan-1)*(n-first_ep)  ;
        %counter for SpikeTraceData, starts at BeginTrace (usually 1), goes in steps of chan-1 (usually two, V and Stim)
        
        m = cell2mat(data);
        tot_pts = size(m,1);
        
        % each episode generates as many SpikeTraceData instances as there are channels -1 (for the time channel):
        for k=0:chan-2
            label=['chan:' int2str(k+2) ' ep:' int2str(n)];
            SpikeTraceData(i+k).Label.ListText=label;
            SpikeTraceData(i+k).DataSize=tot_pts;
            SpikeTraceData(i+k).Trace=m(:,2+k); % start from col. 2 as col. 1 is the time channel
            SpikeTraceData(i+k).XVector=m(:,1)*timeunit/1000; % copy the time channel, converted into seconds
            
            if k==0 % V channel
            SpikeTraceData(i+k).Label.YLabel='mV'; 
            end
            if k==1 % Stim channel
            SpikeTraceData(i+k).Label.YLabel='photodiode signal'; 
            end
            
            SpikeTraceData(i+k).Label.XLabel='s';
            
        end
        
        waitbar(n/(last_ep-first_ep+1),h);
    end
    
    
    tline = fgetl(file_id);
    n = n+1;
    
end

n-1

% We close the file in the end
fclose(file_id);


close(h);

% --- Executes on button press in SelectFile.
function SelectFile_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeTraceData;

% Open file path
[filename, pathname] = uigetfile( ...
    {'*.asc;*.txt','TXT Files (*.asc, *.txt)'},'Select TXT File');

% Open file if exist
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
    return
    
    % Otherwise construct, display and store the fullfilename
else
    % To keep the path accessible to futur request
    cd(pathname);
    set(handles.FilenameShow,'String',fullfile(pathname,filename));
end


function StartEp_Callback(hObject, eventdata, handles)
% hObject    handle to StartEp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartEp as text
%        str2double(get(hObject,'String')) returns contents of StartEp as a double


% --- Executes during object creation, after setting all properties.
function StartEp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartEp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EndEp_Callback(hObject, eventdata, handles)
% hObject    handle to EndEp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EndEp as text
%        str2double(get(hObject,'String')) returns contents of EndEp as a double



% --- Executes during object creation, after setting all properties.
function EndEp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EndEp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ChanNb_Callback(hObject, eventdata, handles)
% hObject    handle to ChanNb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ChanNb as text
%        str2double(get(hObject,'String')) returns contents of ChanNb as a double


% --- Executes during object creation, after setting all properties.
function ChanNb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChanNb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in LoadBehSelect.
function LoadBehSelect_Callback(hObject, eventdata, handles)
% hObject    handle to LoadBehSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LoadBehSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LoadBehSelect


% --- Executes during object creation, after setting all properties.
function LoadBehSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LoadBehSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HeaderLines_Callback(hObject, eventdata, handles)
% hObject    handle to HeaderLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HeaderLines as text
%        str2double(get(hObject,'String')) returns contents of HeaderLines as a double


% --- Executes during object creation, after setting all properties.
function HeaderLines_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HeaderLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeUnit_Callback(hObject, eventdata, handles)
% hObject    handle to TimeUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeUnit as text
%        str2double(get(hObject,'String')) returns contents of TimeUnit as a double


% --- Executes during object creation, after setting all properties.
function TimeUnit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
