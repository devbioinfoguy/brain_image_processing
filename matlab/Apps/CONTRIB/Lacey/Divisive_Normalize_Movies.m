function varargout = Divisive_Normalize_Movies(varargin)
% DIVISIVE_NORMALIZE_MOVIES MATLAB code for Divisive_Normalize_Movies.fig
%      DIVISIVE_NORMALIZE_MOVIES, by itself, creates a new DIVISIVE_NORMALIZE_MOVIES or raises the existing
%      singleton*.
%
%      H = DIVISIVE_NORMALIZE_MOVIES returns the handle to a new DIVISIVE_NORMALIZE_MOVIES or the handle to
%      the existing singleton*.
%
%      DIVISIVE_NORMALIZE_MOVIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIVISIVE_NORMALIZE_MOVIES.M with the given input arguments.
%
%      DIVISIVE_NORMALIZE_MOVIES('Property','Value',...) creates a new DIVISIVE_NORMALIZE_MOVIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Divisive_Normalize_Movies_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Divisive_Normalize_Movies_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Divisive_Normalize_Movies

% Last Modified by GUIDE v2.5 17-Apr-2013 17:00:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Divisive_Normalize_Movies_OpeningFcn, ...
                   'gui_OutputFcn',  @Divisive_Normalize_Movies_OutputFcn, ...
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


% --- Executes just before Divisive_Normalize_Movies is made visible.
function Divisive_Normalize_Movies_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Divisive_Normalize_Movies (see VARARGIN)
global SpikeMovieData;

% Choose default command line output for Offset_Time_Movie
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Offset_Time_Movie wait for user response (see UIRESUME)
% uiwait(handles.figure1);
NumberMovies=length(SpikeMovieData);

if ~isempty(SpikeMovieData)
    for i=1:NumberMovies
        TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
    end
    set(handles.MovieSelector,'String',TextMovie);
    set(handles.BackgroundMovieSelector,'String',TextMovie);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.MovieSelector,'Value',intersect(1:NumberMovies,Settings.MovieSelectorValue));
    set(handles.BackgroundMovieSelector,'Value',intersect(1:NumberMovies,Settings.BackgroundMovieSelectorValue));
end
    

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.BackgroundMovieSelectorValue=get(handles.BackgroundMovieSelector,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Divisive_Normalize_Movies_OutputFcn(hObject, eventdata, handles) 
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
global SpikeMovieData

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');

    % We turn it back on in the end
    Cleanup1=onCleanup(@()set(InterfaceObj,'Enable','on'));

    h=waitbar(0,'Normalising movie...');
    % We close it in the end
    Cleanup2=onCleanup(@()delete(h));
    
    movieSel=get(handles.MovieSelector,'Value');
    backgroundMovieSel=get(handles.BackgroundMovieSelector, 'Value');
    if length(backgroundMovieSel)~=length(movieSel)
        error('Select same number of original and background movies!')
    end
    
    for i=1:length(movieSel)
        
        waitbar((i-1)/length(movieSel), h)
        
        thisBGMovieInd=backgroundMovieSel(i);
        thisMovieInd=movieSel(i);
        
        if sum(size(SpikeMovieData(thisMovieInd).Movie)~=size(SpikeMovieData(thisBGMovieInd).Movie))>0
            error('Original and background movies are not the same size!')
        end
        
        thisNewMovieInd=length(SpikeMovieData)+1;
        
        SpikeMovieData(thisNewMovieInd)=SpikeMovieData(thisMovieInd);
        SpikeMovieData(thisNewMovieInd).Movie=single(SpikeMovieData(thisMovieInd).Movie)./single(SpikeMovieData(thisBGMovieInd).Movie);
        
    end
    
    ValidateValues_Callback(hObject, eventdata, handles);
    
catch errorObj
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
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


% --- Executes on selection change in BackgroundMovieSelector.
function BackgroundMovieSelector_Callback(hObject, eventdata, handles)
% hObject    handle to BackgroundMovieSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns BackgroundMovieSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BackgroundMovieSelector


% --- Executes during object creation, after setting all properties.
function BackgroundMovieSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BackgroundMovieSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
