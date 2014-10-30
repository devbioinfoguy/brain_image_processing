%%% mostly working, just need to investigate problem with labelling IC
%%% number when saving cell filters/traces...turns 15 into 1, 12 into 1,
%%% etc
%%% then need to remove global variable declarations that shouldn't be
%%% there

function varargout = Select_Cells_From_ICs(varargin)
% SELECT_CELLS_FROM_ICS MATLAB code for Select_Cells_From_ICs.fig
%      SELECT_CELLS_FROM_ICS, by itself, creates a new SELECT_CELLS_FROM_ICS or raises the existing
%      singleton*.
%
%      H = SELECT_CELLS_FROM_ICS returns the handle to a new SELECT_CELLS_FROM_ICS or the handle to
%      the existing singleton*.
%
%      SELECT_CELLS_FROM_ICS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECT_CELLS_FROM_ICS.M with the given input arguments.
%
%      SELECT_CELLS_FROM_ICS('Property','Value',...) creates a new SELECT_CELLS_FROM_ICS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Select_Cells_From_ICs_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Select_Cells_From_ICs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Select_Cells_From_ICs

% Last Modified by GUIDE v2.5 01-Mar-2012 17:36:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Select_Cells_From_ICs_OpeningFcn, ...
                   'gui_OutputFcn',  @Select_Cells_From_ICs_OutputFcn, ...
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


% --- Executes just before Select_Cells_From_ICs is made visible.
function Select_Cells_From_ICs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Select_Cells_From_ICs (see VARARGIN)

global SpikeImageData;

% Choose default command line output for Apply_Filter
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Apply_Filter wait for user response (see UIRESUME)
% uiwait(handles.figure1);
NumImages=length(SpikeImageData);

TextImage={};
if ~isempty(SpikeImageData)
    ICImageInd=0;
    for i=1:NumImages
        if ~isempty(strfind(SpikeImageData(i).Label.ListText, 'IC ' ))
            ICImageInd=ICImageInd+1;
            TextImage{ICImageInd}=[num2str(i),' - ',SpikeImageData(i).Label.ListText];
        end
    end
    set(handles.ImageSelector,'String',TextImage);
end


if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.ImageSelector,'Value',intersect(1:ICImageInd,Settings.ImageSelectorValue));
    set(handles.SelectAllImages,'Value',Settings.SelectAllImageValue);
    set(handles.RemoveBadICs, 'Value', Settings.RemoveBadICsValue);
    set(handles.IncludeICnum, 'Value', Settings.IncludeICnumValue);
end
    
SelectAllImages_Callback(hObject, eventdata, handles);


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.ImageSelectorValue=get(handles.ImageSelector,'Value');
Settings.SelectAllImageValue=get(handles.SelectAllImages,'Value');
Settings.RemoveBadICsValue=get(handles.RemoveBadICs, 'Value');
Settings.IncludeICnumValue=get(handles.IncludeICnum, 'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Select_Cells_From_ICs_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeImageData
global SpikeTraceData

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    % Select both Images and traces to classify, based on input
    % also keep track of what IC number is associated with a Image
    % (in case there are non-IC Images)
    % and make sure Images and traces match (by comparing IC number)
    ICfiltList=get(handles.ImageSelector,'String');
    numICfilts=length(ICfiltList);
    ICfiltNums=zeros(numICfilts,1);
    ICnums=zeros(numICfilts,1);
    TracesToClassify=[];
    FiltersToClassify=[];
    ICsToClassify=[];
    
    
    for i=1:numICfilts
        ICname=ICfiltList{i};
        ICfiltNums(i)=str2double(ICname(1:strfind(ICname, ' - IC ')));
        ICnums(i)=str2double(ICname((strfind(ICname, 'IC ')+3):end));
    end
    if (get(handles.SelectAllImages,'Value')==1)
        FiltersToClassify=ICfiltNums;
        ICsToClassify=ICnums;
    else
        ListInds=get(handles.ImageSelector,'Value');
        FiltersToClassify=ICfiltNums(ListInds);
        ICsToClassify=ICnums(ListInds);
    end
    for i=1:length(SpikeTraceData)
        if ismember('IC ', SpikeTraceData(i).Label.ListText)
            ICname=SpikeTraceData(i).Label.ListText;
            if ismember(str2double(ICname((strfind(ICname, 'IC ')+3):end)), ICsToClassify)
                TracesToClassify(end+1)=i;
            end
        end
    end
    TracesToClassify=TracesToClassify';
    
    % calculated features for all selected ICs
    % uses external feature function, in folder
    if ~isempty(FiltersToClassify)
        h=waitbar(0,'Calculating filter features...');
        features=calcFeatures(FiltersToClassify, TracesToClassify);
        waitbar(1,h)
        delete(h)
        
        % classify, based on features
        h=waitbar(0,'Classifying Filters and saving...');
        load('SVMStruct_cellFind')
        classifications=svmclassify(SVMStruct, features);
        clear SVMStruct
        
        % save cell filters and traces
        % and delete IC filters/traces if user input says to
        waitbar(0.25, h)
        goodFilts=FiltersToClassify(logical(classifications));
        goodTraces=TracesToClassify(logical(classifications));
        goodICs=ICsToClassify(logical(classifications));
        if get(handles.RemoveBadICs, 'Value')
            nonclassifiedFilters=1:length(SpikeImageData);
            nonclassifiedFilters(FiltersToClassify)=[];
            nonclassifiedTraces=1:length(SpikeTraceData);
            nonclassifiedTraces(TracesToClassify)=[];
            SpikeImageData=SpikeImageData([goodFilts' nonclassifiedFilters]);
            SpikeTraceData=SpikeTraceData([goodTraces' nonclassifiedTraces]);
            for i=1:length(goodFilts)
                if get(handles.IncludeICnum, 'Value')
                    SpikeImageData(i).Label.ListText=['Cell ' num2str(i) ' (IC' num2str(goodICs(i)) ')'];
                    SpikeTraceData(i).Label.ListText=['Cell ' num2str(i) ' (IC' num2str(goodICs(i)) ')'];
                else
                    SpikeImageData(i).Label.ListText=['Cell ' num2str(i)];
                    SpikeTraceData(i).Label.ListText=['Cell ' num2str(i)];
                end
            end
            numFilters=length(nonclassifiedFilters);
            numTraces=length(nonclassifiedTraces);
        else
            numFilters=length(SpikeImageData);
            numTraces=length(SpikeTraceData);
            for i=1:length(goodFilts)
                if get(handles.IncludeICnum, 'Value')
                    SpikeImageData(numFilters+i)=SpikeImageData(goodFilts(i));
                    SpikeImageData(numFilters+i).Label.ListText=['Cell ' num2str(i) ' (IC' num2str(goodICs(i)) ')'];
                    SpikeTraceData(numTraces+i)=SpikeTraceData(goodTraces(i));
                    SpikeTraceData(numTraces+i).Label.ListText=['Cell ' num2str(i) ' (IC' num2str(goodICs(i)) ')'];
                else
                    SpikeImageData(numFilters+i)=SpikeImageData(goodFilts(i));
                    SpikeImageData(numFilters+i).Label.ListText=['Cell ' num2str(i)];
                    SpikeTraceData(numTraces+i)=SpikeTraceData(goodTraces(i));
                    SpikeTraceData(numTraces+i).Label.ListText=['Cell ' num2str(i)];
                end
            end
        end
        waitbar(1,h)
        delete(h)
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

% --- Executes on button press in ValidateValues.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Settings=GetSettings(hObject);
uiresume;


% --- Executes on button press in SelectAllImages.
function SelectAllImages_Callback(hObject, eventdata, handles)
% hObject    handle to SelectAllImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SelectAllImages
if (get(handles.SelectAllImages,'Value')==1)
    set(handles.ImageSelector,'Enable','off');
else
    set(handles.ImageSelector,'Enable','on');
end


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

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RemoveBadICs.
function RemoveBadICs_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveBadICs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RemoveBadICs


% --- Executes on button press in IncludeICnum.
function IncludeICnum_Callback(hObject, eventdata, handles)
% hObject    handle to IncludeICnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IncludeICnum



function FiltCropVal_Callback(hObject, eventdata, handles)
% hObject    handle to FiltCropVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FiltCropVal as text
%        str2double(get(hObject,'String')) returns contents of FiltCropVal as a double


% --- Executes during object creation, after setting all properties.
function FiltCropVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FiltCropVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


