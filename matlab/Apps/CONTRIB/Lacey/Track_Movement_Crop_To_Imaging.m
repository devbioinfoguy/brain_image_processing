function varargout = Track_Movement_Crop_To_Imaging(varargin)
% TRACK_MOVEMENT_CROP_TO_IMAGING MATLAB code for Track_Movement_Crop_To_Imaging.fig
%      TRACK_MOVEMENT_CROP_TO_IMAGING, by itself, creates a new TRACK_MOVEMENT_CROP_TO_IMAGING or raises the existing
%      singleton*.
%
%      H = TRACK_MOVEMENT_CROP_TO_IMAGING returns the handle to a new TRACK_MOVEMENT_CROP_TO_IMAGING or the handle to
%      the existing singleton*.
%
%      TRACK_MOVEMENT_CROP_TO_IMAGING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACK_MOVEMENT_CROP_TO_IMAGING.M with the given input arguments.
%
%      TRACK_MOVEMENT_CROP_TO_IMAGING('Property','Value',...) creates a new TRACK_MOVEMENT_CROP_TO_IMAGING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Track_Movement_Crop_To_Imaging_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Track_Movement_Crop_To_Imaging_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Track_Movement_Crop_To_Imaging

% Last Modified by GUIDE v2.5 06-Dec-2012 14:06:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Track_Movement_Crop_To_Imaging_OpeningFcn, ...
                   'gui_OutputFcn',  @Track_Movement_Crop_To_Imaging_OutputFcn, ...
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


% --- Executes just before Track_Movement_Crop_To_Imaging is made visible.
function Track_Movement_Crop_To_Imaging_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Track_Movement_Crop_To_Imaging (see VARARGIN)

% Choose default command line output for Track_Movement_Crop_To_Imaging
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Track_Movement_Crop_To_Imaging wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global SpikeMovieData
global SpikeImageData


if ~isempty(SpikeMovieData)
    for i=1:length(SpikeMovieData)
        TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
    end
    set(handles.MovieSelector,'String',TextMovie);

    set(handles.MovieDisplayed,'String',TextMovie);
    set(handles.MovieDisplayed,'Value',min(1,length(SpikeMovieData)));
end

TextImage{1}='None';
if ~isempty(SpikeImageData)
    for i=1:length(SpikeImageData)
        TextImage{i+1}=[num2str(i),' - ',SpikeImageData(i).Label.ListText];
    end
    set(handles.MaskSelector,'String',TextImage);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.Project1D, 'Value', Settings.Project1DValue);
    set(handles.DisplayFrameMode,'String',Settings.DisplayFrameModeString);
    set(handles.MovieDisplayed,'Value',min(Settings.MoviesDisplayedValue, length(SpikeMovieData)));
    set(handles.MovieSelector,'Value',min(Settings.MovieSelectorValue, length(SpikeMovieData)));
    set(handles.MaxValueToDetect, 'String', Settings.MaxValueToDetectString);
    set(handles.MinAreaToDetect, 'String', Settings.MinAreaToDetectString);
    set(handles.DisplayMouse, 'Value', Settings.DisplayMouseValue);
    set(handles.MaskSelector, 'Value', Settings.MaskSelectorValue);
    set(handles.Rescale, 'Value', Settings.RescaleValue);
    set(handles.CutToImaging, 'Value', Settings.CutToImagingValue);
    set(handles.SelectSubregion, 'Value', Settings.SelectSubregionValue);
end  

%DisplayROIImage(handles);

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.Project1DValue=get(handles.Project1D, 'Value');
Settings.DisplayFrameModeString=get(handles.DisplayFrameMode,'String');
Settings.MoviesDisplayedString=get(handles.MovieDisplayed,'String');
Settings.MoviesDisplayedValue=get(handles.MovieDisplayed,'Value');
Settings.MaxValueToDetectString=get(handles.MaxValueToDetect, 'String');
Settings.MinAreaToDetectString=get(handles.MinAreaToDetect, 'String');
Settings.DisplayMouseValue=get(handles.DisplayMouse, 'Value');
Settings.MaskSelectorValue=get(handles.MaskSelector, 'Value');
Settings.MovieSelectorValue=get(handles.MovieSelector, 'Value');
Settings.RescaleValue=get(handles.Rescale, 'Value');
Settings.CutToImagingValue=get(handles.CutToImaging, 'Value');
Settings.SelectSubregionValue=get(handles.SelectSubregion, 'Value');

% --- Outputs from this function are returned to the command line.
function varargout = Track_Movement_Crop_To_Imaging_OutputFcn(hObject, eventdata, handles) 
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
global BW_ROI
global imagingCutTrace uncutImTrace trace_vector projectedMvmt


try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');

    displayedMovie=get(handles.MovieDisplayed,'Value');
    MovieSel=get(handles.MovieSelector, 'Value');
    displayMouse=get(handles.DisplayMouse, 'Value');
    
    if get(handles.SelectSubregion, 'Value') || get(handles.CutToImaging, 'Value')
        hSelect=figure();
        switch get(handles.DisplayFrameMode, 'Value')
            case 1
                movieLength=size(SpikeMovieData(displayedMovie).Movie,3);
                imageToDisplay=SpikeMovieData(displayedMovie).Movie(:,:,round(movieLength/2));
            case 2
                imageToDisplay=SpikeMovieData(displayedMovie).Movie(:,:,1);
            case 3
                hWaitMean=waitbar('Calculating movie mean to display...');
                imageToDisplay=zeros(size(SpikeMovieData(displayedMovie).Movie(:,:,1)));
                for yInd=1:size(imageToDisplay,1)
                    if mod(yInd, round(size(imageToDisplay,1)/10))==0
                        waitbar(yInd/size(imageToDisplay,1), hWaitMean);
                    end
                    for xInd=1:size(imageToDisplay,1)
                        imageToDisplay(yInd,xInd)=mean(SpikeMovieData(displayedMovie).Movie(yInd,xInd,:));
                    end
                end
                close(hWaitMean)
            case 4
                hWaitMax=waitbar('Calculating movie max to display...');
                imageToDisplay=zeros(size(SpikeMovieData(displayedMovie).Movie(:,:,1)));
                for yInd=1:size(imageToDisplay,1)
                    if mod(yInd, round(size(imageToDisplay,1)/10))==0
                        waitbar(yInd/size(imageToDisplay,1), hWaitMax);
                    end
                    for xInd=1:size(imageToDisplay,1)
                        imageToDisplay(yInd,xInd)=max(SpikeMovieData(displayedMovie).Movie(yInd,xInd,:));
                    end
                end
                close(hWaitMax)
        end
        imagesc(imageToDisplay)
        if get(handles.SelectSubregion, 'Value')
            title('Create polygon to select tracking area. Double-click polygon when finished.')
            BW_ROI=roipoly;
        else
            BW_ROI=ones(size(SpikeMovieData(MovieSel(1)).Movie(:,:,1)));
        end
        if get(handles.CutToImaging, 'Value')
            title('Create ellipse around indicator light.')
            hellipse=imellipse;
            imagingROI=logical(createMask(hellipse));
        end
        close(hSelect)
    else
        BW_ROI=ones(size(SpikeMovieData(MovieSel(1)).Movie(:,:,1)));
    end
    
    maskInd=get(handles.MaskSelector, 'Value')-1;
    if maskInd>0
        BW_ROI=logical(SpikeImageData(maskInd).Image);
    end

        
        
    for movieInd=MovieSel
        % track motion
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
        dividerWaitbar=round(last_frame/10);
        hWait=waitbar(1/20, 'Tracking Movement....');
        for i=1:last_frame;

            if mod(i, dividerWaitbar)==0
                waitbar(i/last_frame, hWait)
            end

            % pick out the current frame
            current_image = double(SpikeMovieData(movieInd).Movie(:,:,i));
            if get(handles.CutToImaging, 'Value')
                if i==1
                    imagingCutTrace=zeros(1,last_frame);
                end
                imagingCutTrace(i)=sum(sum(current_image(imagingROI)));
                if i==last_frame
                    figure()
                    plot(imagingCutTrace/max(imagingCutTrace))
                    hold all
                    uncutImTrace=imagingCutTrace;
                    imagingCutTrace=imagingCutTrace>mean(imagingCutTrace)/2;
                    plot(imagingCutTrace)
                end
            end
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
                trace_vector(i,1) = cornerX;
                trace_vector(i,2) = cornerY;
            end
            thisX=round(trace_vector(i,1));
            thisY=round(trace_vector(i,2));
            LocationImage(thisY, thisX)=1;
            LocationMovie(thisY+(0:10), thisX+(0:10), i)=1;
        end
        trace_vector(i,2)=size(current_image, 1)-trace_vector(i,2);
        
        close(hWait)
        if displayMouse
            close(hDisp)
        end
        guidata(gcbo,handles);

        NumberTraces=length(SpikeTraceData);
        if get(handles.Project1D, 'Value')
            cc=bwconncomp(BW_ROI);
            info=regionprops(cc, 'Orientation', 'Area', 'MajorAxisLength', 'Extrema');
            if length(info)>1
                for infoInd=1:length(info)
                    infoAreas(infoInd)=info(infoInd).Area;
                end
                [~, properInd]=max(infoAreas);
                theta=info(properInd).Orientation;
                %videoScaleLength=info(properInd).MajorAxisLength;
                extrema=info(properInd).Extrema;
            else
                theta=info.Orientation;
                %videoScaleLength=info.MajorAxisLength;
                extrema=info.Extrema;
            end

            if get(handles.Rescale, 'Value')
                xVals=sort(extrema(:,1),'ascend');
                yVals=sort(extrema(:,2),'descend');
                trace_vector(:,1)=trace_vector(:,1)-mean(xVals([1,3]));
                trace_vector(:,2)=trace_vector(:,2)-(size(current_image,1)-mean(yVals([1,3])));
                if theta>-45 && theta<45
                    projectedMvmt=trace_vector(:,1)'/cos(theta*pi/180);
                else
                    projectedMvmt=trace_vector(:,2)'/sin(theta*pi/180);
                end
                trackLength=str2double(get(handles.TrackLength, 'String'));
                xLen=mean(xVals([6,8]))-mean(xVals([1,3]));
                yLen=mean(yVals([1,3]))-mean(yVals([6,8]));
                videoScaleLength=sqrt(yLen^2+xLen^2);
                projectedMvmt=projectedMvmt*trackLength/videoScaleLength;
                %projectedMvmt(projectedMvmt>trackLength)=trackLength;
                %projectedMvmt(projectedMvmt<0)=0;
            else
                if theta>-45 && theta<45
                    projectedMvmt=trace_vector(:,1)'/cos(theta*pi/180);
                else
                    projectedMvmt=trace_vector(:,2)'/sin(theta*pi/180);
                end
            end
               
            SpikeTraceData(NumberTraces+1).Trace=projectedMvmt;
            SpikeTraceData(NumberTraces+1).XVector=SpikeMovieData(movieInd).TimeFrame;
            SpikeTraceData(NumberTraces+1).DataSize=size(SpikeTraceData(NumberTraces+1).Trace);
            SpikeTraceData(NumberTraces+1).Label.XLabel='Time (s)';
            SpikeTraceData(NumberTraces+1).Label.ListText=['1D position ', SpikeMovieData(movieInd).Label.ListText];
            if get(handles.Rescale, 'Value')
                SpikeTraceData(NumberTraces+1).Label.YLabel='cm';
            else
                SpikeTraceData(NumberTraces+1).Label.YLabel=SpikeMovieData(movieInd).Label.YLabel;
            end
            
            if get(handles.CutToImaging, 'Value')
                SpikeTraceData(NumberTraces+2).Trace=projectedMvmt(imagingCutTrace);
                SpikeTraceData(NumberTraces+2).XVector=SpikeMovieData(movieInd).TimeFrame(imagingCutTrace);
                SpikeTraceData(NumberTraces+2).DataSize=size(SpikeTraceData(NumberTraces+2).Trace);
                SpikeTraceData(NumberTraces+2).Label.XLabel='Time (s)';
                SpikeTraceData(NumberTraces+2).Label.ListText=['cut 1D position ', SpikeMovieData(movieInd).Label.ListText];
                if get(handles.Rescale, 'Value')
                    SpikeTraceData(NumberTraces+2).Label.YLabel='cm';
                else
                    SpikeTraceData(NumberTraces+2).Label.YLabel=SpikeMovieData(movieInd).Label.YLabel;
                end
            end


        else
            
            SpikeTraceData(NumberTraces+1).Trace=trace_vector(:,1)';
            SpikeTraceData(NumberTraces+1).XVector=SpikeMovieData(movieInd).TimeFrame;
            SpikeTraceData(NumberTraces+1).DataSize=size(SpikeTraceData(NumberTraces+1).Trace);
            SpikeTraceData(NumberTraces+1).Label.XLabel='Time (s)';
            SpikeTraceData(NumberTraces+1).Label.ListText=['X position ', SpikeMovieData(movieInd).Label.ListText];
            SpikeTraceData(NumberTraces+1).Label.YLabel=SpikeMovieData(movieInd).Label.YLabel;
            SpikeTraceData(NumberTraces+2).Trace=trace_vector(:,2)';
            SpikeTraceData(NumberTraces+2).XVector=SpikeMovieData(movieInd).TimeFrame;
            SpikeTraceData(NumberTraces+2).DataSize=size(SpikeTraceData(NumberTraces+2).Trace);
            SpikeTraceData(NumberTraces+2).Label.XLabel='Time (s)';
            SpikeTraceData(NumberTraces+2).Label.ListText=['Y position ', SpikeMovieData(movieInd).Label.ListText];
            SpikeTraceData(NumberTraces+2).Label.YLabel='Pixels';
            
            if get(handles.CutToImaging, 'Value')
                SpikeTraceData(NumberTraces+3).Trace=trace_vector(imagingCutTrace,1)';
                SpikeTraceData(NumberTraces+3).XVector=SpikeMovieData(movieInd).TimeFrame(imagingCutTrace);
                SpikeTraceData(NumberTraces+3).DataSize=size(SpikeTraceData(NumberTraces+3).Trace);
                SpikeTraceData(NumberTraces+3).Label.XLabel='Time (s)';
                SpikeTraceData(NumberTraces+3).Label.ListText=['X position ', SpikeMovieData(movieInd).Label.ListText];
                SpikeTraceData(NumberTraces+3).Label.YLabel=SpikeMovieData(movieInd).Label.YLabel;
                SpikeTraceData(NumberTraces+4).Trace=trace_vector(imagingCutTrace,2)';
                SpikeTraceData(NumberTraces+4).XVector=SpikeMovieData(movieInd).TimeFrame(imagingCutTrace);
                SpikeTraceData(NumberTraces+4).DataSize=size(SpikeTraceData(NumberTraces+4).Trace);
                SpikeTraceData(NumberTraces+4).Label.XLabel='Time (s)';
                SpikeTraceData(NumberTraces+4).Label.ListText=['Y position ', SpikeMovieData(movieInd).Label.ListText];
                SpikeTraceData(NumberTraces+4).Label.YLabel='Pixels';
            end
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




% --- Executes on selection change in MovieDisplayed.
function MovieDisplayed_Callback(hObject, eventdata, handles)
% hObject    handle to MovieDisplayed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MovieDisplayed contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MovieDisplayed


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

if get(handles.Project1D, 'Value')
    set(handles.Rescale, 'Enable', 'on')
else
    set(handles.Rescale, 'Value', 0)
    set(handles.Rescale, 'Enable', 'off')
end


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



function TrackLength_Callback(hObject, eventdata, handles)
% hObject    handle to TrackLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TrackLength as text
%        str2double(get(hObject,'String')) returns contents of TrackLength as a double


% --- Executes during object creation, after setting all properties.
function TrackLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TrackLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Rescale.
function Rescale_Callback(hObject, eventdata, handles)
% hObject    handle to Rescale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Rescale


% --- Executes on button press in CutToImaging.
function CutToImaging_Callback(hObject, eventdata, handles)
% hObject    handle to CutToImaging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CutToImaging



function MaxTime_Callback(hObject, eventdata, handles)
% hObject    handle to MaxTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxTime as text
%        str2double(get(hObject,'String')) returns contents of MaxTime as a double


% --- Executes during object creation, after setting all properties.
function MaxTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SelectSubregion.
function SelectSubregion_Callback(hObject, eventdata, handles)
% hObject    handle to SelectSubregion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SelectSubregion

if get(handles.Project1D, 'Value')
    set(handles.DisplayFrameMode, 'Enable', 'on')
    set(handles.MovieDisplayed, 'Enable', 'on')
else
    set(handles.DisplayFrameMode, 'Enable', 'off')
    set(handles.MovieDisplayed, 'Enable', 'off')
end


% --- Executes on selection change in MaskSelector.
function MaskSelector_Callback(hObject, eventdata, handles)
% hObject    handle to MaskSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MaskSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MaskSelector


% --- Executes during object creation, after setting all properties.
function MaskSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaskSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
