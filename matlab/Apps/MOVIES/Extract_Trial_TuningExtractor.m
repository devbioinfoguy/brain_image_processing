function varargout = Extract_Trial_TuningExtractor(varargin)
% EXTRACT_TRIAL_TUNINGEXTRACTOR MATLAB code for Extract_Trial_TuningExtractor.fig
%      EXTRACT_TRIAL_TUNINGEXTRACTOR, by itself, creates a new EXTRACT_TRIAL_TUNINGEXTRACTOR or raises the existing
%      singleton*.
%
%      H = EXTRACT_TRIAL_TUNINGEXTRACTOR returns the handle to a new EXTRACT_TRIAL_TUNINGEXTRACTOR or the handle to
%      the existing singleton*.
%
%      EXTRACT_TRIAL_TUNINGEXTRACTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXTRACT_TRIAL_TUNINGEXTRACTOR.M with the given input arguments.
%
%      EXTRACT_TRIAL_TUNINGEXTRACTOR('Property','Value',...) creates a new EXTRACT_TRIAL_TUNINGEXTRACTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Extract_Trial_TuningExtractor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Extract_Trial_TuningExtractor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Extract_Trial_TuningExtractor

% Last Modified by GUIDE v2.5 07-Feb-2012 11:49:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Extract_Trial_TuningExtractor_OpeningFcn, ...
                   'gui_OutputFcn',  @Extract_Trial_TuningExtractor_OutputFcn, ...
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


% --- Executes just before Extract_Trial_TuningExtractor is made visible.
function Extract_Trial_TuningExtractor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Extract_Trial_TuningExtractor (see VARARGIN)
global SpikeMovieData;
global SpikeGui;

% Choose default command line output for Extract_Trial_TuningExtractor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Extract_Trial_TuningExtractor wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% We get the input settings to restore state if needed
if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.FilenameTuningShow,'String',Settings.FilenameTuningShowString);
    set(handles.MovieAlignselectionList,'String',Settings.MovieAlignselectionListString);
    set(handles.MovieAlignselectionList,'Value',Settings.MovieAlignselectionListValue);
    set(handles.MovieDiode,'Value',Settings.MovieDiodeValue);
    set(handles.MovieDiode,'String',Settings.MovieDiodeString);
    set(handles.TrialList,'Value',Settings.TrialListValue);
    set(handles.TrialList,'String',Settings.TrialListString);    
    set(handles.ResetTimeTrials,'Value',Settings.ResetTimeTrialsValue);
    set(handles.ThresholdDetect,'String',Settings.ThresholdDetectString);
    set(handles.CorrImagFile,'String',Settings.CorrImagFileString);
    set(handles.ClearPrevMovies,'Value',Settings.ClearPrevMoviesValue);
    set(handles.StimType,'String',Settings.StimTypeString);
else
    if ~isempty(SpikeMovieData)
        for i=1:length(SpikeMovieData)
            TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
        end
        set(handles.MovieDiode,'String',TextMovie);
        set(handles.MovieAlignselectionList,'String',TextMovie);
        set(handles.MovieDiode,'Value',1);
        set(handles.MovieAlignselectionList,'Value',[]);
    end
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.FilenameTuningShowString=get(handles.FilenameTuningShow,'String');
Settings.MovieAlignselectionListString=get(handles.MovieAlignselectionList,'String');
Settings.MovieAlignselectionListValue=get(handles.MovieAlignselectionList,'Value');
Settings.MovieDiodeValue=get(handles.MovieDiode,'Value');
Settings.MovieDiodeString=get(handles.MovieDiode,'String');
Settings.TrialListValue=get(handles.TrialList,'Value');
Settings.TrialListString=get(handles.TrialList,'String');
Settings.ResetTimeTrialsValue=get(handles.ResetTimeTrials,'Value');
Settings.ThresholdDetectString=get(handles.ThresholdDetect,'String');
Settings.CorrImagFileString=get(handles.CorrImagFile,'String');
Settings.ClearPrevMoviesValue=get(handles.ClearPrevMovies,'Value');
Settings.StimTypeString=get(handles.StimType,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Extract_Trial_TuningExtractor_OutputFcn(hObject, eventdata, handles) 
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
if isfield(handles,'hPlotFrame')
    if (ishandle(handles.hPlotFrame))
        delete(handles.hPlotFrame);
    end
end
uiresume;


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    DiodeMovie=get(handles.MovieDiode,'Value');
    AppliedMovie=get(handles.MovieAlignselectionList,'Value');
    
    TuningFile=get(handles.FilenameTuningShow,'String');
    matObj=matfile(TuningFile);
    SaveParamTuning=matObj.SaveParam;
    SetupTuning=matObj.SetupProp;
    StimProp=matObj.StimProp;
    
    DiodeRealValue=squeeze(mean(mean(SpikeMovieData(DiodeMovie).Movie,1),2));
    DiodeRealTime=SpikeMovieData(DiodeMovie).TimeFrame;
    
    % We bring base to zero
    DiodeRealValue=DiodeRealValue-mean(DiodeRealValue(DiodeRealTime<SetupTuning.Delay));
    
    % We make sure to have positive values and threshold it.
    DiodeRealValue=abs(DiodeRealValue);
    
    DiodeRealValue=abs(DiodeRealValue)/max(DiodeRealValue(DiodeRealTime<SetupTuning.Duration));
    
    % We bring to zeros beginning of movies as can be mixed with initialization
    % of screen.
    DiodeRealValue((SetupTuning.Delay/2)>DiodeRealTime)=0;
    
    BWTrials = im2bw(DiodeRealValue,str2num(get(handles.ThresholdDetect,'String'))/100);
    NumberMoviesBefore=length(SpikeMovieData);
    
    if strcmp(SaveParamTuning.StimType,'Infinite Drifting Gratings')
        SingleTrialList = bwconncomp(BWTrials);
        CellArrayTrial=get(handles.TrialList,'String');
        AllAvailableAngles=str2num(char(CellArrayTrial(1:length(CellArrayTrial))));
        SelectedAngles=AllAvailableAngles(get(handles.TrialList,'Value'));
        IndiceTrials=find(ismember(SaveParamTuning.ChosenAngles(1:SingleTrialList.NumObjects), SelectedAngles));
        TimeBeforeTrial=SetupTuning.ITI;
        TimeAfterTrial=StimProp.DurationGrating+SetupTuning.ITI;
        ListMovieKeep=get(handles.MovieAlignselectionList,'Value');
        
        % waitbar is consuming too much ressources, so I divide its access
        dividerWaitbar=10^(floor(log10(length(IndiceTrials)))-1);
        
        h=waitbar(0,'Extracting Trials ...');
        
        for i=1:length(IndiceTrials)
            IndexRef=min(SingleTrialList.PixelIdxList{IndiceTrials(i)});
            TimeInterv(1)=SpikeMovieData(DiodeMovie).TimeFrame(IndexRef)-TimeBeforeTrial;
            TimeInterv(2)=SpikeMovieData(DiodeMovie).TimeFrame(IndexRef)+TimeAfterTrial;
            FrameKeep=find(SpikeMovieData(DiodeMovie).TimeFrame>TimeInterv(1) & SpikeMovieData(DiodeMovie).TimeFrame<TimeInterv(2));
            for j=1:length(ListMovieKeep)
                IndexMovieReg=ListMovieKeep(j);
                IndexMovie=NumberMoviesBefore+(i-1)*length(ListMovieKeep)+j;
                SpikeMovieData(IndexMovie).TimePixelUnits=SpikeMovieData(IndexMovieReg).TimePixelUnits;
                SpikeMovieData(IndexMovie).Xposition=SpikeMovieData(IndexMovieReg).Xposition;
                SpikeMovieData(IndexMovie).Yposition=SpikeMovieData(IndexMovieReg).Yposition;
                SpikeMovieData(IndexMovie).Zposition=SpikeMovieData(IndexMovieReg).Zposition;
                SpikeMovieData(IndexMovie).Label.XLabel=SpikeMovieData(IndexMovieReg).Label.XLabel;
                SpikeMovieData(IndexMovie).Label.YLabel=SpikeMovieData(IndexMovieReg).Label.YLabel;
                SpikeMovieData(IndexMovie).Label.ZLabel=SpikeMovieData(IndexMovieReg).Label.ZLabel;
                SpikeMovieData(IndexMovie).Label.CLabel=SpikeMovieData(IndexMovieReg).Label.CLabel;
                SpikeMovieData(IndexMovie).Path=SpikeMovieData(IndexMovieReg).Path;
                SpikeMovieData(IndexMovie).Filename=SpikeMovieData(IndexMovieReg).Filename;
                SpikeMovieData(IndexMovie).Movie=SpikeMovieData(IndexMovieReg).Movie(:,:,FrameKeep);
                SpikeMovieData(IndexMovie).DataSize=size(SpikeMovieData(IndexMovie).Movie);
                if (get(handles.ResetTimeTrials,'Value')==1)
                    SpikeMovieData(IndexMovie).TimeFrame=SpikeMovieData(IndexMovieReg).TimeFrame(FrameKeep)...
                        -SpikeMovieData(IndexMovieReg).TimeFrame(FrameKeep(1))+SpikeMovieData(IndexMovieReg).TimeFrame(1);
                else
                    SpikeMovieData(IndexMovie).TimeFrame=SpikeMovieData(IndexMovieReg).TimeFrame(FrameKeep);
                end
                SpikeMovieData(IndexMovie).Exposure=SpikeMovieData(IndexMovieReg).Exposure;
                SpikeMovieData(IndexMovie).TimePixel=SpikeMovieData(IndexMovieReg).TimePixel(:,:,FrameKeep);
            end
            if (round(i/dividerWaitbar)==i/dividerWaitbar)
                waitbar(i/length(IndiceTrials),h);
            end
        end
        delete(h);
    end
    
    if (get(handles.ClearPrevMovies,'Value')==1)
        CurrentSize=length(SpikeMovieData);
        SpikeMovieData=SpikeMovieData(NumberMoviesBefore+1:CurrentSize);
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

% --- Executes on button press in SelectFileTuning.
function SelectFileTuning_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFileTuning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;

% Open file path
[filename, pathname] = uigetfile( ...
    {'*.mat','All Files (*.mat)'},'Select MAT File');

% Open file if exist
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
    return
    
    % Otherwise construct the fullfilename and Check and load the file
else
    % To keep the path accessible to futur request
    cd(pathname);
    
    LocalFile=fullfile(pathname,filename);
    guidata(hObject,handles);
    matObj=matfile(LocalFile);
    info=whos(matObj,'SaveParam');
    if ~isempty(info)
        set(handles.FilenameTuningShow,'String',LocalFile);
        MovieDiode_Callback(hObject, eventdata, handles);
    else
        msgbox('No TuningExtractor data in this file');
    end
end


% --- Executes on selection change in MovieAlignselectionList.
function MovieAlignselectionList_Callback(hObject, eventdata, handles)
% hObject    handle to MovieAlignselectionList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MovieAlignselectionList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MovieAlignselectionList


% --- Executes during object creation, after setting all properties.
function MovieAlignselectionList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MovieAlignselectionList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on selection change in MovieDiode.
function MovieDiode_Callback(hObject, eventdata, handles)
% hObject    handle to MovieDiode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MovieDiode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MovieDiode
global SpikeMovieData;

TuningFile=get(handles.FilenameTuningShow,'String');
if exist(TuningFile,'file')==2
    matObj=matfile(TuningFile);
    SaveParam=matObj.SaveParam;
    SetupProp=matObj.SetupProp;
    StimProp=matObj.StimProp;
    
    if strcmp(SaveParam.StimType,'Infinite Drifting Gratings')
        PreviousSelection=get(handles.TrialList,'Value');
        PreviousSelectionText=get(handles.TrialList,'String');
        PreviousAngles=str2num(char(PreviousSelectionText(PreviousSelection)));
        NumberAngles=length(SaveParam.ChosenAngles);
        TimeTrials=SetupProp.Delay+(1:NumberAngles)*(StimProp.DurationGrating+SetupProp.ITI);
        set(handles.CorrImagFile,'String',matObj.ImageFile);

        DiodeMovie=get(handles.MovieDiode,'Value');
        MaxImagingTime=max(SpikeMovieData(DiodeMovie).TimeFrame);
        LastRecordedTrial=max(find(TimeTrials<MaxImagingTime));
        
        AllAvailableAngles=sort(unique(SaveParam.ChosenAngles(1:LastRecordedTrial)));
        set(handles.StimType,'String','Infinite Drifting Gratings, avail. angles (deg):');
        for i=1:length(AllAvailableAngles)
            TextTrial{i}=[num2str(AllAvailableAngles(i))];
        end
        set(handles.TrialList,'String',TextTrial);
        if ~isempty(PreviousAngles)
            IndexValue=find(ismember(AllAvailableAngles, PreviousAngles));
            set(handles.TrialList,'Value',IndexValue);
        end
    else
        msgbox('This Apps is only configured for Infinite Drifting Gratings');
    end
end


% --- Executes during object creation, after setting all properties.
function MovieDiode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MovieDiode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SaveBehSelect.
function SaveBehSelect_Callback(hObject, eventdata, handles)
% hObject    handle to SaveBehSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SaveBehSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SaveBehSelect


% --- Executes during object creation, after setting all properties.
function SaveBehSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaveBehSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TrialList.
function TrialList_Callback(hObject, eventdata, handles)
% hObject    handle to TrialList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TrialList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TrialList


% --- Executes during object creation, after setting all properties.
function TrialList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TrialList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ThresholdDetect_Callback(hObject, eventdata, handles)
% hObject    handle to ThresholdDetect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ThresholdDetect as text
%        str2double(get(hObject,'String')) returns contents of ThresholdDetect as a double


% --- Executes during object creation, after setting all properties.
function ThresholdDetect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThresholdDetect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TestDetectTrials.
function TestDetectTrials_Callback(hObject, eventdata, handles)
% hObject    handle to TestDetectTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;

DiodeMovie=get(handles.MovieDiode,'Value');

TuningFile=get(handles.FilenameTuningShow,'String');
matObj=matfile(TuningFile);
SetupTuning=matObj.SetupProp;

DiodeRealValue=squeeze(mean(mean(SpikeMovieData(DiodeMovie).Movie,1),2));
DiodeRealTime=SpikeMovieData(DiodeMovie).TimeFrame;

% We bring base to zero
DiodeRealValue=DiodeRealValue-mean(DiodeRealValue(DiodeRealTime<SetupTuning.Delay));

% We make sure to have positive values and threshold it.
DiodeRealValue=abs(DiodeRealValue);

DiodeRealValue=abs(DiodeRealValue)/max(DiodeRealValue(DiodeRealTime<SetupTuning.Duration));

% We bring to zeros beginning of movies as can be mixed with initialization
% of screen.
DiodeRealValue((SetupTuning.Delay/2)>DiodeRealTime)=0;

BWTrials = im2bw(DiodeRealValue, str2num(get(handles.ThresholdDetect,'String'))/100);

if ~isfield(handles,'hPlotFrame')
    handles.hPlotFrame=figure('Name','Testing trial detection','NumberTitle','off');
else
    if (isempty(handles.hPlotFrame) || ~ishandle(handles.hPlotFrame))
        handles.hPlotFrame=figure('Name','Testing trial detection','NumberTitle','off');
    else
        figure(handles.hPlotFrame);
    end
end
guidata(gcbo,handles);

plot(DiodeRealTime,DiodeRealValue,'b-',DiodeRealTime,BWTrials,'r-');


% --- Executes on button press in ResetTimeTrials.
function ResetTimeTrials_Callback(hObject, eventdata, handles)
% hObject    handle to ResetTimeTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ResetTimeTrials


% --- Executes on button press in ClearPrevMovies.
function ClearPrevMovies_Callback(hObject, eventdata, handles)
% hObject    handle to ClearPrevMovies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ClearPrevMovies
