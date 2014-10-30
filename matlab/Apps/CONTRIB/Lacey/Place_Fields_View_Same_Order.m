function varargout = Place_Fields_View_Same_Order(varargin)
% PLACE_FIELDS_VIEW_SAME_ORDER 
%
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Place_Fields_View_Same_Order

% Last Modified by GUIDE v2.5 14-Jan-2013 17:12:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Place_Fields_View_Same_Order_OpeningFcn, ...
                   'gui_OutputFcn',  @Place_Fields_View_Same_Order_OutputFcn, ...
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
function Place_Fields_View_Same_Order_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Place_Fields_View_Same_Order (see VARARGIN)

% Choose default command line output for Place_Fields_View_Same_Order
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeTraceData
global SpikeImageData

if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.ActiveIndsTraceSelector, 'String', TextTrace);
end

if ~isempty(SpikeImageData)
    for i=1:length(SpikeImageData)
        TextImage{i}=[num2str(i),' - ',SpikeImageData(i).Label.ListText];
    end
    set(handles.SpikeMapImageSelector,'String',TextImage);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.SpikeMapImageSelector,'Value',Settings.TraceSelectorValue);
    set(handles.ActiveIndsTraceSelector,'Value',Settings.XPosTraceSelectorValue);
    set(handles.SortIndex, 'String', Settings.SigmaString);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorValue=get(handles.SpikeMapImageSelector,'Value');
Settings.XPosTraceSelectorValue=get(handles.ActiveIndsTraceSelector,'Value');
Settings.SigmaString=get(handles.SortIndex, 'String');



% --- Outputs from this function are returned to the command line.
function varargout = Place_Fields_View_Same_Order_OutputFcn(hObject, eventdata, handles) 
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

try
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    % get parameters from interface
    activeIndsTraces=get(handles.ActiveIndsTraceSelector, 'Value');
    spikeMapsImages=get(handles.SpikeMapImageSelector, 'Value');
    sortInd=str2double(get(handles.SortIndex, 'String'));
    
    if length(activeIndsTraces)~=length(spikeMapsImages)
        error('Select same number of traces and images!')
    end
    numMaps=length(activeIndsTraces);
    
    mainActiveSpikeInds=SpikeTraceData(activeIndsTraces(sortInd)).Trace;
    keepNormSame=get(handles.KeepNormSame, 'Value');
    
    if keepNormSame
        mainMap=SpikeImageData(spikeMapsImages(sortInd)).Image;
        mainMap=mainMap(mainActiveSpikeInds,:);
        mainMaxes=max(mainMap,2);
        mainMaxes=mainMaxes(ones(size(mainMap,2)),:)';
    end
    
    figh=figure();
    subplot(1,numMaps,1);
    for mapInd=1:numMaps
        imageInd=spikeMapsImages(mapInd);
        traceInd=activeIndsTraces(mapInd);
        thisMap=SpikeImageData(imageInd).Image;
        theseActiveInds=SpikeTraceData(traceInd).Trace;
        inactiveInd=find(sum(thisMap, 2)==0, 1);
        activeInds=mainActiveSpikeInds;
        for i=1:length(activeInds)
            if ~ismember(activeInds(i), theseActiveInds)
                activeInds(i)=inactiveInd;
            end
        end
        thisMap=thisMap(activeInds,:);
        if keepNormSame
            thisMap=thisMap./mainMaxes;
        end
        figure(figh)
        subplot(1,numMaps,mapInd)
        imagesc(thisMap)
        colormap(jet)
        if mapInd~=sortInd
            mainMap=SpikeImageData(spikeMapsImages(sortInd)).Image;
            mainMap=mainMap(mainActiveSpikeInds,:);
            thisCorr=corrcoef(thisMap(:), mainMap(:));
            thisCorr=thisCorr(1,2);
            mainMap=mainMap(sum(thisMap,2)==0, :);
            thisMap=thisMap(sum(thisMap,2)==0, :);
            thisCorrActive=corrcoef(thisMap(:), mainMap(:));
            thisCorrActive=thisCorrActive(1,2);
            title(['R = ' num2str(thisCorr), ' active R = ' num2str(thisCorrActive)]);
            
            allCorrs=zeros(1,size(thisMap,1));
            for cellInd=1:size(thisMap,1)
                thisCorr=corrcoef(thisMap(cellInd,:), mainMap(cellInd,:));
                allCorrs(cellInd)=thisCorr(1,2);
            end
            
            numTraces=length(SpikeTraceData);
            SpikeTraceData(numTraces+1).Trace=allCorrs;
            SpikeTraceData(numTraces+1).XVector=1:length(allCorrs);
            SpikeTraceData(numTraces+1).Label.XLabel='cell number';
            SpikeTraceData(numTraces+1).Label.YLabel='correlation';
            SpikeTraceData(numTraces+1).Label.ListText=['place field correlations ',...
                SpikeImageData(spikeMapsImages(mapInd)).Label.ListText,...
                SpikeImageData(spikeMapsImages(sortInd)).Label.ListText];
        end
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



% --- Executes on selection change in SpikeMapImageSelector.
function SpikeMapImageSelector_Callback(hObject, eventdata, handles)
% hObject    handle to SpikeMapImageSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SpikeMapImageSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SpikeMapImageSelector


% --- Executes during object creation, after setting all properties.
function SpikeMapImageSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpikeMapImageSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in ActiveIndsTraceSelector.
function ActiveIndsTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to ActiveIndsTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ActiveIndsTraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ActiveIndsTraceSelector


% --- Executes during object creation, after setting all properties.
function ActiveIndsTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ActiveIndsTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SortIndex_Callback(hObject, eventdata, handles)
% hObject    handle to SortIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SortIndex as text
%        str2double(get(hObject,'String')) returns contents of SortIndex as a double


% --- Executes during object creation, after setting all properties.
function SortIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SortIndex (see GCBO)
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


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6


% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in KeepNormSame.
function KeepNormSame_Callback(hObject, eventdata, handles)
% hObject    handle to KeepNormSame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KeepNormSame
