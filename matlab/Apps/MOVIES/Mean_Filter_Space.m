function varargout = Mean_Filter_Space(varargin)
% MEAN_FILTER_SPACE MATLAB code for Mean_Filter_Space.fig
%      MEAN_FILTER_SPACE, by itself, creates a new MEAN_FILTER_SPACE or raises the existing
%      singleton*.
%
%      H = MEAN_FILTER_SPACE returns the handle to a new MEAN_FILTER_SPACE or the handle to
%      the existing singleton*.
%
%      MEAN_FILTER_SPACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MEAN_FILTER_SPACE.M with the given input arguments.
%
%      MEAN_FILTER_SPACE('Property','Value',...) creates a new MEAN_FILTER_SPACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Mean_Filter_Space_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Mean_Filter_Space_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Mean_Filter_Space

% Last Modified by GUIDE v2.5 06-Feb-2012 22:38:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Mean_Filter_Space_OpeningFcn, ...
                   'gui_OutputFcn',  @Mean_Filter_Space_OutputFcn, ...
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


% --- Executes just before Mean_Filter_Space is made visible.
function Mean_Filter_Space_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Mean_Filter_Space (see VARARGIN)
global SpikeMovieData;

% Choose default command line output for Mean_Filter_Space
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Mean_Filter_Space wait for user response (see UIRESUME)
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
    set(handles.FrameNumber,'String',Settings.FrameNumberString);
    set(handles.RectAverSelect,'Value',Settings.RectAverSelectValue);
    set(handles.DiskAverSelect,'Value',Settings.DiskAverSelectValue);
    set(handles.GaussAverSelect,'Value',Settings.GaussAverSelectValue);
    set(handles.HeightRect,'String',Settings.HeightRectString);
    set(handles.WidthRect,'String',Settings.WidthRectString);
    set(handles.DiskRadius,'String',Settings.DiskRadiusString);
    set(handles.HeightGauss,'String',Settings.HeightGaussString);
    set(handles.WidthGauss,'String',Settings.WidthGaussString);
    set(handles.SigmaGauss,'String',Settings.SigmaGaussString);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.FrameNumberString=get(handles.FrameNumber,'String');
Settings.RectAverSelectValue=get(handles.RectAverSelect,'Value');
Settings.DiskAverSelectValue=get(handles.DiskAverSelect,'Value');
Settings.GaussAverSelectValue=get(handles.GaussAverSelect,'Value');
Settings.HeightRectString=get(handles.HeightRect,'String');
Settings.WidthRectString=get(handles.WidthRect,'String');
Settings.DiskRadiusString=get(handles.DiskRadius,'String');
Settings.HeightGaussString=get(handles.HeightGauss,'String');
Settings.WidthGaussString=get(handles.WidthGauss,'String');
Settings.SigmaGaussString=get(handles.SigmaGauss,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Mean_Filter_Space_OutputFcn(hObject, eventdata, handles) 
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
    
    h=waitbar(0,'Filtering data...');
    
    MovieToApply=get(handles.MovieSelector,'Value');
    
    if get(handles.RectAverSelect,'Value')==1
        Height=str2num(get(handles.HeightRect,'String'));
        Width=str2num(get(handles.WidthRect,'String'));
        HFilter = fspecial('average',[Height Width]);
    elseif get(handles.DiskAverSelect,'Value')==1
        Radius=str2num(get(handles.DiskRadius,'String'));
        HFilter = fspecial('disk', Radius);
    elseif get(handles.GaussAverSelect,'Value')==1
        Height=str2num(get(handles.HeightGauss,'String'));
        Width=str2num(get(handles.WidthGauss,'String'));
        Sigma=str2num(get(handles.SigmaGauss,'String'));
        HFilter = fspecial('gaussian',[Height Width],Sigma);
    end

    % waitbar is consuming too much ressources, so I divide its acces
    dividerWaitbar=10^(floor(log10(SpikeMovieData(MovieToApply).DataSize(3)))-1);
    for i=1:SpikeMovieData(MovieToApply).DataSize(3)
        SpikeMovieData(MovieToApply).Movie(:,:,i)=imfilter(SpikeMovieData(MovieToApply).Movie(:,:,i),HFilter);
        
        if (round(i/dividerWaitbar)==i/dividerWaitbar)
            waitbar(i/SpikeMovieData(MovieToApply).DataSize(3),h);
        end
    end
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


% --- Executes on button press in RectAverSelect.
function RectAverSelect_Callback(hObject, eventdata, handles)
% hObject    handle to RectAverSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RectAverSelect
LocalValue=get(hObject,'Value');
set(handles.DiskAverSelect,'Value',~LocalValue);
set(handles.GaussAverSelect,'Value',~LocalValue);

% --- Executes on button press in DiskAverSelect.
function DiskAverSelect_Callback(hObject, eventdata, handles)
% hObject    handle to DiskAverSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DiskAverSelect
LocalValue=get(hObject,'Value');
set(handles.RectAverSelect,'Value',~LocalValue);
set(handles.GaussAverSelect,'Value',~LocalValue);

% --- Executes on button press in GaussAverSelect.
function GaussAverSelect_Callback(hObject, eventdata, handles)
% hObject    handle to GaussAverSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GaussAverSelect
LocalValue=get(hObject,'Value');
set(handles.DiskAverSelect,'Value',~LocalValue);
set(handles.RectAverSelect,'Value',~LocalValue);

% --- Executes on button press in TestFilter.
function TestFilter_Callback(hObject, eventdata, handles)
% hObject    handle to TestFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;
global SpikeGui;

if ~isempty(SpikeMovieData)
    handles=guidata(gcbo);
    
    if isfield(handles,'hFigImageTest')
        if (isempty(handles.hFigImageTest) || ~ishandle(handles.hFigImageTest))
            handles.hFigImageTest=figure('Name','Filtering Test Image','NumberTitle','off');
        else
            figure(handles.hFigImageTest);
        end
    else
        handles.hFigImageTest=figure('Name','Filtering Test Image','NumberTitle','off');
    end
    
    if (ishandle(SpikeGui.hDataDisplay))
        GlobalColorMap = get(SpikeGui.hDataDisplay,'Colormap');
        set(handles.hFigImageTest,'Colormap',GlobalColorMap)
    end
    
    CurrentMovie=get(handles.MovieSelector,'Value');
    if get(handles.RectAverSelect,'Value')==1
        Height=str2num(get(handles.HeightRect,'String'));
        Width=str2num(get(handles.WidthRect,'String'));
        HFilter = fspecial('average',[Height Width]);
    elseif get(handles.DiskAverSelect,'Value')==1
        Radius=str2num(get(handles.DiskRadius,'String'));
        HFilter = fspecial('disk', Radius);
    elseif get(handles.GaussAverSelect,'Value')==1
        Height=str2num(get(handles.HeightGauss,'String'));
        Width=str2num(get(handles.WidthGauss,'String'));
        Sigma=str2num(get(handles.SigmaGauss,'String'));
        HFilter = fspecial('gaussian',[Height Width],Sigma);
    end
    
    NewPic=imfilter(SpikeMovieData(CurrentMovie).Movie(:,:,str2num(get(handles.FrameNumber,'String'))),HFilter);
    
    imagesc(NewPic);
    guidata(gcbo,handles);
end


function FrameNumber_Callback(hObject, eventdata, handles)
% hObject    handle to FrameNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameNumber as text
%        str2double(get(hObject,'String')) returns contents of FrameNumber as a double
TestFilter_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function FrameNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HeightGauss_Callback(hObject, eventdata, handles)
% hObject    handle to HeightGauss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HeightGauss as text
%        str2double(get(hObject,'String')) returns contents of HeightGauss as a double


% --- Executes during object creation, after setting all properties.
function HeightGauss_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HeightGauss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function WidthGauss_Callback(hObject, eventdata, handles)
% hObject    handle to WidthGauss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WidthGauss as text
%        str2double(get(hObject,'String')) returns contents of WidthGauss as a double


% --- Executes during object creation, after setting all properties.
function WidthGauss_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WidthGauss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SigmaGauss_Callback(hObject, eventdata, handles)
% hObject    handle to SigmaGauss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SigmaGauss as text
%        str2double(get(hObject,'String')) returns contents of SigmaGauss as a double


% --- Executes during object creation, after setting all properties.
function SigmaGauss_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SigmaGauss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DiskRadius_Callback(hObject, eventdata, handles)
% hObject    handle to DiskRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DiskRadius as text
%        str2double(get(hObject,'String')) returns contents of DiskRadius as a double


% --- Executes during object creation, after setting all properties.
function DiskRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DiskRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function WidthRect_Callback(hObject, eventdata, handles)
% hObject    handle to WidthRect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WidthRect as text
%        str2double(get(hObject,'String')) returns contents of WidthRect as a double


% --- Executes during object creation, after setting all properties.
function WidthRect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WidthRect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HeightRect_Callback(hObject, eventdata, handles)
% hObject    handle to HeightRect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HeightRect as text
%        str2double(get(hObject,'String')) returns contents of HeightRect as a double


% --- Executes during object creation, after setting all properties.
function HeightRect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HeightRect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
