function varargout = Movie_Spectrum(varargin)
% MOVIE_SPECTRUM MATLAB code for Movie_Spectrum.fig
%      MOVIE_SPECTRUM, by itself, creates a new MOVIE_SPECTRUM or raises the existing
%      singleton*.
%
%      H = MOVIE_SPECTRUM returns the handle to a new MOVIE_SPECTRUM or the handle to
%      the existing singleton*.
%
%      MOVIE_SPECTRUM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOVIE_SPECTRUM.M with the given input arguments.
%
%      MOVIE_SPECTRUM('Property','Value',...) creates a new MOVIE_SPECTRUM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Movie_Spectrum_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Movie_Spectrum_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Movie_Spectrum

% Last Modified by GUIDE v2.5 27-Mar-2012 09:46:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Movie_Spectrum_OpeningFcn, ...
                   'gui_OutputFcn',  @Movie_Spectrum_OutputFcn, ...
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


% --- Executes just before Movie_Spectrum is made visible.
function Movie_Spectrum_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Movie_Spectrum (see VARARGIN)

% Choose default command line output for Movie_Spectrum
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Movie_Spectrum wait for user response (see UIRESUME)
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
    set(handles.FrequBegin,'String',Settings.FrequBeginString);
    set(handles.FrequEnd,'String',Settings.FrequEndString);
    set(handles.ExportImages,'Value',Settings.ExportImagesValue);
else
    if ~isempty(SpikeMovieData)
        set(handles.FrequEnd,'String',num2str(SpikeMovieData(1).DataSize(3)));
    end
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.MovieSelectorString=get(handles.MovieSelector,'String');
Settings.FrequBeginString=get(handles.FrequBegin,'String');
Settings.FrequEndString=get(handles.FrequEnd,'String');
Settings.ExportImagesValue=get(handles.ExportImages,'Value');

% --- Outputs from this function are returned to the command line.
function varargout = Movie_Spectrum_OutputFcn(hObject, eventdata, handles) 
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
if isfield(handles,'hFigImageFreq')
    if (ishandle(handles.hFigImageFreq))
        delete(handles.hFigImageFreq);
    end
end

if isfield(handles,'hFigImagePhase')
    if (ishandle(handles.hFigImagePhase))
        delete(handles.hFigImagePhase);
    end
end

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
global SpikeImageData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    % We turn it back on in the end
    Cleanup1=onCleanup(@()set(InterfaceObj,'Enable','on'));

    MovieSel=get(handles.MovieSelector,'Value');
    
    FrequBegin=str2double(get(handles.FrequBegin,'String'));
    FrequEnd=str2double(get(handles.FrequEnd,'String'));
    
    h=waitbar(0,'Computing frequency maps...');
    
    % We close it in the end
    Cleanup2=onCleanup(@()delete(h));
    
    dividerWaitbar=10^(floor(log10(SpikeMovieData(MovieSel).DataSize(2)))-1);
    
    % Preallocate matrix
    PhaseMap=zeros(SpikeMovieData(MovieSel).DataSize(1:2),'double');
    PSDMap=PhaseMap;
    
    % The closest larger power of 2 to get faster FFT
    NFFT = SpikeMovieData(MovieSel).DataSize(3);
    
    FrequencySampl=1/mean(diff(SpikeMovieData(MovieSel).TimeFrame));           
    FreqAxis=FrequencySampl/NFFT*(1:(floor(NFFT/2)+1));
    
    % We find the indices to keep
    IKeep=find(FreqAxis>FrequBegin & FreqAxis<FrequEnd);
    
    % We go along second dimension as Matlab is Column-major
    for i=1:SpikeMovieData(MovieSel).DataSize(2)            
            Spectrum=fft(single(SpikeMovieData(MovieSel).Movie(:,i,:)),NFFT,3);

            FFTvalues=Spectrum(:,1,IKeep);
            
            % We first Calculate Power Sprectral Density
            
            % To get the density
            SD=abs(FFTvalues)/SpikeMovieData(MovieSel).DataSize(3);
            
            % To get the power
            PSD=SD.^2;
            
            % we only get one average value
            PSDMap(:,i)=mean(PSD,3);
            
            % Next we extract the phase curve
            Phase=180/pi*atan(imag(FFTvalues)./real(FFTvalues));
            
            PhaseMap(:,i)=mean(Phase,3);
            
        if (round(i/dividerWaitbar)==i/dividerWaitbar)
            waitbar(i/SpikeMovieData(MovieSel).DataSize(2),h);
        end
    end
    
    if isfield(handles,'hFigImageFreq')
        if (isempty(handles.hFigImageFreq) || ~ishandle(handles.hFigImageFreq))
            handles.hFigImageFreq=figure('Name','Power Spectral Density map','NumberTitle','off');
        else
            figure(handles.hFigImageFreq);
        end
    else
        handles.hFigImageFreq=figure('Name','Power Spectral Density map','NumberTitle','off');
    end
    imagesc(PSDMap);
    
    if isfield(handles,'hFigImagePhase')
        if (isempty(handles.hFigImagePhase) || ~ishandle(handles.hFigImagePhase))
            handles.hFigImagePhase=figure('Name','Phase map','NumberTitle','off');
        else
            figure(handles.hFigImagePhase);
        end
    else
        handles.hFigImagePhase=figure('Name','Phase map','NumberTitle','off');
    end
    imagesc(PhaseMap);
    
    if get(handles.ExportImages,'Value')
        CurrentNumberImage=length(SpikeImageData);
        if isempty(SpikeImageData)
            InitImages();
        end
        SpikeImageData(CurrentNumberImage+1).Image=PhaseMap;
        SpikeImageData(CurrentNumberImage+1).DataSize=size(SpikeImageData(CurrentNumberImage+1).Image);
        SpikeImageData(CurrentNumberImage+1).Label.CLabel='Oscillation phase (deg)';
        SpikeImageData(CurrentNumberImage+1).Label.XLabel=SpikeMovieData(MovieSel).Label.XLabel;
        SpikeImageData(CurrentNumberImage+1).Label.YLabel=SpikeMovieData(MovieSel).Label.YLabel;
        SpikeImageData(CurrentNumberImage+1).Label.ZLabel=SpikeMovieData(MovieSel).Label.ZLabel;
        SpikeImageData(CurrentNumberImage+1).Xposition=SpikeMovieData(MovieSel).Xposition;
        SpikeImageData(CurrentNumberImage+1).Yposition=SpikeMovieData(MovieSel).Yposition;
        SpikeImageData(CurrentNumberImage+1).Zposition=SpikeMovieData(MovieSel).Zposition;
        SpikeImageData(CurrentNumberImage+1).Filename=SpikeMovieData(MovieSel).Filename;
        SpikeImageData(CurrentNumberImage+1).Path=SpikeMovieData(MovieSel).Path;
        SpikeImageData(CurrentNumberImage+1).Label.ListText='Phase map';
        
        SpikeImageData(CurrentNumberImage+2).Image=PSDMap;
        SpikeImageData(CurrentNumberImage+2).DataSize=size(SpikeImageData(CurrentNumberImage+2).Image);
        SpikeImageData(CurrentNumberImage+2).Label.CLabel='Oscillation power (W/Hz)';
        SpikeImageData(CurrentNumberImage+2).Label.XLabel=SpikeMovieData(MovieSel).Label.XLabel;
        SpikeImageData(CurrentNumberImage+2).Label.YLabel=SpikeMovieData(MovieSel).Label.YLabel;
        SpikeImageData(CurrentNumberImage+2).Label.ZLabel=SpikeMovieData(MovieSel).Label.ZLabel;
        SpikeImageData(CurrentNumberImage+2).Xposition=SpikeMovieData(MovieSel).Xposition;
        SpikeImageData(CurrentNumberImage+2).Yposition=SpikeMovieData(MovieSel).Yposition;
        SpikeImageData(CurrentNumberImage+2).Zposition=SpikeMovieData(MovieSel).Zposition;
        SpikeImageData(CurrentNumberImage+2).Filename=SpikeMovieData(MovieSel).Filename;
        SpikeImageData(CurrentNumberImage+2).Path=SpikeMovieData(MovieSel).Path;
        SpikeImageData(CurrentNumberImage+2).Label.ListText='PSD map';
    end
    guidata(handles.output, handles);
    
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


function FrequBegin_Callback(hObject, eventdata, handles)
% hObject    handle to FrequBegin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrequBegin as text
%        str2double(get(hObject,'String')) returns contents of FrequBegin as a double


% --- Executes during object creation, after setting all properties.
function FrequBegin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrequBegin (see GCBO)
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
