function varargout = Normalize_Traces(varargin)
% NORMALIZE_TRACES MATLAB code for Normalize_Traces.fig
%      NORMALIZE_TRACES, by itself, creates a new NORMALIZE_TRACES or raises the existing
%      singleton*.
%
%      H = NORMALIZE_TRACES returns the handle to a new NORMALIZE_TRACES or the handle to
%      the existing singleton*.
%
%      NORMALIZE_TRACES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NORMALIZE_TRACES.M with the given input arguments.
%
%      NORMALIZE_TRACES('Property','Value',...) creates a new NORMALIZE_TRACES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Normalize_Traces_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Normalize_Traces_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Normalize_Traces

% Last Modified by GUIDE v2.5 02-Nov-2012 13:41:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Normalize_Traces_OpeningFcn, ...
                   'gui_OutputFcn',  @Normalize_Traces_OutputFcn, ...
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


% --- Executes just before Normalize_Traces is made visible.
function Normalize_Traces_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Normalize_Traces (see VARARGIN)
global SpikeTraceData;

% Choose default command line output for Normalize_Traces
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Normalize_Traces wait for user response (see UIRESUME)
% uiwait(handles.figure1);
NumberTraces=length(SpikeTraceData);

if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.TraceSelector,'String',TextTrace);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.TraceSelector,'Value',intersect(1:NumberTraces,Settings.TraceSelectorValue));
    set(handles.SelectAllTraces,'Value',Settings.SelectAllTracesValue);
    set(handles.NormalizationMode,'Value',Settings.NormalizationModeValue);
    set(handles.NormFactor,'String',num2str(Settings.NormFactorValue));
else
    set(handles.TraceSelector,'Value',[]);
end

if (get(handles.NormalizationMode,'Value')==1)
    set(handles.NormFactor,'Enable','on');
else
    set(handles.NormFactor,'Enable','off');
end

SelectAllTraces_Callback(hObject, eventdata, handles);


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');
Settings.SelectAllTracesValue=get(handles.SelectAllTraces,'Value');
Settings.TracesValue=get(handles.SelectAllTraces,'Value');
Settings.NormalizationModeValue=get(handles.NormalizationMode,'Value');
Settings.NormFactorValue=str2double(get(handles.NormFactor,'String'));


% --- Outputs from this function are returned to the command line.
function varargout = Normalize_Traces_OutputFcn(hObject, eventdata, handles) 
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
global SpikeImageData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
        % We turn it back on in the end
    Cleanup1=onCleanup(@()set(InterfaceObj,'Enable','on'));

    h=waitbar(0,'Creating iamge...');
    
    % We close it in the end
    Cleanup2=onCleanup(@()delete(h));
    
    if (get(handles.SelectAllTraces,'Value')==1)
        TraceSel=1:length(SpikeTraceData);
    else
        TraceSel=get(handles.TraceSelector,'Value');
    end
    
    NMode=get(handles.NormalizationMode,'Value'); 
    %    1=Normalize by number
    %    2=Normalize each trace by its max
    %    3=Normalize each trace by global max
    NFactor=0;
    switch NMode
        case 1 
            NFactor=str2double(get(handles.NormFactor,'String'));
        case 2
            NFactor=1;
        case 3
             for i=1:numel(TraceSel)
                TraceNumber=TraceSel(i);
                NFactor=max(max(SpikeTraceData(TraceNumber).Trace(:)), NFactor);
             end 
    end
    
    

    
    NumberSelTraces=length(TraceSel);
    CurrentSize=SpikeTraceData(TraceSel(1)).DataSize;
        
    % waitbar is consuming too much ressources, so I divide its acces
    dividerWaitbar=10^(floor(log10(NumberSelTraces))-1);
    
    
    
    % We check the homogeneity of siee
    for i=1:numel(TraceSel)
        TraceNumber=TraceSel(i);
        
        if(NMode==2)
            NFactor=max(SpikeTraceData(TraceNumber).Trace(:));
        end
        
        SpikeTraceData(TraceNumber).Trace=SpikeTraceData(TraceNumber).Trace/NFactor;
               
        
        if (round(i/dividerWaitbar)==i/dividerWaitbar)
            waitbar(i/NumberSelTraces,h);
        end
    end
    
    ValidateValues_Callback(hObject, eventdata, handles);
    
catch errorObj
    % If there is a problem, we display the error message and bring back
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
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


% --- Executes during object creation, after setting all properties.
function ValidateValues_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in SelectAllTraces.
function SelectAllTraces_Callback(hObject, eventdata, handles)
% hObject    handle to SelectAllTraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SelectAllTraces
if (get(handles.SelectAllTraces,'Value')==1)
    set(handles.TraceSelector,'Enable','off');
else
    set(handles.TraceSelector,'Enable','on');
end


% --- Executes on selection change in NormalizationMode.
function NormalizationMode_Callback(hObject, eventdata, handles)
% hObject    handle to NormalizationMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NormalizationMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NormalizationMode
if (get(handles.NormalizationMode,'Value')==1)
    set(handles.NormFactor,'Enable','on');
else
    set(handles.NormFactor,'Enable','off');
end



% --- Executes during object creation, after setting all properties.
function NormalizationMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NormalizationMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NormFactor_Callback(hObject, eventdata, handles)
% hObject    handle to NormFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NormFactor as text
%        str2double(get(hObject,'String')) returns contents of NormFactor as a double


% --- Executes during object creation, after setting all properties.
function NormFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NormFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
