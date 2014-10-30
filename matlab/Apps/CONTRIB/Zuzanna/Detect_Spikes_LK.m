function varargout = Detect_Spikes_LK(varargin)
% DETECT_SPIKES_LK M-file for Detect_Spikes_LK.fig
%      DETECT_SPIKES_LK, by itself, creates a new DETECT_SPIKES_LK or raises the existing
%      singleton*.
%
%      H = DETECT_SPIKES_LK returns the handle to a new DETECT_SPIKES_LK or the handle to
%      the existing singleton*.
%
%      DETECT_SPIKES_LK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DETECT_SPIKES_LK.M with the given input arguments.
%
%      DETECT_SPIKES_LK('Property','Value',...) creates a new DETECT_SPIKES_LK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Detect_Spikes_LK_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Detect_Spikes_LK_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Detect_Spikes_LK

% Last Modified by GUIDE v2.5 06-Aug-2012 15:23:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Detect_Spikes_LK_OpeningFcn, ...
                   'gui_OutputFcn',  @Detect_Spikes_LK_OutputFcn, ...
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


% --- Executes just before Detect_Spikes_LK is made visible.
function Detect_Spikes_LK_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Detect_Spikes_LK (see VARARGIN)

% Choose default command line output for Detect_Spikes_LK
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Detect_Spikes_LK wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global SpikeTraceData;


if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.ThreshTrace,'String',Settings.ThreshTraceSelectorString);
    set(handles.ThreshTrace,'Value',Settings.ThreshTraceSelectorValue);
    set(handles.EPhysTrace,'String',Settings.EphysTraceSelectorString);
    set(handles.EPhysTrace,'Value', Settings.EphysTraceSelectorValue);
    set(handles.NumClusters, 'String', Settings.NumClusters);
    set(handles.NumPCsToCluster, 'String', Settings.NumPCsToCluster);
    set(handles.SaveSnippets, 'Value', Settings.SaveSnippets);
    set(handles.ClusteringAlg, 'Value', Settings.ClusteringAlgValue);
    set(handles.MsBetweenSpikes, 'String', Settings.MsBetweenSpikesString);
    set(handles.MinAboveThresh, 'String', Settings.MinAboveThreshString);
    set(handles.ThreshUsed, 'String', Settings.ThreshUsedString);
end

if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        Text{i}=['Trace ',num2str(i)];
    end
    set(handles.ThreshTrace,'String',Text);
    set(handles.EPhysTrace,'String',Text);
end


% --- Outputs from this function are returned to the command line.
function varargout = Detect_Spikes_LK_OutputFcn(hObject, eventdata, handles) 
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
Settings.ThreshTraceSelectorString=get(handles.ThreshTrace,'String');
Settings.ThreshTraceSelectorValue=get(handles.ThreshTrace,'Value');
Settings.EphysTraceSelectorString=get(handles.EPhysTrace,'String');
Settings.EphysTraceSelectorValue=get(handles.EPhysTrace,'Value');
Settings.NumClustersString=get(handles.NumClusters, 'String');
Settings.NumPCsToClusterString=get(handles.NumPCsToCluster, 'String');
Settings.SaveSnippetsValue=get(handles.SaveSnippets, 'Value');
Settings.ClusteringAlgValue=get(handles.ClusteringAlg, 'Value');
Settings.MsBetweenSpikesString=get(handles.MsBetweenSpikes, 'String');
Settings.MinAboveThreshString=get(handles.MinAboveThresh, 'String');
Settings.ThreshUsedString=get(handles.ThreshUsed, 'String');



% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeTraceData;


msBefore=str2double(get(handles.TimeBefore, 'String'));
msAfter=str2double(get(handles.TimeAfter, 'String'));
msBetween=str2double(get(handles.MsBetweenSpikes, 'String'));
minpts=str2double(get(handles.MinAboveThresh, 'String'));
thresh=str2double(get(handles.ThreshUsed, 'String'));
fs=30; % sampling frequency in MHz

% get data in proper format
threshCrossTrace=get(handles.ThreshTrace, 'Value');
ephysTrace=get(handles.EPhysTrace, 'Value');

threshCrossings=double(SpikeTraceData(threshCrossTrace).XVector);
trace=double(SpikeTraceData(ephysTrace).Trace);
traceTimes=double(SpikeTraceData(ephysTrace).XVector);

logInds=ismember(traceTimes, threshCrossings);
crossInds=1:length(traceTimes);
crossInds=crossInds(logInds);
clear logInds traceTimes threshCrossings

length(crossInds)

% gather snippets of trace surrounding crossings
snipInd=0;
lastCind=0;
snippets=zeros(fs*msBefore+fs*msAfter+1, length(crossInds));
snipInds=zeros(size(crossInds));
for c=1:length(crossInds)
    cInd=crossInds(c);
    if (cInd>fs*msBefore) && (cInd-lastCind)>fs*msBetween && cInd+fs*msAfter<=length(trace) % && abs(trace(cInd+minpts))>abs(thresh)
        snipInd=snipInd+1;
        thisSnippet=trace(cInd-fs*msBefore:cInd+fs*msAfter);
        snippets(:,snipInd)=thisSnippet;
        snipInds(snipInd)=cInd;
    end
    lastCind=cInd;
end
snippets=snippets(:, 1:snipInd);
snipInds=snipInds(1:snipInd);

numClusts=str2double(get(handles.NumClusters, 'String'));
numPCs2Clust=str2double(get(handles.NumPCsToCluster, 'String'));

%%% PCA and Cluster
coefs=princomp(snippets');
kmeansIn=zeros(numPCs2Clust, size(snippets,2));
for pc=1:numPCs2Clust
    kmeansIn(pc,:)=snippets'*coefs(:,pc);
end

if get(handles.ClusteringAlg, 'Value')==1
    idx=kmeans(kmeansIn',numClusts);
else
    Z=linkage(kmeansIn');
    idx=cluster(Z, 'maxclust', numClusts);
end


%%% Make Plots and Cluster Cell
ag = findobj;
nf = max(ag(logical(ag==fix(ag))));
if nf==0
    figure(2)
    nf=2;
else
    figure(nf+1)
    nf=nf+1;
end
hold all;
clustFig=nf;
pc1vals=snippets'*coefs(:,1);
pc2vals=snippets'*coefs(:,2);
for k=1:numClusts
    % plot the cluster on the pc2 vs pc1 graph
    clustpc1=pc1vals(idx==k);
    clustpc2=pc2vals(idx==k);
    figure(clustFig)
    plot(clustpc1, clustpc2, '.', 'MarkerSize', 10);
    legd{k}=['c', num2str(k)]; 
    % make new entry in snippets cell and plot snippets
    snipsByClust{k}=snippets(:,idx==k);
    figure(nf+1); nf=nf+1;
    plot(snipsByClust{k})
    title(['cluster ' num2str(k)])
end
figure(clustFig)
legend(legd)

% save spike waveforms
traceTimes=double(SpikeTraceData(ephysTrace).XVector);
traceInd=length(SpikeTraceData);
origTraceInd=traceInd;

for k=1:numClusts
    sInds=snipInds(idx==k);
    vals=zeros(1,length(traceTimes));
    vals(sInds)=1;
    traceInd=traceInd+1;
    SpikeTraceData(traceInd).Trace=vals;
    SpikeTraceData(traceInd).XVector=traceTimes;
    SpikeTraceData(traceInd).Label.ListText=['c', num2str(k), ' spike times'];
    SpikeTraceData(traceInd).Label.YLabel='detections';
    SpikeTraceData(traceInd).Label.XLabel=SpikeTraceData(ephysTrace).Label.XLabel;
    SpikeTraceData(traceInd).Filename=SpikeTraceData(ephysTrace).Filename;
    SpikeTraceData(traceInd).Path=SpikeTraceData(ephysTrace).Path;

%save spike times in ZP format:
times=SpikeTraceData(traceInd).XVector(logical(SpikeTraceData(traceInd).Trace));

traceInd=traceInd+1;

SpikeTraceData(traceInd).XVector=times;
SpikeTraceData(traceInd).Trace=ones(size(times));
SpikeTraceData(traceInd).DataSize=length(times);
SpikeTraceData(traceInd).Label.ListText=['c', num2str(k), ' only times'];
SpikeTraceData(traceInd).Label.YLabel='detections';
SpikeTraceData(traceInd).Label.XLabel=SpikeTraceData(ephysTrace).Label.XLabel;
SpikeTraceData(traceInd).Filename=SpikeTraceData(ephysTrace).Filename;
SpikeTraceData(traceInd).Path=SpikeTraceData(ephysTrace).Path;

end







if get(handles.SaveSnippets, 'Value')
    h=waitbar(0,'Saving spike waveforms...');
    for k=1:numClusts
        sInds=snipInds(idx==k);
        for sInd=1:size(snipsByClust{k}, 2)
            if mod(sInd,100)==0
                waitbar((traceInd-origTraceInd)/size(snippets,2))
            end
            traceInd=traceInd+1;
            SpikeTraceData(traceInd).Trace=snipsByClust{k}(:,sInd);
            SpikeTraceData(traceInd).XVector=traceTimes((sInds(sInd)-30*msBefore):(sInds(sInd)+30*msAfter))-traceTimes(sInds(sInd)-30*msBefore);
            SpikeTraceData(traceInd).Label.ListText=['c', num2str(k), ' ', num2str(sInd)];
            SpikeTraceData(traceInd).Label.YLabel=SpikeTraceData(ephysTrace).Label.XLabel;
            SpikeTraceData(traceInd).Label.XLabel=SpikeTraceData(ephysTrace).Label.XLabel;
            SpikeTraceData(traceInd).Filename=SpikeTraceData(ephysTrace).Filename;
            SpikeTraceData(traceInd).Path=SpikeTraceData(ephysTrace).Path;
        end
        
    end
    close(h);
end




ValidateValues_Callback(hObject, eventdata, handles);




% --- Executes on button press in ValidateValues.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;



% --- Executes on selection change in ThreshTrace.
function ThreshTrace_Callback(hObject, eventdata, handles)
% hObject    handle to ThreshTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ThreshTrace contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ThreshTrace


% --- Executes during object creation, after setting all properties.
function ThreshTrace_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThreshTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveSnippets.
function SaveSnippets_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSnippets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SaveSnippets


% --- Executes on selection change in EPhysTrace.
function EPhysTrace_Callback(hObject, eventdata, handles)
% hObject    handle to EPhysTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns EPhysTrace contents as cell array
%        contents{get(hObject,'Value')} returns selected item from EPhysTrace


% --- Executes during object creation, after setting all properties.
function EPhysTrace_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EPhysTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NumClusters_Callback(hObject, eventdata, handles)
% hObject    handle to NumClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumClusters as text
%        str2double(get(hObject,'String')) returns contents of NumClusters as a double


% --- Executes during object creation, after setting all properties.
function NumClusters_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NumPCsToCluster_Callback(hObject, eventdata, handles)
% hObject    handle to NumPCsToCluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumPCsToCluster as text
%        str2double(get(hObject,'String')) returns contents of NumPCsToCluster as a double


% --- Executes during object creation, after setting all properties.
function NumPCsToCluster_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumPCsToCluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ClusteringAlg.
function ClusteringAlg_Callback(hObject, eventdata, handles)
% hObject    handle to ClusteringAlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ClusteringAlg contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ClusteringAlg


% --- Executes during object creation, after setting all properties.
function ClusteringAlg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ClusteringAlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MsBetweenSpikes_Callback(hObject, eventdata, handles)
% hObject    handle to MsBetweenSpikes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MsBetweenSpikes as text
%        str2double(get(hObject,'String')) returns contents of MsBetweenSpikes as a double


% --- Executes during object creation, after setting all properties.
function MsBetweenSpikes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MsBetweenSpikes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeBefore_Callback(hObject, eventdata, handles)
% hObject    handle to TimeBefore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeBefore as text
%        str2double(get(hObject,'String')) returns contents of TimeBefore as a double


% --- Executes during object creation, after setting all properties.
function TimeBefore_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeBefore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeAfter_Callback(hObject, eventdata, handles)
% hObject    handle to TimeAfter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeAfter as text
%        str2double(get(hObject,'String')) returns contents of TimeAfter as a double


% --- Executes during object creation, after setting all properties.
function TimeAfter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeAfter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinAboveThresh_Callback(hObject, eventdata, handles)
% hObject    handle to MinAboveThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinAboveThresh as text
%        str2double(get(hObject,'String')) returns contents of MinAboveThresh as a double


% --- Executes during object creation, after setting all properties.
function MinAboveThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinAboveThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ThreshUsed_Callback(hObject, eventdata, handles)
% hObject    handle to ThreshUsed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ThreshUsed as text
%        str2double(get(hObject,'String')) returns contents of ThreshUsed as a double


% --- Executes during object creation, after setting all properties.
function ThreshUsed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThreshUsed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
