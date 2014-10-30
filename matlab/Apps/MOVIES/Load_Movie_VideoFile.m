function varargout = Load_Movie_VideoFile(varargin)
% LOAD_MOVIE_VIDEOFILE MATLAB code for Load_Movie_VideoFile.fig
%      LOAD_MOVIE_VIDEOFILE, by itself, creates a new LOAD_MOVIE_VIDEOFILE or raises the existing
%      singleton*.
%
%      H = LOAD_MOVIE_VIDEOFILE returns the handle to a new LOAD_MOVIE_VIDEOFILE or the handle to
%      the existing singleton*.
%
%      LOAD_MOVIE_VIDEOFILE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOAD_MOVIE_VIDEOFILE.M with the given input arguments.
%
%      LOAD_MOVIE_VIDEOFILE('Property','Value',...) creates a new LOAD_MOVIE_VIDEOFILE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Load_Movie_VideoFile_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Load_Movie_VideoFile_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Load_Movie_VideoFile

% Last Modified by GUIDE v2.5 15-Mar-2012 10:43:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Load_Movie_VideoFile_OpeningFcn, ...
                   'gui_OutputFcn',  @Load_Movie_VideoFile_OutputFcn, ...
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


% --- Executes just before Load_Movie_VideoFile is made visible.
function Load_Movie_VideoFile_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Load_Movie_VideoFile (see VARARGIN)

% Choose default command line output for Load_Movie_VideoFile
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Load_Movie_VideoFile wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.FilenameShow,'String',Settings.FilenameShowString);
    set(handles.NbFrame,'String',Settings.NbFrameString);
    set(handles.StartFrame,'String',Settings.StartFrameString);
    set(handles.EndFrame,'String',Settings.EndFrameString);
    set(handles.XSinglePixelSize,'String',Settings.XSinglePixelSizeString);
    set(handles.FrameRate,'String',Settings.FrameRateString);
    set(handles.LoadBehSelect,'Value',Settings.LoadBehSelectValue);
    set(handles.ExposureTime,'String',Settings.ExposureTimeString);
    set(handles.PixelLabel,'String',Settings.PixelLabelString);
    set(handles.MovieName,'String',Settings.MovieNameString);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.FilenameShowString=get(handles.FilenameShow,'String');
Settings.NbFrameString=get(handles.NbFrame,'String');
Settings.StartFrameString=get(handles.StartFrame,'String');
Settings.EndFrameString=get(handles.EndFrame,'String');
Settings.XSinglePixelSizeString=get(handles.XSinglePixelSize,'String');
Settings.FrameRateString=get(handles.FrameRate,'String');
Settings.LoadBehSelectValue=get(handles.LoadBehSelect,'Value');
Settings.ExposureTimeString=get(handles.ExposureTime,'String');
Settings.PixelLabelString=get(handles.PixelLabel,'String');
Settings.MovieNameString=get(handles.MovieName,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Load_Movie_VideoFile_OutputFcn(hObject, eventdata, handles)
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
    
    h=waitbar(0,'Reading file');

    if (1==get(handles.LoadBehSelect,'Value'))
        InitMovies();
        BeginMovie=1;
    else
        BeginMovie=length(SpikeMovieData)+1;
    end
    
    [pathstr, name, ext] = fileparts(get(handles.FilenameShow,'String'));
    
    fileInLoading=fullfile(pathstr,[name ext]);
        
    % We create the Movie object to the file
    VideoObject=VideoReader(fileInLoading);
    
    % We read one picture to get the image size as well as the data type
    LocalImage=read(VideoObject, 1);
    
    % We only want gray pictures so we average all RGB components if there
    % are any.
    RealClass=class(LocalImage);
    LocalImage=mean(LocalImage,3);
    LocalImage=cast(LocalImage,RealClass);
    SizeImage=size(LocalImage);

    framerate=str2num(get(handles.FrameRate,'String'));
    
    StartFrame=str2num(get(handles.StartFrame,'String'));
    EndFrame=str2num(get(handles.EndFrame,'String'));
    Exposure=str2double(get(handles.ExposureTime,'String'));
    
    % Number of frame is straightforward
    Numberframe=1+EndFrame-StartFrame;
    
    % We prallocate the movie
    SpikeMovieData(BeginMovie).Movie=zeros(SizeImage(1),SizeImage(2),Numberframe,class(LocalImage));
    SpikeMovieData(BeginMovie).DataSize=size(SpikeMovieData(BeginMovie).Movie);
    
    % We create the various time matrix
    SpikeMovieData(BeginMovie).TimeFrame=zeros(1,Numberframe,'single');
    
    % For this particular loader, we assume all pixels are acquired at the
    % same exact time.
    SpikeMovieData(BeginMovie).TimePixel=zeros(SpikeMovieData(BeginMovie).DataSize(1:3),'uint8');
    SpikeMovieData(BeginMovie).Exposure=Exposure*ones(SpikeMovieData(BeginMovie).DataSize(1:2),'single');
    
    % Since TimePixel is zeros, this TimePixelUnits is not really used but
    % we need a value still.
    SpikeMovieData(BeginMovie).TimePixelUnits=10^-6;
    
    % waitbar is consuming too much ressources, so I divide its acces
    dividerWaitbar=10^(floor(log10(Numberframe))-1);
   
    for i=StartFrame:EndFrame

        SpikeMovieData(BeginMovie).Movie(:,:,i-StartFrame+1)=cast(mean(read(VideoObject,i),3),class(LocalImage));
        
        if (round(i/dividerWaitbar)==i/dividerWaitbar)
            waitbar(i/Numberframe,h);
        end
    end
    
    for j=BeginMovie:length(SpikeMovieData)
        for i=1:SpikeMovieData(j).DataSize(3)
            SpikeMovieData(j).TimeFrame(i)=i/framerate+Exposure/2;
        end
    end
    
    % We get the X and Y calibration values from the interface
    RatioPixelSpaceX=str2num(get(handles.XSinglePixelSize,'String'));
    RatioPixelSpaceY=str2num(get(handles.YSinglePixelSize,'String'));
    
    % We create the position matrix that store X,Y,Z position of all pixels
    for j=BeginMovie:length(SpikeMovieData)
        [SpikeMovieData(j).Xposition(:,:),SpikeMovieData(j).Yposition(:,:)] = meshgrid(RatioPixelSpaceX*(1:SpikeMovieData(j).DataSize(2)),RatioPixelSpaceY*(1:SpikeMovieData(j).DataSize(1)));
        SpikeMovieData(j).Zposition(:,:)=zeros(size(SpikeMovieData(j).Xposition(:,:)));
    end
    
    SpikeMovieData(BeginMovie).Path=pathstr;
    SpikeMovieData(BeginMovie).Filename=[name ext];
    SpikeMovieData(BeginMovie).Label.XLabel='\mum';
    SpikeMovieData(BeginMovie).Label.YLabel='\mum';
    SpikeMovieData(BeginMovie).Label.ZLabel='\mum';
    SpikeMovieData(BeginMovie).Label.CLabel=get(handles.PixelLabel,'String');
    SpikeMovieData(BeginMovie).Label.ListText=get(handles.MovieName,'String');
    
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


% --- Executes on button press in SelectFile.
function SelectFile_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;

% We get the list of supported file formats
LocallySupportedVideo=VideoReader.getFileFormats;

% and we send it to uiget file nicely
filterSpec = getFilterSpec(LocallySupportedVideo);

% Open file path
[filename, pathname] = uigetfile(filterSpec);

% Open file if exist
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
    return
    
    % Otherwise construct the fullfilename and Check and load the file
else 
    % To keep the path accessible to futur request
    cd(pathname);
    
    try
        InterfaceObj=findobj(handles.output,'Enable','on');
        set(InterfaceObj,'Enable','off');
        h=waitbar(0,'Checking data...');
        
        set(handles.FilenameShow,'String',fullfile(pathname,filename));
        handles=guidata(gcbo);
        
        fileInLoading=get(handles.FilenameShow,'String');
        
        if (exist(fileInLoading)==2)
            VideoObject=VideoReader(fileInLoading);
            Numberframe=VideoObject.NumberOfFrames;
            FrameRate=VideoObject.FrameRate;
            
            set(handles.FrameRate,'String',num2str(FrameRate));
            set(handles.NbFrame,'String',num2str(Numberframe));
            
            EndFrame=str2num(get(handles.EndFrame,'String'));
            if isempty(EndFrame)
                set(handles.EndFrame,'String',num2str(Numberframe));
            elseif EndFrame>Numberframe
                set(handles.EndFrame,'String',num2str(Numberframe));
            end
            
            % We check that the exposure time is making sense at all given a
            % certain frame rate. 
            ExposureTime=str2num(get(handles.ExposureTime,'String'));
            if isempty(ExposureTime)
                set(handles.ExposureTime,'String',num2str(1/FrameRate));
            elseif ExposureTime>1/FrameRate
                set(handles.ExposureTime,'String',num2str(1/FrameRate));
            end
            
        end
        delete(h);
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
end


function StartFrame_Callback(hObject, eventdata, handles)
% hObject    handle to StartFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartFrame as text
%        str2double(get(hObject,'String')) returns contents of StartFrame as a double


% --- Executes during object creation, after setting all properties.
function StartFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EndFrame_Callback(hObject, eventdata, handles)
% hObject    handle to EndFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EndFrame as text
%        str2double(get(hObject,'String')) returns contents of EndFrame as a double


% --- Executes during object creation, after setting all properties.
function EndFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EndFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XSinglePixelSize_Callback(hObject, eventdata, handles)
% hObject    handle to XSinglePixelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XSinglePixelSize as text
%        str2double(get(hObject,'String')) returns contents of XSinglePixelSize as a double


% --- Executes during object creation, after setting all properties.
function XSinglePixelSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XSinglePixelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FrameRate_Callback(hObject, eventdata, handles)
% hObject    handle to FrameRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameRate as text
%        str2double(get(hObject,'String')) returns contents of FrameRate as a double


% --- Executes during object creation, after setting all properties.
function FrameRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in LoadBehSelect.
function LoadBehSelect_Callback(hObject, eventdata, handles)
% hObject    handle to LoadBehSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LoadBehSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LoadBehSelect


% --- Executes during object creation, after setting all properties.
function LoadBehSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LoadBehSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ExposureTime_Callback(hObject, eventdata, handles)
% hObject    handle to ExposureTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ExposureTime as text
%        str2double(get(hObject,'String')) returns contents of ExposureTime as a double


% --- Executes during object creation, after setting all properties.
function ExposureTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ExposureTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function YSinglePixelSize_Callback(hObject, eventdata, handles)
% hObject    handle to YSinglePixelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YSinglePixelSize as text
%        str2double(get(hObject,'String')) returns contents of YSinglePixelSize as a double


% --- Executes during object creation, after setting all properties.
function YSinglePixelSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YSinglePixelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PixelLabel_Callback(hObject, eventdata, handles)
% hObject    handle to PixelLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PixelLabel as text
%        str2double(get(hObject,'String')) returns contents of PixelLabel as a double


% --- Executes during object creation, after setting all properties.
function PixelLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PixelLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MovieName_Callback(hObject, eventdata, handles)
% hObject    handle to MovieName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MovieName as text
%        str2double(get(hObject,'String')) returns contents of MovieName as a double


% --- Executes during object creation, after setting all properties.
function MovieName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MovieName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
