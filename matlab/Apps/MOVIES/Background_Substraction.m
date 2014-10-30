function varargout = Background_Substraction(varargin)
% BACKGROUND_SUBSTRACTION MATLAB code for Background_Substraction.fig
%      BACKGROUND_SUBSTRACTION, by itself, creates a new BACKGROUND_SUBSTRACTION or raises the existing
%      singleton*.
%
%      H = BACKGROUND_SUBSTRACTION returns the handle to a new BACKGROUND_SUBSTRACTION or the handle to
%      the existing singleton*.
%
%      BACKGROUND_SUBSTRACTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BACKGROUND_SUBSTRACTION.M with the given input arguments.
%
%      BACKGROUND_SUBSTRACTION('Property','Value',...) creates a new BACKGROUND_SUBSTRACTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Background_Substraction_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Background_Substraction_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Background_Substraction

% Last Modified by GUIDE v2.5 06-Feb-2012 21:35:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Background_Substraction_OpeningFcn, ...
                   'gui_OutputFcn',  @Background_Substraction_OutputFcn, ...
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


% --- Executes just before Background_Substraction is made visible.
function Background_Substraction_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Background_Substraction (see VARARGIN)

% Choose default command line output for Background_Substraction
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Background_Substraction wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global SpikeMovieData;

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.MovieSelector,'Value',Settings.MovieSelectorValue);
    set(handles.MovieSelector,'String',Settings.MovieSelectorString);
    set(handles.SelectFullFrameMean,'Value',Settings.SelectFullFrameMeanValue);
    set(handles.SelectDiskAverage,'Value',Settings.SelectDiskAverageValue);
    set(handles.DiskRadius,'String',Settings.DiskRadiusString);
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
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.MovieSelectorString=get(handles.MovieSelector,'String');
Settings.SelectFullFrameMeanValue=get(handles.SelectFullFrameMean,'Value');
Settings.SelectDiskAverageValue=get(handles.SelectDiskAverage,'Value');
Settings.DiskRadiusString=get(handles.DiskRadius,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Background_Substraction_OutputFcn(hObject, eventdata, handles) 
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
    
    h=waitbar(0,'Substracting background...');
    
    MovieSel=get(handles.MovieSelector,'Value');
    
    dividerWaitbar=10^(floor(log10(SpikeMovieData(MovieSel).DataSize(3)))-1);
    SpikeMovieData(MovieSel).Movie=single(SpikeMovieData(MovieSel).Movie);
    
    for i=1:SpikeMovieData(MovieSel).DataSize(3)
        data=SpikeMovieData(MovieSel).Movie(:,:,i);
        Radius=str2num(get(handles.DiskRadius,'String'));
        LocalPick=SpikeMovieData(MovieSel).Movie(:,:,i);
        switch get(handles.SelectFullFrameMean,'Value')
            case 1
                PicBack=mean(LocalPick(:))*ones(size(LocalPick));
            case 0
                HFilter = fspecial('disk', Radius);
                PicBack=imfilter(LocalPick, HFilter);
        end
        
        SpikeMovieData(MovieSel).Movie(:,:,i)=SpikeMovieData(MovieSel).Movie(:,:,i)./PicBack;
        if (round(i/dividerWaitbar)==i/dividerWaitbar)
            waitbar(i/SpikeMovieData(MovieSel).DataSize(3),h);
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


% --- Executes during object creation, after setting all properties.
function ValidateValues_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


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
