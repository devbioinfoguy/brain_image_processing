function varargout = Save_Image_Tif(varargin)
% SAVE_IMAGE_TIF MATLAB code for Save_Image_Tif.fig
%      SAVE_IMAGE_TIF, by itself, creates a new SAVE_IMAGE_TIF or raises the existing
%      singleton*.
%
%      H = SAVE_IMAGE_TIF returns the handle to a new SAVE_IMAGE_TIF or the handle to
%      the existing singleton*.
%
%      SAVE_IMAGE_TIF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAVE_IMAGE_TIF.M with the given input arguments.
%
%      SAVE_IMAGE_TIF('Property','Value',...) creates a new SAVE_IMAGE_TIF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Save_Image_Tif_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Save_Image_Tif_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Save_Image_Tif

% Last Modified by GUIDE v2.5 01-May-2012 14:29:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Save_Image_Tif_OpeningFcn, ...
                   'gui_OutputFcn',  @Save_Image_Tif_OutputFcn, ...
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


% --- Executes just before Save_Image_Tif is made visible.
function Save_Image_Tif_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Save_Image_Tif (see VARARGIN)

% Choose default command line output for Save_Image_Tif
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Save_Image_Tif wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global SpikeImageData;

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.UseOriginalPath,'Value',Settings.UseOriginalPathValue);
    set(handles.UseOriginal,'Value',Settings.UseOriginalValue);
    set(handles.PathText,'String',Settings.PathTextString);
    set(handles.IterateFile,'Value',Settings.IterateFileValue);
    set(handles.OverwriteFile,'Value',Settings.OverwriteFileValue);
    set(handles.FileTxt,'Value',Settings.FileTxtValue);
    set(handles.ImageSelectionList,'Value',Settings.ImageSelectionListValue);
    set(handles.ImageSelectionList,'String',Settings.ImageSelectionListString);
    set(handles.CompressionValue,'Value',Settings.CompressionValueValue);

    handles.Path=Settings.Path;
    handles.BasalFile=Settings.BasalFile;
    guidata(hObject, handles);
    
    UseOriginalPath_Callback(hObject, eventdata, handles);
    UseOriginal_Callback(hObject, eventdata, handles);
    
    handles=guidata(hObject);
    CreateFileName(hObject,handles);
else
    if ~isempty(SpikeImageData)
           
        if ~isempty(SpikeImageData(1).Path) && 0<exist(SpikeImageData(1).Path,'dir')
            handles.Path=SpikeImageData(1).Path;
        else
            handles.Path=cd;
        end
        
        set(handles.PathText,'String',handles.Path);
        
        if ~isempty(SpikeImageData(1).Filename)
            handles.BasalFile=SpikeImageData(1).Filename;
        else
            handles.BasalFile='Image.tif';
        end
        
        guidata(hObject, handles);
        CreateFileName(hObject,handles);
        
        for i=1:length(SpikeImageData)
            TextImage{i}=[num2str(i),' - ',SpikeImageData(i).Label.ListText];
        end
        
        set(handles.ImageSelectionList,'String',TextImage);
        set(handles.ImageSelectionList,'Value',1);
    end
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.UseOriginalPathValue=get(handles.UseOriginalPath,'Value');
Settings.UseOriginalValue=get(handles.UseOriginal,'Value');
Settings.PathTextString=get(handles.PathText,'String');
Settings.IterateFileValue=get(handles.IterateFile,'Value');
Settings.OverwriteFileValue=get(handles.OverwriteFile,'Value');
Settings.FileTxtValue=get(handles.FileTxt,'Value');
Settings.ImageSelectionListValue=get(handles.ImageSelectionList,'Value');
Settings.ImageSelectionListString=get(handles.ImageSelectionList,'String');
Settings.Path=handles.Path;
Settings.BasalFile=handles.BasalFile;
Settings.CompressionValue=get(handles.Compression,'Value');



% --- Outputs from this function are returned to the command line.
function varargout = Save_Image_Tif_OutputFcn(hObject, eventdata, handles) 
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
global SpikeImageData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    ListImageToSave=get(handles.ImageSelectionList,'Value');
    FileSaving=fullfile(handles.Path,handles.File);
    
    h=waitbar(0,'Saving...');
    TifFile = Tiff(FileSaving,'w');
    imgdata=SpikeImageData(ListImageToSave).Image;
    
    % We populate the tag on pixel format depending on the current data
    % type
    switch class(imgdata)
        case 'logical'
            tagstruct.SampleFormat=1;
            tagstruct.BitsPerSample=1;
        case 'uint16'
            tagstruct.SampleFormat=1;
            tagstruct.BitsPerSample=16;
        case 'int16'
            tagstruct.SampleFormat=2;
            tagstruct.BitsPerSample=16;
        case 'single'
            tagstruct.SampleFormat=3;
            tagstruct.BitsPerSample=32;
        case 'double'
            tagstruct.SampleFormat=3;
            tagstruct.BitsPerSample=64;
        case 'uint8'
            tagstruct.SampleFormat=1;
            tagstruct.BitsPerSample=8;
        case 'int8'
            tagstruct.SampleFormat=2;
            tagstruct.BitsPerSample=8;
        case 'uint32'
            tagstruct.SampleFormat=1;
            tagstruct.BitsPerSample=32;
        case 'int32'
            tagstruct.SampleFormat=2;
            tagstruct.BitsPerSample=32;
    end
    
    % We populate compression scheme
    switch get(handles.Compression,'Value')
        case 1
            % No compression
            tagstruct.Compression=1;
        case 2
            % LZW lossless
            tagstruct.Compression=5;
        case 3
            % Packbits lossless
            tagstruct.Compression=32773;
        case 4
            % Deflate lossless
            tagstruct.Compression=32946;
    end
    
    tagstruct.ImageLength = size(imgdata,1);
    tagstruct.ImageWidth = size(imgdata,2);
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software = 'MATLAB';
    
    TifFile.setTag(tagstruct);
    TifFile.write(SpikeImageData(ListImageToSave).Image);
    TifFile.writeDirectory();
    
    TifFile.close();
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
uiresume;

% --- Executes on button press in ChoosePath.
function ChoosePath_Callback(hObject, eventdata, handles)
% hObject    handle to ChoosePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Oldpath=cd;

cd(handles.Path);

% Open directory interface
NewPath=uigetdir(handles.Path);

cd(Oldpath);

% If "Cancel" is selected then return
if isequal(NewPath,0)
    return
else
    handles.Path=NewPath;
    set(handles.PathText,'String',NewPath);
    set(handles.UseOriginalPath,'Value',0);
    guidata(hObject,handles);
    CreateFileName(hObject, handles);
end
   
% Function to create the filename based on the current selected basal
% filename
function CreateFileName(hObject, handles)

FullFilePath=fullfile(handles.Path,handles.BasalFile);
[pathstr, name, ext] = fileparts(FullFilePath);
NewName=[name '.tif'];
CorrespondingMat=fullfile(pathstr,NewName);
while (exist(CorrespondingMat, 'file')==2 && get(handles.IterateFile,'Value')==1)
    I=strfind(name, '-v');
    if ~isempty(I)
        % if it can find the pattern, we take the last one
        IndiceStart=I(length(I));
        Strnumber=str2num(name(IndiceStart+2:length(name)));
        if ~isempty(Strnumber)
            Strnumber=Strnumber+1;
        else
            Strnumber=1;
        end
        name=[name(1:IndiceStart-1) '-v' num2str(Strnumber)];
    else
        Strnumber=1;
        AddString='-v1';
        name=[name AddString];
    end
    NewName=[name '.tif'];
    CorrespondingMat=fullfile(pathstr,NewName);
    FullFilePath=fullfile(handles.Path,NewName);
end
handles.File=NewName;
set(handles.FileTxt,'String',NewName);
guidata(hObject,handles);


% --- Executes on button press in ChangeFilename.
function ChangeFilename_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Oldpath=cd;

cd(handles.Path);

% Open file path
[filename, pathname] = uiputfile( ...
    {'*.tif','All Files (*.tif)'},'Select Tif File');

cd(Oldpath);

% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
    return
else
    handles.BasalFile=filename;
    if ~strcmp(handles.Path,pathname)
        handles.Path=pathname;
        set(handles.PathText,'String',pathname);
        set(handles.UseOriginalPath,'Value',0);
    end    
    
    set(handles.UseOriginal,'Value',0);
    
    guidata(hObject,handles);
    CreateFileName(hObject,handles); 
end


% --- Executes on button press in UseOriginalPath.
function UseOriginalPath_Callback(hObject, eventdata, handles)
% hObject    handle to UseOriginalPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UseOriginalPath
global SpikeImageData;

if (get(hObject,'Value')==1)
    set(handles.PathText,'String',SpikeImageData(1).Path);
    handles.Path=SpikeImageData(1).Path;
    guidata(hObject,handles);
end
CreateFileName(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ChoosePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChoosePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in UseOriginal.
function UseOriginal_Callback(hObject, eventdata, handles)
% hObject    handle to UseOriginal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UseOriginal
global SpikeImageData;

if (get(hObject,'Value')==1)
    handles.BasalFile=SpikeImageData(1).Filename;
    guidata(hObject,handles);
    CreateFileName(hObject,handles); 
end


% --- Executes on button press in OverwriteFile.
function OverwriteFile_Callback(hObject, eventdata, handles)
% hObject    handle to OverwriteFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OverwriteFile
set(handles.IterateFile,'Value',~get(hObject,'Value'));
CreateFileName(hObject,handles);

% --- Executes on button press in IterateFile.
function IterateFile_Callback(hObject, eventdata, handles)
% hObject    handle to IterateFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IterateFile
set(handles.OverwriteFile,'Value',~get(hObject,'Value'));
CreateFileName(hObject,handles);


% --- Executes on selection change in ImageSelectionList.
function ImageSelectionList_Callback(hObject, eventdata, handles)
% hObject    handle to ImageSelectionList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ImageSelectionList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImageSelectionList


% --- Executes during object creation, after setting all properties.
function ImageSelectionList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageSelectionList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Compression.
function Compression_Callback(hObject, eventdata, handles)
% hObject    handle to Compression (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Compression contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Compression


% --- Executes during object creation, after setting all properties.
function Compression_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Compression (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
