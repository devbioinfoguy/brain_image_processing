function varargout = Analyze_PSTH_pause(varargin)
% ANALYZE_PSTH_PAUSE M-file for Analyze_PSTH_pause.fig
%      ANALYZE_PSTH_PAUSE, by itself, creates a new ANALYZE_PSTH_PAUSE or raises the existing
%      singleton*.
%
%      H = ANALYZE_PSTH_PAUSE returns the handle to a new ANALYZE_PSTH_PAUSE or the handle to
%      the existing singleton*.
%
%      ANALYZE_PSTH_PAUSE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALYZE_PSTH_PAUSE.M with the given input arguments.
%
%      ANALYZE_PSTH_PAUSE('Property','Value',...) creates a new ANALYZE_PSTH_PAUSE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Analyze_PSTH_pause_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Analyze_PSTH_pause_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Analyze_PSTH_pause

% Last Modified by GUIDE v2.5 07-Aug-2012 21:11:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Analyze_PSTH_pause_OpeningFcn, ...
                   'gui_OutputFcn',  @Analyze_PSTH_pause_OutputFcn, ...
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


% --- Executes just before Analyze_PSTH_pause is made visible.
function Analyze_PSTH_pause_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Analyze_PSTH_pause (see VARARGIN)

% Choose default command line output for Analyze_PSTH_pause
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Analyze_PSTH_pause wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global SpikeTraceData;


if (length(varargin)>1)
    Settings=varargin{2};
    %     set(handles.TraceSelector,'String',Settings.TraceSelectorString);
%     set(handles.TraceSelector,'Value',Settings.TraceSelectorValue);
    set(handles.CrossType1,'String',Settings.CrossType1String);
    set(handles.CrossType1,'Value',Settings.CrossType1Value);
    set(handles.Threshold1,'String',Settings.Threshold1String);
    set(handles.CrossType2,'String',Settings.CrossType2String);
    set(handles.CrossType2,'Value',Settings.CrossType2Value);
    set(handles.Threshold2,'String',Settings.Threshold2String);
    set(handles.StartBin,'String',Settings.StartBinString);
    set(handles.StopBin,'String',Settings.StopBinString);
       
end

TextTrace{1}='All Traces';
if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i+1}=['Trace ',num2str(i)];
    end
    set(handles.TraceSelector,'String',TextTrace);
end


% --- Outputs from this function are returned to the command line.
function varargout = Analyze_PSTH_pause_OutputFcn(hObject, eventdata, handles) 
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
Settings.CrossType1String=get(handles.CrossType1,'String');
Settings.CrossType1Value=get(handles.CrossType1,'Value');
Settings.Threshold1String=get(handles.Threshold1,'String');
Settings.CrossType2String=get(handles.CrossType2,'String');
Settings.CrossType2Value=get(handles.CrossType2,'Value');
Settings.Threshold2String=get(handles.Threshold2,'String');
Settings.StartBinString=get(handles.StartBin,'String'); 
Settings.StopBinString=get(handles.StopBin,'String');

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

thresh1=str2double(get(handles.Threshold1,'String'));
CrossType1Contents=cellstr(get(handles.CrossType1, 'String'));
CrossType1=CrossType1Contents{get(handles.CrossType1, 'Value')};

thresh2=str2double(get(handles.Threshold2,'String'));
CrossType2Contents=cellstr(get(handles.CrossType2, 'String'));
CrossType2=CrossType2Contents{get(handles.CrossType2, 'Value')};

if strcmp(CrossType1, 'low-to-high')
    lowhigh1=1;
elseif strcmp(CrossType1, 'high-to-low')
    lowhigh1=0;
end

if strcmp(CrossType2, 'low-to-high')
    lowhigh2=1;
elseif strcmp(CrossType2, 'high-to-low')
    lowhigh2=0;
end
 
 lowhigh1
  lowhigh2

BeginTrace=length(SpikeTraceData)+1;
n=0; %new trace counter

h=waitbar(0,'Detecting crossings...');
for k=TracesToApply

times1=Thresh_Cross(SpikeTraceData(k).Trace,SpikeTraceData(k).XVector',thresh1,lowhigh1,handles);
times2=Thresh_Cross(SpikeTraceData(k).Trace,SpikeTraceData(k).XVector',thresh2,lowhigh2,handles);

SpikeTraceData(BeginTrace+n).XVector=times1;
SpikeTraceData(BeginTrace+n).Trace=ones(size(times1));
SpikeTraceData(BeginTrace+n).DataSize=length(times1);

name='PSTH threshold 1 crossings';
SpikeTraceData(BeginTrace+n).Label.ListText=name;
SpikeTraceData(BeginTrace+n).Label.YLabel='detections';
SpikeTraceData(BeginTrace+n).Label.XLabel=SpikeTraceData(k).Label.XLabel;
SpikeTraceData(BeginTrace+n).Filename=SpikeTraceData(k).Filename;
SpikeTraceData(BeginTrace+n).Path=SpikeTraceData(k).Path;

n=n+1;

SpikeTraceData(BeginTrace+n).XVector=times2;
SpikeTraceData(BeginTrace+n).Trace=ones(size(times2));
SpikeTraceData(BeginTrace+n).DataSize=length(times2);

name='PSTH threshold 2 crossings';
SpikeTraceData(BeginTrace+n).Label.ListText=name;
SpikeTraceData(BeginTrace+n).Label.YLabel='detections';
SpikeTraceData(BeginTrace+n).Label.XLabel=SpikeTraceData(k).Label.XLabel;
SpikeTraceData(BeginTrace+n).Filename=SpikeTraceData(k).Filename;
SpikeTraceData(BeginTrace+n).Path=SpikeTraceData(k).Path;

n=n+1;
waitbar(k/length(TracesToApply));
 
end

close(h);

set(handles.Dur_Crossings,'String',int2str(SpikeTraceData(BeginTrace+n-1).DataSize));

% ValidateValues_Callback(hObject, eventdata, handles);


% this function does the big job, ie detecting threshold1 crossings in a trace,
% and creating a new trace (times) holding spike times 

function times=Thresh_Cross(trace,timepts,thresh,lowhigh,handles)

m2=[timepts trace];

if lowhigh==1
    %low-to-high threshold crossings
    th = m2((m2(:,2)>thresh),1); %get all times (from m2(:,1)) when signal in m2 (m2(:,2)) is ABOVE threshold thresh
elseif lowhigh==0
    %high-to-low threshold crossings
    th = m2((m2(:,2)<thresh),1); %get all times (from m2(:,1)) when signal in m2 (m2(:,2)) is BELOW threshold thresh
end
      
    jump = 1; %minimal interval between 2 pts of th such that these 2 pts belong to 2 diff. thresh crossings
   
    
    if size(th)>0
        th_shift = th(2:size(th),1); % th shifted 1 point to the left
        th_shift(size(th),1)=th(size(th),1); % duplicate last point of th to have same lenth vectors (assumes no threshold crossing on last datapoint;
        % such event could never be confirmed to be a spike anyway )
        
        th_m = [th th_shift];
        
        times = th_m(((th_m(:,2)-th_m(:,1))>jump),2); %threshold crossing times("jumps" in th)
        
        times(size(times,1)+1,1) = th(1,1); % the first threshold crossing time is necessarily a spike onset
        
        times = sort(times);
       
    else
        times=[];
   
end



% --- Executes on button press in ValidateValues.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;



function Threshold1_Callback(hObject, eventdata, handles)
% hObject    handle to Threshold1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Threshold1 as text
%        str2double(get(hObject,'String')) returns contents of Threshold1 as a double


% --- Executes during object creation, after setting all properties.
function Threshold1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Threshold1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CrossType1.
function CrossType1_Callback(hObject, eventdata, handles)
% hObject    handle to CrossType1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CrossType1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CrossType1



% --- Executes during object creation, after setting all properties.
function CrossType1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CrossType1 (see GCBO)
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


function Dur_Crossings_Callback(hObject, eventdata, handles)
% hObject    handle to Dur_Crossings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Dur_Crossings as text
%        str2double(get(hObject,'String')) returns contents of Dur_Crossings as a double


% --- Executes during object creation, after setting all properties.
function Dur_Crossings_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dur_Crossings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Threshold2_Callback(hObject, eventdata, handles)
% hObject    handle to Threshold2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Threshold2 as text
%        str2double(get(hObject,'String')) returns contents of Threshold2 as a double


% --- Executes during object creation, after setting all properties.
function Threshold2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Threshold2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CrossType2.
function CrossType2_Callback(hObject, eventdata, handles)
% hObject    handle to CrossType2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CrossType2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CrossType2


% --- Executes during object creation, after setting all properties.
function CrossType2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CrossType2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StartBin_Callback(hObject, eventdata, handles)
% hObject    handle to StartBin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartBin as text
%        str2double(get(hObject,'String')) returns contents of StartBin as a double


% --- Executes during object creation, after setting all properties.
function StartBin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartBin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StopBin_Callback(hObject, eventdata, handles)
% hObject    handle to StopBin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StopBin as text
%        str2double(get(hObject,'String')) returns contents of StopBin as a double


% --- Executes during object creation, after setting all properties.
function StopBin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StopBin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
