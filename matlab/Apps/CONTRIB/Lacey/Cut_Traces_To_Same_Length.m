function varargout = Cut_Traces_To_Same_Length(varargin)
% CUT_TRACES_TO_SAME_LENGTH 
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Cut_Traces_To_Same_Length

% Last Modified by GUIDE v2.5 14-Jun-2012 14:36:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Cut_Traces_To_Same_Length_OpeningFcn, ...
                   'gui_OutputFcn',  @Cut_Traces_To_Same_Length_OutputFcn, ...
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
function Cut_Traces_To_Same_Length_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Cut_Traces_To_Same_Length (see VARARGIN)

% Choose default command line output for Cut_Traces_To_Same_Length
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeTraceData

if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.TraceSelector1,'String',TextTrace);
    set(handles.TraceSelector2, 'String', TextTrace);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.TraceSelector1,'String',Settings.TraceSelector1String);
    set(handles.TraceSelector1,'Value',Settings.TraceSelector1Value);
    set(handles.TraceSelector2,'String',Settings.TraceSelector2String);
    set(handles.TraceSelector2,'Value',Settings.TraceSelector2Value);
    set(handles.MaxLengthDifference, 'String', Settings.MaxLengthDifferenceString);
    set(handles.CuttingBehav, 'Value', Settings.CuttingBehavValue);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelector1String=get(handles.TraceSelector1,'String');
Settings.TraceSelector1Value=get(handles.TraceSelector1,'Value');
Settings.TraceSelector2String=get(handles.TraceSelector2,'String');
Settings.TraceSelector2Value=get(handles.TraceSelector2,'Value');
Settings.MaxLengthDifferenceString=get(handles.MaxLengthDifference, 'String');
Settings.CuttingBehavValue=get(handles.CuttingBehav, 'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Cut_Traces_To_Same_Length_OutputFcn(hObject, eventdata, handles) 
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
    traces1=get(handles.TraceSelector1, 'Value');
    traces2=get(handles.TraceSelector2, 'Value');
    
    if length(traces1)~=length(traces2)
        error('Must select same number of traces')
    end
    cutBehav=get(handles.CuttingBehav, 'Value');    % 1=cut end, 2=cut both
    maxDiff=str2double(get(handles.MaxLengthDifference, 'String'));
    
    for i=1:length(traces1)
        traceInd1=traces1(i);
        traceInd2=traces2(i);
        length1=length(SpikeTraceData(traceInd1).Trace);
        length2=length(SpikeTraceData(traceInd2).Trace);
        if abs(length1-length2)>maxDiff
            error('Traces differ by more than specified amount in length');
        end
        
        if length1>length2
            longerInd=traceInd1;
            shorterInd=traceInd2;
            lenDiff=length1-length2;
        else
            longerInd=traceInd2;
            shorterInd=traceInd1;
            lenDiff=length2-length1;
        end
        
        if cutBehav==1
            SpikeTraceData(longerInd).Trace=SpikeTraceData(longerInd).Trace(1:end-lenDiff);
            SpikeTraceData(longerInd).XVector=SpikeTraceData(longerInd).XVector(1:end-lenDiff);
        else
            SpikeTraceData(longerInd).Trace=SpikeTraceData(longerInd).Trace((ceil(lenDiff/2)+1):end-floor(lenDiff/2));
            SpikeTraceData(longerInd).XVector=SpikeTraceData(longerInd).XVector((ceil(lenDiff/2)+1):end-floor(lenDiff/2));
        end
        SpikeTraceData(longerInd).DataSize=size(SpikeTraceData(longerInd).Trace);

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



% --- Executes on selection change in TraceSelector1.
function TraceSelector1_Callback(hObject, eventdata, handles)
% hObject    handle to TraceSelector1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TraceSelector1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TraceSelector1


% --- Executes during object creation, after setting all properties.
function TraceSelector1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TraceSelector1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TraceSelector2.
function TraceSelector2_Callback(hObject, eventdata, handles)
% hObject    handle to TraceSelector2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TraceSelector2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TraceSelector2


% --- Executes during object creation, after setting all properties.
function TraceSelector2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TraceSelector2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function MaxLengthDifference_Callback(hObject, eventdata, handles)
% hObject    handle to MaxLengthDifference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxLengthDifference as text
%        str2double(get(hObject,'String')) returns contents of MaxLengthDifference as a double


% --- Executes during object creation, after setting all properties.
function MaxLengthDifference_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxLengthDifference (see GCBO)
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


% --- Executes on selection change in CuttingBehav.
function CuttingBehav_Callback(hObject, eventdata, handles)
% hObject    handle to CuttingBehav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CuttingBehav contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CuttingBehav


% --- Executes during object creation, after setting all properties.
function CuttingBehav_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CuttingBehav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
