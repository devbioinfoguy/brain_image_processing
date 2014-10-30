function varargout = High_Pass_Filter_Time(varargin)
% HIGH_PASS_FILTER_TIME MATLAB code for High_Pass_Filter_Time.fig
%      HIGH_PASS_FILTER_TIME, by itself, creates a new HIGH_PASS_FILTER_TIME or raises the existing
%      singleton*.
%
%      H = HIGH_PASS_FILTER_TIME returns the handle to a new HIGH_PASS_FILTER_TIME or the handle to
%      the existing singleton*.
%
%      HIGH_PASS_FILTER_TIME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HIGH_PASS_FILTER_TIME.M with the given input arguments.
%
%      HIGH_PASS_FILTER_TIME('Property','Value',...) creates a new HIGH_PASS_FILTER_TIME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before High_Pass_Filter_Time_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to High_Pass_Filter_Time_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help High_Pass_Filter_Time

% Last Modified by GUIDE v2.5 06-Feb-2012 21:41:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @High_Pass_Filter_Time_OpeningFcn, ...
                   'gui_OutputFcn',  @High_Pass_Filter_Time_OutputFcn, ...
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


% --- Executes just before High_Pass_Filter_Time is made visible.
function High_Pass_Filter_Time_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to High_Pass_Filter_Time (see VARARGIN)
global SpikeMovieData;

% Choose default command line output for High_Pass_Filter_Time
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes High_Pass_Filter_Time wait for user response (see UIRESUME)
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
    set(handles.FilterType,'String',Settings.FilterTypeString);
    set(handles.FilterType,'Value',Settings.FilterTypeValue);
    set(handles.FilterCutOff,'String',Settings.FilterCutOffString);
    set(handles.FilterOrder,'String',Settings.FilterOrderString);
    set(handles.UseFiltFilt,'Value',Settings.UseFiltFiltValue);
    set(handles.KeepMean,'Value',Settings.KeepMeanValue);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorString=get(handles.MovieSelector,'String');
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.FilterTypeString=get(handles.FilterType,'String');
Settings.FilterTypeValue=get(handles.FilterType,'Value');
Settings.FilterCutOffString=get(handles.FilterCutOff,'String');
Settings.FilterOrderString=get(handles.FilterOrder,'String');
Settings.UseFiltFiltValue=get(handles.UseFiltFilt,'Value');
Settings.KeepMeanValue=get(handles.KeepMean,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = High_Pass_Filter_Time_OutputFcn(hObject, eventdata, handles) 
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

    MovieToApply=get(handles.MovieSelector,'Value');
    
    FrequencySample=1/(SpikeMovieData(MovieToApply).TimeFrame(2)-SpikeMovieData(MovieToApply).TimeFrame(1));
    FNyquist=double(FrequencySample/2);
    
    Order=str2double(get(handles.FilterOrder,'String'));
    CutOff=str2double(get(handles.FilterCutOff,'String'));
    
    Wn=CutOff/FNyquist;
    
    [PassB,PassA] = butter(Order,Wn,'high');
    
    % waitbar is consuming too much ressources, so I divide its acces
    dividerWaitbar=10^(floor(log10(SpikeMovieData(MovieToApply).DataSize(2)))-1);
    OriginalClass=class(SpikeMovieData(MovieToApply).Movie);
    
    h=waitbar(0,'Filtering data...');
    
    % We close it in the end
    Cleanup2=onCleanup(@()delete(h));
    
    LocalFluo=zeros(1,1,SpikeMovieData(MovieToApply).DataSize(3),'double');
    UseFiltFilt=get(handles.UseFiltFilt,'Value');
    KeepMean=get(handles.KeepMean,'Value');
    for j=1:SpikeMovieData(MovieToApply).DataSize(2)
        for i=1:SpikeMovieData(MovieToApply).DataSize(1)
            LocalFluo=double(SpikeMovieData(MovieToApply).Movie(i,j,:));
            if (UseFiltFilt==1)
                ResultFiltered=filtfilt(PassB,PassA,LocalFluo(:));
            else
                ResultFiltered=filter(PassB,PassA,LocalFluo(:));
            end
            
            if (KeepMean==1)
                MeanBefore=sum(LocalFluo,3)/SpikeMovieData(MovieToApply).DataSize(3);
                MeanResultFiltered=sum(ResultFiltered,1)/SpikeMovieData(MovieToApply).DataSize(3);
                ResultFiltered=ResultFiltered-MeanResultFiltered+MeanBefore;
            end
            
            % In any case, we want to keep the baseline value the same.
            % We also go back to the original data class
            SpikeMovieData(MovieToApply).Movie(i,j,:)=cast(ResultFiltered(:),OriginalClass);
        end
        if (round(j/dividerWaitbar)==j/dividerWaitbar)
            waitbar(j/SpikeMovieData(MovieToApply).DataSize(2),h);
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


% --- Executes on selection change in FilterType.
function FilterType_Callback(hObject, eventdata, handles)
% hObject    handle to FilterType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FilterType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FilterType


% --- Executes during object creation, after setting all properties.
function FilterType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilterType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in UseFiltFilt.
function UseFiltFilt_Callback(hObject, eventdata, handles)
% hObject    handle to UseFiltFilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UseFiltFilt



function FilterOrder_Callback(hObject, eventdata, handles)
% hObject    handle to FilterOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FilterOrder as text
%        str2double(get(hObject,'String')) returns contents of FilterOrder as a double


% --- Executes during object creation, after setting all properties.
function FilterOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilterOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FilterCutOff_Callback(hObject, eventdata, handles)
% hObject    handle to FilterCutOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FilterCutOff as text
%        str2double(get(hObject,'String')) returns contents of FilterCutOff as a double


% --- Executes during object creation, after setting all properties.
function FilterCutOff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilterCutOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in KeepMean.
function KeepMean_Callback(hObject, eventdata, handles)
% hObject    handle to KeepMean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KeepMean
