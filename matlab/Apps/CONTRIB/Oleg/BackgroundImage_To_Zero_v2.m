function varargout = BackgroundImage_To_Zero_v2(varargin)
% BACKGROUNDIMAGE_TO_ZERO_V2 MATLAB code for BackgroundImage_To_Zero_v2.fig
%      BACKGROUNDIMAGE_TO_ZERO_V2, by itself, creates a new BACKGROUNDIMAGE_TO_ZERO_V2 or raises the existing
%      singleton*.
%
%      H = BACKGROUNDIMAGE_TO_ZERO_V2 returns the handle to a new BACKGROUNDIMAGE_TO_ZERO_V2 or the handle to
%      the existing singleton*.
%
%      BACKGROUNDIMAGE_TO_ZERO_V2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BACKGROUNDIMAGE_TO_ZERO_V2.M with the given input arguments.
%
%      BACKGROUNDIMAGE_TO_ZERO_V2('Property','Value',...) creates a new BACKGROUNDIMAGE_TO_ZERO_V2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BackgroundImage_To_Zero_v2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BackgroundImage_To_Zero_v2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help BackgroundImage_To_Zero_v2

% Last Modified by GUIDE v2.5 02-Nov-2012 09:50:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BackgroundImage_To_Zero_v2_OpeningFcn, ...
                   'gui_OutputFcn',  @BackgroundImage_To_Zero_v2_OutputFcn, ...
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


% --- Executes just before BackgroundImage_To_Zero_v2 is made visible.
function BackgroundImage_To_Zero_v2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BackgroundImage_To_Zero_v2 (see VARARGIN)
global SpikeImageData;

% Choose default command line output for BackgroundImage_To_Zero_v2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BackgroundImage_To_Zero_v2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
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
    set(handles.SelectAllImages,'Value',Settings.SelectAllImageValue);
    set(handles.ThresholdSelectorManual,'Value',Settings.ThresholdSelectorManualValue);
    set(handles.ThresholdSelectorAuto,'Value',Settings.ThresholdSelectorAutoValue);
    set(handles.ThreshLevel,'String',Settings.ThresholdValueString);
else
    set(handles.ImageSelector,'Value',[]);
end

SelectAllImages_Callback(hObject, eventdata, handles);

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.ImageSelectorValue=get(handles.ImageSelector,'Value');
Settings.SelectAllImageValue=get(handles.SelectAllImages,'Value');
Settings.ThresholdSelectorManualValue=get(handles.ThresholdSelectorManual,'Value');
Settings.ThresholdSelectorAutoValue=get(handles.ThresholdSelectorAuto,'Value');
Settings.ThresholdValueString=get(handles.ThreshLevel,'String');


% --- Outputs from this function are returned to the command line.
function varargout = BackgroundImage_To_Zero_v2_OutputFcn(hObject, eventdata, handles) 
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
    
    h=waitbar(0,'Filtering images...');
    
    if (get(handles.SelectAllImages,'Value')==1)
        ImageSel=1:length(SpikeImageData);
    else
        ImageSel=get(handles.ImageSelector,'Value');
    end
    
    % Depending on the threshold option, we use Matlab or the interface to
    % get the threshold value.
    if get(handles.ThresholdSelectorAuto,'Value')
        ThresholdValue=-1;
    else
        ThresholdValue=str2double(get(handles.ThreshLevel,'String'));
    end
    
    NumberImages=length(ImageSel);
    
    % waitbar is consuming too much ressources, so I divide its acces
    dividerWaitbar=10^(floor(log10(length(ImageSel)))-1);
    for i=1:NumberImages
        
        % To avoid calling the interface in the loop (computationnaly
        % infavorable), we check on the variable for -1
        if (ThresholdValue==-1)
            LocalThresh=graythresh(SpikeImageData(ImageSel(i)).Image);
        else
            LocalThresh=ThresholdValue;
        end
        
        % We convert the selected image to black and white.
        SpikeImageData(ImageSel(i)).Image(SpikeImageData(ImageSel(i)).Image<LocalThresh)=0;
        
        if (round(i/dividerWaitbar)==i/dividerWaitbar)
            waitbar(i/NumberImages,h);
        end
    end
    
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


% --- Executes on button press in SelectAllImages.
function SelectAllImages_Callback(hObject, eventdata, handles)
% hObject    handle to SelectAllImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SelectAllImages
if (get(handles.SelectAllImages,'Value')==1)
    set(handles.ImageSelector,'Enable','off');
else
    set(handles.ImageSelector,'Enable','on');
end



function ThreshLevel_Callback(hObject, eventdata, handles)
% hObject    handle to ThreshLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ThreshLevel as text
%        str2double(get(hObject,'String')) returns contents of ThreshLevel as a double


% --- Executes during object creation, after setting all properties.
function ThreshLevel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThreshLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ThresholdSelectorManual.
function ThresholdSelectorManual_Callback(hObject, eventdata, handles)
% hObject    handle to ThresholdSelectorManual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ThresholdSelectorManual


% --- Executes on button press in ThresholdSelectorAuto.
function ThresholdSelectorAuto_Callback(hObject, eventdata, handles)
% hObject    handle to ThresholdSelectorAuto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ThresholdSelectorAuto
