function varargout = Load_Trace_Mat_ZP(varargin)
% LOAD_TRACE_MAT_ZP MATLAB code for Load_Trace_Mat_ZP.fig
%      LOAD_TRACE_MAT_ZP, by itself, creates a new LOAD_TRACE_MAT_ZP or raises the existing
%      singleton*.
%
%      H = LOAD_TRACE_MAT_ZP returns the handle to a new LOAD_TRACE_MAT_ZP or the handle to
%      the existing singleton*.
%
%      LOAD_TRACE_MAT_ZP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOAD_TRACE_MAT_ZP.M with the given input arguments.
%
%      LOAD_TRACE_MAT_ZP('Property','Value',...) creates a new LOAD_TRACE_MAT_ZP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Load_Trace_Mat_ZP_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Load_Trace_Mat_ZP_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Load_Trace_Mat_ZP

% Last Modified by GUIDE v2.5 01-Jun-2012 11:12:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Load_Trace_Mat_ZP_OpeningFcn, ...
                   'gui_OutputFcn',  @Load_Trace_Mat_ZP_OutputFcn, ...
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


% --- Executes just before Load_Trace_Mat_ZP is made visible.
function Load_Trace_Mat_ZP_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Load_Trace_Mat_ZP (see VARARGIN)

% Choose default command line output for Load_Trace_Mat_ZP
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Load_Trace_Mat_ZP wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% We get the input settings to restore state if needed
if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.FilenameShow,'String',Settings.FilenameShowString);
    set(handles.TraceSelectionList,'String',Settings.TraceSelectionListString);
    set(handles.TraceSelectionList,'Value',Settings.TraceSelectionListValue);
    set(handles.LoadBehSelect,'Value',Settings.LoadBehSelectValue);
    set(handles.LoadBehSelect,'String',Settings.LoadBehSelectString);
    set(handles.SelectAllTrace,'Value',Settings.SelectAllTraceValue);
end
    
SelectAllTrace_Callback(hObject, eventdata, handles);

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.FilenameShowString=get(handles.FilenameShow,'String');
Settings.TraceSelectionListString=get(handles.TraceSelectionList,'String');
Settings.TraceSelectionListValue=get(handles.TraceSelectionList,'Value');
Settings.LoadBehSelectValue=get(handles.LoadBehSelect,'Value');
Settings.LoadBehSelectString=get(handles.LoadBehSelect,'String');
Settings.SelectAllTraceValue=get(handles.SelectAllTrace,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Load_Trace_Mat_ZP_OutputFcn(hObject, eventdata, handles) 
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
global SpikeTraceData;
global savefile;
global savefile_epstart;
global savefile_eplast;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    if (get(handles.LoadBehSelect,'Value')==1)
        InitTraces();
        BeginTrace=1;
    else
        BeginTrace=length(SpikeTraceData)+1;
    end
    
    h=waitbar(0,'loading data...');
    LocalFile=get(handles.FilenameShow,'String');
    
    if (get(handles.SelectAllTrace,'Value')==1)
        
        if exist('matfile')==2
            matObj = matfile(LocalFile);
            info=whos(matObj,'SpikeTraceData');
        else
            info=whos('-file',LocalFile,'SpikeTraceData');
        end
        
        NumberTrace=max(info.size);
        
        ListTraceToLoad=1:NumberTrace;
    else
        ListTraceToLoad=get(handles.TraceSelectionList,'Value');
    end
    
    if exist('matfile')==2
        matObj = matfile(LocalFile);
        SpikeTraceData(BeginTrace:(BeginTrace-1+length(ListTraceToLoad)))=matObj.SpikeTraceData(1,ListTraceToLoad);
    else
        Tmp=load(LocalFile,'SpikeTraceData');
        SpikeTraceData(BeginTrace:(BeginTrace-1+length(ListTraceToLoad)))=Tmp.SpikeTraceData(1,ListTraceToLoad);
    end
    
    delete(h);
    
    [savepath,savefile,ext]=fileparts(LocalFile)
    savefile=[savepath '\' savefile]
    savefile_epstart=0;
    savefile_eplast=0;
    
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
global SpikeTraceData;


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
            info=whos(matObj,'SpikeTraceData');
        else
            info=whos('-file',LocalFile,'SpikeTraceData');
        end
        
        if ~isempty(info)
            NumberTrace=max(info.size);
            for i=1:NumberTrace
                TextTrace{i}=['Trace',' ',num2str(i)];
            end
            set(handles.FilenameShow,'String',LocalFile);
            set(handles.TraceSelectionList,'String',TextTrace);
        else
            msgbox('No Traces in this file');
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


% --- Executes on selection change in TraceSelectionList.
function TraceSelectionList_Callback(hObject, eventdata, handles)
% hObject    handle to TraceSelectionList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TraceSelectionList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TraceSelectionList


% --- Executes during object creation, after setting all properties.
function TraceSelectionList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TraceSelectionList (see GCBO)
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


% --- Executes on button press in SelectAllTrace.
function SelectAllTrace_Callback(hObject, eventdata, handles)
% hObject    handle to SelectAllTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SelectAllTrace
if (get(handles.SelectAllTrace,'Value')==1)
    set(handles.TraceSelectionList,'Enable','off');
else
    set(handles.TraceSelectionList,'Enable','on');
end
