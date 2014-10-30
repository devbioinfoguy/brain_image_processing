function varargout = Low_High_Filter_Trace_Time(varargin)
% LOW_HIGH_FILTER_TRACE_TIME M-file for Low_High_Filter_Trace_Time.fig
%      LOW_HIGH_FILTER_TRACE_TIME, by itself, creates a new LOW_HIGH_FILTER_TRACE_TIME or raises the existing
%      singleton*.
%
%      H = LOW_HIGH_FILTER_TRACE_TIME returns the handle to a new LOW_HIGH_FILTER_TRACE_TIME or the handle to
%      the existing singleton*.
%
%      LOW_HIGH_FILTER_TRACE_TIME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOW_HIGH_FILTER_TRACE_TIME.M with the given input arguments.
%
%      LOW_HIGH_FILTER_TRACE_TIME('Property','Value',...) creates a new LOW_HIGH_FILTER_TRACE_TIME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Low_High_Filter_Trace_Time_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Low_High_Filter_Trace_Time_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Low_High_Filter_Trace_Time

% Last Modified by GUIDE v2.5 01-Mar-2012 17:51:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Low_High_Filter_Trace_Time_OpeningFcn, ...
                   'gui_OutputFcn',  @Low_High_Filter_Trace_Time_OutputFcn, ...
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


% --- Executes just before Low_High_Filter_Trace_Time is made visible.
function Low_High_Filter_Trace_Time_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Low_High_Filter_Trace_Time (see VARARGIN)

% Choose default command line output for Low_High_Filter_Trace_Time
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Low_High_Filter_Trace_Time wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global SpikeTraceData;

if (length(varargin)>1)
    Settings=varargin{2};
%   set(handles.TraceSelector,'String',Settings.TraceSelectorString);
%   set(handles.TraceSelector,'Value',Settings.TraceSelectorValue);
    set(handles.FilterType,'String',Settings.FilterTypeString);
    set(handles.FilterType,'Value',Settings.FilterTypeValue);
    set(handles.LowCutOff,'String',Settings.LowCutOffString);
    set(handles.HighCutOff,'String',Settings.HighCutOffString);
    set(handles.UseFiltFilt,'Value',Settings.UseFiltFiltValue);

end

TextTrace{1}='All Traces';
if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i+1}=['Trace ',num2str(i)];
    end
    set(handles.TraceSelector,'String',TextTrace);
end


% --- Outputs from this function are returned to the command line.
function varargout = Low_High_Filter_Trace_Time_OutputFcn(hObject, eventdata, handles) 
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
Settings.LowCutOffString=get(handles.LowCutOff,'String');
Settings.HighCutOffString=get(handles.HighCutOff,'String');
Settings.UseFiltFiltValue=get(handles.UseFiltFilt,'Value');


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeTraceData;

if (get(handles.TraceSelector,'Value')==1)
    TracesToApply=1:length(SpikeTraceData);
else
    TracesToApply=get(handles.TraceSelector,'Value')-1;
end

%%%%%%%%%%%%%

LowCutOff=str2double(get(handles.LowCutOff,'String'));
HighCutOff=str2double(get(handles.HighCutOff,'String'));

Order = 2;

FiltBH=zeros(Order+1, length(TracesToApply));
FiltAH=zeros(Order+1, length(TracesToApply));
FiltBL=zeros(Order+1, length(TracesToApply));
FiltAL=zeros(Order+1, length(TracesToApply));

for k=TracesToApply
    FrequencySample=1/(SpikeTraceData(k).XVector(2)-SpikeTraceData(k).XVector(1));
    
%     FNyquist=FrequencySample/2;
%     
%     Wn=FCutOff/FNyquist;
    
    FiltTypeContents=cellstr(get(handles.FilterType, 'String'));
    FiltType=FiltTypeContents{get(handles.FilterType, 'Value')};
    if strcmp(FiltType, 'Butterworth')
        [FiltBH(:,k),FiltAH(:,k)] = butterhigh2(LowCutOff/FrequencySample);  %see end of file for butterhigh2 function
        [FiltBL(:,k),FiltAL(:,k)] = butterlow2(HighCutOff/FrequencySample);  %see end of file for butterlow2 function
    %%%% other filter types not implemented currently
    elseif strcmp(FiltType, 'Chebyshev')
        return;
    elseif strcmp(FiltType, 'Elliptic')
        return;
    end
end

h=waitbar(0,'Filtering traces...');
for k=TracesToApply
    OriginalClass=class(SpikeTraceData(k).Trace);
    
    % highpass filter first 
    if (get(handles.UseFiltFilt,'Value')==1)
        ResultFiltered=single(filtfilt(double(FiltBH(:,k)),double(FiltAH(:,k)),double(SpikeTraceData(k).Trace)));
    else
        ResultFiltered=single(filter(double(FiltBH(:,k)),double(FiltAH(:,k)),double(SpikeTraceData(k).Trace)));
    end
    % In any case, we want to keep the baseline value the same.
    % We also go back to the original data class
    SpikeTraceData(k).Trace(:)=cast(ResultFiltered(:),OriginalClass);
    
    % lowpass filter next
    
        if (get(handles.UseFiltFilt,'Value')==1)
        ResultFiltered=single(filtfilt(double(FiltBL(:,k)),double(FiltAL(:,k)),double(SpikeTraceData(k).Trace)));
    else
        ResultFiltered=single(filter(double(FiltBL(:,k)),double(FiltAL(:,k)),double(SpikeTraceData(k).Trace)));
    end
    % In any case, we want to keep the baseline value the same.
    % We also go back to the original data class
    SpikeTraceData(k).Trace(:)=cast(ResultFiltered(:),OriginalClass);
   
    waitbar(k/length(TracesToApply));
end
close(h);
uiresume;


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





function LowCutOff_Callback(hObject, eventdata, handles)
% hObject    handle to LowCutOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LowCutOff as text
%        str2double(get(hObject,'String')) returns contents of LowCutOff as a double


% --- Executes during object creation, after setting all properties.
function LowCutOff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LowCutOff (see GCBO)
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



function HighCutOff_Callback(hObject, eventdata, handles)
% hObject    handle to HighCutOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HighCutOff as text
%        str2double(get(hObject,'String')) returns contents of HighCutOff as a double


% --- Executes during object creation, after setting all properties.
function HighCutOff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HighCutOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%
function [b,a]=butterhigh2(f)
% [b,a] = BUTTERHIGH2(wn) creates a second order high-pass Butterworth filter
% with cutoff at WN. (WN=1 corresponds to the sample frequency, not half!)
% 
% Filter coefficients lifted from http://www.apicsllc.com/apics/Sr_3/Sr_3.htm
% by Brian T. Boulter

c = cot(f*pi);

n0=c^2; 
n1=-2*c^2;
n2=c^2;
d0=c^2+sqrt(2)*c+1;
d1=-2*(c^2-1);
d2=c^2-sqrt(2)*c+1;

a=[1 d1/d0 d2/d0];
b=[n0/d0 n1/d0 n2/d0];

function [b,a]=butterlow2(f)
% [b,a] = BUTTERLOW2(wn) creates a second order low-pass Butterworth filter
% with cutoff at WN. (WN=1 corresponds to the sample frequency, not half!)
% 
% Filter coefficients lifted from http://www.apicsllc.com/apics/Sr_3/Sr_3.htm
% by Brian T. Boulter

c = cot(f*pi);

n0=1;
n1=2;
n2=1;
d0=c^2+sqrt(2)*c+1;
d1=-2*(c^2-1);
d2=c^2-sqrt(2)*c+1;

a=[1 d1/d0 d2/d0];
b=[n0/d0 n1/d0 n2/d0];
