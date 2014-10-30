function varargout = Load_Movie_Folder_Sequence_Prarie(varargin)
% LOAD_MOVIE_FOLDER_SEQUENCE_PRARIE MATLAB code for Load_Movie_Folder_Sequence_Prarie.fig
%      LOAD_MOVIE_FOLDER_SEQUENCE_PRARIE, by itself, creates a new LOAD_MOVIE_FOLDER_SEQUENCE_PRARIE or raises the existing
%      singleton*.
%
%      H = LOAD_MOVIE_FOLDER_SEQUENCE_PRARIE returns the handle to a new LOAD_MOVIE_FOLDER_SEQUENCE_PRARIE or the handle to
%      the existing singleton*.
%
%      LOAD_MOVIE_FOLDER_SEQUENCE_PRARIE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOAD_MOVIE_FOLDER_SEQUENCE_PRARIE.M with the given input arguments.
%
%      LOAD_MOVIE_FOLDER_SEQUENCE_PRARIE('Property','Value',...) creates a new LOAD_MOVIE_FOLDER_SEQUENCE_PRARIE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Load_Movie_Folder_Sequence_Prarie_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Load_Movie_Folder_Sequence_Prarie_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Load_Movie_Folder_Sequence_Prarie

% Last Modified by GUIDE v2.5 19-Oct-2012 09:58:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Load_Movie_Folder_Sequence_Prarie_OpeningFcn, ...
                   'gui_OutputFcn',  @Load_Movie_Folder_Sequence_Prarie_OutputFcn, ...
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


% --- Executes just before Load_Movie_Folder_Sequence_Prarie is made visible.
function Load_Movie_Folder_Sequence_Prarie_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Load_Movie_Folder_Sequence_Prarie (see VARARGIN)

% Choose default command line output for Load_Movie_Folder_Sequence_Prarie
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Load_Movie_Folder_Sequence_Prarie wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.FolderNameList,'String',Settings.FilenameListString);
    set(handles.NbFrame,'String',Settings.NbFrameString);
    set(handles.StartFrame,'String',Settings.StartFrameString);
    set(handles.EndFrame,'String',Settings.EndFrameString);
    set(handles.XSinglePixelSize,'String',Settings.XSinglePixelSizeString);
    set(handles.YSinglePixelSize,'String',Settings.YSinglePixelSizeString);
    set(handles.FrameRate,'String',Settings.FrameRateString);
    set(handles.StepFrame,'String',Settings.StepFrameString);
    set(handles.LoadBehSelect,'Value',Settings.LoadBehSelectValue);
    set(handles.ExposureTime,'String',Settings.ExposureTimeString);
end
    

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.FilenameListString=get(handles.FolderNameList,'String');
Settings.NbFrameString=get(handles.NbFrame,'String');
Settings.StartFrameString=get(handles.StartFrame,'String');
Settings.EndFrameString=get(handles.EndFrame,'String');
Settings.XSinglePixelSizeString=get(handles.XSinglePixelSize,'String');
Settings.YSinglePixelSizeString=get(handles.YSinglePixelSize,'String');
Settings.FrameRateString=get(handles.FrameRate,'String');
Settings.LoadBehSelectValue=get(handles.LoadBehSelect,'Value');
Settings.StepFrameString=get(handles.StepFrame,'String');
Settings.ExposureTimeString=get(handles.ExposureTime,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Load_Movie_Folder_Sequence_Prarie_OutputFcn(hObject, eventdata, handles) 
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
    
    % How do we load folders: 1)  indepndently (take care of stage coordinates)
    % 2) Get coords in StageX, StageY, StageZ fields
    % 3) Load coords stored in *.xy file
    choice=get(handles.LoadStageCoordsOptions,'Value'); 
    
    ReturnDir=pwd;
    h=waitbar(0,'Reading files');
           
    FolderGroup=get(handles.FolderNameList,'String');
    
        
    if(choice==3)  % Loading coords from file
          FoldersXYZ=zeros(length(FolderGroup),3);
        
          [xml_data] = xml2struct(get(handles.BrowseFileSelected,'String'));
          for iFold=1:length(FolderGroup)
              
              FoldersXYZ(iFold,1)=str2double(xml_data.Children(2*iFold).Attributes(2).Value); % X
              FoldersXYZ(iFold,2)=str2double(xml_data.Children(2*iFold).Attributes(3).Value); % Y
              FoldersXYZ(iFold,3)=str2double(xml_data.Children(2*iFold).Attributes(4).Value); % Z
          end
          FoldersXYZ
    end

    for iMovie=1:1:length(FolderGroup)
        
        BeginMovie=length(SpikeMovieData)+1;
        cd(FolderGroup{iMovie});
        FilesTif=dir('*.tif');
        FileGroup=struct2cell(FilesTif);
        FileGroup=FileGroup(1,:)';
       
        
        switch choice
            case 1
                
                MoviesDataFile=dir('*.xml');
                MoviesDataFile=MoviesDataFile.name;
              
                
                % Trying to truncate the xml file for faster reading
                % Problem - need to ceate correct XML structure
                
%                 fidXML = fopen(MoviesDataFile, 'r');
%                 fidShortXML = fopen('ShortXMLdata.xml', 'w');
%                 for i=1:100
%                     a=fgets(fidXML);
%                     fprintf(fidShortXML,'%s',a);
%                 end
%                 fclose(fidXML);
%                 fclose(fidShortXML);
%                 
%                 MoviesDataFile=ShortXMLdata.xml;
                
                [xml_data] = xml2struct(MoviesDataFile);
                frame_index=1;
                framerate=1/str2double(xml_data.Children(4).Children(frame_index*2).Children(6).Children(18).Attributes(3).Value); % Frame Rate
                Exposure=str2double(xml_data.Children(4).Children(frame_index*2).Children(6).Children(22).Attributes(3).Value); % Dwell Time
                scanlinePeriod=str2double(xml_data.Children(4).Children(frame_index*2).Children(6).Children(20).Attributes(3).Value); % Scanline time (s)
                XPos=str2double(xml_data.Children(4).Children(frame_index*2).Children(6).Children(26).Attributes(3).Value); % X coord
                YPos=str2double(xml_data.Children(4).Children(frame_index*2).Children(6).Children(28).Attributes(3).Value); % Y coord
                ZPos=str2double(xml_data.Children(4).Children(frame_index*2).Children(6).Children(30).Attributes(3).Value); % Z coord
                RatioPixelSpaceX=str2double(xml_data.Children(4).Children(frame_index*2).Children(6).Children(38).Attributes(3).Value); % X pixel size
                RatioPixelSpaceY=str2double(xml_data.Children(4).Children(frame_index*2).Children(6).Children(40).Attributes(3).Value); % Z pixel size
                StartFrame=1;
                StepFrame=1;
                EndFrame=length(FileGroup); % Temporary solution need to handle Channels
                
               
            case 2
                
                framerate=str2double(get(handles.FrameRate,'String'));
                Exposure=str2double(get(handles.ExposureTime,'String'));
                scanlinePeriod=str2double(get(handles.scanlinePeriod,'String'));
                XPos=str2double(get(handles.StageX,'String'));
                YPos=str2double(get(handles.StageY,'String'));
                ZPos=str2double(get(handles.StageZ,'String'));
                StartFrame=str2double(get(handles.StartFrame,'String'));
                EndFrame=str2double(get(handles.EndFrame,'String'));
                StepFrame=str2double(get(handles.StepFrame,'String'));
                % We get the X and Y calibration values from the interface
                RatioPixelSpaceX=str2double(get(handles.XSinglePixelSize,'String'));
                RatioPixelSpaceY=str2double(get(handles.YSinglePixelSize,'String'));
                
            case 3
                
                framerate=str2double(get(handles.FrameRate,'String'));
                Exposure=str2double(get(handles.ExposureTime,'String'));
                scanlinePeriod=str2double(get(handles.scanlinePeriod,'String'));
                StartFrame=str2double(get(handles.StartFrame,'String'));
                EndFrame=str2double(get(handles.EndFrame,'String'));
                StepFrame=str2double(get(handles.StepFrame,'String'));
                % We get the X and Y calibration values from the interface
                RatioPixelSpaceX=str2double(get(handles.XSinglePixelSize,'String'));
                RatioPixelSpaceY=str2double(get(handles.YSinglePixelSize,'String'));
                
                XPos=FoldersXYZ(iMovie,1);
                YPos=FoldersXYZ(iMovie,2);
                ZPos=FoldersXYZ(iMovie,3);
                
        end
        
        
        
        [pathstr, name, ext] = fileparts(FileGroup{1});
        
        % We load first image to get image size and Class type
        LocalImage=imread(FileGroup{1});
        SizeImage=size(LocalImage);
        info=imfinfo(FileGroup{1});
        SpikeMovieData(BeginMovie).Path=pathstr;
        SpikeMovieData(BeginMovie).Filename=[name ext];

        FrameMat=StartFrame:StepFrame:EndFrame;
        
        Numberframe=length(FrameMat);
        

        
        % We prallocate the movie
        SpikeMovieData(BeginMovie).Movie=zeros(SizeImage(1),SizeImage(2),Numberframe,class(LocalImage));
        SpikeMovieData(BeginMovie).DataSize=size(SpikeMovieData(BeginMovie).Movie);
        
        % We create the various time matrix
        SpikeMovieData(BeginMovie).TimeFrame=zeros(1,Numberframe,'single');
        SpikeMovieData(BeginMovie).TimePixel=zeros(SpikeMovieData(BeginMovie).DataSize(1:3),'uint8');
        SpikeMovieData(BeginMovie).Exposure=Exposure*ones(SpikeMovieData(BeginMovie).DataSize(1:2),'single');
        SpikeMovieData(BeginMovie).TimePixelUnits=10^-6;
        
        % waitbar is consuming too much resources, so I divide its access
        dividerWaitbar=10^(floor(log10(Numberframe))-1);
        
        k=1;
        
        % We get matlab low-level image format capabilities.
        Format=imformats(info.Format);
        
        % Verify that a read function exists
        if (isempty(Format.read))
            error(message('MATLAB:imagesci:imread:readFunctionRegistration', fmt_s.ext{ 1 }));
        else
            for i=FrameMat
                % Instead of imread, we use a low-level reading line from Matlab to
                % get things faster
                SpikeMovieData(BeginMovie).Movie(:,:,k)=feval(Format.read, FileGroup{i});
                if (round(k/dividerWaitbar)==k/dividerWaitbar)
                    waitbar(k/Numberframe,h);
                end
                k=k+1;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Timing calculation
        
            % We extract all the scanning parameters to create a meaningfull set of
            % paramters to extract the timing of each pixel
            Bidirection=0;
           % fillFraction=header.acq.fillFraction;
            msPerLine=scanlinePeriod*1000;
            scanDelay=0;
            LineSpeed=msPerLine/1000;
           % Exposure=(LineSpeed*fillFraction)/SpikeMovieData(NbSaveMovie).DataSize(2);
            
            % In case we have bidireaction scanning, ScanDelay is different
           % if (Bidirection==1)
           %     scanDelay=(LineSpeed-LineSpeed*fillFraction)/2;
           % end
            
            % LineMatrix is from left to right scanning
            % Whereas AntiLine is right to left, this is used by bidirectionnal
            % scanning
            
            LineMatrix=scanDelay+Exposure/2+(0:(SpikeMovieData(BeginMovie).DataSize(2)-1))*Exposure;
            AntiLineMatrix=LineMatrix(length(LineMatrix):-1:1);
            
            waitbar(1/5,h);
            
            % We create the time matrix for all pixels
            TimeSingle=zeros(SpikeMovieData(BeginMovie).DataSize(1),SpikeMovieData(BeginMovie).DataSize(2),'single');
            for i=1:SpikeMovieData(BeginMovie).DataSize(1)
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
            AverageTimeFrame=framerate; %mean2(TimeSingle);
            
            waitbar(2/5,h);
            
            % We check whether last flyback line is kept or not.
            FlybackLastLine=1;
            DiscardLastFlyback=1;
            AddOneTimeLine=FlybackLastLine && DiscardLastFlyback;
            
            % This change the period for scanning
            PeriodForSinglePic=LineSpeed*(AddOneTimeLine+SpikeMovieData(BeginMovie).DataSize(1));
            
            FinalTimeMatrix=TimeSingle-AverageTimeFrame;
            MaxTime=max(FinalTimeMatrix(:));
            MinTime=min(FinalTimeMatrix(:));
            Range=max(abs([MaxTime MinTime]));
            
            waitbar(3/5,h);
            
            % This is a conservative choice. If memory is a problem, in many cases (Frame rate>8Hz), int8
            % is good enough to have ms precision
            ChosenTimeClass='int16';
            SpikeMovieData(BeginMovie).TimePixelUnits=10^floor(log10(Range)+1)/10000;
            
             
            SpikeMovieData(BeginMovie).TimeFrame=(AverageTimeFrame:PeriodForSinglePic:(AverageTimeFrame+(SpikeMovieData(BeginMovie).DataSize(3)-1)*PeriodForSinglePic));
            ToFillTimePixel=cast((TimeSingle-AverageTimeFrame)/SpikeMovieData(BeginMovie).TimePixelUnits,ChosenTimeClass);
            SpikeMovieData(BeginMovie).TimePixel=repmat(ToFillTimePixel,[1 1 SpikeMovieData(BeginMovie).DataSize(3)]);
            
           
            SpikeMovieData(BeginMovie).Path=cd;
              
        
        
        
        
        % end of Timing calculation
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
        % We create the position matrix that store X,Y,Z position of all pixels
        [SpikeMovieData(BeginMovie).Xposition,SpikeMovieData(BeginMovie).Yposition] ...
            = meshgrid(RatioPixelSpaceX*(1:SpikeMovieData(BeginMovie).DataSize(2))-XPos,RatioPixelSpaceY*(1:SpikeMovieData(BeginMovie).DataSize(1))+YPos);
        SpikeMovieData(BeginMovie).Zposition(:,:)=zeros(size(SpikeMovieData(BeginMovie).Xposition))+ZPos;
        
        SpikeMovieData(BeginMovie).Label.XLabel='\mum';
        SpikeMovieData(BeginMovie).Label.YLabel='\mum';
        SpikeMovieData(BeginMovie).Label.ZLabel='\mum';
        SpikeMovieData(BeginMovie).Label.CLabel=get(handles.PixelLabel,'String');
        SpikeMovieData(BeginMovie).Label.ListText=get(handles.MovieName,'String');
                
        
    end
        cd(ReturnDir);
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

% --- Executes on button press in SelectFolders.
function SelectFolders_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFolders (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open file path
%[InLoading,user_canceled]=imgetfile;
%Load multiple folders
user_cancelled=0;
InLoading=uipickfiles('Type', { '*.tif',   'Tif-files'});
CancelError=whos('InLoading');
if (length(InLoading)==0 || strcmp(CancelError.class,'double'))
   user_cancelled=1; 
end

% Open file if exist
% If "Cancel" is selected then return
if user_cancelled==1
    return
    
    % Otherwise construct the fullfilename and Check and load the file
else
    
    

    % To keep the path accessible to future request
          
    for i=1:1:length(InLoading)
       [pathstr, name, ext]=fileparts(InLoading{i});
    end
        
    cd([pathstr,'/',name]);
    
    set(handles.FolderNameList,'String',    InLoading);
    
    % Going to first folder
    [pathstr, name, ext]=fileparts(InLoading{1});
    cd([pathstr,'/',name]);
    
    
    % Automatic recognition of xml data file generated by Prairie
        
    MoviesDataFile=dir('*.xml');
    MoviesDataFile=MoviesDataFile.name;
    [xml_data] = xml2struct(MoviesDataFile);
    
    frame_index=1;
    
    FrameRate=1.0/str2double(xml_data.Children(4).Children(frame_index*2).Children(6).Children(18).Attributes(3).Value); % Frame Rate
    scanlinePeriod=str2double(xml_data.Children(4).Children(frame_index*2).Children(6).Children(20).Attributes(3).Value); % Scanline time (s)
    DwellTime=str2double(xml_data.Children(4).Children(frame_index*2).Children(6).Children(22).Attributes(3).Value); % Dwell Time (us)
    
    DwellTime=DwellTime*1e-6; % dwell time in microseconds
    
    XPos=str2double(xml_data.Children(4).Children(frame_index*2).Children(6).Children(26).Attributes(3).Value); % X coord
    YPos=str2double(xml_data.Children(4).Children(frame_index*2).Children(6).Children(28).Attributes(3).Value); % Y coord
    ZPos=str2double(xml_data.Children(4).Children(frame_index*2).Children(6).Children(30).Attributes(3).Value); % Z coord
    
    Zoom=str2double(xml_data.Children(4).Children(frame_index*2).Children(6).Children(36).Attributes(3).Value); % Zoom
    XPixSize=str2double(xml_data.Children(4).Children(frame_index*2).Children(6).Children(38).Attributes(3).Value); % X pixel size (non zoomed)
    YPixSize=str2double(xml_data.Children(4).Children(frame_index*2).Children(6).Children(40).Attributes(3).Value); % Y pixel size (non zoomed)
    
    XPixSize=XPixSize/Zoom;
    YPixSize=YPixSize/Zoom;
   
    set(handles.XSinglePixelSize,'String',num2str(XPixSize));
    set(handles.YSinglePixelSize,'String',num2str(YPixSize));
    set(handles.ExposureTime,'String',num2str(DwellTime));
    set(handles.FrameRate,'String',num2str(FrameRate));
    set(handles.scanlinePeriod,'String',num2str(scanlinePeriod));
    
    set(handles.StageX,'String',num2str(XPos));
    set(handles.StageY,'String',num2str(YPos));
    set(handles.StageZ,'String',num2str(ZPos));
    
    FilesTif=dir('*.tif');
    FileGroup=struct2cell(FilesTif);
    FileGroup=FileGroup(1,:)';
    set(handles.EndFrame,'String',num2str(length(FileGroup))); % Temporary solution need to handle Channels
    
    
    choice=get(handles.LoadStageCoordsOptions,'Value');
    if (choice==3)
        set(handles.BrowseFileSelected,'Enable','on');
        set(handles.Browse,'Enable','on');
        [FileName,PathName,~] = uigetfile('*.xy');  % Format of prarie points locations.
        set(handles.BrowseFileSelected,'String',strcat(PathName,FileName));
    else
        set(handles.BrowseFileSelected,'Enable','off');
        set(handles.Browse,'Enable','off');
    end

            
%     try
%         InterfaceObj=findobj(handles.output,'Enable','on');
%         set(InterfaceObj,'Enable','off');
%         h=waitbar(0,'Checking data...');
% 
%         if (exist(InLoading)==2)
%             [returnFileGroup] = findFileSeries(InLoading, 0, 1);
%             set(handles.FolderNameList,'String',returnFileGroup);
%             
%             Numberframe=length(returnFileGroup);
%             set(handles.NbFrame,'String',num2str(Numberframe));
%             set(handles.EndFrame,'String',num2str(Numberframe));
%         end
%         delete(h);
%         set(InterfaceObj,'Enable','on');
%         
%     catch errorObj
%         set(InterfaceObj,'Enable','on');
%         % If there is a problem, we display the error message
%         errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
%         if exist('h','var')
%             if ishandle(h)
%                 delete(h);
%             end
%         end
%     end
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


% --- Executes on selection change in FolderNameList.
function FolderNameList_Callback(hObject, eventdata, handles)
% hObject    handle to FolderNameList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FolderNameList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FolderNameList


% --- Executes during object creation, after setting all properties.
function FolderNameList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FolderNameList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
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



function StepFrame_Callback(hObject, eventdata, handles)
% hObject    handle to StepFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StepFrame as text
%        str2double(get(hObject,'String')) returns contents of StepFrame as a double


% --- Executes during object creation, after setting all properties.
function StepFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StepFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StageX_Callback(hObject, eventdata, handles)
% hObject    handle to StageX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StageX as text
%        str2double(get(hObject,'String')) returns contents of StageX as a double


% --- Executes during object creation, after setting all properties.
function StageX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StageX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StageY_Callback(hObject, eventdata, handles)
% hObject    handle to StageY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StageY as text
%        str2double(get(hObject,'String')) returns contents of StageY as a double


% --- Executes during object creation, after setting all properties.
function StageY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StageY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StageZ_Callback(hObject, eventdata, handles)
% hObject    handle to StageZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StageZ as text
%        str2double(get(hObject,'String')) returns contents of StageZ as a double


% --- Executes during object creation, after setting all properties.
function StageZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StageZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in LoadStageCoordsOptions.
function LoadStageCoordsOptions_Callback(hObject, eventdata, handles)
% hObject    handle to LoadStageCoordsOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

choice=get(handles.LoadStageCoordsOptions,'Value');
if (choice==3)
    set(handles.BrowseFileSelected,'Enable','on');
    set(handles.Browse,'Enable','on');
    [FileName,PathName,~] = uigetfile('*.xy');  % Format of prarie points locations.
    set(handles.BrowseFileSelected,'String',strcat(PathName,FileName));
else
    set(handles.BrowseFileSelected,'Enable','off');
    set(handles.Browse,'Enable','off');
end


% Hints: contents = cellstr(get(hObject,'String')) returns LoadStageCoordsOptions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LoadStageCoordsOptions


% --- Executes during object creation, after setting all properties.
function LoadStageCoordsOptions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LoadStageCoordsOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Browse.
function Browse_Callback(hObject, eventdata, handles)
% hObject    handle to Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName,~] = uigetfile('*.xy');  % Format of prarie points locations.
set(handles.BrowseFileSelected,'String',strcat(PathName,FileName));




function BrowseFileSelected_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseFileSelected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BrowseFileSelected as text
%        str2double(get(hObject,'String')) returns contents of BrowseFileSelected as a double


% --- Executes during object creation, after setting all properties.
function BrowseFileSelected_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BrowseFileSelected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function scanlinePeriod_Callback(hObject, eventdata, handles)
% hObject    handle to scanlinePeriod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scanlinePeriod as text
%        str2double(get(hObject,'String')) returns contents of scanlinePeriod as a double


% --- Executes during object creation, after setting all properties.
function scanlinePeriod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scanlinePeriod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
