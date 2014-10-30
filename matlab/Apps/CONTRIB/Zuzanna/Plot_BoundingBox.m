function varargout = Plot_BoundingBox(varargin)
% PLOT_BOUNDINGBOX MATLAB code for Plot_BoundingBox.fig
%      PLOT_BOUNDINGBOX, by itself, creates a new PLOT_BOUNDINGBOX or raises the existing
%      singleton*.
%
%      H = PLOT_BOUNDINGBOX returns the handle to a new PLOT_BOUNDINGBOX or the handle to
%      the existing singleton*.
%
%      PLOT_BOUNDINGBOX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOT_BOUNDINGBOX.M with the given input arguments.
%
%      PLOT_BOUNDINGBOX('Property','Value',...) creates a new PLOT_BOUNDINGBOX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Plot_BoundingBox_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Plot_BoundingBox_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Plot_BoundingBox

% Last Modified by GUIDE v2.5 16-Apr-2012 13:00:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Plot_BoundingBox_OpeningFcn, ...
                   'gui_OutputFcn',  @Plot_BoundingBox_OutputFcn, ...
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


% --- Executes just before Plot_BoundingBox is made visible.
function Plot_BoundingBox_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Plot_BoundingBox (see VARARGIN)
global SpikeImageData;

% Choose default command line output for Plot_BoundingBox
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Plot_BoundingBox wait for user response (see UIRESUME)
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
    set(handles.FirstInd,'String',Settings.FirstIndString);
    set(handles.LastInd,'String',Settings.LastIndString);
else
    set(handles.ImageSelector,'Value',[]);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.ImageSelectorValue=get(handles.ImageSelector,'Value');
Settings.FirstIndString=get(handles.FirstInd,'String')
Settings.LastIndString=get(handles.LastInd,'String')


% --- Outputs from this function are returned to the command line.
function varargout = Plot_BoundingBox_OutputFcn(hObject, eventdata, handles) 
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
global RegionsParams_new



try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
   
    ImageSel=get(handles.ImageSelector,'Value');
   
    firstind = str2num(get(handles.FirstInd,'String'));
    lastind = str2num(get(handles.LastInd,'String'));
      
    NumberImages=length(ImageSel);
    
   
    for n=1:NumberImages
        
        figure;
        imagesc(SpikeImageData(ImageSel(n)).Image);
        axis equal;
        hold on;
        
        for i=firstind:lastind
        rectangle('Position',RegionsParams_new(i).BoundingBox,'EdgeColor',[1 1 1]);         
        end

    end
    

    ValidateValues_Callback(hObject, eventdata, handles);
    set(InterfaceObj,'Enable','on');
    
catch errorObj
    set(InterfaceObj,'Enable','on');
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');

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



function FirstInd_Callback(hObject, eventdata, handles)
% hObject    handle to FirstInd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FirstInd as text
%        str2double(get(hObject,'String')) returns contents of FirstInd as a double


% --- Executes during object creation, after setting all properties.
function FirstInd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FirstInd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LastInd_Callback(hObject, eventdata, handles)
% hObject    handle to LastInd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LastInd as text
%        str2double(get(hObject,'String')) returns contents of LastInd as a double


% --- Executes during object creation, after setting all properties.
function LastInd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LastInd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
