function varargout = Merge_Images(varargin)
% MERGE_IMAGES MATLAB code for Merge_Images.fig
%      MERGE_IMAGES, by itself, creates a new MERGE_IMAGES or raises the existing
%      singleton*.
%
%      H = MERGE_IMAGES returns the handle to a new MERGE_IMAGES or the handle to
%      the existing singleton*.
%
%      MERGE_IMAGES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MERGE_IMAGES.M with the given input arguments.
%
%      MERGE_IMAGES('Property','Value',...) creates a new MERGE_IMAGES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Merge_Images_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Merge_Images_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Merge_Images

% Last Modified by GUIDE v2.5 17-May-2012 07:19:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Merge_Images_OpeningFcn, ...
                   'gui_OutputFcn',  @Merge_Images_OutputFcn, ...
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


% --- Executes just before Merge_Images is made visible.
function Merge_Images_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Merge_Images (see VARARGIN)

% Choose default command line output for Merge_Images
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Merge_Images wait for user response (see UIRESUME)
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
    set(handles.MergeType,'Value',Settings.MergeTypeValue);
    set(handles.KeepOriginal,'Value',Settings.KeepOriginalValue);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.ImageSelectorValue=get(handles.ImageSelector,'Value');
Settings.MergeTypeValue=get(handles.MergeType,'Value');
Settings.KeepOriginalValue=get(handles.KeepOriginal,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Merge_Images_OutputFcn(hObject, eventdata, handles) 
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
    
    if ~isempty(ImageSel)
        % Checking that they all are of the same size
        LocalSize=SpikeImageData(ImageSel(1)).DataSize;
        for i=1:length(ImageSel)
            if any(LocalSize-SpikeImageData(ImageSel(i)).DataSize)
                error('Images are not all of the same size');
            end
        end
        
        h=waitbar(0,'Merging images...');
        % We create a double Image for storing the temporary calculation and
        % avoiding rounding issues.
        TempImage=zeros(LocalSize);
        TempImage=SpikeImageData(ImageSel(1)).Image;
        
        NumberImages=length(SpikeImageData);
        
        SpikeImageData(NumberImages+1)=SpikeImageData(ImageSel(1));
        SelectionType=get(handles.MergeType,'Value');
        for i=2:numel(ImageSel)
            switch SelectionType
                case 1
                    TempImage=max(TempImage,SpikeImageData(ImageSel(i)).Image);
                case 2
                    TempImage=TempImage.*SpikeImageData(ImageSel(i)).Image;
                case 3
                    TempImage=min(TempImage,SpikeImageData(ImageSel(i)).Image);
            end
        end
        if SelectionType==2
            TempImage=TempImage/length(ImageSel);
        end
        SpikeImageData(NumberImages+1).Image=TempImage;%cast(TempImage,class(SpikeImageData(ImageSel(1)).Image));
        if get(handles.KeepOriginal,'Value')==0
            SpikeImageData(ImageSel)=[];
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


% --- Executes on selection change in MergeType.
function MergeType_Callback(hObject, eventdata, handles)
% hObject    handle to MergeType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MergeType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MergeType


% --- Executes during object creation, after setting all properties.
function MergeType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MergeType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in KeepOriginal.
function KeepOriginal_Callback(hObject, eventdata, handles)
% hObject    handle to KeepOriginal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KeepOriginal
