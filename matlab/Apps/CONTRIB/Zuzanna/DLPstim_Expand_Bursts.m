function varargout = DLPstim_Expand_Bursts(varargin)
% DLPSTIM_EXPAND_BURSTS M-file for DLPstim_Expand_Bursts.fig
%      DLPSTIM_EXPAND_BURSTS, by itself, creates a new DLPSTIM_EXPAND_BURSTS or raises the existing
%      singleton*.
%
%      H = DLPSTIM_EXPAND_BURSTS returns the handle to a new DLPSTIM_EXPAND_BURSTS or the handle to
%      the existing singleton*.
%
%      DLPSTIM_EXPAND_BURSTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DLPSTIM_EXPAND_BURSTS.M with the given input arguments.
%
%      DLPSTIM_EXPAND_BURSTS('Property','Value',...) creates a new DLPSTIM_EXPAND_BURSTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DLPstim_Expand_Bursts_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DLPstim_Expand_Bursts_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DLPstim_Expand_Bursts

% Last Modified by GUIDE v2.5 15-Mar-2012 10:34:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DLPstim_Expand_Bursts_OpeningFcn, ...
                   'gui_OutputFcn',  @DLPstim_Expand_Bursts_OutputFcn, ...
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


% --- Executes just before DLPstim_Expand_Bursts is made visible.
function DLPstim_Expand_Bursts_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DLPstim_Expand_Bursts (see VARARGIN)

% Choose default command line output for DLPstim_Expand_Bursts
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DLPstim_Expand_Bursts wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.BurstSize,'String',Settings.BurstSizeString);
end



% --- Outputs from this function are returned to the command line.
function varargout = DLPstim_Expand_Bursts_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);

Settings.BurstSizeString=get(handles.BurstSize,'String');




% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DLPstim;


%%%%%%%%%%%%%

burstsize=str2num(get(handles.BurstSize,'String'));
 global testbs
testbs=burstsize;

New_Savedxin = expand_cellarray(DLPstim.SaveParam.Savedxin,burstsize);
New_Savedyin = expand_cellarray(DLPstim.SaveParam.Savedyin,burstsize);

DLPstim.SaveParam.Savedxin=New_Savedxin;
DLPstim.SaveParam.Savedyin=New_Savedyin;


ValidateValues_Callback(hObject, eventdata, handles);


% this function does the big job, ie takes as input a 1D cell array and
% expands it using burstsize so that if burstsize=4, for ex, {1} {4} {5}
% becomes {1} {1} {1} {1} {4} {4} {4} {4} {5} {5} {5} {5}

function Output_cellarray = expand_cellarray(Input_cellarray, burstsize, handles)

sz = size(Input_cellarray);
[maxsz,maxsz_ind]=max(sz);
[minsz,minsz_ind]=min(sz);

newmaxsz= maxsz*burstsize; %expand by burstsize the bigger dimension
newminsz=minsz; % keep smaller dimension as was (1)

newsz(minsz_ind)=newminsz;
newsz(maxsz_ind)=newmaxsz;

Output_cellarray = cell(newsz);

for n=1:maxsz
    for k=1:burstsize
   Output_cellarray{((n-1)*burstsize)+k}=Input_cellarray{n}; 
    end
end


% --- Executes on button press in ValidateValues.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;



function BurstSize_Callback(hObject, eventdata, handles)
% hObject    handle to BurstSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BurstSize as text
%        str2double(get(hObject,'String')) returns contents of BurstSize as a double


% --- Executes during object creation, after setting all properties.
function BurstSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BurstSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% Hint: get(hObject,'Value') returns toggle state of Extract
