function varargout = ROI_Analysis(varargin)
% ROI_ANALYSIS MATLAB code for ROI_Analysis.fig
%      ROI_ANALYSIS, by itself, creates a new ROI_ANALYSIS or raises the existing
%      singleton*.
%
%      H = ROI_ANALYSIS returns the handle to a new ROI_ANALYSIS or the handle to
%      the existing singleton*.
%
%      ROI_ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROI_ANALYSIS.M with the given input arguments.
%
%      ROI_ANALYSIS('Property','Value',...) creates a new ROI_ANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROI_Analysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROI_Analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help ROI_Analysis

% Last Modified by GUIDE v2.5 01-Mar-2012 14:01:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROI_Analysis_OpeningFcn, ...
                   'gui_OutputFcn',  @ROI_Analysis_OutputFcn, ...
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


% --- Executes just before ROI_Analysis is made visible.
function ROI_Analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROI_Analysis (see VARARGIN)

% Choose default command line output for ROI_Analysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ROI_Analysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global SpikeMovieData;

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.SelectROIMovieMenu,'Value',Settings.SelectROIMovieMenuValue);
    set(handles.SelectROIMovieMenu,'String',Settings.SelectROIMovieMenuString);
    set(handles.SelectROITypeMenu,'Value',Settings.SelectROITypeMenuValue);
    set(handles.ROIRadius,'String',Settings.ROIRadiusString);
    set(handles.ChooseColorMode,'Value',Settings.ChooseColorModeValue);
    set(handles.ChooseTraceDisplayMode,'Value',Settings.ChooseTraceDisplayModeValue);
    set(handles.StackStep,'String',Settings.StackStepString);
    set(handles.DisplayFrameMode,'String',Settings.DisplayFrameModeString);
    set(handles.MoviesDisplayed,'String',Settings.MoviesDisplayedString);
    set(handles.MoviesDisplayed,'Value',Settings.MoviesDisplayedValue);
else   
    if ~isempty(SpikeMovieData)
        for i=1:length(SpikeMovieData)
            TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
        end
        set(handles.SelectROIMovieMenu,'String',TextMovie);
        set(handles.SelectROIMovieMenu,'Value',1);

        set(handles.MoviesDisplayed,'String',TextMovie);
        set(handles.MoviesDisplayed,'Value',min(1,length(SpikeMovieData)));
    end
end

DisplayROIImage(handles);

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.SelectROIMovieMenuValue=get(handles.SelectROIMovieMenu,'Value');
Settings.SelectROIMovieMenuString=get(handles.SelectROIMovieMenu,'String');
Settings.SelectROITypeMenuValue=get(handles.SelectROITypeMenu,'Value');
Settings.ROIRadiusString=get(handles.ROIRadius,'String');
Settings.ChooseColorModeValue=get(handles.ChooseColorMode,'Value');
Settings.ChooseTraceDisplayModeValue=get(handles.ChooseTraceDisplayMode,'Value');
Settings.StackStepString=get(handles.StackStep,'String');
Settings.DisplayFrameModeString=get(handles.DisplayFrameMode,'String');
Settings.MoviesDisplayedString=get(handles.MoviesDisplayed,'String');
Settings.MoviesDisplayedValue=get(handles.MoviesDisplayed,'Value');


% --- Outputs from this function are returned to the command line.
function varargout = ROI_Analysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in DisplayFrameMode.
function DisplayFrameMode_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayFrameMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DisplayFrameMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DisplayFrameMode
DisplayROIImage(handles);


% --- Executes during object creation, after setting all properties.
function DisplayFrameMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DisplayFrameMode (see GCBO)
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
if isfield(handles,'hLocalFrame')
    if (ishandle(handles.hLocalFrame))
        delete(handles.hLocalFrame);
    end
end
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
global SpikeTraceData;
global SpikeImageData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    h = findobj(handles.hLocalFrame,'Type','axes');
    h=sort(h);
    ListDisplayedMovie=get(handles.MoviesDisplayed,'Value');
    
    localH=findobj(handles.hLocalFrame,'Type','hggroup');
    if ~isempty(localH)
        NumberROI=length(localH);
        
        hWait=waitbar(0,'Creating plots');
        for LocalROI=1:NumberROI
            LocalAxe=get(localH(LocalROI),'Parent');
            IndexChannel=find(LocalAxe==h);
            LocalSelMovie=ListDisplayedMovie(IndexChannel);
            
            ROIPlots(LocalROI).TimeFramePlot=zeros(SpikeMovieData(LocalSelMovie).DataSize(3),1,'single');
            ROIPlots(LocalROI).currentMoviePlot=zeros(SpikeMovieData(LocalSelMovie).DataSize(3),1,'single');
            ROIPlots(LocalROI).StdcurrentMoviePlot=zeros(SpikeMovieData(LocalSelMovie).DataSize(3),1,'single');
            ROIPlots(LocalROI).SEMcurrentMoviePlot=zeros(SpikeMovieData(LocalSelMovie).DataSize(3),1,'single');
            
            hROI=getappdata(localH(LocalROI),'roiObjectReference');
            
            BW_ROI = createMask(hROI);
            IndicesROI=find(BW_ROI);
            for j=1:SpikeMovieData(LocalSelMovie).DataSize(3)
                LocalMovie=SpikeMovieData(LocalSelMovie).Movie(:,:,j);
                LocalTime=SpikeMovieData(LocalSelMovie).TimeFrame(j);
                LocalPixel=SpikeMovieData(LocalSelMovie).TimePixel(:,:,j);
                ROIPlots(LocalROI).TimeFramePlot(j,1)=LocalTime+SpikeMovieData(LocalSelMovie).TimePixelUnits*mean(LocalPixel(IndicesROI));
                ROIPlots(LocalROI).currentMoviePlot(j,1)=mean(LocalMovie(IndicesROI));
                ROIPlots(LocalROI).StdcurrentMoviePlot(j,1)=std(double(LocalMovie(IndicesROI)));
                ROIPlots(LocalROI).SEMcurrentMoviePlot(j,1)=ROIPlots(LocalROI).StdcurrentMoviePlot(j)/sqrt(length(IndicesROI));
            end
            
            if get(handles.ChooseTraceDisplayMode,'Value')==2
                StackStep=str2num(get(handles.StackStep,'String'));
                LocalMean=mean(ROIPlots(LocalROI).currentMoviePlot);
                ROIPlots(LocalROI).currentMoviePlot=ROIPlots(LocalROI).currentMoviePlot-LocalMean+LocalROI*StackStep;
            end
            waitbar(LocalROI/NumberROI,hWait);
        end
        close(hWait);
        
        if isfield(handles,'hPlotFrame')
            if (isempty(handles.hPlotFrame) || ~ishandle(handles.hPlotFrame))
                handles.hPlotFrame=figure('Name','Averaging figure from ROIs','NumberTitle','off');
            else
                figure(handles.hPlotFrame);
            end
        else
            handles.hPlotFrame=figure('Name','Averaging figure from ROIs','NumberTitle','off');
        end
        CurrentNumberTrace=length(SpikeTraceData);
        CurrentNumberImage=length(SpikeImageData);
        
        for LocalROI=1:NumberROI
            % Plot average trace of ROIs
            hROI=getappdata(localH(LocalROI),'roiObjectReference');
            LocalColor=getColor(hROI);
            
            switch get(handles.SelectROIBarsMenu,'Value')
                case 1
                    plot(ROIPlots(LocalROI).TimeFramePlot,ROIPlots(LocalROI).currentMoviePlot,'Color',LocalColor);
                case 2
                    errorbar(gca,ROIPlots(LocalROI).TimeFramePlot,ROIPlots(LocalROI).currentMoviePlot,ROIPlots(LocalROI).StdcurrentMoviePlot,'Color',LocalColor);
                case 3
                    errorbar(gca,ROIPlots(LocalROI).TimeFramePlot,ROIPlots(LocalROI).currentMoviePlot,ROIPlots(LocalROI).SEMcurrentMoviePlot,'Color',LocalColor);
            end
            if LocalROI<NumberROI
                hold on;
            else
                hold off;
            end
            if (get(handles.ExportTraceList,'Value')==1)
                if isempty(SpikeTraceData)
                    InitTraces();
                end
                SpikeTraceData(CurrentNumberTrace+LocalROI).XVector=ROIPlots(LocalROI).TimeFramePlot;
                SpikeTraceData(CurrentNumberTrace+LocalROI).Trace=ROIPlots(LocalROI).currentMoviePlot;
                SpikeTraceData(CurrentNumberTrace+LocalROI).DataSize=size(SpikeTraceData(CurrentNumberTrace+LocalROI).Trace);
                SpikeTraceData(CurrentNumberTrace+LocalROI).Label.YLabel=SpikeMovieData(LocalSelMovie).Label.CLabel;
                SpikeTraceData(CurrentNumberTrace+LocalROI).Filename=SpikeMovieData(LocalSelMovie).Filename;
                SpikeTraceData(CurrentNumberTrace+LocalROI).Path=SpikeMovieData(LocalSelMovie).Path;
                SpikeTraceData(CurrentNumberTrace+LocalROI).Label.ListText=['ROI ',num2str(LocalROI)];
                SpikeTraceData(CurrentNumberTrace+LocalROI).Label.XLabel='Time (s)';
            end
            if (get(handles.ExportImageList,'Value')==1)
                if isempty(SpikeImageData)
                    InitImages();
                end
                BW_ROI = createMask(hROI);
                NumberOnes=length(find(BW_ROI));
                % We divide the filter by the number of selected pixel
                % to ensure proper normalization of the filter.
                SpikeImageData(CurrentNumberImage+LocalROI).Image=double(BW_ROI)/NumberOnes;
                SpikeImageData(CurrentNumberImage+LocalROI).DataSize=size(SpikeImageData(CurrentNumberImage+LocalROI).Image);
                SpikeImageData(CurrentNumberImage+LocalROI).Label.CLabel=SpikeMovieData(LocalSelMovie).Label.CLabel;
                SpikeImageData(CurrentNumberImage+LocalROI).Label.XLabel=SpikeMovieData(LocalSelMovie).Label.XLabel;
                SpikeImageData(CurrentNumberImage+LocalROI).Label.YLabel=SpikeMovieData(LocalSelMovie).Label.YLabel;
                SpikeImageData(CurrentNumberImage+LocalROI).Label.ZLabel=SpikeMovieData(LocalSelMovie).Label.ZLabel;
                SpikeImageData(CurrentNumberImage+LocalROI).Xposition=SpikeMovieData(LocalSelMovie).Xposition;
                SpikeImageData(CurrentNumberImage+LocalROI).Yposition=SpikeMovieData(LocalSelMovie).Yposition;
                SpikeImageData(CurrentNumberImage+LocalROI).Zposition=SpikeMovieData(LocalSelMovie).Zposition;
                SpikeImageData(CurrentNumberImage+LocalROI).Filename=SpikeMovieData(LocalSelMovie).Filename;
                SpikeImageData(CurrentNumberImage+LocalROI).Path=SpikeMovieData(LocalSelMovie).Path;
                SpikeImageData(CurrentNumberImage+LocalROI).Label.ListText=['ROI ',num2str(LocalROI)];
            end
            
        end
        xlabel('Time (s)');
        ylabel(SpikeMovieData(LocalSelMovie).Label.CLabel);
        guidata(gcbo,handles);
    end
    set(InterfaceObj,'Enable','on');
    
catch errorObj
    set(InterfaceObj,'Enable','on');
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
    if exist('hWait','var')
        if ishandle(hWait)
            close(hWait);
        end
    end
end


% --- Executes on selection change in SelectROIMovieMenu.
function SelectROIMovieMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SelectROIMovieMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SelectROIMovieMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectROIMovieMenu


% --- Executes during object creation, after setting all properties.
function SelectROIMovieMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectROIMovieMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SelectROITypeMenu.
function SelectROITypeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SelectROITypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SelectROITypeMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectROITypeMenu


% --- Executes during object creation, after setting all properties.
function SelectROITypeMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectROITypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SelectROIBarsMenu.
function SelectROIBarsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SelectROIBarsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SelectROIBarsMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectROIBarsMenu


% --- Executes during object creation, after setting all properties.
function SelectROIBarsMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectROIBarsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SelectROIAverageMenu.
function SelectROIAverageMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SelectROIAverageMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SelectROIAverageMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectROIAverageMenu


% --- Executes during object creation, after setting all properties.
function SelectROIAverageMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectROIAverageMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddROI.
function AddROI_Callback(hObject, eventdata, handles,LocalAxe)
% hObject    handle to AddROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(handles.output);

if isfield(handles,'hLocalFrame')
    figure(handles.hLocalFrame);
else
    DisplayROIImage(handles);
    handles=guidata(handles.output);
end

if nargin>3
    CurrentAxe=LocalAxe;
else
    h = findobj(handles.hLocalFrame,'Type','axes');
    h=sort(h);
    NumberAxis=get(handles.SelectROIMovieMenu,'Value');
    CurrentAxe=h(NumberAxis);
end

localH=findobj(handles.hLocalFrame,'Type','hggroup');
if ~isempty(localH)
    NumberROI=length(localH);
else
    NumberROI=0;
end

if get(handles.ChooseColorMode,'Value')==1
    ColorMatrix=get(gca,'ColorOrder');
    
    NbColors=size(ColorMatrix,1);
    LocalColorIndex=NumberROI+1-NbColors*floor((NumberROI)/NbColors);
    LocalColor=ColorMatrix(LocalColorIndex,:);
else
    LocalColorIndice=get(handles.ChooseColorMode,'Value');
    ListColor=get(handles.ChooseColorMode,'String');
    LocalColor=char(ListColor{LocalColorIndice});
end

switch get(handles.SelectROITypeMenu,'Value')
    case 1
        hROI=imellipse(CurrentAxe);
    case 2
        hROI=imrect(CurrentAxe);
    case 3
        hROI=imline(CurrentAxe);
    case 4
        hROI=impoint(CurrentAxe);
    case 5
        hROI=impoly(CurrentAxe);
    case 6
        hROI=imfreehand(CurrentAxe);
end

setColor(hROI,LocalColor);
guidata(handles.output,handles);


% --- Executes on button press in ClearROI.
function ClearROI_Callback(hObject, eventdata, handles)
% hObject    handle to ClearROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h=findobj(handles.hLocalFrame,'Type','hggroup');
delete(h);


% --- Executes on selection change in ChooseTraceDisplayMode.
function ChooseTraceDisplayMode_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseTraceDisplayMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ChooseTraceDisplayMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ChooseTraceDisplayMode


% --- Executes during object creation, after setting all properties.
function ChooseTraceDisplayMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChooseTraceDisplayMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function StackStep_Callback(hObject, eventdata, handles)
% hObject    handle to StackStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StackStep as text
%        str2double(get(hObject,'String')) returns contents of StackStep as a double


% --- Executes during object creation, after setting all properties.
function StackStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StackStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ChooseColorMode.
function ChooseColorMode_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseColorMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ChooseColorMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ChooseColorMode


% --- Executes during object creation, after setting all properties.
function ChooseColorMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChooseColorMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% function to display the current ROI over the movies
function DisplayROIImage(handles)
global SpikeMovieData;
global SpikeGui;

h=waitbar(0,'Creating background picture...');

ValueMovies=get(handles.MoviesDisplayed,'Value');


for i=1:length(ValueMovies)
    LocalMovie=ValueMovies(i);
    NewPic(i).data=zeros(SpikeMovieData(LocalMovie).DataSize(1:2) ,'single');

    % We do it line by line to reduce memory usage of subfunction and keep
    % speed.
    dividerWaitbar=10^(floor(log10(SpikeMovieData(LocalMovie).DataSize(1)))-1);

    if get(handles.DisplayFrameMode, 'Value')==1
        NewPic(i).data=SpikeMovieData(LocalMovie).Movie(:,:,round(SpikeMovieData(LocalMovie).DataSize(3)/2));
    else
        for j=1:SpikeMovieData(LocalMovie).DataSize(1)
            switch get(handles.DisplayFrameMode,'Value')
                case 2
                    NewPic(i).data(j,:)=mean(SpikeMovieData(LocalMovie).Movie(j,:,:),3);
                case 3
                    NewPic(i).data(j,:)=max(SpikeMovieData(LocalMovie).Movie(j,:,:),[],3);
                case 4
                    for k=1:SpikeMovieData(LocalMovie).DataSize(2)
                        NewPic(i).data(j,k,i)=std(single(SpikeMovieData(LocalMovie).Movie(j,k,:)),1,3);
                    end
            end
            if (round(j/dividerWaitbar)==j/dividerWaitbar)
                waitbar(j/SpikeMovieData(LocalMovie).DataSize(1),h);
            end
        end
    end
    
end
delete(h);

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

for i=1:length(ValueMovies)
    LocalAxe=subplot(1,length(ValueMovies),i);
    LocalH=imagesc(NewPic(i).data(:,:));
    set(LocalH,'ButtonDownFcn',{@AddROI_Callback, handles,LocalAxe});
end

guidata(handles.output,handles);


% --- Executes on selection change in MoviesDisplayed.
function MoviesDisplayed_Callback(hObject, eventdata, handles)
% hObject    handle to MoviesDisplayed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MoviesDisplayed contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MoviesDisplayed
DisplayROIImage(handles);


% --- Executes during object creation, after setting all properties.
function MoviesDisplayed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MoviesDisplayed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in EnablepresetsROI.
function EnablepresetsROI_Callback(hObject, eventdata, handles)
% hObject    handle to EnablepresetsROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of EnablepresetsROI



function ROIRadius_Callback(hObject, eventdata, handles)
% hObject    handle to ROIRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROIRadius as text
%        str2double(get(hObject,'String')) returns contents of ROIRadius as a double


% --- Executes during object creation, after setting all properties.
function ROIRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in ExportTraceList.
function ExportTraceList_Callback(hObject, eventdata, handles)
% hObject    handle to ExportTraceList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ExportTraceList


% --- Executes during object creation, after setting all properties.
function AddROI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AddROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in ExportImageList.
function ExportImageList_Callback(hObject, eventdata, handles)
% hObject    handle to ExportImageList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ExportImageList
