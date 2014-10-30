function varargout = Save_Data_Avi(varargin)
% SAVE_DATA_AVI MATLAB code for Save_Data_Avi.fig
%      SAVE_DATA_AVI, by itself, creates a new SAVE_DATA_AVI or raises the existing
%      singleton*.
%
%      H = SAVE_DATA_AVI returns the handle to a new SAVE_DATA_AVI or the handle to
%      the existing singleton*.
%
%      SAVE_DATA_AVI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAVE_DATA_AVI.M with the given input arguments.
%
%      SAVE_DATA_AVI('Property','Value',...) creates a new SAVE_DATA_AVI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Save_Data_Avi_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Save_Data_Avi_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Save_Data_Avi

% Last Modified by GUIDE v2.5 06-Feb-2012 23:34:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Save_Data_Avi_OpeningFcn, ...
                   'gui_OutputFcn',  @Save_Data_Avi_OutputFcn, ...
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


% --- Executes just before Save_Data_Avi is made visible.
function Save_Data_Avi_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Save_Data_Avi (see VARARGIN)

% Choose default command line output for Save_Data_Avi
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Save_Data_Avi wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.FileText,'String',Settings.FileTextString);
    set(handles.FrameRate,'String',Settings.FrameRateString);
    set(handles.Quality,'String',Settings.QualityString);   
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.FileTextString=get(handles.FileText,'String');
Settings.FrameRateString=get(handles.FrameRate,'String');
Settings.QualityString=get(handles.Quality,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Save_Data_Avi_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeGui;


try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    handlesToSpikeE=SpikeGui.MAINhandle;
    
    TimeSpeed=str2double(get(handlesToSpikeE.FactorRealTime,'String'));
    TimeStep=TimeSpeed/str2double(get(handles.FrameRate,'String'));
    HandleToLoader=str2func('SpikeExtractor');
    
    SpikeGui.currentTime=SpikeGui.MinTime;
    
    % Prepare the new video file.
    vidObj=VideoWriter(get(handles.FileText,'String'));
    vidObj.FrameRate=str2double(get(handles.FrameRate,'String'));
    vidObj.Quality=str2double(get(handles.Quality,'String'));
    open(vidObj);
    
    while (SpikeGui.currentTime+TimeStep)<SpikeGui.MaxTime
        set(handlesToSpikeE.currentTime,'String',num2str(SpikeGui.currentTime));
        set(handlesToSpikeE.PositionSlider,'Value',SpikeGui.currentTime/SpikeGui.MaxTime);
        HandleToLoader('UpdateFrameNumber',handlesToSpikeE);
        HandleToLoader('DisplayData',handlesToSpikeE);
        
        currFrame = getframe(SpikeGui.hDataDisplay);
        writeVideo(vidObj,currFrame);
        SpikeGui.currentTime=SpikeGui.currentTime+TimeStep;
    end
    % Close the file.
    close(vidObj);
    
    ValidateValues_Callback(hObject, eventdata, handles);
    set(InterfaceObj,'Enable','on');
    
catch errorObj
    set(InterfaceObj,'Enable','on');
    
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
end

% --- Executes on button press in ValidateValues.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;

% --- Executes on button press in ChooseFile.
function ChooseFile_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open directory interface
[filename,pathname]=uiputfile('*.avi','Save movie As');

% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
    return
else
    set(handles.FileText,'String',fullfile(pathname,filename));
end
   

% --- Executes during object creation, after setting all properties.
function ChooseFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChooseFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function FrameRate_Callback(hObject, eventdata, handles)
% hObject    handle to FrameRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameRate as text
%        str2double(get(hObject,'String')) returns contents of FrameRate as a double


% --- Executes during object creation, after setting all properties.
function FrameRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Quality_Callback(hObject, eventdata, handles)
% hObject    handle to Quality (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Quality as text
%        str2double(get(hObject,'String')) returns contents of Quality as a double


% --- Executes during object creation, after setting all properties.
function Quality_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Quality (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
