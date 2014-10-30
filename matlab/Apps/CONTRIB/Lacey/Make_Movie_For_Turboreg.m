function varargout = Make_Movie_For_Turboreg(varargin)
% MAKE_MOVIE_FOR_TURBOREG This App takes in a trace and sets it to 1 when it is
% above a thresholdtop and 0 when it is less than or equal to the thresholdtop.
% ThresholdTop can be set numerically or in terms of the mean and standard
% deviation of the trace, which will be calculated individually for each
% trace processed.
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Make_Movie_For_Turboreg

% Last Modified by GUIDE v2.5 10-Dec-2012 20:43:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Make_Movie_For_Turboreg_OpeningFcn, ...
                   'gui_OutputFcn',  @Make_Movie_For_Turboreg_OutputFcn, ...
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
function Make_Movie_For_Turboreg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Make_Movie_For_Turboreg (see VARARGIN)

% Choose default command line output for Make_Movie_For_Turboreg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeMovieData

if ~isempty(SpikeMovieData)
    for i=1:length(SpikeMovieData)
        TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
    end
    set(handles.MovieSelector,'String',TextMovie);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.MovieSelector,'Value',Settings.TraceSelectorValue);
    set(handles.KeepMovie, 'Value', Settings.KeepMovieValue);
    set(handles.MeanFilterRadius, 'String', Settings.MeanFilterRadiusString);
    set(handles.GaussianSigma, 'String', Settings.GaussianSigmaString);
    set(handles.SaturateLow, 'String', Settings.FractionSaturateLowString);
    set(handles.SaturateHigh, 'String', Settings.FractionSaturateHighString);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorValue=get(handles.MovieSelector,'Value');
Settings.KeepMovieValue=get(handles.KeepMovie, 'Value');
Settings.MeanFilterRadiusString=get(handles.MeanFilterRadius, 'String');
Settings.GaussianSigmaString=get(handles.GaussianSigma,'String');
Settings.FractionSaturateLowString=get(handles.SaturateLow, 'String');
Settings.FractionSaturateHighString=get(handles.SaturateHigh, 'String');


% --- Outputs from this function are returned to the command line.
function varargout = Make_Movie_For_Turboreg_OutputFcn(hObject, eventdata, handles) 
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

global SpikeMovieData;
global origFrame newFrame thisFramePadded
global meanFilt
global gWin

try
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    % get parameters from interface
  
    keepMovie=get(handles.KeepMovie, 'Value');
    movieSel=get(handles.MovieSelector, 'Value');
    
    % process traces and save
    h=waitbar(0, 'Processing movie...');
    
    meanFiltRad=str2double(get(handles.MeanFilterRadius, 'String'));
    gaussSig=str2double(get(handles.GaussianSigma, 'String'));
    
    movSize=size(SpikeMovieData(movieSel).Movie);
    [xgrid, ygrid]=meshgrid(1:movSize(2), 1:movSize(1));
    meanFilt=((xgrid-movSize(2)/2).^2+(ygrid-movSize(1)/2).^2)<meanFiltRad^2;
    meanFilt=double(meanFilt);
    meanFilt=meanFilt/sum(meanFilt(:));
    gWin=fspecial('gaussian', movSize(1:2), gaussSig);
    
    if keepMovie
        saveInd=length(SpikeMovieData)+1;
    else
        saveInd=movieSel;
    end
    SpikeMovieData(saveInd)=SpikeMovieData(movieSel);
    
    origClass=class(SpikeMovieData(movieSel).Movie);
    waitbarInc=movSize(3)/20;
    for fr=1:movSize(3)
        origFrame=double(SpikeMovieData(movieSel).Movie(:,:,fr));
        thisFramePadded=zeros(movSize(1)+2*meanFiltRad, movSize(2)+2*meanFiltRad);
        thisFramePadded(meanFiltRad+(1:movSize(1)),1:meanFiltRad)=repmat(origFrame(:,1), 1, meanFiltRad);
        thisFramePadded(meanFiltRad+(1:movSize(1)),end-meanFiltRad+1:end)=repmat(origFrame(:,end), 1, meanFiltRad);
        thisFramePadded(1:meanFiltRad,meanFiltRad+(1:movSize(2)))=repmat(origFrame(1,:), meanFiltRad, 1);
        thisFramePadded(end-meanFiltRad+1:end,meanFiltRad+(1:movSize(2)))=repmat(origFrame(end,:), meanFiltRad, 1);
        thisFramePadded(1:meanFiltRad, 1:meanFiltRad)=origFrame(1,1);
        thisFramePadded(1:meanFiltRad, end-meanFiltRad+1:end)=origFrame(1,end);
        thisFramePadded(end-meanFiltRad+1:end, end-meanFiltRad+1:end)=origFrame(end,end);
        thisFramePadded(end-meanFiltRad+1:end, 1:meanFiltRad)=origFrame(end,1);
        thisFramePadded(meanFiltRad+(1:movSize(1)), meanFiltRad+(1:movSize(2)))=origFrame;
        toSubtract=conv2(thisFramePadded, meanFilt, 'same');
        toSubtract=toSubtract(meanFiltRad+(1:movSize(1)), meanFiltRad+(1:movSize(2)));
        newFrame=origFrame-toSubtract;
        
        newFrame=conv2(newFrame, gWin, 'same');
        
        %newFrame(newFrame<minVal)=minVal;
        %newFrame(newFrame>maxVal)=maxVal;

        SpikeMovieData(saveInd).Movie(:,:,fr)=cast(newFrame, origClass);
        
        if mod(fr, waitbarInc)==0
            waitbar(fr/movSize(3), h);
        end
        
    end
    
    
    maxValFrac=str2double(get(handles.SaturateHigh, 'String'));
    minValFrac=str2double(get(handles.SaturateLow, 'String'));
    
    testFrameInds=round(movSize(3)/2)+(-10:10);
    testFrameInds(testFrameInds<1)=[];
    testFrames=SpikeMovieData(saveInd).Movie(:,:,testFrameInds);
    prcVals=prctile(double(testFrames(:)), [100*minValFrac, 100*maxValFrac]);
    minVal=prcVals(1);
    maxVal=prcVals(2);
    
    SpikeMovieData(saveInd).Movie(SpikeMovieData(saveInd).Movie<minVal)=minVal;
    SpikeMovieData(saveInd).Movie(SpikeMovieData(saveInd).Movie>maxVal)=maxVal;
    
    SpikeMovieData(saveInd).Label.ListText=['processed ' SpikeMovieData(movieSel).Label.ListText];
    
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



% --- Executes on selection change in MovieSelector.
function MovieSelector_Callback(hObject, eventdata, handles)
% hObject    handle to MovieSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MovieSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MovieSelector


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


% --- Executes on button press in KeepMovie.
function KeepMovie_Callback(hObject, eventdata, handles)
% hObject    handle to KeepMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KeepMovie



function MeanFilterRadius_Callback(hObject, eventdata, handles)
% hObject    handle to ThresholdTop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ThresholdTop as text
%        str2double(get(hObject,'String')) returns contents of ThresholdTop as a double


% --- Executes during object creation, after setting all properties.
function MeanFilterRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThresholdTop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GaussianSigma_Callback(hObject, eventdata, handles)
% hObject    handle to GaussianSigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GaussianSigma as text
%        str2double(get(hObject,'String')) returns contents of GaussianSigma as a double


% --- Executes during object creation, after setting all properties.
function GaussianSigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GaussianSigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SaturateLow_Callback(hObject, eventdata, handles)
% hObject    handle to SaturateLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SaturateLow as text
%        str2double(get(hObject,'String')) returns contents of SaturateLow as a double


% --- Executes during object creation, after setting all properties.
function SaturateLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaturateLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SaturateHigh_Callback(hObject, eventdata, handles)
% hObject    handle to SaturateHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SaturateHigh as text
%        str2double(get(hObject,'String')) returns contents of SaturateHigh as a double


% --- Executes during object creation, after setting all properties.
function SaturateHigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaturateHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
