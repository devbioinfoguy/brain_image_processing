function varargout = Traces_Viewer(varargin)
% TRACES_VIEWER MATLAB code for Traces_Viewer.fig
%      TRACES_VIEWER, by itself, creates a new TRACES_VIEWER or raises the existing
%      singleton*.
%
%      H = TRACES_VIEWER returns the handle to a new TRACES_VIEWER or the handle to
%      the existing singleton*.
%
%      TRACES_VIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACES_VIEWER.M with the given input arguments.
%
%      TRACES_VIEWER('Property','Value',...) creates a new TRACES_VIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Traces_Viewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Traces_Viewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Traces_Viewer

% Last Modified by GUIDE v2.5 10-Jul-2012 20:24:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Traces_Viewer_OpeningFcn, ...
                   'gui_OutputFcn',  @Traces_Viewer_OutputFcn, ...
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


% --- Executes just before Traces_Viewer is made visible.
function Traces_Viewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Traces_Viewer (see VARARGIN)
global SpikeTraceData;

% Choose default command line output for Traces_Viewer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Traces_Viewer wait for user response (see UIRESUME)
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
    set(handles.UseYChoice,'Value',Settings.UseYChoiceValue);
    set(handles.TraceColor,'Value',Settings.TraceColorValue);
    set(handles.DispLegend,'Value',Settings.DispLegendValue);
    set(handles.TraceOffsetY,'String',Settings.TraceOffsetYString);
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
Settings.UseYChoiceValue=get(handles.UseYChoice,'Value');
Settings.TraceColorValue=get(handles.TraceColor,'Value');
Settings.DispLegendValue=get(handles.DispLegend,'Value');
Settings.TraceOffsetYString=get(handles.TraceOffsetY,'String');



% --- Outputs from this function are returned to the command line.
function varargout = Traces_Viewer_OutputFcn(hObject, eventdata, handles) 
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
if isfield(handles,'hFigImage')
    if (ishandle(handles.hFigImage))
        delete(handles.hFigImage);
    end
end
uiresume;


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeTraceData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    % We turn it back on in the end
    Cleanup1=onCleanup(@()set(InterfaceObj,'Enable','on'));
    
    if (isfield(handles,'hFigImage') && ~isempty(handles.hFigImage) && ishandle(handles.hFigImage))
        figure(handles.hFigImage);
    else
        handles.hFigImage=figure('Name','Traces Viewer','NumberTitle','off');
    end
    
    if (get(handles.SelectAllTraces,'Value')==1)
        TraceSel=1:length(SpikeTraceData);
    else
        TraceSel=get(handles.TraceSelector,'Value');
    end
    guidata(hObject, handles);

    NumberSelTraces=length(TraceSel);
    CurrentSize=SpikeTraceData(TraceSel(1)).DataSize;
        
    % waitbar is consuming too much ressources, so I divide its acces
    dividerWaitbar=10^(floor(log10(NumberSelTraces))-1);
    
    UseYRaw=get(handles.UseYChoice,'Value');
    OffsetValue=str2double(get(handles.TraceOffsetY,'String'));
    ColorChoice=get(handles.TraceColor,'Value');
        DispLegend=get(handles.DispLegend,'Value');

    ColorMat=get(gca,'ColorOrder');
    
    % We check the homogeneity of siee
    for i=1:numel(TraceSel)
        TraceNumber=TraceSel(i);
        if UseYRaw==1
            LocalTrace=SpikeTraceData(TraceNumber).Trace;
        else
            LocalTrace=OffsetValue*(i-1)+SpikeTraceData(TraceNumber).Trace-mean(SpikeTraceData(TraceNumber).Trace);
        end
        if ColorChoice==1
            colorLocal='k';
        else
            IndexColor=mod(i,size(ColorMat,1))+1;
            colorLocal=ColorMat(IndexColor,:);
        end
        if DispLegend
            LegendData{i}=SpikeTraceData(TraceNumber).Label.ListText;
        end
        plot(SpikeTraceData(TraceNumber).XVector,LocalTrace,'color',colorLocal);
        hold on;
    end
    hold off;
    
    if DispLegend
        legend(LegendData);
    end
    xlabel(SpikeTraceData(TraceSel(1)).Label.XLabel);
    ylabel(SpikeTraceData(TraceSel(1)).Label.YLabel);
    drawnow;
    
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



function TraceOffsetY_Callback(hObject, eventdata, handles)
% hObject    handle to TraceOffsetY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TraceOffsetY as text
%        str2double(get(hObject,'String')) returns contents of TraceOffsetY as a double


% --- Executes during object creation, after setting all properties.
function TraceOffsetY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TraceOffsetY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in UseYChoice.
function UseYChoice_Callback(hObject, eventdata, handles)
% hObject    handle to UseYChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns UseYChoice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from UseYChoice


% --- Executes during object creation, after setting all properties.
function UseYChoice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UseYChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TraceColor.
function TraceColor_Callback(hObject, eventdata, handles)
% hObject    handle to TraceColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TraceColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TraceColor


% --- Executes during object creation, after setting all properties.
function TraceColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TraceColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DispLegend.
function DispLegend_Callback(hObject, eventdata, handles)
% hObject    handle to DispLegend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DispLegend
