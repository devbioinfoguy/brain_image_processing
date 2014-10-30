function varargout = Movie_Time_Projection(varargin)
% MOVIE_TIME_PROJECTION MATLAB code for Movie_Time_Projection.fig
%      MOVIE_TIME_PROJECTION, by itself, creates a new MOVIE_TIME_PROJECTION or raises the existing
%      singleton*.
%
%      H = MOVIE_TIME_PROJECTION returns the handle to a new MOVIE_TIME_PROJECTION or the handle to
%      the existing singleton*.
%
%      MOVIE_TIME_PROJECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOVIE_TIME_PROJECTION.M with the given input arguments.
%
%      MOVIE_TIME_PROJECTION('Property','Value',...) creates a new MOVIE_TIME_PROJECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Movie_Time_Projection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Movie_Time_Projection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Movie_Time_Projection

% Last Modified by GUIDE v2.5 19-Apr-2012 16:38:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Movie_Time_Projection_OpeningFcn, ...
                   'gui_OutputFcn',  @Movie_Time_Projection_OutputFcn, ...
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


% --- Executes just before Movie_Time_Projection is made visible.
function Movie_Time_Projection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Movie_Time_Projection (see VARARGIN)

% Choose default command line output for Movie_Time_Projection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Movie_Time_Projection wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global SpikeMovieData;

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.MovieSelector,'Value',Settings.MovieSelectorValue);
    set(handles.MovieSelector,'String',Settings.MovieSelectorString);
    set(handles.FrameBegin,'String',Settings.FrameBeginString);
    set(handles.FrameEnd,'String',Settings.FrameEndString);
    set(handles.AveragingType,'Value',Settings.AveragingTypeValue);
    set(handles.ExportImage,'Value',Settings.ExportImageValue);
else
    if ~isempty(SpikeMovieData)
        for i=1:length(SpikeMovieData)
            TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
        end
        
        set(handles.MovieSelector,'String',TextMovie);
        set(handles.FrameEnd,'String',num2str(SpikeMovieData(1).DataSize(3)));
    end
end
FrameEnd_Callback(hObject, eventdata, handles);
FrameBegin_Callback(hObject, eventdata, handles);

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.MovieSelectorString=get(handles.MovieSelector,'String');
Settings.FrameBeginString=get(handles.FrameBegin,'String');
Settings.FrameEndString=get(handles.FrameEnd,'String');
Settings.AveragingTypeValue=get(handles.AveragingType,'Value');
Settings.ExportImageValue=get(handles.ExportImage,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Movie_Time_Projection_OutputFcn(hObject, eventdata, handles) 
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
if isfield(handles,'hFigImage')
    if (ishandle(handles.hFigImage))
        delete(handles.hFigImage);
    end
end
uiresume;


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;
global SpikeGui;
global SpikeImageData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    % We turn it back on in the end
    Cleanup1=onCleanup(@()set(InterfaceObj,'Enable','on'));

    SelectionAveraging=get(handles.AveragingType,'Value');
    MovieSel=get(handles.MovieSelector,'Value');
    
    BeginFrame=str2num(get(handles.FrameBegin,'String'));
    EndFrame=str2num(get(handles.FrameEnd,'String'));
    
    h=waitbar(0,'Computing projection...');
    % We close it in the end
    Cleanup2=onCleanup(@()delete(h));
    
    dividerWaitbar=10^(floor(log10(SpikeMovieData(MovieSel).DataSize(1)))-1);

    % Final datatype is the same as input except for std
    switch SelectionAveraging
        case {1,2,3,5}
            ImageClass=class(SpikeMovieData(MovieSel).Movie);
        case 4
            ImageClass='double';
    end
    NewPic=zeros(SpikeMovieData(MovieSel).DataSize(1:2),ImageClass);
    
    % We scan movie to avoid re-allocating a large matrix in single
    % precision
    for i=1:SpikeMovieData(MovieSel).DataSize(1)
        switch SelectionAveraging
            case 1
                NewPic(i,:)=mean(SpikeMovieData(MovieSel).Movie(i,:,BeginFrame:EndFrame),3);
            case 2
                NewPic(i,:)=max(SpikeMovieData(MovieSel).Movie(i,:,BeginFrame:EndFrame),[],3);
            case 3
                NewPic(i,:)=min(SpikeMovieData(MovieSel).Movie(i,:,BeginFrame:EndFrame),[],3);
            case 4
                for j=1:SpikeMovieData(MovieSel).DataSize(2)
                    NewPic(i,j)=std(double(SpikeMovieData(MovieSel).Movie(i,j,BeginFrame:EndFrame)),1,3);
                end
            case 5
                NewPic(i,:)=median(SpikeMovieData(MovieSel).Movie(i,:,BeginFrame:EndFrame),3);
        end
        if (round(i/dividerWaitbar)==i/dividerWaitbar)
            waitbar(i/SpikeMovieData(MovieSel).DataSize(1),h);
        end
    end
    
    if (isfield(handles,'hFigImage') && ~isempty(handles.hFigImage) && ishandle(handles.hFigImage))
        figure(handles.hFigImage);
    else
        handles.hFigImage=figure('Name','Average Image','NumberTitle','off');
    end
    
    if (ishandle(SpikeGui.hDataDisplay))
        GlobalColorMap = get(SpikeGui.hDataDisplay,'Colormap');
        set(handles.hFigImage,'Colormap',GlobalColorMap)
    end
    
    imagesc(NewPic);
    guidata(hObject, handles);
    
    if get(handles.ExportImage,'Value')
        if isempty(SpikeImageData)
            InitImages();
        end
        
        CurrentNumberImage=length(SpikeImageData);
        SpikeImageData(CurrentNumberImage+1).Image=NewPic;
        SpikeImageData(CurrentNumberImage+1).DataSize=size(SpikeImageData(CurrentNumberImage+1).Image);
        SpikeImageData(CurrentNumberImage+1).Label.CLabel=SpikeMovieData(MovieSel).Label.CLabel;
        SpikeImageData(CurrentNumberImage+1).Label.XLabel=SpikeMovieData(MovieSel).Label.XLabel;
        SpikeImageData(CurrentNumberImage+1).Label.YLabel=SpikeMovieData(MovieSel).Label.YLabel;
        SpikeImageData(CurrentNumberImage+1).Label.ZLabel=SpikeMovieData(MovieSel).Label.ZLabel;
        SpikeImageData(CurrentNumberImage+1).Xposition=SpikeMovieData(MovieSel).Xposition;
        SpikeImageData(CurrentNumberImage+1).Yposition=SpikeMovieData(MovieSel).Yposition;
        SpikeImageData(CurrentNumberImage+1).Zposition=SpikeMovieData(MovieSel).Zposition;
        SpikeImageData(CurrentNumberImage+1).Filename=SpikeMovieData(MovieSel).Filename;
        SpikeImageData(CurrentNumberImage+1).Path=SpikeMovieData(MovieSel).Path;
        SpikeImageData(CurrentNumberImage+1).Label.ListText=['Projection of ' SpikeMovieData(MovieSel).Label.ListText];
    end
    
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
FrameEnd_Callback(hObject, eventdata, handles);
FrameBegin_Callback(hObject, eventdata, handles);


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

function CurrentFrameValue_Callback(hObject, eventdata, handles)
% hObject    handle to CurrentFrameValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CurrentFrameValue as text
%        str2double(get(hObject,'String')) returns contents of CurrentFrameValue as a double

% --- Executes during object creation, after setting all properties.
function CurrentFrameValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentFrameValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function FrameBegin_Callback(hObject, eventdata, handles)
% hObject    handle to FrameBegin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameBegin as text
%        str2double(get(hObject,'String')) returns contents of FrameBegin as a double
CurrentNumber=str2num(get(handles.FrameBegin,'String'));
CurrentNumber=max(1,CurrentNumber);
set(handles.FrameBegin,'String',num2str(CurrentNumber));

% --- Executes during object creation, after setting all properties.
function FrameBegin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameBegin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function FrameEnd_Callback(hObject, eventdata, handles)
% hObject    handle to FrameEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameEnd as text
%        str2double(get(hObject,'String')) returns contents of FrameEnd as a double
global SpikeMovieData;
MovieSel=get(handles.MovieSelector,'Value');

CurrentNumber=str2num(get(handles.FrameEnd,'String'));
CurrentNumber=min(SpikeMovieData(MovieSel).DataSize(3),CurrentNumber);
set(handles.FrameEnd,'String',num2str(CurrentNumber));

% --- Executes during object creation, after setting all properties.
function FrameEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in AveragingType.
function AveragingType_Callback(hObject, eventdata, handles)
% hObject    handle to AveragingType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AveragingType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AveragingType


% --- Executes during object creation, after setting all properties.
function AveragingType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AveragingType (see GCBO)
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


% --- Executes on button press in ExportImage.
function ExportImage_Callback(hObject, eventdata, handles)
% hObject    handle to ExportImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ExportImage
