function varargout = Track_Movement(varargin)
% TRACK_MOVEMENT MATLAB code for Track_Movement.fig
%      TRACK_MOVEMENT, by itself, creates a new TRACK_MOVEMENT or raises the existing
%      singleton*.
%
%      H = TRACK_MOVEMENT returns the handle to a new TRACK_MOVEMENT or the handle to
%      the existing singleton*.
%
%      TRACK_MOVEMENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACK_MOVEMENT.M with the given input arguments.
%
%      TRACK_MOVEMENT('Property','Value',...) creates a new TRACK_MOVEMENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Track_Movement_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Track_Movement_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Track_Movement

% Last Modified by GUIDE v2.5 21-Oct-2012 12:45:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Track_Movement_OpeningFcn, ...
                   'gui_OutputFcn',  @Track_Movement_OutputFcn, ...
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


% --- Executes just before Track_Movement is made visible.
function Track_Movement_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Track_Movement (see VARARGIN)

% Choose default command line output for Track_Movement
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Track_Movement wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global SpikeMovieData;

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.MovieSelector,'Value',Settings.SelectROIMovieMenuValue);
    set(handles.SelectROITypeMenu,'Value',Settings.SelectROITypeMenuValue);
    set(handles.Project1D, 'Value', Settings.Project1DValue);
    set(handles.DisplayFrameMode,'String',Settings.DisplayFrameModeString);
    set(handles.MovieDisplayed,'Value',Settings.MoviesDisplayedValue);
    set(handles.MaxValueToDetect, 'String', Settings.MaxValueToDetectString);
    set(handles.MinAreaToDetect, 'String', Settings.MinAreaToDetectString);
    set(handles.DisplayMouse, 'Value', Settings.DisplayMouseValue);
end  
if ~isempty(SpikeMovieData)
    for i=1:length(SpikeMovieData)
        TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
    end
    set(handles.MovieSelector,'String',TextMovie);

    set(handles.MovieDisplayed,'String',TextMovie);
    set(handles.MovieDisplayed,'Value',min(1,length(SpikeMovieData)));
end

%DisplayROIImage(handles);

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.SelectROIMovieMenuValue=get(handles.MovieSelector,'Value');
Settings.SelectROIMovieMenuString=get(handles.MovieSelector,'String');
Settings.SelectROITypeMenuValue=get(handles.SelectROITypeMenu,'Value');
Settings.Project1DValue=get(handles.Project1D, 'Value');
Settings.DisplayFrameModeString=get(handles.DisplayFrameMode,'String');
Settings.MoviesDisplayedString=get(handles.MovieDisplayed,'String');
Settings.MoviesDisplayedValue=get(handles.MovieDisplayed,'Value');
Settings.MaxValueToDetectString=get(handles.MaxValueToDetect, 'String');
Settings.MinAreaToDetectString=get(handles.MinAreaToDetect, 'String');
Settings.DisplayMouseValue=get(handles.DisplayMouse, 'Value');

% --- Outputs from this function are returned to the command line.
function varargout = Track_Movement_OutputFcn(hObject, eventdata, handles) 
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

    ListDisplayedMovie=get(handles.MovieDisplayed,'Value');
    MovieSel=get(handles.MovieSelector, 'Value');
    displayMouse=get(handles.DisplayMouse, 'Value');
    
    localH=findobj(handles.hLocalFrame,'Type','hggroup');
    if isempty(localH)
        warning('Warning: No subregion detected')
        BW_ROI=ones(size(SpikeMovieData(MovieSel).DataSize(1:2)));
    else
        % get the subregion selected from the figure
        NumberROI=length(localH);
        if NumberROI>1
            error('Too many subregions selected!')
        elseif NumberROI==0
            BW_ROI=ones(size(SpikeMovieData(MovieSel).Movie(:,:,1)));
        else
            hROI=getappdata(localH(1),'roiObjectReference');
            BW_ROI = createMask(hROI); 
        end
    end
        
    for movieInd=MovieSel
        % track motion
        first_frame=1;
        last_frame=SpikeMovieData(movieInd).DataSize(3);
        trace_vector = zeros(last_frame,2);
        movement_threshold = .2;
        bout_threshold = 5;
        total_value = 0;

        % initialize the cells that will store the final images);
        frame1gray=SpikeMovieData(movieInd).Movie(:,:,1);
        location = zeros(size(frame1gray));
        LocationImage=zeros(size(frame1gray));
        LocationMovie=false(SpikeMovieData(movieInd).DataSize+[10,10,0]);

        % define threshold for area of blob and location in ROI
        area_threshold=str2double(get(handles.MinAreaToDetect, 'String'));
        value_threshold=str2double(get(handles.MaxValueToDetect, 'String'));

        if displayMouse
            hDisp=figure();
            subplot(121)
            subplot(122)
            colormap(jet)
        end
        dividerWaitbar=round((last_frame-first_frame)/10);
        hWait=waitbar(1/20, 'Tracking Movement....');
        for i=first_frame:last_frame;

            if mod(i-first_frame, dividerWaitbar)==0
                waitbar((i-first_frame)/(last_frame-first_frame), hWait)
            end

            % pick out the current frame
            current_image = double(SpikeMovieData(movieInd).Movie(:,:,i));
            current_image=current_image.*double(BW_ROI);

            % Locate the dark mouse and turn it white on an all black backgound
            current_image(current_image>value_threshold)=0;
            current_image(current_image<=value_threshold & current_image~=0) = 200;

            if displayMouse
                figure(hDisp)
                subplot(121)
                imagesc(current_image)
            end

            % definie objects as blobs (N) with matrix (L). No holes
            [~,L,N] = bwboundaries(current_image,'noholes');
            stats = regionprops(L,'Area','Centroid');

            if displayMouse
                figure(hDisp)
                subplot(122)
                imagesc(L)
            end

            counter=0;
            min_area=area_threshold;
            for k = 1:N

                % obtain the area calculation and y centroid corresponding to region 'k'
                area = stats(k).Area;

                % mark objects above the threshold that meet criteria
                if area > min_area
                    min_area=area;
                    centroid = stats(k).Centroid;
                    trace_vector(i,1) = centroid(1);
                    trace_vector(i,2) = centroid(2);
                    counter=1;
                end
            end

            % if a 'blob' was detected (counter=1) write that position to the
            % location matrix (which constantly updates from the previous image)

            % if no blob is detected (counter=0) use the previous position for the
            % location matrix. Note that when writng the location image, the
            % centroid is enlarged by filling in nearby pixels

            location((1:10),(1:10)) = 0;
            
            if counter==1;
                location(((round(trace_vector(i,2))-2):(round(trace_vector(i,2)))+2),((round(trace_vector(i,1)))-2):(round(trace_vector(i,1)))+2)=i;
            elseif i>1
                trace_vector(i,1) = trace_vector(i-1,1);
                trace_vector(i,2) = trace_vector(i-1,2);
            else
                [cornerY, cornerX]=ind2sub(size(BW_ROI), find(BW_ROI==1, 1, 'first'));
                trace_vector(i,1) = cornerY;
                trace_vector(i,2) = cornerX;
            end
            thisX=round(trace_vector(i,1));
            thisY=round(trace_vector(i,2));
            LocationImage(thisY, thisX)=1;
            LocationMovie(thisY+(0:10), thisX+(0:10), i)=1;
        end
        trace_vector(:,1)=trace_vector(:,1)*(SpikeMovieData(movieInd).Xposition(1,2)-SpikeMovieData(movieInd).Xposition(1,1));
        trace_vector(:,2)=trace_vector(:,2)*(SpikeMovieData(movieInd).Yposition(2,1)-SpikeMovieData(movieInd).Yposition(1,1));
        close(hWait)
        if displayMouse
            close(hDisp)
        end
        guidata(gcbo,handles);

        NumberTraces=length(SpikeTraceData);
        if get(handles.Project1D, 'Value')
            cc=bwconncomp(BW_ROI);
            info=regionprops(cc, 'Orientation', 'Area');
            if length(info)>1
                for infoInd=1:length(info)
                    infoAreas(infoInd)=info(infoInd).Area;
                end
                [~, properInd]=max(infoAreas);
                theta=info(properInd).Orientation;
            else
                theta=info.Orientation;
            end
            if theta>-45 && theta<45
                SpikeTraceData(NumberTraces+1).Trace=trace_vector(:,1)'/cos(theta);
            else
                SpikeTraceData(NumberTraces+1).Trace=trace_vector(:,2)'/sin(theta);
            end
            SpikeTraceData(NumberTraces+1).XVector=SpikeMovieData(movieInd).TimeFrame;
            SpikeTraceData(NumberTraces+1).Label.XLabel='Time (s)';
            SpikeTraceData(NumberTraces+1).Label.ListText=['1D position ', SpikeMovieData(movieInd).Label.ListText];
            SpikeTraceData(NumberTraces+1).Label.YLabel=SpikeMovieData(movieInd).Label.YLabel;
        else
            SpikeTraceData(NumberTraces+1).Trace=trace_vector(:,1)';
            SpikeTraceData(NumberTraces+1).XVector=SpikeMovieData(movieInd).TimeFrame;
            SpikeTraceData(NumberTraces+1).Label.XLabel='Time (s)';
            SpikeTraceData(NumberTraces+1).Label.ListText=['X position ', SpikeMovieData(movieInd).Label.ListText];
            SpikeTraceData(NumberTraces+1).Label.YLabel=SpikeMovieData(movieInd).Label.YLabel;
            SpikeTraceData(NumberTraces+2).Trace=trace_vector(:,2)';
            SpikeTraceData(NumberTraces+2).XVector=SpikeMovieData(movieInd).TimeFrame;
            SpikeTraceData(NumberTraces+2).Label.XLabel='Time (s)';
            SpikeTraceData(NumberTraces+2).Label.ListText=['Y position ', SpikeMovieData(movieInd).Label.ListText];
            SpikeTraceData(NumberTraces+2).Label.YLabel='Pixels';
        end

        NumberMovies=length(SpikeMovieData);
        SpikeMovieData(NumberMovies+1)=SpikeMovieData(movieInd);
        SpikeMovieData(NumberMovies+1).Movie=LocationMovie(6:end-5, 6:end-5, :);
        SpikeMovieData(NumberMovies+1).TimePixel=[];
        SpikeMovieData(NumberMovies+1).Label.ListText = ['2D position ', SpikeMovieData(movieInd).Label.ListText];

        NumberImages=length(SpikeImageData);
        SpikeImageData(NumberImages+1).Image=LocationImage;
        SpikeImageData(NumberImages+1).Label.ListText=['2D position ', SpikeMovieData(movieInd).Label.ListText];
        SpikeImageData(NumberImages+1).Label.XLabel=SpikeMovieData(movieInd).Label.XLabel;
        SpikeImageData(NumberImages+1).Label.YLabel=SpikeMovieData(movieInd).Label.YLabel;
    end
    
    close(handles.hLocalFrame);
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
    NumberAxis=get(handles.MovieSelector,'Value');
    CurrentAxe=h(1);
end

localH=findobj(handles.hLocalFrame,'Type','hggroup');
if ~isempty(localH)
    NumberROI=length(localH);
else
    NumberROI=0;
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

LocalMovie=get(handles.MovieDisplayed,'Value');
NewPicData=zeros(SpikeMovieData(LocalMovie).DataSize(1:2) ,'single');

% We do it line by line to reduce memory usage of subfunction and keep
% speed.
dividerWaitbar=10^(floor(log10(SpikeMovieData(LocalMovie).DataSize(1)))-1);

if get(handles.DisplayFrameMode, 'Value')==1
    NewPicData=SpikeMovieData(LocalMovie).Movie(:,:,1);
else
    for j=1:SpikeMovieData(LocalMovie).DataSize(1)
        switch get(handles.DisplayFrameMode,'Value')
            case 1
                NewPicData(j,:)=mean(SpikeMovieData(LocalMovie).Movie(j,:,:),3);
            case 2
                NewPicData(j,:)=max(SpikeMovieData(LocalMovie).Movie(j,:,:),[],3);
            case 3
                for k=1:SpikeMovieData(LocalMovie).DataSize(2)
                    NewPicData(j,k)=std(single(SpikeMovieData(LocalMovie).Movie(j,k,:)),1,3);
                end
        end
        if (round(j/dividerWaitbar)==j/dividerWaitbar)
            waitbar(j/SpikeMovieData(LocalMovie).DataSize(1),h);
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

LocalAxe=gca();
LocalH=imagesc(NewPicData);
set(LocalH,'ButtonDownFcn',{@AddROI_Callback, handles,LocalAxe});

guidata(handles.output,handles);


% --- Executes on selection change in MovieDisplayed.
function MovieDisplayed_Callback(hObject, eventdata, handles)
% hObject    handle to MovieDisplayed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MovieDisplayed contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MovieDisplayed
DisplayROIImage(handles);


% --- Executes during object creation, after setting all properties.
function MovieDisplayed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MovieDisplayed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function AddROI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AddROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function MaxValueToDetect_Callback(hObject, eventdata, handles)
% hObject    handle to MaxValueToDetect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxValueToDetect as text
%        str2double(get(hObject,'String')) returns contents of MaxValueToDetect as a double


% --- Executes during object creation, after setting all properties.
function MaxValueToDetect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxValueToDetect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinAreaToDetect_Callback(hObject, eventdata, handles)
% hObject    handle to MinAreaToDetect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinAreaToDetect as text
%        str2double(get(hObject,'String')) returns contents of MinAreaToDetect as a double


% --- Executes during object creation, after setting all properties.
function MinAreaToDetect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinAreaToDetect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DisplayMouse.
function DisplayMouse_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayMouse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DisplayMouse


% --- Executes on button press in Project1D.
function Project1D_Callback(hObject, eventdata, handles)
% hObject    handle to Project1D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Project1D


% --- Executes on selection change in MovieSelector.
function MovieSel_Callback(hObject, eventdata, handles)
% hObject    handle to MovieSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MovieSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MovieSelector


% --- Executes during object creation, after setting all properties.
function MovieSel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MovieSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
