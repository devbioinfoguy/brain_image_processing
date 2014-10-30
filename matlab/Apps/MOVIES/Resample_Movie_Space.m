function varargout = Resample_Movie_Space(varargin)
% RESAMPLE_MOVIE_SPACE MATLAB code for Resample_Movie_Space.fig
%      RESAMPLE_MOVIE_SPACE, by itself, creates a new RESAMPLE_MOVIE_SPACE or raises the existing
%      singleton*.
%
%      H = RESAMPLE_MOVIE_SPACE returns the handle to a new RESAMPLE_MOVIE_SPACE or the handle to
%      the existing singleton*.
%
%      RESAMPLE_MOVIE_SPACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RESAMPLE_MOVIE_SPACE.M with the given input arguments.
%
%      RESAMPLE_MOVIE_SPACE('Property','Value',...) creates a new RESAMPLE_MOVIE_SPACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Resample_Movie_Space_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Resample_Movie_Space_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Resample_Movie_Space

% Last Modified by GUIDE v2.5 06-Feb-2012 23:32:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Resample_Movie_Space_OpeningFcn, ...
                   'gui_OutputFcn',  @Resample_Movie_Space_OutputFcn, ...
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


% --- Executes just before Resample_Movie_Space is made visible.
function Resample_Movie_Space_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Resample_Movie_Space (see VARARGIN)
global SpikeMovieData;

% Choose default command line output for Resample_Movie_Space
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Resample_Movie_Space wait for user response (see UIRESUME)
% uiwait(handles.figure1);

NumberMovies=length(SpikeMovieData);
if ~isempty(SpikeMovieData)
    for i=1:NumberMovies
        TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
    end
    set(handles.MovieSelector,'String',TextMovie);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.MovieSelector,'Value',intersect(1:NumberMovies,Settings.MovieSelectorValue));
    set(handles.DimensionReduction,'String',Settings.DimensionReductionString);
    set(handles.ResolutionRatio,'String',Settings.ResolutionRatioString);
    set(handles.selectInterpMethod,'Value',Settings.selectInterpMethodValue);
    set(handles.CurrentFrameValue,'String',Settings.CurrentFrameValueString);
    set(handles.FinalWidthPixel,'String',Settings.FinalWidthPixelString);
    set(handles.FinalHeightPixel,'String',Settings.FinalHeightPixelString);
    handles.CropRect=Settings.CropRect;
else
    if ~isempty(SpikeMovieData)
        set(handles.MovieSelector,'Value',1);
        LocalSize=SpikeMovieData(1).DataSize;
        handles.CropRect=[1 1 LocalSize(2) LocalSize(1)];
    end
end
guidata(hObject,handles);

if ~isempty(SpikeMovieData)
    UpdateFinalResolution(handles);
end

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.DimensionReductionString=get(handles.DimensionReduction,'String');
Settings.ResolutionRatioString=get(handles.ResolutionRatio,'String');
Settings.selectInterpMethodValue=get(handles.selectInterpMethod,'Value');
Settings.CurrentFrameValueString=get(handles.CurrentFrameValue,'String');
Settings.FinalWidthPixelString=get(handles.FinalWidthPixel,'String');
Settings.FinalHeightPixelString=get(handles.FinalHeightPixel,'String');
Settings.CropRect=handles.CropRect;


% --- Outputs from this function are returned to the command line.
function varargout = Resample_Movie_Space_OutputFcn(hObject, eventdata, handles) 
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
if isfield(handles,'hFigImageTest')
    if (ishandle(handles.hFigImageTest))
        delete(handles.hFigImageTest);
    end
end

uiresume;


% This function update the display of number of lines and columns in the
% final picture given the current settings in the interface
function UpdateFinalResolution(handles)
global SpikeMovieData;

MovieApplied=get(handles.MovieSelector,'Value');

[FinalNumRows FinalNumCols]=FinalSize(handles,SpikeMovieData(MovieApplied).Movie(:,:,1));
set(handles.FinalWidthPixel,'String',num2str(FinalNumCols));
set(handles.FinalHeightPixel,'String',num2str(FinalNumRows));


% This function computes the final image size based on the current selected
% settings
function [FinalNumRows FinalNumCols]=FinalSize(handles,InputImage)

% We first get all the selected parameters from the interface
ResolutionRed=str2double(get(handles.DimensionReduction,'String'));
ResolutionRedHorVert=str2double(get(handles.ResolutionRatio,'String'));

IntermediatePic = imcrop(InputImage, handles.CropRect); 

CurrentSize=size(IntermediatePic);
[MaxDim,IndiceMax]=max(CurrentSize);

switch IndiceMax
    case 1
        FinalNumRows=round(MaxDim/ResolutionRed);
        FinalNumCols=round(CurrentSize(2)*ResolutionRedHorVert/ResolutionRed);
    case 2
        FinalNumRows=round(CurrentSize(1)*ResolutionRedHorVert/ResolutionRed);
        FinalNumCols=round(MaxDim/ResolutionRed);        
end


% This function applies all the current selected filters to the input image
function OutputPic=FilterSelectedImage(handles,InputImage,FinalNumRows,FinalNumCols)
ListMethods=get(handles.selectInterpMethod,'String');
InterpMethods=char(ListMethods{get(handles.selectInterpMethod,'Value')});
IntermediatePic = imcrop(InputImage, handles.CropRect); 
OutputPic=imresize(IntermediatePic,'OutputSize',[FinalNumRows FinalNumCols],'Method',InterpMethods);


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    MovieApplied=get(handles.MovieSelector,'Value');
    
    % We measure the new size to be to allow preallocation of the Storing
    % matrix.
    [FinalNumRows FinalNumCols]=FinalSize(handles,SpikeMovieData(MovieApplied).Movie(:,:,1))
    
    % waitbar is consuming too much ressources, so I divide its access
    dividerWaitBar=10^(floor(log10(SpikeMovieData(MovieApplied).DataSize(3)))-1);
    
    % We prallocate the big matrixes.
    NewMovie=zeros([FinalNumRows FinalNumCols SpikeMovieData(MovieApplied).DataSize(3)],class(SpikeMovieData(MovieApplied).Movie));
    NewTime=zeros([FinalNumRows FinalNumCols SpikeMovieData(MovieApplied).DataSize(3)],class(SpikeMovieData(MovieApplied).TimePixel));
    
    h=waitbar(0,'Changing resolution...');
    for i=1:SpikeMovieData(MovieApplied).DataSize(3)
        NewMovie(:,:,i)=FilterSelectedImage(handles,SpikeMovieData(MovieApplied).Movie(:,:,i),FinalNumRows,FinalNumCols);
        NewTime(:,:,i)=FilterSelectedImage(handles,SpikeMovieData(MovieApplied).TimePixel(:,:,i),FinalNumRows,FinalNumCols);
        
        if (round(i/dividerWaitBar)==i/dividerWaitBar)
            waitbar(i/SpikeMovieData(MovieApplied).DataSize(3),h);
        end
    end
    
    SpikeMovieData(MovieApplied).Movie=NewMovie;
    SpikeMovieData(MovieApplied).TimePixel=NewTime;
    SpikeMovieData(MovieApplied).DataSize=size(SpikeMovieData(MovieApplied).Movie);
    
    % We also adjust the single time matrix
    SpikeMovieData(MovieApplied).Xposition=FilterSelectedImage(handles,SpikeMovieData(MovieApplied).Xposition,FinalNumRows,FinalNumCols);
    SpikeMovieData(MovieApplied).Yposition=FilterSelectedImage(handles,SpikeMovieData(MovieApplied).Yposition,FinalNumRows,FinalNumCols);
    SpikeMovieData(MovieApplied).Zposition=FilterSelectedImage(handles,SpikeMovieData(MovieApplied).Zposition,FinalNumRows,FinalNumCols);
    SpikeMovieData(MovieApplied).Exposure=FilterSelectedImage(handles,SpikeMovieData(MovieApplied).Exposure,FinalNumRows,FinalNumCols);
    
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

function DimensionReduction_Callback(hObject, eventdata, handles)
% hObject    handle to DimensionReduction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DimensionReduction as text
%        str2double(get(hObject,'String')) returns contents of DimensionReduction as a double
UpdateFinalResolution(handles);


% --- Executes during object creation, after setting all properties.
function DimensionReduction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DimensionReduction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function CurrentFrameValue_Callback(hObject, eventdata, handles)
% hObject    handle to CurrentFrameValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CurrentFrameValue as text
%        str2double(get(hObject,'String')) returns contents of CurrentFrameValue as a double
global SpikeMovieData;

MovieApplied=get(handles.MovieSelector,'Value');
MaxFrame=SpikeMovieData(MovieApplied).DataSize(3);
CurrentFrame=str2num(get(hObject,'String'));

if CurrentFrame>MaxFrame
    set(hObject,'String',num2str(MaxFrame));
elseif  CurrentFrame<1
    set(hObject,'String','1');
end

% --- Executes during object creation, after setting all properties.
function CurrentFrameValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentFrameValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% function to display the current settings on a text figure
function DisplayTestImage()
global SpikeMovieData;
global SpikeGui;

handles=guidata(gcbo);
MovieTest=get(handles.MovieSelector,'Value');

ResolutionRed=str2double(get(handles.DimensionReduction,'String'));
if isfield(handles,'hFigImageTest')
    if (isempty(handles.hFigImageTest) || ~ishandle(handles.hFigImageTest))
        handles.hFigImageTest=figure('Name','Resolution Test Image','NumberTitle','off');
    else
        figure(handles.hFigImageTest);
    end
else
    handles.hFigImageTest=figure('Name','Resolution Test Image','NumberTitle','off');
end

if (ishandle(SpikeGui.hDataDisplay))
    GlobalColorMap = get(SpikeGui.hDataDisplay,'Colormap');
    set(handles.hFigImageTest,'Colormap',GlobalColorMap)
end

[FinalNumRows FinalNumCols]=FinalSize(handles,SpikeMovieData(MovieTest).Movie(:,:,str2num(get(handles.CurrentFrameValue,'String'))));
NewPic=FilterSelectedImage(handles,SpikeMovieData(MovieTest).Movie(:,:,str2num(get(handles.CurrentFrameValue,'String'))),FinalNumRows,FinalNumCols);

imagesc(NewPic);
guidata(gcbo,handles);


% --- Executes on selection change in MovieSelector.
function MovieSelector_Callback(hObject, eventdata, handles)
% hObject    handle to MovieSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MovieSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MovieSelector
global SpikeMovieData;

LocalSize=SpikeMovieData(get(handles.MovieSelector,'Value')).DataSize;
handles.CropRect=[1 1 LocalSize(2) LocalSize(1)];
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function MovieSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MovieSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in selectInterpMethod.
function selectInterpMethod_Callback(hObject, eventdata, handles)
% hObject    handle to selectInterpMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns selectInterpMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectInterpMethod


% --- Executes during object creation, after setting all properties.
function selectInterpMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectInterpMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TestResample.
function TestResample_Callback(hObject, eventdata, handles)
% hObject    handle to TestResample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DisplayTestImage();


% --- Executes on button press in SelectSubFrame.
function SelectSubFrame_Callback(hObject, eventdata, handles)
% hObject    handle to SelectSubFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;
MovieTest=get(handles.MovieSelector,'Value');
CurrentFrame=str2num(get(handles.CurrentFrameValue,'String'));
hFigImageCrop=figure('Name','Select cropping region','NumberTitle','off');
imagesc(SpikeMovieData(MovieTest).Movie(:,:,CurrentFrame));
hROI=imrect(gca(hFigImageCrop));
RectFinal=getPosition(hROI);
handles.CropRect=RectFinal;
guidata(gcbo,handles);
delete(hFigImageCrop);
UpdateFinalResolution(handles);
DisplayTestImage();


% --- Executes on button press in ResetSubPortion.
function ResetSubPortion_Callback(hObject, eventdata, handles)
% hObject    handle to ResetSubPortion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;
MovieTest=get(handles.MovieSelector,'Value');
LocalSize=SpikeMovieData(MovieTest).DataSize;
handles.CropRect=[1 1 LocalSize(2) LocalSize(1)];
guidata(gcbo,handles);

UpdateFinalResolution(handles);
DisplayTestImage();


function ResolutionRatio_Callback(hObject, eventdata, handles)
% hObject    handle to ResolutionRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ResolutionRatio as text
%        str2double(get(hObject,'String')) returns contents of ResolutionRatio as a double
UpdateFinalResolution(handles);

% --- Executes during object creation, after setting all properties.
function ResolutionRatio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ResolutionRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
