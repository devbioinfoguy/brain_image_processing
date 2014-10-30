function varargout = Average_Movie_Mat(varargin)
% AVERAGE_MOVIE_MAT MATLAB code for Average_Movie_Mat.fig
%      AVERAGE_MOVIE_MAT, by itself, creates a new AVERAGE_MOVIE_MAT or raises the existing
%      singleton*.
%
%      H = AVERAGE_MOVIE_MAT returns the handle to a new AVERAGE_MOVIE_MAT or the handle to
%      the existing singleton*.
%
%      AVERAGE_MOVIE_MAT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AVERAGE_MOVIE_MAT.M with the given input arguments.
%
%      AVERAGE_MOVIE_MAT('Property','Value',...) creates a new AVERAGE_MOVIE_MAT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Average_Movie_Mat_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Average_Movie_Mat_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Average_Movie_Mat

% Last Modified by GUIDE v2.5 06-Feb-2012 21:34:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Average_Movie_Mat_OpeningFcn, ...
                   'gui_OutputFcn',  @Average_Movie_Mat_OutputFcn, ...
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


% --- Executes just before Average_Movie_Mat is made visible.
function Average_Movie_Mat_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Average_Movie_Mat (see VARARGIN)

% Choose default command line output for Average_Movie_Mat
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Average_Movie_Mat wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% We get the input settings to restore state if needed
if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.FileSelectionList,'String',Settings.FileSelectionListString);
    set(handles.FileSelectionList,'Value',Settings.FileSelectionListValue);
    set(handles.MovieSelector,'String',Settings.MovieSelectionListString);
    set(handles.MovieSelector,'Value',Settings.MovieSelectionListValue);
    set(handles.LoadBehSelect,'Value',Settings.LoadBehSelectValue);
end
    
% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.FileSelectionListString=get(handles.FileSelectionList,'String');
Settings.FileSelectionListValue=get(handles.FileSelectionList,'Value');
Settings.MovieSelectionListString=get(handles.MovieSelector,'String');
Settings.MovieSelectionListValue=get(handles.MovieSelector,'Value');
Settings.LoadBehSelectValue=get(handles.LoadBehSelect,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Average_Movie_Mat_OutputFcn(hObject, eventdata, handles) 
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
global SpikeMovieData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    if (get(handles.LoadBehSelect,'Value')==1)
        BeginMovie=1;
    else
        BeginMovie=length(SpikeMovieData)+1;
    end
    FileList=get(handles.FileSelectionList,'String');
    if ischar(FileList)
        FileList={FileList};
    end
    
    FileListValue=get(handles.FileSelectionList,'Value');
    SelectedFileList=FileList(FileListValue);
    numberFiles=length(FileListValue);
    
    if ~isempty(SelectedFileList)
        MovieList=get(handles.MovieSelector,'Value');
        numberMovies=length(MovieList);
        if ~isempty(MovieList)
            h=waitbar(0,'Averaging data...');
            for k=1:numberMovies
                for i=1:numberFiles
                    matObj = matfile(SelectedFileList{i});
                    TmpStructLocal=matObj.SpikeMovieData(1,MovieList(k));
                    if i==1
                        TmpStruct=TmpStructLocal;
                        TmpStruct.Movie=1/numberFiles*TmpStructLocal.Movie;
                        TmpStruct.TimeFrame=1/numberFiles*TmpStructLocal.TimeFrame;
                        TmpStruct.TimePixel=1/numberFiles*TmpStructLocal.TimePixel;
                        TmpStruct.Exposure=1/numberFiles*TmpStructLocal.Exposure;
                        TmpStruct.Xposition=1/numberFiles*TmpStructLocal.Xposition;
                        TmpStruct.Yposition=1/numberFiles*TmpStructLocal.Yposition;
                        TmpStruct.Zposition=1/numberFiles*TmpStructLocal.Zposition;
                    else
                        if (any(TmpStructLocal.DataSize-TmpStruct.DataSize))
                            errordlg('Averaged movies should be of the same X*Y*T size');
                        else
                            TmpStruct.Movie=TmpStruct.Movie+1/numberFiles*TmpStructLocal.Movie;
                            TmpStruct.TimeFrame=TmpStruct.TimeFrame+1/numberFiles*TmpStructLocal.TimeFrame;
                            TmpStruct.TimePixel=TmpStruct.TimePixel+1/numberFiles*TmpStructLocal.TimePixel;
                            TmpStruct.Exposure=TmpStruct.Exposure+1/numberFiles*TmpStructLocal.Exposure;
                            TmpStruct.Xposition=TmpStruct.Xposition+1/numberFiles*TmpStructLocal.Xposition;
                            TmpStruct.Yposition=TmpStruct.Yposition+1/numberFiles*TmpStructLocal.Yposition;
                            TmpStruct.Zposition=TmpStruct.Zposition+1/numberFiles*TmpStructLocal.Zposition;
                        end
                    end
                    waitbar(((k-1)*numberMovies+i)/(numberFiles*numberMovies),h);
                end
                SpikeMovieData(BeginMovie-1+k)=TmpStruct;
            end
            % We only modified gloval variable when everything has been
            % averaged without errors.
            delete(h);
        end
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

% --- Executes on button press in SelectFile.
function SelectFile_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;

% Open file path
[filename, pathname] = uigetfile( ...
    {'*.mat','All Files (*.mat)'},'Select MAT Files','MultiSelect', 'on');

% Open file if exist
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
    return
    
    % Otherwise construct the fullfilename and Check and load the file
else
    % To keep the path accessible to futur request
    cd(pathname);
    
    ListFile=get(handles.FileSelectionList,'String');
    if isempty(ListFile)
        ListFile={};
    elseif ~iscell(ListFile)
        ListFile={ListFile};
    end
    
    if ~iscell(filename)
        filename={filename};
    end
    oldLength=length(ListFile);
    for i=1:length(filename)
        ListFile{i+oldLength}=fullfile(pathname,filename{i});
    end
    set(handles.FileSelectionList,'String',ListFile);
    
    if isempty(get(handles.MovieSelector,'String'))
        matObj = matfile(ListFile{1});
        NumberMovie=max(size(matObj,'SpikeMovieData'));
        for i=1:NumberMovie
            TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
        end
        
        set(handles.MovieSelector,'String',TextMovie);
        set(handles.MovieSelector,'Value',1:NumberMovie);
    end
    set(handles.FileSelectionList,'Value',1:length(ListFile));
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


% --- Executes on selection change in MovieSelector.
function MovieSelector_Callback(hObject, eventdata, handles)
% hObject    handle to MovieSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MovieSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MovieSelector


% --- Executes during object creation, after setting all properties.
function MovieSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MovieSelector (see GCBO)
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


% --- Executes on selection change in FileSelectionList.
function FileSelectionList_Callback(hObject, eventdata, handles)
% hObject    handle to FileSelectionList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FileSelectionList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FileSelectionList


% --- Executes during object creation, after setting all properties.
function FileSelectionList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileSelectionList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XSize_Callback(hObject, eventdata, handles)
% hObject    handle to XSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XSize as text
%        str2double(get(hObject,'String')) returns contents of XSize as a double


% --- Executes during object creation, after setting all properties.
function XSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function YSize_Callback(hObject, eventdata, handles)
% hObject    handle to YSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YSize as text
%        str2double(get(hObject,'String')) returns contents of YSize as a double


% --- Executes during object creation, after setting all properties.
function YSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FrameNb_Callback(hObject, eventdata, handles)
% hObject    handle to FrameNb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameNb as text
%        str2double(get(hObject,'String')) returns contents of FrameNb as a double


% --- Executes during object creation, after setting all properties.
function FrameNb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameNb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
