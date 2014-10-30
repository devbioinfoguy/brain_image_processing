function varargout = Remove_Black_Edges(varargin)
% REMOVE_BLACK_EDGES MATLAB code for Remove_Black_Edges.fig
%      REMOVE_BLACK_EDGES, by itself, creates a new REMOVE_BLACK_EDGES or raises the existing
%      singleton*.
%
%      H = REMOVE_BLACK_EDGES returns the handle to a new REMOVE_BLACK_EDGES or the handle to
%      the existing singleton*.
%
%      REMOVE_BLACK_EDGES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REMOVE_BLACK_EDGES.M with the given input arguments.
%
%      REMOVE_BLACK_EDGES('Property','Value',...) creates a new REMOVE_BLACK_EDGES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Remove_Black_Edges_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Remove_Black_Edges_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Remove_Black_Edges

% Last Modified by GUIDE v2.5 28-Mar-2012 18:18:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Remove_Black_Edges_OpeningFcn, ...
                   'gui_OutputFcn',  @Remove_Black_Edges_OutputFcn, ...
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


% --- Executes just before Remove_Black_Edges is made visible.
function Remove_Black_Edges_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Remove_Black_Edges (see VARARGIN)
global SpikeMovieData;

% Choose default command line output for Remove_Black_Edges
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Remove_Black_Edges wait for user response (see UIRESUME)
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
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Remove_Black_Edges_OutputFcn(hObject, eventdata, handles) 
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
    
    h=waitbar(0,'Removing black edges...');
    
    MovieSel=get(handles.MovieSelector,'Value');
    
    % We project along z and make a nice binary image with 0 on the sides
    AveragePicture=(SpikeMovieData(MovieSel).Movie(:,:,1)==0);
    for i=2:SpikeMovieData(MovieSel).DataSize(3)
        AveragePicture=AveragePicture | (SpikeMovieData(MovieSel).Movie(:,:,i)==0);
    end
    AveragePicture=~AveragePicture;
    
    StatsRegion = regionprops(AveragePicture,'Extrema');
    TopIndice=[1 2 3 8];
    LeftIndice=[1 6 7 8];
    RightIndice=[2 3 4 5];
    BottomIndice=[4 5 6 7];
    
    xmin=ceil(max(StatsRegion.Extrema(LeftIndice,1)));
    ymin=ceil(max(StatsRegion.Extrema(TopIndice,2)));
    xmax=floor(min(StatsRegion.Extrema(RightIndice,1)));
    ymax=floor(min(StatsRegion.Extrema(BottomIndice,2)));
    
    RectCrop=[xmin ymin xmax-xmin ymax-ymin];
    dividerWaitbar=10^(floor(log10(SpikeMovieData(MovieSel).DataSize(3)))-1);
    
    % To get the final size, we just apply on the first figure
    TestMovie=imcrop(SpikeMovieData(MovieSel).Movie(:,:,1),RectCrop);
    FinalNumRows=size(TestMovie,1);
    FinalNumCols=size(TestMovie,2);
    
    % We prallocate the big matrixes.
    NewMovie=zeros([FinalNumRows FinalNumCols SpikeMovieData(MovieSel).DataSize(3)],class(SpikeMovieData(MovieSel).Movie));
    NewTime=zeros([FinalNumRows FinalNumCols SpikeMovieData(MovieSel).DataSize(3)],class(SpikeMovieData(MovieSel).TimePixel));
    
    for i=1:SpikeMovieData(MovieSel).DataSize(3)
        NewMovie(:,:,i)=imcrop(SpikeMovieData(MovieSel).Movie(:,:,i),RectCrop);
        NewTime(:,:,i)=imcrop(SpikeMovieData(MovieSel).TimePixel(:,:,i),RectCrop);
        
        if (round(i/dividerWaitbar)==i/dividerWaitbar)
            waitbar(i/SpikeMovieData(MovieSel).DataSize(3),h);
        end
    end
    
    SpikeMovieData(MovieSel).Movie=NewMovie;
    SpikeMovieData(MovieSel).TimePixel=NewTime;
    SpikeMovieData(MovieSel).DataSize=size(SpikeMovieData(MovieSel).Movie);
    
    % We also adjust the single time matrix
    SpikeMovieData(MovieSel).Xposition=imcrop(SpikeMovieData(MovieSel).Xposition,RectCrop);
    SpikeMovieData(MovieSel).Yposition=imcrop(SpikeMovieData(MovieSel).Yposition,RectCrop);
    SpikeMovieData(MovieSel).Zposition=imcrop(SpikeMovieData(MovieSel).Zposition,RectCrop);
    SpikeMovieData(MovieSel).Exposure=imcrop(SpikeMovieData(MovieSel).Exposure,RectCrop);
    
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
