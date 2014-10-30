function varargout = Deinterlace(varargin)
% DEINTERLACE MATLAB code for Deinterlace.fig
%      DEINTERLACE, by itself, creates a new DEINTERLACE or raises the existing
%      singleton*.
%
%      H = DEINTERLACE returns the handle to a new DEINTERLACE or the handle to
%      the existing singleton*.
%
%      DEINTERLACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEINTERLACE.M with the given input arguments.
%
%      DEINTERLACE('Property','Value',...) creates a new DEINTERLACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Deinterlace_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Deinterlace_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Deinterlace

% Last Modified by GUIDE v2.5 06-Feb-2012 21:36:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Deinterlace_OpeningFcn, ...
                   'gui_OutputFcn',  @Deinterlace_OutputFcn, ...
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


% --- Executes just before Deinterlace is made visible.
function Deinterlace_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Deinterlace (see VARARGIN)

% Choose default command line output for Deinterlace
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Deinterlace wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global SpikeMovieData;

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.MovieSelector,'Value',Settings.MovieSelectorValue);
    set(handles.MovieSelector,'String',Settings.MovieSelectorString);
    set(handles.sliderShift,'Value',Settings.sliderShiftValue);
    set(handles.InterlaceValue,'String',Settings.InterlaceValueString);
    set(handles.CurrentFrameValue,'String',Settings.CurrentFrameValueString);
else
    if ~isempty(SpikeMovieData)
        for i=1:length(SpikeMovieData)
            TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
        end
        set(handles.MovieSelector,'String',TextMovie);
        
        guidata(hObject,handles);
    end
end

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.MovieSelectorString=get(handles.MovieSelector,'String');
Settings.sliderShiftValue=get(handles.sliderShift,'Value');
Settings.InterlaceValueString=get(handles.InterlaceValue,'String');
Settings.CurrentFrameValueString=get(handles.CurrentFrameValue,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Deinterlace_OutputFcn(hObject, eventdata, handles) 
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
if isfield(handles,'hFigImageTest')
    if (ishandle(handles.hFigImageTest))
        delete(handles.hFigImageTest);
    end
end
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
    
    if ~isempty(SpikeMovieData)
        MovieSel=get(handles.MovieSelector,'Value');
        % waitbar is consuming too much ressources, so I divide its access
        dividerWaitBar=10^(floor(log10(SpikeMovieData(MovieSel).DataSize(3)))-1);
        
        ShiftValue=get(handles.sliderShift,'Value');
        
        h=waitbar(0,'Deinterlacing pictures ...');
        for i=1:SpikeMovieData(MovieSel).DataSize(3)
            SpikeMovieData(MovieSel).Movie(:,:,i)=SingleDeinterlace(SpikeMovieData(MovieSel).Movie(:,:,i),ShiftValue);
            SpikeMovieData(MovieSel).TimePixel(:,:,i)=SingleDeinterlace(SpikeMovieData(MovieSel).TimePixel(:,:,i),ShiftValue);
            if (round(i/dividerWaitBar)==i/dividerWaitBar)
                waitbar(i/SpikeMovieData(MovieSel).DataSize(3),h);
            end
        end
        SpikeMovieData(MovieSel).Exposure=SingleDeinterlace(SpikeMovieData(MovieSel).Exposure,ShiftValue);
        delete(h);
    end
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

% --- Executes on selection change in MovieSelector.
function MovieSelector_Callback(hObject, eventdata, handles)
% hObject    handle to MovieSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MovieSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MovieSelector
DisplayTestImage(handles);
ShiftValue=get(handles.sliderShift,'Value');
set(handles.sliderShift,'Value',ShiftValue);
sliderShift_Callback(hObject, eventdata, handles);

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
DisplayTestImage(handles);

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
MovieSel=get(handles.MovieSelector,'Value');

CurrentIteration=str2num(get(handles.CurrentFrameValue,'String'));

if ~isempty(SpikeMovieData)
    CurrentIteration=min(SpikeMovieData(MovieSel).DataSize(3),CurrentIteration+1);
    set(handles.CurrentFrameValue,'String',num2str(CurrentIteration));
    DisplayTestImage(handles);
end

% --- Executes on button press in PreviousFrame.
function PreviousFrame_Callback(hObject, eventdata, handles)
% hObject    handle to PreviousFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CurrentIteration=str2num(get(handles.CurrentFrameValue,'String'));

CurrentIteration=max(1,CurrentIteration-1);
set(handles.CurrentFrameValue,'String',num2str(CurrentIteration));
DisplayTestImage(handles);

% function to display the current settings on a test figure
function DisplayTestImage(handles)
global SpikeMovieData;
global SpikeGui;

if ~isempty(SpikeMovieData)
    handles=guidata(handles.output);
    
    if isfield(handles,'hFigImageTest')
        if (isempty(handles.hFigImageTest) || ~ishandle(handles.hFigImageTest))
            handles.hFigImageTest=figure('Name','Resolution Test Image','NumberTitle','off');
        else
            figure(handles.hFigImageTest);
        end
    else
        handles.hFigImageTest=figure('Name','Resolution Test Image','NumberTitle','off');
    end
    
    if (ishandle(SpikeGui.hDataDisplay))
        GlobalColorMap = get(SpikeGui.hDataDisplay,'Colormap');
        set(handles.hFigImageTest,'Colormap',GlobalColorMap)
    end
    
    CurrentMovie=get(handles.MovieSelector,'Value');
    NewPic=SingleDeinterlace(SpikeMovieData(CurrentMovie).Movie(:,:,str2num(get(handles.CurrentFrameValue,'String'))),get(handles.sliderShift,'Value'));
    
    imagesc(NewPic);
    guidata(handles.output,handles);
end

% --- Executes on slider movement.
function sliderShift_Callback(hObject, eventdata, handles)
% hObject    handle to sliderShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

SliderPos=get(hObject,'Value');

if round(SliderPos)~=SliderPos
    SliderPos=round(SliderPos);
    set(handles.output,'Value',SliderPos);
end
set(handles.InterlaceValue,'String',num2str(SliderPos));

DisplayTestImage(handles);

% --- Executes during object creation, after setting all properties.
function sliderShift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
