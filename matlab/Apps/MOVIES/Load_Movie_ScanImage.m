function varargout = Load_Movie_ScanImage(varargin)
% LOAD_MOVIE_SCANIMAGE MATLAB code for Load_Movie_ScanImage.fig
%      LOAD_MOVIE_SCANIMAGE, by itself, creates a new LOAD_MOVIE_SCANIMAGE or raises the existing
%      singleton*.
%
%      H = LOAD_MOVIE_SCANIMAGE returns the handle to a new LOAD_MOVIE_SCANIMAGE or the handle to
%      the existing singleton*.
%
%      LOAD_MOVIE_SCANIMAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOAD_MOVIE_SCANIMAGE.M with the given input arguments.
%
%      LOAD_MOVIE_SCANIMAGE('Property','Value',...) creates a new LOAD_MOVIE_SCANIMAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Load_Movie_ScanImage_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Load_Movie_ScanImage_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Load_Movie_ScanImage

% Last Modified by GUIDE v2.5 05-Jun-2012 17:54:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Load_Movie_ScanImage_OpeningFcn, ...
                   'gui_OutputFcn',  @Load_Movie_ScanImage_OutputFcn, ...
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


% --- Executes just before Load_Movie_ScanImage is made visible.
function Load_Movie_ScanImage_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Load_Movie_ScanImage (see VARARGIN)

% Choose default command line output for Load_Movie_ScanImage
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Load_Movie_ScanImage wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.FilenameShow,'String',Settings.FilenameShowString);
    set(handles.MovieSelector,'String',Settings.MovieSelectionListString);
    set(handles.MovieSelector,'Value',Settings.MovieSelectionListValue);
    set(handles.SpaceCalib,'String',Settings.SpaceCalibString);
    set(handles.LoadBehSelect,'Value',Settings.LoadBehSelectValue);
end
    

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.FilenameShowString=get(handles.FilenameShow,'String');
Settings.MovieSelectionListString=get(handles.MovieSelector,'String');
Settings.MovieSelectionListValue=get(handles.MovieSelector,'Value');
Settings.SpaceCalibString=get(handles.SpaceCalib,'String');
Settings.LoadBehSelectValue=get(handles.LoadBehSelect,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Load_Movie_ScanImage_OutputFcn(hObject, eventdata, handles) 
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
    drawnow;
    
    switch get(handles.LoadBehSelect,'Value')
        case 1
            InitMovies();
            BeginMovie=1;
        case 2
            BeginMovie=length(SpikeMovieData)+1;
    end
    [pathstr, name, ext] = fileparts(get(handles.FilenameShow,'String'));
    
    if exist(fullfile(pathstr,[name ext]),'file')
        Movie=get(handles.MovieSelector,'Value');
        
        fileInLoading=fullfile(pathstr,[name ext]);
        
        TiffLibAccessToFile = Tiff(fileInLoading,'r');
        
        % Because MATLAB did not implement the TIFFnumberofdirectory
        % function in their libtiff, we have to do something a little
        % fancy to get the number of frames quickly
        Step=10000;
        
        numImages=TiffLibAccessToFile.currentDirectory;
        while Step>=1
            try
                TestImage=numImages+Step;
                TiffLibAccessToFile.setDirectory(TestImage);
                numImages=TestImage;
            catch
                % If the image does not exixt, we reduce the step size.
                Step=Step/10;
            end
        end
        
        headerString = TiffLibAccessToFile.getTag('ImageDescription');
        header=parseHeader(headerString);
        
        TiffLibAccessToFile.close();
        
        % Read image meta-data
        numChans = 4;
        savedChans = [];
        for i=1:numChans
            if isfield(header.acq,['savingChannel' num2str(i)])
                if header.acq.(['savingChannel' num2str(i)]) && header.acq.(['acquiringChannel' num2str(i)])
                    savedChans = [savedChans i];
                end
            end
        end
        numChans = length(savedChans);
        
        numPixels = header.acq.pixelsPerLine;
        numLines = header.acq.linesPerFrame;
        
        if isfield(header.acq,'slowDimDiscardFlybackLine') && header.acq.slowDimDiscardFlybackLine
            numLines = numLines - 1;
        end
        
        numFrames=floor(numImages/numChans);
        
        selection=1:numFrames;
        
        for iChannel=BeginMovie:(BeginMovie+length(Movie)-1)
            SpikeMovieData(iChannel).Path=pathstr;
            SpikeMovieData(iChannel).Filename=[name ext];
            
            NbLoadMovie=Movie(iChannel+1-BeginMovie);
            NbSaveMovie=iChannel;
            
            SpikeMovieData(NbSaveMovie).Movie = zeros(numLines,numPixels,numFrames,'uint16');
            
            % We reduce access to the waitbar to limit its usage as it is CPU intensive
            dividerWaitbar=10^(floor(log10(length(selection)))-1);
            
            %% Read image data
            FileID = tifflib('open',fileInLoading,'r');
            rps = tifflib('getField',FileID,Tiff.TagID.RowsPerStrip);
            hImage = tifflib('getField',FileID,Tiff.TagID.ImageLength);
            rps = min(rps,hImage);
            
            h = waitbar(0,'Loading Tif movie...');
            % We close it in the end
            Cleanup2=onCleanup(@()delete(h));
            
            count = 0; %Initialize counter required for flat case
            for i=1:length(selection)
                if ishandle(h)
                    if ((i/dividerWaitbar)==floor(i/dividerWaitbar))
                        waitbar(i/length(selection),h);
                    end
                end
                
                idx = numChans * (selection(i) - 1) + NbLoadMovie;
                
                count = count + 1;
                
                tifflib('setDirectory',FileID,idx);
                % Go through each strip of data.
                for r = 1:rps:hImage
                    row_inds = r:min(hImage,r+rps-1);
                    stripNum = tifflib('computeStrip',FileID,r);
                    SpikeMovieData(NbSaveMovie).Movie(row_inds,:,count) = tifflib('readEncodedStrip',FileID,stripNum);
                end
            end
            
            tifflib('close',FileID);
            
            SpikeMovieData(NbSaveMovie).DataSize=size(SpikeMovieData(NbSaveMovie).Movie);
            
            h=waitbar(0,'Create reference Time Frame');
            
            % We extract all the scanning parameters to create a meaningfull set of
            % paramters to extract the timing of each pixel
            Bidirection=header.acq.bidirectionalScan;
            fillFraction=header.acq.fillFraction;
            msPerLine=header.acq.msPerLine;
            scanDelay=header.acq.scanDelay;
            LineSpeed=msPerLine/1000;
            Exposure=(LineSpeed*fillFraction)/SpikeMovieData(NbSaveMovie).DataSize(2);
            
            % In case we have bidireaction scanning, ScanDelay is different
            if (Bidirection==1)
                scanDelay=(LineSpeed-LineSpeed*fillFraction)/2;
            end
            
            % LineMatrix is from left to right scanning
            % Whereas AntiLine is right to left, this is used by bidirectionnal
            % scanning
            LineMatrix=scanDelay+Exposure/2+(0:(SpikeMovieData(NbSaveMovie).DataSize(2)-1))*Exposure;
            AntiLineMatrix=LineMatrix(length(LineMatrix):-1:1);
            
            waitbar(1/5,h);
            
            % We create the time matrix for all pixels
            TimeSingle=zeros(SpikeMovieData(NbSaveMovie).DataSize(1),SpikeMovieData(NbSaveMovie).DataSize(2),'single');
            for i=1:SpikeMovieData(NbSaveMovie).DataSize(1)
                if (Bidirection==1)
                    if (floor(i/2)==i/2)
                        currentLineMatrix=AntiLineMatrix;
                    else
                        currentLineMatrix=LineMatrix;
                    end
                else
                    currentLineMatrix=LineMatrix;
                end
                TimeSingle(i,:)=currentLineMatrix+LineSpeed*(i-1);
            end
            
            % This is the average time of the whole frame
            AverageTimeFrame=mean2(TimeSingle);
            
            waitbar(2/5,h);
            
            % We check whether last flyback line is kept or not.
            FlybackLastLine=header.acq.slowDimFlybackFinalLine;
            DiscardLastFlyback=header.acq.slowDimDiscardFlybackLine;
            AddOneTimeLine=FlybackLastLine && DiscardLastFlyback;
            
            % This change the period for scanning
            PeriodForSinglePic=LineSpeed*(AddOneTimeLine+SpikeMovieData(NbSaveMovie).DataSize(1));
            
            FinalTimeMatrix=TimeSingle-AverageTimeFrame;
            MaxTime=max(FinalTimeMatrix(:));
            MinTime=min(FinalTimeMatrix(:));
            Range=max(abs([MaxTime MinTime]));
            
            waitbar(3/5,h);
            
            % This is a conservative choice. If memory is a problem, in many cases (Frame rate>8Hz), int8
            % is good enough to have ms precision
            ChosenTimeClass='int16';
            SpikeMovieData(NbSaveMovie).TimePixelUnits=10^floor(log10(Range)+1)/10000;
            
            % We preallocate the matrixes
            SpikeMovieData(NbSaveMovie).Exposure=zeros(SpikeMovieData(NbSaveMovie).DataSize(1:2),'single');
            SpikeMovieData(NbSaveMovie).TimePixel=zeros(SpikeMovieData(NbSaveMovie).DataSize(1:3),ChosenTimeClass);
            SpikeMovieData(NbSaveMovie).TimeFrame=zeros(SpikeMovieData(NbSaveMovie).DataSize(3),'single');
            
            waitbar(4/5,h);
            
            SpikeMovieData(NbSaveMovie).TimeFrame=(AverageTimeFrame:PeriodForSinglePic:(AverageTimeFrame+(SpikeMovieData(NbSaveMovie).DataSize(3)-1)*PeriodForSinglePic));
            ToFillTimePixel=cast((TimeSingle-AverageTimeFrame)/SpikeMovieData(NbSaveMovie).TimePixelUnits,ChosenTimeClass);
            SpikeMovieData(NbSaveMovie).TimePixel=repmat(ToFillTimePixel,[1 1 SpikeMovieData(NbSaveMovie).DataSize(3)]);
            
            SpikeMovieData(NbSaveMovie).Exposure=Exposure*ones(SpikeMovieData(NbSaveMovie).DataSize(1:2));
            
            RatioPixelSpace=str2double(get(handles.SpaceCalib,'String'));
            
            % We calibrate the real size of the image based on the number of pixels and
            % the angular range.
            VoltagePerOpticalDegree=0.8325;
            MaxVoltage=10;
            MaxOpticalDegree=MaxVoltage/VoltagePerOpticalDegree;
            
            if header.acq.scanAngularRangeFast>MaxOpticalDegree
                FastRange=MaxOpticalDegree;
            else
                FastRange=header.acq.scanAngularRangeFast;
            end
            
            if header.acq.scanAngularRangeSlow>MaxOpticalDegree
                SlowRange=MaxOpticalDegree;
            else
                SlowRange=header.acq.scanAngularRangeSlow;
            end
            
            ZoomHundred=header.acq.zoomhundreds;
            ZoomTens=header.acq.zoomtens;
            ZoomOnes=header.acq.zoomones;
            ZoomFrac=header.acq.zoomfrac;
            
            DoubleZoom=ZoomOnes+ZoomTens*10+ZoomHundred*100+ZoomFrac*0.1;
            
            if (header.acq.fastScanningX==1)
                RatioPixelSpaceX=RatioPixelSpace*FastRange/DoubleZoom/header.acq.linesPerFrame;
                RatioPixelSpaceY=RatioPixelSpace*SlowRange/DoubleZoom/header.acq.pixelsPerLine;
            else
                RatioPixelSpaceX=RatioPixelSpace*SlowRange/DoubleZoom/header.acq.pixelsPerLine;
                RatioPixelSpaceY=RatioPixelSpace*FastRange/DoubleZoom/header.acq.linesPerFrame;
            end
            
            % We create the position matrix that store X,Y,Z position of all pixels
            [SpikeMovieData(NbSaveMovie).Xposition(:,:),SpikeMovieData(NbSaveMovie).Yposition(:,:)] = meshgrid(RatioPixelSpaceY*(1:SpikeMovieData(NbSaveMovie).DataSize(2)),RatioPixelSpaceX*(1:SpikeMovieData(NbSaveMovie).DataSize(1)));
            SpikeMovieData(NbSaveMovie).Zposition(:,:)=zeros(size(SpikeMovieData(NbSaveMovie).Xposition(:,:)));
            
            % We set the labelling properties
            SpikeMovieData(NbSaveMovie).Label.XLabel='\mum';
            SpikeMovieData(NbSaveMovie).Label.YLabel='\mum';
            SpikeMovieData(NbSaveMovie).Label.ZLabel='\mum';
            SpikeMovieData(NbSaveMovie).Label.CLabel='Fluorescence (au)';
            SpikeMovieData(NbSaveMovie).Label.ListText=['Scanimage - chan',num2str(NbLoadMovie)];
            
            delete(h);
        end
    end
    ValidateValues_Callback(hObject, eventdata, handles);
    
catch errorObj
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
end


% --- Executes on button press in SelectFile.
function SelectFile_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global header;

% Open file path
[filename, pathname] = uigetfile( ...
    {'*.tif','All Files (*.tif)'},'Select TIF File');

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
        FileTiff=Tiff(fullfile(pathname,filename),'r');
        headerString=FileTiff.getTag('ImageDescription');
        header=parseHeader(headerString);
        FileTiff.close();
        NumberMovie=header.acq.numberOfChannelsSave;
        
        % We create the text for the number of Movies
        for i=1:NumberMovie
            TextToMovies{i}=['Movie ' num2str(i)];
        end
        set(handles.MovieSelector,'String',TextToMovies);
        
        % By default we display all available Movies
        set(handles.MovieSelector,'Value',1:NumberMovie);
        
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



function SpaceCalib_Callback(hObject, eventdata, handles)
% hObject    handle to SpaceCalib (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SpaceCalib as text
%        str2double(get(hObject,'String')) returns contents of SpaceCalib as a double


% --- Executes during object creation, after setting all properties.
function SpaceCalib_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpaceCalib (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
