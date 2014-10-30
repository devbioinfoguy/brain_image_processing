function varargout = Remove_Small_Area_ICs(varargin)
% REMOVE_SMALL_AREA_ICS MATLAB code for Remove_Small_Area_ICs.fig
%      REMOVE_SMALL_AREA_ICS, by itself, creates a new REMOVE_SMALL_AREA_ICS or raises the existing
%      singleton*.
%
%      H = REMOVE_SMALL_AREA_ICS returns the handle to a new REMOVE_SMALL_AREA_ICS or the handle to
%      the existing singleton*.
%
%      REMOVE_SMALL_AREA_ICS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REMOVE_SMALL_AREA_ICS.M with the given input arguments.
%
%      REMOVE_SMALL_AREA_ICS('Property','Value',...) creates a new REMOVE_SMALL_AREA_ICS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Remove_Small_Area_ICs_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Remove_Small_Area_ICs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Remove_Small_Area_ICs

% Last Modified by GUIDE v2.5 11-Jul-2012 10:48:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Remove_Small_Area_ICs_OpeningFcn, ...
                   'gui_OutputFcn',  @Remove_Small_Area_ICs_OutputFcn, ...
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


% --- Executes just before Remove_Small_Area_ICs is made visible.
function Remove_Small_Area_ICs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Remove_Small_Area_ICs (see VARARGIN)

% Choose default command line output for Remove_Small_Area_ICs
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Remove_Small_Area_ICs wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global SpikeImageData;

NumberImages=length(SpikeImageData);
if ~isempty(SpikeImageData)
    for i=1:NumberImages
        TextImage{i}=[num2str(i),' - ',SpikeImageData(i).Label.ListText];
    end
    set(handles.ImageSelector,'String',TextImage);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.ImageSelector,'Value',intersect(1:NumberImages,Settings.ImageSelectorValue));
    set(handles.FractionMax, 'String', Settings.FractionMaxString);
    set(handles.MinSizePixels, 'String', Settings.MinSizePixelsString);
    set(handles.UseAllICs, 'Value', Settings.UseAllICsValue);
else
    set(handles.ImageSelector,'Value',[]);
    
end
    

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.ImageSelectorValue=get(handles.ImageSelector,'Value');
Settings.FractionMaxString=get(handles.FractionMax, 'String');
Settings.MinSizePixelsString=get(handles.MinSizePixels, 'String');
Settings.UseAllICsValue=get(handles.UseAllICs,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Remove_Small_Area_ICs_OutputFcn(hObject, eventdata, handles) 
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
uiresume;


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeImageData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    if get(handles.UseAllICs,'Value')
        ICsToCheck=1:length(SpikeImageData);
    else
        ICsToCheck=get(handles.ImageSelector,'Value');
    end
    fracMaxVal=str2double(get(handles.FractionMax, 'String'));
    minNumPixels=str2double(get(handles.MinSizePixels, 'String'));
    
    if ~isempty(ICsToCheck)
        h=waitbar(0,'Removing small area ICs...');
        
        ICsToDelete=[];
        for imageInd=ICsToCheck
            thisIC=double(SpikeImageData(imageInd).Image);
            thisIC(thisIC<(fracMaxVal*max(thisIC(:))))=0;
            if sum(thisIC(:)>0)<minNumPixels
                ICsToDelete(end+1)=imageInd; %#ok<AGROW>
            end
        end
            
        SpikeImageData(ICsToDelete)=[];
        
        delete(h);
    end
    
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


% --- Executes on selection change in ImageSelector.
function ImageSelector_Callback(hObject, eventdata, handles)
% hObject    handle to ImageSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ImageSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImageSelector


% --- Executes during object creation, after setting all properties.
function ImageSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageSelector (see GCBO)
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



function MinSizePixels_Callback(hObject, eventdata, handles)
% hObject    handle to MinSizePixels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinSizePixels as text
%        str2double(get(hObject,'String')) returns contents of MinSizePixels as a double


% --- Executes during object creation, after setting all properties.
function MinSizePixels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinSizePixels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FractionMax_Callback(hObject, eventdata, handles)
% hObject    handle to FractionMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FractionMax as text
%        str2double(get(hObject,'String')) returns contents of FractionMax as a double


% --- Executes during object creation, after setting all properties.
function FractionMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FractionMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in UseAllICs.
function UseAllICs_Callback(hObject, eventdata, handles)
% hObject    handle to UseAllICs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UseAllICs
if (get(handles.UseAllICs,'Value')==1)
    set(handles.ImageSelector,'Enable','off');
else
    set(handles.ImageSelector,'Enable','on');
end
