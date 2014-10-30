function varargout = Histogram(varargin)
% HISTOGRAM MATLAB code for Histogram.fig
%      HISTOGRAM, by itself, creates a new HISTOGRAM or raises the existing
%      singleton*.
%
%      H = HISTOGRAM returns the handle to a new HISTOGRAM or the handle to
%      the existing singleton*.
%
%      HISTOGRAM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HISTOGRAM.M with the given input arguments.
%
%      HISTOGRAM('Property','Value',...) creates a new HISTOGRAM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Histogram_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Histogram_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Histogram

% Last Modified by GUIDE v2.5 06-Feb-2012 21:42:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Histogram_OpeningFcn, ...
                   'gui_OutputFcn',  @Histogram_OutputFcn, ...
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


% --- Executes just before Histogram is made visible.
function Histogram_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Histogram (see VARARGIN)

% Choose default command line output for Histogram
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Histogram wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global SpikeMovieData;

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.MovieSelector,'String',Settings.MovieSelectorString);
    set(handles.MovieSelector,'Value',Settings.MovieSelectorValue);    
    set(handles.CurrentFrameValue,'String',Settings.CurrentFrameValue);
else
    if ~isempty(SpikeMovieData)
        for i=1:length(SpikeMovieData)
            TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
        end
        set(handles.MovieSelector,'String',TextMovie);
    end
end

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorString=get(handles.MovieSelector,'String');
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.CurrentFrameValue=get(handles.CurrentFrameValue,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Histogram_OutputFcn(hObject, eventdata, handles) 
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
if isfield(handles,'hFigImage')
    if (ishandle(handles.hFigImage))
        delete(handles.hFigImage);
    end
end
uiresume;

% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    DisplayHist();
    set(InterfaceObj,'Enable','on');
    
catch errorObj
    set(InterfaceObj,'Enable','on');
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


% --- Executes on button press in NextFrame.
function NextFrame_Callback(hObject, eventdata, handles)
% hObject    handle to NextFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;
if ~isempty(SpikeMovieData)
    CurrentMovie=get(handles.MovieSelector,'Value');
    CurrentIteration=str2num(get(handles.CurrentFrameValue,'String'));
    
    CurrentIteration=min(SpikeMovieData(CurrentMovie).DataSize(3),CurrentIteration+1);
    set(handles.CurrentFrameValue,'String',num2str(CurrentIteration));
end

% --- Executes on button press in PreviousFrame.
function PreviousFrame_Callback(hObject, eventdata, handles)
% hObject    handle to PreviousFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CurrentIteration=str2num(get(handles.CurrentFrameValue,'String'));

CurrentIteration=max(1,CurrentIteration-1);
set(handles.CurrentFrameValue,'String',num2str(CurrentIteration));


% function to display the current hist on a figure
function DisplayHist()
global SpikeMovieData;

if ~isempty(SpikeMovieData)
    handles=guidata(gcbo);
    
    if isfield(handles,'hFigImage')
        if (isempty(handles.hFigImage) || ~ishandle(handles.hFigImage))
            handles.hFigImage=figure('Name','Histogram','NumberTitle','off');
        else
            figure(handles.hFigImage);
        end
    else
        handles.hFigImage=figure('Name','Histogram','NumberTitle','off');
    end
    CurrentMovie=get(handles.MovieSelector,'Value');
    
    CurrentY=SpikeMovieData(CurrentMovie).Movie(:,:,str2num(get(handles.CurrentFrameValue,'String')));
    
    hist(double(CurrentY(:)),100);
    xlabel(SpikeMovieData(CurrentMovie).Label.CLabel);     
    ylabel('N');

    guidata(gcbo,handles);
end
