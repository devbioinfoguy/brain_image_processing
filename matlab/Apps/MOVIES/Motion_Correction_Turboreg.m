function varargout = Motion_Correction_Turboreg(varargin)
% MOTION_CORRECTION_TURBOREG apply motion correction algorithm imported
% from TurboReg, initially developed by Philippe Thevenaz.
% This App is using a compiled version of the ANSI C code developed by
% Philippe Thevenaz.
%
% It uses a MEX file as a gateway between the C code and MATLAB code. 
% All C codes files are available in subfolder 'C'. The interface file is
% 'turboreg.c'. The main file from Turboreg is 'regFlt3d.c'. Original code
% has been modified to move new image calculation from C to Matlab to provide 
% additionnal flexibility.  
%      
% SETTINGS
% 
% 
% zapMean
%      If 'zapMean' is set to 'FALSE', the input data is left untouched. If zapMean is set
%      to 'TRUE', the test data is modified by removing its average value, and the reference
%      data is also modified by removing its average value prior to optimization.
%      
% minGain
%      An iterative algorithm needs a convergence criterion. If 'minGain' is set to '0.0',
%      new tries will be performed as long as numerical accuracy permits. If 'minGain'
%      is set between '0.0' and '1.0', the computations will stop earlier, possibly to the
%      price of some loss of accuracy. If 'minGain' is set to '1.0', the algorithm pretends
%      to have reached convergence as early as just after the very first successful attempt.
%     
% epsilon
%      The specification of machine-accuracy is normally machine-dependent. The proposed
%      value has shown good results on a variety of systems; it is the C-constant FLT_EPSILON.
%
% levels
%      This variable specifies how deep the multi-resolution pyramid is. By convention, the
%      finest level is numbered '1', which means that a pyramid of depth '1' is strictly
%      equivalent to no pyramid at all. For best registration results, the rule of thumb is
%      to select a number of levels such that the coarsest representation of the data is a
%      cube between 30 and 60 pixels on each side. Default value ensure that values
%      
% lastLevel
%      It is possible to short-cut the optimization before reaching the finest stages, which
%      are the most time-consuming. The variable 'lastLevel' specifies which is the finest
%      level on which optimization is to be performed. If 'lastLevel' is set to the same value
%      as 'levels', the registration will take place on the coarsest stage only. If
%      'lastLevel' is set to '1', the optimization will take advantage of the whole multi-
%      resolution pyramid.
%
% NOTES
%
% If you get error on the availibility of turboreg, please consider
% creating the mex file for your system using the following command in the C folder :
% mex turboreg.c regFlt3d.c svdcmp.c reg3.c reg2.c reg1.c reg0.c quant.c pyrGetSz.c pyrFilt.c getPut.c convolve.c BsplnWgt.c BsplnTrf.c phil.c
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Motion_Correction_Turboreg

% Last Modified by GUIDE v2.5 04-Oct-2012 10:16:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Motion_Correction_Turboreg_OpeningFcn, ...
                   'gui_OutputFcn',  @Motion_Correction_Turboreg_OutputFcn, ...
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


% --- Executes just before Motion_Correction_Turboreg is made visible.
function Motion_Correction_Turboreg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Motion_Correction_Turboreg (see VARARGIN)
global SpikeMovieData;

% Choose default command line output for Motion_Correction_Turboreg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Motion_Correction_Turboreg wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.MovieSelector,'Value',Settings.MovieSelectorValue);
    set(handles.RefFrameNumber,'String',Settings.RefFrameNumberString);
    set(handles.ReferenceSel,'Value',Settings.ReferenceSelValue);
    set(handles.FileRef,'String',Settings.FileRefString);
    set(handles.SelectSubRegion,'Value',Settings.SelectSubRegionValue);
    set(handles.ExportMotion,'Value',Settings.DisplMotionValue);
    set(handles.MotionCorrectType,'Value',Settings.MotionCorrectTypeValue);
    handles.MaskMotCorr=Settings.MaskMotCorr;
    set(handles.minGain,'String',Settings.minGainString);
    set(handles.Levels,'String',Settings.LevelsString);
    set(handles.Epsilon,'String',Settings.EpsilonString);
    set(handles.lastLevel,'String',Settings.lastLevelString);
    set(handles.zapMean,'Value',Settings.zapMeanValue);
    set(handles.BlackEdgekeep,'Value',Settings.BlackEdgekeep);

    guidata(hObject, handles);
end
if ~isempty(SpikeMovieData)
    for i=1:length(SpikeMovieData)
        TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
    end
    MovieSelector_Callback(hObject, eventdata, handles);    
    set(handles.MovieSelector,'String',TextMovie);
end



% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.MovieSelectorString=get(handles.MovieSelector,'String');
Settings.RefFrameNumberString=get(handles.RefFrameNumber,'String');
Settings.SelectSubRegionValue=get(handles.SelectSubRegion,'Value');
Settings.DisplMotionValue=get(handles.ExportMotion,'Value');
Settings.FileRefString=get(handles.FileRef,'String');
Settings.ReferenceSelValue=get(handles.ReferenceSel,'Value');
Settings.MaskMotCorr=handles.MaskMotCorr;
Settings.MotionCorrectTypeValue=get(handles.MotionCorrectType,'Value');
Settings.minGainString=get(handles.minGain,'String');
Settings.LevelsString=get(handles.Levels,'String');
Settings.EpsilonString=get(handles.Epsilon,'String');
Settings.lastLevelString=get(handles.lastLevel,'String');
Settings.zapMeanValue=get(handles.zapMean,'Value');
Settings.BlackEdgekeep=get(handles.BlackEdgekeep,'Value');



% --- Outputs from this function are returned to the command line.
function varargout = Motion_Correction_Turboreg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%  Function to display pre-processed Image
function DisplayImage(handles)
global SpikeGui;

handles=guidata(handles.output);
if isfield(handles,'hFigImageMotCorr')
    if (isempty(handles.hFigImageMotCorr) || ~ishandle(handles.hFigImageMotCorr))
        handles.hFigImageMotCorr=figure('Name','Motion correction picture','NumberTitle','off');
    else
        figure(handles.hFigImageMotCorr);
    end
else
    handles.hFigImageMotCorr=figure('Name','Motion correction picture','NumberTitle','off');
end

if (ishandle(SpikeGui.hDataDisplay))
    GlobalColorMap = get(SpikeGui.hDataDisplay,'Colormap');
    set(handles.hFigImageMotCorr,'Colormap',GlobalColorMap)
end

if (get(handles.SelectSubRegion,'Value')==1)
    if isfield(handles,'MaskMotCorr')
        Mask=single(handles.MaskMotCorr);
    else
        Mask=ones(size(handles.PostProcessPic),'single');
    end
else
    Mask=ones(size(handles.PostProcessPic));
end

imagesc(Mask.*single(handles.PostProcessPic));
guidata(handles.output,handles);


% This function apply the set of all selected filters to the current
% picture
function ProcessImage(handles)
global SpikeMovieData;

handles=guidata(handles.output);
CurrentMovie=get(handles.MovieSelector,'Value');

% depending on settings, reference frame is taken in current movie or from
% file
switch get(handles.ReferenceSel,'Value')
    case 1
        handles.PostProcessPic=squeeze(SpikeMovieData(CurrentMovie).Movie(:,:,str2num(get(handles.RefFrameNumber,'String'))));
    case 2
        handles.PostProcessPic=imread(get(handles.FileRef,'String'));
end
guidata(handles.output,handles);


% --- Executes on selection change in MovieSelector.
function MovieSelector_Callback(hObject, eventdata, handles)
% hObject    handle to MovieSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MovieSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MovieSelector
global SpikeMovieData;
ProcessImage(handles);
DisplayImage(handles);

CurrentMovie=get(handles.MovieSelector,'Value');

% We estimate the pyramid size based on the picture size
MIN_SIZE=12;

pyramidDepth = 1;

% This code is taken from ImageJ TurboReg plugin
sw=SpikeMovieData(CurrentMovie).DataSize(1);
sh=SpikeMovieData(CurrentMovie).DataSize(2);
while (((2 * MIN_SIZE) <= sw) && ((2 * MIN_SIZE) <= sh))
    sw=sw/2;
    sh=sh/2;
    pyramidDepth=pyramidDepth+1;
end
set(handles.Levels,'String',num2str(pyramidDepth));


% --- Executes during object creation, after setting all properties.
function MovieSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MovieSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ValidateValues.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'hFigImageMotCorr')
    if (ishandle(handles.hFigImageMotCorr))
        delete(handles.hFigImageMotCorr);
    end
end
uiresume;


function RefFrameSelect_Callback(hObject, eventdata, handles)
% hObject    handle to RefFrameSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RefFrameSelect as text
%        str2double(get(hObject,'String')) returns contents of RefFrameSelect as a double


% --- Executes during object creation, after setting all properties.
function RefFrameSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RefFrameSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SelectSubRegion.
function SelectSubRegion_Callback(hObject, eventdata, handles)
% hObject    handle to SelectSubRegion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SelectSubRegion
if (get(handles.SelectSubRegion,'Value')==1)
    ProcessImage(handles);
    DisplayImage(handles);
    handles=guidata(hObject);

    figure(handles.hFigImageMotCorr);
    hROI = imrect;
    handles.MaskMotCorr = createMask(hROI);
    handles.SubRegMotCorr=getPosition(hROI);   
    guidata(hObject,handles);

    DisplayImage(handles);
else
    ProcessImage(handles);
    DisplayImage(handles);
end


function RefFrameNumber_Callback(hObject, eventdata, handles)
% hObject    handle to RefFrameNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RefFrameNumber as text
%        str2double(get(hObject,'String')) returns contents of RefFrameNumber as a double
ProcessImage(handles);
DisplayImage(handles);


% --- Executes during object creation, after setting all properties.
function RefFrameNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RefFrameNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;
global SpikeTraceData;
global SpikeImageData

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    CurrentMovie=get(handles.MovieSelector,'Value');
    
    % waitbar is consuming too much ressources, so I divide its access
    dividerWaitBar=10^(floor(log10(SpikeMovieData(CurrentMovie).DataSize(3)))-1);
    
    h=waitbar(0,'Apply Turboreg motion correction on pictures ...','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    
    MaxFrame=SpikeMovieData(CurrentMovie).DataSize(3);
    MatrixMotCorrDispl=zeros(3,MaxFrame);
    
    switch get(handles.ReferenceSel,'Value')
        case 1
            RefPic=SpikeMovieData(CurrentMovie).Movie(:,:,str2num(get(handles.RefFrameNumber,'String')));
        case 2
            RefPic=imread(get(handles.FileRef,'String'));
        case 3
            RefPic=SpikeImageData(str2double(get(handles.ImageNumberRef, 'String'))).Image;
    end
    
    
    if isfield(handles,'MaskMotCorr')
        Mask=single(handles.MaskMotCorr);
    else
        Mask=ones(size(handles.PostProcessPic),'single');
    end
    
    TurboRegOptions.RegisType=get(handles.MotionCorrectType,'Value');
    TurboRegOptions.SmoothX=get(handles.SmoothX,'Value');
    TurboRegOptions.SmoothY=get(handles.SmoothY,'Value');
    TurboRegOptions.minGain=str2double(get(handles.minGain,'String'));
    TurboRegOptions.Levels=str2double(get(handles.Levels,'String'));
    TurboRegOptions.Lastlevels=str2double(get(handles.lastLevel,'String'));
    TurboRegOptions.Epsilon=str2double(get(handles.Epsilon,'String'));
    TurboRegOptions.zapMean=get(handles.zapMean,'Value');
    TurboRegOptions.Interp=get(handles.InterpType,'Value');
    
    OriginalClass=class(SpikeMovieData(CurrentMovie).Movie);
    
    if (TurboRegOptions.RegisType==1 || TurboRegOptions.RegisType==2)
        TransformationType='affine';
    else
        TransformationType='projective';
    end
    RefPic=single(RefPic);
    imgRegMask=single(double(Mask));

    AveragePictureEdge=zeros(size(imgRegMask));
    
    % we add an offset to be able to give NaN to black borders
    for i=1:MaxFrame
        ToAlign=single(SpikeMovieData(CurrentMovie).Movie(:,:,i));
        
        [ImageOut,ResultsOut]=turboreg(RefPic,ToAlign,Mask,imgRegMask,TurboRegOptions);
        
        MatrixMotCorrDispl(:,i)=[ResultsOut.Translation(1) ResultsOut.Translation(2) ResultsOut.Rotation];
                
        SkewingMat=ResultsOut.Skew;
        translateMat=[0 0 0;0 0 0;ResultsOut.Translation(2) ResultsOut.Translation(1) 0];
        xform=translateMat+SkewingMat;
        
        tform=maketform(TransformationType,double(xform));
        InterpList=get(handles.InterpType,'String');
        InterpSelection=get(handles.InterpType,'Value');
        
        %rotationAngle=180/pi*ResultsOut.Rotation;
        SpikeMovieData(CurrentMovie).Movie(:,:,i)=imtransform(SpikeMovieData(CurrentMovie).Movie(:,:,i),tform,char(InterpList{InterpSelection}),...
            'UData',[1 SpikeMovieData(CurrentMovie).DataSize(2)]-ResultsOut.Origin(2)-1,'VData',[1 SpikeMovieData(CurrentMovie).DataSize(1)]-ResultsOut.Origin(1)-1,...
            'XData',[1 SpikeMovieData(CurrentMovie).DataSize(2)]-ResultsOut.Origin(2)-1,'YData',[1 SpikeMovieData(CurrentMovie).DataSize(1)]-ResultsOut.Origin(1)-1,...
            'FillValues',0);
        
        % We project along z and make a nice binary image with 0 on the sides
        AveragePictureEdge=AveragePictureEdge | SpikeMovieData(CurrentMovie).Movie(:,:,i)==0;
        
        if (round(i/dividerWaitBar)==i/dividerWaitBar)
            waitbar(i/SpikeMovieData(CurrentMovie).DataSize(3),h);
            % Check for Cancel button press
            if getappdata(h,'canceling')
                error('Aborted');
            end
        end
    end
    
    if ~get(handles.BlackEdgekeep,'Value')
        % We project along z and make a nice binary image with 0 on the sides
        AveragePictureEdge=~AveragePictureEdge;
        
        StatsRegion = regionprops(AveragePictureEdge,'Extrema');
        TopIndice=[1 2 3 8];
        LeftIndice=[1 6 7 8];
        RightIndice=[2 3 4 5];
        BottomIndice=[4 5 6 7];
        
        xmin=ceil(max(StatsRegion.Extrema(LeftIndice,1)));
        ymin=ceil(max(StatsRegion.Extrema(TopIndice,2)));
        xmax=floor(min(StatsRegion.Extrema(RightIndice,1)));
        ymax=floor(min(StatsRegion.Extrema(BottomIndice,2)));
        
        RectCrop=[xmin ymin xmax-xmin ymax-ymin];
        dividerWaitbar=10^(floor(log10(SpikeMovieData(CurrentMovie).DataSize(3)))-1);
        
        % To get the final size, we just apply on the first figure
        TestMovie=imcrop(SpikeMovieData(CurrentMovie).Movie(:,:,1),RectCrop);
        FinalNumRows=size(TestMovie,1);
        FinalNumCols=size(TestMovie,2);
        
        % We prallocate the big matrixes.
        NewMovie=zeros([FinalNumRows FinalNumCols SpikeMovieData(CurrentMovie).DataSize(3)],class(SpikeMovieData(CurrentMovie).Movie));
        NewTime=zeros([FinalNumRows FinalNumCols SpikeMovieData(CurrentMovie).DataSize(3)],class(SpikeMovieData(CurrentMovie).TimePixel));
        
        for i=1:SpikeMovieData(CurrentMovie).DataSize(3)
            NewMovie(:,:,i)=imcrop(SpikeMovieData(CurrentMovie).Movie(:,:,i),RectCrop);
            NewTime(:,:,i)=imcrop(SpikeMovieData(CurrentMovie).TimePixel(:,:,i),RectCrop);
            
            if (round(i/dividerWaitbar)==i/dividerWaitbar)
                waitbar(i/SpikeMovieData(CurrentMovie).DataSize(3),h);
            end
        end
        
        SpikeMovieData(CurrentMovie).Movie=NewMovie;
        SpikeMovieData(CurrentMovie).TimePixel=NewTime;
        SpikeMovieData(CurrentMovie).DataSize=size(SpikeMovieData(CurrentMovie).Movie);
        
        % We also adjust the single time matrix
        SpikeMovieData(CurrentMovie).Xposition=imcrop(SpikeMovieData(CurrentMovie).Xposition,RectCrop);
        SpikeMovieData(CurrentMovie).Yposition=imcrop(SpikeMovieData(CurrentMovie).Yposition,RectCrop);
        SpikeMovieData(CurrentMovie).Zposition=imcrop(SpikeMovieData(CurrentMovie).Zposition,RectCrop);
        SpikeMovieData(CurrentMovie).Exposure=imcrop(SpikeMovieData(CurrentMovie).Exposure,RectCrop);
    end
    delete(h);

    if (get(handles.ExportMotion,'Value')==1)
        CurrentNumberTrace=length(SpikeTraceData);
        SpikeTraceData(CurrentNumberTrace+1).Path=SpikeMovieData(CurrentMovie).Path;
        SpikeTraceData(CurrentNumberTrace+1).Filename=SpikeMovieData(CurrentMovie).Filename;
        SpikeTraceData(CurrentNumberTrace+1).XVector=SpikeMovieData(CurrentMovie).TimeFrame;
        SpikeTraceData(CurrentNumberTrace+1).Trace=MatrixMotCorrDispl(1,:);
        SpikeTraceData(CurrentNumberTrace+1).DataSize=size(SpikeTraceData(CurrentNumberTrace+1).Trace);
        SpikeTraceData(CurrentNumberTrace+1).Label.YLabel='Translation (\mum)';
        SpikeTraceData(CurrentNumberTrace+1).Label.ListText='Motion - X Translation';
        SpikeTraceData(CurrentNumberTrace+1).Label.XLabel='Time (s)';
        
        SpikeTraceData(CurrentNumberTrace+2).Path=SpikeMovieData(CurrentMovie).Path;
        SpikeTraceData(CurrentNumberTrace+2).Filename=SpikeMovieData(CurrentMovie).Filename;
        SpikeTraceData(CurrentNumberTrace+2).XVector=SpikeMovieData(CurrentMovie).TimeFrame;
        SpikeTraceData(CurrentNumberTrace+2).Trace=MatrixMotCorrDispl(2,:);
        SpikeTraceData(CurrentNumberTrace+2).DataSize=size(SpikeTraceData(CurrentNumberTrace+1).Trace);
        SpikeTraceData(CurrentNumberTrace+2).Label.YLabel='Translation (\mum)';
        SpikeTraceData(CurrentNumberTrace+2).Label.ListText='Motion - Y Translation';
        SpikeTraceData(CurrentNumberTrace+2).Label.XLabel='Time (s)';
        
        % We only save rotation if it is relevant
        if (TurboRegOptions.RegisType==2 || TurboRegOptions.RegisType==3)
            
            SpikeTraceData(CurrentNumberTrace+3).Path=SpikeMovieData(CurrentMovie).Path;
            SpikeTraceData(CurrentNumberTrace+3).Filename=SpikeMovieData(CurrentMovie).Filename;
            SpikeTraceData(CurrentNumberTrace+3).XVector=SpikeMovieData(CurrentMovie).TimeFrame;
            SpikeTraceData(CurrentNumberTrace+3).Trace=180/pi*MatrixMotCorrDispl(3,:);
            SpikeTraceData(CurrentNumberTrace+3).DataSize=size(SpikeTraceData(CurrentNumberTrace+1).Trace);
            SpikeTraceData(CurrentNumberTrace+3).Label.YLabel='Rotation (deg)';
            SpikeTraceData(CurrentNumberTrace+3).Label.ListText='Motion - Rotation';
            SpikeTraceData(CurrentNumberTrace+3).Label.XLabel='Time (s)';
        end
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


% --- Executes on button press in ExportMotion.
function ExportMotion_Callback(hObject, eventdata, handles)
% hObject    handle to ExportMotion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ExportMotion


% --- Executes on selection change in MotionCorrectType.
function MotionCorrectType_Callback(hObject, eventdata, handles)
% hObject    handle to MotionCorrectType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MotionCorrectType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MotionCorrectType


% --- Executes during object creation, after setting all properties.
function MotionCorrectType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MotionCorrectType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SmoothX_Callback(hObject, eventdata, handles)
% hObject    handle to SmoothX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SmoothX as text
%        str2double(get(hObject,'String')) returns contents of SmoothX as a double


% --- Executes during object creation, after setting all properties.
function SmoothX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SmoothX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SmoothY_Callback(hObject, eventdata, handles)
% hObject    handle to SmoothY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SmoothY as text
%        str2double(get(hObject,'String')) returns contents of SmoothY as a double


% --- Executes during object creation, after setting all properties.
function SmoothY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SmoothY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in InterpType.
function InterpType_Callback(hObject, eventdata, handles)
% hObject    handle to InterpType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns InterpType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from InterpType


% --- Executes during object creation, after setting all properties.
function InterpType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InterpType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ReferenceSel.
function ReferenceSel_Callback(hObject, eventdata, handles)
% hObject    handle to ReferenceSel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ReferenceSel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ReferenceSel
if (get(hObject,'Value')==2)
    SelectFileRef_Callback(hObject, eventdata, handles);
    if strcmp(get(handles.FileRef,'String'),'...')
        set(hObject,'Value',1)
    end
end


% --- Executes during object creation, after setting all properties.
function ReferenceSel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ReferenceSel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SelectFileRef.
function SelectFileRef_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFileRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;

Oldpath=cd;

if isfield(SpikeMovieData,'Path')
    if (~isempty(SpikeMovieData))
        cd(SpikeMovieData(1).Path);
    end
end
% Open file path
[filename, pathname] = uigetfile({'*.tif;*.png;*.jpg;*.gif','All Image Files'},'Select Image File');

if isfield(SpikeMovieData,'Path')
    if (~isempty(SpikeMovieData))
        cd(Oldpath);
    end
end

% Open file if exist
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
    return  
    % Otherwise construct the full filename and save file location
else 
    set(handles.FileRef,'String',fullfile(pathname,filename));
end


% --- Executes on button press in OpenHelp.
function OpenHelp_Callback(hObject, eventdata, handles)
% hObject    handle to OpenHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CurrentMfilePath = mfilename('fullpath');
[PathToM, name, ext] = fileparts(CurrentMfilePath);
eval(['doc ',name]);


function Epsilon_Callback(hObject, eventdata, handles)
% hObject    handle to Epsilon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Epsilon as text
%        str2double(get(hObject,'String')) returns contents of Epsilon as a double


% --- Executes during object creation, after setting all properties.
function Epsilon_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Epsilon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lastLevel_Callback(hObject, eventdata, handles)
% hObject    handle to lastLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lastLevel as text
%        str2double(get(hObject,'String')) returns contents of lastLevel as a double


% --- Executes during object creation, after setting all properties.
function lastLevel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lastLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Levels_Callback(hObject, eventdata, handles)
% hObject    handle to Levels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Levels as text
%        str2double(get(hObject,'String')) returns contents of Levels as a double


% --- Executes during object creation, after setting all properties.
function Levels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Levels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in zapMean.
function zapMean_Callback(hObject, eventdata, handles)
% hObject    handle to zapMean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of zapMean


% --- Executes on button press in BlackEdgekeep.
function BlackEdgekeep_Callback(hObject, eventdata, handles)
% hObject    handle to BlackEdgekeep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BlackEdgekeep



function ImageNumberRef_Callback(hObject, eventdata, handles)
% hObject    handle to ImageNumberRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ImageNumberRef as text
%        str2double(get(hObject,'String')) returns contents of ImageNumberRef as a double


% --- Executes during object creation, after setting all properties.
function ImageNumberRef_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageNumberRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
