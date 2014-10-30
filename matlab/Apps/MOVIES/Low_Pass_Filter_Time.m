function varargout = Low_Pass_Filter_Time(varargin)
% LOW_PASS_FILTER_TIME MATLAB code for Low_Pass_Filter_Time.fig
%      LOW_PASS_FILTER_TIME, by itself, creates a new LOW_PASS_FILTER_TIME or raises the existing
%      singleton*.
%
%      H = LOW_PASS_FILTER_TIME returns the handle to a new LOW_PASS_FILTER_TIME or the handle to
%      the existing singleton*.
%
%      LOW_PASS_FILTER_TIME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOW_PASS_FILTER_TIME.M with the given input arguments.
%
%      LOW_PASS_FILTER_TIME('Property','Value',...) creates a new LOW_PASS_FILTER_TIME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Low_Pass_Filter_Time_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Low_Pass_Filter_Time_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Low_Pass_Filter_Time

% Last Modified by GUIDE v2.5 06-Feb-2012 22:38:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Low_Pass_Filter_Time_OpeningFcn, ...
                   'gui_OutputFcn',  @Low_Pass_Filter_Time_OutputFcn, ...
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


% --- Executes just before Low_Pass_Filter_Time is made visible.
function Low_Pass_Filter_Time_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Low_Pass_Filter_Time (see VARARGIN)

% Choose default command line output for Low_Pass_Filter_Time
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Low_Pass_Filter_Time wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global SpikeMovieData;

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.MovieSelector,'String',Settings.MovieSelectorString);
    set(handles.MovieSelector,'Value',Settings.MovieSelectorValue);
    set(handles.FilterType,'String',Settings.FilterTypeString);
    set(handles.FilterType,'Value',Settings.FilterTypeValue);
    set(handles.FilterCutOff,'String',Settings.FilterCutOffString);
    set(handles.FilterOrder,'String',Settings.FilterOrderString);
    set(handles.UseFiltFilt,'Value',Settings.UseFiltFiltValue);
else
    TextMovie{1}='All Movies';
    if ~isempty(SpikeMovieData)
        for i=1:length(SpikeMovieData)
            TextMovie{i+1}=['Movie ',num2str(i)];
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
Settings.FilterTypeString=get(handles.FilterType,'String');
Settings.FilterTypeValue=get(handles.FilterType,'Value');
Settings.FilterCutOffString=get(handles.FilterCutOff,'String');
Settings.FilterOrderString=get(handles.FilterOrder,'String');
Settings.UseFiltFiltValue=get(handles.UseFiltFilt,'Value');

% --- Outputs from this function are returned to the command line.
function varargout = Low_Pass_Filter_Time_OutputFcn(hObject, eventdata, handles) 
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
    
    if (get(handles.MovieSelector,'Value')==1)
        MovieToApply=1:length(SpikeMovieData);
    else
        MovieToApply=get(handles.MovieSelector,'Value')-1;
    end
    
    for k=MovieToApply
        FrequencySample=1/(SpikeMovieData(k).TimeFrame(2)-SpikeMovieData(k).TimeFrame(1));
        FNyquist=FrequencySample/2;
        
        Order=str2double(get(handles.FilterOrder,'String'));
        CutOff=str2double(get(handles.FilterCutOff,'String'));
        
        Wn=CutOff/FNyquist;
        
        [PassB(:,k),PassA(:,k)] = butter(Order,Wn,'low');
    end
    
    for k=MovieToApply
        % waitbar is consuming too much ressources, so I divide its acces
        dividerWaitbar=10^(floor(log10(SpikeMovieData(k).DataSize(1)))-1);
        OriginalClass=class(SpikeMovieData(k).Movie);
        FiltFilt=get(handles.UseFiltFilt,'Value');

        h=waitbar(0,'Filtering data...');
        
        for i=1:SpikeMovieData(k).DataSize(1)
            for j=1:SpikeMovieData(k).DataSize(2)
                LocalFluo=SpikeMovieData(k).Movie(i,j,:);
                if (FiltFilt==1)
                    ResultFiltered=single(filtfilt(PassB(:,k),PassA(:,k),double(LocalFluo(:))));
                else
                    ResultFiltered=single(filter(PassB(:,k)),PassA(:,k),double(LocalFluo(:)));
                end
                
                % In any case, we want to keep the baseline value the same.
                % We also go back to the original data class
                SpikeMovieData(k).Movie(i,j,:)=cast(ResultFiltered(:),OriginalClass);
            end
            if (round(i/dividerWaitbar)==i/dividerWaitbar)
                waitbar(i/SpikeMovieData(k).DataSize(1),h);
            end
        end
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
