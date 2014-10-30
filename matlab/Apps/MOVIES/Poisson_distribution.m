function varargout = Poisson_distribution(varargin)
% POISSON_DISTRIBUTION MATLAB code for Poisson_distribution.fig
%      POISSON_DISTRIBUTION, by itself, creates a new POISSON_DISTRIBUTION or raises the existing
%      singleton*.
%
%      H = POISSON_DISTRIBUTION returns the handle to a new POISSON_DISTRIBUTION or the handle to
%      the existing singleton*.
%
%      POISSON_DISTRIBUTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POISSON_DISTRIBUTION.M with the given input arguments.
%
%      POISSON_DISTRIBUTION('Property','Value',...) creates a new POISSON_DISTRIBUTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Poisson_distribution_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Poisson_distribution_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help Poisson_distribution

% Last Modified by GUIDE v2.5 05-Mar-2012 00:17:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Poisson_distribution_OpeningFcn, ...
                   'gui_OutputFcn',  @Poisson_distribution_OutputFcn, ...
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


% --- Executes just before Poisson_distribution is made visible.
function Poisson_distribution_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Poisson_distribution (see VARARGIN)

% Choose default command line output for Poisson_distribution
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Poisson_distribution wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global SpikeMovieData;

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.MovieSelector,'Value',Settings.MovieSelectorValue);
    set(handles.MovieSelector,'String',Settings.MovieSelectorString);
    set(handles.GainExtract,'Value',Settings.GainExtractValue);
    set(handles.NbPhotonsCorrect,'Value',Settings.NbPhotonsCorrectValue);
    set(handles.FromGain,'String',Settings.FromGainString);
    set(handles.ToGain,'String',Settings.ToGainString);
else
    if ~isempty(SpikeMovieData)
        for i=1:length(SpikeMovieData)
            TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
        end
        set(handles.MovieSelector,'String',TextMovie);
    end
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.MovieSelectorString=get(handles.MovieSelector,'String');
Settings.GainExtractValue=get(handles.GainExtract,'Value');
Settings.NbPhotonsCorrectValue=get(handles.NbPhotonsCorrect,'Value');
Settings.FromGainString=get(handles.FromGain,'String');
Settings.ToGainString=get(handles.ToGain,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Poisson_distribution_OutputFcn(hObject, eventdata, handles) 
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
if isfield(handles,'hFigImage')
    if (ishandle(handles.hFigImage))
        delete(handles.hFigImage);
    end
end
uiresume;


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    DisplayPoisson();
    set(InterfaceObj,'Enable','on');
    
catch errorObj
    set(InterfaceObj,'Enable','on');
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

% function to display the current hist on a figure
function DisplayPoisson()
global SpikeMovieData;

handles=guidata(gcbo);

CurrentMovie=get(handles.MovieSelector,'Value');

dividerWaitbar=10^(floor(log10(SpikeMovieData(CurrentMovie).DataSize(1)))-1);

h=waitbar(0,'Computing Poisson distribution...');

MeanData=zeros(SpikeMovieData(CurrentMovie).DataSize(1),...
    SpikeMovieData(CurrentMovie).DataSize(2),class(SpikeMovieData(CurrentMovie).Movie));
VarData=zeros(SpikeMovieData(CurrentMovie).DataSize(1),...
    SpikeMovieData(CurrentMovie).DataSize(2),'single');

% We scan movie to avoid reallocating a large matrix on single precision
for i=1:SpikeMovieData(CurrentMovie).DataSize(1)
    MeanData(i,:)=mean(SpikeMovieData(CurrentMovie).Movie(i,:,:),3);
    VarData(i,:)=var(single(SpikeMovieData(CurrentMovie).Movie(i,:,:)),0,3);
    
    if (round(i/dividerWaitbar)==i/dividerWaitbar)
        waitbar(i/SpikeMovieData(CurrentMovie).DataSize(1),h);
    end
end

delete(h);
if isfield(handles,'hFigImage')
    if (isempty(handles.hFigImage) || ~ishandle(handles.hFigImage))
        handles.hFigImage=figure('Name','Poisson distribution','NumberTitle','off');
    else
        figure(handles.hFigImage);
    end
else
    handles.hFigImage=figure('Name','Poisson distribution','NumberTitle','off');
end

plot(MeanData(:),VarData(:),'b.');
xlabel('Mean (au)');
ylabel('Variance (au)');

if get(handles.GainExtract,'Value')==1
    hold on;
    maxValue=max(MeanData(:));
    MinInterv=str2num(get(handles.FromGain,'String'));
    MaxInterv=str2num(get(handles.ToGain,'String'));

    I=find((MeanData(:))>(MinInterv) & (MeanData(:))<(MaxInterv));
    Poly=polyfit(MeanData(I),VarData(I),1);
    NewX=(MinInterv):(0.1*maxValue/100):(MaxInterv);
    NewY=polyval(Poly,NewX);
    set(handles.EquationResult,'String',['Var=' num2str(Poly(1)) '*Mean+' num2str(Poly(2))]);
    plot(NewX,NewY,'r-');
    hold off;
    if get(handles.NbPhotonsCorrect,'Value')==1
        if (0==strcmp(class(SpikeMovieData(CurrentMovie).Movie),'single'))
            h=waitbar(0,'Converting movie to single precision');
            % Since we are making division, we need to move to single precision, even
            % if that cost much larger amount of memory
            SpikeMovieData(CurrentMovie).Movie=single(SpikeMovieData(CurrentMovie).Movie);
            delete(h);
        end
        MeanZero=-Poly(2)/Poly(1);
        SpikeMovieData(CurrentMovie).Movie=(SpikeMovieData(CurrentMovie).Movie-MeanZero)/Poly(1);
    end
end
guidata(gcbo,handles);


% --- Executes on button press in GainExtract.
function GainExtract_Callback(hObject, eventdata, handles)
% hObject    handle to GainExtract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GainExtract


% --- Executes on button press in NbPhotonsCorrect.
function NbPhotonsCorrect_Callback(hObject, eventdata, handles)
% hObject    handle to NbPhotonsCorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NbPhotonsCorrect



function FromGain_Callback(hObject, eventdata, handles)
% hObject    handle to FromGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FromGain as text
%        str2double(get(hObject,'String')) returns contents of FromGain as a double


% --- Executes during object creation, after setting all properties.
function FromGain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FromGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ToGain_Callback(hObject, eventdata, handles)
% hObject    handle to ToGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ToGain as text
%        str2double(get(hObject,'String')) returns contents of ToGain as a double


% --- Executes during object creation, after setting all properties.
function ToGain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ToGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
