function varargout = SpikeExtractor(varargin)
% SPIKEEXTRACTOR M-file for SpikeExtractor.fig
%      SPISEEXTRACTOR, by itself, creates a new SPIKEEXTRACTOR or raises the existing
%      singleton*.
%
%      H = SPIKEEXTRACTOR returns the handle to a new SPIKEEXTRACTOR or the handle to
%      the existing singleton*.
%
%      SPIKEEXTRACTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPIKEEXTRACTOR.M with the given input arguments.
%
%      SPIKEEXTRACTOR('Property','Value',...) creates a new SPIKEEXTRACTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SpikeExtractor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SpikeExtractor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help SpikeExtractor

% Last Modified by GUIDE v2.5 01-Mar-2012 13:37:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpikeExtractor_OpeningFcn, ...
                   'gui_OutputFcn',  @SpikeExtractor_OutputFcn, ...
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


% --- Executes just before SpikeExtractor is made visible.
function SpikeExtractor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SpikeExtractor (see VARARGIN)

% Choose default command line output for SpikeExtractor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SpikeExtractor wait for user response (see UIRESUME)
% uiwait(handles.MainWindow);

% We initialize the main variables
global SpikeMovieData;
global SpikeImageData;
global SpikeTraceData;
global SpikeBatchData;
global SpikeGui;
global SpikeOption;

% We add all subfolders to matlab search path so that all functions are
% available
CurrentMfilePath = mfilename('fullpath');
[PathToM, name, ext] = fileparts(CurrentMfilePath);
AllFolderAndSubs = genpath(PathToM);
addpath(AllFolderAndSubs);

% We initialize the global variables 

InitGUI();
% SpikeGui is always initialize as it stores handles that can change from
% one execution to the next.
if isempty(SpikeOption);
    InitOption();
end
if isempty(SpikeImageData);
    InitImages();
end
if isempty(SpikeTraceData);
    InitTraces();
end
if isempty(SpikeMovieData);
    InitMovies();
end
if isempty(SpikeBatchData);
    InitBatch();
end

% We save the handle to the main GUI
SpikeGui(1).MAINhandle=handles;

% We start the Apps folder location
SpikeGui.CurrentAppFolder='Apps';

% We load availables Apps
RefreshAppsList(handles);

% We change the default colormap to gray
NewDefaultColorMap=colormap('gray');
set(0,'DefaultFigureColormap',NewDefaultColorMap);

% We update the display in case memory is not empty (usefull after a crash)
UpdateInterface(handles);

% --- Outputs from this function are returned to the command line.
function varargout = SpikeExtractor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% Function to update the display on the figure
% This is optimized for speed to provide fast movie playback
function DisplayData(handles)
global SpikeMovieData;
global SpikeImageData;
global SpikeTraceData;
global SpikeGui;
global SpikeOption;

ListMovies=get(handles.ListSelectMovies,'Value');
ListImages=get(handles.ListSelectImages,'Value');
ListTraces=get(handles.ListSelectTraces,'Value');

% If anything is selected
if (isempty(ListMovies) && isempty(ListImages) && isempty(ListTraces))
    if (~isempty(SpikeGui.hDataDisplay))
        if (ishandle(SpikeGui.hDataDisplay))
            close(SpikeGui.hDataDisplay);
        end
    end
else
    % We create the figure if it does not exist
    if (~isempty(SpikeGui.hDataDisplay))
        if (~ishandle(SpikeGui.hDataDisplay))
            SpikeGui.hDataDisplay=figure('Name','Data display','NumberTitle','off');
            SpikeGui.ImageHandle=[];
            SpikeGui.TraceHandle=[];
            SpikeGui.SubAxes=[];
            SpikeGui.TitleHandle=[];
        else
            set(0,'CurrentFigure',SpikeGui.hDataDisplay);
        end
    else
        SpikeGui.hDataDisplay=figure('Name','Data display','NumberTitle','off');
        SpikeGui.ImageHandle=[];
        SpikeGui.TraceHandle=[];
        SpikeGui.SubAxes=[];
        SpikeGui.TitleHandle=[];
    end
    
    if (~isempty(ListMovies) || ~isempty(ListImages))
        RelativeHeightTrace=SpikeOption.RelativeHeightTrace;
    else
        RelativeHeightTrace=0;
    end
    
    
    MovieHeight=RelativeHeightTrace/(length(ListTraces)+RelativeHeightTrace);
    MovieWidth=1/(length(ListMovies)+length(ListImages));
    TraceHeight=1/(length(ListTraces)+RelativeHeightTrace);
    
    % We update the display of movies
    for CurrentMovieNumber=1:length(ListMovies)
        iMovie=ListMovies(CurrentMovieNumber);
        
        switch SpikeOption.DisplayMovieTitle
            case 1
                % Display movie name
                TestMovieTitle=SpikeMovieData(iMovie).Label.ListText;
            case 2
                % Display Frame number
                TestMovieTitle=[sprintf('%u',SpikeGui.CurrentNumberInMovie(iMovie)),'/',sprintf('%u',SpikeMovieData(iMovie).DataSize(3))];
            case 3
                % Display Time
                TestMovieTitle=strcat(num2str(SpikeGui.currentTime),'s');
        end
        
        if (SpikeOption.DisplayMovie3D==1)
            if (length(SpikeGui.ImageHandle)<CurrentMovieNumber) || any(isempty(SpikeGui.ImageHandle) || any(~ishandle(SpikeGui.ImageHandle)))
                % We create the full display for the current selected movie
                % along with its associated labels
                LocalAxe=axes('Parent',SpikeGui.hDataDisplay,...
                    'OuterPosition',[(CurrentMovieNumber-1)*MovieWidth length(ListTraces)*TraceHeight MovieWidth MovieHeight]);
                SpikeGui.SubAxes(CurrentMovieNumber)=LocalAxe;
                SpikeGui.ImageHandle(CurrentMovieNumber)=surf(LocalAxe,SpikeMovieData(iMovie).Xposition(:,:),SpikeMovieData(iMovie).Yposition(:,:),...
                    double(SpikeMovieData(iMovie).Movie(:,:,SpikeGui.CurrentNumberInMovie(iMovie))));
                xlabel(LocalAxe,SpikeMovieData(iMovie).Label.XLabel);
                ylabel(LocalAxe,SpikeMovieData(iMovie).Label.YLabel);
                
                if SpikeOption.DisplayMovieTitle<4
                    SpikeGui.TitleHandle(CurrentMovieNumber)=title(LocalAxe,TestMovieTitle);
                end
                set(LocalAxe,'CLimMode','manual');
                set(LocalAxe,'ZLimMode','manual');
            else
                % We only update the data as the display is already created to
                % ensure maximal speed
                set(SpikeGui.ImageHandle(CurrentMovieNumber),'ZData',double(SpikeMovieData(iMovie).Movie(:,:,SpikeGui.CurrentNumberInMovie(iMovie))));
                if (SpikeOption.DisplayMovieTitle==2 || SpikeOption.DisplayMovieTitle==3)
                    set(SpikeGui.TitleHandle(CurrentMovieNumber),'String',TestMovieTitle);
                end
            end
        else
            if (length(SpikeGui.ImageHandle)<CurrentMovieNumber) || any(isempty(SpikeGui.ImageHandle)) || any(~ishandle(SpikeGui.ImageHandle))
                % We create the full display for the current selected movie
                % along with its associated labels
                LocalAxe=axes('Parent',SpikeGui.hDataDisplay,...
                    'OuterPosition',[(CurrentMovieNumber-1)*MovieWidth length(ListTraces)*TraceHeight MovieWidth MovieHeight]);
                SpikeGui.SubAxes(CurrentMovieNumber)=LocalAxe;
                
                XPosVector=mean(SpikeMovieData(iMovie).Xposition(:,:),1);
                YPosVector=mean(SpikeMovieData(iMovie).Yposition(:,:),2);
                
                SpikeGui.ImageHandle(CurrentMovieNumber)=imagesc(XPosVector,YPosVector,...
                    SpikeMovieData(iMovie).Movie(:,:,SpikeGui.CurrentNumberInMovie(iMovie)));
                
                switch SpikeOption.DisplayMovieXYRatio
                    case 1
                        axis(LocalAxe,'normal');
                    case 2
                        axis(LocalAxe,'image');
                end
                
                if SpikeOption.DisplayMovieAxis==2
                    axis(LocalAxe,'off');
                else
                    xlabel(LocalAxe,SpikeMovieData(iMovie).Label.XLabel);
                    ylabel(LocalAxe,SpikeMovieData(iMovie).Label.YLabel);
                end
                
                if SpikeOption.DisplayMovieTitle<4
                    SpikeGui.TitleHandle(CurrentMovieNumber)=title(LocalAxe,TestMovieTitle);
                end
                
                set(LocalAxe,'CLimMode','manual');
            else
                % We only update the data as the display is already created to
                % ensure maximal speed
                set(SpikeGui.ImageHandle(CurrentMovieNumber),'CData',SpikeMovieData(iMovie).Movie(:,:,SpikeGui.CurrentNumberInMovie(iMovie)));
                if (SpikeOption.DisplayMovieTitle==2 || SpikeOption.DisplayMovieTitle==3)
                    set(SpikeGui.TitleHandle(CurrentMovieNumber),'String',TestMovieTitle);
                end
            end
        end
    end
    
    % If no movies we adjust the value of currentMovieNumber to 0
    if isempty(CurrentMovieNumber)
        CurrentMovieNumber=0;
    end
    
    % We update the display of images
    for CurrentImageNumber=1:length(ListImages)
        iImage=ListImages(CurrentImageNumber);
        
        switch SpikeOption.DisplayImageTitle
            case 1
                % Display image name
                TestImageTitle=SpikeImageData(iImage).Label.ListText;
        end
        
        if (length(SpikeGui.ImageHandle)<CurrentImageNumber+CurrentMovieNumber) || any(isempty(SpikeGui.ImageHandle) || any(~ishandle(SpikeGui.ImageHandle)))
            % We create the full display for the current selected movie
            % along with its associated labels
            LocalAxe=axes('Parent',SpikeGui.hDataDisplay,...
                'OuterPosition',[(CurrentMovieNumber+CurrentImageNumber-1)*MovieWidth length(ListTraces)*TraceHeight MovieWidth MovieHeight]);
            SpikeGui.SubAxes(CurrentMovieNumber+CurrentImageNumber)=LocalAxe;
            
            XPosVector=mean(SpikeImageData(iImage).Xposition(:,:),1);
            YPosVector=mean(SpikeImageData(iImage).Yposition(:,:),2);
            SpikeGui.ImageHandle(CurrentMovieNumber+CurrentImageNumber)=imagesc(XPosVector,YPosVector,...
                SpikeImageData(iImage).Image);
            
            switch SpikeOption.DisplayImageXYRatio
                case 1
                    axis(LocalAxe,'normal');
                case 2
                    axis(LocalAxe,'image');
            end
            
            if SpikeOption.DisplayImageAxis==2
                axis(LocalAxe,'off');
            else
                xlabel(LocalAxe,SpikeImageData(iImage).Label.XLabel);
                ylabel(LocalAxe,SpikeImageData(iImage).Label.YLabel);
            end
            
            if SpikeOption.DisplayImageTitle<2
                SpikeGui.TitleHandle(CurrentMovieNumber+CurrentImageNumber)=title(LocalAxe,TestImageTitle);
            end
            
            set(LocalAxe,'CLimMode','manual');
        else
            % We only update the data as the display is already created to
            % ensure maximal speed
            set(SpikeGui.ImageHandle(CurrentMovieNumber+CurrentImageNumber),'CData',SpikeImageData(iImage).Image);
        end
    end
    
    % If no movies we adjust the value of currentMovieNumber to 0
    if isempty(CurrentImageNumber)
        CurrentImageNumber=0;
    end
    
    % We update the display of traces
    for CurrentTraceNumber=1:length(ListTraces)
        iTrace=ListTraces(CurrentTraceNumber);
        
        switch SpikeOption.DisplayTraceTitle
            case 1
                % Display trace name
                TestTraceTitle=SpikeTraceData(iTrace).Label.ListText;
            case 2
                % Display Time
                TestTraceTitle=strcat(num2str(SpikeGui.currentTime),'s');
        end
        
        if (length(SpikeGui.TraceHandle)<CurrentTraceNumber) || any(isempty(SpikeGui.TraceHandle) || any(~ishandle(SpikeGui.TraceHandle)))
            % We create the axes and plot the corresponding curve and its
            % labels
            LocalAxe=axes('Parent',SpikeGui.hDataDisplay,'OuterPosition',[0 (length(ListTraces)-CurrentTraceNumber)*TraceHeight 1 TraceHeight]);
            SpikeGui.SubAxes(CurrentImageNumber+CurrentMovieNumber+CurrentTraceNumber)=LocalAxe;
            SpikeGui.TraceHandle(CurrentTraceNumber)=plot(LocalAxe,SpikeTraceData(iTrace).XVector,SpikeTraceData(iTrace).Trace);
            
            if SpikeOption.DisplayTraceAxis==2
                axis(LocalAxe,'off');
            else
                xlabel(LocalAxe,'Time (s)');
                ylabel(LocalAxe,SpikeTraceData(iTrace).Label.YLabel);
            end
            
            if SpikeOption.DisplayTraceTitle<3
                SpikeGui.TitleHandle(CurrentMovieNumber+CurrentImageNumber+CurrentTraceNumber)=title(LocalAxe,TestTraceTitle);
            end
            
            if (SpikeOption.DisplayTraceTimeBar==1)
                v=axis(LocalAxe);
                SpikeGui.LineHandle(CurrentTraceNumber)=line('XData',[SpikeGui.currentTime SpikeGui.currentTime],'YData',[v(3) v(4)],'Color','r','LineWidth',1);
            end
            
            if (CurrentTraceNumber==length(ListTraces))
                switch SpikeOption.LinkAxis
                    case 2
                        linkaxes(SpikeGui.SubAxes(CurrentImageNumber+CurrentMovieNumber+1:CurrentImageNumber+CurrentMovieNumber+CurrentTraceNumber),'x');
                    case 3
                        linkaxes(SpikeGui.SubAxes(CurrentImageNumber+CurrentMovieNumber+1:CurrentImageNumber+CurrentMovieNumber+CurrentTraceNumber),'y');
                    case 4
                        linkaxes(SpikeGui.SubAxes(CurrentImageNumber+CurrentMovieNumber+1:CurrentImageNumber+CurrentMovieNumber+CurrentTraceNumber),'xy');
                end                
            end
        else
            if (SpikeOption.DisplayTraceTimeBar==1)
                % We only update the display for the current time point
                v=axis(SpikeGui.SubAxes(CurrentImageNumber+CurrentMovieNumber+CurrentTraceNumber));
                set(SpikeGui.LineHandle(CurrentTraceNumber),'XData',[SpikeGui.currentTime SpikeGui.currentTime],'YData',[v(3) v(4)]);
            end
            if SpikeOption.DisplayTraceTitle==2
                set(SpikeGui.TitleHandle(CurrentImageNumber+CurrentMovieNumber+CurrentTraceNumber),'String',TestTraceTitle);
            end
        end
    end
end


% --- Executes on slider movement.
function PositionSlider_Callback(hObject, eventdata, handles)
% hObject    handle to PositionSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global SpikeGui;

NewPos=get(handles.PositionSlider,'Value');

SpikeGui.currentTime=NewPos*(SpikeGui.MaxTime-SpikeGui.MinTime)+SpikeGui.MinTime;
set(handles.currentTime,'String',num2str(SpikeGui.currentTime));

UpdateFrameNumber(handles);
DisplayData(handles);


% --- Executes during object creation, after setting all properties.
function PositionSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PositionSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in PlayMovie.
function PlayMovie_Callback(hObject, eventdata, handles)
% hObject    handle to PlayMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeGui;

if (get(handles.PlayMovie,'Value')==0)
    if strcmp(get(SpikeGui.TimerData,'Running'),'on')
        stop(SpikeGui.TimerData);
    end
    set(handles.PlayMovie,'String','Play');
    
    HallObj=findobj('Enable','off');
    set(HallObj,'Enable','on');
else
    % This is fixed as going faster won't be noticable
    NumberFrameDisplayPerSecond=25;
    
    if isempty(SpikeGui.TimerData)
        % Before we create a new one, we remove any remainings of timers
        % from memory
        out = timerfind;
        delete(out);
        
        SpikeGui.TimerData=timer('TimerFcn', {@FrameRateDisplay,NumberFrameDisplayPerSecond,handles},...
            'Period',1/NumberFrameDisplayPerSecond,'ExecutionMode','fixedRate','BusyMode','drop');
    else
        if strcmp(get(SpikeGui.TimerData,'Running'),'off')
            delete(SpikeGui.TimerData);
            
            SpikeGui.TimerData=timer('TimerFcn', {@FrameRateDisplay,NumberFrameDisplayPerSecond,handles},...
                'Period',1/NumberFrameDisplayPerSecond,'ExecutionMode','fixedRate','BusyMode','drop');
        end
    end
    
    HallObj=findobj('Enable','on');
    MoviePlayBacksObj=findobj(handles.TimePanel,'Enable','on');
    HallObj=setdiff(HallObj,MoviePlayBacksObj);
    set(HallObj,'Enable','off');
    set(handles.PlayMovie,'String','Stop');

    start(SpikeGui.TimerData);
end


% This function is called by the timer to display one frame of the movie
% at the right frame rate
function FrameRateDisplay(obj, event,NumberFrameDisplayPerSecond,handles)
global SpikeGui;

TimeSpeed=str2double(get(handles.FactorRealTime,'String'));
TimeStep=TimeSpeed/NumberFrameDisplayPerSecond;

if (SpikeGui.currentTime+TimeStep)<SpikeGui.MaxTime
    SpikeGui.currentTime=SpikeGui.currentTime+TimeStep;
else
    SpikeGui.currentTime=SpikeGui.MinTime;
end

set(handles.currentTime,'String',sprintf('%0.4f',SpikeGui.currentTime));
set(handles.PositionSlider,'Value',(SpikeGui.currentTime-SpikeGui.MinTime)/(SpikeGui.MaxTime-SpikeGui.MinTime));
UpdateFrameNumber(handles);
DisplayData(handles);
    

% --- Executes on slider movement.
function SpeedMovieButton_Callback(hObject, eventdata, handles)
% hObject    handle to SpeedMovieButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SpeedMovieButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpeedMovieButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in BatchApps.
function BatchApps_Callback(hObject, eventdata, handles)
% hObject    handle to BatchApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeBatchData;

% We initiate the batch list
if (get(handles.BatchApps,'Value')==1)    
    % Transform the batch button to allow ABORT
    set(handles.BatchApps,'String','STOP');
    set(handles.BatchList,'Value',1);
else
    set(handles.BatchApps,'String','Batch');
end

% And process the list while the user does not stop it or we reach the end
% of the batch list
try
    while (get(handles.BatchApps,'Value')==1)
        CurrentAppNumber=get(handles.BatchList,'Value');
        HandleToLoader=str2func(SpikeBatchData(CurrentAppNumber).AppsName);
        
        % We turn off all object on the interface to allow user interaction
        % with the Apps only
        HallObj=findobj('Enable','on');
        set(HallObj,'Enable','off');
        set(handles.BatchApps,'Enable','on');
        
        if ~isempty(SpikeBatchData(CurrentAppNumber).Settings)
            h=HandleToLoader([],SpikeBatchData(CurrentAppNumber).Settings);
        else
            h=HandleToLoader();
        end
        
        HandleToLoader('ApplyApps_Callback',h,[],guidata(h));
        if ishandle(h)
            delete(h);
        end
        
        % Turn main interface ON again
        set(HallObj,'Enable','on');
        
        % We update AppNumber in case one Apps change it directly on the interface
        CurrentAppNumber=get(handles.BatchList,'Value');
        
        UpdateInterface(handles);
        if CurrentAppNumber<length(SpikeBatchData)
            % We shift current Apps one time
            set(handles.BatchList,'Value',CurrentAppNumber+1);
        else
            % If we reached the end of the list, we stop processing
            set(handles.BatchApps,'Value',0);
            set(handles.BatchApps,'String','Batch');
        end
    end
catch errorObj
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
    % If there is a problem, we display the error message and bring back
    % the main interface ON.
    if exist('h','var')
        if ishandle(h)
            delete(h);
        end
    end
    HallObj=findobj('Enable','off');
    set(HallObj,'Enable','on');
    set(handles.BatchApps,'Value',0);
    set(handles.BatchApps,'String','Batch');
    UpdateInterface(handles);
end


% --- Executes on selection change in AppsList.
function AppsList_Callback(hObject, eventdata, handles)
% hObject    handle to AppsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AppsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AppsList

% If user double click, we open current selection (if only one is selected).
global SpikeGui;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    % We turn it back on in the end
    Cleanup1=onCleanup(@()set(InterfaceObj,'Enable','on'));
    
    if strcmp(get(handles.MainWindow,'SelectionType'),'open')
        if (~isempty(get(handles.AppsList,'String')))
            if (length(get(handles.AppsList,'Value'))==1)
                if (get(handles.AppsList,'Value')>0)
                    
                    ListOfApps=get(handles.AppsList,'String');
                    Filename=ListOfApps{get(handles.AppsList,'Value')};
                    [path,name,ext] = fileparts(Filename);
                    
                    if strcmp(ext,'.fig')
                        HallObj=findobj('Enable','on');
                        set(HallObj,'Enable','off');
                        % if a figure file, this is a regular Apps, start
                        % it.
                        CurrentApps=name;
                        HandleToLoader=str2func(CurrentApps);
                        
                        try
                            h=HandleToLoader();
                            uiwait(h);
                            if exist('h','var')
                                if ishandle(h)
                                    delete(h);
                                end
                            end
                            HallObj=findobj('Enable','off');
                            set(HallObj,'Enable','on');
                            
                            UpdateInterface(handles);
                        catch errorObj
                            % If we have a recursion error because user is clicking
                            % too fast, we do nothing. Otherwise we display error
                            % message and reactivate main Window.
                            if (~strcmp(errorObj.identifier,'MATLAB:hgload:RecursionDetected'))
                                errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
                                
                                if exist('h','var')
                                    if ishandle(h)
                                        delete(h);
                                    end
                                end
                                HallObj=findobj('Enable','off');
                                set(HallObj,'Enable','on');
                                
                                UpdateInterface(handles);
                            end
                        end
                    else
                        % if not a figure, this a folder, open the folder
                        Slash=filesep;
                        SpikeGui.CurrentAppFolder=strcat(SpikeGui.CurrentAppFolder,Slash,Filename);
                        RefreshAppsList(handles);
                    end
                end
            end
        end
    end
catch errorObj
        errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');  
end


% --- Executes during object creation, after setting all properties.
function AppsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AppsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in BatchList.
function BatchList_Callback(hObject, eventdata, handles)
% hObject    handle to BatchList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns BatchList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BatchList    
global SpikeBatchData;

if strcmp(get(handles.MainWindow,'SelectionType'),'open')
    if (~isempty(get(handles.BatchList,'String')))
        if (length(get(handles.BatchList,'Value'))==1)
            if (get(handles.BatchList,'Value')>0)
                
                CurrentApps=get(handles.BatchList,'Value');
                HallObj=findobj('Enable','on');
                set(HallObj,'Enable','off');

                HandleToLoader=str2func(SpikeBatchData(CurrentApps).AppsName);
                
                try
                    if ~isempty(SpikeBatchData(CurrentApps).Settings)
                        h=HandleToLoader([],SpikeBatchData(CurrentApps).Settings);
                    else
                        h=HandleToLoader();
                    end
                    uiwait(h);
                    
                    if ishandle(h)
                        SpikeBatchData(CurrentApps).Settings=HandleToLoader('GetSettings',h);
                    end
                    
                    if exist('h','var')
                        if ishandle(h)
                            delete(h);
                        end
                    end
                    HallObj=findobj('Enable','off');
                    set(HallObj,'Enable','on');
                    
                    UpdateInterface(handles);     
                catch errorObj
                    % If we have a recursion error because user is clicking
                    % too fast, we do nothing. Otherwise we display error
                    % message and reactivate main Window.
                    if (~strcmp(errorObj.identifier,'MATLAB:hgload:RecursionDetected'))
                        errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
                        
                        if exist('h','var')
                            if ishandle(h)
                                delete(h);
                            end
                        end
                        HallObj=findobj('Enable','off');
                        set(HallObj,'Enable','on');
                        
                        UpdateInterface(handles);
                    end
                end
            end
        end
    end 
end


% --- Executes during object creation, after setting all properties.
function BatchList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BatchList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddApps.
function AddApps_Callback(hObject, eventdata, handles)
% hObject    handle to AddApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeBatchData;
global SpikeGui;

CurrentSelectedApps=get(handles.AppsList,'Value');
ListAllApps=get(handles.AppsList,'String');

Filename=ListAllApps{CurrentSelectedApps};
[path,AppName,ext] = fileparts(Filename);
switch ext
    case '.fig'
        NumberAppliedApps=length(SpikeBatchData);
       
        SpikeBatchData(NumberAppliedApps+1).Settings=[];
        SpikeBatchData(NumberAppliedApps+1).AppsName=AppName;
        SpikeBatchData(NumberAppliedApps+1).Filename=Filename;
        SpikeBatchData(NumberAppliedApps+1).Path=SpikeGui.CurrentAppFolder;
        SpikeBatchData(NumberAppliedApps+1).Label.ListText=AppName;
        UpdateBatch(handles);

end


% --- Executes on button press in MoveAppsUp.
function MoveAppsUp_Callback(hObject, eventdata, handles)
% hObject    handle to MoveAppsUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeBatchData;

CurrentSelectedApps=get(handles.BatchList,'Value');

if (CurrentSelectedApps>1)
    % We swap the settings
    StoreOld=SpikeBatchData(CurrentSelectedApps-1);
    SpikeBatchData(CurrentSelectedApps-1)=SpikeBatchData(CurrentSelectedApps);
    SpikeBatchData(CurrentSelectedApps)=StoreOld;
    UpdateBatch(handles);

    set(handles.BatchList,'Value',CurrentSelectedApps-1);
end


% --- Executes on button press in MoveAppsDown.
function MoveAppsDown_Callback(hObject, eventdata, handles)
% hObject    handle to MoveAppsDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeBatchData;

CurrentSelectedApps=get(handles.BatchList,'Value');
NumberAppliedApps=length(SpikeBatchData);

if (CurrentSelectedApps<NumberAppliedApps)
    % We swap the settings
    StoreOld=SpikeBatchData(CurrentSelectedApps+1);
    SpikeBatchData(CurrentSelectedApps+1)=SpikeBatchData(CurrentSelectedApps);
    SpikeBatchData(CurrentSelectedApps)=StoreOld;
    UpdateBatch(handles);

    set(handles.BatchList,'Value',CurrentSelectedApps+1);
end


% --- This function is used to refresh the AppList from Hard drive
function RefreshAppsList(handles)
% hObject    handle to RefreshAppsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeGui;

CurrentMfilePath = mfilename('fullpath');
[PathToM, name, ext] = fileparts(CurrentMfilePath);

Slash=filesep;

% We clean up the path
OldPath=cd;
cd(strcat(PathToM,Slash,SpikeGui.CurrentAppFolder));
CurrentPath=cd;
SpikeGui.CurrentAppFolder=CurrentPath(length(PathToM)+1:end);
cd(OldPath);

set(handles.CurrentAppFolder,'String',SpikeGui.CurrentAppFolder);

% We check current level
[pathstr, name, ext]=fileparts(SpikeGui.CurrentAppFolder);

if strcmp(name,'Apps')
    % We don't display the '..' button in that case
    BanDotDot=1;
else
    BanDotDot=0;
end

% We get the list of Apps
AppsDir = dir(strcat(PathToM,Slash,SpikeGui.CurrentAppFolder,Slash,'*.fig'));

% We get the list of directories and files
AllDir = dir(strcat(PathToM,Slash,SpikeGui.CurrentAppFolder,Slash));

ListOfAllDir = {AllDir.name};
ListOfAppsOnly = {AppsDir.name};

j=1;
for i=1:length(ListOfAllDir)
    if (AllDir(i).isdir && ~strcmp(ListOfAllDir{i},'.svn'))
        % We ban '..' if we are in the root Apps folder
        if ~(strcmp(ListOfAllDir{i},'..') && 1==BanDotDot)
            % We check no folder are Apps dedicated folder
            AppFolder=0;
            
            if ~strcmp(ListOfAllDir{i},'.')
                for k=1:length(AppsDir)
                    if ~isempty(strfind(ListOfAppsOnly{k}, ListOfAllDir{i}))
                        AppFolder=1;
                        break;
                    end
                end
            end
            if AppFolder==0
                ListOfApps{j}=ListOfAllDir{i};
                j=j+1;
            end
        end
    end
end

ListOfApps = [ListOfApps ListOfAppsOnly];
PreviousValue=get(handles.AppsList,'Value');

if ((PreviousValue>0) && PreviousValue>length(ListOfApps))
    set(handles.AppsList,'Value',min(length(ListOfApps),PreviousValue));
end
set(handles.AppsList,'String',ListOfApps);


% This function is to update the Batch List on the interface
function UpdateBatch(handles)
global SpikeBatchData;

if (~isempty(SpikeBatchData))
    set(handles.BatchList,'Enable','on');
    for i=1:length(SpikeBatchData)
        TextToBatch{i}=[num2str(i),' - ',SpikeBatchData(i).Label.ListText];
    end
    set(handles.BatchList,'String',TextToBatch);
    
    PreviousListboxTop=get(handles.BatchList,'ListboxTop');
    PreviousSelApps=get(handles.BatchList,'Value');
    NewValue=max(1,min(PreviousSelApps,length(SpikeBatchData)));
    NewListboxTop=min(max(NewValue),min(length(SpikeBatchData),PreviousListboxTop));
    if isempty(NewListboxTop)
        NewListboxTop=1;
    end
    
    set(handles.BatchList,'ListboxTop',NewListboxTop);
    set(handles.BatchList,'Value',NewValue);
else
    set(handles.BatchList,'String','');
    set(handles.BatchList,'Enable','off');
end

% This function update the time limit that is used by the time playback
% function 
function UpdateTimeLimit(handles)
global SpikeMovieData;
global SpikeTraceData;
global SpikeGui;

% We put back MaxTime and MinTime to empty to rescale the limits
SpikeGui.MaxTime=[];
SpikeGui.MinTime=[];

% We check SpikeMovieData for new selection
SelectedMovies=get(handles.ListSelectMovies,'Value');
for i=SelectedMovies
    if isempty(SpikeGui.MaxTime)
        SpikeGui.MaxTime=max(SpikeMovieData(i).TimeFrame);
    else
        SpikeGui.MaxTime=max(SpikeGui.MaxTime,max(SpikeMovieData(i).TimeFrame));
    end
    
    if isempty(SpikeGui.MinTime)
        SpikeGui.MinTime=min(SpikeMovieData(i).TimeFrame);
    else
        SpikeGui.MinTime=min(SpikeGui.MinTime,min(SpikeMovieData(i).TimeFrame));
    end
end

% We check SpikeTraceData for new selection
SelectedTraces=get(handles.ListSelectTraces,'Value');
for i=SelectedTraces
    if isempty(SpikeGui.MaxTime)
        SpikeGui.MaxTime=max(SpikeTraceData(i).XVector);
    else
        SpikeGui.MaxTime=max(SpikeGui.MaxTime,max(SpikeTraceData(i).XVector));
    end
    
    if isempty(SpikeGui.MinTime)
        SpikeGui.MinTime=min(SpikeTraceData(i).XVector);
    else
        SpikeGui.MinTime=min(SpikeGui.MinTime,min(SpikeTraceData(i).XVector));
    end
end

       
% And then we populate the interface with Movie playback options and
% update the display
if ~isempty(SpikeGui.MaxTime)
    
    if isempty(SpikeGui.currentTime)
        SpikeGui.currentTime=SpikeGui.MinTime;
    else
        SpikeGui.currentTime=max(min(SpikeGui.MaxTime,SpikeGui.currentTime),SpikeGui.MinTime);
    end
    
    set(handles.PositionSlider,'Value',(SpikeGui.currentTime-SpikeGui.MinTime)/(SpikeGui.MaxTime-SpikeGui.MinTime));
    set(handles.currentTime,'String',num2str(SpikeGui.currentTime));
    set(handles.TimeText,'String',['/' num2str(SpikeGui.MaxTime) ' s']);
    
    MoviePlayBacksObj=findobj(handles.TimePanel,'Enable','off');
    set(MoviePlayBacksObj,'Enable','on');
    
    % We update current frame number
    UpdateFrameNumber(handles);
else
    set(handles.PositionSlider,'Value',0);
    set(handles.currentTime,'String','0');
    set(handles.TimeText,'String',['/... s']);
    
    MoviePlayBacksObj=findobj(handles.TimePanel,'Enable','on');
    set(MoviePlayBacksObj,'Enable','off');
end


% This function is to update the interface in case anything change in the
% data that need some adjustements. 
function UpdateInterface(handles)
global SpikeMovieData;
global SpikeImageData;
global SpikeTraceData;
global SpikeGui;

handles=guidata(handles.output);

% We clear current figure in case something changed in the data to force
% update of figure axes
ClearFigure(handles);

% We check SpikeMovieData for new data
if isfield(SpikeMovieData,'TimeFrame') && (~isempty(SpikeMovieData))
    set(handles.ListSelectMovies,'Enable','on');
    
    for i=1:length(SpikeMovieData)
        TextToMovies{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
    end
    set(handles.ListSelectMovies,'String',TextToMovies);
    
    PreviousListboxTop=get(handles.ListSelectMovies,'ListboxTop');
    PreviousSelMovies=get(handles.ListSelectMovies,'Value');
    NewValues=intersect(PreviousSelMovies,1:length(SpikeMovieData));
    NewListboxTop=min(max(NewValues),min(length(SpikeMovieData),PreviousListboxTop));
    if isempty(NewListboxTop)
        NewListboxTop=1;
    end
    set(handles.ListSelectMovies,'ListboxTop',NewListboxTop);
    set(handles.ListSelectMovies,'Value',NewValues);
else
    set(handles.ListSelectMovies,'String','');
    set(handles.ListSelectMovies,'Value',[]);
    set(handles.ListSelectMovies,'Enable','off');
end

% We check SpikeImageData for new data
if isfield(SpikeImageData,'Image')
    if (~isempty(SpikeImageData))
        set(handles.ListSelectImages,'Enable','on');
        
        for i=1:length(SpikeImageData)
            TextToImage{i}=[num2str(i),' - ',SpikeImageData(i).Label.ListText];
        end
        
        set(handles.ListSelectImages,'String',TextToImage);
        
        PreviousListboxTop=get(handles.ListSelectImages,'ListboxTop');
        PreviousSelImages=get(handles.ListSelectImages,'Value');
        NewValues=intersect(PreviousSelImages,1:length(SpikeImageData));
        NewListboxTop=min(max(NewValues),min(length(SpikeImageData),PreviousListboxTop));
        if isempty(NewListboxTop)
            NewListboxTop=1;
        end
        set(handles.ListSelectImages,'ListboxTop',NewListboxTop);
        set(handles.ListSelectImages,'Value',NewValues);
    else
        set(handles.ListSelectImages,'String','');
        set(handles.ListSelectImages,'Value',[]);
        set(handles.ListSelectImages,'Enable','off');
    end
else
    set(handles.ListSelectImages,'String','');
    set(handles.ListSelectImages,'Value',[]);
    set(handles.ListSelectImages,'Enable','off');
end

% We check SpikeTraceData for new data
if isfield(SpikeTraceData,'Trace') && (~isempty(SpikeTraceData))
    set(handles.ListSelectTraces,'Enable','on');
    
    for i=1:length(SpikeTraceData)
        TextToTraces{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    
    set(handles.ListSelectTraces,'String',TextToTraces);
    
    PreviousListboxTop=get(handles.ListSelectTraces,'ListboxTop');
    PreviousSelTraces=get(handles.ListSelectTraces,'Value');
    NewValues=intersect(PreviousSelTraces,1:length(SpikeTraceData));
    NewListboxTop=min(max(NewValues),min(length(SpikeTraceData),PreviousListboxTop));
    if isempty(NewListboxTop)
        NewListboxTop=1;
    end
    set(handles.ListSelectTraces,'ListboxTop',NewListboxTop);
    set(handles.ListSelectTraces,'Value',NewValues);
else
    set(handles.ListSelectTraces,'String','');
    set(handles.ListSelectTraces,'Value',[]);
    set(handles.ListSelectTraces,'Enable','off');
end

% We also update the Batch list
UpdateBatch(handles);

% We also update the time limits of the display
UpdateTimeLimit(handles)

% Create display figure and add image data to it
DisplayData(handles);


% --- Executes during object creation, after setting all properties.
function MainWindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MainWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in ListSelectMovies.
function ListSelectMovies_Callback(hObject, eventdata, handles)
% hObject    handle to ListSelectMovies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListSelectMovies contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListSelectMovies
ClearFigure(handles);

% We also update the time limits of the display
UpdateTimeLimit(handles)

DisplayData(handles);


% --- Executes during object creation, after setting all properties.
function ListSelectMovies_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListSelectMovies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function SpeedSlider_Callback(hObject, eventdata, handles)
% hObject    handle to SpeedSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global SpikeGui;

SpeedValue=get(handles.SpeedSlider,'Value');
MinFactor=0.01;
NewSpeed=10^(SpeedValue*5)*MinFactor;
MajorValue=(SpikeGui.MaxTime-SpikeGui.MinTime)*NewSpeed/1000;
MinorValue=MajorValue/10;

FinalMat=[MinorValue MajorValue]/(SpikeGui.MaxTime-SpikeGui.MinTime);
set(handles.PositionSlider,'SliderStep',FinalMat);
set(handles.FactorRealTime,'String',num2str(NewSpeed));


% --- Executes during object creation, after setting all properties.
function SpeedSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpeedSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in ListSelectTraces.
function ListSelectTraces_Callback(hObject, eventdata, handles)
% hObject    handle to ListSelectTraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListSelectTraces contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListSelectTraces
ClearFigure(handles);

% We also update the time limits of the display
UpdateTimeLimit(handles)

DisplayData(handles);

% bring back the main interface to the front
figure(handles.output);


% Function to clear the axes on the current figure
function ClearFigure(handles)
global SpikeGui;

if (~isempty(SpikeGui.hDataDisplay))
    if (ishandle(SpikeGui.hDataDisplay))
        clf(SpikeGui.hDataDisplay);
    end
end

SpikeGui.ImageHandle=[];
SpikeGui.TraceHandle=[];
SpikeGui.SubAxes=[];
SpikeGui.TitleHandle=[];


% --- Executes during object creation, after setting all properties.
function ListSelectTraces_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListSelectTraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function FactorRealTime_Callback(hObject, eventdata, handles)
% hObject    handle to FactorRealTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FactorRealTime as text
%        str2double(get(hObject,'String')) returns contents of FactorRealTime as a double
global SpikeGui;

MinFactor=0.01;
MaxFactor=1000;

SpeedValue=str2double(get(handles.FactorRealTime,'String'));
if ((SpeedValue>MaxFactor) || (SpeedValue<MinFactor))
    SpeedValue=max(MinFactor,min(MaxFactor,SpeedValue));
    set(handles.FactorRealTime,'String',num2str(SpeedValue));
end

SliderPos=log10(SpeedValue/MinFactor)/5;
set(handles.SpeedSlider,'Value',SliderPos);

MajorValue=(SpikeGui.MaxTime-SpikeGui.MinTime)*SpeedValue/1000;
MinorValue=MajorValue/10;

FinalMat=[MinorValue MajorValue]/(SpikeGui.MaxTime-SpikeGui.MinTime);
set(handles.PositionSlider,'SliderStep',FinalMat);


% --- Executes during object creation, after setting all properties.
function FactorRealTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FactorRealTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function currentTime_Callback(hObject, eventdata, handles)
% hObject    handle to currentTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of currentTime as text
%        str2double(get(hObject,'String')) returns contents of currentTime as a double
global SpikeGui;

NewPos=str2double(get(handles.currentTime,'String'));
NewPos=max(min(NewPos,SpikeGui.MaxTime),SpikeGui.MinTime);
set(handles.currentTime,'String',num2str(NewPos));
set(handles.PositionSlider,'Value',(NewPos-SpikeGui.MinTime)/(SpikeGui.MaxTime-SpikeGui.MinTime));

SpikeGui.currentTime=NewPos;

UpdateFrameNumber(handles);
DisplayData(handles);


% --- Executes during object creation, after setting all properties.
function currentTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Function to find the closest frame number on all frames for the current
% time position
function UpdateFrameNumber(handles)
global SpikeGui;
global SpikeMovieData;

if ~isempty(SpikeMovieData)
    if isfield(SpikeMovieData,'TimeFrame')
        for i=1:length(SpikeMovieData)
            [Value,Indice]=min(abs(SpikeMovieData(i).TimeFrame-SpikeGui.currentTime));
            SpikeGui.CurrentNumberInMovie(i)=Indice(1);
        end
    end
end


% --- Executes on selection change in ListSelectImages.
function ListSelectImages_Callback(hObject, eventdata, handles)
% hObject    handle to ListSelectImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListSelectImages contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListSelectImages
ClearFigure(handles);
DisplayData(handles);

% bring back the main interface to the front
figure(handles.output);


% --- Executes during object creation, after setting all properties.
function ListSelectImages_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListSelectImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on BatchList and none of its controls.
function BatchList_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to BatchList (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global SpikeBatchData;

% if asking for delete. We take charge of it, ie remove the selected item
if (strcmp(eventdata.Key,'backspace') || strcmp(eventdata.Key,'delete'))
        
    NumberAppliedApps=length(SpikeBatchData);    
    SelectedAppliedApps=get(handles.BatchList,'Value');
    ListRemaining=setdiff(1:NumberAppliedApps,SelectedAppliedApps);
    SpikeBatchData=SpikeBatchData(ListRemaining);
    UpdateBatch(handles);

end


% --- Executes on key press with focus on ListSelectMovies and none of its controls.
function ListSelectMovies_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ListSelectMovies (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;

% if asking for delete. We take charge of it, ie remove the selected item
if (strcmp(eventdata.Key,'backspace') || strcmp(eventdata.Key,'delete'))
    
    NumberItems=length(SpikeMovieData);
    SelectedItems=get(handles.ListSelectMovies,'Value');
    ListRemaining=setdiff(1:NumberItems,SelectedItems);
    SpikeMovieData=SpikeMovieData(ListRemaining);
    UpdateInterface(handles);
end

% --- Executes on key press with focus on ListSelectImages and none of its controls.
function ListSelectImages_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ListSelectImages (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global SpikeImageData;

% if asking for delete. We take charge of it, ie remove the selected item
if (strcmp(eventdata.Key,'backspace') || strcmp(eventdata.Key,'delete'))
    
    NumberItems=length(SpikeImageData);
    SelectedItems=get(handles.ListSelectImages,'Value');
    ListRemaining=setdiff(1:NumberItems,SelectedItems);
    SpikeImageData=SpikeImageData(ListRemaining);
    UpdateInterface(handles);
end

% --- Executes on key press with focus on ListSelectTraces and none of its controls.
function ListSelectTraces_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ListSelectTraces (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global SpikeTraceData;

% if asking for delete. We take charge of it, ie remove the selected item
if (strcmp(eventdata.Key,'backspace') || strcmp(eventdata.Key,'delete'))
    
    NumberItems=length(SpikeTraceData);
    SelectedItems=get(handles.ListSelectTraces,'Value');
    ListRemaining=setdiff(1:NumberItems,SelectedItems);
    SpikeTraceData=SpikeTraceData(ListRemaining);
    UpdateInterface(handles);
end
