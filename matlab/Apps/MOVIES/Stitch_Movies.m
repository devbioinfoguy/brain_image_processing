function varargout = Stitch_Movies(varargin)
% STITCH_MOVIES MATLAB code for Stitch_Movies.fig
%      STITCH_MOVIES, by itself, creates a new STITCH_MOVIES or raises the existing
%      singleton*.
%
%      H = STITCH_MOVIES returns the handle to a new STITCH_MOVIES or the handle to
%      the existing singleton*.
%
%      STITCH_MOVIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STITCH_MOVIES.M with the given input arguments.
%
%      STITCH_MOVIES('Property','Value',...) creates a new STITCH_MOVIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Stitch_Movies_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Stitch_Movies_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Stitch_Movies

% Last Modified by GUIDE v2.5 17-May-2012 05:13:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Stitch_Movies_OpeningFcn, ...
                   'gui_OutputFcn',  @Stitch_Movies_OutputFcn, ...
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


% --- Executes just before Stitch_Movies is made visible.
function Stitch_Movies_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Stitch_Movies (see VARARGIN)
global SpikeMovieData;

% Choose default command line output for Stitch_Movies
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Stitch_Movies wait for user response (see UIRESUME)
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
    set(handles.OutputMovie,'Value',Settings.OutputMovieValue);
    set(handles.StitchBeh,'Value',Settings.StitchBehValue);
    set(handles.MovieFixedInterval,'String',Settings.MovieFixedIntervalString);    
else
    set(handles.MovieSelector,'Value',[]);
end
    

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.OutputMovieValue=get(handles.OutputMovie,'Value');
Settings.StitchBehValue=get(handles.StitchBeh,'Value');
Settings.MovieFixedIntervalString=get(handles.MovieFixedInterval,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Stitch_Movies_OutputFcn(hObject, eventdata, handles) 
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
    
    MovieSel=get(handles.MovieSelector,'Value');
    
    if ~isempty(MovieSel)
        FinalSize=SpikeMovieData(MovieSel(1)).DataSize;
        for i=2:length(MovieSel)
            LocalSize=SpikeMovieData(MovieSel(i)).DataSize;
            if any(LocalSize(1:2)-FinalSize(1:2))
                error('Selected movies have to be of the same size');
            else
                FinalSize(3)=LocalSize(3)+FinalSize(3);
            end
        end
        
        % We rely on Copy on Write to avoid double memory usage
        TimePixelFinal=zeros(FinalSize,class(SpikeMovieData(MovieSel(1)).TimePixel));
        TimeFrameFinal=zeros([1 FinalSize(3)]);
        MovieFinal=zeros(FinalSize,class(SpikeMovieData(MovieSel(1)).Movie));
        
        % Get the time interval between movies
        switch get(handles.StitchBeh,'Value')
            case 1
                TimeInterval=SpikeMovieData(MovieSel(1)).TimeFrame(2)-SpikeMovieData(MovieSel(1)).TimeFrame(1);
            case 2
                TimeInterval=str2double(get(handles.MovieFixedInterval,'String'));
        end
        
        h=waitbar(0,'Stitching movies...');
        % We close it in the end
        Cleanup2=onCleanup(@()delete(h));
        
        CurrentBeginningFrame=1;
        CurrentBeginningTime=SpikeMovieData(MovieSel(1)).TimeFrame(1);
        TextStichMovie='';
        
        for i=1:length(MovieSel)
            LocalNbFrame=SpikeMovieData(MovieSel(i)).DataSize(3);
            MovieFinal(:,:,CurrentBeginningFrame:(CurrentBeginningFrame+LocalNbFrame-1))=SpikeMovieData(MovieSel(i)).Movie;
            TimePixelFinal(:,:,CurrentBeginningFrame:(CurrentBeginningFrame+LocalNbFrame-1))=SpikeMovieData(MovieSel(i)).TimePixel;
            TimeFrameFinal(CurrentBeginningFrame:(CurrentBeginningFrame+LocalNbFrame-1))=SpikeMovieData(MovieSel(i)).TimeFrame-SpikeMovieData(MovieSel(i)).TimeFrame(1)+CurrentBeginningTime;
            CurrentBeginningFrame=CurrentBeginningFrame+LocalNbFrame;
            CurrentBeginningTime=max(TimeFrameFinal)+TimeInterval;
            TextStichMovie=[TextStichMovie ',' SpikeMovieData(MovieSel(i)).Label.ListText];
            
            waitbar(i/length(MovieSel),h);
        end
        
        % We fill the new movie
        CurrentNbMovie=length(SpikeMovieData);
        SpikeMovieData(CurrentNbMovie+1)=SpikeMovieData(MovieSel(1));
        SpikeMovieData(CurrentNbMovie+1).DataSize=size(MovieFinal);
        SpikeMovieData(CurrentNbMovie+1).Movie=MovieFinal;
        SpikeMovieData(CurrentNbMovie+1).TimePixel=TimePixelFinal;
        SpikeMovieData(CurrentNbMovie+1).TimeFrame=TimeFrameFinal;
        SpikeMovieData(CurrentNbMovie+1).Label.ListText=['Stitch Movie of ' TextStichMovie];
        
        % Deleting old movies if required
        if (get(handles.OutputMovie,'Value')==1)
            SpikeMovieData(MovieSel)=[];
        end
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


% --- Executes on selection change in StitchBeh.
function StitchBeh_Callback(hObject, eventdata, handles)
% hObject    handle to StitchBeh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns StitchBeh contents as cell array
%        contents{get(hObject,'Value')} returns selected item from StitchBeh


% --- Executes during object creation, after setting all properties.
function StitchBeh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StitchBeh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MovieFixedInterval_Callback(hObject, eventdata, handles)
% hObject    handle to MovieFixedInterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MovieFixedInterval as text
%        str2double(get(hObject,'String')) returns contents of MovieFixedInterval as a double


% --- Executes during object creation, after setting all properties.
function MovieFixedInterval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MovieFixedInterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OutputMovie.
function OutputMovie_Callback(hObject, eventdata, handles)
% hObject    handle to OutputMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OutputMovie contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OutputMovie


% --- Executes during object creation, after setting all properties.
function OutputMovie_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OutputMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
