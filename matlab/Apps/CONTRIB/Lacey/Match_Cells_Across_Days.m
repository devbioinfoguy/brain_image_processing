function varargout = Match_Cells_Across_Days(varargin)
% MATCH_CELLS_ACROSS_DAYS 
%
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Match_Cells_Across_Days

% Last Modified by GUIDE v2.5 11-Nov-2012 18:18:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Match_Cells_Across_Days_OpeningFcn, ...
                   'gui_OutputFcn',  @Match_Cells_Across_Days_OutputFcn, ...
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
function Match_Cells_Across_Days_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Match_Cells_Across_Days (see VARARGIN)

% Choose default command line output for Match_Cells_Across_Days
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeTraceData
global SpikeImageData

if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.Set1TraceSelector, 'String', TextTrace);
    set(handles.Set2TraceSelector, 'String', TextTrace);
end

if ~isempty(SpikeImageData)
    for i=1:length(SpikeImageData)
        TextImage{i}=[num2str(i),' - ',SpikeImageData(i).Label.ListText];
    end
    set(handles.Set1ImageSelector,'String',TextImage);
    set(handles.Set2ImageSelector,'String',TextImage);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.Set1ImageSelector,'Value',intersect(Settings.Set1ImageSelectorValue, 1:length(SpikeImageData)));
    set(handles.Set2ImageSelector,'Value',intersect(Settings.Set2ImageSelectorValue, 1:length(SpikeImageData)));
    set(handles.Set1TraceSelector,'Value',intersect(Settings.Set1TraceSelectorValue, 1:length(SpikeTraceData)));
    set(handles.Set2TraceSelector,'Value',intersect(Settings.Set2TraceSelectorValue, 1:length(SpikeTraceData)));
    set(handles.ViewMatched, 'Value', Settings.ViewMatchedValue);
    set(handles.ViewNonmatched, 'Value', Settings.ViewNonmatchedValue);
    set(handles.MaxDistance, 'String', Settings.MaxDistanceString);
    set(handles.MaxDistanceViewNonmatched, 'String', Settings.MaxDistanceViewNonmatchedString);
    set(handles.Set1Label, 'String', Settings.Set1LabelString);
    set(handles.Set2Label, 'String', Settings.Set2LabelString);
    set(handles.GlobalBehavior, 'Value', Settings.GlobalBehaviorValue);
    
end

if (get(handles.ViewNonmatched,'Value')==1)
    set(handles.MaxDistanceViewNonmatched,'Enable','on');
else
    set(handles.MaxDistanceViewNonmatched,'Enable','off');
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.Set1ImageSelectorValue=get(handles.Set1ImageSelector,'Value');
Settings.Set2ImageSelectorValue=get(handles.Set2ImageSelector,'Value');
Settings.Set1TraceSelectorValue=get(handles.Set1TraceSelector,'Value');
Settings.Set2TraceSelectorValue=get(handles.Set2TraceSelector,'Value');
Settings.ViewMatchedValue=get(handles.ViewMatched,'Value');
Settings.ViewNonmatchedValue=get(handles.ViewNonmatched,'Value');
Settings.MaxDistanceString=get(handles.MaxDistance, 'String');
Settings.MaxDistanceViewNonmatchedString=get(handles.MaxDistanceViewNonmatched, 'String');
Settings.Set1LabelString=get(handles.Set1Label, 'String');
Settings.Set2LabelString=get(handles.Set2Label, 'String');
Settings.GlobalBehaviorValue=get(handles.GlobalBehavior, 'Value');

% --- Outputs from this function are returned to the command line.
function varargout = Match_Cells_Across_Days_OutputFcn(hObject, eventdata, handles) 
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

    imagesToProcess1=get(handles.Set1ImageSelector, 'Value');
    imagesToProcess2=get(handles.Set2ImageSelector, 'Value');
    sizeIm=size(SpikeImageData(imagesToProcess1(1)).Image);

    centroids1=zeros(length(imagesToProcess1),2);
    centroids2=zeros(length(imagesToProcess2),2);

    xCoords=repmat(1:sizeIm(2), sizeIm(1), 1);
    yCoords=repmat((1:sizeIm(1))', 1, sizeIm(2));
    numPix=sizeIm(1)*sizeIm(2);

    for imInd=1:length(imagesToProcess1)
        thisImageInd=imagesToProcess1(imInd);
        thisImage=SpikeImageData(thisImageInd).Image;
        thisImSum=sum(sum(thisImage));
        centroids1(imInd,1)=sum(sum(thisImage.*xCoords))/thisImSum;
        centroids1(imInd,2)=sum(sum(thisImage.*yCoords))/thisImSum;
    end

    for imInd=1:length(imagesToProcess2)
        thisImageInd=imagesToProcess2(imInd);
        thisImage=SpikeImageData(thisImageInd).Image;
        thisImSum=sum(sum(thisImage));
        centroids2(imInd,1)=sum(sum(thisImage.*xCoords))/thisImSum;
        centroids2(imInd,2)=sum(sum(thisImage.*yCoords))/thisImSum;
    end

    % mapImage=401;
    % figure(5); imagesc(SpikeImageData(mapImage).Image)
    % hold on
    % plot(centroids(:,1), centroids(:,2), '*');
    % xlim([1 sizeIm(2)])
    % ylim([1 sizeIm(1)])

    % figure(4)
    % plot(centroids(:,1), centroids(:,2), 'g*');
    % xlim([1 sizeIm(2)])
    % ylim([1 sizeIm(1)])

    num1=size(centroids1,1);
    num2=size(centroids2,1);

    dsq=squareform(pdist([centroids1; centroids2]));
    dsq(1:num1, 1:num1)=1000;
    dsq(num1+(1:num2), num1+(1:num2))=1000;
    for i=1:size(dsq,1)
        dsq(i,i)=0;
    end
    dlin=squareform(dsq);
    h=linkage(dlin, 'complete');
    maxDist=str2double(get(handles.MaxDistance, 'String'));
    c=cluster(h, 'cutoff', maxDist, 'criterion', 'distance');

    cInds=1:max(c);
    if length(unique(c(1:num1)))~=num1 || length(unique(c(num1+(1:num2))))~=num2
        warndlg('cells from same day assigned to same cluster!')
    end
    for cInd=cInds
        if sum(c==cInd)>2
            warndlg('more than 2 cells in a cluster!')
        end
    end
    
    
    
        % assign daily IDs if they don't already exist
    tracesToProcess1=get(handles.Set1TraceSelector, 'Value');
    tracesToProcess2=get(handles.Set2TraceSelector, 'Value');
    if length(tracesToProcess1)~=num1
        error('Must select same number of images and traces!');
    elseif length(tracesToProcess2)~=num2
        error('Must select same number of images and traces!');
    end

    for i=1:length(imagesToProcess1)
                imInd=imagesToProcess1(i);
        trInd=tracesToProcess1(i);
        if i==1
            SpikeImageData(imInd)
            SpikeTraceData(trInd)
        end
        if ~isfield(SpikeImageData(imInd), 'ID') || ~isa(SpikeImageData(imInd).ID, 'containers.Map')
            SpikeImageData(imInd).ID=containers.Map;
            SpikeImageData(imInd).ID('daily')=i;
        end
        if ~isfield(SpikeTraceData(trInd), 'ID') || ~isa(SpikeTraceData(trInd).ID, 'containers.Map')
            SpikeTraceData(trInd).ID=containers.Map;
            SpikeTraceData(trInd).ID('daily')=i;
        end
        
        if i==1
            SpikeImageData(imInd)
            SpikeTraceData(trInd)
        end
    end
    for i=1:length(imagesToProcess2)
        imInd=imagesToProcess2(i);
        trInd=tracesToProcess2(i);
        if i==1
            SpikeImageData(imInd)
            SpikeTraceData(trInd)
        end
        
        if ~isfield(SpikeImageData(imInd), 'ID') || ~isa(SpikeImageData(imInd).ID, 'containers.Map')
            SpikeImageData(imInd).ID=containers.Map;
            SpikeImageData(imInd).ID('daily')=i;
        end
        if ~isfield(SpikeTraceData(trInd), 'ID') || ~isa(SpikeTraceData(trInd).ID, 'containers.Map')
            SpikeTraceData(trInd).ID=containers.Map;
            SpikeTraceData(trInd).ID('daily')=i;
        end
        if i==1
            SpikeImageData(imInd)
            SpikeTraceData(trInd)
        end
    end


    % get parameters from interface and decide which set of global IDs to use
    
    switch get(handles.GlobalBehavior, 'Value')
        case 1
            if isKey(SpikeImageData(imagesToProcess1(1)).ID, 'global')
                hasGlobal1=1;
            else
                hasGlobal1=0;
            end
            if isKey(SpikeImageData(imagesToProcess2(1)).ID, 'global')
                hasGlobal2=1;
            else
                hasGlobal2=0;
            end
        case 2
            if isKey(SpikeImageData(imagesToProcess1(1)).ID, 'global')
                hasGlobal1=1;
            else
                hasGlobal1=0;
            end
            hasGlobal2=0;
        case 3
            hasGlobal1=0;
            if isKey(SpikeImageData(imagesToProcess2(1)).ID, 'global')
                hasGlobal2=1;
            else
                hasGlobal2=0;
            end
        case 4
            hasGlobal1=0;
            hasGlobal2=0;
    end
    
    if hasGlobal1 && hasGlobal2
        error('Both sets of images have global IDs already assigned. Select which set of global IDs to use.')
    end


    % manual check of clustered cells
    manualcheck=get(handles.ViewMatched, 'Value');
    numSharedCells=0;
    numNonsingleClusts=max(c)-length(unique(c));
    numClustsAll=max(c);
    sharedCellInds=zeros(numNonsingleClusts,2);
    clustInd=0;
    for cInd=cInds
        theseCells=find(c==cInd);
        ind1=theseCells(theseCells<=num1);
        ind2=theseCells(theseCells>num1)-num1;
        if ~isempty(ind1) && ~isempty(ind2)
            clustInd=clustInd+1;
            numSharedCells=numSharedCells+1;
            sharedCellInds(clustInd,:)=[ind1, ind2];
            if manualcheck
                figure(10)
                image1=SpikeImageData(imagesToProcess1(ind1)).Image;
                image2=SpikeImageData(imagesToProcess2(ind2)).Image;
                imagesc(image1+image2);
                hold on
                plot(centroids1(ind1,1), centroids1(ind1,2), 'g*')
                plot(centroids2(ind2,1), centroids2(ind2,2), 'b*')
                title(['MATCHED: cluster ', num2str(cInd), '. Click to continue. Press r to reject, q to stop checking'])
                k=waitforbuttonpress();
                if k==1
                    keyPressed = get(gcf,'CurrentCharacter');
                    if keyPressed=='q'
                        manualcheck=0;
                    elseif keyPressed=='r'
                        clustInd=clustInd-1;
                        numSharedCells=numSharedCells-1;
                        c(ind2+num1)=numClustsAll+1;
                        numClustsAll=numClustsAll+1;
                    end    
                end
            end
            hold off
        end
    end


    % manual check of non-clustered cells
    maxDistNonmatch=str2double(get(handles.MaxDistanceViewNonmatched, 'String'));
    [closei, closej]=ind2sub(size(dsq), find(and(dsq<maxDistNonmatch, dsq>0)));
    nonRepeatInds=closei<closej;
    closei=closei(nonRepeatInds);
    closej=closej(nonRepeatInds);

    manualcheckNonmatches=get(handles.ViewNonmatched, 'Value');
    for pairInd=1:length(closei)
        i=closei(pairInd);
        j=closej(pairInd);
        if manualcheckNonmatches
            if i<num1+1 && j>num1
                scalej=j-num1;
                if c(i)~=c(j)
                    figure(10)
                    image1=SpikeImageData(imagesToProcess1(i)).Image;
                    image2=SpikeImageData(imagesToProcess2(scalej)).Image;
                    imagesc(image1+image2);
                    hold on
                    plot(centroids1(i,1), centroids1(i,2), 'g*')
                    plot(centroids2(scalej,1), centroids2(scalej,2), 'b*')
                    title(['NOT MATCHED. Dist=' num2str(dsq(i,j)), '. Click to continue, key press to stop checking.'])
                    k=waitforbuttonpress();
                    if k==1
                        manualcheckNonmatches=0;
                        continue
                    end
                    hold off
                end
            end
        end
    end




    % assign global IDs to clusters of cells, starting with day 1
    globalOrderInd=0;
    nonsharedCount=0;
    globalIDs1=zeros(size(imagesToProcess1));
    globalIDs2=zeros(size(imagesToProcess2));
    numSharedCells=size(sharedCellInds,1);

    for ind1=1:length(imagesToProcess1)
        sharedInd=find(sharedCellInds(:,1)==ind1);
        thisSpikeInd1=imagesToProcess1(ind1);
        if ~isempty(sharedInd)
            globalOrderInd=globalOrderInd+1;
            ind2=sharedCellInds(sharedInd,2);
            thisSpikeInd2=imagesToProcess2(ind2);

            if hasGlobal1
                thisGlobalID=SpikeImageData(thisSpikeInd1).ID('global');
            elseif hasGlobal2
                thisGlobalID=SpikeImageData(thisSpikeInd2).ID('global');
            else
                thisGlobalID=globalOrderInd;
            end
            globalIDs1(ind1)=thisGlobalID;
            globalIDs2(ind2)=thisGlobalID;

        else
            nonsharedCount=nonsharedCount+1;

            if hasGlobal1
                thisGlobalID=SpikeImageData(thisSpikeInd1).ID('global');
            else
                thisGlobalID=numSharedCells+nonsharedCount;
            end
            globalIDs1(ind1)=thisGlobalID;
        end
    end



    % give global IDs to cells from day 2 which didn't overlap with day 1
    unassignedInds2=find(globalIDs2==0);
    for ind2Ind=1:length(unassignedInds2)
        ind2=unassignedInds2(ind2Ind);
        if hasGlobal2
            thisGlobalID=SpikeTraceData(thisSpikeInd2).ID('global');
        else
            thisGlobalID=max(globalIDs1)+ind2Ind;
        end
        globalIDs2(ind2)=thisGlobalID;
    end



    % save traces and images in new order and give them the above global IDs
    if length(unique(globalIDs1))~=length(globalIDs1)
        error('Duplicate global ID assigned.')
    end

    numTraces=length(SpikeTraceData);
    numImages=length(SpikeImageData);

    day1tag=get(handles.Set1Label, 'String');
    day2tag=get(handles.Set2Label, 'String');
    
    maxGlobal=max([globalIDs1, globalIDs2]);
    allGlobals=1:maxGlobal;
    
    blankTrace1=SpikeTraceData(tracesToProcess1(1));
    blankTrace2=SpikeTraceData(tracesToProcess2(1));
    blankTrace1.Trace=zeros(size(SpikeTraceData(tracesToProcess1(1)).Trace));
    blankTrace2.Trace=zeros(size(SpikeTraceData(tracesToProcess2(1)).Trace));
    blankTrace1.ID('daily')=0;
    blankTrace2.ID('daily')=0;
    
    blankImage1=SpikeImageData(imagesToProcess1(1));
    blankImage2=SpikeImageData(imagesToProcess2(1));
    blankImage1.Image=zeros(size(SpikeImageData(imagesToProcess1(1)).Image));
    blankImage2.Image=zeros(size(SpikeImageData(imagesToProcess2(1)).Image));
    blankImage1.ID('daily')=0;
    blankImage2.ID('daily')=0;
    
    for gID=allGlobals
        saveTraceInd1=numTraces+gID;
        saveImageInd1=numImages+gID;
        saveTraceInd2=numTraces+maxGlobal+gID;
        saveImageInd2=numImages+maxGlobal+gID;
        ind1=find(globalIDs1==gID);
        ind2=find(globalIDs2==gID);
        if ~isempty(ind1)
            traceInd1=tracesToProcess1(ind1);
            imageInd1=imagesToProcess1(ind1);

            SpikeTraceData(saveTraceInd1)=SpikeTraceData(traceInd1);
            SpikeImageData(saveImageInd1)=SpikeImageData(imageInd1);
            
            SpikeTraceData(saveTraceInd1).ID('global')=gID;
            if ~hasGlobal1
                SpikeTraceData(saveTraceInd1).Label.ListText=['g ', num2str(gID), ' ', day1tag, ' ', num2str(ind1), ' ', SpikeTraceData(saveTraceInd1).Label.ListText];
            end
            
            SpikeImageData(saveImageInd1).ID('global')=gID;
            if ~hasGlobal1
                SpikeImageData(saveImageInd1).Label.ListText=['g ', num2str(gID), ' ', day1tag, ' ', num2str(ind1), ' ', SpikeImageData(saveImageInd1).Label.ListText];
            end
        else
            SpikeTraceData(saveTraceInd1)=blankTrace1;
            if ~isempty(ind2)
                SpikeImageData(saveImageInd1)=SpikeImageData(imagesToProcess2(ind2));
            else
                SpikeImageData(saveImageInd1)=blankImage1;
            end

            SpikeTraceData(saveTraceInd1).ID('global')=gID;
            if ~hasGlobal2
                SpikeTraceData(saveTraceInd1).Label.ListText=['g ', num2str(gID), ' ', day1tag, ' zeros'];
            end

            SpikeImageData(saveImageInd1).ID('global')=gID;
            if ~hasGlobal2
                SpikeImageData(saveImageInd1).Label.ListText=['g ', num2str(gID), ' ', day1tag, ' zeros'];
            end
        end
        
        if ~isempty(ind2)
            traceInd2=tracesToProcess2(ind2);
            imageInd2=imagesToProcess2(ind2);

            SpikeTraceData(saveTraceInd2)=SpikeTraceData(traceInd2);
            SpikeImageData(saveImageInd2)=SpikeImageData(imageInd2);
            
            SpikeTraceData(saveTraceInd2).ID('global')=gID;
            SpikeTraceData(saveTraceInd2).Label.ListText=['g ', num2str(gID), ' ', day2tag, ' ', num2str(ind2), ' ', SpikeTraceData(saveTraceInd2).Label.ListText];

            SpikeImageData(saveImageInd2).ID('global')=gID;
            SpikeImageData(saveImageInd2).Label.ListText=['g ', num2str(gID), ' ', day2tag, ' ', num2str(ind2), ' ', SpikeImageData(saveImageInd2).Label.ListText];
        else
            SpikeTraceData(saveTraceInd2)=blankTrace2;
            if ~isempty(ind1)
                SpikeImageData(saveImageInd2)=SpikeImageData(imagesToProcess1(ind1));
            else
                SpikeImageData(saveImageInd2)=blankImage2;
            end

            SpikeTraceData(saveTraceInd2).ID('global')=gID;
            SpikeTraceData(saveTraceInd2).Label.ListText=['g ', num2str(gID), ' ', day2tag, ' zeros'];

            SpikeImageData(saveImageInd2).ID('global')=gID;
            SpikeImageData(saveImageInd2).Label.ListText=['g ', num2str(gID), ' ', day2tag, ' zeros'];
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



% --- Executes on selection change in Set1ImageSelector.
function Set1ImageSelector_Callback(hObject, eventdata, handles)
% hObject    handle to Set1ImageSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Set1ImageSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Set1ImageSelector


% --- Executes during object creation, after setting all properties.
function Set1ImageSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Set1ImageSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Set2Label_Callback(hObject, eventdata, handles)
% hObject    handle to Set2Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Set2Label as text
%        str2double(get(hObject,'String')) returns contents of Set2Label as a double


% --- Executes during object creation, after setting all properties.
function Set2Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Set2Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in Set2ImageSelector.
function Set2ImageSelector_Callback(hObject, eventdata, handles)
% hObject    handle to Set2ImageSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Set2ImageSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Set2ImageSelector


% --- Executes during object creation, after setting all properties.
function Set2ImageSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Set2ImageSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Set2TraceSelector.
function Set2TraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to Set2TraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Set2TraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Set2TraceSelector


% --- Executes during object creation, after setting all properties.
function Set2TraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Set2TraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxDistance_Callback(hObject, eventdata, handles)
% hObject    handle to MaxDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxDistance as text
%        str2double(get(hObject,'String')) returns contents of MaxDistance as a double


% --- Executes during object creation, after setting all properties.
function MaxDistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ViewMatched.
function ViewMatched_Callback(hObject, eventdata, handles)
% hObject    handle to ViewMatched (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ViewMatched


% --- Executes on button press in ViewNonmatched.
function ViewNonmatched_Callback(hObject, eventdata, handles)
% hObject    handle to ViewNonmatched (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ViewNonmatched
if (get(handles.ViewNonmatched,'Value')==1)
    set(handles.MaxDistanceViewNonmatched,'Enable','on');
else
    set(handles.MaxDistanceViewNonmatched,'Enable','off');
end



function MaxDistanceViewNonmatched_Callback(hObject, eventdata, handles)
% hObject    handle to MaxDistanceViewNonmatched (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxDistanceViewNonmatched as text
%        str2double(get(hObject,'String')) returns contents of MaxDistanceViewNonmatched as a double


% --- Executes during object creation, after setting all properties.
function MaxDistanceViewNonmatched_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxDistanceViewNonmatched (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Set1Label_Callback(hObject, eventdata, handles)
% hObject    handle to Set1Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Set1Label as text
%        str2double(get(hObject,'String')) returns contents of Set1Label as a double


% --- Executes during object creation, after setting all properties.
function Set1Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Set1Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Set1TraceSelector.
function Set1TraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to Set1TraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Set1TraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Set1TraceSelector


% --- Executes during object creation, after setting all properties.
function Set1TraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Set1TraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in GlobalBehavior.
function GlobalBehavior_Callback(hObject, eventdata, handles)
% hObject    handle to GlobalBehavior (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns GlobalBehavior contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GlobalBehavior


% --- Executes during object creation, after setting all properties.
function GlobalBehavior_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GlobalBehavior (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
