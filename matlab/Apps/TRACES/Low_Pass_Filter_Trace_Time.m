function varargout = Low_Pass_Filter_Trace_Time(varargin)
% LOW_PASS_FILTER_TRACE_TIME M-file for Low_Pass_Filter_Trace_Time.fig
%      LOW_PASS_FILTER_TRACE_TIME, by itself, creates a new LOW_PASS_FILTER_TRACE_TIME or raises the existing
%      singleton*.
%
%      H = LOW_PASS_FILTER_TRACE_TIME returns the handle to a new LOW_PASS_FILTER_TRACE_TIME or the handle to
%      the existing singleton*.
%
%      LOW_PASS_FILTER_TRACE_TIME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOW_PASS_FILTER_TRACE_TIME.M with the given input arguments.
%
%      LOW_PASS_FILTER_TRACE_TIME('Property','Value',...) creates a new LOW_PASS_FILTER_TRACE_TIME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Low_Pass_Filter_Trace_Time_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Low_Pass_Filter_Trace_Time_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Low_Pass_Filter_Trace_Time

% Last Modified by GUIDE v2.5 06-Feb-2012 21:32:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Low_Pass_Filter_Trace_Time_OpeningFcn, ...
                   'gui_OutputFcn',  @Low_Pass_Filter_Trace_Time_OutputFcn, ...
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


% --- Executes just before Low_Pass_Filter_Trace_Time is made visible.
function Low_Pass_Filter_Trace_Time_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Low_Pass_Filter_Trace_Time (see VARARGIN)
global SpikeTraceData;

% Choose default command line output for Low_Pass_Filter_Trace_Time
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Low_Pass_Filter_Trace_Time wait for user response (see UIRESUME)
% uiwait(handles.figure1);
NumberTraces=length(SpikeTraceData);

if ~isempty(SpikeTraceData)
    TextTrace{1}='All Traces';

    for i=1:length(SpikeTraceData)
        TextTrace{i+1}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.TraceSelector,'String',TextTrace);
end
    
if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.TraceSelector,'Value',intersect(1:NumberTraces,Settings.TraceSelectorValue));
    set(handles.FilterType,'String',Settings.FilterTypeString);
    set(handles.FilterType,'Value',Settings.FilterTypeValue);
    set(handles.FilterCutOff,'String',Settings.FilterCutOffString);
    set(handles.FilterOrder,'String',Settings.FilterOrderString);
    set(handles.UseFiltFilt,'Value',Settings.UseFiltFiltValue);
end


% --- Outputs from this function are returned to the command line.
function varargout = Low_Pass_Filter_Trace_Time_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorString=get(handles.TraceSelector,'String');
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');
Settings.FilterTypeString=get(handles.FilterType,'String');
Settings.FilterTypeValue=get(handles.FilterType,'Value');
Settings.FilterCutOffString=get(handles.FilterCutOff,'String');
Settings.FilterOrderString=get(handles.FilterOrder,'String');
Settings.UseFiltFiltValue=get(handles.UseFiltFilt,'Value');


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeTraceData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    if (get(handles.TraceSelector,'Value')==1)
        TracesToApply=1:length(SpikeTraceData);
    else
        TracesToApply=get(handles.TraceSelector,'Value')-1;
    end
    
    h=waitbar(0,'Filtering traces...');

    Order=str2num(get(handles.FilterOrder,'String'));
    FCutOff=str2double(get(handles.FilterCutOff,'String'));
    
    FiltB=zeros(Order+1, length(TracesToApply));
    FiltA=zeros(Order+1, length(TracesToApply));
    
    for k=TracesToApply
        FrequencySample=1/(SpikeTraceData(k).XVector(2)-SpikeTraceData(k).XVector(1));
        FNyquist=FrequencySample/2;
        
        Wn=FCutOff/FNyquist;
        if Wn>1
            error('Cutoff frequency cannot be greater than half the sampling frequency!')
        end
        
        FiltTypeContents=cellstr(get(handles.FilterType, 'String'));
        FiltType=FiltTypeContents{get(handles.FilterType, 'Value')};
        if strcmp(FiltType, 'Butterworth')
            [FiltB(:,k),FiltA(:,k)] = butter(Order,Wn,'low');
            %%%% Cannot currently set ripple for chebyshev and elliptic filter
            %%%% types, and these set values are somewhat arbitrary.
        elseif strcmp(FiltType, 'Chebyshev')
            [FiltB(:,k),FiltA(:,k)] = cheby1(Order,0.5,Wn);
        elseif strcmp(FiltType, 'Elliptic')
            [FiltB(:,k),FiltA(:,k)] = ellip(Order,1,50,Wn);
        end
    end
    
    for k=TracesToApply
        OriginalClass=class(SpikeTraceData(k).Trace);
        
        if (get(handles.UseFiltFilt,'Value')==1)
            ResultFiltered=single(filtfilt(double(FiltB(:,k)),double(FiltA(:,k)),double(SpikeTraceData(k).Trace)));
        else
            ResultFiltered=single(filter(double(FiltB(:,k)),double(FiltA(:,k)),double(SpikeTraceData(k).Trace)));
        end
        
        % In any case, we want to keep the baseline value the same.
        % We also go back to the original data class
        SpikeTraceData(k).Trace(:)=cast(ResultFiltered(:),OriginalClass);
        waitbar(k/length(TracesToApply));
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


% --- Executes on button press in ValidateValues.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;


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


% --- Executes on selection change in TraceSelector.
function TraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to TraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TraceSelector


% --- Executes during object creation, after setting all properties.
function TraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
