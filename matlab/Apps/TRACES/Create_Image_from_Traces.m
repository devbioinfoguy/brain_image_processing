function varargout = Create_Image_from_Traces(varargin)
% CREATE_IMAGE_FROM_TRACES MATLAB code for Create_Image_from_Traces.fig
%      CREATE_IMAGE_FROM_TRACES, by itself, creates a new CREATE_IMAGE_FROM_TRACES or raises the existing
%      singleton*.
%
%      H = CREATE_IMAGE_FROM_TRACES returns the handle to a new CREATE_IMAGE_FROM_TRACES or the handle to
%      the existing singleton*.
%
%      CREATE_IMAGE_FROM_TRACES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATE_IMAGE_FROM_TRACES.M with the given input arguments.
%
%      CREATE_IMAGE_FROM_TRACES('Property','Value',...) creates a new CREATE_IMAGE_FROM_TRACES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Create_Image_from_Traces_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Create_Image_from_Traces_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Create_Image_from_Traces

% Last Modified by GUIDE v2.5 09-Apr-2012 19:44:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Create_Image_from_Traces_OpeningFcn, ...
                   'gui_OutputFcn',  @Create_Image_from_Traces_OutputFcn, ...
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


% --- Executes just before Create_Image_from_Traces is made visible.
function Create_Image_from_Traces_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Create_Image_from_Traces (see VARARGIN)
global SpikeTraceData;

% Choose default command line output for Create_Image_from_Traces
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Create_Image_from_Traces wait for user response (see UIRESUME)
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
else
    set(handles.TraceSelector,'Value',[]);
end

SelectAllTraces_Callback(hObject, eventdata, handles);


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');
Settings.SelectAllTracesValue=get(handles.SelectAllTraces,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Create_Image_from_Traces_OutputFcn(hObject, eventdata, handles) 
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
    
    NumberSelTraces=length(TraceSel);
    CurrentSize=SpikeTraceData(TraceSel(1)).DataSize;
        
    % waitbar is consuming too much ressources, so I divide its acces
    dividerWaitbar=10^(floor(log10(NumberSelTraces))-1);
    
    % We check the homogeneity of siee
    ImageTrace=zeros(NumberSelTraces,max(CurrentSize));
    for i=1:numel(TraceSel)
        TraceNumber=TraceSel(i);
        CurrentSize=SpikeTraceData(TraceNumber).DataSize;
        if any(SpikeTraceData(TraceNumber).DataSize-CurrentSize)
            error('Selected traces must be of the same size');
        end
        ImageTrace(i,:)=SpikeTraceData(TraceNumber).Trace(:);
        
        if (round(i/dividerWaitbar)==i/dividerWaitbar)
            waitbar(i/NumberSelTraces,h);
        end
    end
    
    CurrentNbImage=length(SpikeImageData);
    
    SpikeImageData(CurrentNbImage+1).Image=ImageTrace;
    SpikeImageData(CurrentNbImage+1).Path='';
    SpikeImageData(CurrentNbImage+1).Filename='';
    SpikeImageData(CurrentNbImage+1).DataSize=size(SpikeImageData(CurrentNbImage+1).Image);
    
    [SpikeImageData(CurrentNbImage+1).Xposition,SpikeImageData(CurrentNbImage+1).Yposition] ...
        = meshgrid(SpikeTraceData(TraceSel(1)).XVector,TraceSel);
    SpikeImageData(CurrentNbImage+1).Zposition(:,:)=zeros(size(SpikeImageData(CurrentNbImage+1).Xposition));
    
    SpikeImageData(CurrentNbImage+1).Xposition;
    SpikeImageData(CurrentNbImage+1).Yposition;
    SpikeImageData(CurrentNbImage+1).Zposition;
    SpikeImageData(CurrentNbImage+1).Label.ListText='Image of traces';
    SpikeImageData(CurrentNbImage+1).Label.XLabel=SpikeTraceData(TraceSel(1)).Label.XLabel;
    SpikeImageData(CurrentNbImage+1).Label.YLabel='Trace number';
    SpikeImageData(CurrentNbImage+1).Label.ZLabel='';
    SpikeImageData(CurrentNbImage+1).Label.CLabel=SpikeTraceData(TraceSel(1)).Label.YLabel;
    
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
