function varargout = MergeMovies(varargin)
% MERGEMOVIES MATLAB code for MergeMovies.fig
%      MERGEMOVIES, by itself, creates a new MERGEMOVIES or raises the existing
%      singleton*.
%
%      H = MERGEMOVIES returns the handle to a new MERGEMOVIES or the handle to
%      the existing singleton*.
%
%      MERGEMOVIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MERGEMOVIES.M with the given input arguments.
%
%      MERGEMOVIES('Property','Value',...) creates a new MERGEMOVIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MergeMovies_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MergeMovies_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help MergeMovies

% Last Modified by GUIDE v2.5 30-Jul-2012 11:36:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MergeMovies_OpeningFcn, ...
                   'gui_OutputFcn',  @MergeMovies_OutputFcn, ...
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


% --- Executes just before MergeMovies is made visible.
function MergeMovies_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MergeMovies (see VARARGIN)

global SpikeMovieData;

% Choose default command line output for MergeMovies
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MergeMovies wait for user response (see UIRESUME)
% uiwait(handles.figure1);
if isfield(SpikeMovieData,'TimeFrame') && (~isempty(SpikeMovieData))
    set(handles.ListSelectMovies,'Enable','on');
    
    for i=1:length(SpikeMovieData)
        TextToMovies{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
    end
    set(handles.ListSelectMovies,'String',TextToMovies);
    guidata(handles.output, handles);
    
else
    set(handles.ListSelectMovies,'String','');
    set(handles.ListSelectMovies,'Value',[]);
    set(handles.ListSelectMovies,'Enable','off');
    guidata(handles.output, handles);
end
% Update handles structure
guidata(handles.output, handles);



% --- Outputs from this function are returned to the command line.
function varargout = MergeMovies_OutputFcn(hObject, eventdata, handles) 
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

InterfaceObj=findobj(handles.output,'Enable','on');

guidata(handles.output, handles);
ListMovies=get(handles.ListSelectMovies,'Value');

if (isempty(ListMovies))%&& isempty(ListImages) && isempty(ListTraces))
    if (~isempty(handles.hDataDisplay) && ishandle(handles.hDataDisplay))
            close(handles.hDataDisplay);
    end
else
    NMovies=length(ListMovies);
    MovieName=get(handles.MovieName,'String');
    
    
    % Go through all movies and get the range of coordinates
    allTopLeftCornerXY=zeros(NMovies, 2);
    allBottomRightCornerXY=zeros(NMovies, 2);
    
    % getting coners of each movie
    for CurrentMovieNumber=1:NMovies
        iMovie=ListMovies(CurrentMovieNumber);
        allTopLeftCornerXY(CurrentMovieNumber,1)=min(SpikeMovieData(iMovie).Xposition(:));
        allTopLeftCornerXY(CurrentMovieNumber,2)=min(SpikeMovieData(iMovie).Yposition(:));
        allBottomRightCornerXY(CurrentMovieNumber,1)=max(SpikeMovieData(iMovie).Xposition(:));
        allBottomRightCornerXY(CurrentMovieNumber,2)=max(SpikeMovieData(iMovie).Yposition(:));
    end
    
    TopLeftCornerXY=min(allTopLeftCornerXY,[],1);
    BottomRightCornerXY=max(allBottomRightCornerXY,[],1);
    
    % Create a big Movie (initialize)
    MergedMovie=length(SpikeMovieData)+1;
    %SpikeMovieData(MergedMovie).Path=pathstr;
    %SpikeMovieData(MergedMovie).Filename=[name ext];
    
    % Getting settings from the first movie
    [~,~,NumberOfFrames]=size(SpikeMovieData(ListMovies(1)).Movie);
    VarClass=class(SpikeMovieData(ListMovies(1)).Movie);
    PixelSize=SpikeMovieData(ListMovies(1)).Xposition(1,2)-SpikeMovieData(ListMovies(1)).Xposition(1,1);
    SizeX=ceil((BottomRightCornerXY(1)-TopLeftCornerXY(1))/PixelSize);
    SizeY=ceil((BottomRightCornerXY(2)-TopLeftCornerXY(2))/PixelSize);
    SpikeMovieData(MergedMovie).Movie=zeros(SizeY,SizeX,NumberOfFrames,VarClass);
    SpikeMovieData(MergedMovie).DataSize=size(SpikeMovieData(MergedMovie).Movie);
    
    SpikeMovieData(MergedMovie).TimeFrame=SpikeMovieData(ListMovies(1)).TimeFrame;
    SpikeMovieData(MergedMovie).TimePixel=zeros(SpikeMovieData(MergedMovie).DataSize(1:3),'uint8');
    SpikeMovieData(MergedMovie).Exposure=SpikeMovieData(ListMovies(1)).Exposure(1,1)*ones(SpikeMovieData(MergedMovie).DataSize(1:2),'single');
    SpikeMovieData(MergedMovie).TimePixelUnits=10^-6;
    
    [SpikeMovieData(MergedMovie).Xposition,SpikeMovieData(MergedMovie).Yposition] ...
            = meshgrid(linspace(TopLeftCornerXY(1),BottomRightCornerXY(1),SizeX),linspace(TopLeftCornerXY(2),BottomRightCornerXY(2),SizeY));
    
    SpikeMovieData(MergedMovie).Label.ListText= MovieName;  
    SpikeMovieData(MergedMovie).Label.XLabel='Microns';
    SpikeMovieData(MergedMovie).Label.YLabel='Microns';
    SpikeMovieData(MergedMovie).Label.ZLabel='Fluor';
    SpikeMovieData(MergedMovie).Label.CLabel='Fluor';
        
    % Start merging into Big Movie
    XYcounter=0;
    for CurrentMovieNumber=1:NMovies
        XYcounter=XYcounter+1;
        iMovie=ListMovies(CurrentMovieNumber);
        iX=allTopLeftCornerXY(XYcounter,1);
        iY=allTopLeftCornerXY(XYcounter,2);
        
        [~,XTopLeftCoord]=min(abs(SpikeMovieData(MergedMovie).Xposition(1,:)-iX));
        XTopLeftCoord=XTopLeftCoord(1);        
        [~,YTopLeftCoord]=min(abs(SpikeMovieData(MergedMovie).Yposition(:,1)-iY));
        YTopLeftCoord=YTopLeftCoord(1);
        
%         iX=allBottomRightCornerXY(iMovie,1);
%         iY=allBottomRightCornerXY(iMovie,2);
%         
%         [~,XBottomRightCoord]=min(abs(SpikeMovieData(MergedMovie).Xposition(1,:)-iX));
%         XBottomRightCoord=XBottomRightCoord(1);        
%         [~,YBottomRightCoord]=min(abs(SpikeMovieData(MergedMovie).Yposition(:,1)-iY));
%         YBottomRightCoord=YBottomRightCoord(1);
    
    %    SpikeMovieData(MergedMovie).Movie(,,:))=interpn(SpikeMovieData(iMovie).Xposition,SpikeMovieData(iMovie).Yposition,SpikeMovieData(MergedMovie).TimeFrame,...
    %        SpikeMovieData(iMovie).Movie,,,SpikeMovieData(MergedMovie).TimeFrame);
    
    [iYSize,iXSize,~]=size(SpikeMovieData(iMovie).Movie);
    SpikeMovieData(MergedMovie).Movie(YTopLeftCoord:YTopLeftCoord+iYSize-1,XTopLeftCoord:XTopLeftCoord+iXSize-1,:)=SpikeMovieData(iMovie).Movie(:,:,:);
        
    
        
    end
    
    
    % Save Movie to disk - optional (can use existing Spike App).
    
     ValidateValues_Callback(hObject, eventdata, handles);
     set(InterfaceObj,'Enable','on');
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



% --- Executes on selection change in ListSelectMovies.
function ListSelectMovies_Callback(hObject, eventdata, handles)
% hObject    handle to ListSelectMovies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListSelectMovies contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListSelectMovies


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
