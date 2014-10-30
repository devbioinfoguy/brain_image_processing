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

% Last Modified by GUIDE v2.5 22-May-2012 15:35:26

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
handles.hDataDisplay=[];
handles.ImageHandle=[];
handles.MinTime=[];
handles.MaxTime=[];

handles.TimerData=[];
handles.CurrentNumberInMovie=[];


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
%global SpikeGui;
global SpikeOption;

guidata(handles.output, handles);
ListMovies=get(handles.ListSelectMovies,'Value');
% ListImages=get(handles.ListSelectImages,'Value');
% ListTraces=get(handles.ListSelectTraces,'Value');

% If anything is selected
 if (isempty(ListMovies))%&& isempty(ListImages) && isempty(ListTraces))
    if (~isempty(handles.hDataDisplay) && ishandle(handles.hDataDisplay))
            close(handles.hDataDisplay);
    end
 else
    % We create the figure if it does not exist
    if (~isempty(handles.hDataDisplay))
        if (~ishandle(handles.hDataDisplay))
            handles.hDataDisplay=figure('Name','Data display','NumberTitle','off');
            scrsz = get(0,'ScreenSize');
            set(handles.hDataDisplay,'Position',[1 1 min(scrsz(3:4)) min(scrsz(3:4))]);
            %SpikeGui.ImageHandle=[];
            %SpikeGui.TraceHandle=[];
            handles.SubAxes=[];
            handles.TitleHandle=[];
            guidata(handles.output, handles);
        else
            set(0,'CurrentFigure',handles.hDataDisplay);
            scrsz = get(0,'ScreenSize');
            set(handles.hDataDisplay,'Position',[1 1 min(scrsz(3:4)) min(scrsz(3:4))]);
        end
    else
        handles.hDataDisplay=figure('Name','Data display','NumberTitle','off');
        scrsz = get(0,'ScreenSize');
        set(handles.hDataDisplay,'Position',[1 1 min(scrsz(3:4)) min(scrsz(3:4))]);
        %SpikeGui.ImageHandle=[];
        %SpikeGui.TraceHandle=[];
        handles.SubAxes=[];
        handles.TitleHandle=[];
        guidata(handles.output, handles);
    end
    set(handles.hDataDisplay,'MenuBar','none');
    
%     if (~isempty(ListMovies) || ~isempty(ListImages))
%         RelativeHeightTrace=SpikeOption.RelativeHeightTrace;
%     else
%         RelativeHeightTrace=0;
%     end
    
    Nmov=length(ListMovies);
    Nx=get(handles.Nx,'Value');
    Ny=get(handles.Ny,'Value');
    MovieHeight=1/Nx; %RelativeHeightTrace/(length(ListTraces)+RelativeHeightTrace);
    MovieWidth=1/Ny;  %1/(length(ListMovies)+length(ListImages));
    Overlap=get(handles.Overlap,'Value');
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
                TestMovieTitle=[sprintf('%u',handles.CurrentNumberInMovie(iMovie)),'/',sprintf('%u',SpikeMovieData(iMovie).DataSize(3))];
            case 3
                % Display Time
                TestMovieTitle=strcat(num2str(get(handles.currentTime,'Value')),'s');
        end
        
              if (length(handles.ImageHandle)<CurrentMovieNumber) || any(isempty(handles.ImageHandle)) || any(~ishandle(handles.ImageHandle))
                % We create the full display for the current selected movie
                % along with its associated labels
                 %LocalAxe=axes('Parent',handles.hDataDisplay,...
                 %'Position',[(CurrentMovieNumber-1)*MovieWidth 0 MovieWidth MovieHeight]);
                 
                 
                 ScanType=get(handles.ScanType,'Value');
                 
                 
                 
                 % %For snake scan
                 if(ScanType==2)
                     if (mod(ceil(CurrentMovieNumber/Nx),2)==1) % Odd columns
                         ColumnX=ceil(CurrentMovieNumber/Nx); % Column number, counting from right
                         RowY=rem(CurrentMovieNumber-1,Ny)+1 ;  % Column number, counting from top
                     elseif(mod(ceil(CurrentMovieNumber/Nx),2)~=1) % Even columns
                         ColumnX=ceil(CurrentMovieNumber/Nx); % Column number, counting from right
                         RowY=Ny-rem(CurrentMovieNumber-1,Ny) ;  % Column number, counting from top
                     end
                 end
                 if(ScanType==1)
                     %%%%%%%%%%%%%%%%%%%%%%%%%
                     
                     
                     %For column by column scan
                     
                     ColumnX=ceil(CurrentMovieNumber/Nx); % Column number, counting from right
                     RowY=rem(CurrentMovieNumber-1,Ny)+1 ;  % Column number, counting from top
                 end
                 %%%%%%%%%%%%%%%%%%%%%%%
                 
                
                Xpos_rel=1-ColumnX*MovieWidth+(ColumnX-1)*MovieWidth*Overlap;
                Ypos_rel=1-RowY*MovieHeight+(RowY-1)*MovieHeight*Overlap;
                
                

                LocalAxe=axes('Parent',handles.hDataDisplay,...
                     'Position',[Xpos_rel Ypos_rel MovieWidth MovieHeight]);
                handles.SubAxes(CurrentMovieNumber)=LocalAxe;
                
                XPosVector=mean(SpikeMovieData(iMovie).Xposition(:,:),1);
                YPosVector=mean(SpikeMovieData(iMovie).Yposition(:,:),2);
                
                handles.ImageHandle(CurrentMovieNumber)=imagesc(XPosVector,YPosVector,...
                    SpikeMovieData(iMovie).Movie(:,:,handles.CurrentNumberInMovie(iMovie)),[0 5000]);
                
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
                set(handles.ImageHandle(CurrentMovieNumber),'CData',SpikeMovieData(iMovie).Movie(:,:,handles.CurrentNumberInMovie(iMovie)));
                if (SpikeOption.DisplayMovieTitle==2 || SpikeOption.DisplayMovieTitle==3)
                    set(handles.TitleHandle(CurrentMovieNumber),'String',TestMovieTitle);
                end
            end
       
    end
    
    % If no movies we adjust the value of currentMovieNumber to 0
    if isempty(CurrentMovieNumber)
        CurrentMovieNumber=0;
    end
  
% Update handles structure
guidata(handles.output, handles);
end


% --- Executes on slider movement.
function PositionSlider_Callback(hObject, eventdata, handles)
% hObject    handle to PositionSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%global SpikeGui;

NewPos=get(handles.PositionSlider,'Value');

set(handles.currentTime,'Value',NewPos*(handles.MaxTime-handles.MinTime)+handles.MinTime);
set(handles.currentTime,'String',num2str(get(handles.currentTime,'Value')));
guidata(handles.output, handles);
UpdateFrameNumber(handles);
handles=guidata(handles.output);
DisplayData(handles);
% Update handles structure
handles=guidata(handles.output);
guidata(handles.output, handles);


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
%global SpikeGui;

if (get(handles.PlayMovie,'Value')==0)
    handles=guidata(handles.output);

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
    % Update handles structure
    guidata(handles.output, handles);
    HallObj=findobj('Enable','on');
    MoviePlayBacksObj=findobj(handles.TimePanel,'Enable','on');
    HallObj=setdiff(HallObj,MoviePlayBacksObj);
    set(HallObj,'Enable','off');
    set(handles.PlayMovie,'String','Stop');
    guidata(handles.output, handles);
    handles=guidata(handles.output);
    start(handles.TimerData);
    % Update handles structure
   % guidata(handles.output, handles);
    %set(handles.TimerData,'Running','on');
    guidata(handles.output, handles);
end



% This function is called by the timer to display one frame of the movie
% at the right frame rate
function FrameRateDisplay(obj, event,NumberFrameDisplayPerSecond,handles)
handles=guidata(handles.output);

TimeSpeed=str2double(get(handles.FactorRealTime,'String'));
TimeStep=TimeSpeed/NumberFrameDisplayPerSecond;

if (get(handles.currentTime,'Value')+TimeStep)<handles.MaxTime
    set(handles.currentTime,'Value',get(handles.currentTime,'Value')+TimeStep);
else
    set(handles.currentTime,'Value',handles.MinTime);
end

set(handles.currentTime,'String',sprintf('%0.4f',get(handles.currentTime,'Value')));
set(handles.PositionSlider,'Value',(get(handles.currentTime,'Value')-handles.MinTime)/(handles.MaxTime-handles.MinTime));
% Update handles structure
UpdateFrameNumber(handles);

handles=guidata(handles.output);

DisplayData(handles);
% Update handles structure
handles=guidata(handles.output);
guidata(handles.output, handles);

    

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



function UpdateTimeLimit(handles)
global SpikeMovieData;
%global SpikeGui;

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

 % Update handles structure
    guidata(handles.output, handles);
      
% And then we populate the interface with Movie playback options and
% update the display
if ~isempty(handles.MaxTime)
    
    if isempty(get(handles.currentTime,'Value'))
        set(handles.currentTime,'Value',handles.MinTime);
    else
        set(handles.currentTime,'Value',max(min(handles.MaxTime,get(handles.currentTime,'Value')),handles.MinTime));
    end
    
    set(handles.PositionSlider,'Value',(get(handles.currentTime,'Value')-handles.MinTime)/(handles.MaxTime-handles.MinTime));
    set(handles.currentTime,'String',num2str(get(handles.currentTime,'Value')));
    set(handles.TimeText,'String',['/' num2str(handles.MaxTime) ' s']);
    % Update handles structure
    guidata(handles.output, handles);
    
    MoviePlayBacksObj=findobj(handles.TimePanel,'Enable','off');
    set(MoviePlayBacksObj,'Enable','on');
    
    % Update handles structure
    guidata(handles.output, handles);
    % We update current frame number
    UpdateFrameNumber(handles);
    handles=guidata(handles.output);
else
    set(handles.PositionSlider,'Value',0);
    set(handles.currentTime,'String','0');
    set(handles.TimeText,'String',['/... s']);
    % Update handles structure
    guidata(handles.output, handles);
    MoviePlayBacksObj=findobj(handles.TimePanel,'Enable','on');
    set(MoviePlayBacksObj,'Enable','off');
end
guidata(handles.output, handles);


% This function is to update the interface in case anything change in the
% data that need some adjustements. 
function UpdateInterface(handles)
global SpikeMovieData;
% global SpikeImageData;
% global SpikeTraceData;
%global SpikeGui;

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
    guidata(handles.output, handles);
    
    PreviousListboxTop=get(handles.ListSelectMovies,'ListboxTop');
    PreviousSelMovies=get(handles.ListSelectMovies,'Value');
    NewValues=intersect(PreviousSelMovies,1:length(SpikeMovieData));
    NewListboxTop=min(max(NewValues),min(length(SpikeMovieData),PreviousListboxTop));
    if isempty(NewListboxTop)
        NewListboxTop=1;
    end
    set(handles.ListSelectMovies,'ListboxTop',NewListboxTop);
    set(handles.ListSelectMovies,'Value',NewValues);
    guidata(handles.output, handles);
else
    set(handles.ListSelectMovies,'String','');
    set(handles.ListSelectMovies,'Value',[]);
    set(handles.ListSelectMovies,'Enable','off');
    guidata(handles.output, handles);
end
% Update handles structure
    guidata(handles.output, handles);
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
handles=guidata(handles.output);
% Create display figure and add image data to it
DisplayData(handles);
handles=guidata(handles.output);
guidata(handles.output, handles);


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
handles=guidata(handles.output);
% We also update the time limits of the display
UpdateTimeLimit(handles);
handles=guidata(handles.output);
DisplayData(handles);
handles=guidata(handles.output);
guidata(handles.output, handles);


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
% global SpikeGui;
guidata(handles.output, handles);
SpeedValue=get(handles.SpeedSlider,'Value');
MinFactor=0.01;
NewSpeed=10^(SpeedValue*5)*MinFactor;
MajorValue=(handles.MaxTime-handles.MinTime)*NewSpeed/1000;
MinorValue=MajorValue/10;

FinalMat=[MinorValue MajorValue]/(handles.MaxTime-handles.MinTime);
set(handles.PositionSlider,'SliderStep',FinalMat);
set(handles.FactorRealTime,'String',num2str(NewSpeed));
% Update handles structure
    guidata(handles.output, handles);


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
%global SpikeGui;
guidata(handles.output, handles);
if (~isempty(handles.hDataDisplay))
    if (ishandle(handles.hDataDisplay))
        clf(handles.hDataDisplay);
    end
end
guidata(handles.output, handles);
handles.ImageHandle=[];
handles.TraceHandle=[];
handles.SubAxes=[];
handles.TitleHandle=[];
guidata(handles.output,handles);


function FactorRealTime_Callback(hObject, eventdata, handles)
% hObject    handle to FactorRealTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FactorRealTime as text
%        str2double(get(hObject,'String')) returns contents of FactorRealTime as a double
%global SpikeGui;
guidata(handles.output, handles);
MinFactor=0.01;
MaxFactor=1000;

SpeedValue=str2double(get(handles.FactorRealTime,'String'));
if ((SpeedValue>MaxFactor) || (SpeedValue<MinFactor))
    SpeedValue=max(MinFactor,min(MaxFactor,SpeedValue));
    set(handles.FactorRealTime,'String',num2str(SpeedValue));
    guidata(handles.output, handles);
end

SliderPos=log10(SpeedValue/MinFactor)/5;
set(handles.SpeedSlider,'Value',SliderPos);

MajorValue=(handles.MaxTime-handles.MinTime)*SpeedValue/1000;
MinorValue=MajorValue/10;

FinalMat=[MinorValue MajorValue]/(handles.MaxTime-handles.MinTime);
set(handles.PositionSlider,'SliderStep',FinalMat);
% Update handles structure
    guidata(handles.output, handles);


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
%global SpikeGui;
guidata(handles.output, handles);
NewPos=str2double(get(handles.currentTime,'String'));
NewPos=max(min(NewPos,handles.MaxTime),handles.MinTime);
set(handles.currentTime,'String',num2str(NewPos));
set(handles.PositionSlider,'Value',(NewPos-handles.MinTime)/(handles.MaxTime-handles.MinTime));

set(handles.currentTime,'Value',NewPos);
% Update handles structure
guidata(handles.output, handles);
UpdateFrameNumber(handles);
handles=guidata(handles.output);
DisplayData(handles);
handles=guidata(handles.output);
guidata(handles.output, handles);


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
% global SpikeGui;
global SpikeMovieData;

if ~isempty(SpikeMovieData)
    if isfield(SpikeMovieData,'TimeFrame')
        for i=1:length(SpikeMovieData)
            [Value,Indice]=min(abs(SpikeMovieData(i).TimeFrame-get(handles.currentTime,'Value')));
            handles.CurrentNumberInMovie(i)=Indice(1);
        end
    end
end
% Update handles structure
guidata(handles.output, handles);




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
    guidata(handles.output, handles);
    UpdateInterface(handles);
    handles=guidata(handles.output);
end



function Nx_Callback(hObject, eventdata, handles)
% hObject    handle to Nx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Nx as text
%        str2double(get(hObject,'String')) returns contents of Nx as a double
set(handles.Nx,'Value',str2double(get(handles.Nx,'String')));
guidata(handles.output, handles);

% --- Executes during object creation, after setting all properties.
function Nx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Nx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ny_Callback(hObject, eventdata, handles)
% hObject    handle to Ny (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ny as text
%        str2double(get(hObject,'String')) returns contents of Ny as a double
set(handles.Ny,'Value',str2double(get(handles.Ny,'String')));
guidata(handles.output, handles);

% --- Executes during object creation, after setting all properties.
function Ny_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ny (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Overlap_Callback(hObject, eventdata, handles)
% hObject    handle to Overlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Overlap as text
%        str2double(get(hObject,'String')) returns contents of Overlap as a double
set(handles.Overlap,'Value',str2double(get(handles.Overlap,'String')));
guidata(handles.output, handles);

% --- Executes during object creation, after setting all properties.
function Overlap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Overlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ScanType.
function ScanType_Callback(hObject, eventdata, handles)
% hObject    handle to ScanType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ScanType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ScanType


% --- Executes during object creation, after setting all properties.
function ScanType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScanType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
