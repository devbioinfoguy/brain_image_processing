function varargout = Save_Batch_Mat(varargin)
% SAVE_BATCH_MAT MATLAB code for Save_Batch_Mat.fig
%      SAVE_BATCH_MAT, by itself, creates a new SAVE_BATCH_MAT or raises the existing
%      singleton*.
%
%      H = SAVE_BATCH_MAT returns the handle to a new SAVE_BATCH_MAT or the handle to
%      the existing singleton*.
%
%      SAVE_BATCH_MAT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAVE_BATCH_MAT.M with the given input arguments.
%
%      SAVE_BATCH_MAT('Property','Value',...) creates a new SAVE_BATCH_MAT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Save_Batch_Mat_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Save_Batch_Mat_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Save_Batch_Mat

% Last Modified by GUIDE v2.5 24-Feb-2012 18:43:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Save_Batch_Mat_OpeningFcn, ...
                   'gui_OutputFcn',  @Save_Batch_Mat_OutputFcn, ...
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


% --- Executes just before Save_Batch_Mat is made visible.
function Save_Batch_Mat_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Save_Batch_Mat (see VARARGIN)

% Choose default command line output for Save_Batch_Mat
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Save_Batch_Mat wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global SpikeBatchData;

NumberAppliedApps=length(SpikeBatchData);
if ~isempty(SpikeBatchData)
    for i=1:NumberAppliedApps
        TextBatch{i}=[num2str(i),' - ',SpikeBatchData(i).AppsName];
    end
    set(handles.AppsSelectionList,'String',TextBatch);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.PathText,'String',Settings.PathTextString);
    set(handles.IterateFile,'Value',Settings.IterateFileValue);
    set(handles.OverwriteFile,'Value',Settings.OverwriteFileValue);
    set(handles.AppendFile,'Value',Settings.AppendFileValue);
    set(handles.FileTxt,'Value',Settings.FileTxtValue);
    set(handles.AppsSelectionList,'Value',intersect(1:NumberAppliedApps,Settings.AppsSelectionListValue));
    set(handles.SelectAllApps,'Value',Settings.SelectAllAppsValue);

    handles.Path=Settings.Path;
    handles.BasalFile=Settings.BasalFile;
    guidata(hObject, handles);

    handles=guidata(hObject);
    CreateFileName(hObject,handles);
else
    if ~isempty(SpikeBatchData)
        handles.Path=cd;        
        set(handles.PathText,'String',handles.Path);
        handles.BasalFile='BatchList.mat';
        guidata(hObject, handles);
        CreateFileName(hObject,handles);
    end
end

SelectAllApps_Callback(hObject, eventdata, handles);

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.PathTextString=get(handles.PathText,'String');
Settings.IterateFileValue=get(handles.IterateFile,'Value');
Settings.OverwriteFileValue=get(handles.OverwriteFile,'Value');
Settings.AppendFileValue=get(handles.AppendFile,'Value');
Settings.FileTxtValue=get(handles.FileTxt,'Value');
Settings.AppsSelectionListValue=get(handles.AppsSelectionList,'Value');
Settings.SelectAllAppsValue=get(handles.SelectAllApps,'Value');
Settings.Path=handles.Path;
Settings.BasalFile=handles.BasalFile;


% --- Outputs from this function are returned to the command line.
function varargout = Save_Batch_Mat_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeBatchData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    if (get(handles.SelectAllApps,'Value')==1)
        ListAppsToSave=1:length(SpikeBatchData);
    else
        ListAppsToSave=get(handles.AppsSelectionList,'Value');
    end
    
    FileSaving=fullfile(handles.Path,handles.File);
    
    h=waitbar(0,'Saving...');
    
    % Depending on the existence of the matfile function, we adjust
    % behavior
    if exist('matfile')==2
        matObj = matfile(FileSaving);
        matObj.Properties.Writable = true;
        if (get(handles.AppendFile,'Value')==1)
            info=whos(matObj,'SpikeBatchData');
            if ~isempty(info)
                NumberApps=max(size(matObj,'SpikeBatchData'));
                matObj.SpikeBatchData(1,NumberApps+1:NumberApps+length(ListAppsToSave))=SpikeBatchData(ListAppsToSave);
            else
                matObj.SpikeBatchData=SpikeBatchData(ListAppsToSave);
            end
        else
            matObj.SpikeBatchData=SpikeBatchData(ListAppsToSave);
        end
    else
        % Because does not allow subset of variable to be saved. We need to
        % have a tempory copy. This not so bad thanks to the Copy On Write
        % mechanism.
        SaveOldData=SpikeBatchData;
        
        % At this stage, Matlab duplicate SpikeTraceData in memory through
        % SaveOldData.
        SpikeBatchData=SpikeBatchData(ListAppsToSave);
        
        if (get(handles.AppendFile,'Value')==1)
            save(FileSaving,'SpikeBatchData','-append')
        else
            save(FileSaving,'SpikeBatchData');
        end
        SpikeBatchData=SaveOldData;
    end
    
    waitbar(1,h);
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

% --- Executes on button press in ValidateValues.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;


% --- Executes on button press in ChoosePath.
function ChoosePath_Callback(hObject, eventdata, handles)
% hObject    handle to ChoosePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Oldpath=cd;

cd(handles.Path);

% Open directory interface
NewPath=uigetdir(handles.Path);

cd(Oldpath);

% If "Cancel" is selected then return
if isequal(NewPath,0)
    return
else
    handles.Path=NewPath;
    set(handles.PathText,'String',NewPath);
    guidata(hObject,handles);
    CreateFileName(hObject, handles);
end
   

% Function to create the filename based on the current selected basal
% filename
function CreateFileName(hObject, handles)

FullFilePath=fullfile(handles.Path,handles.BasalFile);
[pathstr, name, ext] = fileparts(FullFilePath);
NewName=[name '.mat'];
CorrespondingMat=fullfile(pathstr,NewName);
while (exist(CorrespondingMat, 'file')==2 && get(handles.IterateFile,'Value')==1)
    I=strfind(name, '-v');
    if ~isempty(I)
        % if it can find the pattern, we take the last one
        IndiceStart=I(length(I));
        Strnumber=str2num(name(IndiceStart+2:length(name)));
        if ~isempty(Strnumber)
            Strnumber=Strnumber+1;
        else
            Strnumber=1;
        end
        name=[name(1:IndiceStart-1) '-v' num2str(Strnumber)];
    else
        Strnumber=1;
        AddString='-v1';
        name=[name AddString];
    end
    NewName=[name '.mat'];
    CorrespondingMat=fullfile(pathstr,NewName);
    FullFilePath=fullfile(handles.Path,NewName);
end
handles.File=NewName;
set(handles.FileTxt,'String',NewName);
guidata(hObject,handles);

% --- Executes on button press in ChangeFilename.
function ChangeFilename_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Oldpath=cd;

cd(handles.Path);

% Open file path
[filename, pathname] = uiputfile( ...
    {'*.mat','All Files (*.mat)'},'Select Data File');

cd(Oldpath);

% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
    return
else
    handles.BasalFile=filename;
    if ~strcmp(handles.Path,pathname)
        handles.Path=pathname;
        set(handles.PathText,'String',pathname);
    end    
        
    guidata(hObject,handles);
    CreateFileName(hObject,handles); 
end


% --- Executes during object creation, after setting all properties.
function ChoosePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChoosePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in OverwriteFile.
function OverwriteFile_Callback(hObject, eventdata, handles)
% hObject    handle to OverwriteFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OverwriteFile
set(handles.AppendFile,'Value',0);
set(handles.IterateFile,'Value',0);
set(handles.OverwriteFile,'Value',1);
CreateFileName(hObject,handles);


% --- Executes on button press in IterateFile.
function IterateFile_Callback(hObject, eventdata, handles)
% hObject    handle to IterateFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IterateFile
set(handles.AppendFile,'Value',0);
set(handles.OverwriteFile,'Value',0);
set(handles.IterateFile,'Value',1);
CreateFileName(hObject,handles);


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


% --- Executes on button press in AppendFile.
function AppendFile_Callback(hObject, eventdata, handles)
% hObject    handle to AppendFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AppendFile
set(handles.IterateFile,'Value',0);
set(handles.OverwriteFile,'Value',0);
set(handles.AppendFile,'Value',1);
CreateFileName(hObject,handles);


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
