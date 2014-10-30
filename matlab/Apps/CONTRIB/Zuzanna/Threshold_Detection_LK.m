function varargout = Threshold_Detection_LK(varargin)
% THRESHOLD_DETECTION_LK M-file for Threshold_Detection_LK.fig
%      THRESHOLD_DETECTION_LK, by itself, creates a new THRESHOLD_DETECTION_LK or raises the existing
%      singleton*.
%
%      H = THRESHOLD_DETECTION_LK returns the handle to a new THRESHOLD_DETECTION_LK or the handle to
%      the existing singleton*.
%
%      THRESHOLD_DETECTION_LK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in THRESHOLD_DETECTION_LK.M with the given input arguments.
%
%      THRESHOLD_DETECTION_LK('Property','Value',...) creates a new THRESHOLD_DETECTION_LK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Threshold_Detection_LK_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Threshold_Detection_LK_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Threshold_Detection_LK

% Last Modified by GUIDE v2.5 06-Apr-2012 15:03:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Threshold_Detection_LK_OpeningFcn, ...
                   'gui_OutputFcn',  @Threshold_Detection_LK_OutputFcn, ...
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


% --- Executes just before Threshold_Detection_LK is made visible.
function Threshold_Detection_LK_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Threshold_Detection_LK (see VARARGIN)

% Choose default command line output for Threshold_Detection_LK
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Threshold_Detection_LK wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global SpikeTraceData;


if (length(varargin)>1)
    Settings=varargin{2};
    %     set(handles.TraceSelector,'String',Settings.TraceSelectorString);
%     set(handles.TraceSelector,'Value',Settings.TraceSelectorValue);
    set(handles.CrossType,'String',Settings.CrossTypeString);
    set(handles.CrossType,'Value',Settings.CrossTypeValue);
    set(handles.Threshold,'String',Settings.ThresholdString);
       
end

TextTrace{1}='All Traces';
if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i+1}=['Trace ',num2str(i)];
    end
    set(handles.TraceSelector,'String',TextTrace);
end


% --- Outputs from this function are returned to the command line.
function varargout = Threshold_Detection_LK_OutputFcn(hObject, eventdata, handles) 
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
Settings.CrossTypeString=get(handles.CrossType,'String');
Settings.CrossTypeValue=get(handles.CrossType,'Value');
Settings.ThresholdString=get(handles.Threshold,'String');



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
if get(handles.UseQQthresh, 'Value')
    thresh=median(abs(double(SpikeTraceData(TracesToApply(1)).Trace))/0.6745)
else
    thresh=str2double(get(handles.Threshold,'String'));
end
CrossTypeContents=cellstr(get(handles.CrossType, 'String'));
CrossType=CrossTypeContents{get(handles.CrossType, 'Value')};

 if strcmp(CrossType, 'low-to-high')
 lowhigh=1;
 elseif strcmp(CrossType, 'high-to-low')       
 lowhigh=0;       
 end
 
BeginTrace=length(SpikeTraceData)+1;
n=0; %new trace counter

h=waitbar(0,'Detecting crossings...');
for k=TracesToApply

times=Thresh_Cross(SpikeTraceData(k).Trace,SpikeTraceData(k).XVector,thresh,lowhigh,handles);

SpikeTraceData(BeginTrace+n).XVector=times;
SpikeTraceData(BeginTrace+n).Trace=ones(size(times));
SpikeTraceData(BeginTrace+n).DataSize=length(times);

name='threshold crossings';
SpikeTraceData(BeginTrace+n).Label.ListText=name;
SpikeTraceData(BeginTrace+n).Label.YLabel='detections';
SpikeTraceData(BeginTrace+n).Label.XLabel=SpikeTraceData(k).Label.XLabel;
SpikeTraceData(BeginTrace+n).Filename=SpikeTraceData(k).Filename;
SpikeTraceData(BeginTrace+n).Path=SpikeTraceData(k).Path;
SpikeTraceData(BeginTrace+n).OriginalMovie=SpikeTraceData(k).OriginalMovie;

end
close(h);
ValidateValues_Callback(hObject, eventdata, handles);


% this function does the big job, ie detecting threshold crossings in a trace,
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
      
    jump = 0.0005; %minimal interval between 2 pts of th such that these 2 pts belong to 2 diff. thresh crossings
    % in principle any time > sampling period should work, here is chosen
    % to be 0.5 ms
    
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



function Threshold_Callback(hObject, eventdata, handles)
% hObject    handle to Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Threshold as text
%        str2double(get(hObject,'String')) returns contents of Threshold as a double


% --- Executes during object creation, after setting all properties.
function Threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CrossType.
function CrossType_Callback(hObject, eventdata, handles)
% hObject    handle to CrossType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CrossType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CrossType



% --- Executes during object creation, after setting all properties.
function CrossType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CrossType (see GCBO)
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






% --- Executes on button press in UseQQthresh.
function UseQQthresh_Callback(hObject, eventdata, handles)
% hObject    handle to UseQQthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UseQQthresh


% --- Executes on button press in SaveSnippets.
function SaveSnippets_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSnippets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SaveSnippets
