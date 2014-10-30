function varargout = Sync_Folders(varargin)
% SYNC_FOLDERS This is the simplest Apps you can make. It is the best start
% to start a new Apps. Just open this Apps in GUIDE, save it to a new
% name and modify it.
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Sync_Folders

% Last Modified by GUIDE v2.5 10-Mar-2012 20:30:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Sync_Folders_OpeningFcn, ...
                   'gui_OutputFcn',  @Sync_Folders_OutputFcn, ...
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
function Sync_Folders_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Sync_Folders (see VARARGIN)

% Choose default command line output for Sync_Folders
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Here we read from the Settings structure created by the function
% GetSettings. This is used to reload saved settings from a previously
% opened instance of this Apps in the batch list.
if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.SourceFolder,'String',Settings.SourceFolderString);
    set(handles.DestinationFolder,'String',Settings.DestinationFolderString);
    set(handles.IfFileExist,'Value',Settings.IfFileExistValue);
    set(handles.Restrict,'String',Settings.RestrictString);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)

handles=guidata(hObject);
Settings.SourceFolderString=get(handles.SourceFolder,'String');
Settings.DestinationFolderString=get(handles.DestinationFolder,'String');
Settings.IfFileExistValue=get(handles.IfFileExist,'Value');
Settings.RestrictString=get(handles.Restrict,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Sync_Folders_OutputFcn(hObject, eventdata, handles) 
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
    
    h=waitbar(0,'Copying files...');
    SourceFolder=get(handles.SourceFolder,'String');
    DestinationFolder=get(handles.DestinationFolder,'String');
    Restrict=get(handles.Restrict,'String');
    
    listingDir=dir([SourceFolder filesep Restrict]);
    
    for i=1:length(listingDir)
        if ~(listingDir(i).isdir)
            if get(handles.IfFileExist,'Value')==2
                copyfile([SourceFolder filesep listingDir(i).name],DestinationFolder);
            else
                if ~exist([DestinationFolder filesep listingDir(i).name],'file')
                    copyfile([SourceFolder filesep listingDir(i).name],DestinationFolder);
                end
            end
        end
        waitbar(i/length(listingDir));
    end
    
    % We close the waitbar
    delete(h);
    
    % We turn back on the interface
    set(InterfaceObj,'Enable','on');
    
    ValidateValues_Callback(hObject, eventdata, handles);
    
    % In case of errors
catch errorObj
    % We turn back on the interface
    set(InterfaceObj,'Enable','on');
     
    % We close the waitbar if still exist.
    if exist('h','var')
        if ishandle(h)
            delete(h);
        end
    end
    
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


% --- Executes on button press in ChangeDestination.
function ChangeDestination_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeDestination (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open directory interface
NewPath=uigetdir;

% If "Cancel" is selected then return
if isequal(NewPath,0)
    return
else
    set(handles.DestinationFolder,'String',NewPath);
end


% --- Executes on selection change in IfFileExist.
function IfFileExist_Callback(hObject, eventdata, handles)
% hObject    handle to IfFileExist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns IfFileExist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from IfFileExist


% --- Executes during object creation, after setting all properties.
function IfFileExist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IfFileExist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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
