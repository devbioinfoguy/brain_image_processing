function varargout = PSTH_xcorr(varargin)
% PSTH_XCORR M-file for PSTH_xcorr.fig
%      PSTH_XCORR, by itself, creates a new PSTH_XCORR or raises the existing
%      singleton*.
%
%      H = PSTH_XCORR returns the handle to a new PSTH_XCORR or the handle to
%      the existing singleton*.
%
%      PSTH_XCORR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PSTH_XCORR.M with the given input arguments.
%
%      PSTH_XCORR('Property','Value',...) creates a new PSTH_XCORR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PSTH_xcorr_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PSTH_xcorr_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PSTH_xcorr

% Last Modified by GUIDE v2.5 07-Aug-2012 16:57:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PSTH_xcorr_OpeningFcn, ...
                   'gui_OutputFcn',  @PSTH_xcorr_OutputFcn, ...
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


% --- Executes just before PSTH_xcorr is made visible.
function PSTH_xcorr_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PSTH_xcorr (see VARARGIN)

% Choose default command line output for PSTH_xcorr
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PSTH_xcorr wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global SpikeTraceData;

   if ~isempty(SpikeTraceData)
        for i=1:length(SpikeTraceData)
            TextTrace_Stims{i}=['Trace ',num2str(i)];
        end
        set(handles.TraceSelector_Stims,'String',TextTrace_Stims);
        set(handles.TraceSelector_Stims,'Value',7);
    end
    
    
    if ~isempty(SpikeTraceData)
        for i=1:length(SpikeTraceData)
            TextTrace_Spikes{i}=['Trace ',num2str(i)];
        end
        set(handles.TraceSelector_Spikes,'String',TextTrace_Spikes);
        set(handles.TraceSelector_Spikes,'Value',6);
    end

if (length(varargin)>1)
    Settings=varargin{2};
%     set(handles.TraceSelector_Stims,'String',Settings.TraceSelectorStimsString);
%     set(handles.TraceSelector_Stims,'Value',Settings.TraceSelectorStimsValue);
% %     set(handles.TraceSelector_Spikes,'String',Settings.TraceSelectorSpikesString);
%     set(handles.TraceSelector_Spikes,'Value',Settings.TraceSelectorSpikesValue);
    set(handles.Lag,'String',Settings.LagString);
    set(handles.start1,'String',Settings.start1String);
    set(handles.dur1,'String',Settings.dur1String);
    set(handles.start2,'String',Settings.start2String);
    set(handles.dur2,'String',Settings.dur2String);
    set(handles.start3,'String',Settings.start3String);
    set(handles.dur3,'String',Settings.dur3String);
    set(handles.SaveFigs,'Value',Settings.SaveFigsValue);
    set(handles.SSEv1,'Value',Settings.SSEv1Value);
    set(handles.SSEv2,'Value',Settings.SSEv2Value);
    set(handles.CSEv1,'Value',Settings.CSEv1Value);
    set(handles.CSEv2,'Value',Settings.CSEv2Value);
    set(handles.StimEv1,'Value',Settings.StimEv1Value);
    set(handles.StimEv2,'Value',Settings.StimEv2Value);
end


% --- Outputs from this function are returned to the command line.
function varargout = PSTH_xcorr_OutputFcn(hObject, eventdata, handles) 
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
Settings.TraceSelectorStimsString=get(handles.TraceSelector_Stims,'String');
Settings.TraceSelectorStimsValue=get(handles.TraceSelector_Stims,'Value');
Settings.TraceSelectorSpikesString=get(handles.TraceSelector_Spikes,'String');
Settings.TraceSelectorSpikesValue=get(handles.TraceSelector_Spikes,'Value');
Settings.LagString=get(handles.Lag,'String');
Settings.start1String=get(handles.start1,'String');
Settings.dur1String=get(handles.dur1,'String');
Settings.start2String=get(handles.start2,'String');
Settings.dur2String=get(handles.dur2,'String');
Settings.start3String=get(handles.start3,'String');
Settings.dur3String=get(handles.dur3,'String');
Settings.SaveFigsValue=get(handles.SaveFigs,'Value');
Settings.SSEv1Value=get(handles.SSEv1,'Value');
Settings.SSEv2Value=get(handles.SSEv2,'Value');
Settings.CSEv1Value=get(handles.CSEv1,'Value');
Settings.CSEv2Value=get(handles.CSEv2,'Value');
Settings.StimEv1Value=get(handles.StimEv1,'Value');
Settings.StimEv2Value=get(handles.StimEv2,'Value');

% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeTraceData;
global savefile_epstart;
global savefile_eplast;
global savefile;
global SpikeImageData;

TracesToApply_Stims=get(handles.TraceSelector_Stims,'Value');
TracesToApply_Spikes=get(handles.TraceSelector_Spikes,'Value');

savefigs=get(handles.SaveFigs,'Value');
SSEv1=get(handles.SSEv1,'Value');
SSEv2=get(handles.SSEv2,'Value');
CSEv1=get(handles.CSEv1,'Value');
CSEv2=get(handles.CSEv2,'Value');
StimEv1=get(handles.StimEv1,'Value');
StimEv2=get(handles.StimEv2,'Value');

%%%%%%%%%%%%%

lag=str2double(get(handles.Lag,'String'))/1000; %in s

binsize = SpikeTraceData(TracesToApply_Stims).XVector(2)-SpikeTraceData(TracesToApply_Stims).XVector(1); %in sec

psth_xcorr(SpikeTraceData(TracesToApply_Stims).Trace,SpikeTraceData(TracesToApply_Spikes).Trace,lag,binsize,handles);



if savefigs

 basename=[savefile '_ep' int2str(savefile_epstart) '-' int2str(savefile_eplast)];
 if SSEv1==1
     string1='_SS-';
 elseif CSEv1==1
     string1='_CS-';
 elseif StimEv1==1
     string1='_Stim-';
 else string1=''
 end
 
  if SSEv2==1
     string2='SS';
 elseif CSEv2==1
     string2='CS';
 elseif StimEv2==1
     string2='Stim';
 else string2=''
 end
 
 
 fig_fig=[basename '_psth' string1 string2 '.fig'];
 fig_tiff=[basename '_psth' string1 string2 '.tif'];
 print(222,'-dtiff',fig_tiff);
 saveas(222,fig_fig);
 
 psth_int=[basename '_psth_int' string1 string2 '.mat']
 save(psth_int,'SpikeImageData');

end
 
ValidateValues_Callback(hObject, eventdata, handles);

%%%%%%%%%%%%


% xcorr of 2 vectors containing numbers of events per time bin (ie spikes and
% stimulations): produces psth with binsize equal to the binsize of the
% vectors.

function psth_xcorr(stimtimes,spiketimes,lag,binsize,handles)

global SpikeImageData
global SpikeTraceData

start1=str2double(get(handles.start1,'String'))/1000; % converting to s
dur1=str2double(get(handles.dur1,'String'))/1000; % converting to s
start2=str2double(get(handles.start2,'String'))/1000; % converting to s
dur2=str2double(get(handles.dur2,'String'))/1000; % converting to s
start3=str2double(get(handles.start3,'String'))/1000; % converting to s
dur3=str2double(get(handles.dur3,'String'))/1000; % converting to s

SSEv1=get(handles.SSEv1,'Value');
SSEv2=get(handles.SSEv2,'Value');
CSEv1=get(handles.CSEv1,'Value');
CSEv2=get(handles.CSEv2,'Value');
StimEv1=get(handles.StimEv1,'Value');
StimEv2=get(handles.StimEv2,'Value');

maxlag=lag; % in s

[ccs,lags]=xcorr(spiketimes(:),stimtimes(:),floor(maxlag/binsize));

xminlag=-floor(maxlag/binsize);
xmaxlag=floor(maxlag/binsize);

figure(222);
stem(lags,ccs/(sum(stimtimes)*binsize),'k.-','Markersize',0)  %correlation divided by number of stimuli and by binsize in s -> firing rate in Hz
axis([xminlag xmaxlag 0 10+max(ccs/(sum(stimtimes)*binsize))])
xlabel('time (bins)')
ylabel('firing rate (Hz)')

%initialize 3 1x1 images that will contain "colormaps based on the integrated
%PSTHS (single point, but needed for consistency with the spatially sorted PSTHs):

if isempty(SpikeImageData)
    InitImages();
    BeginImage=1;
else
    BeginImage=length(SpikeImageData)+1;
end

for k=0:4
  
    SpikeImageData(BeginImage+k).DataSize=[1 1];
    
    SpikeImageData(BeginImage+k).Path='';
    SpikeImageData(BeginImage+k).Filename=''; 
    SpikeImageData(BeginImage+k).Xposition=[1:1];
    SpikeImageData(BeginImage+k).Yposition=[1:1];
%     SpikeImageData(image_nb).Zposition=SpikeMovieData(CurrentMovie).Zposition;
    SpikeImageData(BeginImage+k).Label.XLabel='Y index';
    SpikeImageData(BeginImage+k).Label.YLabel='X index';
    SpikeImageData(BeginImage+k).Label.ZLabel='';
%     SpikeImageData(image_nb).Label.CLabel=SpikeMovieData(CurrentMovie).Label.CLabel;

end

SpikeImageData(BeginImage).Label.ListText=['Integrated PSTH, ' num2str(start1*1000) '-' num2str((start1+dur1)*1000) ' ms'];
SpikeImageData(BeginImage+1).Label.ListText=['Integrated PSTH, ' num2str(start2*1000) '-' num2str((start2+dur2)*1000) ' ms'];
SpikeImageData(BeginImage+2).Label.ListText=['Integrated PSTH, ' num2str(start3*1000) '-' num2str((start3+dur3)*1000) ' ms'];
SpikeImageData(BeginImage+3).Label.ListText=['Int. PSTH, ' num2str(start2*1000) '-' num2str((start2+dur2)*1000) ' ms /Int. PSTH, ' num2str(start1*1000) '-' num2str((start1+dur1)*1000) ' ms'];
SpikeImageData(BeginImage+4).Label.ListText=['Int. PSTH, ' num2str(start3*1000) '-' num2str((start3+dur3)*1000) ' ms /Int. PSTH, ' num2str(start1*1000) '-' num2str((start1+dur1)*1000) ' ms'];
   
sum_psth1=integrate_psth(ccs,binsize,start1,start1+dur1);
sum_psth2=integrate_psth(ccs,binsize,start2,start2+dur2);
sum_psth3=integrate_psth(ccs,binsize,start3,start3+dur3);

SpikeImageData(BeginImage).Image(1,1)=sum_psth1;
SpikeImageData(BeginImage+1).Image(1,1)=sum_psth2;
SpikeImageData(BeginImage+2).Image(1,1)=sum_psth3;
SpikeImageData(BeginImage+3).Image(1,1)=sum_psth2/sum_psth1;
SpikeImageData(BeginImage+4).Image(1,1)=sum_psth3/sum_psth1;

% saving psth in SpikeTraceData:
if isempty(SpikeTraceData)
    InitTraces();
    BeginTrace=1;
else
    BeginTrace=length(SpikeTraceData)+1;
end

 if SSEv1==1
     string1='-SS-';
 elseif CSEv1==1
     string1='-CS-';
 elseif StimEv1==1
     string1='-Stim-';
 else string1=''
 end
 
  if SSEv2==1
     string2='SS';
 elseif CSEv2==1
     string2='CS';
 elseif StimEv2==1
     string2='Stim';
 else string2=''
 end

    SpikeTraceData(BeginTrace).Trace=ccs/(sum(stimtimes)*binsize);
    SpikeTraceData(BeginTrace).XVector=lags;
    SpikeTraceData(BeginTrace).Label.ListText=['psth' string1 string2];
    SpikeTraceData(BeginTrace).Label.YLabel='firing rate (Hz)';
    SpikeTraceData(BeginTrace).Label.XLabel='time (bins)';
    SpikeTraceData(BeginTrace).Filename='';
    SpikeTraceData(BeginTrace).Path='';


function sum_psth=integrate_psth(cc,binsize,t1,t2)

% takes output of xcorr, ie vec cc, and sums cc between lags t1
% and t2.

% this allows the extraction of a single value out of a psth. This value
% can then be used for example to create a color map or for further
% analyses.

% binsize, t1 and t2 are in s
% t1 and t2 can be negative (= preceding the stimulus)

%extract the right portion of cc into cc_cut

s=length(cc)*binsize; %in s

d1=floor(((s/2)+t1)/binsize);
d2=floor(((s/2)+t2)/binsize);

cc_cut = cc(d1:d2);

%sum all of cc_cut
 sum_psth = sum(cc_cut)


% --- Executes on button press in ValidateValues.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;


% --- Executes on selection change in TraceSelector_Stims.
function TraceSelector_Stims_Callback(hObject, eventdata, handles)
% hObject    handle to TraceSelector_Stims (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TraceSelector_Stims contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TraceSelector_Stims

% --- Executes during object creation, after setting all properties.
function TraceSelector_Stims_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TraceSelector_Stims (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Lag_Callback(hObject, eventdata, handles)
% hObject    handle to Lag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Lag as text
%        str2double(get(hObject,'String')) returns contents of Lag as a double

% --- Executes during object creation, after setting all properties.
function Lag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Lag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TraceSelector_Spikes.
function TraceSelector_Spikes_Callback(hObject, eventdata, handles)
% hObject    handle to TraceSelector_Spikes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TraceSelector_Spikes contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TraceSelector_Spikes


% --- Executes during object creation, after setting all properties.
function TraceSelector_Spikes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TraceSelector_Spikes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







function start1_Callback(hObject, eventdata, handles)
% hObject    handle to start1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of start1 as text
%        str2double(get(hObject,'String')) returns contents of start1 as a double


% --- Executes during object creation, after setting all properties.
function start1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dur1_Callback(hObject, eventdata, handles)
% hObject    handle to dur1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dur1 as text
%        str2double(get(hObject,'String')) returns contents of dur1 as a double


% --- Executes during object creation, after setting all properties.
function dur1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dur1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function start2_Callback(hObject, eventdata, handles)
% hObject    handle to start2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of start2 as text
%        str2double(get(hObject,'String')) returns contents of start2 as a double


% --- Executes during object creation, after setting all properties.
function start2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dur2_Callback(hObject, eventdata, handles)
% hObject    handle to dur2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dur2 as text
%        str2double(get(hObject,'String')) returns contents of dur2 as a double


% --- Executes during object creation, after setting all properties.
function dur2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dur2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function start3_Callback(hObject, eventdata, handles)
% hObject    handle to start3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of start3 as text
%        str2double(get(hObject,'String')) returns contents of start3 as a double


% --- Executes during object creation, after setting all properties.
function start3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dur3_Callback(hObject, eventdata, handles)
% hObject    handle to dur3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dur3 as text
%        str2double(get(hObject,'String')) returns contents of dur3 as a double


% --- Executes during object creation, after setting all properties.
function dur3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dur3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveFigs.
function SaveFigs_Callback(hObject, eventdata, handles)
% hObject    handle to SaveFigs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SaveFigs


% --- Executes on button press in SSEv1.
function SSEv1_Callback(hObject, eventdata, handles)
% hObject    handle to SSEv1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SSEv1


% --- Executes on button press in CSEv1.
function CSEv1_Callback(hObject, eventdata, handles)
% hObject    handle to CSEv1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CSEv1


% --- Executes on button press in StimEv1.
function StimEv1_Callback(hObject, eventdata, handles)
% hObject    handle to StimEv1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StimEv1


% --- Executes on button press in StimEv2.
function StimEv2_Callback(hObject, eventdata, handles)
% hObject    handle to StimEv2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StimEv2


% --- Executes on button press in CSEv2.
function CSEv2_Callback(hObject, eventdata, handles)
% hObject    handle to CSEv2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CSEv2


% --- Executes on button press in SSEv2.
function SSEv2_Callback(hObject, eventdata, handles)
% hObject    handle to SSEv2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SSEv2
