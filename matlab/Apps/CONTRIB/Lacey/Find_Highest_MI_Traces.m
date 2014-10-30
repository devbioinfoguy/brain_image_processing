function varargout = Find_Highest_MI_Traces(varargin)
% FIND_HIGHEST_MI_TRACES This App aligns one or more traces to points given in the
% binary alignment trace. Any point in the alignment trace with a 1 will be
% an alignment point, and all trace fragments surrounding an alignment
% point will be laid on top of one another. Useful for traces which contain
% multiple repeats of the same experiment, cue, or action.
%
% Output will save as many traces as are input; each will be of length (#
% frames before) + 1 + (# frames after), as set in the GUI.
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Find_Highest_MI_Traces

% Last Modified by GUIDE v2.5 15-Jun-2012 10:38:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Find_Highest_MI_Traces_OpeningFcn, ...
                   'gui_OutputFcn',  @Find_Highest_MI_Traces_OutputFcn, ...
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
function Find_Highest_MI_Traces_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Find_Highest_MI_Traces (see VARARGIN)

% Choose default command line output for Find_Highest_MI_Traces
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeTraceData

if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.XTraceSelector,'String',TextTrace);
    set(handles.YTraceSelector, 'String', TextTrace);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.XTraceSelector,'String',Settings.TraceSelectorString);
    set(handles.XTraceSelector,'Value',Settings.TraceSelectorValue);
    set(handles.KeepTraces, 'Value', Settings.KeepTracesValue);
    set(handles.UseAllTraces, 'Value', Settings.UseAllTracesValue);
    set(handles.NumPoints, 'String', Settings.NumPointsString);
    set(handles.PointRank, 'String', Settings.PointRankString);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorString=get(handles.XTraceSelector,'String');
Settings.TraceSelectorValue=get(handles.XTraceSelector,'Value');
Settings.KeepTracesValue=get(handles.KeepTraces, 'Value');
Settings.NumPointsString=get(handles.NumPoints, 'String');
Settings.PointRankString=get(handles.PointRank, 'String');


% --- Outputs from this function are returned to the command line.
function varargout = Find_Highest_MI_Traces_OutputFcn(hObject, eventdata, handles) 
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
global X
global Y
global numXtraces
global numValuesY
global theseX
global yVal
global logProbX0givenY
global logProbX1givenY
global logProbY
global logProbX0
global logProbX1

try
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    % get parameters from interface
    xTraceInds=get(handles.XTraceSelector, 'Value');
    numXtraces=length(xTraceInds);
    yTraceInd=get(handles.YTraceSelector, 'Value');
    yTrace=SpikeTraceData(yTraceInd).Trace;
    numValuesY=str2double(get(handles.NumValuesY, 'String'));
    fracToSave=str2double(get(handles.FractionTraces, 'String'));
    numTraces=length(SpikeTraceData);
    
    % put X data into logical matrix
    numPoints=length(SpikeTraceData(xTraceInds(1)).Trace);
    if length(yTrace)~=numPoints
        error('Y trace not same length as X traces')
    else
        % divide y to have numValuesY discrete values, range 0 to
        % numValuesY-1
        Y=round((yTrace-min(yTrace))*(numValuesY-1)/(max(yTrace)-min(yTrace)));
        
    end
    X=false(numXtraces, numPoints);
    for i=1:numXtraces
        traceInd=xTraceInds(i);
        if length(SpikeTraceData(traceInd).Trace)~=numPoints
            error('X Traces are not same length')
        else
            X(i,:)=logical(SpikeTraceData(traceInd).Trace);
        end
    end
    
    % calculate probabilities
    logProbX0=log(sum(1-X,2))-log(numPoints);
    logProbX1=log(sum(X,2))-log(numPoints);
    logProbY=zeros(1,numValuesY);
    logProbX0givenY=zeros(numXtraces, numValuesY);
    logProbX1givenY=zeros(numXtraces, numValuesY);
    for yVal=0:numValuesY-1
        logProbY(yVal+1)=log(sum(Y==yVal))-log(numPoints);
        theseX=X(:,Y==yVal);
        logProbX0givenY(:,yVal+1)=log(sum(1-theseX,2)+1)-log(size(theseX,2)+1);
        logProbX1givenY(:, yVal+1)=log(sum(theseX,2)+1)-log(size(theseX,2)+1);
    end
    logProbX0andY=log(exp(logProbX0givenY).*repmat(exp(logProbY),numXtraces,1));
    logProbX1andY=log(exp(logProbX1givenY).*repmat(exp(logProbY),numXtraces,1));
    
    % calculate MI
    MI=sum(exp(logProbX0andY).*(logProbX0andY-repmat(logProbX0,1,numValuesY)-repmat(logProbY,numXtraces,1)),2)+...
        sum(exp(logProbX1andY).*(logProbX1andY-repmat(logProbX1,1,numValuesY)-repmat(logProbY,numXtraces,1)),2); 
    
    % Save MI in a new trace
    SpikeTraceData(numTraces+1).XVector=1:numXtraces;
    SpikeTraceData(numTraces+1).Trace=MI;
    SpikeTraceData(numTraces+1).DataSize=size(MI);
    SpikeTraceData(numTraces+1).Label.XLabel='trace number';
    SpikeTraceData(numTraces+1).Label.YLabel='I';
    SpikeTraceData(numTraces+1).Label.ListText='Mutual Info';
    
    % Save top MI cells as new traces
    [~, indsSorted]=sort(MI, 'descend');
    indsSorted=indsSorted(1:ceil(fracToSave*numXtraces));
    topMIInds=xTraceInds(indsSorted);
    for i=1:length(topMIInds)
        origTraceInd=topMIInds(i);
        SpikeTraceData(numTraces+1+i)=SpikeTraceData(origTraceInd);
        SpikeTraceData(numTraces+1+i).Label.ListText=['topMI ', SpikeTraceData(origTraceInd).Label.ListText];
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



% --- Executes on selection change in XtraceIndselector.
function XTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to XtraceIndselector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns XtraceIndselector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from XtraceIndselector


% --- Executes during object creation, after setting all properties.
function XTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XtraceIndselector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in YTraceSelector.
function YTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to YTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns YTraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from YTraceSelector


% --- Executes during object creation, after setting all properties.
function YTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NumValuesY_Callback(hObject, eventdata, handles)
% hObject    handle to NumValuesY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumValuesY as text
%        str2double(get(hObject,'String')) returns contents of NumValuesY as a double


% --- Executes during object creation, after setting all properties.
function NumValuesY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumValuesY (see GCBO)
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



function FractionTraces_Callback(hObject, eventdata, handles)
% hObject    handle to FractionTraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FractionTraces as text
%        str2double(get(hObject,'String')) returns contents of FractionTraces as a double


% --- Executes during object creation, after setting all properties.
function FractionTraces_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FractionTraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
