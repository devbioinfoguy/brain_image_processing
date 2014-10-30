function varargout = Image_Reg_Turboreg_Apply(varargin)
% IMAGE_REG_TURBOREG_APPLY apply motion correction algorithm imported
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

% Edit the above text to modify the response to help Image_Reg_Turboreg_Apply

% Last Modified by GUIDE v2.5 10-Dec-2012 19:38:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Image_Reg_Turboreg_Apply_OpeningFcn, ...
                   'gui_OutputFcn',  @Image_Reg_Turboreg_Apply_OutputFcn, ...
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


% --- Executes just before Image_Reg_Turboreg_Apply is made visible.
function Image_Reg_Turboreg_Apply_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Image_Reg_Turboreg_Apply (see VARARGIN)
global SpikeImageData
global SpikeMovieData

% Choose default command line output for Image_Reg_Turboreg_Apply
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Image_Reg_Turboreg_Apply wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.ImageSelector,'Value',Settings.ImageSelectorValue);
    set(handles.ApplyImageSelector,'Value',Settings.ApplyImageSelectorValue);
    set(handles.SelectSubRegion,'Value',Settings.SelectSubRegionValue);
    set(handles.RegistrationCorrectType,'Value',Settings.MotionCorrectTypeValue);
    if isfield(Settings, 'MaskMotCorr')
        handles.MaskMotCorr=Settings.MaskMotCorr;
    end
    set(handles.minGain,'String',Settings.minGainString);
    set(handles.Levels,'String',Settings.LevelsString);
    set(handles.Epsilon,'String',Settings.EpsilonString);
    set(handles.lastLevel,'String',Settings.lastLevelString);
    set(handles.zapMean,'Value',Settings.zapMeanValue);
    set(handles.ApplyMovieSelector, 'Value', Settings.ApplyMovieSelectorValue);
    set(handles.TimesToRepeat, 'String', Settings.TimesToRepeatString);

    guidata(hObject, handles);
end

if ~isempty(SpikeImageData)
    for i=1:length(SpikeImageData)
        TextImage{i}=[num2str(i),' - ',SpikeImageData(i).Label.ListText];
    end
    ImageSelector_Callback(hObject, eventdata, handles);    
    set(handles.ImageSelector,'String',TextImage);
    set(handles.ApplyImageSelector,'String',TextImage);
    set(handles.TargetImage,'String',TextImage);
end
TextApplyMovie{1}='none';
if ~isempty(SpikeMovieData)
    for i=1:length(SpikeMovieData)
        TextApplyMovie{i+1}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
    end
end
set(handles.ApplyMovieSelector,'String',TextApplyMovie);



% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.ImageSelectorValue=get(handles.ImageSelector,'Value');
Settings.ImageSelectorString=get(handles.ImageSelector,'String');
Settings.ApplyImageSelectorValue=get(handles.ApplyImageSelector,'Value');
Settings.SelectSubRegionValue=get(handles.SelectSubRegion,'Value');
if isfield(handles, 'MaskMotCorr')
    Settings.MaskMotCorr=handles.MaskMotCorr;
end
Settings.MotionCorrectTypeValue=get(handles.RegistrationCorrectType,'Value');
Settings.minGainString=get(handles.minGain,'String');
Settings.LevelsString=get(handles.Levels,'String');
Settings.EpsilonString=get(handles.Epsilon,'String');
Settings.lastLevelString=get(handles.lastLevel,'String');
Settings.zapMeanValue=get(handles.zapMean,'Value');
Settings.TargetImageValue=get(handles.TargetImage,'Value');
Settings.ApplyMovieSelectorValue=get(handles.ApplyMovieSelector, 'Value');
Settings.TimesToRepeatString=get(handles.TimesToRepeat, 'String');


% --- Outputs from this function are returned to the command line.
function varargout = Image_Reg_Turboreg_Apply_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%  Function to display pre-processed Image
function DisplayImage(handles)
global SpikeGui
global SpikeImageData

handles=guidata(handles.output);
if isfield(handles,'hFigImageMotCorr')
    if (isempty(handles.hFigImageMotCorr) || ~ishandle(handles.hFigImageMotCorr))
        handles.hFigImageMotCorr=figure('Name','Motion correction picture','NumberTitle','off');
    else
        figure(handles.hFigImageMotCorr);
    end
else
    handles.hFigImageMotCorr=figure('Name','Image registration picture','NumberTitle','off');
end

if (ishandle(SpikeGui.hDataDisplay))
    GlobalColorMap = get(SpikeGui.hDataDisplay,'Colormap');
    set(handles.hFigImageMotCorr,'Colormap',GlobalColorMap)
end

TargetImage=get(handles.TargetImage,'Value');

handles.PostProcessPic=SpikeImageData(TargetImage).Image;
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
global SpikeImageData;

handles=guidata(handles.output);
TargetImage=get(handles.TargetImage,'Value');

handles.PostProcessPic=SpikeImageData(TargetImage).Image;

guidata(handles.output,handles);


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


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeImageData
global ResultsOut
global SpikeMovieData

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    ImageToRegister=get(handles.ImageSelector,'Value');
    if length(ImageToRegister)>1
        error('For this App please only select 1 Image to register. You can select many images to apply the transformation to.')
    end
    ImagesToApply=get(handles.ApplyImageSelector, 'Value');
    NumApplyImages=length(ImagesToApply);
    
    a=1
  
    applyMovieSel=get(handles.ApplyMovieSelector, 'Value')-1;
    if applyMovieSel~=0
        NumApplyFrames=size(SpikeMovieData(applyMovieSel).Movie,3);
    else
        NumApplyFrames=0;
    end
    
    dividerWaitBar=10^(floor(log10(NumApplyImages+NumApplyFrames))-1);
    
    h=waitbar(0,'Apply Turboreg image registration on pictures ...','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    
    RefImageNb=get(handles.TargetImage,'Value');
 
    RefPic=SpikeImageData(RefImageNb).Image;
    
    b=1
    
    if isfield(handles,'MaskMotCorr')
        Mask=single(handles.MaskMotCorr);
    else
        Mask=ones(size(RefPic),'single');
    end
    
    TurboRegOptions.RegisType=get(handles.RegistrationCorrectType,'Value');
    TurboRegOptions.SmoothX=get(handles.SmoothX,'Value');
    TurboRegOptions.SmoothY=get(handles.SmoothY,'Value');
    TurboRegOptions.minGain=str2double(get(handles.minGain,'String'));
    TurboRegOptions.Levels=str2double(get(handles.Levels,'String'));
    TurboRegOptions.Lastlevels=str2double(get(handles.lastLevel,'String'));
    TurboRegOptions.Epsilon=str2double(get(handles.Epsilon,'String'));
    TurboRegOptions.zapMean=get(handles.zapMean,'Value');
    TurboRegOptions.Interp=get(handles.InterpType,'Value');
    
    c=1
    
    if (TurboRegOptions.RegisType==1 || TurboRegOptions.RegisType==2)
        TransformationType='affine';
    else
        TransformationType='projective';
    end
 
    d=1
    
    timesToRepeat=str2double(get(handles.TimesToRepeat, 'String'));
    for i=1:timesToRepeat
        
        if i>1
            h=waitbar(0,['Apply Turboreg image registration on pictures, iteration ', num2str(i)],'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
        end
            
        ToAlign=SpikeImageData(ImageToRegister).Image;
        
        imgSize=size(ToAlign);
        
        if any(SpikeImageData(ImageToRegister).DataSize~=SpikeImageData(RefImageNb).DataSize)
            disp('Warning: Target image is not the same size as image to register. This may foil turboreg. Use zero padding to correct.')
        end
        
        e=1

        [ImageOut,ResultsOut]=turboreg(single(RefPic),single(ToAlign),Mask,single(ones(size(Mask))),TurboRegOptions);

        f=1
        
        SpikeImageData(ImageToRegister).Image=cast(ImageOut,class(SpikeImageData(ImageToRegister).Image));
        
        g=1

%         SkewingMat=ResultsOut.Skew;
%         translMat=[0 0 0;0 0 0;ResultsOut.Translation(2) ResultsOut.Translation(1) 0];
%         xform=translMat+SkewingMat;
% 
%         tform=maketform(TransformationType,double(xform));
%         InterpList=get(handles.InterpType,'String');
%         InterpSelection=get(handles.InterpType,'Value');

        for j=1:NumApplyImages
            imageToApply=ImagesToApply(j);
            SpikeImageData(imageToApply).DataSize=size(SpikeImageData(imageToApply).Image);
            
            if any(SpikeImageData(imageToApply).DataSize~=imgSize)
                disp('Warning: Some of the images to apply are not the same size as image to register')
            end

%             SpikeImageData(ImageToApply).Image=imtransform(SpikeImageData(ImageToApply).Image,tform,char(InterpList{InterpSelection}),...
%                 'UData',[1 SpikeImageData(ImageToApply).DataSize(2)]-ResultsOut.Origin(2)-1,'VData',[1 SpikeImageData(ImageToApply).DataSize(1)]-ResultsOut.Origin(1)-1,...
%                 'XData',[1 SpikeImageData(ImageToApply).DataSize(2)]-ResultsOut.Origin(2)-1,'YData',[1 SpikeImageData(ImageToApply).DataSize(1)]-ResultsOut.Origin(1)-1,...
%                 'FillValues',0);
            
            thisImageClass=class(SpikeImageData(imageToApply).Image);
            
            SpikeImageData(imageToApply).Image=cast(transfturboreg(single(SpikeImageData(imageToApply).Image),ones(size(SpikeImageData(imageToApply).Image),'single'),ResultsOut), thisImageClass);
            
            if (round(j/dividerWaitBar)==j/dividerWaitBar)
                waitbar(j/(NumApplyImages+NumApplyFrames),h);
                % Check for Cancel button press
                if getappdata(h,'canceling')
                    error('Aborted');
                end
            end
        end


        if applyMovieSel~=0
            
            movSize=size(SpikeMovieData(applyMovieSel).Movie(:,:,j));
            if any(movSize(1:2)~=imgSize)
                disp('Warning: Some of the images to apply are not the same size as image to register')
            end
            
            thisMovieClass=class(SpikeMovieData(applyMovieSel).Movie);

            for j=1:NumApplyFrames

%                 SpikeMovieData(applyMovieSel).Movie(:,:,j)=imtransform(SpikeMovieData(applyMovieSel).Movie(:,:,j),tform,char(InterpList{InterpSelection}),...
%                 'UData',[1 SpikeMovieData(applyMovieSel).DataSize(2)]-ResultsOut.Origin(2)-1,'VData',[1 SpikeMovieData(applyMovieSel).DataSize(1)]-ResultsOut.Origin(1)-1,...
%                 'XData',[1 SpikeMovieData(applyMovieSel).DataSize(2)]-ResultsOut.Origin(2)-1,'YData',[1 SpikeMovieData(applyMovieSel).DataSize(1)]-ResultsOut.Origin(1)-1,...
%                 'FillValues',0);
            
                SpikeMovieData(applyMovieSel).Movie(:,:,j)=cast(transfturboreg(single(SpikeMovieData(applyMovieSel).Movie(:,:,j)),...
                    ones(size(SpikeMovieData(applyMovieSel).Movie(:,:,j)),'single'),ResultsOut), thisMovieClass);

                if (round(j/dividerWaitBar)==j/dividerWaitBar)
                    waitbar((j+NumApplyImages)/(NumApplyImages+NumApplyFrames),h);
                    if getappdata(h,'canceling')
                        error('Aborted');
                    end
                end
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


% --- Executes on selection change in RegistrationCorrectType.
function RegistrationCorrectType_Callback(hObject, eventdata, handles)
% hObject    handle to RegistrationCorrectType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RegistrationCorrectType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RegistrationCorrectType


% --- Executes during object creation, after setting all properties.
function RegistrationCorrectType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RegistrationCorrectType (see GCBO)
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


% --- Executes on selection change in TargetImage.
function TargetImage_Callback(hObject, eventdata, handles)
% hObject    handle to TargetImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TargetImage contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TargetImage
global SpikeImageData;
ProcessImage(handles);
DisplayImage(handles);

TargetImage=get(handles.TargetImage,'Value');

% We estimate the pyramid size based on the picture size
MIN_SIZE=12;

pyramidDepth = 1;

% This code is taken from ImageJ TurboReg plugin
sw=SpikeImageData(TargetImage).DataSize(1);
sh=SpikeImageData(TargetImage).DataSize(2);
while (((2 * MIN_SIZE) <= sw) && ((2 * MIN_SIZE) <= sh))
    sw=sw/2;
    sh=sh/2;
    pyramidDepth=pyramidDepth+1;
end
set(handles.Levels,'String',num2str(pyramidDepth));


% --- Executes during object creation, after setting all properties.
function TargetImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TargetImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ApplyImageSelector.
function ApplyImageSelector_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyImageSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ApplyImageSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ApplyImageSelector


% --- Executes during object creation, after setting all properties.
function ApplyImageSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ApplyImageSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ApplyMovieSelector.
function ApplyMovieSelector_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyMovieSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ApplyMovieSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ApplyMovieSelector


% --- Executes during object creation, after setting all properties.
function ApplyMovieSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ApplyMovieSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimesToRepeat_Callback(hObject, eventdata, handles)
% hObject    handle to TimesToRepeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimesToRepeat as text
%        str2double(get(hObject,'String')) returns contents of TimesToRepeat as a double


% --- Executes during object creation, after setting all properties.
function TimesToRepeat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimesToRepeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
