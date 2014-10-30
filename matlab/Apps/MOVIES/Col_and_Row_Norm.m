function varargout = Col_and_Row_Norm(varargin)
% COL_AND_ROW_NORM MATLAB code for Col_and_Row_Norm.fig
%      COL_AND_ROW_NORM, by itself, creates a new COL_AND_ROW_NORM or raises the existing
%      singleton*.
%
%      H = COL_AND_ROW_NORM returns the handle to a new COL_AND_ROW_NORM or the handle to
%      the existing singleton*.
%
%      COL_AND_ROW_NORM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COL_AND_ROW_NORM.M with the given input arguments.
%
%      COL_AND_ROW_NORM('Property','Value',...) creates a new COL_AND_ROW_NORM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Col_and_Row_Norm_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Col_and_Row_Norm_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Col_and_Row_Norm

% Last Modified by GUIDE v2.5 05-Mar-2012 00:11:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Col_and_Row_Norm_OpeningFcn, ...
                   'gui_OutputFcn',  @Col_and_Row_Norm_OutputFcn, ...
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


% --- Executes just before Col_and_Row_Norm is made visible.
function Col_and_Row_Norm_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Col_and_Row_Norm (see VARARGIN)
global SpikeMovieData;

% Choose default command line output for Offset_Time_Movie
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Offset_Time_Movie wait for user response (see UIRESUME)
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
end
    

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.MovieSelectorString=get(handles.MovieSelector,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Col_and_Row_Norm_OutputFcn(hObject, eventdata, handles) 
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

    h=waitbar(0,'Normalising movie...');
    % We close it in the end
    Cleanup2=onCleanup(@()delete(h));
    
    MovieSel=get(handles.MovieSelector,'Value');
    
    dividerWaitbar=10^(floor(log10(SpikeMovieData(MovieSel).DataSize(3)))-1);
    
    LocalClass=class(SpikeMovieData(MovieSel).Movie);
    if strcmp(LocalClass,'single') || strcmp(LocalClass,'double')
        MaxValue=1/2;
    else
        MaxValue=intmax(LocalClass)/2;
    end
    
    for i=1:SpikeMovieData(MovieSel).DataSize(3)
        data=SpikeMovieData(MovieSel).Movie(:,:,i);
        meanRows = single(repmat(mean(data,1),size(data,1),1));
        meanCols = single(repmat(mean(data,2),1,size(data,2)));
        meanRows = meanRows.*meanCols/mean(meanCols(floor(size(data,2)/2),:));
        
        SpikeMovieData(MovieSel).Movie(:,:,i)=cast(single(MaxValue)*single(data)./meanRows,LocalClass);
        if (round(i/dividerWaitbar)==i/dividerWaitbar)
            waitbar(i/SpikeMovieData(MovieSel).DataSize(3),h);
        end
    end
    
    ValidateValues_Callback(hObject, eventdata, handles);
    
catch errorObj
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


% --- Executes during object creation, after setting all properties.
function ValidateValues_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
