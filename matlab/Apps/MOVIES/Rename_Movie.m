function varargout = Rename_Movie(varargin)
% RENAME_MOVIE MATLAB code for Rename_Movie.fig
%      RENAME_MOVIE, by itself, creates a new RENAME_MOVIE or raises the existing
%      singleton*.
%
%      H = RENAME_MOVIE returns the handle to a new RENAME_MOVIE or the handle to
%      the existing singleton*.
%
%      RENAME_MOVIE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RENAME_MOVIE.M with the given input arguments.
%
%      RENAME_MOVIE('Property','Value',...) creates a new RENAME_MOVIE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Rename_Movie_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Rename_Movie_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Rename_Movie

% Last Modified by GUIDE v2.5 25-Feb-2012 23:49:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Rename_Movie_OpeningFcn, ...
                   'gui_OutputFcn',  @Rename_Movie_OutputFcn, ...
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


% --- Executes just before Rename_Movie is made visible.
function Rename_Movie_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Rename_Movie (see VARARGIN)

% Choose default command line output for Rename_Movie
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Rename_Movie wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global SpikeMovieData;
NumberMovies=length(SpikeMovieData);

if ~isempty(SpikeMovieData)
    for i=1:length(SpikeMovieData)
        TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
    end
    set(handles.OldName,'String',TextMovie);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.AddPrefix,'String',Settings.AddPrefixString);
    set(handles.AddSuffix,'String',Settings.AddSuffixString);
    set(handles.Rename,'String',Settings.RenameString);
    set(handles.OldName,'Value',intersect(1:NumberMovies,Settings.OldNameValue));  
    set(handles.SelectAll,'Value',Settings.SelectAllValue);
end

SelectAll_Callback(hObject, eventdata, handles);
Rename_Callback(hObject, eventdata, handles);


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.AddPrefixString=get(handles.AddPrefix,'String');
Settings.AddSuffixString=get(handles.AddSuffix,'String');
Settings.RenameString=get(handles.Rename,'String');
Settings.OldNameValue=get(handles.OldName,'Value');
Settings.SelectAllValue=get(handles.SelectAll,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Rename_Movie_OutputFcn(hObject, eventdata, handles) 
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
global SpikeMovieData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    if ~isempty(SpikeMovieData)
        
        h=waitbar(0,'Renaming...');
        
        SelectAll=get(handles.SelectAll,'Value');
        ToChangeSelection=get(handles.OldName,'Value');
        Prefix=get(handles.AddPrefix,'String');
        Rename=get(handles.Rename,'String');
        Suffix=get(handles.AddSuffix,'String');
        
        for i=1:length(SpikeMovieData)
            if (ismember(i,ToChangeSelection) || SelectAll)
                if isempty(Rename)
                    SpikeMovieData(i).Label.ListText=[Prefix,SpikeMovieData(i).Label.ListText,Suffix];
                else
                    SpikeMovieData(i).Label.ListText=[Prefix,Rename,Suffix];
                end
            end
        end
        
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


% --- Executes on selection change in OldName.
function OldName_Callback(hObject, eventdata, handles)
% hObject    handle to OldName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OldName contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OldName
Rename_Callback(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function OldName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OldName (see GCBO)
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


% --- Executes on button press in SelectAllMovies.
function SelectAllMovies_Callback(hObject, eventdata, handles)
% hObject    handle to SelectAllMovies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SelectAllMovies
if (get(handles.SelectAllMovies,'Value')==1)
    set(handles.OldName,'Enable','off');
else
    set(handles.OldName,'Enable','on');
end


% --- Executes on selection change in NewName.
function NewName_Callback(hObject, eventdata, handles)
% hObject    handle to NewName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NewName contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NewName


% --- Executes during object creation, after setting all properties.
function NewName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NewName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in NamingOptText.
function NamingOpt_Callback(hObject, eventdata, handles)
% hObject    handle to NamingOptText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NamingOptText contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NamingOptText


% --- Executes during object creation, after setting all properties.
function NamingOptText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NamingOptText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AddPrefix_Callback(hObject, eventdata, handles)
% hObject    handle to AddPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AddPrefix as text
%        str2double(get(hObject,'String')) returns contents of AddPrefix as a double
Rename_Callback(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function AddPrefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AddPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Rename_Callback(hObject, eventdata, handles)
% hObject    handle to Rename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Rename as text
%        str2double(get(hObject,'String')) returns contents of Rename as a double
global SpikeMovieData;

if ~isempty(SpikeMovieData)
    SelectAll=get(handles.SelectAll,'Value');
    ToChangeSelection=get(handles.OldName,'Value');
    Prefix=get(handles.AddPrefix,'String');
    Rename=get(handles.Rename,'String');
    Suffix=get(handles.AddSuffix,'String');
    
    for i=1:length(SpikeMovieData)
        if (ismember(i,ToChangeSelection) || SelectAll)
            if isempty(Rename)
                NewNameList{i}=[num2str(i),' - ',Prefix,SpikeMovieData(i).Label.ListText,Suffix];
            else
                NewNameList{i}=[num2str(i),' - ',Prefix,Rename,Suffix];
            end
        else
            NewNameList{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
        end
    end
    set(handles.NewName,'String',NewNameList);
end

% --- Executes during object creation, after setting all properties.
function Rename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AddSuffix_Callback(hObject, eventdata, handles)
% hObject    handle to AddSuffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AddSuffix as text
%        str2double(get(hObject,'String')) returns contents of AddSuffix as a double
Rename_Callback(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function AddSuffix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AddSuffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SelectAll.
function SelectAll_Callback(hObject, eventdata, handles)
% hObject    handle to SelectAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SelectAll
if (get(handles.SelectAll,'Value')==1)
    set(handles.OldName,'Enable','off');
else
    set(handles.OldName,'Enable','on');
end
Rename_Callback(hObject, eventdata, handles);
