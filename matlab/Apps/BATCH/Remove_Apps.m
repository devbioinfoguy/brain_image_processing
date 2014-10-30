function varargout = Remove_Apps(varargin)
% REMOVE_APPS MATLAB code for Remove_Apps.fig
%      REMOVE_APPS, by itself, creates a new REMOVE_APPS or raises the existing
%      singleton*.
%
%      H = REMOVE_APPS returns the handle to a new REMOVE_APPS or the handle to
%      the existing singleton*.
%
%      REMOVE_APPS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REMOVE_APPS.M with the given input arguments.
%
%      REMOVE_APPS('Property','Value',...) creates a new REMOVE_APPS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Remove_Apps_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Remove_Apps_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Remove_Apps

% Last Modified by GUIDE v2.5 26-Feb-2012 00:54:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Remove_Apps_OpeningFcn, ...
                   'gui_OutputFcn',  @Remove_Apps_OutputFcn, ...
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


% --- Executes just before Remove_Apps is made visible.
function Remove_Apps_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Remove_Apps (see VARARGIN)
global SpikeBatchData;

% Choose default command line output for Remove_Apps
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Remove_Apps wait for user response (see UIRESUME)
% uiwait(handles.figure1);
NumberApps=length(SpikeBatchData);

if ~isempty(SpikeBatchData)
    for i=1:NumberApps
        TextApp{i}=[num2str(i),' - ',SpikeBatchData(i).Label.ListText];
    end
    set(handles.AppsSelector,'String',TextApp);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.SelectAllApps,'Value',Settings.SelectAllAppsValue);
    set(handles.AppsSelector,'Value',intersect(1:NumberApps,Settings.AppSelectorValue));
else
    set(handles.AppsSelector,'Value',[]);
end    

SelectAllApps_Callback(hObject, eventdata, handles);


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.AppSelectorValue=get(handles.AppsSelector,'Value');
Settings.SelectAllAppsValue=get(handles.SelectAllApps,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Remove_Apps_OutputFcn(hObject, eventdata, handles) 
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
    h=waitbar(0,'Removing movies...');
    
    if (get(handles.SelectAllApps,'Value')==1)
        AppSel=1:length(SpikeBatchData);
    else
        AppSel=get(handles.AppsSelector,'Value');
    end
    
    NumberApps=length(SpikeBatchData);
    KeepApps=setdiff(1:NumberApps,AppSel);
    SpikeBatchData=SpikeBatchData(KeepApps);
    
    delete(h);
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


% --- Executes on button press in SelectAllApps.
function SelectAllApps_Callback(hObject, eventdata, handles)
% hObject    handle to SelectAllApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SelectAllApps
if (get(handles.SelectAllApps,'Value')==1)
    set(handles.AppsSelector,'Enable','off');
else
    set(handles.AppsSelector,'Enable','on');
end
