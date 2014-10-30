function varargout = SpikeE_Options(varargin)
% SPIKEE_OPTIONS This Apps controls the display on the figure window in the 
% Main interface. Change these options as you need.
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help SpikeE_Options

% Last Modified by GUIDE v2.5 07-Mar-2012 19:37:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpikeE_Options_OpeningFcn, ...
                   'gui_OutputFcn',  @SpikeE_Options_OutputFcn, ...
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
function SpikeE_Options_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SpikeE_Options (see VARARGIN)
global SpikeOption;

% Choose default command line output for SpikeE_Options
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Here we read from the Settings structure created by the function
% GetSettings. This is used to reload saved settings from a previously
% opened instance of this Apps in the batch list.
if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.DisplayTraceTimeBar,'Value',Settings.DisplayTraceTimeBarValue);
    set(handles.DisplayTraceTitle,'Value',Settings.DisplayTraceTitleValue);
    set(handles.DisplayTraceAxis,'Value',Settings.DisplayTraceAxisValue);
    set(handles.DisplayImageXYRatio,'Value',Settings.DisplayImageXYRatioValue);
    set(handles.DisplayImageAxis,'Value',Settings.DisplayImageAxisValue);
    set(handles.DisplayImageTitle,'Value',Settings.DisplayImageTitleValue);
    set(handles.DisplayMovie3D,'Value',Settings.DisplayMovie3DValue);
    set(handles.DisplayMovieXYRatio,'Value',Settings.DisplayMovieXYRatioValue);
    set(handles.DisplayMovieAxis,'Value',Settings.DisplayMovieAxisValue);
    set(handles.DisplayMovieTitle,'Value',Settings.DisplayMovieTitleValue);
    set(handles.RelativeHeightTrace,'String',num2str(Settings.RelativeHeightTrace));
    set(handles.LinkAxis,'Value',num2str(Settings.LinkAxisValue));
else
    set(handles.DisplayTraceTimeBar,'Value',SpikeOption.DisplayTraceTimeBar);
    set(handles.DisplayTraceTitle,'Value',SpikeOption.DisplayTraceTitle);
    set(handles.DisplayTraceAxis,'Value',SpikeOption.DisplayTraceAxis);
    set(handles.DisplayImageXYRatio,'Value',SpikeOption.DisplayImageXYRatio);
    set(handles.DisplayImageAxis,'Value',SpikeOption.DisplayImageAxis);
    set(handles.DisplayImageTitle,'Value',SpikeOption.DisplayImageTitle);
    set(handles.DisplayMovie3D,'Value',SpikeOption.DisplayMovie3D);
    set(handles.DisplayMovieXYRatio,'Value',SpikeOption.DisplayMovieXYRatio);
    set(handles.DisplayMovieAxis,'Value',SpikeOption.DisplayMovieAxis);
    set(handles.DisplayMovieTitle,'Value',SpikeOption.DisplayMovieTitle);
    set(handles.RelativeHeightTrace,'String',num2str(SpikeOption.RelativeHeightTrace));
    set(handles.LinkAxis,'Value',SpikeOption.LinkAxis);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)

handles=guidata(hObject);
Settings.DisplayTraceTimeBarValue=get(handles.DisplayTraceTimeBar,'Value');
Settings.DisplayTraceTitleValue=get(handles.DisplayTraceTitle,'Value');
Settings.DisplayTraceAxisValue=get(handles.DisplayTraceAxis,'Value');
Settings.DisplayImageXYRatioValue=get(handles.DisplayImageXYRatio,'Value');
Settings.DisplayImageAxisValue=get(handles.DisplayImageAxis,'Value');
Settings.DisplayImageTitleValue=get(handles.DisplayImageTitle,'Value');
Settings.DisplayMovie3DValue=get(handles.DisplayMovie3D,'Value');
Settings.DisplayMovieXYRatioValue=get(handles.DisplayMovieXYRatio,'Value');
Settings.DisplayMovieAxisValue=get(handles.DisplayMovieAxis,'Value');
Settings.DisplayMovieTitleValue=get(handles.DisplayMovieTitle,'Value');
Settings.RelativeHeightTrace=str2num(get(handles.RelativeHeightTrace,'String'));
Settings.LinkAxisValue=get(handles.LinkAxis,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = SpikeE_Options_OutputFcn(hObject, eventdata, handles) 
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

% For these Apps, it is more meaningfull to put the SpikeOption storage in
% ValidateValues.
try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    ValidateValues_Callback(hObject, eventdata, handles);
    set(InterfaceObj,'Enable','on');
    
catch errorObj
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
global SpikeOption;

SpikeOption.DisplayTraceTimeBar=get(handles.DisplayTraceTimeBar,'Value');
SpikeOption.DisplayTraceTitle=get(handles.DisplayTraceTitle,'Value');
SpikeOption.DisplayTraceAxis=get(handles.DisplayTraceAxis,'Value');
SpikeOption.DisplayImageXYRatio=get(handles.DisplayImageXYRatio,'Value');
SpikeOption.DisplayImageAxis=get(handles.DisplayImageAxis,'Value');
SpikeOption.DisplayImageTitle=get(handles.DisplayImageTitle,'Value');
SpikeOption.DisplayMovie3D=get(handles.DisplayMovie3D,'Value');
SpikeOption.DisplayMovieXYRatio=get(handles.DisplayMovieXYRatio,'Value');
SpikeOption.DisplayMovieAxis=get(handles.DisplayMovieAxis,'Value');
SpikeOption.DisplayMovieTitle=get(handles.DisplayMovieTitle,'Value');
SpikeOption.RelativeHeightImagetoTrace=str2num(get(handles.RelativeHeightTrace,'String'));
SpikeOption.LinkAxis=get(handles.LinkAxis,'Value');

uiresume;


% This function is executed when the object Text is modified.
function Text_Callback(hObject, eventdata, handles)
% hObject    handle to Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Text as text
%        str2double(get(hObject,'String')) returns contents of Text as a double


% --- Executes during object creation, after setting all properties.
function Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% This function opens the help that is written in the header of this M file.
function OpenHelp_Callback(hObject, eventdata, handles)
% hObject    handle to OpenHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CurrentMfilePath = mfilename('fullpath');
[PathToM, name, ext] = fileparts(CurrentMfilePath);
eval(['doc ',name]);


% --- Executes on selection change in DisplayFigureTitle.
function DisplayFigureTitle_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayFigureTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DisplayFigureTitle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DisplayFigureTitle


% --- Executes during object creation, after setting all properties.
function DisplayFigureTitle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DisplayFigureTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DisplayMovie3D.
function DisplayMovie3D_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayMovie3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DisplayMovie3D contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DisplayMovie3D


% --- Executes during object creation, after setting all properties.
function DisplayMovie3D_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DisplayMovie3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DisplayTraceTimeBar.
function DisplayTraceTimeBar_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayTraceTimeBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DisplayTraceTimeBar contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DisplayTraceTimeBar


% --- Executes during object creation, after setting all properties.
function DisplayTraceTimeBar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DisplayTraceTimeBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DisplayMovieXYRatio.
function DisplayMovieXYRatio_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayMovieXYRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DisplayMovieXYRatio contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DisplayMovieXYRatio


% --- Executes during object creation, after setting all properties.
function DisplayMovieXYRatio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DisplayMovieXYRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DisplayMovieTitle.
function DisplayMovieTitle_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayMovieTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DisplayMovieTitle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DisplayMovieTitle


% --- Executes during object creation, after setting all properties.
function DisplayMovieTitle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DisplayMovieTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DisplayImageTitle.
function DisplayImageTitle_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayImageTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DisplayImageTitle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DisplayImageTitle


% --- Executes during object creation, after setting all properties.
function DisplayImageTitle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DisplayImageTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DisplayTraceTitle.
function DisplayTraceTitle_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayTraceTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DisplayTraceTitle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DisplayTraceTitle


% --- Executes during object creation, after setting all properties.
function DisplayTraceTitle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DisplayTraceTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DisplayMovieXaxis.
function DisplayMovieXaxis_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayMovieXaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DisplayMovieXaxis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DisplayMovieXaxis


% --- Executes during object creation, after setting all properties.
function DisplayMovieXaxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DisplayMovieXaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DisplayMovieAxis.
function DisplayMovieAxis_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayMovieAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DisplayMovieAxis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DisplayMovieAxis


% --- Executes during object creation, after setting all properties.
function DisplayMovieAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DisplayMovieAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DisplayImageAxis.
function DisplayImageAxis_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayImageAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DisplayImageAxis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DisplayImageAxis


% --- Executes during object creation, after setting all properties.
function DisplayImageAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DisplayImageAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DisplayTraceYaxis.
function DisplayTraceYaxis_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayTraceYaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DisplayTraceYaxis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DisplayTraceYaxis


% --- Executes during object creation, after setting all properties.
function DisplayTraceYaxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DisplayTraceYaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DisplayTraceAxis.
function DisplayTraceAxis_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayTraceAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DisplayTraceAxis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DisplayTraceAxis


% --- Executes during object creation, after setting all properties.
function DisplayTraceAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DisplayTraceAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DisplayImageXYRatio.
function DisplayImageXYRatio_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayImageXYRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DisplayImageXYRatio contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DisplayImageXYRatio


% --- Executes during object creation, after setting all properties.
function DisplayImageXYRatio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DisplayImageXYRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RelativeHeightTrace_Callback(hObject, eventdata, handles)
% hObject    handle to RelativeHeightTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RelativeHeightTrace as text
%        str2double(get(hObject,'String')) returns contents of RelativeHeightTrace as a double


% --- Executes during object creation, after setting all properties.
function RelativeHeightTrace_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RelativeHeightTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in LinkAxis.
function LinkAxis_Callback(hObject, eventdata, handles)
% hObject    handle to LinkAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LinkAxis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LinkAxis


% --- Executes during object creation, after setting all properties.
function LinkAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LinkAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
