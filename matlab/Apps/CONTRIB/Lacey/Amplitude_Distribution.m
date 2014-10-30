function varargout = Amplitude_Distribution(varargin)
% AMPLITUDE_DISTRIBUTION This App aligns one or more traces to points given in the
% binary alignment trace. Any point in the alignment trace with a 1 will be
% an alignment point, and all trace fragments surrounding an alignment
% point will be laid on top of one another. Useful for traces which contain
% multiple repeats of the same experiment, cue, or action.
%
% Output will save as many traces as are input; each will be of length (#
% frames before) + 1 + (# frames after), as set in the GUI.
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Amplitude_Distribution

% Last Modified by GUIDE v2.5 08-Oct-2012 09:17:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Amplitude_Distribution_OpeningFcn, ...
                   'gui_OutputFcn',  @Amplitude_Distribution_OutputFcn, ...
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


% This function is created by GUIDE for every GUI. Just put here all
% the code that you want to be executed before the GUI is made visible. 
function Amplitude_Distribution_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Amplitude_Distribution (see VARARGIN)

% Choose default command line output for Amplitude_Distribution
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeTraceData

if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.SignalTraceSelector,'String',TextTrace);
    set(handles.EventTraceSelector, 'String', TextTrace);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.SignalTraceSelector,'Value',Settings.TraceSelectorValue);
    set(handles.EventTraceSelector,'Value',Settings.AlignTraceSelectorValue);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorValue=get(handles.SignalTraceSelector,'Value');
Settings.AlignTraceSelectorValue=get(handles.EventTraceSelector,'Value');



% --- Outputs from this function are returned to the command line.
function varargout = Amplitude_Distribution_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.output;


% 'ApplyApps' is the main function of your Apps. It is launched by the
% Main interface when using batch mode. 
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SpikeTraceData

try
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    signalTraces=get(handles.SignalTraceSelector, 'Value');
    eventTraces=get(handles.EventTraceSelector, 'Value');
    beginTime=str2double(get(handles.BeginTime, 'String'));
    endTime=str2double(get(handles.EndTime, 'String'));
    
    if length(signalTraces)~=length(eventTraces)
        error('Must select same number of signal traces and event traces!')
    end
    
    global meanRates
    global meanAmps
    global allAmps
    
    meanRates=zeros(1,length(signalTraces));
    meanAmps=zeros(1,length(signalTraces));
    amps=cell(1,length(signalTraces));
    
    numEvents=0;
    for ind=1:length(signalTraces)
        sigInd=signalTraces(ind);
        evInd=eventTraces(ind);
        sigTrace=SpikeTraceData(sigInd).Trace;
        evTrace=SpikeTraceData(evInd).Trace;
        timeTrace=SpikeTraceData(evInd).XVector;
        sigTrace=sigTrace(and(timeTrace>=beginTime, timeTrace<=endTime));
        evTrace=evTrace(and(timeTrace>=beginTime, timeTrace<=endTime));
        totalTime=min(endTime,timeTrace(end))-max(beginTime, timeTrace(1));
        if length(sigTrace)~=length(evTrace)
            error('Signal traces and event traces must all be the same length!')
        end
        
        meanRates(ind)=sum(evTrace)/totalTime;
        
        evTimes=find(evTrace(1:(end-5)))+5;
        numEvents=numEvents+length(evTimes);
        if size(evTimes,1)~=1
            evTimes=evTimes';
        end
        amps{ind}=zeros(1,length(evTimes));
        if ~isempty(evTimes)
            for tInd=1:length(evTimes)
                evTime=evTimes(tInd);
                amps{ind}(tInd)=max(sigTrace(evTime:min(evTime+10, length(sigTrace))));
            end
        end
        
        meanAmps(ind)=mean(amps{ind});
    end
    
    allAmps=zeros(1,numEvents);
    
    evInd=1;
    for ind=1:length(signalTraces)
        allAmps(evInd:(evInd+length(amps{ind})-1))=amps{ind};
        evInd=evInd+length(amps{ind});
    end 
    
    k=2;
    figure(13)
    %subplot(2,1,k)
    set(gca(), 'FontSize', 14)
    hist(100*meanAmps,0:10:300)
    %xlim([0 300])
    %ylim([0 180])
    xlabel('Mean Amplitude (% dF/F)')
    ylabel('Number of cells')
    
    figure(14)
    %subplot(2,1,k)
    set(gca(), 'FontSize', 14)
    hist(meanRates,0:0.0025:0.08)
    %xlim([0 0.08])
    %ylim([0 120])
    xlabel('Mean Rate (hz)')
    ylabel('Number of cells')
    
    figure(15)
    %subplot(2,1,k)
    set(gca(), 'FontSize', 14)
    plot(meanRates, 100*meanAmps,'.')
    %xlim([0 0.08])
    %ylim([0 300])
    xlabel('Mean Rate (hz)')
    ylabel('Mean Amplitude (%dF/F)')
    
    figure(16)
    %subplot(2,1,k)
    set(gca(), 'FontSize', 14)
    hist(100*allAmps, 0:10:300)
    %xlim([0 300])
    %ylim([0 1500])
    xlabel('Amplitude (% dF/F)')
    ylabel('Number of events')
    
    
    hAllAmp=hist(100*allAmps, 0:10:500);
    hMeanAmp=hist(100*meanAmps,0:10:500);
    hMeanRate=hist(meanRates,0:0.0025:0.15);
    numTraces=length(SpikeTraceData);
    SpikeTraceData(numTraces+1).Trace=hMeanAmp;
    SpikeTraceData(numTraces+1).XVector=0:10:500;
    SpikeTraceData(numTraces+1).Label.ListText='Mean Amplitude Histogram';
    SpikeTraceData(numTraces+1).Label.YLabel='Number cells';
    SpikeTraceData(numTraces+1).Label.YLabel='% dF/F';
    
    SpikeTraceData(numTraces+2).Trace=hMeanRate;
    SpikeTraceData(numTraces+2).XVector=0:0.0025:0.15; 
    SpikeTraceData(numTraces+2).Label.ListText='Mean Rate Histogram';
    SpikeTraceData(numTraces+2).Label.YLabel='Number cells';
    SpikeTraceData(numTraces+2).Label.YLabel='hz';
    
    SpikeTraceData(numTraces+3).Trace=hAllAmp;
    SpikeTraceData(numTraces+3).XVector=0:10:500;
    SpikeTraceData(numTraces+3).Label.ListText='All Amplitudes Histogram';
    SpikeTraceData(numTraces+3).Label.YLabel='Number events';
    SpikeTraceData(numTraces+3).Label.YLabel='% dF/F';
    
    numTraces=length(SpikeTraceData);
    SpikeTraceData(numTraces+1).Trace=allAmps;
    SpikeTraceData(numTraces+1).XVector=1:length(allAmps);
    SpikeTraceData(numTraces+1).Label.ListText='All Amplitudes';
    SpikeTraceData(numTraces+1).Label.YLabel='% dF/F';
    SpikeTraceData(numTraces+1).Label.YLabel='Event Number';
    
    SpikeTraceData(numTraces+2).Trace=hMeanRate;
    SpikeTraceData(numTraces+2).XVector=0:0.0025:0.15; 
    SpikeTraceData(numTraces+2).Label.ListText='Mean Amplitudes';
    SpikeTraceData(numTraces+2).Label.YLabel='% dF/F';
    SpikeTraceData(numTraces+2).Label.YLabel='Cell Number';
    
    SpikeTraceData(numTraces+3).Trace=hAllAmp;
    SpikeTraceData(numTraces+3).XVector=0:10:500;
    SpikeTraceData(numTraces+3).Label.ListText='Mean Rates';
    SpikeTraceData(numTraces+3).Label.YLabel='Hz';
    SpikeTraceData(numTraces+3).Label.YLabel='Cell Number';
    
    
    
    % We turn back on the interface
    set(InterfaceObj,'Enable','on');
    
    ValidateValues_Callback(hObject, eventdata, handles);
    
% In case of errors
catch errorObj
    % We turn back on the interface
    set(InterfaceObj,'Enable','on');
    
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
end


% 'ValidateValues' is executed in the end to trigger the end of your Apps and
% check all unneeded windows are closed.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% We give back control to the Main interface.
uiresume;


% This function opens the help that is written in the header of this M file.
function OpenHelp_Callback(hObject, eventdata, handles)
% hObject    handle to OpenHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CurrentMfilePath = mfilename('fullpath');
[PathToM, name, ext] = fileparts(CurrentMfilePath);
eval(['doc ',name]);



% --- Executes on selection change in SignalTraceSelector.
function SignalTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to SignalTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SignalTraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SignalTraceSelector


% --- Executes during object creation, after setting all properties.
function SignalTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SignalTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in EventTraceSelector.
function EventTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to EventTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns EventTraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from EventTraceSelector


% --- Executes during object creation, after setting all properties.
function EventTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EventTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MedianTimepoints_Callback(hObject, eventdata, handles)
% hObject    handle to MedianTimepoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MedianTimepoints as text
%        str2double(get(hObject,'String')) returns contents of MedianTimepoints as a double


% --- Executes during object creation, after setting all properties.
function MedianTimepoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MedianTimepoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DoOrdFilt.
function DoOrdFilt_Callback(hObject, eventdata, handles)
% hObject    handle to DoOrdFilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DoOrdFilt



function BeginTime_Callback(hObject, eventdata, handles)
% hObject    handle to BeginTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BeginTime as text
%        str2double(get(hObject,'String')) returns contents of BeginTime as a double


% --- Executes during object creation, after setting all properties.
function BeginTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BeginTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EndTime_Callback(hObject, eventdata, handles)
% hObject    handle to EndTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EndTime as text
%        str2double(get(hObject,'String')) returns contents of EndTime as a double


% --- Executes during object creation, after setting all properties.
function EndTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EndTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
