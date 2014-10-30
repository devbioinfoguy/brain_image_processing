function varargout = Load_Freezing_Txt(varargin)
% LOAD_FREEZING_TXT MATLAB code for Load_Freezing_Txt.fig
%      LOAD_FREEZING_TXT, by itself, creates a new LOAD_FREEZING_TXT or raises the existing
%      singleton*.
%
%      H = LOAD_FREEZING_TXT returns the handle to a new LOAD_FREEZING_TXT or the handle to
%      the existing singleton*.
%
%      LOAD_FREEZING_TXT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOAD_FREEZING_TXT.M with the given input arguments.
%
%      LOAD_FREEZING_TXT('Property','Value',...) creates a new LOAD_FREEZING_TXT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Load_Freezing_Txt_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Load_Freezing_Txt_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Load_Freezing_Txt

% Last Modified by GUIDE v2.5 08-Jun-2012 17:27:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Load_Freezing_Txt_OpeningFcn, ...
                   'gui_OutputFcn',  @Load_Freezing_Txt_OutputFcn, ...
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


% --- Executes just before Load_Freezing_Txt is made visible.
function Load_Freezing_Txt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Load_Freezing_Txt (see VARARGIN)

% Choose default command line output for Load_Freezing_Txt
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Load_Freezing_Txt wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% We get the input settings to restore state if needed
if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.FilenameShow,'String',Settings.FilenameShowString);
    set(handles.Framerate,'String',Settings.FramerateString);
    set(handles.TraceTag,'String',Settings.TraceTagString);
end
    

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.FilenameShowString=get(handles.FilenameShow,'String');
Settings.FramerateString=get(handles.Framerate,'String');
Settings.TraceTagString=get(handles.TraceTag,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Load_Freezing_Txt_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% delete(hObject);

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

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    NewTraceNum=length(SpikeTraceData)+1;
    
    h=waitbar(0,'loading data...');
    LocalFile=get(handles.FilenameShow,'String');
    framerate=str2double(get(handles.Framerate, 'String'));

    allText=textread(LocalFile, '%f');
    times=allText(1:3:end);
    interval=allText(2);
    freezing=allText(3:3:end);
    
    finalTraceLength=round(length(times)*interval*framerate);
    SpikeTraceData(NewTraceNum).XVector=(1:finalTraceLength)*(1/framerate);
    SpikeTraceData(NewTraceNum).Trace=zeros(1,finalTraceLength);
    lastFrame=0;
    for epoch=1:length(freezing)
        SpikeTraceData(NewTraceNum).Trace((lastFrame+1):round(epoch*interval*framerate))=freezing(epoch);
        lastFrame=round(epoch*interval*framerate);
    end
    SpikeTraceData(NewTraceNum).Label.ListText=get(handles.TraceTag, 'String');
    SpikeTraceData(NewTraceNum).Label.XLabel='s';
    SpikeTraceData(NewTraceNum).Label.YLabel='% freezing';
    
        
    delete(h);
    ValidateValues_Callback(hObject, eventdata, handles);
    set(InterfaceObj,'Enable','on');
    
catch errorObj
    set(InterfaceObj,'Enable','on');
    
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
    if exist('h','var')
        if ishandle(h)
            delete(h);
        end
    end
end


% --- Executes on button press in SelectFile.
function SelectFile_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Open file path
[filename, pathname] = uigetfile( ...
    {'*.txt','All Files (*.txt)'},'Select Text File');

% Open file if exist
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
    return
    
    % Otherwise construct the fullfilename and Check and load the file
else
    % To keep the path accessible to futur request
    cd(pathname);
    try
        InterfaceObj=findobj(handles.output,'Enable','on');
        set(InterfaceObj,'Enable','off');
        h=waitbar(0,'Checking data...');
        
        LocalFile=fullfile(pathname,filename);

        set(handles.FilenameShow,'String',LocalFile);
        
        delete(h);
        set(InterfaceObj,'Enable','on');
        
    catch errorObj
        set(InterfaceObj,'Enable','on');
        % If there is a problem, we display the error message
        errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
        if exist('h','var')
            if ishandle(h)
                delete(h);
            end
        end
    end
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);



function Framerate_Callback(hObject, eventdata, handles)
% hObject    handle to Framerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Framerate as text
%        str2double(get(hObject,'String')) returns contents of Framerate as a double


% --- Executes during object creation, after setting all properties.
function Framerate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Framerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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
