function varargout = DeltaF_over_F(varargin)
% DELTAF_OVER_F MATLAB code for DeltaF_over_F.fig
%      DELTAF_OVER_F, by itself, creates a new DELTAF_OVER_F or raises the existing
%      singleton*.
%
%      H = DELTAF_OVER_F returns the handle to a new DELTAF_OVER_F or the handle to
%      the existing singleton*.
%
%      DELTAF_OVER_F('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DELTAF_OVER_F.M with the given input arguments.
%
%      DELTAF_OVER_F('Property','Value',...) creates a new DELTAF_OVER_F or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DeltaF_over_F_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DeltaF_over_F_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help DeltaF_over_F

% Last Modified by GUIDE v2.5 03-Mar-2012 12:26:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DeltaF_over_F_OpeningFcn, ...
                   'gui_OutputFcn',  @DeltaF_over_F_OutputFcn, ...
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


% --- Executes just before DeltaF_over_F is made visible.
function DeltaF_over_F_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DeltaF_over_F (see VARARGIN)
global SpikeMovieData;

% Choose default command line output for DeltaF_over_F
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DeltaF_over_F wait for user response (see UIRESUME)
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
    set(handles.SelectTypeDF,'Value',Settings.SelectTypeDFValue);
    set(handles.MovieSelector,'Value',intersect(1:NumberMovies,Settings.MovieSelectorValue));
    set(handles.FixBackSelect,'Value',Settings.FixBackSelectValue);
    set(handles.BeginAverage,'String',Settings.BeginAverageString);
    set(handles.EndAverage,'String',Settings.EndAverageString);
    set(handles.LowPassBackSelect,'Value',Settings.LowPassBackSelectValue);
    set(handles.FilterType,'Value',Settings.FilterTypeValue);
    set(handles.FilterOrder,'String',Settings.FilterOrderString);
    set(handles.FilterCutOff,'String',Settings.FilterCutOffString);
    set(handles.UseFiltFilt,'Value',Settings.UseFiltFiltValue);
else
    if ~isempty(SpikeMovieData)
        set(handles.EndAverage,'String',num2str(max(SpikeMovieData(get(handles.MovieSelector,'Value')).TimeFrame)));
    end
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.SelectTypeDFValue=get(handles.SelectTypeDF,'Value');
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.FixBackSelectValue=get(handles.FixBackSelect,'Value');
Settings.BeginAverageString=get(handles.BeginAverage,'String');
Settings.EndAverageString=get(handles.EndAverage,'String');
Settings.LowPassBackSelectValue=get(handles.LowPassBackSelect,'Value');
Settings.FilterTypeValue=get(handles.FilterType,'Value');
Settings.FilterOrderString=get(handles.FilterOrder,'String');
Settings.FilterCutOffString=get(handles.FilterCutOff,'String');
Settings.UseFiltFiltValue=get(handles.UseFiltFilt,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = DeltaF_over_F_OutputFcn(hObject, eventdata, handles) 
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
if isfield(handles,'hLocalFrame')
    if (ishandle(handles.hLocalFrame))
        delete(handles.hLocalFrame);
    end
end
if isfield(handles,'hLocalTestF0')
    if (ishandle(handles.hLocalTestF0))
        delete(handles.hLocalTestF0);
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
    
    MovieApplied=get(handles.MovieSelector,'Value');
    
    h=waitbar(0,'Converting movie to single precision');
    % Since we are making division, we need to move to single precision, even
    % if that cost much larger amount of memory
    SpikeMovieData(MovieApplied).Movie=single(SpikeMovieData(MovieApplied).Movie);
    delete(h);
    
    h=waitbar(0,'Apply Delta F...');
    
    % waitbar is consuming too much ressources, so I divide its acces
    dividerWaitbar=10^(floor(log10(SpikeMovieData(MovieApplied).DataSize(1)))-1);
    
    FrequencySample=1/(SpikeMovieData(MovieApplied).TimeFrame(2)-SpikeMovieData(MovieApplied).TimeFrame(1));
    FNyquist=FrequencySample/2;
    
    Order=str2num(get(handles.FilterOrder,'String'));
    CutOff=str2double(get(handles.FilterCutOff,'String'));
    
    Wn=CutOff/FNyquist;
    
    
    BeginTime=str2num(get(handles.BeginAverage,'String'));
    EndTime=str2num(get(handles.EndAverage,'String'));
    DFType=get(handles.SelectTypeDF,'Value');
    FiltFilt=get(handles.UseFiltFilt,'Value');
    BackgroundType=get(handles.FixBackSelect,'Value');

    if BackgroundType==1
        [PassB,PassA] = butter(Order,Wn,'low');
end


    if (BackgroundType==1)
        IndiceLocal=(SpikeMovieData(MovieApplied).TimeFrame>=BeginTime & SpikeMovieData(MovieApplied).TimeFrame<=EndTime);
        F0localLine=zeros(1,SpikeMovieData((MovieApplied)).DataSize(2));
    else
        InitialLine=zeros(1,SpikeMovieData((MovieApplied)).DataSize(2),SpikeMovieData((MovieApplied)).DataSize(3));
    end
    
    F0local=zeros(1,SpikeMovieData((MovieApplied)).DataSize(2),SpikeMovieData((MovieApplied)).DataSize(3));
    
    % we still keep one for loop to avoid passing too large arguments to
    % subfunction and provide feedback on the progress of the calculation.
    % 2 nested for loop is very unfavorable computationnaly.
    for i=1:SpikeMovieData((MovieApplied)).DataSize(1)
        
        if (BackgroundType==1)
            F0localLine=mean(SpikeMovieData(MovieApplied).Movie(i,:,IndiceLocal),3);
            
            % We shiftdim to create the proper matrix size.
            F0local=shiftdim(shiftdim(F0localLine,1)*ones(1,SpikeMovieData((MovieApplied)).DataSize(3)),-1);
        else
            % We extract the initial value of the matrix. To reduce lowpass
            % filtering artifact induces by initial values of the filer.
            InitialLine=shiftdim(shiftdim(SpikeMovieData(MovieApplied).Movie(i,:,1),1)*ones(1,SpikeMovieData((MovieApplied)).DataSize(3)),-1);
            
            if (FiltFilt==1)
                % With filtfilt, we have to for loop as it can't take
                % higher dimensions.
                for j=1:SpikeMovieData((MovieApplied)).DataSize(2)
                    F0local(1,j,:)=InitialLine(1,j,1)+single(filtfilt(double(PassB),double(PassA), double(SpikeMovieData(MovieApplied).Movie(i,j,:)-InitialLine(1,j,1))));
                end
            else
                F0local=InitialLine+single(filter(double(PassB),double(PassA),double(SpikeMovieData(MovieApplied).Movie(i,:,:)-InitialLine),[],3));
            end
        end
        
        if (DFType==1)
            % We multiply by 0 all F0local that are zero in that case.
            SpikeMovieData((MovieApplied)).Movie(i,:,:)=~(F0local==0).*(SpikeMovieData(MovieApplied).Movie(i,:,:)-F0local)./F0local;
            
        else
            SpikeMovieData((MovieApplied)).Movie(i,:,:)=SpikeMovieData(MovieApplied).Movie(i,:,:)-F0local;
        end
        
        if (round(i/dividerWaitbar)==i/dividerWaitbar)
            waitbar(i/SpikeMovieData(MovieApplied).DataSize(1),h);
        end
    end
    
    if (DFType==1)
        SpikeMovieData(MovieApplied).Label.CLabel='\DeltaF/F';
    else
        SpikeMovieData(MovieApplied).Label.CLabel='\DeltaF';
    end

    delete(h);
    set(InterfaceObj,'Enable','on');
    ValidateValues_Callback(hObject, eventdata, handles);
        
catch errorObj
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
    if exist('h','var')
        if ishandle(h)
            delete(h);
        end
    end
    set(InterfaceObj,'Enable','on');

end

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

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in FilterType.
function FilterType_Callback(hObject, eventdata, handles)
% hObject    handle to FilterType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FilterType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FilterType


% --- Executes during object creation, after setting all properties.
function FilterType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilterType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in UseFiltFilt.
function UseFiltFilt_Callback(hObject, eventdata, handles)
% hObject    handle to UseFiltFilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UseFiltFilt



function FilterOrder_Callback(hObject, eventdata, handles)
% hObject    handle to FilterOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FilterOrder as text
%        str2double(get(hObject,'String')) returns contents of FilterOrder as a double


% --- Executes during object creation, after setting all properties.
function FilterOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilterOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FilterCutOff_Callback(hObject, eventdata, handles)
% hObject    handle to FilterCutOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FilterCutOff as text
%        str2double(get(hObject,'String')) returns contents of FilterCutOff as a double


% --- Executes during object creation, after setting all properties.
function FilterCutOff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilterCutOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SelectTypeDF.
function SelectTypeDF_Callback(hObject, eventdata, handles)
% hObject    handle to SelectTypeDF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SelectTypeDF contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectTypeDF


% --- Executes during object creation, after setting all properties.
function SelectTypeDF_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectTypeDF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in FixBackSelect.
function FixBackSelect_Callback(hObject, eventdata, handles)
% hObject    handle to FixBackSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FixBackSelect


% --- Executes on button press in LowPassBackSelect.
function LowPassBackSelect_Callback(hObject, eventdata, handles)
% hObject    handle to LowPassBackSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LowPassBackSelect


% --- Executes on button press in SelectROI.
function SelectROI_Callback(hObject, eventdata, handles)
% hObject    handle to SelectROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;
global SpikeGui;

if isfield(handles,'hLocalFrame')
    if (isempty(handles.hLocalFrame) || ~ishandle(handles.hLocalFrame))
        handles.hLocalFrame=figure('Name','ROIs over Movie','NumberTitle','off');
    else
        figure(handles.hLocalFrame);
    end
else
    handles.hLocalFrame=figure('Name','ROIs over Movie','NumberTitle','off');
end

if (ishandle(SpikeGui.hDataDisplay))
    GlobalColorMap = get(SpikeGui.hDataDisplay,'Colormap');
    set(handles.hLocalFrame,'Colormap',GlobalColorMap)
end

MovieApplied=get(handles.MovieSelector,'Value');
NewPic=mean(SpikeMovieData(MovieApplied).Movie,3);
imagesc(NewPic);

h = findobj(handles.hLocalFrame,'Type','axes');

imellipse(h);

guidata(handles.output,handles);

% --- Executes on button press in TestFO.
function TestFO_Callback(hObject, eventdata, handles)
% hObject    handle to TestFO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;

MovieApplied=get(handles.MovieSelector,'Value');

localH=findobj(handles.hLocalFrame,'Type','hggroup');
TimeFramePlot=zeros(SpikeMovieData(MovieApplied).DataSize(3),1,'double');
currentMoviePlot=zeros(SpikeMovieData(MovieApplied).DataSize(3),1,'double');

hwait=waitbar(0,'Creating plot...');

hROI=getappdata(localH,'roiObjectReference');
dividerWaitbar=10^(floor(log10(SpikeMovieData(MovieApplied).DataSize(3)))-1);

BW_ROI = createMask(hROI);
IndicesROI=find(BW_ROI);
for j=1:SpikeMovieData(MovieApplied).DataSize(3)
    LocalMovie=SpikeMovieData(MovieApplied).Movie(:,:,j);
    LocalTime=SpikeMovieData(MovieApplied).TimeFrame(j);
    LocalPixel=SpikeMovieData(MovieApplied).TimePixel(:,:,j);
    TimeFramePlot(j)=LocalTime+SpikeMovieData(MovieApplied).TimePixelUnits*mean(LocalPixel(IndicesROI));
    currentMoviePlot(j)=mean(LocalMovie(IndicesROI));
    if (round(j/dividerWaitbar)==j/dividerWaitbar)
        waitbar(j/SpikeMovieData(MovieApplied).DataSize(3),hwait);
    end
end
close(hwait);

FrequencySample=1/(SpikeMovieData(MovieApplied).TimeFrame(2)-SpikeMovieData(MovieApplied).TimeFrame(1));
FNyquist=FrequencySample/2;

Order=str2num(get(handles.FilterOrder,'String'));
CutOff=str2double(get(handles.FilterCutOff,'String'));

Wn=CutOff/FNyquist;

[PassB,PassA] = butter(Order,Wn,'low');
BeginTime=str2num(get(handles.BeginAverage,'String'));
EndTime=str2num(get(handles.EndAverage,'String'));

if (get(handles.FixBackSelect,'Value')==1)
    IndiceLocal=find(TimeFramePlot>=BeginTime & TimeFramePlot<=EndTime);
    F0local=mean(currentMoviePlot(IndiceLocal))*ones(size(currentMoviePlot));
else
    if (get(handles.UseFiltFilt,'Value')==1)
        F0local=currentMoviePlot(1)+filtfilt(double(PassB),double(PassA),currentMoviePlot(:)-currentMoviePlot(1));
    else
        F0local=currentMoviePlot(1)+filter(double(PassB),double(PassA),currentMoviePlot(:)-currentMoviePlot(1));
    end
end
            
if isfield(handles,'hLocalTestF0')
    if (isempty(handles.hLocalTestF0) || ~ishandle(handles.hLocalTestF0))
        handles.hLocalTestF0=figure('Name','Test of background','NumberTitle','off');
    else
        figure(handles.hLocalTestF0);
    end
else
    handles.hLocalTestF0=figure('Name','Test of background','NumberTitle','off');
end
MedValue=median(currentMoviePlot)*ones(size(currentMoviePlot));
plot(TimeFramePlot,currentMoviePlot,'b-',TimeFramePlot,F0local,'r-');
guidata(gcbo,handles);


function BeginAverage_Callback(hObject, eventdata, handles)
% hObject    handle to BeginAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BeginAverage as text
%        str2double(get(hObject,'String')) returns contents of BeginAverage as a double


% --- Executes during object creation, after setting all properties.
function BeginAverage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BeginAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EndAverage_Callback(hObject, eventdata, handles)
% hObject    handle to EndAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EndAverage as text
%        str2double(get(hObject,'String')) returns contents of EndAverage as a double


% --- Executes during object creation, after setting all properties.
function EndAverage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EndAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
