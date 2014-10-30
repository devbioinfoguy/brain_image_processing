function varargout = Measure_Distance_Image(varargin)
% MEASURE_DISTANCE_IMAGE MATLAB code for Measure_Distance_Image.fig
%      MEASURE_DISTANCE_IMAGE, by itself, creates a new MEASURE_DISTANCE_IMAGE or raises the existing
%      singleton*.
%
%      H = MEASURE_DISTANCE_IMAGE returns the handle to a new MEASURE_DISTANCE_IMAGE or the handle to
%      the existing singleton*.
%
%      MEASURE_DISTANCE_IMAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MEASURE_DISTANCE_IMAGE.M with the given input arguments.
%
%      MEASURE_DISTANCE_IMAGE('Property','Value',...) creates a new MEASURE_DISTANCE_IMAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Measure_Distance_Image_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Measure_Distance_Image_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Measure_Distance_Image

% Last Modified by GUIDE v2.5 02-May-2012 15:33:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Measure_Distance_Image_OpeningFcn, ...
                   'gui_OutputFcn',  @Measure_Distance_Image_OutputFcn, ...
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


% --- Executes just before Measure_Distance_Image is made visible.
function Measure_Distance_Image_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Measure_Distance_Image (see VARARGIN)

% Choose default command line output for Measure_Distance_Image
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Measure_Distance_Image wait for user response (see UIRESUME)
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
    set(handles.Xstart,'String',Settings.XstartString);
    set(handles.Xend,'String',Settings.XendString);
    set(handles.Ystart,'String',Settings.YstartString);
    set(handles.Yend,'String',Settings.YendString);
    set(handles.DistanceUnits,'String',Settings.DistanceUnitsString);
end
    
ImageSel=get(handles.ImageSelector,'Value');

if (isfield(handles,'hFigImage') && ~isempty(handles.hFigImage) && ishandle(handles.hFigImage))
    figure(handles.hFigImage);
else
    handles.hFigImage=figure('Name','Reference Image','NumberTitle','off');
end

XPosVector=mean(SpikeImageData(ImageSel).Xposition(:,:),1);
YPosVector=mean(SpikeImageData(ImageSel).Yposition(:,:),2);
imagesc(XPosVector,YPosVector,SpikeImageData(ImageSel).Image);
xlabel(SpikeImageData(ImageSel).Label.XLabel);
ylabel(SpikeImageData(ImageSel).Label.YLabel);

Xstart=str2double(get(handles.Xstart,'String'));
Ystart=str2double(get(handles.Ystart,'String'));
Xend=str2double(get(handles.Xend,'String'));
Yend=str2double(get(handles.Yend,'String'));
hAxes = findobj(handles.hFigImage,'Type','axes');

pStart = impoint(hAxes(1), Xstart, Ystart);
pEnd = impoint(hAxes(1), Xend, Yend);
guidata(handles.output,handles);
CalcDistance(handles);

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.ImageSelectorValue=get(handles.ImageSelector,'Value');
Settings.XstartString=get(handles.Xstart,'String');
Settings.XendString=get(handles.Xend,'String');
Settings.YstartString=get(handles.Ystart,'String');
Settings.YendString=get(handles.Yend,'String');
Settings.DistanceUnitsString=get(handles.DistanceUnits,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Measure_Distance_Image_OutputFcn(hObject, eventdata, handles) 
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
if isfield(handles,'hFigImage')
    if (ishandle(handles.hFigImage))
        delete(handles.hFigImage);
    end
end

uiresume;

% This function does the job, ie calculate distance and update interface
function CalcDistance(handles)
global SpikeImageData;

ImageSel=get(handles.ImageSelector,'Value');
Xstart=str2double(get(handles.Xstart,'String'));
Ystart=str2double(get(handles.Ystart,'String'));
Xend=str2double(get(handles.Xend,'String'));
Yend=str2double(get(handles.Yend,'String'));

PixelsDistance=sqrt((Xend-Xstart)^2+(Yend-Ystart)^2);
set(handles.DistanceUnits,'String',num2str(PixelsDistance));

% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    % We turn it back on in the end
    Cleanup1=onCleanup(@()set(InterfaceObj,'Enable','on'));
    
    CalcDistance(handles);
    
    ValidateValues_Callback(hObject, eventdata, handles);
    
catch errorObj
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



function Xstart_Callback(hObject, eventdata, handles)
% hObject    handle to Xstart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Xstart as text
%        str2double(get(hObject,'String')) returns contents of Xstart as a double


% --- Executes during object creation, after setting all properties.
function Xstart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xstart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ystart_Callback(hObject, eventdata, handles)
% hObject    handle to Ystart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ystart as text
%        str2double(get(hObject,'String')) returns contents of Ystart as a double


% --- Executes during object creation, after setting all properties.
function Ystart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ystart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Xend_Callback(hObject, eventdata, handles)
% hObject    handle to Xend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Xend as text
%        str2double(get(hObject,'String')) returns contents of Xend as a double


% --- Executes during object creation, after setting all properties.
function Xend_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Yend_Callback(hObject, eventdata, handles)
% hObject    handle to Yend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Yend as text
%        str2double(get(hObject,'String')) returns contents of Yend as a double


% --- Executes during object creation, after setting all properties.
function Yend_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Yend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DistanceUnits_Callback(hObject, eventdata, handles)
% hObject    handle to DistanceUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DistanceUnits as text
%        str2double(get(hObject,'String')) returns contents of DistanceUnits as a double


% --- Executes during object creation, after setting all properties.
function DistanceUnits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DistanceUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RealDistance_Callback(hObject, eventdata, handles)
% hObject    handle to RealDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RealDistance as text
%        str2double(get(hObject,'String')) returns contents of RealDistance as a double


% --- Executes during object creation, after setting all properties.
function RealDistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RealDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ChangeStart.
function ChangeStart_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeImageData;

ImageSel=get(handles.ImageSelector,'Value');

if (isfield(handles,'hFigImage') && ~isempty(handles.hFigImage) && ishandle(handles.hFigImage))
    figure(handles.hFigImage);
else
    handles.hFigImage=figure('Name','Reference Image','NumberTitle','off');
end

XPosVector=mean(SpikeImageData(ImageSel).Xposition(:,:),1);
YPosVector=mean(SpikeImageData(ImageSel).Yposition(:,:),2);
imagesc(XPosVector,YPosVector,SpikeImageData(ImageSel).Image);
xlabel(SpikeImageData(ImageSel).Label.XLabel);
ylabel(SpikeImageData(ImageSel).Label.YLabel);

Xend=str2double(get(handles.Xend,'String'));
Yend=str2double(get(handles.Yend,'String'));

hAxes = findobj(handles.hFigImage,'Type','axes');

pEnd = impoint(hAxes(1), Xend, Yend);
pStart = impoint(hAxes(1));
pos = getPosition(pStart);

set(handles.Xstart,'String',num2str(pos(1)));
set(handles.Ystart,'String',num2str(pos(2)));
guidata(handles.output,handles);
CalcDistance(handles);

% --- Executes on button press in ChangeEnd.
function ChangeEnd_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeImageData;

ImageSel=get(handles.ImageSelector,'Value');

if (isfield(handles,'hFigImage') && ~isempty(handles.hFigImage) && ishandle(handles.hFigImage))
    figure(handles.hFigImage);
else
    handles.hFigImage=figure('Name','Reference Image','NumberTitle','off');
end

XPosVector=mean(SpikeImageData(ImageSel).Xposition(:,:),1);
YPosVector=mean(SpikeImageData(ImageSel).Yposition(:,:),2);
imagesc(XPosVector,YPosVector,SpikeImageData(ImageSel).Image);
xlabel(SpikeImageData(ImageSel).Label.XLabel);
ylabel(SpikeImageData(ImageSel).Label.YLabel);

Xstart=str2double(get(handles.Xstart,'String'));
Ystart=str2double(get(handles.Ystart,'String'));

hAxes = findobj(handles.hFigImage,'Type','axes');

pStart = impoint(hAxes(1), Xstart, Ystart);
pEnd = impoint(hAxes(1));
pos = getPosition(pEnd);

set(handles.Xend,'String',num2str(pos(1)));
set(handles.Yend,'String',num2str(pos(2)));
guidata(handles.output,handles);
CalcDistance(handles);
