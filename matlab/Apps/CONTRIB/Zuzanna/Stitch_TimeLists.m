function varargout = Stitch_TimeLists(varargin)
% STITCH_TIMELISTS M-file for Stitch_TimeLists.fig
%      STITCH_TIMELISTS, by itself, creates a new STITCH_TIMELISTS or raises the existing
%      singleton*.
%
%      H = STITCH_TIMELISTS returns the handle to a new STITCH_TIMELISTS or the handle to
%      the existing singleton*.
%
%      STITCH_TIMELISTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STITCH_TIMELISTS.M with the given input arguments.
%
%      STITCH_TIMELISTS('Property','Value',...) creates a new STITCH_TIMELISTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Stitch_TimeLists_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Stitch_TimeLists_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Stitch_TimeLists

% Last Modified by GUIDE v2.5 04-Jun-2012 16:31:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Stitch_TimeLists_OpeningFcn, ...
                   'gui_OutputFcn',  @Stitch_TimeLists_OutputFcn, ...
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


% --- Executes just before Stitch_TimeLists is made visible.
function Stitch_TimeLists_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Stitch_TimeLists (see VARARGIN)

% Choose default command line output for Stitch_TimeLists
handles.output = hObject;

% add one new field used for passing data between functions below:
handles.Traces_LUT = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Stitch_TimeLists wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global SpikeTraceData;

if (length(varargin)>1)
    Settings=varargin{2};
%     set(handles.TraceSelector,'String',Settings.TraceSelectorString);
%     set(handles.TraceSelector,'Value',Settings.TraceSelectorValue);
    set(handles.Group,'Value',Settings.GroupValue);
    set(handles.Group_Text,'String',Settings.GroupTextString);
    set(handles.TrashPieces,'Value',Settings.TrashPiecesValue);


TextTrace{1}='All Traces';
if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i+1}=['Trace ',num2str(i)];
    end
    set(handles.TraceSelector,'String',TextTrace);
end
    
end


% --- Outputs from this function are returned to the command line.
function varargout = Stitch_TimeLists_OutputFcn(hObject, eventdata, handles) 
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
Settings.GroupValue=get(handles.Group,'Value');
Settings.GroupTextString=get(handles.Group_Text,'String');
Settings.TrashPiecesValue=get(handles.TrashPieces,'Value');



% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeTraceData;

BeginTrace=length(SpikeTraceData)+1;

Trace_indices=get(handles.TraceSelector,'Value');

tot=length(Trace_indices);

TracesToApply=zeros(1,tot);

traces_LUT=handles.Traces_LUT;

for i=1:tot
TracesToApply(i) = traces_LUT(Trace_indices(i));
end

Stitch(BeginTrace,TracesToApply,handles);
ValidateValues_Callback(hObject, eventdata, handles);



% this function does the big job, ie generating a new trace from the list
% of traces to stitch
function Stitch(BeginTrace,TracesToApply,handles)
global SpikeTraceData;


SpikeTraceData(BeginTrace).DataSize = 0;
SpikeTraceData(BeginTrace).Trace=[];


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

h=waitbar(0,'Stitching traces...');
for k=TracesToApply
  
    addend=SpikeTraceData(k).DataSize;  
    SpikeTraceData(BeginTrace).Trace(newend+1:newend+addend,1)=SpikeTraceData(k).Trace(1:addend,1); 
    SpikeTraceData(BeginTrace).XVector(newend+1:newend+addend,1)=SpikeTraceData(k).XVector(1:addend,1);
    newend=newend+SpikeTraceData(k).DataSize;


    waitbar(k/length(TracesToApply));
end
SpikeTraceData(BeginTrace).XVector=sort(SpikeTraceData(BeginTrace).XVector);
name='stitched times';
SpikeTraceData(BeginTrace).Label.ListText=name;
SpikeTraceData(BeginTrace).Label.YLabel=SpikeTraceData(TracesToApply(1)).Label.YLabel;
SpikeTraceData(BeginTrace).Label.XLabel=SpikeTraceData(TracesToApply(1)).Label.XLabel;
SpikeTraceData(BeginTrace).Filename=SpikeTraceData(TracesToApply(1)).Filename;
SpikeTraceData(BeginTrace).Path=SpikeTraceData(TracesToApply(1)).Path;

close(h);


% --- Executes on button press in ValidateValues.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;


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


function Group_Callback(hObject, eventdata, handles)
% hObject    handle to Group (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Group as text
%        str2double(get(hObject,'String')) returns contents of Group as a double

global SpikeTraceData

group=get(handles.Group,'Value');

set(handles.Group_Text,'String',num2str(group));


tot=length(SpikeTraceData);
traces_LUT=zeros(1,tot);

if ~isempty(SpikeTraceData)
    j=1;
    for k=1:group   
        for i=k:group:tot
            TextTrace{j}=['Trace ',num2str(i)];
            traces_LUT(j)=i;
            j=j+1;
        end
        
    end;
    set(handles.TraceSelector,'String',TextTrace);
    handles.Traces_LUT=traces_LUT;
    % Update handles structure
    guidata(handles.output, handles);
   
    
   
 
end




% --- Executes during object creation, after setting all properties.
function Group_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Group (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TrashPieces.
function TrashPieces_Callback(hObject, eventdata, handles)
% hObject    handle to TrashPieces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TrashPieces



function Group_Text_Callback(hObject, eventdata, handles)
% hObject    handle to Group_Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Group_Text as text
%        str2double(get(hObject,'String')) returns contents of Group_Text as a double


% --- Executes during object creation, after setting all properties.
function Group_Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Group_Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
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

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
