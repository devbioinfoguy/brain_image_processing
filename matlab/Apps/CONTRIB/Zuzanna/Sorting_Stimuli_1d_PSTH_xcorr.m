function varargout = Sorting_Stimuli_1d_PSTH_xcorr(varargin)
% SORTING_STIMULI_1D_PSTH_XCORR M-file for Sorting_Stimuli_1d_PSTH_xcorr.fig
%      SORTING_STIMULI_1D_PSTH_XCORR, by itself, creates a new SORTING_STIMULI_1D_PSTH_XCORR or raises the existing
%      singleton*.
%
%      H = SORTING_STIMULI_1D_PSTH_XCORR returns the handle to a new SORTING_STIMULI_1D_PSTH_XCORR or the handle to
%      the existing singleton*.
%
%      SORTING_STIMULI_1D_PSTH_XCORR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SORTING_STIMULI_1D_PSTH_XCORR.M with the given input arguments.
%
%      SORTING_STIMULI_1D_PSTH_XCORR('Property','Value',...) creates a new SORTING_STIMULI_1D_PSTH_XCORR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Sorting_Stimuli_1d_PSTH_xcorr_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Sorting_Stimuli_1d_PSTH_xcorr_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Sorting_Stimuli_1d_PSTH_xcorr

% Last Modified by GUIDE v2.5 04-Jun-2012 13:18:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Sorting_Stimuli_1d_PSTH_xcorr_OpeningFcn, ...
                   'gui_OutputFcn',  @Sorting_Stimuli_1d_PSTH_xcorr_OutputFcn, ...
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


% --- Executes just before Sorting_Stimuli_1d_PSTH_xcorr is made visible.
function Sorting_Stimuli_1d_PSTH_xcorr_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Sorting_Stimuli_1d_PSTH_xcorr (see VARARGIN)

% Choose default command line output for Sorting_Stimuli_1d_PSTH_xcorr
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Sorting_Stimuli_1d_PSTH_xcorr wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global SpikeTraceData;
global DLPstim

   if ~isempty(SpikeTraceData)
        for i=1:length(SpikeTraceData)
            TextTrace_BinStims{i}=['Trace ',num2str(i)];
        end
        set(handles.TraceSelector_BinStims,'String',TextTrace_BinStims);
        set(handles.TraceSelector_BinStims,'Value',7);
    end
    
    
    if ~isempty(SpikeTraceData)
        for i=1:length(SpikeTraceData)
            TextTrace_BinSpikes{i}=['Trace ',num2str(i)];
        end
        set(handles.TraceSelector_BinSpikes,'String',TextTrace_BinSpikes);
        set(handles.TraceSelector_BinSpikes,'Value',6);
    end
    
        if ~isempty(SpikeTraceData)
        for i=1:length(SpikeTraceData)
            TextTrace_Stims{i}=['Trace ',num2str(i)];
        end
        set(handles.TraceSelector_Stims,'String',TextTrace_Stims);
        set(handles.TraceSelector_Stims,'Value',5);
    end
    

if (length(varargin)>1)
    Settings=varargin{2};
%     set(handles.TraceSelector_BinStims,'String',Settings.TraceSelectorStimsString);
%     set(handles.TraceSelector_BinStims,'Value',Settings.TraceSelectorStimsValue);
% %     set(handles.TraceSelector_BinSpikes,'String',Settings.TraceSelectorSpikesString);
%     set(handles.TraceSelector_BinSpikes,'Value',Settings.TraceSelectorSpikesValue);
    set(handles.First_Stim,'String',Settings.FirstStimString);
    set(handles.Last_Stim,'String',Settings.LastStimString);
    set(handles.Lag,'String',Settings.LagString);
    set(handles.First_Stim_In_Detstim,'String',Settings.FirstStimInDetStimString);
    set(handles.DLPNotLoaded,'Value',Settings.DLPNotLoadedValue); 
    set(handles.start1,'String',Settings.start1String);
    set(handles.dur1,'String',Settings.dur1String);
    set(handles.start2,'String',Settings.start2String);
    set(handles.dur2,'String',Settings.dur2String);
    set(handles.start3,'String',Settings.start3String);
    set(handles.dur3,'String',Settings.dur3String);
    set(handles.SaveFigs,'String',Settings.SaveFigsValue);

else

    if ~isempty(DLPstim)
        set(handles.Last_Stim,'String',size(DLPstim.SaveParam.Savedxin,2));
    else
        set(handles.DLPNotLoaded,'Value',1);
    end
      
end


% --- Outputs from this function are returned to the command line.
function varargout = Sorting_Stimuli_1d_PSTH_xcorr_OutputFcn(hObject, eventdata, handles) 
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
Settings.TraceSelectorBinStimsString=get(handles.TraceSelector_BinStims,'String');
Settings.TraceSelectorBinStimsValue=get(handles.TraceSelector_BinStims,'Value');
Settings.TraceSelectorBinSpikesString=get(handles.TraceSelector_BinSpikes,'String');
Settings.TraceSelectorBinSpikesValue=get(handles.TraceSelector_BinSpikes,'Value');
Settings.FirstStimString=get(handles.First_Stim,'String');
Settings.LastStimString=get(handles.Last_Stim,'String');
Settings.LagString=get(handles.Lag,'String');
Settings.FirstStimInDetStimString=get(handles.First_Stim_In_Detstim,'String');
Settings.DLPNotLoadedValue=get(handles.DLPNotLoaded,'Value');
Settings.start1String=get(handles.start1,'String');
Settings.dur1String=get(handles.dur1,'String');
Settings.start2String=get(handles.start2,'String');
Settings.dur2String=get(handles.dur2,'String');
Settings.start3String=get(handles.start3,'String');
Settings.dur3String=get(handles.dur3,'String');
Settings.SaveFigsValue=get(handles.SaveFigs,'Value');


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeTraceData;
global DLPstim;
global savefile_epstart;
global savefile_eplast;
global savefile;
global SpikeImageData;

TracesToApply_BinStims=get(handles.TraceSelector_BinStims,'Value');
TracesToApply_Stims=get(handles.TraceSelector_Stims,'Value');
TracesToApply_BinSpikes=get(handles.TraceSelector_BinSpikes,'Value');


%%%%%%%%%%%%%

first_stim=str2double(get(handles.First_Stim,'String'));
last_stim=str2double(get(handles.Last_Stim,'String'));
first_stim_in_detstim=str2double(get(handles.First_Stim_In_Detstim,'String')); %this is the rank of the stim in TracesToApply_Stims corresponding to first_stim (rank of first stim to analyze in DLPstim, usually 1)
lag=str2double(get(handles.Lag,'String'))/1000; %converting to s

savefigs=get(handles.SaveFigs,'Value');

NoDLP=get(handles.DLPNotLoaded,'Value');

if NoDLP==1
    Savedxin=ones(size(SpikeTraceData(TracesToApply_Stims).XVector));
    Savedyin=ones(size(SpikeTraceData(TracesToApply_Stims).XVector));
else
    Savedxin=DLPstim.SaveParam.Savedxin;
    Savedyin=DLPstim.SaveParam.Savedyin;
end

binsize=SpikeTraceData(TracesToApply_BinStims).XVector(2)-SpikeTraceData(TracesToApply_BinStims).XVector(1); %in sec

Stims_array_2_psth=sort_stimuli_psth(Savedxin,Savedyin,SpikeTraceData(TracesToApply_Stims).XVector,SpikeTraceData(TracesToApply_BinStims).Trace,SpikeTraceData(TracesToApply_BinSpikes).Trace,lag,first_stim,last_stim,first_stim_in_detstim,binsize,handles);

if savefigs

 basename=[savefile '_ep' int2str(savefile_epstart) '-' int2str(savefile_eplast)]
 fig_fig=[basename '_psth-vs-stim-location' '.fig'];
 fig_tiff=[basename '_psth-vs-stim-location' '.tif'];
 print(555,'-dtiff',fig_tiff);
 saveas(555,fig_fig);
 
 psth_int=[basename '_psth_int' '.mat'];
 save(psth_int,'SpikeImageData');

end

ValidateValues_Callback(hObject, eventdata, handles);

%%%%%%%%%%%%


%make PSTHs after sorting stimuli according to location of light stimulus
%this version works for single squares/stimuli only
function Stims_array = sort_stimuli_psth(Savedxin, Savedyin, stimontimes_def, binstimtimes, binspiketimes, lag,first_stim, last_stim,first_stim_in_detstim,binsize,handles)

    clear Stims_array
    clear spikes_ind
    clear vec_x
    clear vec_y
    
global SpikeImageData
    
start1=str2double(get(handles.start1,'String'))/1000; % converting to s
dur1=str2double(get(handles.dur1,'String'))/1000; % converting to s
start2=str2double(get(handles.start2,'String'))/1000; % converting to s
dur2=str2double(get(handles.dur2,'String'))/1000; % converting to s
start3=str2double(get(handles.start3,'String'))/1000; % converting to s
dur3=str2double(get(handles.dur3,'String'))/1000; % converting to s

    
    %copy to vectors for ease of manipulation:
    vec_x = zeros(length(Savedxin),1);
    vec_y = zeros(length(Savedxin),1);
    
    for i = 1:length(Savedxin)
        vec_x(i)=Savedxin{i};
        vec_y(i)=Savedyin{i};
    end
    
    max_x=max(vec_x);
    max_y=max(vec_y);
    
    % create an array in which the case of coords x,y
    % will contain the list of stims associated with stim x,y
    %(ie the indices of this particular x,y combination)
    
    Stims_array = cell(max_x,max_y);
    
    for i=1:max_x
        for j=1:max_y
            Stims_array{i,j}.list={};
        end
    end
    
    stim_lag = first_stim_in_detstim-first_stim; 
    % if for ex. first_stim (in DLPstim sequence of stims) is 3, and
    % this corresponds to the first stim detected by the photodiode (ie
    % first_stim_in_detstim=1), stim_lag = -2.
    % Then the stimulus rank that will get written in the corresponding cell
    % in Stims_arrays below is 1.
    
   
    
    for n=first_stim:last_stim
        Stims_array{vec_x(n),vec_y(n)}.list{end+1}=n+stim_lag;
    end
    
%     global Stims_array
    
    %%%%
   
    
    z=1;
    
% global indmin
% global indmax
% global a
% global b

%initialize 3 max_x-by-max_y images that will contain colormaps based on the integrated
%PSTHS:

if isempty(SpikeImageData)
    InitImages();
    BeginImage=1;
else
    BeginImage=length(SpikeImageData)+1;
end

for k=0:4
 
    
    SpikeImageData(BeginImage+k).DataSize=[max_x max_y];
    
    SpikeImageData(BeginImage+k).Path='';
    SpikeImageData(BeginImage+k).Filename=''; 
    SpikeImageData(BeginImage+k).Xposition=[1:max_x];
    SpikeImageData(BeginImage+k).Yposition=[1:max_y];
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
   
    for i=1:max_x
        for j=1:max_y
            
            sz=size(Stims_array{i,j}.list,2);
            
            if sz>0
                
                tempstims=zeros(1);
                tempspikes=zeros(1);
              
                
                for k=1:sz  %loop over stimuli corresponding to the same stim location (=listed in the same Stims_array cell) to stitch together binned stims and spikes
                  
                    tmin = stimontimes_def(Stims_array{i,j}.list{k})-lag;
                    tmax = stimontimes_def(Stims_array{i,j}.list{k})+lag;
                    
                    indmin=ceil(tmin/binsize);
                    indmax=ceil(tmax/binsize);
                    a=size(binstimtimes);
                    b=size(binspiketimes);
                    
                    tempstims = [tempstims; binstimtimes(max(1,indmin):min(indmax,length(binstimtimes)))];
                    tempspikes = [tempspikes; binspiketimes(max(1,indmin):min(indmax,length(binspiketimes)))];
                    
                    
                end
                
                figure(555);
                subplot(max_x,max_y,z)
                [ccs,lags]=xcorr(tempspikes(:),tempstims(:),floor(lag/binsize));
                
                xminlag=-floor(lag/binsize);
                xmaxlag=floor(lag/binsize);
                
                stem(lags,ccs/(sum(tempstims)*binsize),'k.-','Markersize',0)  %correlation divided by number of stimuli and by binsize in s -> firing rate in Hz
                axis([xminlag xmaxlag 0 10+max(ccs/(sum(tempstims)*binsize))])
                xlabel('time (bins)')
                ylabel('firing rate (Hz)')
                hold on
                  
                sum_psth1=integrate_psth(ccs,binsize,start1,start1+dur1);    
                sum_psth2=integrate_psth(ccs,binsize,start2,start2+dur2);   
                sum_psth3=integrate_psth(ccs,binsize,start3,start3+dur3);   
                
                SpikeImageData(BeginImage).Image(i,j)=sum_psth1;
                SpikeImageData(BeginImage+1).Image(i,j)=sum_psth2;
                SpikeImageData(BeginImage+2).Image(i,j)=sum_psth3;
                SpikeImageData(BeginImage+3).Image(i,j)=sum_psth2/sum_psth1;
                SpikeImageData(BeginImage+4).Image(i,j)=sum_psth3/sum_psth1;
                
            end
            
            %%%
            
            z=z+1;
        end
        
    end
    
    %  fig_fig=[basename 'rasters-vs-stim-location' '.fig'];
    %  fig_tiff=[basename 'rasters-vs-stim-location' '.tif'];
    %  print(323,'-dtiff',fig_tiff);
    %  saveas(323,fig_fig);
   
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



function First_Stim_Callback(hObject, eventdata, handles)
% hObject    handle to First_Stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of First_Stim as text
%        str2double(get(hObject,'String')) returns contents of First_Stim as a double


% --- Executes during object creation, after setting all properties.
function First_Stim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to First_Stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TraceSelector_BinStims.
function TraceSelector_BinStims_Callback(hObject, eventdata, handles)
% hObject    handle to TraceSelector_BinStims (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TraceSelector_BinStims contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TraceSelector_BinStims



% --- Executes during object creation, after setting all properties.
function TraceSelector_BinStims_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TraceSelector_BinStims (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TraceSelector_BinStims.
function TraceSelector_Stims_Callback(hObject, eventdata, handles)
% hObject    handle to TraceSelector_BinStims (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TraceSelector_BinStims contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TraceSelector_BinStims

global SpikeTraceData
global TracesToApply_Stims
TracesToApply_Stims=get(handles.TraceSelector_BinStims,'Value');

stimsdet_size=SpikeTraceData(TracesToApply_Stims).DataSize(1);
stimsdlp_size=str2num(get(handles.Last_Stim,'String'));
stims_size=min(stimsdet_size,stimsdlp_size); %analysis impossible for more stims than recorded in DLPstim
set(handles.Last_Stim,'String',num2str(stims_size));


% --- Executes during object creation, after setting all properties.
function TraceSelector_Stims_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TraceSelector_BinStims (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Last_Stim_Callback(hObject, eventdata, handles)
% hObject    handle to Last_Stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Last_Stim as text
%        str2double(get(hObject,'String')) returns contents of Last_Stim as a double


% --- Executes during object creation, after setting all properties.
function Last_Stim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Last_Stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
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



% --- Executes on selection change in TraceSelector_BinSpikes.
function TraceSelector_BinSpikes_Callback(hObject, eventdata, handles)
% hObject    handle to TraceSelector_BinSpikes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TraceSelector_BinSpikes contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TraceSelector_BinSpikes


% --- Executes during object creation, after setting all properties.
function TraceSelector_BinSpikes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TraceSelector_BinSpikes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function First_Stim_In_Detstim_Callback(hObject, eventdata, handles)
% hObject    handle to First_Stim_In_Detstim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of First_Stim_In_Detstim as text
%        str2double(get(hObject,'String')) returns contents of First_Stim_In_Detstim as a double


% --- Executes during object creation, after setting all properties.
function First_Stim_In_Detstim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to First_Stim_In_Detstim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DLPNotLoaded.
function DLPNotLoaded_Callback(hObject, eventdata, handles)
% hObject    handle to DLPNotLoaded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DLPNotLoaded



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
