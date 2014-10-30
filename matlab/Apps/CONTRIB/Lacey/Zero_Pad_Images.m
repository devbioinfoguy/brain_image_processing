function varargout = Zero_Pad_Images(varargin)
% ZERO_PAD_IMAGES MATLAB code for Zero_Pad_Images.fig
%      ZERO_PAD_IMAGES, by itself, creates a new ZERO_PAD_IMAGES or raises the existing
%      singleton*.
%
%      H = ZERO_PAD_IMAGES returns the handle to a new ZERO_PAD_IMAGES or the handle to
%      the existing singleton*.
%
%      ZERO_PAD_IMAGES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ZERO_PAD_IMAGES.M with the given input arguments.
%
%      ZERO_PAD_IMAGES('Property','Value',...) creates a new ZERO_PAD_IMAGES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Zero_Pad_Images_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Zero_Pad_Images_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Zero_Pad_Images

% Last Modified by GUIDE v2.5 28-Nov-2012 13:34:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Zero_Pad_Images_OpeningFcn, ...
                   'gui_OutputFcn',  @Zero_Pad_Images_OutputFcn, ...
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


% --- Executes just before Zero_Pad_Images is made visible.
function Zero_Pad_Images_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Zero_Pad_Images (see VARARGIN)

% Choose default command line output for Zero_Pad_Images
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Zero_Pad_Images wait for user response (see UIRESUME)
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
    set(handles.ZerosLocation,'Value',Settings.ZerosLocationValue);
    set(handles.KeepOriginalImages,'Value',Settings.KeepOriginalImagesValue);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.ImageSelectorValue=get(handles.ImageSelector,'Value');
Settings.ZerosLocationValue=get(handles.ZerosLocation,'Value');
Settings.KeepOriginalImagesValue=get(handles.KeepOriginalImages,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Zero_Pad_Images_OutputFcn(hObject, eventdata, handles) 
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
global SpikeImageData

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    ImageSel=get(handles.ImageSelector,'Value');
    
    numImages=length(SpikeImageData);
    
    if ~isempty(ImageSel)
        % Checking that they all are of the same size
        sizeVec=zeros(length(ImageSel),2);
        h=waitbar(0,'Zero-padding images...');
        
        for i=1:length(ImageSel)
            sizeVec(i, :)=size(SpikeImageData(ImageSel(i)).Image);
        end
        
        keepImages=get(handles.KeepOriginalImages, 'Value');
        zerosLoc=get(handles.ZerosLocation, 'Value');
        vertSize=max(sizeVec(:,1));
        horSize=max(sizeVec(:,2));
        waitbarDivider=length(ImageSel)/10;
        for i=1:length(ImageSel)
            thisImageInd=ImageSel(i);
            thisImage=SpikeImageData(thisImageInd).Image;
            thisSizeVert=size(thisImage,1);
            thisSizeHor=size(thisImage,2);
            numZerosVert=vertSize-thisSizeVert;
            numZerosHor=horSize-thisSizeHor;
            switch zerosLoc
                case 1  % bottom right
                    thisImage=[thisImage, zeros(thisSizeVert, numZerosHor);
                        zeros(numZerosVert, thisSizeHor+numZerosHor)];
                case 2  % bottom left
                    thisImage=[zeros(thisSizeVert, numZerosHor), thisImage;
                        zeros(numZerosVert, thisSizeHor+numZerosHor)];
                case 3  % top right
                    thisImage=[zeros(numZerosVert, thisSizeHor+numZerosHor);
                        thisImage, zeros(thisSizeVert, numZerosHor)];
                case 4  % top left
                    thisImage=[zeros(numZerosVert, thisSizeHor+numZerosHor);
                        zeros(thisSizeVert, numZerosHor), thisImage];
            end
            if keepImages
                saveInd=numImages+i;
                SpikeImageData(saveInd)=SpikeImageData(thisImageInd);
            else
                saveInd=thisImageInd;
            end
            SpikeImageData(saveInd).Image=thisImage;
            SpikeImageData(saveInd).DataSize=size(SpikeImageData(saveInd).Image);
            
            thisDeltaX=diff(SpikeImageData(thisImageInd).Xposition(1,1:2));
            newXpos=cumsum(thisDeltaX*ones(size(thisImage)),2);
            SpikeImageData(saveInd).Xposition=newXpos;
            thisDeltaY=diff(SpikeImageData(thisImageInd).Yposition(1:2,1));
            newYpos=cumsum(thisDeltaY*ones(size(thisImage)),1);
            SpikeImageData(saveInd).Yposition=newYpos;
            SpikeImageData(saveInd).Zposition=SpikeImageData(thisImageInd).Zposition(1,1)*ones(size(thisImage));
            
            if mod(i, waitbarDivider)==0
                waitbar(i/length(ImageSel), h);
            end
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


% --- Executes on selection change in ZerosLocation.
function ZerosLocation_Callback(hObject, eventdata, handles)
% hObject    handle to ZerosLocation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ZerosLocation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ZerosLocation


% --- Executes during object creation, after setting all properties.
function ZerosLocation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ZerosLocation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in KeepOriginalImages.
function KeepOriginalImages_Callback(hObject, eventdata, handles)
% hObject    handle to KeepOriginalImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KeepOriginalImages
