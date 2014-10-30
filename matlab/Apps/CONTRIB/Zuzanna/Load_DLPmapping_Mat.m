function varargout = Load_DLPmapping_Mat(varargin)
% LOAD_DLPMAPPING_MAT MATLAB code for Load_DLPmapping_Mat.fig
%      LOAD_DLPMAPPING_MAT, by itself, creates a new LOAD_DLPMAPPING_MAT or raises the existing
%      singleton*.
%
%      H = LOAD_DLPMAPPING_MAT returns the handle to a new LOAD_DLPMAPPING_MAT or the handle to
%      the existing singleton*.
%
%      LOAD_DLPMAPPING_MAT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOAD_DLPMAPPING_MAT.M with the given input arguments.
%
%      LOAD_DLPMAPPING_MAT('Property','Value',...) creates a new LOAD_DLPMAPPING_MAT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Load_DLPmapping_Mat_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Load_DLPmapping_Mat_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Load_DLPmapping_Mat

% Last Modified by GUIDE v2.5 07-May-2012 11:48:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Load_DLPmapping_Mat_OpeningFcn, ...
    'gui_OutputFcn',  @Load_DLPmapping_Mat_OutputFcn, ...
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


% --- Executes just before Load_DLPmapping_Mat is made visible.
function Load_DLPmapping_Mat_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Load_DLPmapping_Mat (see VARARGIN)

% Choose default command line output for Load_DLPmapping_Mat
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Load_DLPmapping_Mat wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.FilenameShow,'String',Settings.FilenameShowString);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.FilenameShowString=get(handles.FilenameShow,'String');
Settings.Stim_Nb=get(handles.Stim_Nb,'String');

% --- Outputs from this function are returned to the command line.
function varargout = Load_DLPmapping_Mat_OutputFcn(hObject, eventdata, handles)
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

global DLPstim
global LoadedDLP

filename = get(handles.FilenameShow,'String');


DLPstim = load(filename);
LoadedDLP =1;

sz=length(DLPstim.SaveParam.Savedxin);
set(handles.Stim_Nb,'String',int2str(sz));


% ValidateValues_Callback(hObject, eventdata, handles);




% --- Executes on button press in SelectFile.
function SelectFile_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeTraceData;

% Open file path
[filename, pathname] = uigetfile( ...
    {'*.mat','MAT Files (*.mat)'},'Select MAT File');

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





function Stim_Nb_Callback(hObject, eventdata, handles)
% hObject    handle to Stim_Nb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Stim_Nb as text
%        str2double(get(hObject,'String')) returns contents of Stim_Nb as a double


% --- Executes during object creation, after setting all properties.
function Stim_Nb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Stim_Nb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
