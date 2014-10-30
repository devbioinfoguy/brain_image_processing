function varargout = Load_Image_ImageFile(varargin)
% LOAD_IMAGE_IMAGEFILE MATLAB code for Load_Image_ImageFile.fig
%      LOAD_IMAGE_IMAGEFILE, by itself, creates a new LOAD_IMAGE_IMAGEFILE or raises the existing
%      singleton*.
%
%      H = LOAD_IMAGE_IMAGEFILE returns the handle to a new LOAD_IMAGE_IMAGEFILE or the handle to
%      the existing singleton*.
%
%      LOAD_IMAGE_IMAGEFILE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOAD_IMAGE_IMAGEFILE.M with the given input arguments.
%
%      LOAD_IMAGE_IMAGEFILE('Property','Value',...) creates a new LOAD_IMAGE_IMAGEFILE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Load_Image_ImageFile_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Load_Image_ImageFile_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Load_Image_ImageFile

% Last Modified by GUIDE v2.5 16-Apr-2012 09:46:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Load_Image_ImageFile_OpeningFcn, ...
                   'gui_OutputFcn',  @Load_Image_ImageFile_OutputFcn, ...
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


% --- Executes just before Load_Image_ImageFile is made visible.
function Load_Image_ImageFile_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Load_Image_ImageFile (see VARARGIN)

% Choose default command line output for Load_Image_ImageFile
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Load_Image_ImageFile wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.Filename,'String',Settings.FilenameString);
    set(handles.PixelLabel,'String',Settings.PixelLabelString);
    set(handles.XSinglePixelSize,'String',Settings.XSinglePixelSizeString);
    set(handles.YSinglePixelSize,'String',Settings.YSinglePixelSizeString);
    set(handles.UnitX,'String',Settings.UnitXString);
    set(handles.UnitY,'String',Settings.UnitYString);
    set(handles.ImageName,'String',Settings.ImageNameString);
    set(handles.LoadBehSelect,'Value',Settings.LoadBehSelectValue);
end
    

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.FilenameString=get(handles.Filename,'String');
Settings.XSinglePixelSizeString=get(handles.XSinglePixelSize,'String');
Settings.YSinglePixelSizeString=get(handles.YSinglePixelSize,'String');
Settings.PixelLabelString=get(handles.PixelLabel,'String');
Settings.UnitXString=get(handles.UnitX,'String');
Settings.UnitYString=get(handles.UnitY,'String');
Settings.ImageNameString=get(handles.ImageName,'String');
Settings.LoadBehSelectValue=get(handles.LoadBehSelect,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Load_Image_ImageFile_OutputFcn(hObject, eventdata, handles) 
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
    
    % We turn it back on in the end
    Cleanup1=onCleanup(@()set(InterfaceObj,'Enable','on'));
    
    h=waitbar(0,'Reading file');
    
    % We close it in the end
    Cleanup2=onCleanup(@()delete(h));
      
    if (1==get(handles.LoadBehSelect,'Value'))
        InitImages();
        BeginImage=1;
    else
        BeginImage=length(SpikeImageData)+1;
    end   
    
    Filenane=get(handles.Filename,'String');
    
    [pathstr, name, ext] = fileparts(Filenane);
    
    % We load first image to get image size and Class type
    SpikeImageData(BeginImage).Path=pathstr;
    SpikeImageData(BeginImage).Filename=[name ext];
    
    % For now, we only take grayscale image
    % RGB channels are averaged
    SpikeImageData(BeginImage).Image=mean(imread(Filenane),3);
    
    SpikeImageData(BeginImage).DataSize=size(SpikeImageData(BeginImage).Image);
    
    % We get the X and Y calibration values from the interface
    RatioPixelSpaceX=str2num(get(handles.XSinglePixelSize,'String'));
    RatioPixelSpaceY=str2num(get(handles.YSinglePixelSize,'String'));
    
    % We create the position matrix that store X,Y,Z position of all pixels
    [SpikeImageData(BeginImage).Xposition,SpikeImageData(BeginImage).Yposition] ...
        = meshgrid(RatioPixelSpaceX*(1:SpikeImageData(BeginImage).DataSize(2)),RatioPixelSpaceY*(1:SpikeImageData(BeginImage).DataSize(1)));
    SpikeImageData(BeginImage).Zposition(:,:)=zeros(size(SpikeImageData(BeginImage).Xposition));
    
    SpikeImageData(BeginImage).Label.XLabel=get(handles.UnitX,'String');
    SpikeImageData(BeginImage).Label.YLabel=get(handles.UnitY,'String');
    SpikeImageData(BeginImage).Label.ZLabel='';
    SpikeImageData(BeginImage).Label.CLabel=get(handles.PixelLabel,'String');
    SpikeImageData(BeginImage).Label.ListText=get(handles.ImageName,'String');  
    
    ValidateValues_Callback(hObject, eventdata, handles);
    
catch errorObj
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
end

% --- Executes on button press in SelectFile.
function SelectFile_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

InterfaceObj=findobj(handles.output,'Enable','on');
set(InterfaceObj,'Enable','off');

% We turn it back on in the end
Cleanup1=onCleanup(@()set(InterfaceObj,'Enable','on'));

% Open file path
[fileInLoading,user_canceled]=imgetfile;

% Open file if exist
% If "Cancel" is selected then return
if user_canceled==1
    return
    
    % Otherwise construct the fullfilename and Check and load the file
else
    % To keep the path accessible to futur request
    [pathstr, name, ext]=fileparts(fileInLoading);
    cd(pathstr);
    
    if (exist(fileInLoading)==2)
        set(handles.Filename,'String',fileInLoading);
    end
    
end



function XSinglePixelSize_Callback(hObject, eventdata, handles)
% hObject    handle to XSinglePixelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XSinglePixelSize as text
%        str2double(get(hObject,'String')) returns contents of XSinglePixelSize as a double


% --- Executes during object creation, after setting all properties.
function XSinglePixelSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XSinglePixelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in LoadBehSelect.
function LoadBehSelect_Callback(hObject, eventdata, handles)
% hObject    handle to LoadBehSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LoadBehSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LoadBehSelect


% --- Executes during object creation, after setting all properties.
function LoadBehSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LoadBehSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Filename.
function FilenameList_Callback(hObject, eventdata, handles)
% hObject    handle to Filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Filename contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Filename


% --- Executes during object creation, after setting all properties.
function Filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function YSinglePixelSize_Callback(hObject, eventdata, handles)
% hObject    handle to YSinglePixelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YSinglePixelSize as text
%        str2double(get(hObject,'String')) returns contents of YSinglePixelSize as a double


% --- Executes during object creation, after setting all properties.
function YSinglePixelSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YSinglePixelSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PixelLabel_Callback(hObject, eventdata, handles)
% hObject    handle to PixelLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PixelLabel as text
%        str2double(get(hObject,'String')) returns contents of PixelLabel as a double


% --- Executes during object creation, after setting all properties.
function PixelLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PixelLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ImageName_Callback(hObject, eventdata, handles)
% hObject    handle to ImageName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ImageName as text
%        str2double(get(hObject,'String')) returns contents of ImageName as a double


% --- Executes during object creation, after setting all properties.
function ImageName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function UnitX_Callback(hObject, eventdata, handles)
% hObject    handle to UnitX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of UnitX as text
%        str2double(get(hObject,'String')) returns contents of UnitX as a double


% --- Executes during object creation, after setting all properties.
function UnitX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UnitX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function UnitY_Callback(hObject, eventdata, handles)
% hObject    handle to UnitY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of UnitY as text
%        str2double(get(hObject,'String')) returns contents of UnitY as a double


% --- Executes during object creation, after setting all properties.
function UnitY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UnitY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
