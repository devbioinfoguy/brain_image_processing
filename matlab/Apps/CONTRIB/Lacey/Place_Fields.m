function varargout = Place_Fields(varargin)
% PLACE_FIELDS 
%
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Place_Fields

% Last Modified by GUIDE v2.5 22-Oct-2012 16:03:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Place_Fields_OpeningFcn, ...
                   'gui_OutputFcn',  @Place_Fields_OutputFcn, ...
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
function Place_Fields_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Place_Fields (see VARARGIN)

% Choose default command line output for Place_Fields
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeTraceData
global SpikeMovieData

if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.TraceSelector,'String',TextTrace);
    set(handles.XPosTraceSelector, 'String', TextTrace);
    set(handles.YPosTraceSelector, 'String', TextTrace);
end

if ~isempty(SpikeMovieData)
    for i=1:length(SpikeMovieData)
        TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
    end
    set(handles.MovieSelector,'String',TextMovie);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.TraceSelector,'Value',Settings.TraceSelectorValue);
    set(handles.XPosTraceSelector,'Value',Settings.XPosTraceSelectorValue);
    set(handles.YPosTraceSelector,'Value',Settings.YPosTraceSelectorValue);
    set(handles.Sigma, 'String', Settings.SigmaString);
    set(handles.MovieSelector,'Value',Settings.MovieSelectorValue);
    set(handles.Calc1DPlaceFields,'Value',Settings.Calc1DPlaceFieldsValue);
    set(handles.EndTime, 'String', Settings.EndTimeString);
    set(handles.BeginTime, 'String', Settings.BeginTimeString);
    set(handles.UsePositiveVelocities, 'Value', Settings.UsePositiveVelocitiesValue);
    set(handles.UsePositiveVelocities, 'Value', Settings.UsePositiveVelocitiesValue);
    set(handles.MinimumVelocityFraction, 'String', Settings.MinimumVelocityFractionString);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorString=get(handles.TraceSelector,'String');
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');
Settings.XPosTraceSelectorValue=get(handles.XPosTraceSelector,'Value');
Settings.YPosTraceSelectorValue=get(handles.YPosTraceSelector,'Value');
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.SigmaString=get(handles.Sigma, 'String');
Settings.Calc1DPlaceFieldsValue=get(handles.Calc1DPlaceFields, 'Value');
Settings.BeginTimeString=get(handles.BeginTime, 'String');
Settings.EndTimeString=get(handles.EndTime, 'String');
Settings.MinimumVelocityFractionString=get(handles.MinimumVelocityFraction, 'String');
Settings.UseNegativeVelocitiesValue=get(handles.UseNegativeVelocities, 'Value');
Settings.UsePositiveVelocitiesValue=get(handles.UsePositiveVelocities, 'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Place_Fields_OutputFcn(hObject, eventdata, handles) 
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

global SpikeTraceData
global SpikeImageData
global SpikeMovieData

try
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    % get parameters from interface
    tracesToProcess=get(handles.TraceSelector, 'Value');
    xTrace=SpikeTraceData(get(handles.XPosTraceSelector, 'Value')).Trace;
    OneDfields=get(handles.Calc1DPlaceFields, 'Value');
    spatialBehav=get(handles.Behavior, 'Value');
    if ~OneDfields
        yTrace=SpikeTraceData(get(handles.YPosTraceSelector, 'Value')).Trace;
    end
    posUnits=SpikeTraceData(get(handles.XPosTraceSelector, 'Value')).Label.YLabel;
    xyTime=SpikeTraceData(get(handles.XPosTraceSelector, 'Value')).XVector;
    sigma=str2double(get(handles.Sigma, 'String'));
    
    beginTime=str2double(get(handles.BeginTime, 'String'));
    endTime=str2double(get(handles.EndTime, 'String'));
    
    if OneDfields
        velocity=[0, diff(xTrace)];
        sortedX=sort(xTrace);
        maxXtrace=sortedX(round(98/100*length(xTrace)));
        minXtrace=sortedX(round(2/100*length(xTrace)));
        xTrace(xTrace>maxXtrace)=maxXtrace;
        xTrace(xTrace<minXtrace)=minXtrace;
        xRange=maxXtrace-minXtrace;
        activeSpikeMap=zeros(length(tracesToProcess), ceil(xRange));
        bigSpikeMap=zeros(size(activeSpikeMap));
        bigSpikeMapNN=zeros(size(activeSpikeMap));
        switch spatialBehav
            case 1
                xMin=min(xTrace)+1/12*xRange;
                xMax=max(xTrace)-1/12*xRange;
                bString='mid';
            case 2
                xMin=min(xTrace)-0.01;
                xMax=min(xTrace)+1/12*xRange;
                bString='end1';
            case 3
                xMin=max(xTrace)-1/12*xRange;
                xMax=max(xTrace)+0.01;
                bString='end2';
            case 4
                xMin=min(xTrace)-0.01;
                xMax=max(xTrace)+0.01;
                bString='allx';
        end
        gWin=fspecial('gaussian', [1, size(activeSpikeMap,2)], sigma);
    else
        velocity=sqrt([0, (diff(xTrace)).^2]+[0, (diff(yTrace)).^2]);
        movieSel=get(handles.MovieSelector,'Value');
        gWin=fspecial('gaussian', size(SpikeMovieData(movieSel).Movie(:,:,1)), sigma);
        gWinNorm=fspecial('gaussian', size(SpikeMovieData(movieSel).Movie(:,:,1)), sigma*3);
    end
    
    v=sort(abs(velocity), 'ascend');
    maxVel=v(round(99/100*length(v)));
    velocityThresh=str2double(get(handles.MinimumVelocityFraction, 'String'))*maxVel;
    vString=['v', get(handles.MinimumVelocityFraction, 'String')];
    
    usePos=get(handles.UsePositiveVelocities, 'Value');
    useNeg=get(handles.UseNegativeVelocities, 'Value');
    
    NumberImages=length(SpikeImageData);
    NumberTraces=length(SpikeTraceData);
    activeInd=0;
    activeSpikeInds=[];
    
    if usePos && useNeg
        vString2='allv';
    elseif usePos
        vString2='v>0';
    elseif useNeg
        vString2='v<0';
    end
    
    if ~OneDfields
        normalizingImage=zeros(size(SpikeMovieData(movieSel).Movie(:,:,1)));
        for timeInd=1:length(xTrace)
            normalizingImage(ceil(yTrace(timeInd)), ceil(xTrace(timeInd)))=...
                normalizingImage(ceil(yTrace(timeInd)), ceil(xTrace(timeInd)))+1;
        end
    end
    
    for trInd=1:length(tracesToProcess)
        thisTraceInd=tracesToProcess(trInd);
        thisTrace=SpikeTraceData(thisTraceInd).Trace;
        thisXVector=SpikeTraceData(thisTraceInd).XVector;
        if size(thisXVector,1)>1
            thisXVector=thisXVector';
        end
        if OneDfields
            thisSpikeLine=zeros(1, size(activeSpikeMap,2));
        else
            movieSel=get(handles.MovieSelector, 'Value');
            thisSpikeImage=zeros(size(SpikeMovieData(movieSel).Movie(:,:,1)));
        end
        if max(thisTrace)>1
            error('Use binary event traces!')
        end

        if sum(thisTrace)>0
            for spikeTime=thisXVector(logical(thisTrace))
                if spikeTime<endTime && spikeTime>=beginTime
                    [~, thisConvertedInd]=min(abs(xyTime-spikeTime));
                    velAbsCorrect=abs(velocity(thisConvertedInd))>velocityThresh;
                    if spatialBehav==4
                        xCorrect=1;
                    else
                        xCorrect=xTrace(thisConvertedInd)<=xMax && xTrace(thisConvertedInd)>=xMin;
                    end
                    if usePos && useNeg
                        velValueCorrect=1;
                    elseif usePos
                        velValueCorrect=velocity(thisConvertedInd)>0;
                    elseif useNeg
                        velValueCorrect=velocity(thisConvertedInd)<0;
                    end
                    if OneDfields && velAbsCorrect  && xCorrect && velValueCorrect 
                        thisSpikeLine(ceil(xTrace(thisConvertedInd)-min(xTrace)+0.01))=...
                            thisSpikeLine(ceil(xTrace(thisConvertedInd)-min(xTrace)+0.01))+1;
                    elseif ~OneDfields && velAbsCorrect
                        thisSpikeImage(ceil(yTrace(thisConvertedInd)), ceil(xTrace(thisConvertedInd)))=...
                            thisSpikeImage(ceil(yTrace(thisConvertedInd)), ceil(xTrace(thisConvertedInd)))+1;
                    end
                end
            end
        end
        
        if OneDfields
            adjustedSpikeLine=conv(thisSpikeLine, gWin, 'same');
            thisMax=max(adjustedSpikeLine);
            if thisMax>0
                adjustedSpikeLine=adjustedSpikeLine/thisMax;
            end
            bigSpikeMap(trInd,:)=adjustedSpikeLine;
            bigSpikeMapNN(trInd,:)=conv(thisSpikeLine, gWin, 'same');
        end
            
        if OneDfields && sum(thisSpikeLine)>3
            activeInd=activeInd+1;
            activeSpikeMap(activeInd,:)=adjustedSpikeLine;
            activeSpikeInds(end+1)=trInd;
        elseif ~OneDfields && sum(sum(thisSpikeImage))>3
            activeInd=activeInd+1;
            SpikeImageData(NumberImages+activeInd).Image=conv2(thisSpikeImage, gWin, 'same')./conv2(normalizingImage, gWinNorm, 'same');
            SpikeImageData(NumberImages+activeInd).Label.ListText=['spike map ' SpikeTraceData(thisTraceInd).Label.ListText];
            SpikeImageData(NumberImages+activeInd).Label.YLabel=posUnits;
            SpikeImageData(NumberImages+activeInd).Label.XLabel=posUnits;
        end
    end
    global sortedInds
    if OneDfields
        activeSpikeMap=activeSpikeMap(1:activeInd,:);
        activeSpikeMap(sum(activeSpikeMap,2)==0,:)=[];
        
        xInds=repmat(1:size(activeSpikeMap,2), size(activeSpikeMap,1),1);
        centroids=sum(activeSpikeMap.*xInds,2)./sum(activeSpikeMap,2);
        [~,maxLocs]=max(activeSpikeMap');
        [~, sortedInds]=sort(centroids);
        [sortedLocs, sortedInds]=sort(maxLocs);
        activeSpikeInds=activeSpikeInds(sortedInds);
        activeSpikeLocs=sortedLocs;
        SpikeImageData(NumberImages+1).Image=activeSpikeMap(sortedInds,:);
        SpikeImageData(NumberImages+1).Label.ListText=[bString,  ' ',vString, ' ', vString2, ' ','spike map active cells'];
        SpikeImageData(NumberImages+1).Label.YLabel='cell';
        SpikeImageData(NumberImages+1).Label.XLabel=posUnits;
        
        SpikeImageData(NumberImages+2).Image=bigSpikeMap;
        SpikeImageData(NumberImages+2).Label.ListText=[bString, ' ', vString, ' ', vString2, ' ','spike map all cells'];
        SpikeImageData(NumberImages+2).Label.YLabel='cell';
        SpikeImageData(NumberImages+2).Label.XLabel=posUnits;
        
        SpikeImageData(NumberImages+3).Image=bigSpikeMapNN;
        SpikeImageData(NumberImages+3).Label.ListText=[bString, ' ', vString, ' ', vString2, ' ','nonnorm spike map all cells'];
        SpikeImageData(NumberImages+3).Label.YLabel='cell';
        SpikeImageData(NumberImages+3).Label.XLabel=posUnits;
        
        SpikeTraceData(NumberTraces+1).Trace=activeSpikeInds;
        SpikeTraceData(NumberTraces+1).XVector=1:length(activeSpikeInds);
        SpikeTraceData(NumberTraces+1).Label.ListText=[bString,  ' ',vString, ' ', vString2,  ' ','active spike inds'];
        SpikeTraceData(NumberTraces+1).Label.XLabel='number cell';
        SpikeTraceData(NumberTraces+1).Label.YLabel='active spike ind';
        SpikeTraceData(NumberTraces+1).DataSize=size(activeSpikeInds);
        
        SpikeTraceData(NumberTraces+2).Trace=activeSpikeLocs;
        SpikeTraceData(NumberTraces+2).XVector=1:length(activeSpikeLocs);
        SpikeTraceData(NumberTraces+2).Label.ListText=[bString, ' ', vString,  ' ',vString2, ' ','active spike locs'];
        SpikeTraceData(NumberTraces+2).Label.XLabel='number cell';
        SpikeTraceData(NumberTraces+2).Label.YLabel='place field location';
        SpikeTraceData(NumberTraces+2).DataSize=size(activeSpikeLocs);
    end
    
    
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



% --- Executes on selection change in TraceSelector.
function TraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to TraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TraceSelector


% --- Executes during object creation, after setting all properties.
function TraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in XPosTraceSelector.
function XPosTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to XPosTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns XPosTraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from XPosTraceSelector


% --- Executes during object creation, after setting all properties.
function XPosTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XPosTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Sigma_Callback(hObject, eventdata, handles)
% hObject    handle to Sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Sigma as text
%        str2double(get(hObject,'String')) returns contents of Sigma as a double


% --- Executes during object creation, after setting all properties.
function Sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in YPosTraceSelector.
function YPosTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to YPosTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns YPosTraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from YPosTraceSelector


% --- Executes during object creation, after setting all properties.
function YPosTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YPosTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Calc1DPlaceFields.
function Calc1DPlaceFields_Callback(hObject, eventdata, handles)
% hObject    handle to Calc1DPlaceFields (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Calc1DPlaceFields
if (get(handles.Calc1DPlaceFields,'Value')==1)
    set(handles.YPosTraceSelector,'Enable','off');
    set(handles.MovieSelector,'Enable','off');
else
    set(handles.YPosTraceSelector,'Enable','on');
    set(handles.MovieSelector,'Enable','on');
end



function BeginTime_Callback(hObject, eventdata, handles)
% hObject    handle to BeginTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BeginTime as text
%        str2double(get(hObject,'String')) returns contents of BeginTime as a double


% --- Executes during object creation, after setting all properties.
function BeginTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BeginTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EndTime_Callback(hObject, eventdata, handles)
% hObject    handle to EndTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EndTime as text
%        str2double(get(hObject,'String')) returns contents of EndTime as a double


% --- Executes during object creation, after setting all properties.
function EndTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EndTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in UsePositiveVelocities.
function UsePositiveVelocities_Callback(hObject, eventdata, handles)
% hObject    handle to UsePositiveVelocities (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UsePositiveVelocities


% --- Executes on button press in UseNegativeVelocities.
function UseNegativeVelocities_Callback(hObject, eventdata, handles)
% hObject    handle to UseNegativeVelocities (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UseNegativeVelocities



function MinimumVelocityFraction_Callback(hObject, eventdata, handles)
% hObject    handle to MinimumVelocityFraction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinimumVelocityFraction as text
%        str2double(get(hObject,'String')) returns contents of MinimumVelocityFraction as a double


% --- Executes during object creation, after setting all properties.
function MinimumVelocityFraction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinimumVelocityFraction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Behavior.
function Behavior_Callback(hObject, eventdata, handles)
% hObject    handle to Behavior (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Behavior contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Behavior


% --- Executes during object creation, after setting all properties.
function Behavior_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Behavior (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
