function varargout = ICA_Movie_gpu(varargin)
% ICA_MOVIE_GPU This App performs ICA just as ICA_Movie does, but uses the
% GPU for computation in order to speed things up.
%
% This App requires an NVIDIA graphics card and updated CUDA drivers. 
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help ICA_Movie_gpu

% Last Modified by GUIDE v2.5 30-Apr-2012 14:08:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ICA_Movie_gpu_OpeningFcn, ...
    'gui_OutputFcn',  @ICA_Movie_gpu_OutputFcn, ...
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


% --- Executes just before ICA_Movie_gpu is made visible.
function ICA_Movie_gpu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ICA_Movie_gpu (see VARARGIN)
global SpikeMovieData;
global SpikeTraceData;
global SpikeImageData;

% Choose default command line output for ICA_Movie_gpu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ICA_Movie_gpu wait for user response (see UIRESUME)
% uiwait(handles.figure1);
NumberMovies=length(SpikeMovieData);

if ~isempty(SpikeMovieData)
    for i=1:length(SpikeMovieData)
        TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
    end
    set(handles.MovieSelector,'String',TextMovie);
end

NumberPCs=0;

if ~isempty(SpikeImageData) && ~isempty(SpikeTraceData)
    k=1;
    TextPCs=[];
    % We want to be sure we have pairs of Filter and Traces.
    for i=1:length(SpikeImageData)
        if strcmp(SpikeImageData(i).Label.ListText(1:2),'PC')
            ToFind=SpikeImageData(i).Label.ListText;
            for j=1:length(SpikeTraceData)
                if strcmp(SpikeImageData(i).Label.ListText,SpikeTraceData(j).Label.ListText)
                    TextPCs{k}=SpikeImageData(i).Label.ListText;
                    k=k+1;
                    break;
                end
            end
        end
    end
    set(handles.AvailablePCs,'String',TextPCs);
    NumberPCs=length(TextPCs);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.MovieSelector,'Value',intersect(1:NumberMovies,Settings.MovieSelectorValue));
    set(handles.SelectAllPcs,'Value',Settings.SelectAllPcsValue);
    if get(handles.SelectAllPcs,'Value')
        set(handles.AvailablePCs,'Value',1:NumberPCs);
    else
        set(handles.AvailablePCs,'Value',intersect(1:NumberPCs,Settings.AvailablePCsValue));
    end
    set(handles.DeletePCs,'Value',Settings.DeletePCsValue);
    set(handles.MuICs,'String',Settings.MuICsString);
    set(handles.NbOutputICs,'String',Settings.NbOutputICsString);
    set(handles.TermTolICs,'String',Settings.TermTolICsString);
    set(handles.MaxRoundsICs,'String',Settings.MaxRoundsICsString);
    
end
SelectAllPcs_Callback(hObject, eventdata, handles);


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.AvailablePCsValue=get(handles.AvailablePCs,'Value');
Settings.DeletePCsValue=get(handles.DeletePCs,'Value');
Settings.MuICsString=get(handles.MuICs,'String');
Settings.NbOutputICsString=get(handles.NbOutputICs,'String');
Settings.TermTolICsString=get(handles.TermTolICs,'String');
Settings.MaxRoundsICsString=get(handles.MaxRoundsICs,'String');
Settings.SelectAllPcsValue=get(handles.SelectAllPcs,'Value');

 
% --- Outputs from this function are returned to the command line.
function varargout = ICA_Movie_gpu_OutputFcn(hObject, eventdata, handles)
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
global SpikeTraceData;
global SpikeImageData;

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');

    % Do the ICA calculation
    h=waitbar(0,'Performing ICA','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    
    MovieSel=get(handles.MovieSelector,'Value');
    
    if ~isempty(SpikeImageData) && ~isempty(SpikeTraceData)
        k=1;
        NumberPC=0;
        TextPCs=[];
        UsedPCs=get(handles.AvailablePCs,'Value');
        % We want to be sure we have pairs of Filter and Traces.
        for i=1:length(SpikeImageData)
            if strcmp(SpikeImageData(i).Label.ListText(1:2),'PC')
                ToFind=SpikeImageData(i).Label.ListText;
                for j=1:length(SpikeTraceData)
                    if strcmp(SpikeImageData(i).Label.ListText,SpikeTraceData(j).Label.ListText)
                        if (ismember(k,UsedPCs) || get(handles.SelectAllPcs,'Value'))                           
                            NumberPC=NumberPC+1;
                            if NumberPC==1
                                % We preallocate the matrix for the first
                                % PC met.
                                PcaFilters=zeros(length(UsedPCs),length(SpikeImageData(i).Image(:)),'double');
                                PcaTraces=zeros(length(UsedPCs),length(SpikeTraceData(j).Trace(:)),'double');
                            end
                            PcaFilters(NumberPC,:)=double(SpikeImageData(i).Image(:));
                            PcaTraces(NumberPC,:)=double(SpikeTraceData(j).Trace(:));
                        end
                        k=k+1;
                        break;
                    end
                end
            end
        end
        nPCs=k-1;
    end
    
    nICs=str2num(get(handles.NbOutputICs,'String'));
    Mu=str2double(get(handles.MuICs,'String'));
    TermTolICs=str2double(get(handles.TermTolICs,'String'));
    MaxRoundsICs=str2num(get(handles.MaxRoundsICs,'String'));
    
    % Seed for the ICs calculation
    ica_A_guess = gpuArray(single(orth(randn(nPCs, nICs))));
    
    % % Center the data by removing the mean of each PC
    meanTraces = mean(PcaTraces,2);
    PcaTraces = PcaTraces - meanTraces * ones(1, size(PcaTraces,2));
    
    meanFilters = mean(PcaFilters,2);
    PcaFilters = PcaFilters - meanFilters * ones(1, size(PcaFilters,2));
    
    % Create concatenated data for spatio-temporal ICA
    if Mu == 1
        % Pure temporal ICA
        IcaMixed = gpuArray(PcaTraces);
        
    elseif Mu == 0
        % Pure spatial ICA
        IcaMixed = gpuArray(PcaFilters);
        
    else
        % Spatial-temporal ICA
        IcaMixed = [(1-Mu)*PcaFilters, Mu*PcaTraces];
        IcaMixed = gpuArray(single(IcaMixed / sqrt(1-2*Mu+2*Mu^2))); % This normalization ensures that, if both PcaFilters and PcaTraces have unit covariance, then so will IcaTraces
    end
    
    % Perform ICA
    numSamples = size(IcaMixed,2);
    ica_A = gpuArray(single(ica_A_guess));
    BOld = gpuArray(single(zeros(size(ica_A))));
    numiter = 0;
    minAbsCos = 0;
    
    dividerWaitbar=10^(floor(log10(MaxRoundsICs))-1);
    
    % We preallocate an intermediate matrix
    Interm=gpuArray(zeros(size(IcaMixed,2),nICs,'single'));
    
    while (numiter<MaxRoundsICs) && ((1-minAbsCos)>TermTolICs)
        numiter = numiter + 1;
        
        if numiter>1
            Interm=IcaMixed'*ica_A;
            Interm=Interm.^2;
            ica_A = IcaMixed*Interm/numSamples;
        end
        
        % Symmetric orthogonalization.
        [vecs, vals] = eig(ica_A'*ica_A);
        ica_A = ica_A * real( vecs * diag(power(complex(diag(vals)), complex(-1/2,0)),0) * vecs' );
        
        % Test for termination condition.
        minAbsCos = gather(min(abs(diag(ica_A' * BOld))));
        BOld = ica_A;
        
        if (round(numiter/dividerWaitbar)==numiter/dividerWaitbar)
            waitbar(numiter/MaxRoundsICs,h);
            % Check for Cancel button press
            if getappdata(h,'canceling')
                error('Aborted');
            end
        end
        
     
    end
    
    ica_W = gather(ica_A');
    
    % Add the mean back in.
    IcaTraces = ica_W*PcaTraces+ica_W*(meanTraces*ones(1,size(PcaTraces,2)));
    IcaFilters = ica_W*PcaFilters+ica_W*(meanFilters*ones(1,size(PcaFilters,2)));
    
    % Sort ICs according to skewness of the temporal component
    icskew = skewness(IcaTraces');
    [icskew, ICCoord] = sort(icskew, 'descend');
    ica_A = ica_A(:,ICCoord);
    IcaTraces = IcaTraces(ICCoord,:);
    IcaFilters = IcaFilters(ICCoord,:);
    
    % Note that with these definitions of IcaFilters and IcaTraces, we can decompose
    % the sphered and original movie data matrices as:
    %     mov_sphere ~ PcaFilters * PcaTraces = IcaFilters * IcaTraces = (PcaFilters*ica_A') * (ica_A*PcaTraces),
    %     mov ~ PcaFilters * pca_D * PcaTraces.
    % This gives:
    %     IcaFilters = PcaFilters * ica_A' = mov * PcaTraces' * inv(diag(pca_D.^(1/2)) * ica_A'
    %     IcaTraces = ica_A * PcaTraces = ica_A * inv(diag(pca_D.^(1/2))) * PcaFilters' * mov
    
    
    % Reshape the filter to have a proper image
    IcaFilters = reshape(IcaFilters,nICs,SpikeMovieData(MovieSel).DataSize(1),SpikeMovieData(MovieSel).DataSize(2));
    
    % Now we remove PCs from memory if asked for
    if get(handles.DeletePCs,'Value')
        if ~isempty(SpikeImageData) && ~isempty(SpikeTraceData)
            ListFilterToRemove=[];
            ListTraceToRemove=[];
            % We want to be sure we have pairs of Filter and Traces.
            for i=1:length(SpikeImageData)
                if strcmp(SpikeImageData(i).Label.ListText(1:2),'PC')
                    ListFilterToRemove=[ListFilterToRemove i];
                end
            end
            for i=1:length(SpikeTraceData)
                if strcmp(SpikeTraceData(i).Label.ListText(1:2),'PC')
                    ListTraceToRemove=[ListTraceToRemove i];
                end
            end
            NumberTrace=length(SpikeTraceData);
            NumberFilter=length(SpikeImageData);
            FilterToKeep=setdiff(1:NumberFilter,ListFilterToRemove);
            TraceToKeep=setdiff(1:NumberTrace,ListTraceToRemove);
            SpikeTraceData=SpikeTraceData(TraceToKeep);
            SpikeImageData=SpikeImageData(FilterToKeep);
        end
    end
    
    % Now we export filters and traces to the global variable of SpikeExtractor
    CurrentNumberTrace=length(SpikeTraceData);
    CurrentNumberImage=length(SpikeImageData);
    delete(h);
    
    h=waitbar(0,'Exporting result to Images and Traces');
    dividerWaitbar=10^(floor(log10(nICs))-1);
    
    for i=1:nICs
        if isempty(SpikeTraceData)
            InitTraces();
        end
        SpikeTraceData(CurrentNumberTrace+i).XVector=SpikeMovieData(MovieSel).TimeFrame;
        SpikeTraceData(CurrentNumberTrace+i).Trace=IcaTraces(i,:);
        SpikeTraceData(CurrentNumberTrace+i).DataSize=size(SpikeTraceData(CurrentNumberTrace+i).Trace);
        SpikeTraceData(CurrentNumberTrace+i).Label.YLabel=SpikeMovieData(MovieSel).Label.CLabel;
        SpikeTraceData(CurrentNumberTrace+i).Filename=SpikeMovieData(MovieSel).Filename;
        SpikeTraceData(CurrentNumberTrace+i).Path=SpikeMovieData(MovieSel).Path;
        SpikeTraceData(CurrentNumberTrace+i).Label.ListText=['IC ',num2str(i)];
        SpikeTraceData(CurrentNumberTrace+i).Label.XLabel='Time (s)';
        
        if isempty(SpikeImageData)
            InitImages();
        end
        SpikeImageData(CurrentNumberImage+i).Image=squeeze(IcaFilters(i,:,:));
        SpikeImageData(CurrentNumberImage+i).DataSize=size(SpikeImageData(CurrentNumberImage+i).Image);
        SpikeImageData(CurrentNumberImage+i).Label.CLabel=SpikeMovieData(MovieSel).Label.CLabel;
        SpikeImageData(CurrentNumberImage+i).Label.XLabel=SpikeMovieData(MovieSel).Label.XLabel;
        SpikeImageData(CurrentNumberImage+i).Label.YLabel=SpikeMovieData(MovieSel).Label.YLabel;
        SpikeImageData(CurrentNumberImage+i).Label.ZLabel=SpikeMovieData(MovieSel).Label.ZLabel;
        SpikeImageData(CurrentNumberImage+i).Xposition=SpikeMovieData(MovieSel).Xposition;
        SpikeImageData(CurrentNumberImage+i).Yposition=SpikeMovieData(MovieSel).Yposition;
        SpikeImageData(CurrentNumberImage+i).Zposition=SpikeMovieData(MovieSel).Zposition;
        SpikeImageData(CurrentNumberImage+i).Filename=SpikeMovieData(MovieSel).Filename;
        SpikeImageData(CurrentNumberImage+i).Path=SpikeMovieData(MovieSel).Path;
        SpikeImageData(CurrentNumberImage+i).Label.ListText=['IC ',num2str(i)];
        
        if (round(i/dividerWaitbar)==i/dividerWaitbar)
            waitbar(i/nICs,h);
        end
    end
    delete(h);
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


function MuICs_Callback(hObject, eventdata, handles)
% hObject    handle to MuICs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MuICs as text
%        str2double(get(hObject,'String')) returns contents of MuICs as a double


% --- Executes during object creation, after setting all properties.
function MuICs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MuICs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NbOutputICs_Callback(hObject, eventdata, handles)
% hObject    handle to NbOutputICs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NbOutputICs as text
%        str2double(get(hObject,'String')) returns contents of NbOutputICs as a double
TextPCs=get(handles.AvailablePCs,'String');
nPCs=length(TextPCs);
nICs=str2num(get(handles.NbOutputICs,'String'));

if isempty(nICs)
    nICs=0;
end

if nPCs<nICs
    set(handles.NbOutputICs,'String',num2str(nPCs));
end


% --- Executes during object creation, after setting all properties.
function NbOutputICs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NbOutputICs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TermTolICs_Callback(hObject, eventdata, handles)
% hObject    handle to TermTolICs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TermTolICs as text
%        str2double(get(hObject,'String')) returns contents of TermTolICs as a double


% --- Executes during object creation, after setting all properties.
function TermTolICs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TermTolICs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxRoundsICs_Callback(hObject, eventdata, handles)
% hObject    handle to MaxRoundsICs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxRoundsICs as text
%        str2double(get(hObject,'String')) returns contents of MaxRoundsICs as a double


% --- Executes during object creation, after setting all properties.
function MaxRoundsICs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxRoundsICs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in AvailablePCs.
function AvailablePCs_Callback(hObject, eventdata, handles)
% hObject    handle to AvailablePCs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AvailablePCs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AvailablePCs


% --- Executes during object creation, after setting all properties.
function AvailablePCs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AvailablePCs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DeletePCs.
function DeletePCs_Callback(hObject, eventdata, handles)
% hObject    handle to DeletePCs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DeletePCs


% --- Executes on button press in SelectAllPcs.
function SelectAllPcs_Callback(hObject, eventdata, handles)
% hObject    handle to SelectAllPcs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SelectAllPcs
if (get(handles.SelectAllPcs,'Value')==1)
    set(handles.AvailablePCs,'Enable','off');
else
    set(handles.AvailablePCs,'Enable','on');
end
