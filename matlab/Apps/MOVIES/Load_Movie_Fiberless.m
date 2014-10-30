function varargout = Load_Movie_Fiberless(varargin)
% LOAD_MOVIE_FIBERLESS MATLAB code for Load_Movie_Fiberless.fig
%      LOAD_MOVIE_FIBERLESS, by itself, creates a new LOAD_MOVIE_FIBERLESS or raises the existing
%      singleton*.
%
%      H = LOAD_MOVIE_FIBERLESS returns the handle to a new LOAD_MOVIE_FIBERLESS or the handle to
%      the existing singleton*.
%
%      LOAD_MOVIE_FIBERLESS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOAD_MOVIE_FIBERLESS.M with the given input arguments.
%
%      LOAD_MOVIE_FIBERLESS('Property','Value',...) creates a new LOAD_MOVIE_FIBERLESS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Load_Movie_Fiberless_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Load_Movie_Fiberless_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Load_Movie_Fiberless

% Last Modified by GUIDE v2.5 06-Feb-2012 22:35:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Load_Movie_Fiberless_OpeningFcn, ...
                   'gui_OutputFcn',  @Load_Movie_Fiberless_OutputFcn, ...
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


% --- Executes just before Load_Movie_Fiberless is made visible.
function Load_Movie_Fiberless_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Load_Movie_Fiberless (see VARARGIN)

% Choose default command line output for Load_Movie_Fiberless
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Load_Movie_Fiberless wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.FilenameShow,'String',Settings.FilenameShowString);
    set(handles.TotalNbPixel,'String',Settings.TotalNbPixelString);
    set(handles.WidthPixel,'String',Settings.WidthPixelString);
    set(handles.HeightPixel,'String',Settings.HeightPixelString);
    set(handles.NbFrame,'String',Settings.NbFrameString);
    set(handles.StartFrame,'String',Settings.StartFrameString);
    set(handles.EndFrame,'String',Settings.EndFrameString);
    set(handles.MovieSelector,'Value',Settings.MovieSelectionValue);
    set(handles.SinglePixelSize,'String',Settings.SinglePixelSizeString);
    set(handles.FrameRate,'String',Settings.FrameRateString);
    set(handles.LoadBehSelect,'Value',Settings.LoadBehSelectValue);
end
    

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.FilenameShowString=get(handles.FilenameShow,'String');
Settings.TotalNbPixelString=get(handles.TotalNbPixel,'String');
Settings.WidthPixelString=get(handles.WidthPixel,'String');
Settings.HeightPixelString=get(handles.HeightPixel,'String');
Settings.NbFrameString=get(handles.NbFrame,'String');
Settings.StartFrameString=get(handles.StartFrame,'String');
Settings.EndFrameString=get(handles.EndFrame,'String');
Settings.MovieSelectionValue=get(handles.MovieSelector,'Value');
Settings.SinglePixelSizeString=get(handles.SinglePixelSize,'String');
Settings.FrameRateString=get(handles.FrameRate,'String');
Settings.LoadBehSelectValue=get(handles.LoadBehSelect,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Load_Movie_Fiberless_OutputFcn(hObject, eventdata, handles) 
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
    
    if (1==get(handles.LoadBehSelect,'Value'))
        InitMovies();
        BeginMovie=1;
    else
        BeginMovie=length(SpikeMovieData)+1;
    end
    
    [pathstr, name, ext] = fileparts(get(handles.FilenameShow,'String'));
    
    fileInLoading=fullfile(pathstr,[name ext]);
    
    fid=fopen(fileInLoading,'r');
    
    % We try to extract the number of frames in the file
    fseek(fid,0,'eof');
    filesize = ftell(fid);
    
    % Each pixel is on ubit10
    % Filesize is in bytes
    NumberPixel=filesize*8/10;
    widthMovie=str2num(get(handles.WidthPixel,'String'));
    heightMovie=str2num(get(handles.HeightPixel,'String'));
    framerate=str2num(get(handles.FrameRate,'String'));
    
    % Once you know width and Height, number of frame is straightforward
    Numberframe=1+str2num(get(handles.EndFrame,'String'))-str2num(get(handles.StartFrame,'String'));
    SelectMovies=get(handles.MovieSelector,'Value');
    
    for i=BeginMovie:(BeginMovie+length(SelectMovies)-1)
        % We prallocate the movie
        SpikeMovieData(i).Movie=zeros(widthMovie,heightMovie,Numberframe,'uint16');
        SpikeMovieData(i).DataSize=size(SpikeMovieData(i).Movie);
        
        % We create the various time matrix
        SpikeMovieData(i).TimeFrame=zeros(1,Numberframe,'single');
        SpikeMovieData(i).TimePixel=zeros(SpikeMovieData(i).DataSize(1:3),'uint8');
        SpikeMovieData(i).Exposure=1/framerate*ones(SpikeMovieData(i).DataSize(1:2),'single');
        SpikeMovieData(i).TimePixelUnits=10^-6;
        SpikeMovieData(i).Path=pathstr;
        SpikeMovieData(i).Filename=[name ext];
    end
    
    % waitbar is consuming too much ressources, so I divide its acces
    dividerWaitbar=10^(floor(log10(Numberframe))-1);
    
    % We go back to the beginning of the movie
    frewind(fid);
    
    offsetBegin=widthMovie*heightMovie*10*(str2num(get(handles.StartFrame,'String'))-1)/8;
    fseek(fid, offsetBegin, -1);
    h=waitbar(0,'Reading file');
    
    LocalData=zeros(widthMovie,heightMovie);
    
    for i=1:Numberframe
        LocalData=fread(fid,[widthMovie heightMovie],'ubit10=>uint16');
        rgb = demosaic(LocalData,'gbrg');
        for j=BeginMovie:(BeginMovie+length(SelectMovies)-1)
            SpikeMovieData(j).Movie(:,:,i)=rgb(:,:,SelectMovies(j-BeginMovie+1));
        end
        if (round(i/dividerWaitbar)==i/dividerWaitbar)
            waitbar(i/Numberframe,h);
        end
    end
    delete(h);
    
    % We close the file in the end
    fclose(fid);
    
    for j=BeginMovie:length(SpikeMovieData)
        for i=1:SpikeMovieData(j).DataSize(3)
            SpikeMovieData(j).TimeFrame(i)=1/(2*(framerate))+(i-1)/framerate;
        end
    end
    
    % For now, the microscope is not calibrated
    RatioPixelSpace=str2num(get(handles.SinglePixelSize,'String'));
    
    % We create the position matrix that store X,Y,Z position of all pixels
    for j=BeginMovie:length(SpikeMovieData)
        [SpikeMovieData(j).Xposition(:,:),SpikeMovieData(j).Yposition(:,:)] = meshgrid(RatioPixelSpace*(1:SpikeMovieData(j).DataSize(2)),RatioPixelSpace*(1:SpikeMovieData(j).DataSize(1)));
        SpikeMovieData(j).Zposition(:,:)=zeros(size(SpikeMovieData(j).Xposition(:,:)));
        
        % We set the labelling properties
        SpikeMovieData(j).Label.XLabel='\mum';
        SpikeMovieData(j).Label.YLabel='\mum';
        SpikeMovieData(j).Label.ZLabel='\mum';
        SpikeMovieData(j).Label.CLabel='Fluorescence (au)';
        SpikeMovieData(j).Label.ListText='Fiberless';
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


% --- Executes on button press in SelectFile.
function SelectFile_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;

% Open file path
[filename, pathname] = uigetfile( ...
    {'*.raw','All Files (*.raw)'},'Select RAW File');

% Open file if exist
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
    return
    
    % Otherwise construct the fullfilename and Check and load the file
else
    % To keep the path accessible to futur request
    cd(pathname);
    
    set(handles.FilenameShow,'String',fullfile(pathname,filename));
    UpdateFileInfo();
end


function WidthPixel_Callback(hObject, eventdata, handles)
% hObject    handle to WidthPixel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WidthPixel as text
%        str2double(get(hObject,'String')) returns contents of WidthPixel as a double
UpdateFileInfo();


% --- Executes during object creation, after setting all properties.
function WidthPixel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WidthPixel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HeightPixel_Callback(hObject, eventdata, handles)
% hObject    handle to HeightPixel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HeightPixel as text
%        str2double(get(hObject,'String')) returns contents of HeightPixel as a double
UpdateFileInfo();


% --- Executes during object creation, after setting all properties.
function HeightPixel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HeightPixel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
UpdateFileInfo();

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



function SinglePixelSize_Callback(hObject, eventdata, handles)
% hObject    handle to SinglePixelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SinglePixelSize as text
%        str2double(get(hObject,'String')) returns contents of SinglePixelSize as a double


% --- Executes during object creation, after setting all properties.
function SinglePixelSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SinglePixelSize (see GCBO)
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

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% This function update the display based on file information
function UpdateFileInfo()

handles=guidata(gcbo);

fileInLoading=get(handles.FilenameShow,'String');

if (exist(fileInLoading)==2)
    fid=fopen(fileInLoading,'r');
    
    % We try to extract the number of frames in the file
    fseek(fid,0,'eof');
    filesize = ftell(fid);
    
    % Each pixel is on ubit10
    % Filesize is in bytes
    NumberPixel=filesize*8/10;
    
    fclose(fid);
    
    widthMovie=str2num(get(handles.WidthPixel,'String'));
    heightMovie=str2num(get(handles.HeightPixel,'String'));
    
    % Once you know width and Height, number of frame is straightforward
    Numberframe=NumberPixel/widthMovie/heightMovie;
    
    set(handles.TotalNbPixel,'String',num2str(NumberPixel));
    set(handles.NbFrame,'String',num2str(Numberframe));
    
    EndFrame=str2num(get(handles.EndFrame,'String'));
    if isempty(EndFrame)
        set(handles.EndFrame,'String',num2str(Numberframe));
    elseif EndFrame>Numberframe
        set(handles.EndFrame,'String',num2str(Numberframe));
    end
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
