function varargout = Load_Analyze_Ephys_DataWave(varargin)
% LOAD_ANALYZE_EPHYS_DATAWAVE MATLAB code for Load_Analyze_Ephys_DataWave.fig
%      LOAD_ANALYZE_EPHYS_DATAWAVE, by itself, creates a new LOAD_ANALYZE_EPHYS_DATAWAVE or raises the existing
%      singleton*.
%
%      H = LOAD_ANALYZE_EPHYS_DATAWAVE returns the handle to a new LOAD_ANALYZE_EPHYS_DATAWAVE or the handle to
%      the existing singleton*.
%
%      LOAD_ANALYZE_EPHYS_DATAWAVE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOAD_ANALYZE_EPHYS_DATAWAVE.M with the given input arguments.
%
%      LOAD_ANALYZE_EPHYS_DATAWAVE('Property','Value',...) creates a new LOAD_ANALYZE_EPHYS_DATAWAVE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Load_Analyze_Ephys_DataWave_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Load_Analyze_Ephys_DataWave_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Load_Analyze_Ephys_DataWave

% Last Modified by GUIDE v2.5 30-May-2012 16:35:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Load_Analyze_Ephys_DataWave_OpeningFcn, ...
    'gui_OutputFcn',  @Load_Analyze_Ephys_DataWave_OutputFcn, ...
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


% --- Executes just before Load_Analyze_Ephys_DataWave is made visible.
function Load_Analyze_Ephys_DataWave_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Load_Analyze_Ephys_DataWave (see VARARGIN)

% Choose default command line output for Load_Analyze_Ephys_DataWave
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Load_Analyze_Ephys_DataWave wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.FilenameShow,'String',Settings.FilenameShowString);
    set(handles.StartEp,'String',Settings.StartEpString);
    set(handles.EndEp,'String',Settings.EndEpString);
    set(handles.ChanNb,'String',Settings.ChanNbString);
    set(handles.HeaderLines,'String',Settings.HeaderLinesString);
    set(handles.TimeUnit,'String',Settings.TimeUnitString);
    set(handles.LoadBehSelect,'Value',Settings.LoadBehSelectValue);
    set(handles.Threshold2,'String',Settings.Threshold2String);
    set(handles.CrossType2, 'String',Settings.CrossType2String);
    set(handles.Threshold2,'String',Settings.Threshold1String);
    set(handles.CrossType2, 'String',Settings.CrossType1String);
    set(handles.MinISI2,'String',Settings.MinISI2String);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.FilenameShowString=get(handles.FilenameShow,'String');
Settings.StartEpString=get(handles.StartEp,'String');
Settings.EndEpString=get(handles.EndEp,'String');
Settings.ChanNbString=get(handles.ChanNb,'String');
Settings.HeaderLinesString=get(handles.HeaderLines,'String');
Settings.TimeUnitString=get(handles.TimeUnit,'String');
Settings.LoadBehSelectValue=get(handles.LoadBehSelect,'Value');
Settings.Threshold2String=get(handles.Threshold2,'String');
Settings.CrossType2String=get(handles.CrossType2, 'String');
Settings.Threshold1String=get(handles.Threshold2,'String');
Settings.CrossType1String=get(handles.CrossType2, 'String');
Settings.MinISI2String=get(handles.MinISI2,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Load_Analyze_Ephys_DataWave_OutputFcn(hObject, eventdata, handles)
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
global SpikeTraceData;

if (1==get(handles.LoadBehSelect,'Value'))
    InitTraces();
    BeginTrace=1;
else
    BeginTrace=length(SpikeTraceData)+1;
end

[pathstr, name, ext] = fileparts(get(handles.FilenameShow,'String'));

SpikeTraceData(BeginTrace).Path=pathstr;
SpikeTraceData(BeginTrace).Filename=[name ext];

EphysLoader_Datawave(BeginTrace,handles);

%stitching:
BeginTrace=length(SpikeTraceData)+1;
TracesToApply=1:2:length(SpikeTraceData)-1; %stitch uneven traces (=voltage signal channel) 
Stitch(BeginTrace,TracesToApply,handles);

BeginTrace=length(SpikeTraceData)+1;
TracesToApply=2:2:length(SpikeTraceData)-1; %stitch even traces (=photodiode stim channel) 
Stitch(BeginTrace,TracesToApply,handles);

%removing unstitched episodes:
    h=waitbar(0,'Removing traces...');
    NumberTraces=length(SpikeTraceData);
    SpikeTraceData=SpikeTraceData([NumberTraces-1:NumberTraces]); % keep pnly last 2 traces, ie the stitched ones    
    delete(h);
    
 %filtering Trace 1 (voltage):
 Filter(1,500,10000,handles);
 
 %detecting threshold crossings on Trace 1 (voltage):
 
thresh=str2double(get(handles.Threshold1,'String'));
CrossTypeContents=cellstr(get(handles.CrossType1, 'String'));
CrossType=CrossTypeContents{get(handles.CrossType1, 'Value')};

 if strcmp(CrossType, 'low-to-high')
 lowhigh=1;
 elseif strcmp(CrossType, 'high-to-low')       
 lowhigh=0;       
 end
 
BeginTrace=length(SpikeTraceData)+1;
n=0; %new trace counter

h=waitbar(0,'Detecting crossings...');
for k=1

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

n=n+1;
waitbar(k/length(TracesToApply));
 
end

close(h);

set(handles.Nb_Crossings1,'String',int2str(SpikeTraceData(BeginTrace+n-1).DataSize));
 
 %detecting threshold crossings on Trace 2 (stimulation):
 
 thresh=str2double(get(handles.Threshold2,'String'));
CrossTypeContents=cellstr(get(handles.CrossType2, 'String'));
CrossType=CrossTypeContents{get(handles.CrossType2, 'Value')};

 if strcmp(CrossType, 'low-to-high')
 lowhigh=1;
 elseif strcmp(CrossType, 'high-to-low')       
 lowhigh=0;       
 end
 
BeginTrace=length(SpikeTraceData)+1;
n=0; %new trace counter

h=waitbar(0,'Detecting crossings...');
for k=2

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

n=n+1;
waitbar(k/length(TracesToApply));
 
end

close(h);

set(handles.Nb_Crossings2,'String',int2str(SpikeTraceData(BeginTrace+n-1).DataSize));

% removing short ISIs from detections from Trace 2 (ie from Trace 4):

min_isi=str2double(get(handles.MinISI2,'String'))/1000 %convert from ms to s
 
BeginTrace=length(SpikeTraceData)+1;
n=0; %new trace counter

h=waitbar(0,'Cutting short ISIs...');
for k=4
    
    [times_def, times_bursts] = cutshortisis(SpikeTraceData(k).XVector,min_isi, handles);
    
    SpikeTraceData(BeginTrace+n).XVector=times_def;
    SpikeTraceData(BeginTrace+n).Trace=ones(size(times_def));
    SpikeTraceData(BeginTrace+n).DataSize=length(times_def);
    
    name='threshold crossings, min isis only';
    SpikeTraceData(BeginTrace+n).Label.ListText=name;
    SpikeTraceData(BeginTrace+n).Label.YLabel='detections';
    SpikeTraceData(BeginTrace+n).Label.XLabel=SpikeTraceData(k).Label.XLabel;
    SpikeTraceData(BeginTrace+n).Filename=SpikeTraceData(k).Filename;
    SpikeTraceData(BeginTrace+n).Path=SpikeTraceData(k).Path;
    
    n=n+1;
    
    waitbar(k/length(TracesToApply));
    
end

close(h);

set(handles.Nb_Crossings3,'String',int2str(SpikeTraceData(BeginTrace+n-1).DataSize));

%digitizing the vectors of detection times, ie Trace 3 (spikes) and Trace 5
%(stims, with short ISIs cut)

binsize=str2double(get(handles.Binsize,'String'))/1000; %convert binsize to sec

 
BeginTrace=length(SpikeTraceData)+1;
n=0; %new trace counter

h=waitbar(0,'Digitizing...');
for k=[3 5]

binned_events=Digitize(SpikeTraceData(k).XVector,binsize,handles);

SpikeTraceData(BeginTrace+n).XVector=0:binsize:binsize*(length(binned_events)-1);
SpikeTraceData(BeginTrace+n).Trace=binned_events;
SpikeTraceData(BeginTrace+n).DataSize=length(binned_events);

name='binned events';
SpikeTraceData(BeginTrace+n).Label.ListText=name;
SpikeTraceData(BeginTrace+n).Label.YLabel='nb of events';
SpikeTraceData(BeginTrace+n).Label.XLabel=SpikeTraceData(k).Label.XLabel;
SpikeTraceData(BeginTrace+n).Filename=SpikeTraceData(k).Filename;
SpikeTraceData(BeginTrace+n).Path=SpikeTraceData(k).Path;

n=n+1;
waitbar(k/length(TracesToApply));
 
end

close(h);


% ValidateValues_Callback(hObject, eventdata, handles);


% this function does the big job, ie loading the data from files and
% creating the associated matrix
function EphysLoader_Datawave(BeginTrace,handles)
global SpikeTraceData;
global savefile_epstart;
global savefile_eplast;
global savefile;

h=waitbar(0,'Reading file');

fileInLoading=fullfile(SpikeTraceData(BeginTrace).Path,SpikeTraceData(BeginTrace).Filename);


chan=str2num(get(handles.ChanNb,'String'));
first_ep=str2num(get(handles.StartEp,'String'));
last_ep=str2num(get(handles.EndEp,'String'));
timeunit=str2num(get(handles.TimeUnit,'String'));

[savepath,savefile,ext]=fileparts(fileInLoading)
savefile=[savepath '\' savefile]
savefile_epstart=first_ep;
savefile_eplast=last_ep;

file_id = fopen(fileInLoading);
tline = fgetl(file_id);

n=1; %counter for loaded episodes

%data format
switch chan
    case 2
        format = '%n %n';
    case 3
        format = '%n %n %n';
    case 4
        format = '%n %n %n %n';
    case 5
        format = '%n %n %n %n %n';
    case 6
        format = '%n %n %n %n %n %n';
end

while ischar(tline)
    
    if n==1
        data = textscan(file_id, format, 'Delimiter', '\t', 'HeaderLines',11);
    else
        data = textscan(file_id, format, 'Delimiter', '\t', 'HeaderLines',12);
    end
    
    if n>= first_ep && n<= last_ep
        
        i = BeginTrace+(chan-1)*(n-first_ep)  ;
        %counter for SpikeTraceData, starts at BeginTrace (usually 1), goes in steps of chan-1 (usually two, V and Stim)
        
        m = cell2mat(data);
        tot_pts = size(m,1);
        
        % each episode generates as many SpikeTraceData instances as there are channels -1 (for the time channel):
        for k=0:chan-2
            label=['chan:' int2str(k+2) ' ep:' int2str(n)];
            SpikeTraceData(i+k).Label.ListText=label;
            SpikeTraceData(i+k).DataSize=tot_pts;
            SpikeTraceData(i+k).Trace=m(:,2+k); % start from col. 2 as col. 1 is the time channel
            SpikeTraceData(i+k).XVector=m(:,1)*timeunit/1000; % copy the time channel, converted into seconds
            
            if k==0 % V channel
            SpikeTraceData(i+k).Label.YLabel='mV'; 
            end
            if k==1 % Stim channel
            SpikeTraceData(i+k).Label.YLabel='photodiode signal'; 
            end
            
            SpikeTraceData(i+k).Label.XLabel='s';
            
        end
        
        waitbar(n/(last_ep-first_ep+1),h);
    end
    
    
    tline = fgetl(file_id);
    n = n+1;
    
end

n-1

% We close the file in the end
fclose(file_id);


close(h);

% --- Executes on button press in SelectFile.
function SelectFile_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeTraceData;


% Open file path
[filename, pathname] = uigetfile( ...
    {'*.asc;*.txt','TXT Files (*.asc, *.txt)'},'Select TXT File');

% Open file if exist
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
    return
    
    % Otherwise construct, display and store the fullfilename
else
    % To keep the path accessible to futur request
    cd(pathname);
    set(handles.FilenameShow,'String',fullfile(pathname,filename));

end


function StartEp_Callback(hObject, eventdata, handles)
% hObject    handle to StartEp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartEp as text
%        str2double(get(hObject,'String')) returns contents of StartEp as a double


% --- Executes during object creation, after setting all properties.
function StartEp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartEp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EndEp_Callback(hObject, eventdata, handles)
% hObject    handle to EndEp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EndEp as text
%        str2double(get(hObject,'String')) returns contents of EndEp as a double



% --- Executes during object creation, after setting all properties.
function EndEp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EndEp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ChanNb_Callback(hObject, eventdata, handles)
% hObject    handle to ChanNb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ChanNb as text
%        str2double(get(hObject,'String')) returns contents of ChanNb as a double


% --- Executes during object creation, after setting all properties.
function ChanNb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChanNb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in LoadBehSelect.
function LoadBehSelect_Callback(hObject, eventdata, handles)
% hObject    handle to LoadBehSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LoadBehSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LoadBehSelect


% --- Executes during object creation, after setting all properties.
function LoadBehSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LoadBehSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HeaderLines_Callback(hObject, eventdata, handles)
% hObject    handle to HeaderLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HeaderLines as text
%        str2double(get(hObject,'String')) returns contents of HeaderLines as a double


% --- Executes during object creation, after setting all properties.
function HeaderLines_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HeaderLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeUnit_Callback(hObject, eventdata, handles)
% hObject    handle to TimeUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeUnit as text
%        str2double(get(hObject,'String')) returns contents of TimeUnit as a double


% --- Executes during object creation, after setting all properties.
function TimeUnit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%% stitching function

function Stitch(BeginTrace,TracesToApply,handles)
global SpikeTraceData;


SpikeTraceData(BeginTrace).DataSize = 0;
newend=SpikeTraceData(BeginTrace).DataSize;
SpikeTraceData(BeginTrace).Trace=[];

ep_int=SpikeTraceData(TracesToApply(1)).XVector(2)-SpikeTraceData(TracesToApply(1)).XVector(1) ; 
%time interval between 2 consecutive stitched traces. By default (here) is equal to 1 sample duration, but could be different.
% If different then also change computation of tot_size below.

% get size of stitched trace
tot_size=0;
for k=TracesToApply
    tot_size = tot_size+SpikeTraceData(k).DataSize;
end

% initialize stitched trace
SpikeTraceData(BeginTrace).DataSize=tot_size;
SpikeTraceData(BeginTrace).Trace=zeros(tot_size,1);
SpikeTraceData(BeginTrace).XVector=zeros(tot_size,1);

newend=0;
firsttimept=0;

h=waitbar(0,'Stitching traces...');
for k=TracesToApply
  
    addend=SpikeTraceData(k).DataSize;  
    SpikeTraceData(BeginTrace).Trace(newend+1:newend+addend,1)=SpikeTraceData(k).Trace(1:addend,1); 
    SpikeTraceData(BeginTrace).XVector(newend+1:newend+addend,1)=firsttimept+SpikeTraceData(k).XVector(1:addend,1); %assuming SpikeTraceData(k).TimePoint starts at 0s.
    newend=newend+SpikeTraceData(k).DataSize;
    firsttimept=SpikeTraceData(BeginTrace).XVector(newend,1)+ep_int;
   
    % if chosen in gui delete trace after adding: not implemented yet
    
    waitbar(k/length(TracesToApply));
end
name='stitched';
SpikeTraceData(BeginTrace).Label.ListText=name;
SpikeTraceData(BeginTrace).Label.YLabel=SpikeTraceData(TracesToApply(1)).Label.YLabel;
SpikeTraceData(BeginTrace).Label.XLabel=SpikeTraceData(TracesToApply(1)).Label.XLabel;
SpikeTraceData(BeginTrace).Filename=SpikeTraceData(TracesToApply(1)).Filename;
SpikeTraceData(BeginTrace).Path=SpikeTraceData(TracesToApply(1)).Path;

close(h);

%%%%%%% low and high-pass filtering function

function Filter(TracesToApply,LowCutOff,HighCutOff,handles)
    global SpikeTraceData;
    
% LowCutOff=str2double(get(handles.LowCutOff,'String'));
% HighCutOff=str2double(get(handles.HighCutOff,'String'));

Order = 2;

FiltBH=zeros(Order+1, length(TracesToApply));
FiltAH=zeros(Order+1, length(TracesToApply));
FiltBL=zeros(Order+1, length(TracesToApply));
FiltAL=zeros(Order+1, length(TracesToApply));

UseFiltFilt=1;

for k=TracesToApply
    FrequencySample=1/(SpikeTraceData(k).XVector(2)-SpikeTraceData(k).XVector(1));
    
%     FNyquist=FrequencySample/2;
%     
%     Wn=FCutOff/FNyquist;
    FiltType='Butterworth';
%     FiltTypeContents=cellstr(get(handles.FilterType, 'String'));
%     FiltType=FiltTypeContents{get(handles.FilterType, 'Value')};
    if strcmp(FiltType, 'Butterworth')
        [FiltBH(:,k),FiltAH(:,k)] = butterhigh2(LowCutOff/FrequencySample);  %see end of file for butterhigh2 function
        [FiltBL(:,k),FiltAL(:,k)] = butterlow2(HighCutOff/FrequencySample);  %see end of file for butterlow2 function
    %%%% other filter types not implemented currently
%     elseif strcmp(FiltType, 'Chebyshev')
%         return;
%     elseif strcmp(FiltType, 'Elliptic')
%         return;
    end
end

h=waitbar(0,'Filtering traces...');
for k=TracesToApply
    OriginalClass=class(SpikeTraceData(k).Trace);
    
    % highpass filter first 
    if UseFiltFilt==1
        ResultFiltered=single(filtfilt(double(FiltBH(:,k)),double(FiltAH(:,k)),double(SpikeTraceData(k).Trace)));
    else
        ResultFiltered=single(filter(double(FiltBH(:,k)),double(FiltAH(:,k)),double(SpikeTraceData(k).Trace)));
    end
    % In any case, we want to keep the baseline value the same.
    % We also go back to the original data class
    SpikeTraceData(k).Trace(:)=cast(ResultFiltered(:),OriginalClass);
    
    % lowpass filter next
    
        if UseFiltFilt==1
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


%%%%%%%%% function to detect threshold crossings

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


%%%%%%%%% function to cut out short ISIs from a detection list
    
    function [times_def, times_bursts] = cutshortisis(times,win, handles)

%CUTSHORTISIS 
%  remove from vector of event times times all events that are closer
%  to the preceding one than win ms

% return remaining events in vector times_def
% return times of bursts (=first in a group of events closer apart than win
% ms) in times_bursts

isis = diff(times);

times_def = [];
times_bursts = [];

times_def(end+1)=times(1); 

rem=0; % local counter for removed events, needed to identify true onset of a burst of multiple short ISIs

for n=1:length(isis)
  
  if isis(n)>win
  times_def(end+1) = times(n+1);
  rem=0; %reset counter of short ISIs
  end
  
  if isis(n)<=win
  times_bursts(end+1) = times(n-rem);
  rem=rem+1;
  end
  
end

times_bursts=unique(times_bursts); 


%%%%%%%%%% function for binning detected events

function binned_events=Digitize(events,binsize,handles)

last_time=events(end);
bin_nb = floor(last_time/binsize)+1;

binned_events=zeros(bin_nb,1);

bins_with_event = floor(events/binsize);

for k=1:length(bins_with_event)
    binned_events(bins_with_event(k)+1)=binned_events(bins_with_event(k)+1)+1;
end;



function Binsize_Callback(hObject, eventdata, handles)
% hObject    handle to Binsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Binsize as text
%        str2double(get(hObject,'String')) returns contents of Binsize as a double


% --- Executes during object creation, after setting all properties.
function Binsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Binsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to Binsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Binsize as text
%        str2double(get(hObject,'String')) returns contents of Binsize as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Binsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinISI2_Callback(hObject, eventdata, handles)
% hObject    handle to MinISI2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinISI2 as text
%        str2double(get(hObject,'String')) returns contents of MinISI2 as a double


% --- Executes during object creation, after setting all properties.
function MinISI2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinISI2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Nb_Crossings1_Callback(hObject, eventdata, handles)
% hObject    handle to Nb_Crossings1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Nb_Crossings1 as text
%        str2double(get(hObject,'String')) returns contents of Nb_Crossings1 as a double


% --- Executes during object creation, after setting all properties.
function Nb_Crossings1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Nb_Crossings1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Nb_Crossings2_Callback(hObject, eventdata, handles)
% hObject    handle to Nb_Crossings2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Nb_Crossings2 as text
%        str2double(get(hObject,'String')) returns contents of Nb_Crossings2 as a double


% --- Executes during object creation, after setting all properties.
function Nb_Crossings2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Nb_Crossings2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Nb_Crossings3_Callback(hObject, eventdata, handles)
% hObject    handle to Nb_Crossings3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Nb_Crossings3 as text
%        str2double(get(hObject,'String')) returns contents of Nb_Crossings3 as a double


% --- Executes during object creation, after setting all properties.
function Nb_Crossings3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Nb_Crossings3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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
