function varargout = Find_Last_Created_File(varargin)
% FIND_LAST_CREATED_FILE This is the simplest Apps you can make. It is the best start
% to start a new Apps. Just open this Apps in GUIDE, save it to a new
% name and modify it.
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Find_Last_Created_File

% Last Modified by GUIDE v2.5 05-Apr-2012 14:32:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Find_Last_Created_File_OpeningFcn, ...
                   'gui_OutputFcn',  @Find_Last_Created_File_OutputFcn, ...
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


% This function is created by GUIDE for every GUI. Just put here all
% the code that you want to be executed before the GUI is made visible. 
function Find_Last_Created_File_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Find_Last_Created_File (see VARARGIN)

% Choose default command line output for Find_Last_Created_File
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Here we read from the Settings structure created by the function
% GetSettings. This is used to reload saved settings from a previously
% opened instance of this Apps in the batch list.
if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.SourceFolder,'String',Settings.SourceFolderString);
    set(handles.FileFolder,'String',Settings.FileFolderString);
    set(handles.Restrict,'String',Settings.RestrictString);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)

handles=guidata(hObject);
Settings.SourceFolderString=get(handles.SourceFolder,'String');
Settings.FileFolderString=get(handles.FileFolder,'String');
Settings.RestrictString=get(handles.Restrict,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Find_Last_Created_File_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.output;


% 'ApplyApps' is the main function of your Apps. It is launched by the
% Main interface when using batch mode. 
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    % We turn it back on in the end
    Cleanup1=onCleanup(@()set(InterfaceObj,'Enable','on'));
    
    SourceFolder=get(handles.SourceFolder,'String');
    Restrict=get(handles.Restrict,'String');
    
    listingDir=dir([SourceFolder filesep Restrict]);
    
    for i=1:length(listingDir)
        FileNumber(i)=listingDir(i).datenum;
    end
    
    [ValueMax,IndexMax]=max(FileNumber);
    
    LastFile=listingDir(IndexMax).name;

    set(handles.FileFolder,'String',LastFile);
        
    % In case of errors
catch errorObj
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
end


% 'ValidateValues' is executed in the end to trigger the end of your Apps and
% check all unneeded windows are closed.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% We give back control to the Main interface.
uiresume;


% This function is executed when the object Text is modified.
function Text_Callback(hObject, eventdata, handles)
% hObject    handle to Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Text as text
%        str2double(get(hObject,'String')) returns contents of Text as a double


% --- Executes during object creation, after setting all properties.
function Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% This function opens the help that is written in the header of this M file.
function OpenHelp_Callback(hObject, eventdata, handles)
% hObject    handle to OpenHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CurrentMfilePath = mfilename('fullpath');
[PathToM, name, ext] = fileparts(CurrentMfilePath);
eval(['doc ',name]);


function Restrict_Callback(hObject, eventdata, handles)
% hObject    handle to Restrict (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Restrict as text
%        str2double(get(hObject,'String')) returns contents of Restrict as a double


% --- Executes during object creation, after setting all properties.
function Restrict_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Restrict (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ChangeSource.
function ChangeSource_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open directory interface
NewPath=uigetdir;

% If "Cancel" is selected then return
if isequal(NewPath,0)
    return
else
    set(handles.SourceFolder,'String',NewPath);
end