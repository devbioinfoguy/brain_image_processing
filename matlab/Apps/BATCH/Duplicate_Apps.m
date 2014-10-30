function varargout = Duplicate_Apps(varargin)
% DUPLICATE_APPS MATLAB code for Duplicate_Apps.fig
%      DUPLICATE_APPS, by itself, creates a new DUPLICATE_APPS or raises the existing
%      singleton*.
%
%      H = DUPLICATE_APPS returns the handle to a new DUPLICATE_APPS or the handle to
%      the existing singleton*.
%
%      DUPLICATE_APPS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DUPLICATE_APPS.M with the given input arguments.
%
%      DUPLICATE_APPS('Property','Value',...) creates a new DUPLICATE_APPS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Duplicate_Apps_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Duplicate_Apps_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Duplicate_Apps

% Last Modified by GUIDE v2.5 20-Feb-2012 11:58:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Duplicate_Apps_OpeningFcn, ...
                   'gui_OutputFcn',  @Duplicate_Apps_OutputFcn, ...
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


% --- Executes just before Duplicate_Apps is made visible.
function Duplicate_Apps_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Duplicate_Apps (see VARARGIN)

% Choose default command line output for Duplicate_Apps
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Duplicate_Apps wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global SpikeBatchData;

NumberAppliedApps=length(SpikeBatchData);
if ~isempty(SpikeBatchData)
    for i=1:NumberAppliedApps
        TextBatch{i}=[num2str(i),' - ',SpikeBatchData(i).AppsName];
    end
    set(handles.AppsSelector,'String',TextBatch);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.AppsSelector,'Value',intersect(1:NumberAppliedApps,Settings.AppsSelectorValue));
else
    set(handles.AppsSelector,'Value',[]);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);

% We only save the selected Apps as the string list can change a lot,
% especially if several Duplicate_Apps are looped
Settings.AppsSelectorValue=get(handles.AppsSelector,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Duplicate_Apps_OutputFcn(hObject, eventdata, handles) 
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
global SpikeBatchData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    AppsSel=get(handles.AppsSelector,'Value');
    
    if ~isempty(AppsSel)
        h=waitbar(0,'Duplicate Apps...');
        
        NumberAppliedApps=length(SpikeBatchData);
        SpikeBatchData(NumberAppliedApps+1:NumberAppliedApps+length(AppsSel))=SpikeBatchData(AppsSel);
        
        delete(h);
    end
    
    ValidateValues_Callback(hObject, eventdata, handles);
    set(InterfaceObj,'Enable','on');
    
catch errorObj
    set(InterfaceObj,'Enable','on');
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
    if exist('h','var')
        if ishandle(h)
            delete(h);
        end
    end
end

% --- Executes on selection change in AppsSelector.
function AppsSelector_Callback(hObject, eventdata, handles)
% hObject    handle to AppsSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AppsSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AppsSelector


% --- Executes during object creation, after setting all properties.
function AppsSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AppsSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function ValidateValues_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
