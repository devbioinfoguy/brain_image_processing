function varargout = Average_Movies(varargin)
% AVERAGE_MOVIES MATLAB code for Average_Movies.fig
%      AVERAGE_MOVIES, by itself, creates a new AVERAGE_MOVIES or raises the existing
%      singleton*.
%
%      H = AVERAGE_MOVIES returns the handle to a new AVERAGE_MOVIES or the handle to
%      the existing singleton*.
%
%      AVERAGE_MOVIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AVERAGE_MOVIES.M with the given input arguments.
%
%      AVERAGE_MOVIES('Property','Value',...) creates a new AVERAGE_MOVIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Average_Movies_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Average_Movies_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Average_Movies

% Last Modified by GUIDE v2.5 06-Feb-2012 21:35:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Average_Movies_OpeningFcn, ...
                   'gui_OutputFcn',  @Average_Movies_OutputFcn, ...
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


% --- Executes just before Average_Movies is made visible.
function Average_Movies_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Average_Movies (see VARARGIN)

% Choose default command line output for Average_Movies
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Average_Movies wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global SpikeMovieData;

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.MovieSelector,'Value',Settings.MovieSelectorValue);
    set(handles.MovieSelector,'String',Settings.MovieSelectorString);
    set(handles.SelectAllMovies,'Value',Settings.AverageAllMoviesValue);
    set(handles.ClearPrevMovies,'Value',Settings.ClearPrevMoviesValue);
else
    if ~isempty(SpikeMovieData)
        for i=1:length(SpikeMovieData)
            TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
        end
        set(handles.MovieSelector,'String',TextMovie);
        set(handles.MovieSelector,'Value',1);
    end
end
    
SelectAllMovies_Callback(hObject, eventdata, handles);

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.MovieSelectorString=get(handles.MovieSelector,'String');
Settings.AverageAllMoviesValue=get(handles.SelectAllMovies,'Value');
Settings.ClearPrevMoviesValue=get(handles.ClearPrevMovies,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Average_Movies_OutputFcn(hObject, eventdata, handles) 
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
    
    if (get(handles.SelectAllMovies,'Value')==1)
        MovieSel=1:length(SpikeMovieData);
    else
        MovieSel=get(handles.MovieSelector,'Value');
    end
    
    PreviousNumberMovies=length(SpikeMovieData);
    
    SpikeMovieData(PreviousNumberMovies+1)=SpikeMovieData(MovieSel(1));
    
    dividerWaitbar=10^(floor(log10(length(MovieSel)))-1);
    h=waitbar(0,'Averaging Movies ...');
    
    SpikeMovieData(PreviousNumberMovies+1).Movie=single(SpikeMovieData(PreviousNumberMovies+1).Movie);
    
    for i=2:length(MovieSel)
        SpikeMovieData(PreviousNumberMovies+1).Movie=SpikeMovieData(PreviousNumberMovies+1).Movie+single(SpikeMovieData(MovieSel(i)).Movie);
        SpikeMovieData(PreviousNumberMovies+1).TimeFrame=SpikeMovieData(PreviousNumberMovies+1).TimeFrame+SpikeMovieData(MovieSel(i)).TimeFrame;
        if (round(i/dividerWaitbar)==i/dividerWaitbar)
            waitbar(i/length(MovieSel),h);
        end
    end
    SpikeMovieData(PreviousNumberMovies+1).Movie=(SpikeMovieData(PreviousNumberMovies+1).Movie)/length(MovieSel);
    SpikeMovieData(PreviousNumberMovies+1).TimeFrame=(SpikeMovieData(PreviousNumberMovies+1).TimeFrame)/length(MovieSel);
    SpikeMovieData(PreviousNumberMovies+1).Movie=cast(SpikeMovieData(PreviousNumberMovies+1).Movie,class(SpikeMovieData(MovieSel(1)).Movie));
    delete(h);
    
    if (get(handles.ClearPrevMovies,'Value')==1)
        CurrentSize=length(SpikeMovieData);
        SpikeMovieData=SpikeMovieData(PreviousNumberMovies+1:CurrentSize);
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
    set(handles.MovieSelector,'Enable','off');
else
    set(handles.MovieSelector,'Enable','on');
end


% --- Executes on button press in ClearPrevMovies.
function ClearPrevMovies_Callback(hObject, eventdata, handles)
% hObject    handle to ClearPrevMovies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ClearPrevMovies
