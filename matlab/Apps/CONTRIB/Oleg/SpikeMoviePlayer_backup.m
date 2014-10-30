function varargout = SpikeMoviePlayer(varargin)
% SPIKEMOVIEPLAYER M-file for SpikeMoviePlayer.fig
%      SPIKEMOVIEPLAYER, by itself, creates a new SPIKEMOVIEPLAYER or raises the existing
%      singleton*.
%
%      H = SPIKEMOVIEPLAYER returns the handle to a new SPIKEMOVIEPLAYER or the handle to
%      the existing singleton*.
%
%      SPIKEMOVIEPLAYER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPIKEMOVIEPLAYER.M with the given input arguments.
%
%      SPIKEMOVIEPLAYER('Property','Value',...) creates a new SPIKEMOVIEPLAYER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SpikeMoviePlayer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SpikeMoviePlayer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help SpikeMoviePlayer

% Last Modified by GUIDE v2.5 28-Apr-2012 23:50:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpikeMoviePlayer_OpeningFcn, ...
                   'gui_OutputFcn',  @SpikeMoviePlayer_OutputFcn, ...
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


% --- Executes just before SpikeMoviePlayer is made visible.
function SpikeMoviePlayer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SpikeMoviePlayer (see VARARGIN)

% Choose default command line output for SpikeMoviePlayer
handles.output = hObject;
handles.hDataDisplay={};
handles.ImageHandle={};
handles.MinTime={};
handles.MaxTime={};
handles.currentTime={};


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SpikeMoviePlayer wait for user response (see UIRESUME)
% uiwait(handles.MainWindow);

% We initialize the main variables
global SpikeMovieData;
global SpikeImageData;
global SpikeTraceData;
global SpikeBatchData;
global SpikeGui;
global SpikeOption;

 UpdateInterface(handles);
% We add all subfolders to matlab search path so that all functions are
% available
% CurrentMfilePath = mfilename('fullpath');
% [PathToM, name, ext] = fileparts(CurrentMfilePath);
% AllFolderAndSubs = genpath(PathToM);
% addpath(AllFolderAndSubs);

% % We initialize the global variables 
% 
% InitGUI();
% % SpikeGui is always initialize as it stores handles that can change from
% % one execution to the next.
% if isempty(SpikeOption);
%     InitOption();
% end
% if isempty(SpikeImageData);
%     InitImages();
% end
% if isempty(SpikeTraceData);
%     InitTraces();
% end
%if isempty(SpikeMovieData);
%     InitMovies();
% end
% if isempty(SpikeBatchData);
%     InitBatch();
% end
% 
% % We save the handle to the main GUI
% SpikeGui(1).MAINhandle=handles;
% 
% % We start the Apps folder location
% SpikeGui.CurrentAppFolder='Apps';
% 
% % We load availables Apps
% RefreshAppsList(handles);
% 
% % We change the default colormap to gray
% NewDefaultColorMap=colormap('gray');
% set(0,'DefaultFigureColormap',NewDefaultColorMap);
% 
% % We update the display in case memory is not empty (usefull after a crash)
% UpdateInterface(handles);

% --- Outputs from this function are returned to the command line.
function varargout = SpikeMoviePlayer_OutputFcn(hObject, eventdata, handles) 
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
% global SpikeImageData;
% global SpikeTraceData;
global SpikeGui;
global SpikeOption;

ListMovies=get(handles.ListSelectMovies,'Value');
% ListImages=get(handles.ListSelectImages,'Value');
% ListTraces=get(handles.ListSelectTraces,'Value');

% If anything is selected
 if (isempty(ListMovies))%&& isempty(ListImages) && isempty(ListTraces))
    if (ishandle(handles.hDataDisplay) & ~isempty(handles.hDataDisplay))
            close(handles.hDataDisplay);
    end
else
    % We create the figure if it does not exist
    if (~ishandle(handles.hDataDisplay))
        if (~isempty(handles.hDataDisplay))
            handles.hDataDisplay=figure('Name','Data display','NumberTitle','off');
            %SpikeGui.ImageHandle=[];
            %SpikeGui.TraceHandle=[];
            handles.SubAxes=[];
            handles.TitleHandle=[];
        else
            set(0,'CurrentFigure',handles.hDataDisplay);
        end
    else
        handles.hDataDisplay=figure('Name','Data display','NumberTitle','off');
        %SpikeGui.ImageHandle=[];
        %SpikeGui.TraceHandle=[];
        handles.SubAxes=[];
        handles.TitleHandle=[];
    end
    
%     if (~isempty(ListMovies) || ~isempty(ListImages))
%         RelativeHeightTrace=SpikeOption.RelativeHeightTrace;
%     else
%         RelativeHeightTrace=0;
%     end
    
    
    MovieHeight=1; %RelativeHeightTrace/(length(ListTraces)+RelativeHeightTrace);
    MovieWidth=1;  %1/(length(ListMovies)+length(ListImages));
  %  TraceHeight=1/(length(ListTraces)+RelativeHeightTrace);
    
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
                TestMovieTitle=strcat(num2str(handles.currentTime),'s');
        end
        
        if (SpikeOption.DisplayMovie3D==1)
            if (length(handles.ImageHandle)<CurrentMovieNumber) || any(~ishandle(handles.ImageHandle) || any(isempty(handles.ImageHandle) ))
                % We create the full display for the current selected movie
                % along with its associated labels
                LocalAxe=axes('Parent',handles.hDataDisplay,...
                    'OuterPosition',[(CurrentMovieNumber-1)*MovieWidth 0 MovieWidth MovieHeight]);
                handles.SubAxes(CurrentMovieNumber)=LocalAxe;
                handles.ImageHandle(CurrentMovieNumber)=surf(LocalAxe,SpikeMovieData(iMovie).Xposition(:,:),SpikeMovieData(iMovie).Yposition(:,:),...
                    double(SpikeMovieData(iMovie).Movie(:,:,SpikeGui.CurrentNumberInMovie(iMovie))));
                xlabel(LocalAxe,SpikeMovieData(iMovie).Label.XLabel);
                ylabel(LocalAxe,SpikeMovieData(iMovie).Label.YLabel);
                
                if SpikeOption.DisplayMovieTitle<4
                    handles.TitleHandle(CurrentMovieNumber)=title(LocalAxe,TestMovieTitle);
                end
                set(LocalAxe,'CLimMode','manual');
                set(LocalAxe,'ZLimMode','manual');
            else
                % We only update the data as the display is already created to
                % ensure maximal speed
                set(handles.ImageHandle(CurrentMovieNumber),'ZData',double(SpikeMovieData(iMovie).Movie(:,:,SpikeGui.CurrentNumberInMovie(iMovie))));
                if (SpikeOption.DisplayMovieTitle==2 || SpikeOption.DisplayMovieTitle==3)
                    set(handles.TitleHandle(CurrentMovieNumber),'String',TestMovieTitle);
                end
            end
        else
            if (length(handles.ImageHandle)<CurrentMovieNumber) || any(isempty(handles.ImageHandle)) || any(~ishandle(handles.ImageHandle))
                % We create the full display for the current selected movie
                % along with its associated labels
                LocalAxe=axes('Parent',handles.hDataDisplay,...
                    'OuterPosition',[(CurrentMovieNumber-1)*MovieWidth 0 MovieWidth MovieHeight]);
                handles.SubAxes(CurrentMovieNumber)=LocalAxe;
                
                XPosVector=mean(SpikeMovieData(iMovie).Xposition(:,:),1);
                YPosVector=mean(SpikeMovieData(iMovie).Yposition(:,:),2);
                
                handles.ImageHandle(CurrentMovieNumber)=imagesc(XPosVector,YPosVector,...
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
                    handles.TitleHandle(CurrentMovieNumber)=title(LocalAxe,TestMovieTitle);
                end
                
                set(LocalAxe,'CLimMode','manual');
            else
                % We only update the data as the display is already created to
                % ensure maximal speed
                set(handles.ImageHandle(CurrentMovieNumber),'CData',SpikeMovieData(iMovie).Movie(:,:,SpikeGui.CurrentNumberInMovie(iMovie)));
                if (SpikeOption.DisplayMovieTitle==2 || SpikeOption.DisplayMovieTitle==3)
                    set(handles.TitleHandle(CurrentMovieNumber),'String',TestMovieTitle);
                end
            end
        end
    end
    
    % If no movies we adjust the value of currentMovieNumber to 0
    if isempty(CurrentMovieNumber)
        CurrentMovieNumber=0;
    end
    
%     % We update the display of images
%     for CurrentImageNumber=1:length(ListImages)
%         iImage=ListImages(CurrentImageNumber);
%         
%         switch SpikeOption.DisplayImageTitle
%             case 1
%                 % Display image name
%                 TestImageTitle=SpikeImageData(iImage).Label.ListText;
%         end
%         
%         if (length(SpikeGui.ImageHandle)<CurrentImageNumber+CurrentMovieNumber) || any(isempty(SpikeGui.ImageHandle) || any(~ishandle(SpikeGui.ImageHandle)))
%             % We create the full display for the current selected movie
%             % along with its associated labels
%             LocalAxe=axes('Parent',SpikeGui.hDataDisplay,...
%                 'OuterPosition',[(CurrentMovieNumber+CurrentImageNumber-1)*MovieWidth length(ListTraces)*TraceHeight MovieWidth MovieHeight]);
%             SpikeGui.SubAxes(CurrentMovieNumber+CurrentImageNumber)=LocalAxe;
%             
%             XPosVector=mean(SpikeImageData(iImage).Xposition(:,:),1);
%             YPosVector=mean(SpikeImageData(iImage).Yposition(:,:),2);
%             SpikeGui.ImageHandle(CurrentMovieNumber+CurrentImageNumber)=imagesc(XPosVector,YPosVector,...
%                 SpikeImageData(iImage).Image);
%             
%             switch SpikeOption.DisplayImageXYRatio
%                 case 1
%                     axis(LocalAxe,'normal');
%                 case 2
%                     axis(LocalAxe,'image');
%             end
%             
%             if SpikeOption.DisplayImageAxis==2
%                 axis(LocalAxe,'off');
%             else
%                 xlabel(LocalAxe,SpikeImageData(iImage).Label.XLabel);
%                 ylabel(LocalAxe,SpikeImageData(iImage).Label.YLabel);
%             end
%             
%             if SpikeOption.DisplayImageTitle<2
%                 SpikeGui.TitleHandle(CurrentMovieNumber+CurrentImageNumber)=title(LocalAxe,TestImageTitle);
%             end
%             
%             set(LocalAxe,'CLimMode','manual');
%         else
%             % We only update the data as the display is already created to
%             % ensure maximal speed
%             set(SpikeGui.ImageHandle(CurrentMovieNumber+CurrentImageNumber),'CData',SpikeImageData(iImage).Image);
%         end
%     end
%     
%     % If no movies we adjust the value of currentMovieNumber to 0
%     if isempty(CurrentImageNumber)
%         CurrentImageNumber=0;
%     end
%     
%     % We update the display of traces
%     for CurrentTraceNumber=1:length(ListTraces)
%         iTrace=ListTraces(CurrentTraceNumber);
%         
%         switch SpikeOption.DisplayTraceTitle
%             case 1
%                 % Display trace name
%                 TestTraceTitle=SpikeTraceData(iTrace).Label.ListText;
%             case 2
%                 % Display Time
%                 TestTraceTitle=strcat(num2str(handles.currentTime),'s');
%         end
%         
%         if (length(SpikeGui.TraceHandle)<CurrentTraceNumber) || any(isempty(SpikeGui.TraceHandle) || any(~ishandle(SpikeGui.TraceHandle)))
%             % We create the axes and plot the corresponding curve and its
%             % labels
%             LocalAxe=axes('Parent',SpikeGui.hDataDisplay,'OuterPosition',[0 (length(ListTraces)-CurrentTraceNumber)*TraceHeight 1 TraceHeight]);
%             SpikeGui.SubAxes(CurrentImageNumber+CurrentMovieNumber+CurrentTraceNumber)=LocalAxe;
%             SpikeGui.TraceHandle(CurrentTraceNumber)=plot(LocalAxe,SpikeTraceData(iTrace).XVector,SpikeTraceData(iTrace).Trace);
%             
%             if SpikeOption.DisplayTraceAxis==2
%                 axis(LocalAxe,'off');
%             else
%                 xlabel(LocalAxe,'Time (s)');
%                 ylabel(LocalAxe,SpikeTraceData(iTrace).Label.YLabel);
%             end
%             
%             if SpikeOption.DisplayTraceTitle<3
%                 SpikeGui.TitleHandle(CurrentMovieNumber+CurrentImageNumber+CurrentTraceNumber)=title(LocalAxe,TestTraceTitle);
%             end
%             
%             if (SpikeOption.DisplayTraceTimeBar==1)
%                 v=axis(LocalAxe);
%                 SpikeGui.LineHandle(CurrentTraceNumber)=line('XData',[handles.currentTime handles.currentTime],'YData',[v(3) v(4)],'Color','r','LineWidth',1);
%             end
%             
%             if (CurrentTraceNumber==length(ListTraces))
%                 switch SpikeOption.LinkAxis
%                     case 2
%                         linkaxes(SpikeGui.SubAxes(CurrentImageNumber+CurrentMovieNumber+1:CurrentImageNumber+CurrentMovieNumber+CurrentTraceNumber),'x');
%                     case 3
%                         linkaxes(SpikeGui.SubAxes(CurrentImageNumber+CurrentMovieNumber+1:CurrentImageNumber+CurrentMovieNumber+CurrentTraceNumber),'y');
%                     case 4
%                         linkaxes(SpikeGui.SubAxes(CurrentImageNumber+CurrentMovieNumber+1:CurrentImageNumber+CurrentMovieNumber+CurrentTraceNumber),'xy');
%                 end                
%             end
%         else
%             if (SpikeOption.DisplayTraceTimeBar==1)
%                 % We only update the display for the current time point
%                 v=axis(SpikeGui.SubAxes(CurrentImageNumber+CurrentMovieNumber+CurrentTraceNumber));
%                 set(SpikeGui.LineHandle(CurrentTraceNumber),'XData',[handles.currentTime handles.currentTime],'YData',[v(3) v(4)]);
%             end
%             if SpikeOption.DisplayTraceTitle==2
%                 set(SpikeGui.TitleHandle(CurrentImageNumber+CurrentMovieNumber+CurrentTraceNumber),'String',TestTraceTitle);
%             end
%         end
%     end
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

handles.currentTime=NewPos*(handles.MaxTime-handles.MinTime)+handles.MinTime;
set(handles.currentTime,'String',num2str(handles.currentTime));

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
    if strcmp(get(handles.TimerData,'Running'),'on')
        stop(handles.TimerData);
    end
    set(handles.PlayMovie,'String','Play');
    
    HallObj=findobj('Enable','off');
    set(HallObj,'Enable','on');
else
    % This is fixed as going faster won't be noticable
    NumberFrameDisplayPerSecond=25;
    
    if isempty(handles.TimerData)
        % Before we create a new one, we remove any remainings of timers
        % from memory
        out = timerfind;
        delete(out);
        
        handles.TimerData=timer('TimerFcn', {@FrameRateDisplay,NumberFrameDisplayPerSecond,handles},...
            'Period',1/NumberFrameDisplayPerSecond,'ExecutionMode','fixedRate','BusyMode','drop');
    else
        if strcmp(get(handles.TimerData,'Running'),'off')
            delete(handles.TimerData);
            
            handles.TimerData=timer('TimerFcn', {@FrameRateDisplay,NumberFrameDisplayPerSecond,handles},...
                'Period',1/NumberFrameDisplayPerSecond,'ExecutionMode','fixedRate','BusyMode','drop');
        end
    end
    
    HallObj=findobj('Enable','on');
    MoviePlayBacksObj=findobj(handles.TimePanel,'Enable','on');
    HallObj=setdiff(HallObj,MoviePlayBacksObj);
    set(HallObj,'Enable','off');
    set(handles.PlayMovie,'String','Stop');

    start(handles.TimerData);
end


% This function is called by the timer to display one frame of the movie
% at the right frame rate
function FrameRateDisplay(obj, event,NumberFrameDisplayPerSecond,handles)
global SpikeGui;

TimeSpeed=str2double(get(handles.FactorRealTime,'String'));
TimeStep=TimeSpeed/NumberFrameDisplayPerSecond;

if (handles.currentTime+TimeStep)<handles.MaxTime
    handles.currentTime=handles.currentTime+TimeStep;
else
    handles.currentTime=handles.MinTime;
end

set(handles.currentTime,'String',sprintf('%0.4f',handles.currentTime));
set(handles.PositionSlider,'Value',(handles.currentTime-handles.MinTime)/(handles.MaxTime-handles.MinTime));
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

function UpdateTimeLimit(handles)
global SpikeMovieData;
global SpikeGui;

% We put back MaxTime and MinTime to empty to rescale the limits
handles.MaxTime=[];
handles.MinTime=[];

% We check SpikeMovieData for new selection
SelectedMovies=get(handles.ListSelectMovies,'Value');
for i=SelectedMovies
    if isempty(handles.MaxTime)
        handles.MaxTime=max(SpikeMovieData(i).TimeFrame);
    else
        handles.MaxTime=max(handles.MaxTime,max(SpikeMovieData(i).TimeFrame));
    end
    
    if isempty(handles.MinTime)
        handles.MinTime=min(SpikeMovieData(i).TimeFrame);
    else
        handles.MinTime=min(handles.MinTime,min(SpikeMovieData(i).TimeFrame));
    end
end

      
% And then we populate the interface with Movie playback options and
% update the display
if ~isempty(handles.MaxTime)
    
    if isempty(handles.currentTime)
        handles.currentTime=handles.MinTime;
    else
        handles.currentTime=max(min(handles.MaxTime,handles.currentTime),handles.MinTime);
    end
    
    set(handles.PositionSlider,'Value',(handles.currentTime-handles.MinTime)/(handles.MaxTime-handles.MinTime));
    set(handles.currentTime,'String',num2str(handles.currentTime));
    set(handles.TimeText,'String',['/' num2str(handles.MaxTime) ' s']);
    
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
% global SpikeImageData;
% global SpikeTraceData;
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

% % We check SpikeImageData for new data
% if isfield(SpikeImageData,'Image')
%     if (~isempty(SpikeImageData))
%         set(handles.ListSelectImages,'Enable','on');
%         
%         for i=1:length(SpikeImageData)
%             TextToImage{i}=[num2str(i),' - ',SpikeImageData(i).Label.ListText];
%         end
%         
%         set(handles.ListSelectImages,'String',TextToImage);
%         
%         PreviousListboxTop=get(handles.ListSelectImages,'ListboxTop');
%         PreviousSelImages=get(handles.ListSelectImages,'Value');
%         NewValues=intersect(PreviousSelImages,1:length(SpikeImageData));
%         NewListboxTop=min(max(NewValues),min(length(SpikeImageData),PreviousListboxTop));
%         if isempty(NewListboxTop)
%             NewListboxTop=1;
%         end
%         set(handles.ListSelectImages,'ListboxTop',NewListboxTop);
%         set(handles.ListSelectImages,'Value',NewValues);
%     else
%         set(handles.ListSelectImages,'String','');
%         set(handles.ListSelectImages,'Value',[]);
%         set(handles.ListSelectImages,'Enable','off');
%     end
% else
%     set(handles.ListSelectImages,'String','');
%     set(handles.ListSelectImages,'Value',[]);
%     set(handles.ListSelectImages,'Enable','off');
% end
% 
% % We check SpikeTraceData for new data
% if isfield(SpikeTraceData,'Trace') && (~isempty(SpikeTraceData))
%     set(handles.ListSelectTraces,'Enable','on');
%     
%     for i=1:length(SpikeTraceData)
%         TextToTraces{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
%     end
%     
%     set(handles.ListSelectTraces,'String',TextToTraces);
%     
%     PreviousListboxTop=get(handles.ListSelectTraces,'ListboxTop');
%     PreviousSelTraces=get(handles.ListSelectTraces,'Value');
%     NewValues=intersect(PreviousSelTraces,1:length(SpikeTraceData));
%     NewListboxTop=min(max(NewValues),min(length(SpikeTraceData),PreviousListboxTop));
%     if isempty(NewListboxTop)
%         NewListboxTop=1;
%     end
%     set(handles.ListSelectTraces,'ListboxTop',NewListboxTop);
%     set(handles.ListSelectTraces,'Value',NewValues);
% else
%     set(handles.ListSelectTraces,'String','');
%     set(handles.ListSelectTraces,'Value',[]);
%     set(handles.ListSelectTraces,'Enable','off');
% end

% We also update the Batch list
%UpdateBatch(handles);

% We also update the time limits of the display
UpdateTimeLimit(handles);

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
UpdateTimeLimit(handles);

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
MajorValue=(handles.MaxTime-handles.MinTime)*NewSpeed/1000;
MinorValue=MajorValue/10;

FinalMat=[MinorValue MajorValue]/(handles.MaxTime-handles.MinTime);
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

MajorValue=(handles.MaxTime-handles.MinTime)*SpeedValue/1000;
MinorValue=MajorValue/10;

FinalMat=[MinorValue MajorValue]/(handles.MaxTime-handles.MinTime);
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
NewPos=max(min(NewPos,handles.MaxTime),handles.MinTime);
set(handles.currentTime,'String',num2str(NewPos));
set(handles.PositionSlider,'Value',(NewPos-handles.MinTime)/(handles.MaxTime-handles.MinTime));

handles.currentTime=NewPos;

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
            [Value,Indice]=min(abs(SpikeMovieData(i).TimeFrame-handles.currentTime));
            SpikeGui.CurrentNumberInMovie(i)=Indice(1)
        end
    end
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
