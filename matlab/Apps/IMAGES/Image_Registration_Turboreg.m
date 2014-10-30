function varargout = Image_Registration_Turboreg(varargin)
% IMAGE_REGISTRATION_TURBOREG apply motion correction algorithm imported
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

% Edit the above text to modify the response to help Image_Registration_Turboreg

% Last Modified by GUIDE v2.5 18-May-2012 05:58:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Image_Registration_Turboreg_OpeningFcn, ...
                   'gui_OutputFcn',  @Image_Registration_Turboreg_OutputFcn, ...
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


% --- Executes just before Image_Registration_Turboreg is made visible.
function Image_Registration_Turboreg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Image_Registration_Turboreg (see VARARGIN)
global SpikeImageData;

% Choose default command line output for Image_Registration_Turboreg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Image_Registration_Turboreg wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.ImageSelector,'Value',Settings.ImageSelectorValue);
    set(handles.ImageSelector,'String',Settings.ImageSelectorString);
    set(handles.RefFrameNumber,'String',Settings.RefFrameNumberString);
    set(handles.ReferenceSel,'Value',Settings.ReferenceSelValue);
    set(handles.FileRef,'String',Settings.FileRefString);
    set(handles.SelectSubRegion,'Value',Settings.SelectSubRegionValue);
    set(handles.RegistrationCorrectType,'Value',Settings.MotionCorrectTypeValue);
    handles.MaskMotCorr=Settings.MaskMotCorr;
    set(handles.minGain,'String',Settings.minGainString);
    set(handles.Levels,'String',Settings.LevelsString);
    set(handles.Epsilon,'String',Settings.EpsilonString);
    set(handles.lastLevel,'String',Settings.lastLevelString);
    set(handles.zapMean,'Value',Settings.zapMeanValue);
    set(handles.TargetImage,'Value',TargetImageValue);

    guidata(hObject, handles);
else
    if ~isempty(SpikeImageData)
        for i=1:length(SpikeImageData)
            TextImage{i}=[num2str(i),' - ',SpikeImageData(i).Label.ListText];
        end
        ImageSelector_Callback(hObject, eventdata, handles);    
        set(handles.ImageSelector,'String',TextImage);
            set(handles.TargetImage,'String',TextImage);
    end
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.ImageSelectorValue=get(handles.ImageSelector,'Value');
Settings.ImageSelectorString=get(handles.ImageSelector,'String');
Settings.RefFrameNumberString=get(handles.RefFrameNumber,'String');
Settings.SelectSubRegionValue=get(handles.SelectSubRegion,'Value');
Settings.FileRefString=get(handles.FileRef,'String');
Settings.ReferenceSelValue=get(handles.ReferenceSel,'Value');
Settings.MaskMotCorr=handles.MaskMotCorr;
Settings.MotionCorrectTypeValue=get(handles.RegistrationCorrectType,'Value');
Settings.minGainString=get(handles.minGain,'String');
Settings.LevelsString=get(handles.Levels,'String');
Settings.EpsilonString=get(handles.Epsilon,'String');
Settings.lastLevelString=get(handles.lastLevel,'String');
Settings.zapMeanValue=get(handles.zapMean,'Value');
Settings.TargetImageValue=get(handles.TargetImage,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Image_Registration_Turboreg_OutputFcn(hObject, eventdata, handles) 
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
    handles.hFigImageMotCorr=figure('Name','Image registration picture','NumberTitle','off');
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
global SpikeImageData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    ImageToRegister=get(handles.ImageSelector,'Value');
    MaxFrame=length(ImageToRegister);

    % waitbar is consuming too much ressources, so I divide its access
    dividerWaitBar=10^(floor(log10(MaxFrame))-1);
    
    h=waitbar(0,'Apply Turboreg image registration on pictures ...','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    
    RefImageNb=get(handles.TargetImage,'Value');
 
    RefPic=SpikeImageData(RefImageNb).Image;
    
    if isfield(handles,'MaskMotCorr')
        Mask=single(handles.MaskMotCorr);
    else
        Mask=ones(size(handles.PostProcessPic),'single');
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
        
    for i=1:MaxFrame
        ToAlign=SpikeImageData(ImageToRegister(i)).Image;
        
        [ImageOut,ResultsOut]=turboreg(single(RefPic),single(ToAlign),Mask,single(ones(size(Mask))),TurboRegOptions);
                
        SpikeImageData(ImageToRegister(i)).Image=cast(ImageOut,class(SpikeImageData(ImageToRegister(i)).Image));
        
        %     The following code does the interpolation in matlab from the transformation parameters in case it is
        %     needed.
        %     SkewingMat=ResultsOut.Skew;
        %     xform=SkewingMat;
        %     xform(3,1)=ResultsOut.Translation(1);
        %     xform(3,2)=ResultsOut.Translation(2);
        %
        %     tform=maketform(TransformationType,double(xform));
        %     InterpList=get(handles.InterpType,'String');
        %     InterpSelection=get(handles.InterpType,'Value');
        %
        %     SpikeImageData(ImageToRegister).Image(:,:,i)=imtransform(SpikeImageData(ImageToRegister).Image(:,:,i),tform,char(InterpList{InterpSelection}),...
        %         'UData',[1 SpikeImageData(ImageToRegister).DataSize(2)]-ResultsOut.Origin(2),'VData',[1 SpikeImageData(ImageToRegister).DataSize(1)]-ResultsOut.Origin(1),...
        %         'XData',[1 SpikeImageData(ImageToRegister).DataSize(2)]-ResultsOut.Origin(2)-1,'YData',[1 SpikeImageData(ImageToRegister).DataSize(1)]-ResultsOut.Origin(1)+1,...
        %         'FillValues',0);
        
        if (round(i/dividerWaitBar)==i/dividerWaitBar)
            waitbar(i/MaxFrame,h);
            % Check for Cancel button press
            if getappdata(h,'canceling')
                error('Aborted');
            end
        end
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
