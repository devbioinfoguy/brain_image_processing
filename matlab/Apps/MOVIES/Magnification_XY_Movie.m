function varargout = Magnification_XY_Movie(varargin)
% MAGNIFICATION_XY_MOVIE MATLAB code for Magnification_XY_Movie.fig
%      MAGNIFICATION_XY_MOVIE, by itself, creates a new MAGNIFICATION_XY_MOVIE or raises the existing
%      singleton*.
%
%      H = MAGNIFICATION_XY_MOVIE returns the handle to a new MAGNIFICATION_XY_MOVIE or the handle to
%      the existing singleton*.
%
%      MAGNIFICATION_XY_MOVIE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAGNIFICATION_XY_MOVIE.M with the given input arguments.
%
%      MAGNIFICATION_XY_MOVIE('Property','Value',...) creates a new MAGNIFICATION_XY_MOVIE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Magnification_XY_Movie_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Magnification_XY_Movie_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Magnification_XY_Movie

% Last Modified by GUIDE v2.5 02-May-2012 18:01:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Magnification_XY_Movie_OpeningFcn, ...
                   'gui_OutputFcn',  @Magnification_XY_Movie_OutputFcn, ...
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


% --- Executes just before Magnification_XY_Movie is made visible.
function Magnification_XY_Movie_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Magnification_XY_Movie (see VARARGIN)
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
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.MovieSelector,'Value',intersect(1:NumberMovies,Settings.MovieSelectorValue));
    set(handles.MultiplyX,'String',MultiplyXString);
    set(handles.MultiplyY,'String',MultiplyYString);
end
    

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.MovieSelectorString=get(handles.MovieSelector,'String');
Settings.MultiplyXString=get(handles.MultiplyX,'String');
Settings.MultiplyYString=get(handles.MultiplyY,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Magnification_XY_Movie_OutputFcn(hObject, eventdata, handles) 
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

    % We turn it back on in the end
    Cleanup1=onCleanup(@()set(InterfaceObj,'Enable','on'));

    h=waitbar(0,'Scaling movie...');
    % We close it in the end
    Cleanup2=onCleanup(@()delete(h));
    
    MovieSel=get(handles.MovieSelector,'Value');
    
    ScaleX=str2num(get(handles.MultiplyX,'String'));
    ScaleY=str2num(get(handles.MultiplyY,'String'));
    
    SpikeMovieData(MovieSel).Xposition=ScaleX*SpikeMovieData(MovieSel).Xposition;
    SpikeMovieData(MovieSel).Yposition=ScaleY*SpikeMovieData(MovieSel).Yposition;
    
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



function MultiplyX_Callback(hObject, eventdata, handles)
% hObject    handle to MultiplyX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MultiplyX as text
%        str2double(get(hObject,'String')) returns contents of MultiplyX as a double


% --- Executes during object creation, after setting all properties.
function MultiplyX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MultiplyX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MultiplyY_Callback(hObject, eventdata, handles)
% hObject    handle to MultiplyY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MultiplyY as text
%        str2double(get(hObject,'String')) returns contents of MultiplyY as a double


% --- Executes during object creation, after setting all properties.
function MultiplyY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MultiplyY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
