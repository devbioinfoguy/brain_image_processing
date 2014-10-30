function varargout = Col_and_Row_Norm_Mask(varargin)
% COL_AND_ROW_NORM_MASK MATLAB code for Col_and_Row_Norm_Mask.fig
%      COL_AND_ROW_NORM_MASK, by itself, creates a new COL_AND_ROW_NORM_MASK or raises the existing
%      singleton*.
%
%      H = COL_AND_ROW_NORM_MASK returns the handle to a new COL_AND_ROW_NORM_MASK or the handle to
%      the existing singleton*.
%
%      COL_AND_ROW_NORM_MASK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COL_AND_ROW_NORM_MASK.M with the given input arguments.
%
%      COL_AND_ROW_NORM_MASK('Property','Value',...) creates a new COL_AND_ROW_NORM_MASK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Col_and_Row_Norm_Mask_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Col_and_Row_Norm_Mask_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
%JESSE MARSHALL NOVEMBER 2012 COPYRIGHT NO COPYING
% Edit the above text to modify the response to help Col_and_Row_Norm_Mask

% Last Modified by GUIDE v2.5 28-Nov-2012 11:40:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Col_and_Row_Norm_Mask_OpeningFcn, ...
                   'gui_OutputFcn',  @Col_and_Row_Norm_Mask_OutputFcn, ...
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


% --- Executes just before Col_and_Row_Norm_Mask is made visible.
function Col_and_Row_Norm_Mask_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Col_and_Row_Norm_Mask (see VARARGIN)
global SpikeMovieData;
global SpikeImageData;

% Choose default command line output for Offset_Time_Movie
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Offset_Time_Movie wait for user response (see UIRESUME)
% uiwait(handles.figure1);
NumberMovies=length(SpikeMovieData);
NumberImages=length(SpikeImageData);

if ~isempty(SpikeMovieData)
    for i=1:NumberMovies
        TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
    end
    set(handles.MovieSelector,'String',TextMovie);
end


if ~isempty(SpikeImageData)
    for i=1:NumberImages
        TextImage{i}=[num2str(i),' - ',SpikeImageData(i).Label.ListText];
    end
    set(handles.ImageSelector,'String',TextImage);
end


if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.MovieSelector,'Value',intersect(1:NumberMovies,Settings.MovieSelectorValue));
        set(handles.ImageSelector,'Value',intersect(1:NumberImages,Settings.ImageSelectorValue));

end
    

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.MovieSelectorString=get(handles.MovieSelector,'String');
Settings.ImageSelectorValue=get(handles.ImageSelector,'Value');
Settings.ImageSelectorString=get(handles.ImageSelector,'String');

% --- Outputs from this function are returned to the command line.
function varargout = Col_and_Row_Norm_Mask_OutputFcn(hObject, eventdata, handles) 
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
uiresume;


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData;
global SpikeImageData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');

    % We turn it back on in the end
    Cleanup1=onCleanup(@()set(InterfaceObj,'Enable','on'));

    h=waitbar(0,'Normalising movie...');
    % We close it in the end
    Cleanup2=onCleanup(@()delete(h));
    
    MovieSel=get(handles.MovieSelector,'Value');
        ImageSel=get(handles.ImageSelector,'Value');

    dividerWaitbar=10^(floor(log10(SpikeMovieData(MovieSel).DataSize(3)))-1);
    
    LocalClass=class(SpikeMovieData(MovieSel).Movie);
    
    if strcmp(LocalClass,'single') || strcmp(LocalClass,'double')
        MaxValue=1/2;
    else
        MaxValue=intmax(LocalClass)/2;
    end
    
    mask_image = SpikeImageData(ImageSel).Image;
    %mask_image = roipoly();
    local_cast = class(SpikeMovieData(MovieSel).Movie);
    
    for i=1:SpikeMovieData(MovieSel).DataSize(3)
        
        data=SpikeMovieData(MovieSel).Movie(:,:,i);
        invert_mask = cast(~logical(mask_image),local_cast);
        
        row_size = cast(sum(invert_mask,1),local_cast);
        column_size = cast(sum(invert_mask,2),local_cast);
        
        data = data.*cast(invert_mask,local_cast);
        
   
        rowmean = cast(round(double(sum(data,1))./double(row_size)),local_cast);
        columnmean = cast(round(double(sum(data,2))./double(column_size)),local_cast);

        meanRows = single(repmat(rowmean,size(data,1),1)); 
        meanCols = single(repmat(columnmean,1,size(data,2)));
        meanRows = meanRows.*meanCols/mean(meanCols(floor(size(data,2)/2),:));
        
        SpikeMovieData(MovieSel).Movie(:,:,i)=cast(single(MaxValue)*single(data)./meanRows,LocalClass);
        
        if (round(i/dividerWaitbar)==i/dividerWaitbar)
            waitbar(i/SpikeMovieData(MovieSel).DataSize(3),h);
        end
    end
    
    ValidateValues_Callback(hObject, eventdata, handles);
    
catch errorObj
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
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


% --- Executes during object creation, after setting all properties.
function ValidateValues_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


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
