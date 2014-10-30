function varargout = Image_CloseMorphological(varargin)
% IMAGE_CLOSEMORPHOLOGICAL MATLAB code for Image_CloseMorphological.fig
%      IMAGE_CLOSEMORPHOLOGICAL, by itself, creates a new IMAGE_CLOSEMORPHOLOGICAL or raises the existing
%      singleton*.
%
%      H = IMAGE_CLOSEMORPHOLOGICAL returns the handle to a new IMAGE_CLOSEMORPHOLOGICAL or the handle to
%      the existing singleton*.
%
%      IMAGE_CLOSEMORPHOLOGICAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGE_CLOSEMORPHOLOGICAL.M with the given input arguments.
%
%      IMAGE_CLOSEMORPHOLOGICAL('Property','Value',...) creates a new IMAGE_CLOSEMORPHOLOGICAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Image_CloseMorphological_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Image_CloseMorphological_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Image_CloseMorphological

% Last Modified by GUIDE v2.5 25-Oct-2012 15:07:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Image_CloseMorphological_OpeningFcn, ...
                   'gui_OutputFcn',  @Image_CloseMorphological_OutputFcn, ...
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


% --- Executes just before Image_CloseMorphological is made visible.
function Image_CloseMorphological_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Image_CloseMorphological (see VARARGIN)

% Choose default command line output for Image_CloseMorphological
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Image_CloseMorphological wait for user response (see UIRESUME)
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
else
    set(handles.ImageSelector,'Value',[]);
    
end
    

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.ImageSelectorValue=get(handles.ImageSelector,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Image_CloseMorphological_OutputFcn(hObject, eventdata, handles) 
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
    
    ImageSel=get(handles.ImageSelector,'Value');
    
    se = strel('disk',str2double(get(handles.Radius,'String')));
        
    if ~isempty(ImageSel)
        h=waitbar(0,'Dilating images...');
        
        NumberImages=length(SpikeImageData);
        SpikeImageData(NumberImages+1:NumberImages+length(ImageSel))=SpikeImageData(ImageSel);
        sel_i=0;
        for i=NumberImages+1:NumberImages+length(ImageSel)
            sel_i=sel_i+1;
            SpikeImageData(i)=SpikeImageData(ImageSel(sel_i));
            SpikeImageData(i).Image=imclose(SpikeImageData(ImageSel(sel_i)).Image,se);
            SpikeImageData(i).Label.ListText=[SpikeImageData(ImageSel(sel_i)).Label.ListText,'_Closed']
        end
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



function Radius_Callback(hObject, eventdata, handles)
% hObject    handle to Radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Radius as text
%        str2double(get(hObject,'String')) returns contents of Radius as a double


% --- Executes during object creation, after setting all properties.
function Radius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
