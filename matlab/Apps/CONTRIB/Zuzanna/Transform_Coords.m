function varargout = Transform_Coords(varargin)
% TRANSFORM_COORDS This is the simplest Apps you can make. It is the best start
% to start a new Apps. Just open this Apps in GUIDE, save it to a new
% name and modify it.
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Transform_Coords

% Last Modified by GUIDE v2.5 16-Apr-2012 11:13:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Transform_Coords_OpeningFcn, ...
                   'gui_OutputFcn',  @Transform_Coords_OutputFcn, ...
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
function Transform_Coords_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Transform_Coords (see VARARGIN)

% Choose default command line output for Transform_Coords
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Here we read from the Settings structure created by the function
% GetSettings. This is used to reload saved settings from a previously
% opened instance of this Apps in the batch list.
if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.Text,'String',Settings.TextString);  
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)

handles=guidata(hObject);
Settings.TextString=get(handles.Text,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Transform_Coords_OutputFcn(hObject, eventdata, handles) 
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

global RegionsParams
global RegionsParams_new
global Trans_mat
global Trans_ori

try
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    sz=length(RegionsParams);
    
    RegionsParams_new=struct([]);
    
    for i=1:sz
       
        RegionsParams_new(i).BoundingBox(1:2)=Trans_mat*RegionsParams(i).BoundingBox(1:2)' + Trans_ori;
        
        vec=[RegionsParams(i).BoundingBox(1)+RegionsParams(i).BoundingBox(3);
            RegionsParams(i).BoundingBox(2)+RegionsParams(i).BoundingBox(4)]
        
        vec_new=Trans_mat*vec+Trans_ori;
        
        RegionsParams_new(i).BoundingBox(3)=vec_new(1)-RegionsParams_new(i).BoundingBox(1);
        RegionsParams_new(i).BoundingBox(4)=vec_new(2)-RegionsParams_new(i).BoundingBox(2);
        
        if RegionsParams_new(i).BoundingBox(3)<0
        RegionsParams_new(i).BoundingBox(1)=RegionsParams_new(i).BoundingBox(1)+RegionsParams_new(i).BoundingBox(3);
        RegionsParams_new(i).BoundingBox(3)=-RegionsParams_new(i).BoundingBox(3);    
        end
        
         if RegionsParams_new(i).BoundingBox(4)<0
        RegionsParams_new(i).BoundingBox(2)=RegionsParams_new(i).BoundingBox(2)+RegionsParams_new(i).BoundingBox(4);
        RegionsParams_new(i).BoundingBox(4)=-RegionsParams_new(i).BoundingBox(4);    
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
