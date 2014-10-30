function varargout = Sync_Position_With_Imaging(varargin)
% SYNC_POSITION_WITH_IMAGING 
%This APP goes through the files listed in filelist and downsamples,
%normalizes, and saves the files.

% Last Modified by Maggie 5-Sep-2012 21:34:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Sync_Position_With_Imaging_OpeningFcn, ...
                   'gui_OutputFcn',  @Sync_Position_With_Imaging_OutputFcn, ...
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
function Sync_Position_With_Imaging_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Sync_Position_With_Imaging (see VARARGIN)
global SpikeTraceData

% Choose default command line output for Sync_Position_With_Imaging
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


NumberTraces=length(SpikeTraceData);

if ~isempty(SpikeTraceData)
    for i=1:NumberTraces
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.ImagingTraceSelector,'String',TextTrace);
    set(handles.PositionTraceSelector,'String',TextTrace);
end

% Here we read from the Settings structure created by the function
% GetSettings. This is used to reload saved settings from a previously
% opened instance of this Apps in the batch list.
if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.ListFile,'String',Settings.ListFileString);  
    set(handles.ListFile, 'Value', Settings.ListFileValue);
    set(handles.ImagingTraceSelector, 'Value', Settings.ImagingTraceSelectorValue);
    set(handles.PositionTraceSelector, 'Value', Settings.PositionTraceSelectorValue);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.ListFileString=get(handles.ListFile,'String');
Settings.ListFileValue=get(handles.ListFile, 'Value');
Settings.ImagingTraceSelectorValue=get(handles.ImagingTraceSelector, 'Value');
Settings.PositionTraceSelectorValue=get(handles.PositionTraceSelector, 'Value');



% --- Outputs from this function are returned to the command line.
function varargout = Sync_Position_With_Imaging_OutputFcn(hObject, eventdata, handles) 
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

global SpikeTraceData
global numFrames numSeconds behaviorTime thisText

try
    
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    filelist=get(handles.ListFile,'String');
    filevals=get(handles.ListFile, 'Value');
    
    filelist=filelist(filevals);
    
    h=waitbar(0,'Working...');
    
    positionTraces=get(handles.PositionTraceSelector, 'Value');
    imagingTraces=get(handles.ImagingTraceSelector, 'Value');
    
    if length(positionTraces)~=length(filelist)
        error('Must select same number of position traces as imaging text files')
    end
    
    numFrames=zeros(size(filelist));
    numSeconds=zeros(size(filelist));
    for fileInd=1:numel(filelist)
        fid=fopen(filelist{fileInd});
        thisText=textscan(fid, '%s');
        fclose(fid);
        for textLineInd=1:length(thisText{1})
            if strcmp(thisText{1}(textLineInd), 'FRAMES:')
                numFrames(fileInd)=str2double(thisText{1}(textLineInd+1));
            end
            if strcmp(thisText{1}(textLineInd), 'TIME:')
                timeTextLine=thisText{1}(textLineInd+1);
                colonIndex=find(timeTextLine{1}==':');
                numSeconds(fileInd)=str2double(timeTextLine{1}(1:(colonIndex-1)))*60....
                    +str2double(timeTextLine{1}((colonIndex+1):end));
            end
        end
        behaviorTime(fileInd,:)=SpikeTraceData(positionTraces(fileInd)).XVector(end)...
            -SpikeTraceData(positionTraces(fileInd)).XVector(1)...
            +SpikeTraceData(positionTraces(fileInd)).XVector(2)...
            -SpikeTraceData(positionTraces(fileInd)).XVector(1);
    end
    cumNumFrames=cumsum(numFrames);
    totalNumFrames=sum(numFrames);
    totalTime=sum(numSeconds)/60

    dividerWaitbar=round(length(imagingTraces)/10);
    for traceInd=1:numel(imagingTraces)
        thisTraceIndex=imagingTraces(traceInd);
        thisX=SpikeTraceData(thisTraceIndex).XVector;
        if length(thisX)~=totalNumFrames
            error('One or more imaging traces does not have the same number of frames as the text files indicate')
        end
        
        for trialInd=1:length(numFrames)
            thisDeltaT=behaviorTime(trialInd)/numFrames(trialInd);
            if trialInd==1
                thisX(1:numFrames(1))=thisDeltaT*(1:numFrames(1));
            else
                thisX(cumNumFrames(trialInd-1)+(1:numFrames(trialInd)))=thisX(cumNumFrames(trialInd-1))+thisDeltaT*(1:numFrames(trialInd));
            end
        end
        if thisX(end)~=sum(behaviorTime)
            thisX
        end
        
        SpikeTraceData(thisTraceIndex).XVector=thisX;

        if mod(traceInd, dividerWaitbar)==0
            waitbar(traceInd/numel(imagingTraces),h);
        end
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

global FileName PathName

[FileName,PathName] = uigetfile('*.txt','Select txt files','MultiSelect','on');

if PathName~=0
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

% --- Executes on button press in ChangeDir.
function ChangeDir_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

folder_name = uigetdir;

if folder_name~=0
    set(handles.OutputDirectory,'String',folder_name);
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


% --- Executes on button press in concatCR.
function concatCR_Callback(hObject, eventdata, handles)
% hObject    handle to concatCR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of concatCR



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


% --- Executes on selection change in ImagingTraceSelector.
function ImagingTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to ImagingTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ImagingTraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImagingTraceSelector


% --- Executes during object creation, after setting all properties.
function ImagingTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImagingTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PositionTraceSelector.
function PositionTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to PositionTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PositionTraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PositionTraceSelector


% --- Executes during object creation, after setting all properties.
function PositionTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PositionTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
