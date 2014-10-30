function varargout = Behavior_Load_Cut_Concat(varargin)
% BEHAVIOR_LOAD_CUT_CONCAT 
%This APP goes through the files listed in filelist and downsamples,
%normalizes, and saves the files.

% Last Modified by Maggie 5-Sep-2012 21:34:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Behavior_Load_Cut_Concat_OpeningFcn, ...
                   'gui_OutputFcn',  @Behavior_Load_Cut_Concat_OutputFcn, ...
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


% This function is created by GUIDE for every GUI. Just put here all
% the code that you want to be executed before the GUI is made visible. 
function Behavior_Load_Cut_Concat_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Behavior_Load_Cut_Concat (see VARARGIN)

% Choose default command line output for Behavior_Load_Cut_Concat
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Here we read from the Settings structure created by the function
% GetSettings. This is used to reload saved settings from a previously
% opened instance of this Apps in the batch list.
if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.ListFile,'String',Settings.ListFileString);  
    set(handles.SpatDown,'String',Settings.SpatDownString);  
    set(handles.ListFile, 'Value', Settings.ListFileValue);
    set(handles.TextListFile,'String',Settings.TextListFileString);   
    set(handles.TextListFile, 'Value', Settings.TextListFileValue);
    set(handles.umPerPixel, 'String', Settings.umPerPixelString);
    set(handles.Framerate, 'String', Settings.FramerateString);
    set(handles.Concat, 'Value', Settings.ConcatValue);
    %set(handles.BlackThresh, 'String', Settings.BlackThreshString);
    %set(handles.RemoveBlack, 'Value', Settings.RemoveBlackValue);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)

handles=guidata(hObject);
Settings.ListFileString=get(handles.ListFile,'String');
Settings.SpatDownString=get(handles.SpatDown,'String');
Settings.ConcatValue=get(handles.Concat, 'Value');
Settings.ListFileValue=get(handles.ListFile, 'Value');
Settings.umPerPixelString=get(handles.umPerPixel, 'String');
Settings.FramerateString=get(handles.Framerate, 'String');
Settings.TextListFileString=get(handles.TextListFile,'String');
Settings.TextListFileValue=get(handles.TextListFile, 'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Behavior_Load_Cut_Concat_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.output;


% 'ApplyApps' is the main function of your Apps. It is launched by the
% Main interface when using batch mode. 
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SpikeMovieData
global readerObj TmpImage downsample_xy filelist textfilelist
global numFrames

try
    
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    downsample_xy = str2double(get(handles.SpatDown,'String'));
    filelist=get(handles.ListFile,'String');
    filevals=get(handles.ListFile, 'Value');
    textfilelist=get(handles.TextListFile,'String');
    textfilevals=get(handles.TextListFile, 'Value');
    
    filelist=filelist(filevals);
    textfilelist=textfilelist(textfilevals);
    
    concat=get(handles.Concat,'Value');
    if concat
        cInd=length(SpikeMovieData)+1;
        initConcat=0;
    end

    umPerPix=str2double(get(handles.umPerPixel, 'String'));
    framerate=eval(get(handles.Framerate, 'String'));
    
    h=waitbar(0,'Working...');
    
    if length(textfilelist)~=length(filelist)
        error('Must select same number of behavior videos as imaging text files')
    end
    
    numFrames=zeros(size(textfilelist));
    for fileInd=1:numel(textfilelist)
        fid=fopen(textfilelist{fileInd});
        thisText=textscan(fid, '%s');
        fclose(fid);
        for textLineInd=1:length(thisText{1})
            if strcmp(thisText{1}(textLineInd), 'FRAMES:')
                numFrames(fileInd)=str2double(thisText{1}(textLineInd+1));
            end
        end
    end
    totalFrames=sum(numFrames);
    
    
    %Go through each file in filelist
    for i = 1:numel(filelist)
        
        readerObj=VideoReader(filelist{i});
        
        TmpImage=read(readerObj, 1);
        TmpImage=rgb2gray(TmpImage);
        LocalImage = imresize(TmpImage, 1/downsample_xy);%Resize
        SizeImage=size(LocalImage);%Get the xy dimensions
        
        Numberframe=numFrames(i);% Number of frames
        
        % Pre-allocate the movie
        Movie=zeros(SizeImage(1),SizeImage(2),Numberframe,class(LocalImage));
        clear LocalImage SizeImage TmpImage

        
        for j=1:Numberframe

            TmpImage=read(readerObj, j);
            TmpImage=rgb2gray(TmpImage);
            if downsample_xy~=1
                Movie(:,:,j)=imresize(TmpImage,1/downsample_xy);
            else
                Movie(:,:,j)=TmpImage;
            end
            
        end
        
        if concat
            if ~initConcat
                frInd=0;
                SpikeMovieData(cInd).Movie=zeros([size(Movie,1), size(Movie,2), totalFrames], class(Movie));
                SpikeMovieData(cInd).Movie(:,:,frInd+(1:Numberframe))=Movie;
                frInd=frInd+Numberframe;
                SpikeMovieData(cInd).Path=filelist{1};
                SpikeMovieData(cInd).Filename=filelist{1};
                initConcat=1;
            else
                SpikeMovieData(cInd).Movie(:,:,frInd+(1:Numberframe))=Movie;
                frInd=frInd+Numberframe;
            end
            if i==numel(filelist)
                movSize=size(SpikeMovieData(cInd).Movie);
                SpikeMovieData(cInd).DataSize=movSize;
                xpos=repmat(umPerPix*(1:movSize(2)), movSize(1), 1);
                ypos=repmat(umPerPix*(1:movSize(1))', 1, movSize(2));
                SpikeMovieData(cInd).Xposition=xpos;
                SpikeMovieData(cInd).Yposition=ypos;
                SpikeMovieData(cInd).Zposition=zeros(size(xpos));
                if length(framerate)==1
                    SpikeMovieData(cInd).TimeFrame=(1/framerate)*(1:movSize(3));
                    SpikeMovieData(cInd).Exposure=(1/framerate)*ones(movSize(1:2));
                else
                    SpikeMovieData(cInd).TimeFrame=(1/framerate(i))*(1:movSize(3));
                    SpikeMovieData(cInd).Exposure=(1/framerate(i))*ones(movSize(1:2));
                end
                SpikeMovieData(cInd).TimePixel=zeros(movSize, 'uint8');
                SpikeMovieData(cInd).TimePixelUnits=1*10^(-6);
                SpikeMovieData(cInd).Label.XLabel='\mum';
                SpikeMovieData(cInd).Label.YLabel='\mum';
                SpikeMovieData(cInd).Label.ZLabel='\mum';
                SpikeMovieData(cInd).Label.CLabel='Intensity (au)';
                SpikeMovieData(cInd).Label.ListText='Behav movie';
            end
        end
        
        
        waitbar(i/numel(filelist),h);
    end
    delete(h);
    
    % We turn back on the interface
    set(InterfaceObj,'Enable','on');
    
    ValidateValues_Callback(hObject, eventdata, handles);
    
% In case of errors
catch errorObj
    % We turn back on the interface
    set(InterfaceObj,'Enable','on');
    
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
end


% 'ValidateValues' is executed in the end to trigger the end of your Apps and
% check all unneeded windows are closed.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% We give back control to the Main interface.
uiresume;


% This function opens the help that is written in the header of this M file.
function OpenHelp_Callback(hObject, eventdata, handles)
% hObject    handle to OpenHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CurrentMfilePath = mfilename('fullpath');
[PathToM, name, ext] = fileparts(CurrentMfilePath);
eval(['doc ',name]);


% --- Executes on selection change in ListFile.
function ListFile_Callback(hObject, eventdata, handles)
% hObject    handle to ListFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListFile contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListFile


% --- Executes during object creation, after setting all properties.
function ListFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddFiles.
function AddFiles_Callback(hObject, eventdata, handles)
% hObject    handle to AddFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName] = uigetfile('*.avi','Select AVI files','MultiSelect','on');

if iscell(FileName) || any(FileName~=0)
    currentFileList=get(handles.ListFile,'String');
    
    % This is because Matlab does only output cells if more than one file
    % is selected
    if ~iscell(FileName)
        FileName={FileName};
    end
    % We concatenate the list 
    for i=1:numel(FileName)
        currentFileList=[currentFileList;{fullfile(PathName,FileName{i})}];
    end
    set(handles.ListFile,'String',currentFileList);
end


function SpatDown_Callback(hObject, eventdata, handles)
% hObject    handle to SpatDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SpatDown as text
%        str2double(get(hObject,'String')) returns contents of SpatDown as a double


% --- Executes during object creation, after setting all properties.
function SpatDown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpatDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Concat.
function Concat_Callback(hObject, eventdata, handles)
% hObject    handle to Concat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Concat


function umPerPixel_Callback(hObject, eventdata, handles)
% hObject    handle to umPerPixel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of umPerPixel as text
%        str2double(get(hObject,'String')) returns contents of umPerPixel as a double


% --- Executes during object creation, after setting all properties.
function umPerPixel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to umPerPixel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Framerate_Callback(hObject, eventdata, handles)
% hObject    handle to Framerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Framerate as text
%        str2double(get(hObject,'String')) returns contents of Framerate as a double


% --- Executes during object creation, after setting all properties.
function Framerate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Framerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RemoveBlack.
function RemoveBlack_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveBlack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RemoveBlack



function BlackThresh_Callback(hObject, eventdata, handles)
% hObject    handle to BlackThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BlackThresh as text
%        str2double(get(hObject,'String')) returns contents of BlackThresh as a double


% --- Executes during object creation, after setting all properties.
function BlackThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BlackThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TextListFile.
function TextListFile_Callback(hObject, eventdata, handles)
% hObject    handle to TextListFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TextListFile contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TextListFile


% --- Executes during object creation, after setting all properties.
function TextListFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TextListFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddTextFiles.
function AddTextFiles_Callback(hObject, eventdata, handles)
% hObject    handle to AddTextFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global FileName

[FileName,PathName] = uigetfile('*.txt','Select text files','MultiSelect','on');

if iscell(FileName) || any(FileName~=0)
    currentFileList=get(handles.TextListFile,'String');
    
    % This is because Matlab does only output cells if more than one file
    % is selected
    if ~iscell(FileName)
        FileName={FileName};
    end
    % We concatenate the list 
    for i=1:numel(FileName)
        currentFileList=[currentFileList;{fullfile(PathName,FileName{i})}];
    end
    set(handles.TextListFile,'String',currentFileList);
end
