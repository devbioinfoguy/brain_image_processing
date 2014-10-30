function varargout = Load_Batch_Mat(varargin)
% LOAD_BATCH_MAT MATLAB code for Load_Batch_Mat.fig
%      LOAD_BATCH_MAT, by itself, creates a new LOAD_BATCH_MAT or raises the existing
%      singleton*.
%
%      H = LOAD_BATCH_MAT returns the handle to a new LOAD_BATCH_MAT or the handle to
%      the existing singleton*.
%
%      LOAD_BATCH_MAT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOAD_BATCH_MAT.M with the given input arguments.
%
%      LOAD_BATCH_MAT('Property','Value',...) creates a new LOAD_BATCH_MAT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Load_Batch_Mat_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Load_Batch_Mat_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Load_Batch_Mat

% Last Modified by GUIDE v2.5 04-Mar-2012 23:11:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Load_Batch_Mat_OpeningFcn, ...
                   'gui_OutputFcn',  @Load_Batch_Mat_OutputFcn, ...
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


% --- Executes just before Load_Batch_Mat is made visible.
function Load_Batch_Mat_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Load_Batch_Mat (see VARARGIN)

% Choose default command line output for Load_Batch_Mat
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Load_Batch_Mat wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% We get the input settings to restore state if needed
if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.FilenameShow,'String',Settings.FilenameShowString);
    set(handles.AppsSelectionList,'String',Settings.AppsSelectionListString);
    set(handles.AppsSelectionList,'Value',Settings.AppsSelectionListValue);
    set(handles.LoadBehSelect,'Value',Settings.LoadBehSelectValue);
    set(handles.LoadBehSelect,'String',Settings.LoadBehSelectString);
    set(handles.SelectAllApps,'Value',Settings.SelectAllAppsValue);
end

SelectAllApps_Callback(hObject, eventdata, handles);


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.FilenameShowString=get(handles.FilenameShow,'String');
Settings.AppsSelectionListString=get(handles.AppsSelectionList,'String');
Settings.AppsSelectionListValue=get(handles.AppsSelectionList,'Value');
Settings.LoadBehSelectValue=get(handles.LoadBehSelect,'Value');
Settings.LoadBehSelectString=get(handles.LoadBehSelect,'String');
Settings.SelectAllAppsValue=get(handles.SelectAllApps,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Load_Batch_Mat_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% delete(hObject);

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
    
    if (get(handles.LoadBehSelect,'Value')==1)
        InitBatch();
        BeginApps=1;
    else
        BeginApps=length(SpikeBatchData)+1;
    end
    
    h=waitbar(0,'loading data...');
    LocalFile=get(handles.FilenameShow,'String');
    if exist('matfile')==2
        matObj = matfile(LocalFile);
        info=whos(matObj,'SpikeBatchData');
    else
        info=whos('-file',LocalFile,'SpikeBatchData');
    end
    
    NumberApps=max(info.size);
    
    if (get(handles.SelectAllApps,'Value')==1)
        ListAppsToLoad=1:NumberApps;
    else
        ListAppsToLoad=get(handles.AppsSelectionList,'Value');
    end
    
    if exist('matfile')==2
        SpikeBatchData(BeginApps:(BeginApps-1+length(ListAppsToLoad)))=matObj.SpikeBatchData(1,ListAppsToLoad);
    else
        Tmp=load(LocalFile,'SpikeBatchData');
        SpikeBatchData(BeginApps:(BeginApps-1+length(ListAppsToLoad)))=Tmp.SpikeBatchData(1,ListAppsToLoad);
    end
    
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

% --- Executes on button press in SelectFile.
function SelectFile_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeBatchData;

% Open file path
[filename, pathname] = uigetfile( ...
    {'*.mat','All Files (*.mat)'},'Select MAT File');

% Open file if exist
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
    return
    
    % Otherwise construct the fullfilename and Check and load the file
else
     % To keep the path accessible to futur request
    cd(pathname);
    
    try
        InterfaceObj=findobj(handles.output,'Enable','on');
        set(InterfaceObj,'Enable','off');
        h=waitbar(0,'Checking data...');
        
        LocalFile=fullfile(pathname,filename);
        
        if exist('matfile')==2
            matObj = matfile(LocalFile);
            info=whos(matObj,'SpikeBatchData');
        else
            info=whos('-file',LocalFile,'SpikeBatchData');
        end
        
        if ~isempty(info)
            NumberApps=max(info.size);
            for i=1:NumberApps
                TextBatch{i}=['Apps',' ',num2str(i)];
            end
            set(handles.FilenameShow,'String',LocalFile);
            set(handles.AppsSelectionList,'String',TextBatch);
        else
            msgbox('No Apps in this file');
        end
        
        delete(h);
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


% --- Executes on selection change in AppsSelectionList.
function AppsSelectionList_Callback(hObject, eventdata, handles)
% hObject    handle to AppsSelectionList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AppsSelectionList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AppsSelectionList


% --- Executes during object creation, after setting all properties.
function AppsSelectionList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AppsSelectionList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in SelectAllApps.
function SelectAllApps_Callback(hObject, eventdata, handles)
% hObject    handle to SelectAllApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SelectAllApps
if (get(handles.SelectAllApps,'Value')==1)
    set(handles.AppsSelectionList,'Enable','off');
else
    set(handles.AppsSelectionList,'Enable','on');
end
