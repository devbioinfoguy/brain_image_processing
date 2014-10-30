function varargout = Binning_Movie_Time(varargin)
% BINNING_MOVIE_TIME MATLAB code for Binning_Movie_Time.fig
%      BINNING_MOVIE_TIME, by itself, creates a new BINNING_MOVIE_TIME or raises the existing
%      singleton*.
%
%      H = BINNING_MOVIE_TIME returns the handle to a new BINNING_MOVIE_TIME or the handle to
%      the existing singleton*.
%
%      BINNING_MOVIE_TIME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINNING_MOVIE_TIME.M with the given input arguments.
%
%      BINNING_MOVIE_TIME('Property','Value',...) creates a new BINNING_MOVIE_TIME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Binning_Movie_Time_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Binning_Movie_Time_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Binning_Movie_Time

% Last Modified by GUIDE v2.5 02-Apr-2012 16:28:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Binning_Movie_Time_OpeningFcn, ...
                   'gui_OutputFcn',  @Binning_Movie_Time_OutputFcn, ...
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


% --- Executes just before Binning_Movie_Time is made visible.
function Binning_Movie_Time_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Binning_Movie_Time (see VARARGIN)
global SpikeMovieData;

% Choose default command line output for Binning_Movie_Time
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Binning_Movie_Time wait for user response (see UIRESUME)
% uiwait(handles.figure1);
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
    set(handles.BinningReduction,'String',Settings.BinningReductionString);  
end
guidata(hObject,handles);

% We update some general parameters on the interface
if ~isempty(SpikeMovieData)
    CurrentMovie=get(handles.MovieSelector,'Value');
    
    set(handles.OldRate,'String',num2str(1/(SpikeMovieData(CurrentMovie).TimeFrame(2)...
        -SpikeMovieData(CurrentMovie).TimeFrame(1))));
    RateDiv=str2double(get(handles.BinningReduction,'String'));
    set(handles.NewRate,'String',num2str(1/(RateDiv*(SpikeMovieData(CurrentMovie).TimeFrame(2)...
        -SpikeMovieData(CurrentMovie).TimeFrame(1)))));
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.BinningReductionString=get(handles.BinningReduction,'String');
 

% --- Outputs from this function are returned to the command line.
function varargout = Binning_Movie_Time_OutputFcn(hObject, eventdata, handles) 
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

    CurrentMovie=get(handles.MovieSelector,'Value');
    
    % We measure the new resolution to be to allow preallocation of the Storing
    % matrix.
    NewRate=str2double(get(handles.NewRate,'String'));
    RateChange=str2num(get(handles.BinningReduction,'String'));
    OldRate=str2double(get(handles.OldRate,'String'));
        
    h=waitbar(0,'Resampling movie...');
    % We close it in the end
    Cleanup2=onCleanup(@()delete(h));
        
    
    % We prallocate the big matrixes.
    % As we change data size, we need to do so
    OriginalClassMovie=class(SpikeMovieData(CurrentMovie).Movie);
    OriginalClassTime=class(SpikeMovieData(CurrentMovie).TimePixel);
    
    % We first design the low pass filter to apply to do antialiasing
    % The filter design is a copy from decimate.m from Mathworks so that to
    % avoid unnecessary iterative execution of the same code to apply only
    % the relevant processing to the movie.
    MatrixSelectionBegin=1:RateChange:SpikeMovieData(CurrentMovie).DataSize(3);
    
    % waitbar is consuming too much ressources, so I divide its acces
    dividerWaitbar=10^(floor(log10(SpikeMovieData(CurrentMovie).DataSize(3)))-1);
    
    % We preallocate
    NewMovie=zeros([SpikeMovieData(CurrentMovie).DataSize(1) SpikeMovieData(CurrentMovie).DataSize(2) length(MatrixSelectionBegin)],OriginalClassMovie);
    NewTime=zeros([SpikeMovieData(CurrentMovie).DataSize(1) SpikeMovieData(CurrentMovie).DataSize(2) length(MatrixSelectionBegin)],OriginalClassTime);
    
    
    % We only filter if there is a rate change (ie keep a special case for
    % subframe selection).
    if RateChange~=1
        
        % We go to double to allow slowing summing up all
        % elements and avoid truncating issues.
        LocalMovieData=zeros(SpikeMovieData(CurrentMovie).DataSize(1:2),'double');
        LocalTimeData=zeros(SpikeMovieData(CurrentMovie).DataSize(1:2),'double');
        
        % waitbar is consuming too much ressources, so I divide its access
        dividerWaitBar=10^(floor(log10(SpikeMovieData(CurrentMovie).DataSize(1)))-1);
        
        NewTimeFrame=zeros(length(MatrixSelectionBegin),1,'double');
        NumberFrames=0;
        FrameNumber=1;
        
        for i=1:SpikeMovieData(CurrentMovie).DataSize(3)
           
            LocalMovieData=LocalMovieData+double(SpikeMovieData(CurrentMovie).Movie(:,:,i));
            LocalTimeData=LocalTimeData+double(SpikeMovieData(CurrentMovie).TimePixel(:,:,i));
            
            NewTimeFrame(FrameNumber)=NewTimeFrame(FrameNumber)+SpikeMovieData(CurrentMovie).TimeFrame(i);
            
            NumberFrames=NumberFrames+1;
            
            if i>1 && (ismember(i+1,MatrixSelectionBegin) || (i==SpikeMovieData(CurrentMovie).DataSize(3)))
                % We store the final values if one binning block is
                % finished
                % The last frame might be binned over less frames than
                % the rest of the movie
                NewMovie(:,:,FrameNumber)=cast(LocalMovieData/NumberFrames,OriginalClassMovie);
                NewTime(:,:,FrameNumber)=cast(LocalTimeData/NumberFrames,OriginalClassTime);
                NewTimeFrame(FrameNumber)=NewTimeFrame(FrameNumber)/NumberFrames;
                
                % We go to double to allow slowing summing up all
                % elements and avoid truncating issues.
                LocalMovieData=zeros(SpikeMovieData(CurrentMovie).DataSize(1:2),'double');
                LocalTimeData=zeros(SpikeMovieData(CurrentMovie).DataSize(1:2),'double');
                NumberFrames=0;
                FrameNumber=FrameNumber+1;
            end
            
            if (round(i/dividerWaitBar)==i/dividerWaitBar)
                waitbar(i/SpikeMovieData(CurrentMovie).DataSize(3),h);
            end
        end
        
        SpikeMovieData(CurrentMovie).Movie=NewMovie;
        SpikeMovieData(CurrentMovie).TimePixel=NewTime;
        SpikeMovieData(CurrentMovie).TimeFrame=NewTimeFrame;
        SpikeMovieData(CurrentMovie).DataSize=size(SpikeMovieData(CurrentMovie).Movie);
    end
        
    ValidateValues_Callback(hObject, eventdata, handles);
    
catch errorObj
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
end


function BinningReduction_Callback(hObject, eventdata, handles)
% hObject    handle to BinningReduction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BinningReduction as text
%        str2double(get(hObject,'String')) returns contents of BinningReduction as a double
global SpikeMovieData;

CurrentMovie=get(handles.MovieSelector,'Value');
RateDiv=str2double(get(handles.BinningReduction,'String'));
set(handles.NewRate,'String',num2str(1/(RateDiv*(SpikeMovieData(CurrentMovie).TimeFrame(2)...
        -SpikeMovieData(CurrentMovie).TimeFrame(1)))));   

    
% --- Executes during object creation, after setting all properties.
function BinningReduction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BinningReduction (see GCBO)
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

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
