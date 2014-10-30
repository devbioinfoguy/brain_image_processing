function varargout = Apply_Image_Movie_v2(varargin)
% APPLY_IMAGE_MOVIE_V2 MATLAB code for Apply_Image_Movie_v2.fig
%      APPLY_IMAGE_MOVIE_V2, by itself, creates a new APPLY_IMAGE_MOVIE_V2 or raises the existing
%      singleton*.
%
%      H = APPLY_IMAGE_MOVIE_V2 returns the handle to a new APPLY_IMAGE_MOVIE_V2 or the handle to
%      the existing singleton*.
%
%      APPLY_IMAGE_MOVIE_V2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in APPLY_IMAGE_MOVIE_V2.M with the given input arguments.
%
%      APPLY_IMAGE_MOVIE_V2('Property','Value',...) creates a new APPLY_IMAGE_MOVIE_V2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Apply_Image_Movie_v2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Apply_Image_Movie_v2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Apply_Image_Movie_v2

% Last Modified by GUIDE v2.5 02-Nov-2012 10:05:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Apply_Image_Movie_v2_OpeningFcn, ...
                   'gui_OutputFcn',  @Apply_Image_Movie_v2_OutputFcn, ...
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


% --- Executes just before Apply_Image_Movie_v2 is made visible.
function Apply_Image_Movie_v2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Apply_Image_Movie_v2 (see VARARGIN)
global SpikeImageData;
global SpikeMovieData;

% Choose default command line output for Apply_Image_Movie_v2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Apply_Image_Movie_v2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
NumberMovies=length(SpikeMovieData);

if ~isempty(SpikeMovieData)
    for i=1:NumberMovies
        TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
    end
    set(handles.MovieSelector,'String',TextMovie);
end

NumberImages=length(SpikeImageData);

if ~isempty(SpikeImageData)
    for i=1:NumberImages
        TextImage{i}=[num2str(i),' - ',SpikeImageData(i).Label.ListText];
    end
    set(handles.ImageSelector,'String',TextImage);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.MovieSelector,'Value',intersect(1:NumberMovies,Settings.MovieSelectorValue));
    set(handles.ImageSelector,'Value',intersect(1:NumberImages,Settings.ImageSelectorValue));
    set(handles.SelectAllImages,'Value',Settings.SelectAllImageValue);
end
    
SelectAllImages_Callback(hObject, eventdata, handles);

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.ImageSelectorValue=get(handles.ImageSelector,'Value');
Settings.SelectAllImageValue=get(handles.SelectAllImages,'Value');
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Apply_Image_Movie_v2_OutputFcn(hObject, eventdata, handles) 
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
global SpikeImageData;
global SpikeMovieData;
global SpikeTraceData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    h=waitbar(0,'Applying images...');
    
    if (get(handles.SelectAllImages,'Value')==1)
        ImageSel=1:length(SpikeImageData);
    else
        ImageSel=get(handles.ImageSelector,'Value');
    end
    
    MovieSel=get(handles.MovieSelector,'Value');
    
    NumberImages=length(ImageSel);
    
    dividerWaitbar=10^(floor(log10(NumberImages))-1);
    
    MovieSize=SpikeMovieData(MovieSel).DataSize;
    LocalTrace=length(SpikeTraceData);
    
    ListBadIndex=[];
    
    for i=1:NumberImages
        ImageSize=SpikeImageData(ImageSel(i)).DataSize;
        % We check if image and movies are of the same size
        if (~any(MovieSize(1:2)-ImageSize))
            LocalTrace=LocalTrace+1;
            if isempty(SpikeTraceData)
                InitTraces();
            end
            SpikeTraceData(LocalTrace).XVector=zeros(MovieSize(3),1,'double');
            SpikeTraceData(LocalTrace).Trace=zeros(MovieSize(3),1,'double');
            
            % We reduce computation cost by only selecting non zeros pixels
            NonZeroI=find(abs(SpikeImageData(ImageSel(i)).Image)>0);
            [Xind,Yind]=ind2sub(SpikeImageData(ImageSel(i)).DataSize,NonZeroI);
            MatrixOnes=ones(size(Xind));
            for j=1:MovieSize(3)
                
                LocalIndMovie=sub2ind(SpikeMovieData(MovieSel).DataSize,Xind,Yind,j*MatrixOnes);
                
                SpikeTraceData(LocalTrace).XVector(j,1)=SpikeMovieData(MovieSel).TimeFrame(j);
                SpikeTraceData(LocalTrace).Trace(j,1)=sum(sum(double(SpikeImageData(ImageSel(i)).Image(NonZeroI)).*double(SpikeMovieData(MovieSel).Movie(LocalIndMovie))));
            end
            
            SpikeTraceData(LocalTrace).DataSize=size(SpikeTraceData(LocalTrace).Trace);
            SpikeTraceData(LocalTrace).Label.YLabel=SpikeMovieData(MovieSel).Label.CLabel;
            SpikeTraceData(LocalTrace).Filename=SpikeMovieData(MovieSel).Filename;
            SpikeTraceData(LocalTrace).Path=SpikeMovieData(MovieSel).Path;
            SpikeTraceData(LocalTrace).Label.ListText=SpikeImageData(ImageSel(i)).Label.ListText;
            SpikeTraceData(LocalTrace).Label.YLabel=SpikeMovieData(MovieSel).Label.CLabel;
            SpikeTraceData(LocalTrace).Label.XLabel='Time (s)';
        else
            ListBadIndex=[ListBadIndex,ImageSel(i)];
        end
        if (round(i/dividerWaitbar)==i/dividerWaitbar)
            waitbar(i/NumberImages,h);
        end
    end
    delete(h);
    
    if ~isempty(ListBadIndex)
        msgbox(['Image ',num2str(ListBadIndex),' ','are not of the same size as the movie']);
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

% --- Executes on selection change in ImageSelector.
function ImageSelector_Callback(hObject, eventdata, handles)
% hObject    handle to ImageSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ImageSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImageSelector


% --- Executes during object creation, after setting all properties.
function ImageSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageSelector (see GCBO)
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


% --- Executes on button press in SelectAllImages.
function SelectAllImages_Callback(hObject, eventdata, handles)
% hObject    handle to SelectAllImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SelectAllImages
if (get(handles.SelectAllImages,'Value')==1)
    set(handles.ImageSelector,'Enable','off');
else
    set(handles.ImageSelector,'Enable','on');
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
