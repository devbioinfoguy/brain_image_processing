function varargout = PCA_Movie(varargin)
% PCA_MOVIE MATLAB code for PCA_Movie.fig
%      PCA_MOVIE, by itself, creates a new PCA_MOVIE or raises the existing
%      singleton*.
%
%      H = PCA_MOVIE returns the handle to a new PCA_MOVIE or the handle to
%      the existing singleton*.
%
%      PCA_MOVIE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PCA_MOVIE.M with the given input arguments.
%
%      PCA_MOVIE('Property','Value',...) creates a new PCA_MOVIE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PCA_Movie_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PCA_Movie_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2011

% Edit the above text to modify the response to help PCA_Movie

% Last Modified by GUIDE v2.5 05-Mar-2012 00:16:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PCA_Movie_OpeningFcn, ...
    'gui_OutputFcn',  @PCA_Movie_OutputFcn, ...
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


% --- Executes just before PCA_Movie is made visible.
function PCA_Movie_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PCA_Movie (see VARARGIN)
global SpikeMovieData;

% Choose default command line output for PCA_Movie
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PCA_Movie wait for user response (see UIRESUME)
% uiwait(handles.figure1);
NumberMovies=length(SpikeMovieData);

if ~isempty(SpikeMovieData)
    for i=1:length(SpikeMovieData)
        TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
    end
    set(handles.MovieSelector,'String',TextMovie);
end
    
if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.MovieSelector,'Value',intersect(1:NumberMovies,Settings.MovieSelectorValue));
    set(handles.NbOutputPCs,'String',Settings.NbOutputPCsString);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.NbOutputPCsString=get(handles.NbOutputPCs,'String');


% --- Outputs from this function are returned to the command line.
function varargout = PCA_Movie_OutputFcn(hObject, eventdata, handles)
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

uiresume;


% This function calculate the PCA from the global data
function [PcaFilters,PcaTraces,CovEvals]=PcaCalculation(nPCs,MovieSel)
global SpikeMovieData;

h=waitbar(0,'Performing PCA');
OldClass=class(SpikeMovieData(MovieSel).Movie);

% We convert the movie to single for the calculation
SpikeMovieData(MovieSel).Movie=double(SpikeMovieData(MovieSel).Movie);

% Create covariance matrix in the time domain as it is computationaly more
% advantageous than in space and mathematically equivalent.
SpikeMovieData(MovieSel).DataSize=size(SpikeMovieData(MovieSel).Movie);
Npixels=SpikeMovieData(MovieSel).DataSize(1)*SpikeMovieData(MovieSel).DataSize(2);
Ntime=SpikeMovieData(MovieSel).DataSize(3);

SpikeMovieData(MovieSel).Movie = reshape(SpikeMovieData(MovieSel).Movie, Npixels, Ntime);

% C1 = ((SpikeMovieData(MovieSel).Movie)'*SpikeMovieData(MovieSel).Movie)/Npixels;
% Movtm = mean(SpikeMovieData(MovieSel).Movie,1); % Average over space
% covmat = double(C1 - Movtm'*Movtm);

covmat=double(cov(SpikeMovieData(MovieSel).Movie));

% This is the covariance matrix.
waitbar(1/3,h);

% Options for the Eigenvectors extraction
opts.issym = 'true';
        
if nPCs<size(covmat,1)
    [PcaTraces, CovEvals] = eigs(covmat, nPCs, 'LM', opts); 
else
    [PcaTraces, CovEvals] = eig(covmat);
    nPCs = size(CovEvals,1);
end

% At this stage PcaTraces is Ntime x nPCs, ie each column is an eigenvector
% CovEvals is a square diagonal matrix with the eigenvalues on the diagonal

% We only keep the diagonal values, ie we no longer have a diagonal matrix
waitbar(2/3,h);

% Throwing out negative eigenvalues
CovEvals=diag(CovEvals);
if nnz(CovEvals<=0)
    nPCs=nPCs - nnz(CovEvals<=0);
    PcaTraces = PcaTraces(:,CovEvals>0);
    CovEvals = CovEvals(CovEvals>0);
end
[CovEvals, indices]=sort(CovEvals, 'descend');
PcaTraces=PcaTraces(:,indices);
CovEvals=diag(CovEvals);

% This is to ensure that PcaFilters has variance 1
CovEvals=CovEvals*Npixels;

% This is to calculate the PcaFilters. We need to get the eigenvalues of
% the Movie, not of the covariance matrix. This is the reason for 1/2
% power.
Sinv = inv(CovEvals.^(1/2));

% We calculate the corresponding space filters 
PcaFilters = double(SpikeMovieData(MovieSel).Movie*PcaTraces*Sinv);

% Now because the Filters are not an EXACT calculation, their variance can
% be slighlty off 1. We make sure it is 1, as this can slightly affect the 
% spatio-temporal ICA that expect normalize eigenvectors.
for i=1:nPCs
    PcaFilters(:,i)=PcaFilters(:,i)/norm(PcaFilters(:,i));
end

% We reshape back data in SpikeMovieData
SpikeMovieData(MovieSel).Movie=cast(SpikeMovieData(MovieSel).Movie,OldClass);
SpikeMovieData(MovieSel).Movie = reshape(SpikeMovieData(MovieSel).Movie, SpikeMovieData(MovieSel).DataSize(1),SpikeMovieData(MovieSel).DataSize(2), Ntime);
delete(h);


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
    
    % We turn it back on in the end
    Cleanup1=onCleanup(@()set(InterfaceObj,'Enable','on'));

    MovieSel=get(handles.MovieSelector,'Value');
    
    % Number of Principal Components we extract for dimensionality reduction
    nPCs=str2num(get(handles.NbOutputPCs,'String'));
    
    % Check that the number of PCs is fewer than the number of frames
    if nPCs>SpikeMovieData(MovieSel).DataSize(3)
        error('Number of PCs must be less than number of frames in movie')
    end
    
    % subtract mean of each frame
    for fr=1:size(SpikeMovieData(MovieSel).Movie,3)
        thisFrame=SpikeMovieData(MovieSel).Movie(:,:,fr);
        SpikeMovieData(MovieSel).Movie(:,:,fr)=thisFrame-mean(thisFrame(:));
    end
    
    % Do the PCA calculation
    [PcaFilters,PcaTraces,CovEvals]=PcaCalculation(nPCs,MovieSel);
    
    % Adjust nPCs
    nPCs = size(CovEvals,1);

    % Reshape the filter to have a proper image
    PcaFilters = reshape(PcaFilters,SpikeMovieData(MovieSel).DataSize(1),SpikeMovieData(MovieSel).DataSize(2),nPCs);
    
    h=waitbar(0,'Exporting result to Images and Traces');
    dividerWaitbar=10^(floor(log10(nPCs))-1);
    
    % We close it in the end
    Cleanup2=onCleanup(@()delete(h));
        
    CurrentNumberTrace=length(SpikeTraceData);
    CurrentNumberFilter=length(SpikeImageData);
    
    for i=1:nPCs
        
        if isempty(SpikeTraceData)
            InitTraces();
        end
        SpikeTraceData(CurrentNumberTrace+i).XVector=SpikeMovieData(MovieSel).TimeFrame;
        SpikeTraceData(CurrentNumberTrace+i).Trace=PcaTraces(:,i);
        SpikeTraceData(CurrentNumberTrace+i).DataSize=size(SpikeTraceData(CurrentNumberTrace+i).Trace);
        SpikeTraceData(CurrentNumberTrace+i).Label.YLabel='Units of standard deviation';
        SpikeTraceData(CurrentNumberTrace+i).Filename=SpikeMovieData(MovieSel).Filename;
        SpikeTraceData(CurrentNumberTrace+i).Path=SpikeMovieData(MovieSel).Path;
        SpikeTraceData(CurrentNumberTrace+i).Label.ListText=['PC ',num2str(i)];
        SpikeTraceData(CurrentNumberTrace+i).Label.XLabel='Time (s)';
        
        if isempty(SpikeImageData)
            InitImages();
        end
        
        SpikeImageData(CurrentNumberFilter+i).Image=squeeze(PcaFilters(:,:,i));
        SpikeImageData(CurrentNumberFilter+i).DataSize=size(SpikeImageData(CurrentNumberFilter+i).Image);
        SpikeImageData(CurrentNumberFilter+i).Label.CLabel='Units of standard deviation';
        SpikeImageData(CurrentNumberFilter+i).Label.XLabel=SpikeMovieData(MovieSel).Label.XLabel;
        SpikeImageData(CurrentNumberFilter+i).Label.YLabel=SpikeMovieData(MovieSel).Label.YLabel;
        SpikeImageData(CurrentNumberFilter+i).Label.ZLabel=SpikeMovieData(MovieSel).Label.ZLabel;
        SpikeImageData(CurrentNumberFilter+i).Xposition=SpikeMovieData(MovieSel).Xposition;
        SpikeImageData(CurrentNumberFilter+i).Yposition=SpikeMovieData(MovieSel).Yposition;
        SpikeImageData(CurrentNumberFilter+i).Zposition=SpikeMovieData(MovieSel).Zposition;
        SpikeImageData(CurrentNumberFilter+i).Filename=SpikeMovieData(MovieSel).Filename;
        SpikeImageData(CurrentNumberFilter+i).Path=SpikeMovieData(MovieSel).Path;
        SpikeImageData(CurrentNumberFilter+i).Label.ListText=['PC ',num2str(i)];
        
        if (round(i/dividerWaitbar)==i/dividerWaitbar)
            waitbar(i/nPCs,h);
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


function NbOutputPCs_Callback(hObject, eventdata, handles)
% hObject    handle to NbOutputPCs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NbOutputPCs as text
%        str2double(get(hObject,'String')) returns contents of NbOutputPCs as a double


% --- Executes during object creation, after setting all properties.
function NbOutputPCs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NbOutputPCs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PlotDistribVar.
function PlotDistribVar_Callback(hObject, eventdata, handles)
% hObject    handle to PlotDistribVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PlotDistribVar
global SpikeMovieData;

MovieSel=get(handles.MovieSelector,'Value');

Npixels=SpikeMovieData(MovieSel).DataSize(1)*SpikeMovieData(MovieSel).DataSize(2);
Ntime=SpikeMovieData(MovieSel).DataSize(3);

% Number of Principal Components we extract for dimensionality reduction
nPCs=str2num(get(handles.NbOutputPCs,'String'));

% Do the PCA calculation 
[PcaFilters,PcaTraces,CovEvals]=PcaCalculation(nPCs,MovieSel);
CovEvals=diag(CovEvals);

% Random matrix prediction (Sengupta & Mitra)
p1 = Npixels; % Number of pixels
q1 = Ntime; % Number of time frames
q = max(p1,q1);
p = min(p1,q1);
sigma = 1;
lmax = sigma*sqrt(p+q + 2*sqrt(p*q));
lmin = sigma*sqrt(p+q - 2*sqrt(p*q));
lambda = [lmin: (lmax-lmin)/100.0123423421: lmax];
rho = (1./(pi*lambda*(sigma^2))).*sqrt((lmax^2-lambda.^2).*(lambda.^2-lmin^2));
rho(isnan(rho)) = 0;
rhocdf = cumsum(rho)/sum(rho);
noiseigs = interp1(rhocdf, lambda, [p:-1:1]'/p, 'linear', 'extrap').^2 ;

% Normalize the PC spectrum
normrank = min(Ntime-1,length(CovEvals));
pca_norm = CovEvals*noiseigs(normrank) / (CovEvals(normrank)*noiseigs(1));


if isfield(handles,'hLocalFrame')
    if (isempty(handles.hLocalFrame) || ~ishandle(handles.hLocalFrame))
        handles.hLocalFrame=figure('Name','PCs and noise floor','NumberTitle','off');
    else
        figure(handles.hLocalFrame);
    end
else
    handles.hLocalFrame=figure('Name','PCs and noise floor','NumberTitle','off');
end

plot(pca_norm, 'o-', 'Color', [1,1,1]*0.3);
hold on;
plot(noiseigs / noiseigs(1), 'b-');
plot(2*noiseigs / noiseigs(1), 'b--');
hold off;
set(gca,'XScale','log','YScale','log');
xlabel('PC rank');
ylabel('Normalized variance');
axis tight;
legend('Data variance','Noise floor','2 x Noise floor');

guidata(handles.output,handles);
