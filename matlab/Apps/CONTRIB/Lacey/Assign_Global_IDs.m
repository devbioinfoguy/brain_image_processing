function varargout = Assign_Global_IDs(varargin)
% ASSIGN_GLOBAL_IDS This App aligns one or more traces to points given in the
% binary alignment trace. Any point in the alignment trace with a 1 will be
% an alignment point, and all trace fragments surrounding an alignment
% point will be laid on top of one another. Useful for traces which contain
% multiple repeats of the same experiment, cue, or action.
%
% Output will save as many traces as are input; each will be of length (#
% frames before) + 1 + (# frames after), as set in the GUI.
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Assign_Global_IDs

% Last Modified by GUIDE v2.5 02-Apr-2013 16:53:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Assign_Global_IDs_OpeningFcn, ...
                   'gui_OutputFcn',  @Assign_Global_IDs_OutputFcn, ...
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
function Assign_Global_IDs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Assign_Global_IDs (see VARARGIN)

% Choose default command line output for Assign_Global_IDs
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeTraceData

if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.GlobalTraceSelector,'String',TextTrace);
    set(handles.NonglobalTraceSelector, 'String', TextTrace);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.GlobalTraceSelector,'Value',Settings.TraceSelectorValue);
    set(handles.NonglobalTraceSelector,'Value',Settings.AlignTraceSelectorValue);
    set(handles.TraceTag, 'String', Settings.TimeBeforeString);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorValue=get(handles.GlobalTraceSelector,'Value');
Settings.AlignTraceSelectorValue=get(handles.NonglobalTraceSelector,'Value');
Settings.TimeBeforeString=get(handles.TraceTag, 'String');



% --- Outputs from this function are returned to the command line.
function varargout = Assign_Global_IDs_OutputFcn(hObject, eventdata, handles) 
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
    
    % get parameters from interface
    globalTraceInds=get(handles.GlobalTraceSelector, 'Value');
    nonGlobalTraceInds=get(handles.NonglobalTraceSelector, 'Value');
    dayTag=get(handles.TraceTag, 'String');
    numTraces=length(SpikeTraceData);
    
    usedDailyIDs=[];
    for i=1:length(globalTraceInds)
        traceInd=globalTraceInds(i);
        
        if ~and(isKey(SpikeTraceData(traceInd).ID, 'daily'), isKey(SpikeTraceData(traceInd).ID, 'global'))
            error('Traces do not have proper IDs')
        end
        
        thisDailyID=SpikeTraceData(traceInd).ID('daily');
        thisGlobalID=SpikeTraceData(traceInd).ID('global');
        
        if and(~ismember(thisDailyID, usedDailyIDs), thisDailyID~=0) 
            usedDailyIDs(end+1)=thisDailyID;
            dailyTraceInd=nonGlobalTraceInds(thisDailyID);

            SpikeTraceData(numTraces+i)=SpikeTraceData(dailyTraceInd);
            saveInd=numTraces+i;
            SpikeTraceData(saveInd).ID('daily')=thisDailyID;
            SpikeTraceData(saveInd).ID('global')=thisGlobalID;
            SpikeTraceData(saveInd).Label.ListText=['g ', num2str(thisGlobalID), ' ', dayTag, ' ', num2str(thisDailyID), ' ', SpikeTraceData(dailyTraceInd).Label.ListText];
        else
            SpikeTraceData(numTraces+i)=SpikeTraceData(traceInd);
        end
        
    end

    
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



% --- Executes on selection change in GlobalTraceSelector.
function GlobalTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to GlobalTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns GlobalTraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GlobalTraceSelector


% --- Executes during object creation, after setting all properties.
function GlobalTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GlobalTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in KeepGlobalTraces.
function KeepGlobalTraces_Callback(hObject, eventdata, handles)
% hObject    handle to KeepGlobalTraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KeepGlobalTraces



% --- Executes on selection change in NonglobalTraceSelector.
function NonglobalTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to NonglobalTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NonglobalTraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NonglobalTraceSelector


% --- Executes during object creation, after setting all properties.
function NonglobalTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NonglobalTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in KeepNonglobalTraces.
function KeepNonglobalTraces_Callback(hObject, eventdata, handles)
% hObject    handle to KeepNonglobalTraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KeepNonglobalTraces



function TraceTag_Callback(hObject, eventdata, handles)
% hObject    handle to TraceTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TraceTag as text
%        str2double(get(hObject,'String')) returns contents of TraceTag as a double


% --- Executes during object creation, after setting all properties.
function TraceTag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TraceTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
