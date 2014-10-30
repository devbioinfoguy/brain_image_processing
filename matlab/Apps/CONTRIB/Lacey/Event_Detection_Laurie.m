function varargout = Event_Detection_Laurie(varargin)
% EVENT_DETECTION_LAURIE This App is designed for detecting events in a trace,
% such as a trace representing Calcium activity or voltage. It performs no
% shape matching but simply detects when the trace is above a set threshold
% (set in terms of the mean and std of each trace). It has the following
% options:
% - require trace to stay above the threshold for a certain number of
% frames or seconds
% - require trace to have an n-frame average value, over some window which
% contains the peak value, above threshold
% - require that events be some number of frames or seconds apart. This
% option will always rule in favor of the first event.
% - report event time as the time in between peak and trough time (midpoint
% rise time), or as the peak time
%
% The output is a binary trace which contains a 1 at the time of event, and
% a 0 at all other times.
%
% Note: the threshold is set in terms of the peak-to-trough value, rather
% than the absolute value of the trace. Thus, if an event occurs before the
% previous event has finished its exponential falloff, that event must
% raise the trace value by an additional threshold amount relative to the
% previous value.
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Event_Detection_Laurie

% Last Modified by GUIDE v2.5 20-Jan-2013 23:27:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Event_Detection_Laurie_OpeningFcn, ...
                   'gui_OutputFcn',  @Event_Detection_Laurie_OutputFcn, ...
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
function Event_Detection_Laurie_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Event_Detection_Laurie (see VARARGIN)

% Choose default command line output for Event_Detection_Laurie
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeTraceData
global SpikeImageData

if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText];
    end
    set(handles.TraceSelector,'String',TextTrace);
end

if ~isempty(SpikeImageData)
    for i=1:length(SpikeImageData)
        TextImage{i}=[num2str(i),' - ',SpikeImageData(i).Label.ListText];
    end
    set(handles.ImageSelector,'String',TextImage);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.TraceSelector,'Value',Settings.TraceSelectorValue);
    set(handles.StdDevs, 'String', Settings.StdDevsString);
    set(handles.OffsetFrames, 'String', Settings.OffsetFramesString);
    set(handles.KeepTraces, 'Value', Settings.KeepTracesValue);
    set(handles.UseAllTraces, 'Value', Settings.UseAllTracesValue);
    set(handles.MinTimeBtEvents, 'String', Settings.MinTimeBtEventsString);
    set(handles.NumFramesLocalAverage, 'String', Settings.NumFramesLocalAverageString);
    set(handles.ReportMidpoint, 'Value', Settings.ReportMidpointValue);
    set(handles.MovAvgReqSize, 'String', Settings.MovAvgReqSizeString);
    set(handles.OverlapRadius, 'String', Settings.OverlapRadiusString);
    set(handles.RecordAmplitude, 'Value', Settings.RecordAmplitudeValue);
    set(handles.ImageSelector, 'Value', Settings.ImageSelectorValue);
    set(handles.DoOrdFilt, 'Value', Settings.DoOrdFiltValue)
    set(handles.OrdFiltDomain, 'String', Settings.OrdFiltDomainString);
    set(handles.OrdFiltOrder, 'String', Settings.OrdFiltOrderString);
    set(handles.DoMovingAverage, 'Value', Settings.DoMovingAverageString);
end
UseAllImages_Callback(hObject, eventdata, handles)
UseAllTraces_Callback(hObject, eventdata, handles)

% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TraceSelectorString=get(handles.TraceSelector,'String');
Settings.TraceSelectorValue=get(handles.TraceSelector,'Value');
Settings.StdDevsString=get(handles.StdDevs, 'String');
Settings.OffsetFramesString=get(handles.OffsetFrames, 'String');
Settings.KeepTracesValue=get(handles.KeepTraces, 'Value');
Settings.UseAllTracesValue=get(handles.UseAllTraces, 'Value');
Settings.MinTimeBtEventsString=get(handles.MinTimeBtEvents, 'String');
Settings.NumFramesLocalAverageString=get(handles.NumFramesLocalAverage, 'String');
Settings.ReportMidpointValue=get(handles.ReportMidpoint, 'Value');
Settings.OverlapRadiusString=get(handles.OverlapRadius,'String');
Settings.MovAvgReqSizeString=get(handles.MovAvgReqSize,'String');
Settings.RecordAmplitudeValue=get(handles.RecordAmplitude, 'Value');
Settings.ImageSelectorValue=get(handles.ImageSelector, 'Value');
Settings.DoOrdFiltValue = get(handles.DoOrdFilt, 'Value');
Settings.OrdFiltOrderString = get(handles.OrdFiltOrder, 'String');
Settings.OrdFiltDomainString = get(handles.OrdFiltDomain, 'String');
Settings.DoMovingAverageString = get(handles.DoMovingAverage, 'Value');

% --- Outputs from this function are returned to the command line.
function varargout = Event_Detection_Laurie_OutputFcn(hObject, eventdata, handles) 
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

try
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    %h=waitbar(0.05, 'Processing...');
    % get parameters from interface
    if get(handles.UseAllTraces, 'Value')
        tracesToProcess=1:length(SpikeTraceData);
    else
        tracesToProcess=get(handles.TraceSelector, 'Value');
    end

    keepTraces=get(handles.KeepTraces, 'Value');
    if keepTraces
        numTraces=length(SpikeTraceData);
    end
    offsetFrames=str2double(get(handles.OffsetFrames, 'String'));

    [offsetpeaks, peakrise] = neighborPeaksAndSizes(handles);
    
    for cellNum=1:length(tracesToProcess)
        thesePeaks=offsetpeaks{cellNum};
        theseRises=peakrise{cellNum};
        thesePeaks=thesePeaks-offsetFrames;
        peakrise{cellNum}=theseRises(thesePeaks>0);
        offsetpeaks{cellNum}=thesePeaks(thesePeaks>0);
    end
    
    for i=1:length(tracesToProcess)
        trInd=tracesToProcess(i);
        if keepTraces
            saveInd=numTraces+i;
            SpikeTraceData(saveInd)=SpikeTraceData(trInd);
        else
            saveInd=trInd;
        end
        SpikeTraceData(saveInd).Trace=zeros(length(SpikeTraceData(saveInd).Trace),1);
        if get(handles.RecordAmplitude, 'Value')
            SpikeTraceData(saveInd).Trace(round(offsetpeaks{i}))=peakrise{i};
        else
            SpikeTraceData(saveInd).Trace(round(offsetpeaks{i}))=1;
        end
        SpikeTraceData(saveInd).Label.ListText=['events ', SpikeTraceData(trInd).Label.ListText];
    end
    
    
%     waitbar(1,h)
%     delete(h)
    
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





function [offsetpeaks, peakrise] = neighborPeaksAndSizes(handles)
%% testing cell neighbor contaminant elim and peak finding

global SpikeTraceData
global SpikeImageData

if get(handles.UseAllTraces, 'Value')
    tracesToProcess=1:length(SpikeTraceData);
else
    tracesToProcess=get(handles.TraceSelector, 'Value');
end

    waitbarInterval=round(length(tracesToProcess)/10);

traceLength=length(SpikeTraceData(tracesToProcess(1)).Trace);
celltraces=zeros(length(tracesToProcess), traceLength);
for ind=1:length(tracesToProcess)
    trInd=tracesToProcess(ind);
    if ~(length(SpikeTraceData(trInd).Trace)==traceLength)
        error('Traces not same length!')
    else
        celltraces(ind, :)=SpikeTraceData(trInd).Trace;
    end
end

if get(handles.UseAllImages, 'Value')
    imagesOfICs=1:length(SpikeImageData);
else
    imagesOfICs=get(handles.ImageSelector, 'Value');
end
icSize=size(SpikeImageData(imagesOfICs(1)).Image);
icmat=zeros([icSize, length(imagesOfICs)]);
if ~(length(imagesOfICs)==length(tracesToProcess))
    error('Must select same number of traces and IC images')
end
for ind=1:length(imagesOfICs)
    icInd=imagesOfICs(ind);
    if any(size(SpikeImageData(icInd).Image)~=icSize)
        error('IC Images not same size!')
    else
        icmat(:,:,ind)=SpikeImageData(icInd).Image;
    end
end

%use um space between criteria
neighborsCellFull = identifyNeighborsAuto(icmat, handles);

fprintf('Done assigning neighbor IDs ...')


%% Set up the analysis and calculate the SD of the full traces set

numCells = size(neighborsCellFull,1);
cellstdAll = zeros(numCells,1);


doOrdFilt = get(handles.DoOrdFilt, 'Value');
ordFiltOrder = str2double(get(handles.OrdFiltOrder, 'String'));
ordFiltDomain = str2double(get(handles.OrdFiltDomain, 'String'));

% Get SD by fitting gaussian to the histogrammed data (because of heavy pos
% tail from bursting)
for cellnum = 1 : numCells    
    xdata = linspace(-0.3,0.3,1000)';         %%%% might want to take a look at these values
    if doOrdFilt
        ydata = hist(celltraces(cellnum,:) - ...
            ordfilt2(celltraces(cellnum,:)',ordFiltOrder,ones(ordFiltDomain,1),'symmetric')',xdata)';
    else
        ydata=hist(celltraces(cellnum,:)-mean(celltraces(cellnum,:)), xdata)'; 
    end
    
    options = fitoptions('method','nonlinearleastsquares',...
        'startpoint',[100 0 0.01]);
    try
        fitres = fit(xdata,ydata,'gauss1',options);
        cellstdAll(cellnum,1) = (fitres.c1/sqrt(2));
    catch
        disp('fit failed...')
        cellstdAll(cellnum,1) = std(celltraces(cellnum,:));
    end
end
% clear celltraces
clear options fitres xdata ydata cellnum plotcount plottingOn

fprintf('Done calculating trace SD. \n')



%% Run the peak finding
%superiorPeaks = zeros(0,5);
origpeaks = cell(numCells,1);
finalpeaks = cell(numCells,1);
offsetpeaks = cell(numCells,1);
peakdecay = cell(numCells,1);
peakrise = cell(numCells,1);
thresh = zeros(numCells,1);

makeThePlot = get(handles.MakeThePlot, 'Value');
doMovAvg = get(handles.DoMovingAverage, 'Value');
movAvgFiltSize = str2double(get(handles.NumFramesLocalAverage, 'String'));
numStdsForThresh = str2double(get(handles.StdDevs, 'String'));
movAvgReqSize = str2double(get(handles.MovAvgReqSize, 'String'));
reportMidpoint = get(handles.ReportMidpoint, 'Value');
minTimeBtEvents=str2double(get(handles.MinTimeBtEvents,'String'));

    
% get the traces shifted by the filtered trace
if doOrdFilt
    inputtraces = celltraces'  - ordfilt2(celltraces', ordFiltOrder,ones(ordFiltDomain,1),'symmetric');
    inputtraces = inputtraces';
else
    inputtraces=celltraces;
end


for c=1:size(celltraces,1)
    offsetpeaks{c} = zeros(1,0);
    % set the threshold to a multiple of the SD of the trace for that cell
    thresh(c) = numStdsForThresh*cellstdAll(c);

    if doMovAvg
        inputsignal = filtfilt(ones(1,movAvgFiltSize)/movAvgFiltSize,1,inputtraces(c,:));
%         inputsignal = 1/2*(medfilt1(inputtraces(c,:),movAvgFiltSize)+...       %%% can remove or play with this avg/med combination
%             filtfilt(ones(1,movAvgFiltSize)/movAvgFiltSize,1,inputtraces(c,:)));
    else
        inputsignal=inputtraces(c,:);
    end

    [~,testpeaks] = findpeaks(inputsignal,'minpeakheight',thresh(c));
    [~,testpeaks2] = findpeaks(inputsignal,'minpeakdistance',minTimeBtEvents);
    testpeaks = intersect(testpeaks,testpeaks2);
    clear testpeaks2
    testpeaks = intersect(testpeaks,find(filtfilt(ones(1,movAvgReqSize)/movAvgReqSize,1,...
        inputtraces(c,:))>thresh(c)));


    if isempty(testpeaks)
        origpeaks{c} = zeros(1,0);
        finalpeaks{c} = zeros(1,0);
        peakrise{c} = zeros(1,0);
        offsetpeaks{c} = zeros(1,0);
        continue
    end
    if isempty(neighborsCellFull{c,1})
        [vectowrite,vectoramplitudes] = findRecentTroughs(inputsignal,inputsignal,testpeaks);
        okpeaks = vectoramplitudes > thresh(c); % get the peaks with increase greater than thresh

        origpeaks{c} = testpeaks(okpeaks);
        finalpeaks{c} = testpeaks(okpeaks);
        if reportMidpoint
            offsetpeaks{c} = 1/2*(testpeaks(okpeaks) + vectowrite(okpeaks));
        else
            offsetpeaks{c} = testpeaks{okpeaks};
        end
        peakrise{c} = vectoramplitudes(okpeaks);
    else
        [vectowrite,vectoramplitudes] = findRecentTroughs(inputsignal,inputsignal,testpeaks);
        okpeaks = vectoramplitudes > thresh(c);
        % don't write into 'finalpeaks'
        origpeaks{c} = testpeaks(okpeaks);
        % %             finalpeaks{c,m} = testpeaks(okpeaks);
        if reportMidpoint
            offsetpeaks{c} = 1/2*(testpeaks(okpeaks) + vectowrite(okpeaks));
        else
            offsetpeaks{c} = testpeaks{okpeaks};
        end
        peakrise{c} = vectoramplitudes(okpeaks);
    end
end

for c=1:size(celltraces,1)
    testpeaks = origpeaks{c};
    
    if doMovAvg
        filteredtrace = filtfilt(ones(1,movAvgFiltSize)/movAvgFiltSize,1,inputtraces(c,:));
%         filteredtrace = 1/2*(filtfilt(ones(1,movAvgFiltSize)/movAvgFiltSize,1,inputtraces(c,:))+...    %%% can remove or play with this avg/med combination
%             medfilt1(inputtraces(c,:),movAvgFiltSize));
    else
        filteredtrace=inputtraces(c,:);
    end
    % skip step if empty or no neighbors
    if isempty(testpeaks)
        continue
    end
    if isempty(neighborsCellFull{c,1})
        continue
    end

    % check each peak to see if (1) neighbor spikes w/in 2 frames &&
    % (2) neighbor amplitude is larger
    othersgreater = zeros(length(testpeaks),1);
    testcount = 0;
    for p = testpeaks
        testcount = testcount + 1;
        neighborcellampl = inputtraces(neighborsCellFull{c,1},p) > inputtraces(c,p);
        neighborcount = 0; 
        neighborcellpeak = [];
        for n = [neighborsCellFull{c,1}]'
            neighborcount = neighborcount + 1;
            neighborcellpeak(neighborcount) = ~isempty(intersect(origpeaks{n},p-2:1:p+2));
        end

        rankingmatrix = [];
        if any(size(neighborcellpeak)~=size(neighborcellampl))
            neighborcellpeak=neighborcellpeak';
        end
        if any(neighborcellampl & neighborcellpeak)
            othersgreater(testcount) = 1;
            %%% ranking matrix keeps information about all the neighbors,
            %%% whether they have a peak, peak size, cell number, etc
            %rankingmatrix(:,1) = neighborcellpeak; % 1/0 if have peak
            %rankingmatrix(:,2) = inputtraces(neighborsCellFull{c,1},p); % max amplitude around peak
            %rankingmatrix(:,3) = neighborsCellFull{c,1}; % cell number

            %rankingmatrix = sortrows(rankingmatrix,[-1 -2]);        %%% sort by whether have peak, then by peak size
            %rankingmatrix = rankingmatrix(1,:);                     %%% only take winning neighbor
            %rankingmatrix(1,4) = intersect(origpeaks{rankingmatrix(1,3)},p-2:1:p+2);
            %rankingmatrix(1,5) = 1; % add the trial number - %%% obsolete now
            %superiorPeaks = cat(1,superiorPeaks,rankingmatrix(1,:));
        end
        
        
        %%% not sure why this is here, since peak finding above had a
        %%% minimum distance between peaks
%         if any(filteredtrace(max(1,p-4):1:min(p+4,length(filteredtrace)))>filteredtrace(p))
%             othersgreater(testcount) = true;
%         end
    end
    clear neighborcellampl neighborcellpeak p testcount peakcount
    %%%% check the 'inputtraces' and take max within 3 frames back of
    %%%% it??

    %         othersgreater = max(inputtraces(neighborsCellFull{c,1},testpeaks),[],1) > ...
    %             inputtraces(c,testpeaks);
    %         testpeaks = testpeaks(~othersgreater);
    finalpeaks{c} = testpeaks(~othersgreater);
    offsetpeaks{c} = offsetpeaks{c}(~othersgreater);
    peakrise{c} = peakrise{c}(~othersgreater);

    % fix the dimensionality of the empty matrix
    if isempty(finalpeaks{c})
        finalpeaks{c} = zeros(1,0);
        offsetpeaks{c} = zeros(1,0);
        peakrise{c} = zeros(1,0);
    end

    %%% deleted something here with reference to filteredmoretrace,
    %%% peakdecay, other things

    if makeThePlot
        figure(29)
        clf;
        subplot(2,1,1)
        hold all
        plot(inputtraces(neighborsCellFull{c,1},:)')
        plot(inputtraces(c,:),'k','linewidth',2)
        plot(testpeaks,inputtraces(c,testpeaks),'r.','markersize',20)
        plot(finalpeaks{c},inputtraces(c,finalpeaks{c}),'b.','markersize',20)
        plot(round(offsetpeaks{c}),inputtraces(c,round(offsetpeaks{c})),'c.','markersize',16)
        plot(2*offsetpeaks{c} - finalpeaks{c},inputtraces(c,2*offsetpeaks{c} - finalpeaks{c}),'g.','markersize',16)
        title(sprintf('main cell number %d',c))
        hold off
        legend(num2str(cat(1,neighborsCellFull{c,1},c)))
        currentLims=ylim;
        ylim([-0.1, currentLims(2)])
        subplot(2,1,2)
        hold on
        plot(filteredtrace,'c','linewidth',2)
        plot(testpeaks,inputtraces(c,testpeaks),'r.','markersize',20)
        plot(finalpeaks{c},inputtraces(c,finalpeaks{c}),'b.','markersize',20)
        plot(round(offsetpeaks{c}),inputtraces(c,round(offsetpeaks{c})),'k.','markersize',16)
        plot(2*offsetpeaks{c} - finalpeaks{c},inputtraces(c,2*offsetpeaks{c} - finalpeaks{c}),'g.','markersize',16)
        hold off
        currentLims=ylim;
        ylim([-0.1, currentLims(2)])
        pause()
    end

end





function neighborsCell = identifyNeighborsAuto(icmat, handles)

%%%%%%%%%%%%
% this code automatically sorts through to find all cell neighbors within a
% certain distance of the target (boundary to boundary). the output is a
% cell with the vector of the neighbor indices in the target cell's entry.
% 
% Laurie Burns, Sept 2010.
%%%%%%%%%%%

global SpikeImageData

plottingOn = 0;

overlapradius = str2double(get(handles.OverlapRadius, 'String'));

cellvec(1) = 1;
cellvec(2) = size(icmat,3);


%% look for overlap of IC and dilated IC
neighborsCell=cell(cellvec(2),1);
se = strel('disk',overlapradius,0);
for c = 1:cellvec(2)
    thisCellDilateCopy = repmat(imdilate(icmat(:,:,c),se),[1 1 size(icmat,3)]);
    res = icmat.*thisCellDilateCopy;
    res = squeeze(sum(sum(res,2),1));
    res = find(res>0);
    neighborsCell{c,1} = setdiff(res,c);
    
    if mod(c,50)==1
        fprintf('up to cell number %d \n',c)
    end
end

%% if want to plot it
if plottingOn
    figure;
    colormap(gray);axis image
    hold on
    for c=1:size(icmat,3)
        contour(gaussblur1(icmat(:,:,c),2),1)
        [x,y] = ait_centroid(icmat(:,:,c));
        text(x-2,y,num2str(c),'fontsize',10)
    end
    clear c x y
    
    for cellnum = cellvec(1):cellvec(2)
        % bold red the main cell
        [x,y] = ait_centroid(icmat(:,:,cellnum));
        hmain = text(x-2,y,num2str(cellnum),'fontsize',10,'fontweight','bold','color','r');
        %     handle_array = cell(10,1);
        handle_array = [];

        for d = 1:length(neighborsCell{cellnum,1})
            %         counter = counter + 1;
            c = neighborsCell{cellnum,1}(d);
            [x,y] = ait_centroid(icmat(:,:,c));
            h = text(x-2,y,num2str(c),'fontsize',10,...
                'fontweight','bold','color','b');
            handle_array{d,1} = h;
            %             neighborVector = cat(1,neighborVector,c);
            %         end
        end
        %     neighborsCell{cellnum,1} = neighborVector;
        pause()
        delete(hmain)
        for hnum = 1:length(handle_array)
            delete(handle_array{hnum,1})
        end
    end
end



function [vectowrite,vectoramplitudes] = findRecentTroughs(inputtraces,filteredtrace,peakpoints)

% Laurie Burns, Aug 2011.

diffval = [0 diff(filteredtrace)];
diffval2 = filteredtrace(3:end)-filteredtrace(1:end-2);
diffval2 = [0 0 diffval2];
diffval3 = filteredtrace(5:end)-filteredtrace(1:end-4);
diffval3 = [0 0 0 0 diffval3];
diffval = diffval>0;
diffval2 = diffval2>0;
diffval3 = diffval3>0;
vectowrite = zeros(1,0);
vectoramplitudes = zeros(1,0);
for tp = peakpoints
    t1 = max(1,tp-40); t2 = tp-2;
    testdiff = diffval(t2:-1:t1);
    testdiff2 = diffval2(t2:-1:t1);
    testdiff3 = diffval3(t2:-1:t1);
    T = find((testdiff==0 & testdiff2==0 & testdiff3==0),1,'first');
    if ~isempty(T)
        T = t2-T+1;
        % calculate the difference in DF value
        vectoramplitudes = cat(2,vectoramplitudes,inputtraces(tp) - inputtraces(T));
    else T = t1;
        % if went to the max, just use the height
        vectoramplitudes = cat(2,vectoramplitudes,inputtraces(tp));
    end
    vectowrite = cat(2,vectowrite,T);
end




%% Rest of functions
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



function StdDevs_Callback(hObject, eventdata, handles)
% hObject    handle to StdDevs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StdDevs as text
%        str2double(get(hObject,'String')) returns contents of StdDevs as a double


% --- Executes during object creation, after setting all properties.
function StdDevs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StdDevs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MinTimeAboveThresh_Callback(hObject, eventdata, handles)
% hObject    handle to MinTimeAboveThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinTimeAboveThresh as text
%        str2double(get(hObject,'String')) returns contents of MinTimeAboveThresh as a double


% --- Executes during object creation, after setting all properties.
function MinTimeAboveThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinTimeAboveThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TimeAboveUnits.
function TimeAboveUnits_Callback(hObject, eventdata, handles)
% hObject    handle to TimeAboveUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TimeAboveUnits contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TimeAboveUnits


% --- Executes during object creation, after setting all properties.
function TimeAboveUnits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeAboveUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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


function OffsetFrames_Callback(hObject, eventdata, handles)
% hObject    handle to OffsetFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OffsetFrames as text
%        str2double(get(hObject,'String')) returns contents of OffsetFrames as a double


% --- Executes during object creation, after setting all properties.
function OffsetFrames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OffsetFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in KeepTraces.
function KeepTraces_Callback(hObject, eventdata, handles)
% hObject    handle to KeepTraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KeepTraces


% --- Executes on button press in UseAllTraces.
function UseAllTraces_Callback(hObject, eventdata, handles)
% hObject    handle to UseAllTraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UseAllTraces
if (get(handles.UseAllTraces,'Value')==1)
    set(handles.TraceSelector,'Enable','off');
else
    set(handles.TraceSelector,'Enable','on');
end



function NumFramesLocalAverage_Callback(hObject, eventdata, handles)
% hObject    handle to NumFramesLocalAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumFramesLocalAverage as text
%        str2double(get(hObject,'String')) returns contents of NumFramesLocalAverage as a double


% --- Executes during object creation, after setting all properties.
function NumFramesLocalAverage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumFramesLocalAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinTimeBtEvents_Callback(hObject, eventdata, handles)
% hObject    handle to MinTimeBtEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinTimeBtEvents as text
%        str2double(get(hObject,'String')) returns contents of MinTimeBtEvents as a double


% --- Executes during object creation, after setting all properties.
function MinTimeBtEvents_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinTimeBtEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TimeBtEventsUnits.
function TimeBtEventsUnits_Callback(hObject, eventdata, handles)
% hObject    handle to TimeBtEventsUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TimeBtEventsUnits contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TimeBtEventsUnits


% --- Executes during object creation, after setting all properties.
function TimeBtEventsUnits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeBtEventsUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ReportMidpoint.
function ReportMidpoint_Callback(hObject, eventdata, handles)
% hObject    handle to ReportMidpoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ReportMidpoint


% --- Executes on button press in DoOrdFilt.
function DoOrdFilt_Callback(hObject, eventdata, handles)
% hObject    handle to DoOrdFilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DoOrdFilt

if (get(handles.DoOrdFilt,'Value')==1)
    set(handles.OrdFiltOrder,'Enable','on');
    set(handles.OrdFiltDomain,'Enable','on');
else
    set(handles.OrdFiltOrder,'Enable','off');
    set(handles.OrdFiltDomain,'Enable','off');
end


function OrdFiltOrder_Callback(hObject, eventdata, handles)
% hObject    handle to OrdFiltOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OrdFiltOrder as text
%        str2double(get(hObject,'String')) returns contents of OrdFiltOrder as a double


% --- Executes during object creation, after setting all properties.
function OrdFiltOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OrdFiltOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function OrdFiltDomain_Callback(hObject, eventdata, handles)
% hObject    handle to OrdFiltDomain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OrdFiltDomain as text
%        str2double(get(hObject,'String')) returns contents of OrdFiltDomain as a double


% --- Executes during object creation, after setting all properties.
function OrdFiltDomain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OrdFiltDomain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DoMovingAverage.
function DoMovingAverage_Callback(hObject, eventdata, handles)
% hObject    handle to DoMovingAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DoMovingAverage



function MovAvgReqSize_Callback(hObject, eventdata, handles)
% hObject    handle to MovAvgReqSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MovAvgReqSize as text
%        str2double(get(hObject,'String')) returns contents of MovAvgReqSize as a double


% --- Executes during object creation, after setting all properties.
function MovAvgReqSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MovAvgReqSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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


% --- Executes on button press in UseAllImages.
function UseAllImages_Callback(hObject, eventdata, handles)
% hObject    handle to UseAllImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UseAllImages
if (get(handles.UseAllImages,'Value')==1)
    set(handles.ImageSelector,'Enable','off');
else
    set(handles.ImageSelector,'Enable','on');
end


function OverlapRadius_Callback(hObject, eventdata, handles)
% hObject    handle to OverlapRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OverlapRadius as text
%        str2double(get(hObject,'String')) returns contents of OverlapRadius as a double


% --- Executes during object creation, after setting all properties.
function OverlapRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OverlapRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MakeThePlot.
function MakeThePlot_Callback(hObject, eventdata, handles)
% hObject    handle to MakeThePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MakeThePlot


% --- Executes on button press in RecordAmplitude.
function RecordAmplitude_Callback(hObject, eventdata, handles)
% hObject    handle to RecordAmplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RecordAmplitude
