function varargout = Mask_Image_Movie(varargin)
% MASK_IMAGE_MOVIE MATLAB code for Mask_Image_Movie.fig
%      MASK_IMAGE_MOVIE, by itself, creates a new MASK_IMAGE_MOVIE or raises the existing
%      singleton*.
%
%      H = MASK_IMAGE_MOVIE returns the handle to a new MASK_IMAGE_MOVIE or the handle to
%      the existing singleton*.
%
%      MASK_IMAGE_MOVIE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MASK_IMAGE_MOVIE.M with the given input arguments.
%
%      MASK_IMAGE_MOVIE('Property','Value',...) creates a new MASK_IMAGE_MOVIE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Mask_Image_Movie_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Mask_Image_Movie_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
%JESSE MARSHALL NOVEMBER 2012 COPYRIGHT NO COPYING
% Edit the above text to modify the response to help Mask_Image_Movie

% Last Modified by GUIDE v2.5 28-Nov-2012 10:19:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Mask_Image_Movie_OpeningFcn, ...
                   'gui_OutputFcn',  @Mask_Image_Movie_OutputFcn, ...
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


% --- Executes just before Mask_Image_Movie is made visible.
function Mask_Image_Movie_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Mask_Image_Movie (see VARARGIN)
global SpikeImageData;
global SpikeMovieData;

% Choose default command line output for Mask_Image_Movie
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Mask_Image_Movie wait for user response (see UIRESUME)
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
function varargout = Mask_Image_Movie_OutputFcn(hObject, eventdata, handles) 
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
    
    %make sure only one image is selected
    
    if(NumberImages ~= 1)
        fprintf('Only select one image!!!!!!1 \n')
    end
        %binarize image, if not already
    %invert image and turn into proper cast for multiplication
  local_cast = class(SpikeMovieData(MovieSel).Movie);
 image = cast(~(logical(SpikeImageData(ImageSel).Image)),local_cast);
    
    %make new movie equal to old movie
    nummovies = length(SpikeMovieData);
    SpikeMovieData(nummovies+1) = SpikeMovieData(MovieSel);
    
    %step through frames and multiply new movie by mask
         for j=1:MovieSize(3)
    SpikeMovieData(nummovies+1).Movie(:,:,j) = SpikeMovieData(nummovies+1).Movie(:,:,j).*image;
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
