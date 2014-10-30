function varargout = Frequency_Spectrum(varargin)
% FREQUENCY_SPECTRUM M-file for Frequency_Spectrum.fig
%      FREQUENCY_SPECTRUM, by itself, creates a new FREQUENCY_SPECTRUM or raises the existing
%      singleton*.
%
%      H = FREQUENCY_SPECTRUM returns the handle to a new FREQUENCY_SPECTRUM or the handle to
%      the existing singleton*.
%
%      FREQUENCY_SPECTRUM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FREQUENCY_SPECTRUM.M with the given input arguments.
%
%      FREQUENCY_SPECTRUM('Property','Value',...) creates a new FREQUENCY_SPECTRUM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Frequency_Spectrum_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Frequency_Spectrum_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Frequency_Spectrum

% Last Modified by GUIDE v2.5 22-Feb-2012 07:32:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Frequency_Spectrum_OpeningFcn, ...
                   'gui_OutputFcn',  @Frequency_Spectrum_OutputFcn, ...
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


% --- Executes just before Frequency_Spectrum is made visible.
function Frequency_Spectrum_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Frequency_Spectrum (see VARARGIN)

% Choose default command line output for Frequency_Spectrum
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Frequency_Spectrum wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global SpikeTraceData;

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.TraceSelector,'String',Settings.TraceSelectorString);
    set(handles.TraceSelector,'Value',Settings.TraceSelectorValue);
    set(handles.LogOptions,'Value',Settings.LogOptionsValue);
else
    if ~isempty(SpikeTraceData)
        for i=1:length(SpikeTraceData)
            TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
        end
        set(handles.TraceSelector,'String',TextTrace);
    end
end


% --- Outputs from this function are returned to the command line.
function varargout = Frequency_Spectrum_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorString=get(handles.TraceSelector,'String');
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');
Settings.LogOptionsValue=get(handles.LogOptions,'Value');


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeTraceData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    TraceToApply=get(handles.TraceSelector,'Value');
    
    h=waitbar(0,'Creating frequency spectrum...');
    
    % We get the closest power of 2 for fastest calculation
    NFFT = SpikeTraceData(TraceToApply).DataSize(1);
    
    Spectrum=fft(SpikeTraceData(TraceToApply).Trace,NFFT);
    FrequencySampl=1/mean(diff(double(SpikeTraceData(TraceToApply).XVector)));
    
    FreqAxis=FrequencySampl/NFFT*(1:(floor(NFFT/2)+1));
    delete(h);
    
    if isfield(handles,'hFigImage')
        if (isempty(handles.hFigImage) || ~ishandle(handles.hFigImage))
            handles.hFigImage=figure('Name','Spectrum','NumberTitle','off');
        else
            figure(handles.hFigImage);
        end
    else
        handles.hFigImage=figure('Name','Spectrum','NumberTitle','off');
    end
    
    % Calculate PSD
    % To get the density
    SD=abs(Spectrum)/SpikeTraceData(TraceToApply).DataSize(1);
    
    % FFT is symetric. We only keep half.
    SD=SD(1:(floor(NFFT/2)+1));
    
    % To get the power
    PSD=SD.^2;
    
    % Plot single-sided amplitude spectrum.
    switch get(handles.LogOptions,'Value')
        case 1
            plot(FreqAxis,PSD);
        case 2
            semilogx(FreqAxis,PSD);
        case 3
            semilogy(FreqAxis,PSD);
        case 4
            loglog(FreqAxis,PSD);
    end
    xlabel('Frequency (Hz)');
    ylabel('Power spectral density');
    
    guidata(handles.output,handles);
    
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
if isfield(handles,'hFigImage')
    if (ishandle(handles.hFigImage))
        delete(handles.hFigImage);
    end
end

uiresume;


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

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in LogOptions.
function LogOptions_Callback(hObject, eventdata, handles)
% hObject    handle to LogOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LogOptions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LogOptions


% --- Executes during object creation, after setting all properties.
function LogOptions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LogOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
