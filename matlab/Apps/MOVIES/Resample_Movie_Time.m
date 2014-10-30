function varargout = Resample_Movie_Time(varargin)
% RESAMPLE_MOVIE_TIME MATLAB code for Resample_Movie_Time.fig
%      RESAMPLE_MOVIE_TIME, by itself, creates a new RESAMPLE_MOVIE_TIME or raises the existing
%      singleton*.
%
%      H = RESAMPLE_MOVIE_TIME returns the handle to a new RESAMPLE_MOVIE_TIME or the handle to
%      the existing singleton*.
%
%      RESAMPLE_MOVIE_TIME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RESAMPLE_MOVIE_TIME.M with the given input arguments.
%
%      RESAMPLE_MOVIE_TIME('Property','Value',...) creates a new RESAMPLE_MOVIE_TIME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Resample_Movie_Time_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Resample_Movie_Time_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Resample_Movie_Time

% Last Modified by GUIDE v2.5 06-Feb-2012 23:33:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Resample_Movie_Time_OpeningFcn, ...
                   'gui_OutputFcn',  @Resample_Movie_Time_OutputFcn, ...
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


% --- Executes just before Resample_Movie_Time is made visible.
function Resample_Movie_Time_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Resample_Movie_Time (see VARARGIN)
global SpikeMovieData;

% Choose default command line output for Resample_Movie_Time
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Resample_Movie_Time wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if (length(varargin)>1)
    Settings=varargin{2};
    CurrentMovie=Settings.MovieSelectorValue;
    if CurrentMovie>length(SpikeMovieData)
        CurrentMovie=length(SpikeMovieData);
    end
    
    set(handles.MovieSelector,'Value',CurrentMovie);
    set(handles.MovieSelector,'String',Settings.MovieSelectorString);
    
    if str2num(Settings.NewStartFrameString)>SpikeMovieData(CurrentMovie).DataSize(3)
        Settings.NewStartFrameString=num2str(SpikeMovieData(CurrentMovie).DataSize(3));
    end
    
    set(handles.NewStartFrame,'String',Settings.NewStartFrameString);
    
    if str2num(Settings.NewEndFrameString)>SpikeMovieData(CurrentMovie).DataSize(3)
        Settings.NewEndFrameString=num2str(SpikeMovieData(CurrentMovie).DataSize(3));
    end
    
    set(handles.NewEndFrame,'String',Settings.NewEndFrameString);
    set(handles.FrameRateReduction,'String',Settings.FrameRateReductionString);
    set(handles.NewStartSec,'String',num2str(SpikeMovieData(CurrentMovie).TimeFrame(str2num(Settings.NewStartFrameString))));
    set(handles.NewEndSec,'String',...
        num2str(SpikeMovieData(CurrentMovie).TimeFrame(str2num(Settings.NewEndFrameString))));
else
    if ~isempty(SpikeMovieData)
        for i=1:length(SpikeMovieData)
            TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
        end
        CurrentMovie=1;

        set(handles.MovieSelector,'String',TextMovie);
        set(handles.MovieSelector,'Value',CurrentMovie);
        set(handles.NewStartSec,'String',num2str(SpikeMovieData(CurrentMovie).TimeFrame(1)));
        set(handles.NewEndSec,'String',...
            num2str(SpikeMovieData(CurrentMovie).TimeFrame(SpikeMovieData(CurrentMovie).DataSize(3))));
        set(handles.NewStartFrame,'String','1');
        set(handles.NewEndFrame,'String',num2str(SpikeMovieData(CurrentMovie).DataSize(3)));
    end
end
guidata(hObject,handles);

% We update some general parameters on the interface
if ~isempty(SpikeMovieData)
    set(handles.OldStartSec,'String',num2str(SpikeMovieData(CurrentMovie).TimeFrame(1)));
    set(handles.OldEndSec,'String',num2str(SpikeMovieData(CurrentMovie).TimeFrame(SpikeMovieData(CurrentMovie).DataSize(3))));
    set(handles.OldStartFrame,'String','1');
    set(handles.OldEndFrame,'String',num2str(SpikeMovieData(CurrentMovie).DataSize(3)));
    set(handles.OldRate,'String',num2str(1/(SpikeMovieData(CurrentMovie).TimeFrame(2)...
        -SpikeMovieData(CurrentMovie).TimeFrame(1))));
    RateDiv=str2double(get(handles.FrameRateReduction,'String'));
    set(handles.NewRate,'String',num2str(1/(RateDiv*(SpikeMovieData(CurrentMovie).TimeFrame(2)...
        -SpikeMovieData(CurrentMovie).TimeFrame(1)))));
end

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.MovieSelectorString=get(handles.MovieSelector,'String');
Settings.NewStartFrameString=get(handles.NewStartFrame,'String');
Settings.NewEndFrameString=get(handles.NewEndFrame,'String');
Settings.FrameRateReductionString=get(handles.FrameRateReduction,'String');
 

% This function find the matching frame number to a certain time period
function [BeginFrame EndFrame]=FindMatchFrame(BeginTime,EndTime,handles)
global SpikeMovieData;

CurrentMovie=get(handles.MovieSelector,'Value');
IndexFound=find((SpikeMovieData(CurrentMovie).TimeFrame)>=BeginTime & EndTime>=(SpikeMovieData(CurrentMovie).TimeFrame));
BeginFrame=min(IndexFound);
EndFrame=max(IndexFound);


% --- Outputs from this function are returned to the command line.
function varargout = Resample_Movie_Time_OutputFcn(hObject, eventdata, handles) 
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


% This is a copy from decimate.m from Mathworks
function H = filtmag_db(b,a,f)
%FILTMAG_DB Find filter's magnitude response in decibels at given frequency.

nb = length(b);
na = length(a);
top = exp(-1i*(0:nb-1)*pi*f)*b(:);
bot = exp(-1i*(0:na-1)*pi*f)*a(:);

H = 20*log10(abs(top/bot));


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    CurrentMovie=get(handles.MovieSelector,'Value');
    
    
    % We measure the new resolution to be to allow preallocation of the Storing
    % matrix.
    NewStartFrame=str2double(get(handles.NewStartFrame,'String'));
    NewEndFrame=str2double(get(handles.NewEndFrame,'String'));
    NewRate=str2double(get(handles.NewRate,'String'));
    RateChange=str2num(get(handles.FrameRateReduction,'String'));
    OldRate=str2double(get(handles.OldRate,'String'));
        
    h=waitbar(0,'Resampling movie...');
    
    % We prallocate the big matrixes.
    % As we change data size, we need to do so
    OriginalClassMovie=class(SpikeMovieData(CurrentMovie).Movie);
    
    % We first design the low pass filter to apply to do antialiasing
    % The filter design is a copy from decimate.m from Mathworks so that to
    % avoid unnecessary iterative execution of the same code to apply only
    % the relevant processing to the movie.
    nfilt = 8;
    MatrixSelection=NewStartFrame:RateChange:NewEndFrame;
    
    % We preallocate
    NewMovie=zeros([SpikeMovieData(CurrentMovie).DataSize(1) SpikeMovieData(CurrentMovie).DataSize(2) length(MatrixSelection)],OriginalClassMovie);
    
    % We only filter if there is a rate change (ie keep a special case for
    % subframe selection).
    if RateChange~=1
        % IIR filter
        rip = .05;	% passband ripple in dB
        [bFilter,aFilter] = cheby1(nfilt, rip, .8/RateChange);
        while all(bFilter==0) || (abs(filtmag_db(bFilter,aFilter,.8/RateChange)+rip)>1e-6)
            nfilt = nfilt - 1;
            if nfilt == 0
                break
            end
            [bFilter,aFilter] = cheby1(nfilt, rip, .8/RateChange);
        end
        
        % waitbar is consuming too much ressources, so I divide its access
        dividerWaitBar=10^(floor(log10(SpikeMovieData(CurrentMovie).DataSize(2)))-1);
        
        % We go along second dimension as Matlab is Column-major
        for i=1:SpikeMovieData(CurrentMovie).DataSize(2)
            for j=1:SpikeMovieData(CurrentMovie).DataSize(1)
                LocalMovieData=double(squeeze(SpikeMovieData(CurrentMovie).Movie(j,i,:))');
                
                % be sure to filter in both directions to make sure the filtered data has zero phase
                % make a data vector properly pre- and ap- pended to filter forwards and back
                % so end effects can be obliterated.
                LocalMovieData = filtfilt(bFilter,aFilter,LocalMovieData);
                
                % After low-pass filtering we can safely keep the relevant
                % subpoints.
                LocalMovieData = LocalMovieData(MatrixSelection);
                
                NewMovie(j,i,:)=reshape(cast(LocalMovieData,OriginalClassMovie),[1 1 length(MatrixSelection)]);
            end
            
            if (round(i/dividerWaitBar)==i/dividerWaitBar)
                waitbar(i/SpikeMovieData(CurrentMovie).DataSize(2),h);
            end
        end
    else
        
        % waitbar is consuming too much ressources, so I divide its access
        dividerWaitBar=10^(floor(log10(length(MatrixSelection)))-1);
        
        for i=1:length(MatrixSelection)
            NewMovie(:,:,i)=SpikeMovieData(CurrentMovie).Movie(:,:,MatrixSelection(i));
            
            if (round(i/dividerWaitBar)==i/dividerWaitBar)
                waitbar(i/length(MatrixSelection),h);
            end
        end
    end
    
    SpikeMovieData(CurrentMovie).Movie=NewMovie;
    SpikeMovieData(CurrentMovie).TimePixel=SpikeMovieData(CurrentMovie).TimePixel(:,:,MatrixSelection);
    SpikeMovieData(CurrentMovie).DataSize=size(SpikeMovieData(CurrentMovie).Movie);
    SpikeMovieData(CurrentMovie).TimeFrame=SpikeMovieData(CurrentMovie).TimeFrame(MatrixSelection);
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


function FrameRateReduction_Callback(hObject, eventdata, handles)
% hObject    handle to FrameRateReduction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameRateReduction as text
%        str2double(get(hObject,'String')) returns contents of FrameRateReduction as a double
global SpikeMovieData;

CurrentMovie=get(handles.MovieSelector,'Value');
RateDiv=str2double(get(handles.FrameRateReduction,'String'));
set(handles.NewRate,'String',num2str(1/(RateDiv*(SpikeMovieData(CurrentMovie).TimeFrame(2)...
        -SpikeMovieData(CurrentMovie).TimeFrame(1)))));   

    
% --- Executes during object creation, after setting all properties.
function FrameRateReduction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameRateReduction (see GCBO)
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


% --- Executes on selection change in InterpolationMethod.
function InterpolationMethod_Callback(hObject, eventdata, handles)
% hObject    handle to InterpolationMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns InterpolationMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from InterpolationMethod


% --- Executes during object creation, after setting all properties.
function InterpolationMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InterpolationMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NewStartSec_Callback(hObject, eventdata, handles)
% hObject    handle to NewStartSec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NewStartSec as text
%        str2double(get(hObject,'String')) returns contents of NewStartSec as a double
BeginTime=str2double(get(handles.NewStartSec,'String'));
EndTime=str2double(get(handles.NewEndSec,'String'));
[BeginFrame EndFrame]=FindMatchFrame(BeginTime,EndTime,handles);
set(handles.NewStartFrame,'String',num2str(BeginFrame));
set(handles.NewEndFrame,'String',num2str(EndFrame));


% --- Executes during object creation, after setting all properties.
function NewStartSec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NewStartSec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NewEndSec_Callback(hObject, eventdata, handles)
% hObject    handle to NewEndSec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NewEndSec as text
%        str2double(get(hObject,'String')) returns contents of NewEndSec as a double
BeginTime=str2double(get(handles.NewStartSec,'String'));
EndTime=str2double(get(handles.NewEndSec,'String'));
[BeginFrame EndFrame]=FindMatchFrame(BeginTime,EndTime,handles);
set(handles.NewStartFrame,'String',num2str(BeginFrame));
set(handles.NewEndFrame,'String',num2str(EndFrame));


% --- Executes during object creation, after setting all properties.
function NewEndSec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NewEndSec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NewStartFrame_Callback(hObject, eventdata, handles)
% hObject    handle to NewStartFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NewStartFrame as text
%        str2double(get(hObject,'String')) returns contents of NewStartFrame as a double
global SpikeMovieData;
CurrentMovie=get(handles.MovieSelector,'Value');

% We check whether is it within range
MaxFrame=SpikeMovieData(CurrentMovie).DataSize(3);
CurrentFrame=str2double(get(hObject,'String'));

if MaxFrame<CurrentFrame
    CurrentFrame=MaxFrame;
    set(hObject,'String',num2str(CurrentFrame));
elseif CurrentFrame<1
    CurrentFrame=1;
    set(hObject,'String',num2str(CurrentFrame));
end

set(handles.NewStartSec,'String',num2str(SpikeMovieData(CurrentMovie).TimeFrame(CurrentFrame)));
 

% --- Executes during object creation, after setting all properties.
function NewStartFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NewStartFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NewEndFrame_Callback(hObject, eventdata, handles)
% hObject    handle to NewEndFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NewEndFrame as text
%        str2double(get(hObject,'String')) returns contents of NewEndFrame as a double
global SpikeMovieData;
CurrentMovie=get(handles.MovieSelector,'Value');

% We check whether is it within range
MaxFrame=SpikeMovieData(CurrentMovie).DataSize(3);
CurrentFrame=str2double(get(hObject,'String'));

if MaxFrame<CurrentFrame
    CurrentFrame=MaxFrame;
    set(hObject,'String',num2str(CurrentFrame));
elseif CurrentFrame<1
    CurrentFrame=1;
    set(hObject,'String',num2str(CurrentFrame));
end

set(handles.NewEndSec,'String',num2str(SpikeMovieData(CurrentMovie).TimeFrame(CurrentFrame)));


% --- Executes during object creation, after setting all properties.
function NewEndFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NewEndFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
