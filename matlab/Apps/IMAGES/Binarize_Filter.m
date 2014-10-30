function varargout = Binarize_Filter(varargin)
% BINARIZE_FILTER MATLAB code for Binarize_Filter.fig
%      BINARIZE_FILTER, by itself, creates a new BINARIZE_FILTER or raises the existing
%      singleton*.
%
%      H = BINARIZE_FILTER returns the handle to a new BINARIZE_FILTER or the handle to
%      the existing singleton*.
%
%      BINARIZE_FILTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINARIZE_FILTER.M with the given input arguments.
%
%      BINARIZE_FILTER('Property','Value',...) creates a new BINARIZE_FILTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Binarize_Filter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Binarize_Filter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Binarize_Filter

% Last Modified by GUIDE v2.5 28-Jan-2013 23:30:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Binarize_Filter_OpeningFcn, ...
                   'gui_OutputFcn',  @Binarize_Filter_OutputFcn, ...
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


% --- Executes just before Binarize_Filter is made visible.
function Binarize_Filter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Binarize_Filter (see VARARGIN)

global SpikeImageData;

% Choose default command line output for Apply_Filter
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Apply_Filter wait for user response (see UIRESUME)
% uiwait(handles.figure1);
NumImages=length(SpikeImageData);

TextImage={};
if ~isempty(SpikeImageData)
    ImageInd=0;
    for i=1:NumImages
        ImageInd=ImageInd+1;
        TextImage{ImageInd}=[num2str(i),' - ',SpikeImageData(i).Label.ListText];
    end
    set(handles.ImageSelector,'String',TextImage);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.ImageSelector,'Value',intersect(1:ImageInd,Settings.ImageSelectorValue));
    set(handles.SelectAllImages,'Value',Settings.SelectAllImageValue);
    set(handles.FiltCropVal, 'String', Settings.FiltCropValString);
    set(handles.MaxDiam, 'String', Settings.MaxDiamValue);
    set(handles.MaxDiamUnits, 'Value', Settings.MaxDiamUnitsValue);
    set(handles.KeepFilts, 'Value', Settings.KeepFiltsValue);
end
    
SelectAllImages_Callback(hObject, eventdata, handles);


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.ImageSelectorValue=get(handles.ImageSelector,'Value');
Settings.SelectAllImageValue=get(handles.SelectAllImages,'Value');
Settings.FiltCropValString=get(handles.FiltCropVal, 'String');
Settings.MaxDiamValue=get(handles.MaxDiam, 'String');
Settings.MaxDiamUnitsValue=get(handles.MaxDiamUnits, 'Value');
Settings.KeepFiltsValue=get(handles.KeepFilts, 'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Binarize_Filter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeImageData

global xIndVec yIndVec xInd yInd mask circleMask halfEdgeLength thisFilt filtInd

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    h=waitbar(0, 'Cropping Filters, Saving...');
    
    % get parameters from interface
    if get(handles.SelectAllImages, 'Value')
        filtsToCrop=1:length(SpikeImageData);
    else
        filtsToCrop=get(handles.ImageSelector, 'Value');
    end
    cropVal=str2double(get(handles.FiltCropVal, 'String'));
    maxDiam=get(handles.MaxDiam, 'String');
    cropArea=~strcmp(maxDiam, 'none');
    if cropArea
        maxDiam=str2double(maxDiam);
    end
    
    if get(handles.KeepFilts, 'Value')
        numFilters=length(SpikeImageData);
    else
        numFilters=0;
    end
    subtractNeuropil=0;

    % convert um to pixels
    if get(handles.MaxDiamUnits, 'Value')==2
        umPerPixel=SpikeImageData(filtsToCrop(1)).Xposition(1,2)-...
            SpikeImageData(filtsToCrop(1)).Xposition(1,1);
        maxDiam=maxDiam/umPerPixel;
    end
    
    % create circular crop max for local cell area
    if cropArea
        halfEdgeLength=floor(maxDiam/2);
        x=repmat(-halfEdgeLength:halfEdgeLength, 2*halfEdgeLength+1, 1);
        y=fliplr(x)';
        circleMask=zeros(2*halfEdgeLength+1);
        circleMask(sqrt(x.^2+y.^2)<(maxDiam/2))=1;
    end
        
    
    % crop masks to proper max value, select local area, normalize, save
    waitbarInterval=floor(length(filtsToCrop)/10);
    for i=1:length(filtsToCrop)
        
        if mod(i, waitbarInterval)==0
            waitbar(i/length(filtsToCrop), h)
        end
        
        % crop filter by max value
        filtInd=filtsToCrop(i);
        thisFilt=double(SpikeImageData(filtInd).Image);
        [maxVec, yInd]=max(thisFilt);
        [maxVal, xInd]=max(maxVec);
        yInd=yInd(xInd);
        thisFilt(thisFilt<maxVal*cropVal)=0;
        
        % crop to maximum specified area
        xCoordMat=repmat(1:SpikeImageData(filtInd).DataSize(2), SpikeImageData(filtInd).DataSize(1), 1);
        yCoordMat=repmat((1:SpikeImageData(filtInd).DataSize(1))', 1, SpikeImageData(filtInd).DataSize(2));
        xInd=round(sum(sum(xCoordMat.*thisFilt))/sum(thisFilt(:)));
        yInd=round(sum(sum(yCoordMat.*thisFilt))/sum(thisFilt(:)));
        if cropArea
            mask=zeros(size(thisFilt));
            yIndVec=max(yInd-halfEdgeLength,1):min(yInd+halfEdgeLength, size(thisFilt,1));
            xIndVec=max(xInd-halfEdgeLength,1):min(xInd+halfEdgeLength, size(thisFilt,2));
            mask(yIndVec, xIndVec)=circleMask(1+abs(min(yInd-halfEdgeLength-1,0)):...
                end-abs(min(0, size(thisFilt,1)-(yInd+halfEdgeLength))),...
                1+abs(min(xInd-halfEdgeLength-1,0)):...
                end-abs(min(0, size(thisFilt,2)-(xInd+halfEdgeLength))));
            thisFilt=thisFilt.*mask;

        end
        NumberPixels=length(find(thisFilt>0));
        thisFilt(thisFilt>0)=1/NumberPixels;
        
        % save filter
        if numFilters~=0
            filtSaveInd=numFilters+i;
            SpikeImageData(filtSaveInd).Path=SpikeImageData(filtInd).Path;
            SpikeImageData(filtSaveInd).Filename=SpikeImageData(filtInd).Filename;
            SpikeImageData(filtSaveInd).DataSize=SpikeImageData(filtInd).DataSize;
            SpikeImageData(filtSaveInd).Xposition=SpikeImageData(filtInd).Xposition;
            SpikeImageData(filtSaveInd).Yposition=SpikeImageData(filtInd).Yposition;
            SpikeImageData(filtSaveInd).Zposition=SpikeImageData(filtInd).Zposition;
            SpikeImageData(filtSaveInd).Label=SpikeImageData(filtInd).Label;
            SpikeImageData(filtSaveInd).Path=SpikeImageData(filtInd).Path;
        else
            filtSaveInd=filtInd;
        end
        SpikeImageData(filtSaveInd).Image=thisFilt;
        SpikeImageData(filtSaveInd).Label.ListText=[SpikeImageData(filtInd).Label.ListText, ' max'];
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

% --- Executes on button press in ValidateValues.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Settings=GetSettings(hObject);
uiresume;


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

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function FiltCropVal_Callback(hObject, eventdata, handles)
% hObject    handle to FiltCropVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FiltCropVal as text
%        str2double(get(hObject,'String')) returns contents of FiltCropVal as a double


% --- Executes during object creation, after setting all properties.
function FiltCropVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FiltCropVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MaxDiam_Callback(hObject, eventdata, handles)
% hObject    handle to MaxDiam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxDiam as text
%        str2double(get(hObject,'String')) returns contents of MaxDiam as a double


% --- Executes during object creation, after setting all properties.
function MaxDiam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxDiam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MaxDiamUnits.
function MaxDiamUnits_Callback(hObject, eventdata, handles)
% hObject    handle to MaxDiamUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MaxDiamUnits contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MaxDiamUnits


% --- Executes during object creation, after setting all properties.
function MaxDiamUnits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxDiamUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in NormalizeFilts.
function NormalizeFilts_Callback(hObject, eventdata, handles)
% hObject    handle to NormalizeFilts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NormalizeFilts


% --- Executes on button press in KeepFilts.
function KeepFilts_Callback(hObject, eventdata, handles)
% hObject    handle to KeepFilts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KeepFilts
