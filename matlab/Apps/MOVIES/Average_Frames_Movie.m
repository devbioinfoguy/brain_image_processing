function varargout = Average_Frames_Movie(varargin)
% AVERAGE_FRAMES_MOVIE MATLAB code for Average_Frames_Movie.fig
%      AVERAGE_FRAMES_MOVIE, by itself, creates a new AVERAGE_FRAMES_MOVIE or raises the existing
%      singleton*.
%
%      H = AVERAGE_FRAMES_MOVIE returns the handle to a new AVERAGE_FRAMES_MOVIE or the handle to
%      the existing singleton*.
%
%      AVERAGE_FRAMES_MOVIE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AVERAGE_FRAMES_MOVIE.M with the given input arguments.
%
%      AVERAGE_FRAMES_MOVIE('Property','Value',...) creates a new AVERAGE_FRAMES_MOVIE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Average_Frames_Movie_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Average_Frames_Movie_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Average_Frames_Movie

% Last Modified by GUIDE v2.5 05-Dec-2012 16:36:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Average_Frames_Movie_OpeningFcn, ...
                   'gui_OutputFcn',  @Average_Frames_Movie_OutputFcn, ...
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


% --- Executes just before Average_Frames_Movie is made visible.
function Average_Frames_Movie_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Average_Frames_Movie (see VARARGIN)

% Choose default command line output for Average_Frames_Movie
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Average_Frames_Movie wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global SpikeMovieData;

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
    set(handles.FramesAverage,'String',Settings.FrequAverageString);
    set(handles.SaveBehSelect,'Value',Settings.SaveBehSelectValue);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.MovieSelectorString=get(handles.MovieSelector,'String');
Settings.FrequAverageString=get(handles.FramesAverage,'String');
Settings.SaveBehSelectValue=get(handles.SaveBehSelect,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Average_Frames_Movie_OutputFcn(hObject, eventdata, handles) 
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

if isfield(handles,'hLocalFrame')
    if (ishandle(handles.hLocalFrame))
        delete(handles.hLocalFrame);
    end
end

if isfield(handles,'hFFTFrame')
    if (ishandle(handles.hFFTFrame))
        delete(handles.hFFTFrame);
    end
end

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
    
    FramesAverage=str2double(get(handles.FramesAverage,'String'));
    NumberPoints=FramesAverage;
    
    h=waitbar(0,'Averaging movie...');
  
    % We close it in the end
    Cleanup2=onCleanup(@()delete(h));
        
    dividerWaitBar=10^(floor(log10(SpikeMovieData(MovieSel).DataSize(3)))-1);
    
    MovieSelection=get(handles.SaveBehSelect,'Value');
    
    % Preallocate matrix
    LocalClassTime=class(SpikeMovieData(MovieSel).TimePixel);
    
    % We preallocate end movie in single to allow summing all elements
    % without to worry about touching the top of the max values
    FinalMovie=zeros([SpikeMovieData(MovieSel).DataSize(1:2) NumberPoints],'single');
    FinalTimePixel=zeros([SpikeMovieData(MovieSel).DataSize(1:2) NumberPoints],'single');
    
    NewTimeFrame=zeros(NumberPoints,1,'double');
    NumberAveraged=NewTimeFrame;
    MaxPeriodNumber=str2num(get(handles.PeriodAverage,'String'));
    
    for i=1:SpikeMovieData(MovieSel).DataSize(3)
        
        FrameNumber=i-NumberPoints*floor((i-1)/NumberPoints);

        FinalMovie(:,:,FrameNumber)=FinalMovie(:,:,FrameNumber)+single(SpikeMovieData(MovieSel).Movie(:,:,i));
        FinalTimePixel(:,:,FrameNumber)=FinalTimePixel(:,:,FrameNumber)+single(SpikeMovieData(MovieSel).TimePixel(:,:,i));
       
        if NumberAveraged(FrameNumber)>MaxPeriodNumber
            break;
        else
            NumberAveraged(FrameNumber)=NumberAveraged(FrameNumber)+1;
        end
        
        if (round(i/dividerWaitBar)==i/dividerWaitBar)
            waitbar(i/SpikeMovieData(MovieSel).DataSize(3),h);
        end
    end
    
    % we divide by the number of averaged frames for each time point
    for i=1:NumberPoints
        FinalMovie(:,:,i)=FinalMovie(:,:,i)/NumberAveraged(i);
        FinalTimePixel(:,:,i)=FinalTimePixel(:,:,i)/NumberAveraged(i);
        NewTimeFrame(i)=SpikeMovieData(MovieSel).TimeFrame(i);
    end
    
    if MovieSelection==1
        SpikeMovieData(MovieSel).Movie=FinalMovie;
        SpikeMovieData(MovieSel).TimePixel=cast(FinalTimePixel,LocalClassTime);
        SpikeMovieData(MovieSel).TimeFrame=NewTimeFrame;
        SpikeMovieData(MovieSel).DataSize=size(FinalMovie);
    else
        TargetMovie=length(SpikeMovieData)+1;
        SpikeMovieData(TargetMovie).Movie=FinalMovie;
        SpikeMovieData(TargetMovie).TimePixel=cast(FinalTimePixel,LocalClassTime);
        SpikeMovieData(TargetMovie).TimeFrame=NewTimeFrame;
        SpikeMovieData(TargetMovie).DataSize=size(FinalMovie);
        SpikeMovieData(TargetMovie).Exposure=SpikeMovieData(MovieSel).Exposure;
        SpikeMovieData(TargetMovie).TimePixelUnits=SpikeMovieData(MovieSel).TimePixelUnits;
        SpikeMovieData(TargetMovie).Path=SpikeMovieData(MovieSel).Path;
        SpikeMovieData(TargetMovie).Filename=SpikeMovieData(MovieSel).Filename;
        SpikeMovieData(TargetMovie).Xposition=SpikeMovieData(MovieSel).Xposition;
        SpikeMovieData(TargetMovie).Yposition=SpikeMovieData(MovieSel).Yposition;
        SpikeMovieData(TargetMovie).Zposition=SpikeMovieData(MovieSel).Zposition;
        SpikeMovieData(TargetMovie).Label.XLabel=SpikeMovieData(MovieSel).Label.XLabel;
        SpikeMovieData(TargetMovie).Label.YLabel=SpikeMovieData(MovieSel).Label.YLabel;
        SpikeMovieData(TargetMovie).Label.ZLabel=SpikeMovieData(MovieSel).Label.ZLabel;
        SpikeMovieData(TargetMovie).Label.CLabel=SpikeMovieData(MovieSel).Label.CLabel;
        SpikeMovieData(TargetMovie).Label.ListText=SpikeMovieData(MovieSel).Label.ListText;
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


function FramesAverage_Callback(hObject, eventdata, handles)
% hObject    handle to FramesAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FramesAverage as text
%        str2double(get(hObject,'String')) returns contents of FramesAverage as a double


% --- Executes during object creation, after setting all properties.
function FramesAverage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FramesAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function FrequEnd_Callback(hObject, eventdata, handles)
% hObject    handle to FrequEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrequEnd as text
%        str2double(get(hObject,'String')) returns contents of FrequEnd as a double


% --- Executes during object creation, after setting all properties.
function FrequEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrequEnd (see GCBO)
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


% --- Executes on button press in ExportImages.
function ExportImages_Callback(hObject, eventdata, handles)
% hObject    handle to ExportImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ExportImages


% --- Executes on button press in SelectROI.
function SelectROI_Callback(hObject, eventdata, handles)
% hObject    handle to SelectROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;
global SpikeGui;

if isfield(handles,'hLocalFrame')
    if (isempty(handles.hLocalFrame) || ~ishandle(handles.hLocalFrame))
        handles.hLocalFrame=figure('Name','ROIs over Movie','NumberTitle','off');
    else
        figure(handles.hLocalFrame);
    end
else
    handles.hLocalFrame=figure('Name','ROIs over Movie','NumberTitle','off');
end

if (ishandle(SpikeGui.hDataDisplay))
    GlobalColorMap = get(SpikeGui.hDataDisplay,'Colormap');
    set(handles.hLocalFrame,'Colormap',GlobalColorMap)
end

MovieApplied=get(handles.MovieSelector,'Value');
NewPic=mean(SpikeMovieData(MovieApplied).Movie,3);
imagesc(NewPic);

h = findobj(handles.hLocalFrame,'Type','axes');

imellipse(h);

guidata(handles.output,handles);


% --- Executes on button press in TestFFT.
function TestFFT_Callback(hObject, eventdata, handles)
% hObject    handle to TestFFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;

MovieApplied=get(handles.MovieSelector,'Value');

localH=findobj(handles.hLocalFrame,'Type','hggroup');

h=waitbar(0,'Creating FFT Image...');

hROI=getappdata(localH,'roiObjectReference');

BW_ROI = createMask(hROI);
IndicesROI=find(BW_ROI);

dividerWaitbar=10^(floor(log10(SpikeMovieData(MovieApplied).DataSize(3)))-1);

% The closest larger power of 2 to get faster FFT
NFFT = SpikeMovieData(MovieApplied).DataSize(3);

FrequencySampl=1/mean(diff(SpikeMovieData(MovieApplied).TimeFrame));
FreqAxis=FrequencySampl/NFFT*(1:(floor(NFFT/2)+1));

% We find the indices to keep
IKeep=1:length(FreqAxis);

% Preallocate matrix
LocalTrace=zeros(SpikeMovieData(MovieApplied).DataSize(3),1);
PhaseMap=zeros([length(IndicesROI) length(IKeep)],'double');
PSDMap=PhaseMap;
[X_i,Y_i] = ind2sub(SpikeMovieData(MovieApplied).DataSize(1:2),IndicesROI);

for i=1:SpikeMovieData(MovieApplied).DataSize(3)
    LocalInd = sub2ind(SpikeMovieData(MovieApplied).DataSize(1:3),X_i,Y_i,i*ones(size(X_i)));
    LocalTrace(i) = mean(SpikeMovieData(MovieApplied).Movie(LocalInd));
    
    if (round(i/dividerWaitbar)==i/dividerWaitbar)
        waitbar(i/SpikeMovieData(MovieApplied).DataSize(3),h);
    end
end

Spectrum=fft(single(LocalTrace),NFFT);

FFTvalues=Spectrum(IKeep);

% We first Calculate Power Sprectral Density

% To get the density
SD=abs(FFTvalues)/SpikeMovieData(MovieApplied).DataSize(3);

% To get the power
PSD=SD.^2;

% we only get one average value
PSDMap=PSD;

delete(h);


if isfield(handles,'hFFTFrame')
    if (isempty(handles.hFFTFrame) || ~ishandle(handles.hFFTFrame))
        handles.hFFTFrame=figure('Name','FFT over ROI','NumberTitle','off');
    else
        figure(handles.hFFTFrame);
    end
else
    handles.hFFTFrame=figure('Name','FFT over ROI','NumberTitle','off');
end

loglog(FreqAxis,PSDMap);
xlabel('Frequency (Hz)');
ylabel('Power spectral density');

guidata(handles.output,handles);


% --- Executes on selection change in SaveBehSelect.
function SaveBehSelect_Callback(hObject, eventdata, handles)
% hObject    handle to SaveBehSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SaveBehSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SaveBehSelect


% --- Executes during object creation, after setting all properties.
function SaveBehSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaveBehSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PeriodAverage_Callback(hObject, eventdata, handles)
% hObject    handle to PeriodAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PeriodAverage as text
%        str2double(get(hObject,'String')) returns contents of PeriodAverage as a double


% --- Executes during object creation, after setting all properties.
function PeriodAverage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PeriodAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
