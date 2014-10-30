function varargout = Align_Pixels_Movie(varargin)
% ALIGN_PIXELS_MOVIE MATLAB code for Align_Pixels_Movie.fig
%      ALIGN_PIXELS_MOVIE, by itself, creates a new ALIGN_PIXELS_MOVIE or raises the existing
%      singleton*.
%
%      H = ALIGN_PIXELS_MOVIE returns the handle to a new ALIGN_PIXELS_MOVIE or the handle to
%      the existing singleton*.
%
%      ALIGN_PIXELS_MOVIE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ALIGN_PIXELS_MOVIE.M with the given input arguments.
%
%      ALIGN_PIXELS_MOVIE('Property','Value',...) creates a new ALIGN_PIXELS_MOVIE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Align_Pixels_Movie_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Align_Pixels_Movie_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Align_Pixels_Movie

% Last Modified by GUIDE v2.5 21-Jun-2012 13:49:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Align_Pixels_Movie_OpeningFcn, ...
                   'gui_OutputFcn',  @Align_Pixels_Movie_OutputFcn, ...
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


% --- Executes just before Align_Pixels_Movie is made visible.
function Align_Pixels_Movie_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Align_Pixels_Movie (see VARARGIN)
global SpikeMovieData;

% Choose default command line output for Align_Pixels_Movie
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Align_Pixels_Movie wait for user response (see UIRESUME)
% uiwait(handles.figure1);
NumberMovies=length(SpikeMovieData);

if ~isempty(SpikeMovieData)
    for i=1:NumberMovies
        TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText]; %#ok<AGROW>
    end
    set(handles.MovieSelector,'String',TextMovie);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.SelectAllMovies,'Value',Settings.SelectAllMoviesValue);
    set(handles.MovieSelector,'Value',intersect(1:NumberMovies, Settings.MovieSelectorValue));
    set(handles.KeepOriginalMovies,'Value',Settings.KeepOriginalMoviesValue);
    set(handles.NbFrameCalculation,'String',Settings.NbFrameCalculationString);
else
    set(handles.MovieSelector,'Value',[]);
end

SelectAllMovies_Callback(hObject, eventdata, handles);

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject) %#ok<*DEFNU>
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.SelectAllMoviesValue=get(handles.SelectAllMovies,'Value');
Settings.KeepOriginalMoviesValue=get(handles.KeepOriginalMovies,'Value');
Settings.NbFrameCalculationString=get(handles.NbFrameCalculation,'String');


% --- Outputs from this function are returned to the command line.
function varargout = Align_Pixels_Movie_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ValidateValues.
function ValidateValues_Callback(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;


% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeMovieData

try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    h=waitbar(0,'Aligning pixels...');
    
    if (get(handles.SelectAllMovies,'Value')==1)
        moviesToAlign=1:length(SpikeMovieData);
    else
        moviesToAlign=get(handles.MovieSelector,'Value');
    end
    numberMovies=length(SpikeMovieData);
    startLine=1;
    waitbar(1/(length(moviesToAlign)*5), h);
    NbFrameMax=str2num(get(handles.NbFrameCalculation,'String'));
    for i=1:length(moviesToAlign)
        origMovie=moviesToAlign(i);
        origMovieClass=class(SpikeMovieData(origMovie).Movie);
        endLine=size(SpikeMovieData(origMovie).Movie,1);
        transformTwoPixel=DeinterlaceNonconstant(origMovie, startLine, endLine, NbFrameMax);
        
        if get(handles.KeepOriginalMovies, 'Value')
            saveInd=numberMovies+i;
            SpikeMovieData(saveInd)=SpikeMovieData(origMovie);
        else
            saveInd=origMovie;
        end
        SpikeMovieData(saveInd).Label.ListText=['aligned ' SpikeMovieData(origMovie).Label.ListText];
        
        waitbar(2*i/(length(moviesToAlign)*3), h);
        
        numFrames=size(SpikeMovieData(origMovie).Movie,3);
        for frameInd=1:numFrames
            if mod(frameInd, numFrames/2)==0
                waitbar(3*i/(length(moviesToAlign)*4), h);
            end
            oddLines=SpikeMovieData(origMovie).Movie(:,:,frameInd);
            oddLines(2:2:end,:,:)=0;
            evenLines=SpikeMovieData(origMovie).Movie(:,:,frameInd);
            evenLines(1:2:end,:,:)=0;
            SpikeMovieData(saveInd).Movie(:,:,frameInd)=oddLines+cast(full(double(evenLines)*transformTwoPixel),origMovieClass);
        end
        lastSensibleLine=find(transformTwoPixel(end,:)==1, 1, 'first');
        firstSensibleLine=find(transformTwoPixel(1,:)==1, 1, 'last');
        if isempty(lastSensibleLine)
            lastSensibleLine=size(SpikeMovieData(saveInd).Movie,2);
        end
        if isempty(firstSensibleLine)
            firstSensibleLine=1;
        end
        SpikeMovieData(saveInd).Movie=SpikeMovieData(saveInd).Movie(:,firstSensibleLine:lastSensibleLine,:);
        SpikeMovieData(saveInd).Exposure=SpikeMovieData(saveInd).Movie(:,firstSensibleLine:lastSensibleLine);
        SpikeMovieData(saveInd).XPosition=SpikeMovieData(saveInd).Movie(:,firstSensibleLine:lastSensibleLine);
        SpikeMovieData(saveInd).YPosition=SpikeMovieData(saveInd).Movie(:,firstSensibleLine:lastSensibleLine);
        SpikeMovieData(saveInd).ZPosition=SpikeMovieData(saveInd).Movie(:,firstSensibleLine:lastSensibleLine);
        SpikeMovieData(saveInd).TimePixel=SpikeMovieData(saveInd).Movie(:,firstSensibleLine:lastSensibleLine,:);
        SpikeMovieData(saveInd).DataSize=size(SpikeMovieData(saveInd).Movie);
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



% turns pixel weight matrix into original pixel position vector
function posVec = weightsToPos(weightMat)
numCols=size(weightMat,2);
posVec=zeros(numCols,1);
for colInd=1:numCols
    theseNonZeros=find(weightMat(:,colInd));
    thisShift=sum(theseNonZeros.*weightMat(theseNonZeros,colInd)); 
    posVec(colInd)=thisShift;
end
 


% turns original pixel position vector into pixel weight matrix 
function weightMat = posToWeights(posVec)
numCols=length(posVec);
weightMat=zeros(numCols);
for colInd=1:numCols
    thisPos=posVec(colInd);
    if mod(thisPos,1)>0.005
        weightMat(floor(thisPos),colInd)=1-mod(thisPos,1);
        weightMat(floor(thisPos)+1,colInd)=mod(thisPos,1);
    else
        weightMat(floor(thisPos),colInd)=1;
    end
end



% finds pixel transformation
function transformTwoPixel=DeinterlaceNonconstant(origMovie, startLine, endLine, NbFrameMax)
    global SpikeMovieData

    % get movie data
    nPixelsAcross=size(SpikeMovieData(origMovie).Movie,2);
    nLines=length(startLine:endLine);
    
    nFrames=min(NbFrameMax,size(SpikeMovieData(origMovie).Movie,3));

    % set up lines so that finding pixel weights is just solving y=A*x
    y3d=double(squeeze(SpikeMovieData(origMovie).Movie([startLine:2:nLines, (startLine+2):2:nLines], :, 1:nFrames)));
    y3d=permute(y3d, [1,3,2]);
    y=reshape(y3d, (nLines-1)*nFrames, nPixelsAcross);
    A3d=double(squeeze(SpikeMovieData(origMovie).Movie([(startLine+1):2:nLines, (startLine+1):2:(nLines-1)], :, 1:nFrames)));
    A3d=permute(A3d, [1,3,2]);
    A=reshape(A3d, (nLines-1)*nFrames, nPixelsAcross);
    pixelWeights=A\y;
    clear A3d y3d
    
    % smooth the weights a little, helps eliminate outliers
    smoothingConstant=10;
    smoothPixelWeights=zeros(nPixelsAcross);
    for pixInd=1:size(pixelWeights,1)
        thisTr=[pixelWeights(1,pixInd)*ones(smoothingConstant,1); pixelWeights(:,pixInd); pixelWeights(nPixelsAcross,pixInd)*ones(smoothingConstant,1)];
        smoothTr=conv(thisTr, ones(1,smoothingConstant), 'same');
        smoothPixelWeights(:,pixInd)=smoothTr(smoothingConstant+(1:nPixelsAcross));
    end

    % select highest 2 weights
    transformTwoPixel=zeros(nPixelsAcross);
    transformInds=zeros(nPixelsAcross,2);
    for pixInd=1:nPixelsAcross
        [~, inds]=sort(smoothPixelWeights(:,pixInd), 'descend');
        maxInds=inds(1:2); 
        transformInds(pixInd,:)=maxInds;
        inds=1:nPixelsAcross; 
        inds(transformInds(pixInd,:))=[];
        transformTwoPixel(:,pixInd)=smoothPixelWeights(:,pixInd); transformTwoPixel(inds,pixInd)=0;
    end

    % normalize pixel weights, get corresponding pixel positions
    transformSums=sum(transformTwoPixel,1);
    transformSums=1./transformSums;
    transformTwoPixel=transformTwoPixel.*(repmat(transformSums, nPixelsAcross, 1));
    posVec = weightsToPos(transformTwoPixel);

    % fit a polynomial to the positions, to ensure smoothness
    X=[(1:nPixelsAcross)', ((1:nPixelsAcross).^2)'];
    p=robustfit(X, posVec, 'huber');
    fitPosVec=p(3)*X(:,2)+p(2)*X(:,1)+p(1);
    fitPosVec=min(max(fitPosVec,1),nPixelsAcross);
    transformTwoPixel=sparse(posToWeights(fitPosVec));



% --- Executes on selection change in MovieSelector.
function MovieSelector_Callback(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to MovieSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MovieSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MovieSelector


% --- Executes during object creation, after setting all properties.
function MovieSelector_CreateFcn(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to MovieSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function ValidateValues_CreateFcn(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in SelectAllMovies.
function SelectAllMovies_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to SelectAllMovies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SelectAllMovies
if (get(handles.SelectAllMovies,'Value')==1)
    set(handles.MovieSelector,'Enable','off');
else
    set(handles.MovieSelector,'Enable','on');
end


% --- Executes on button press in KeepOriginalMovies.
function KeepOriginalMovies_Callback(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to KeepOriginalMovies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KeepOriginalMovies



function NbFrameCalculation_Callback(hObject, eventdata, handles)
% hObject    handle to NbFrameCalculation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NbFrameCalculation as text
%        str2double(get(hObject,'String')) returns contents of NbFrameCalculation as a double


% --- Executes during object creation, after setting all properties.
function NbFrameCalculation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NbFrameCalculation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
