function varargout = Movie_Information(varargin)
% MOVIE_INFORMATION MATLAB code for Movie_Information.fig
%      MOVIE_INFORMATION, by itself, creates a new MOVIE_INFORMATION or raises the existing
%      singleton*.
%
%      H = MOVIE_INFORMATION returns the handle to a new MOVIE_INFORMATION or the handle to
%      the existing singleton*.
%
%      MOVIE_INFORMATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOVIE_INFORMATION.M with the given input arguments.
%
%      MOVIE_INFORMATION('Property','Value',...) creates a new MOVIE_INFORMATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Movie_Information_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Movie_Information_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Movie_Information

% Last Modified by GUIDE v2.5 05-Mar-2012 00:15:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Movie_Information_OpeningFcn, ...
                   'gui_OutputFcn',  @Movie_Information_OutputFcn, ...
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


% --- Executes just before Movie_Information is made visible.
function Movie_Information_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Movie_Information (see VARARGIN)
global SpikeMovieData;

% Choose default command line output for Movie_Information
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Movie_Information wait for user response (see UIRESUME)
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
    NewMovieValue=intersect(1:NumberMovies,Settings.MovieSelectorValue);
    if isempty(NewMovieValue)
        NewMovieValue=1;
    end
    set(handles.MovieSelector,'Value',NewMovieValue);
end

UpdateInfoDisplay(handles);


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');


% This function does the job, ie updating info displyed based on selected
% movie
function UpdateInfoDisplay(handles)
global SpikeMovieData;

if ~isempty(SpikeMovieData)
    SelectMovie=get(handles.MovieSelector,'Value');
    set(handles.SamplFreq,'String',num2str(1/mean(diff(SpikeMovieData(SelectMovie).TimeFrame))));
    set(handles.FrameNumber,'String',num2str(SpikeMovieData(SelectMovie).DataSize(3)));
    set(handles.NbHorizPixels,'String',num2str(SpikeMovieData(SelectMovie).DataSize(2)));
    set(handles.NbVertPixels,'String',num2str(SpikeMovieData(SelectMovie).DataSize(1)));
    set(handles.MemClassMovie,'String',class(SpikeMovieData(SelectMovie).Movie));
    LocalSize=whos('SpikeMovieData');
    set(handles.AllMoviesMem,'String',num2str(LocalSize.bytes/10^6));
    set(handles.PathToFile,'String',SpikeMovieData(SelectMovie).Path);
    set(handles.FileName,'String',SpikeMovieData(SelectMovie).Filename);
    set(handles.Exposure,'String',num2str(mean(SpikeMovieData(SelectMovie).Exposure(:))));
    set(handles.TotalMovieDuration,'String',num2str(max(SpikeMovieData(SelectMovie).TimeFrame)));
    set(handles.HorPixSize,'String',num2str(mean(diff(SpikeMovieData(SelectMovie).Xposition(1,:)))));
    set(handles.VertPixSize,'String',num2str(mean(diff(SpikeMovieData(SelectMovie).Yposition(:,1)))));
end

% --- Outputs from this function are returned to the command line.
function varargout = Movie_Information_OutputFcn(hObject, eventdata, handles) 
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

% --- Executes on selection change in MovieSelector.
function MovieSelector_Callback(hObject, eventdata, handles)
% hObject    handle to MovieSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MovieSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MovieSelector
UpdateInfoDisplay(handles);

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
    


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    UpdateInfoDisplay(handles);
    ValidateValues_Callback(hObject, eventdata, handles);
    set(InterfaceObj,'Enable','on');
    
catch errorObj
    set(InterfaceObj,'Enable','on');
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
end
