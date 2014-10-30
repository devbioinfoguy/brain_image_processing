function varargout = Remove_Traces_If_Image_Deleted(varargin)
% REMOVE_TRACES_IF_IMAGE_DELETED This is the simplest Apps you can make. It is the best start
% to start a new Apps. Just open this Apps in GUIDE, save it to a new
% name and modify it.
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Remove_Traces_If_Image_Deleted

% Last Modified by GUIDE v2.5 04-Jan-2013 19:28:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Remove_Traces_If_Image_Deleted_OpeningFcn, ...
                   'gui_OutputFcn',  @Remove_Traces_If_Image_Deleted_OutputFcn, ...
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
function Remove_Traces_If_Image_Deleted_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Remove_Traces_If_Image_Deleted (see VARARGIN)

% Choose default command line output for Remove_Traces_If_Image_Deleted
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


global SpikeTraceData
if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end 
    set(handles.TraceSelector,'String',TextTrace);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.TraceSelector,'Value',Settings.TraceSelectorValue); 
    set(handles.SelectAllTraces,'Value',Settings.SelectAllTracesValue);
end
SelectAllTraces_Callback(hObject, eventdata, handles); 


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');
Settings.SelectAllTracesValue=get(handles.SelectAllTraces, 'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Remove_Traces_If_Image_Deleted_OutputFcn(hObject, eventdata, handles) 
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
global SpikeImageData

try
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    

    if get(handles.SelectAllTraces, 'Value')
        tracesToComb=1:length(SpikeTraceData);
    else
        tracesToComb=get(handles.TraceSelector,'Value');
    end
    
    tracesToDelete=zeros(size(tracesToComb));
    numTracesToDelete=0;
    
    numImages=length(SpikeImageData);
    imageNames=cell(numImages,1);
    for imInd=1:numImages
        imageNames{imInd}=SpikeImageData(imInd).Label.ListText;
    end
    
    for trInd=tracesToComb
        thisTraceName=SpikeTraceData(trInd).Label.ListText;
        imInd=0;
        notFound=1;
        while notFound && imInd<numImages
            imInd=imInd+1;
            if strcmp(thisTraceName, imageNames{imInd})
                notFound=0;
            end
        end
        if notFound
            numTracesToDelete=numTracesToDelete+1;
            tracesToDelete(numTracesToDelete)=trInd;
        end
    end
    tracesToDelete=tracesToDelete(1:numTracesToDelete);
    SpikeTraceData(tracesToDelete)=[];
        
        
    
    
    
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


% --- Executes on button press in SelectAllTraces.
function SelectAllTraces_Callback(hObject, eventdata, handles)
% hObject    handle to SelectAllTraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SelectAllTraces

if get(handles.SelectAllTraces, 'Value')
    set(handles.TraceSelector, 'Enable', 'off')
else
    set(handles.TraceSelector, 'Enable', 'on')
end
