function varargout = Decode(varargin)
% DECODE This App aligns one or more traces to points given in the
% binary alignment trace. Any point in the alignment trace with a 1 will be
% an alignment point, and all trace fragments surrounding an alignment
% point will be laid on top of one another. Useful for traces which contain
% multiple repeats of the same experiment, cue, or action.
%
% Output will save as many traces as are input; each will be of length (#
% frames before) + 1 + (# frames after), as set in the GUI.
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Decode

% Last Modified by GUIDE v2.5 06-Mar-2013 15:15:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Decode_OpeningFcn, ...
                   'gui_OutputFcn',  @Decode_OutputFcn, ...
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
function Decode_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Decode (see VARARGIN)

% Choose default command line output for Decode
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeTraceData

if ~isempty(SpikeTraceData)
    for i=1:length(SpikeTraceData)
        TextTrace{i}=[num2str(i),' - ',SpikeTraceData(i).Label.ListText]; %#ok<AGROW>
    end
    set(handles.XTraceSelector,'String',TextTrace);
    set(handles.YTraceSelector, 'String', TextTrace);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.XTraceSelector,'Value',Settings.XTraceSelectorValue);
    set(handles.YTraceSelector,'Value',Settings.YTraceSelectorValue);
    set(handles.NumCrossVal, 'String', Settings.NumCrossValString);
    set(handles.NumberPastFeatures, 'String', Settings.NumberPastFeaturesString);
    set(handles.NumberYValues, 'String', Settings.NumberYValuesString);
    set(handles.EndTime, 'String', Settings.EndTimeString);
    set(handles.StartTime, 'String', Settings.StartTimeString);
    set(handles.NumberExcludeBins, 'String', Settings.NumberExcludeBinsString);
    set(handles.VelocityCutoff, 'String', Settings.VelocityCutoffString);
    set(handles.NumSmooth, 'String', Settings.NumSmoothString);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.XTraceSelectorValue=get(handles.XTraceSelector,'Value');
Settings.YTraceSelectorValue=get(handles.YTraceSelector,'Value');
Settings.NumCrossValString=get(handles.NumCrossVal, 'String');
Settings.NumberPastFeaturesString=get(handles.NumberPastFeatures, 'String');
Settings.NumberYValuesString=get(handles.NumberYValues, 'String');
Settings.StartTimeString=get(handles.StartTime, 'String');
Settings.NumberExcludeBinsString=get(handles.NumberExcludeBins, 'String');
Settings.EndTimeString=get(handles.EndTime, 'String');
Settings.VelocityCutoffString=get(handles.VelocityCutoff, 'String');
Settings.NumSmoothString=get(handles.NumSmooth, 'String');


% --- Outputs from this function are returned to the command line.
function varargout = Decode_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.output;


% 'ApplyApps' is the main function of your Apps. It is launched by the
% Main interface when using batch mode. 
function ApplyApps_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SpikeTraceData

try
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    % get parameters from interface
    trainEventTraceInds=get(handles.XTraceSelector, 'Value');
    yTraceInd=get(handles.YTraceSelector, 'Value');
    numValuesY=str2double(get(handles.NumberYValues, 'String'));
    numTraces=length(SpikeTraceData);
    numXtraces=length(trainEventTraceInds);
    numCrossVal=str2double(get(handles.NumCrossVal, 'String'));
    numBinsExclude=str2double(get(handles.NumberExcludeBins, 'String'));
    useMedianError=1;
    
    h=waitbar(0, 'Building and testing decoder...');
    
    % construct discrete Y
    timeTrace=SpikeTraceData(trainEventTraceInds(1)).XVector;
    oldYtrace=SpikeTraceData(yTraceInd).Trace;
    oldYtime=SpikeTraceData(yTraceInd).XVector;
    xTime=timeTrace;
    yTrace=zeros(size(timeTrace));
    for timeInd=1:length(timeTrace)
        [~, closestYtimeInd]=min(abs(oldYtime-xTime(timeInd)));
        yTrace(timeInd)=oldYtrace(closestYtimeInd);
    end
    
    % get velocity
    if size(yTrace,1)==1
        velocityTrace=[diff(yTrace), 0];
    else
        velocityTrace=[diff(yTrace); 0];
    end
    
    % find times with the correct velocity, before the end time and after start
    beginTime=str2double(get(handles.StartTime, 'String'));
    endTime=str2double(get(handles.EndTime, 'String'));
    goodTimes=and(timeTrace>=beginTime, timeTrace<endTime);
    switch get(handles.VelocitySelector, 'Value')
        case 1
            goodTimes=goodTimes;
        case 2
            goodTimes=and(goodTimes, velocityTrace>0);
        case 3
            goodTimes=and(goodTimes, velocityTrace<0);
    end
    
    maxVelocity=prctile(abs(velocityTrace), 97);
    minimumReqVelocity=maxVelocity*str2num(get(handles.VelocityCutoff, 'String'));
    goodTimes=and(goodTimes, abs(velocityTrace)>minimumReqVelocity);
    
    yTrace=round((yTrace-min(yTrace))*(numValuesY-1)/(max(yTrace)-min(yTrace)));
    yTrace(yTrace<=numBinsExclude-1)=-1;
    yTrace(yTrace>=(numValuesY-numBinsExclude))=-1;
    goodTimes=and(goodTimes, yTrace>0);
    yTrace=yTrace(goodTimes);

    pf=str2double(get(handles.NumberPastFeatures, 'String'));
    smoothLength=str2double(get(handles.NumSmooth, 'String'));

    plotErrorHist=get(handles.MakeErrorHist, 'Value');

    testEventTraceInds=trainEventTraceInds;
        
    smoothVec=ones(1,smoothLength);

    meanErr=zeros(numCrossVal,1);
    allOutputs=cell(numCrossVal,1);
    testCategories=cell(numCrossVal,1);
    allErrors=cell(numCrossVal,1);
    allTestTimeInds=cell(numCrossVal,1);
    
    numFramesPerCross=round(sum(goodTimes)/numCrossVal);


    for crossValInd=1:numCrossVal
        
        waitbar(crossValInd/numCrossVal, h)
        
        if crossValInd~=numCrossVal
            testTimeInds=((crossValInd-1)*numFramesPerCross+1):crossValInd*numFramesPerCross;
        else
            testTimeInds=((crossValInd-1)*numFramesPerCross+1):sum(goodTimes);
        end
            
        trainTimeInds=1:sum(goodTimes);
        trainTimeInds(testTimeInds)=[];

        %%% train
        Y=yTrace(trainTimeInds);
        if size(Y,1)>1
            Y=Y';
        end

        A=zeros(length(SpikeTraceData(trainEventTraceInds(1)).Trace(trainTimeInds)), length(trainEventTraceInds));
        for ind=1:length(trainEventTraceInds)
            thisTrace=SpikeTraceData(trainEventTraceInds(ind)).Trace(goodTimes);
            thisTrace=thisTrace(trainTimeInds);
            A(:,ind)=conv(thisTrace, smoothVec, 'same');
        end

        [A,Y]=getPastFutureMatrix(A, Y, pf);

        trainMatrix=sparse(A);  % time x numfeatures (cells*(pf+1))
        trainCategory=Y;

        numTrainPoints = size(trainMatrix, 1);
        numFeatures = size(trainMatrix, 2);

        % addition terms inside each probability calculation are for laplacian
        % smoothing: takes care of occasional lack of examples of combinations
        logProb1givenPos=-100*ones(max(trainCategory), numFeatures);
        logProb0givenPos=-100*ones(max(trainCategory), numFeatures);
        logProbPos=-100*ones(max(trainCategory),1);

        positions=unique(trainCategory);
        for pos=positions
           theseExamples=trainMatrix(trainCategory==pos,:);
           logProb1givenPos(pos, :)=log(sum(theseExamples,1)+1)-log(size(theseExamples,1)+2);
           logProb0givenPos(pos, :)=log(sum(1-theseExamples,1)+1)-log(size(theseExamples,1)+2);
           logProbPos(pos)=log(size(theseExamples,1)+1)-log(numTrainPoints+max(trainCategory)-min(trainCategory)); 
        end

        logProbX1=log(sum(trainMatrix, 1)+1)-log(numTrainPoints);       % 1 x numfeatures
        logProbX0=log(sum(1-trainMatrix, 1)+1)-log(numTrainPoints);

        %%% test
        Ytest=yTrace(testTimeInds);

        if size(Ytest,1)>1
            Ytest=Ytest';
        end

        Atest=zeros(length(SpikeTraceData(testEventTraceInds(1)).Trace(testTimeInds)), length(testEventTraceInds));
        for ind=1:length(testEventTraceInds)
            thisTrace=SpikeTraceData(testEventTraceInds(ind)).Trace(goodTimes);
            thisTrace=thisTrace(testTimeInds);
            Atest(:,ind)=conv(thisTrace, smoothVec, 'same');
        end

        [Atest,Ytest]=getPastFutureMatrix(Atest, Ytest, pf);

        testMatrix = sparse(Atest);
        testCategory = Ytest;

        numTestPoints = size(testMatrix, 1);
        output = zeros(1, numTestPoints);

        testMatrix=sparse(testMatrix);

        cvals=positions;
        logProb=zeros(numTestPoints, max(positions));
        for c=cvals
            logProb(:,c)=testMatrix*logProb1givenPos(c,:)'+(1-testMatrix)*logProb0givenPos(c,:)'+logProbPos(c)-(testMatrix*logProbX1'+(1-testMatrix)*logProbX0');
        end

        for ii=1:length(output)
            thisProb=exp(logProb(ii,:));
            [~,maxind]=max(thisProb);
            output(ii)=maxind;
        end

        errors=abs(output-testCategory);
        if useMedianError
            meanErr(crossValInd)=median(errors);
        else
            meanErr(crossValInd)=mean(errors);
        end

        allOutputs{crossValInd}=output;

        testCategories{crossValInd}=testCategory;

        allErrors{crossValInd}=errors;

        allTestTimeInds{crossValInd}=testTimeInds;
        
        if get(handles.MakeCValPlots, 'Value')
            figure;
            plot(testCategory, 'k', 'Linewidth', 2)
            hold on
            plot(output, 'r.')
        end

    end


    if plotErrorHist
        allErrorsAllTest=[];
        for tr=1:crossValInd
            allErrorsAllTest=[allErrorsAllTest, allErrors{crossValInd}]; %#ok<AGROW>
        end
        figure; hist(allErrorsAllTest, 0:numValuesY)
        xlim([-1 numValuesY])
        set(gca, 'Fontsize', 14)
        xlabel('Decoder Error (bins)')
        title(['Decoder, min vel = ' num2str(minimumReqVelocity) ' cm/s, # past features = ' num2str(pf)]);
        ylabel('Number frames')
    end
    
    SpikeTraceData(numTraces+1).Trace=allErrorsAllTest;
    SpikeTraceData(numTraces+1).DataSize=size(SpikeTraceData(numTraces+1).Trace);
    SpikeTraceData(numTraces+1).XVector=1:length(allErrorsAllTest);
    SpikeTraceData(numTraces+1).Label.ListText=['all decode errors, c=' num2str(numCrossVal)];
    SpikeTraceData(numTraces+1).Label.XLabel='frame in cross validation';
    SpikeTraceData(numTraces+1).Label.YLabel='decoder error (bins)';
    
    delete(h)
    
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

function [Aout,Yout]=getPastFutureMatrix(A, Y, pf)
Aout=A;
Yout=Y;

for k=1:pf
   Aout=[[zeros(k,size(A,2)); A(1:end-k,:)], Aout];
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



% --- Executes on selection change in XtraceIndselector.
function XTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to XtraceIndselector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns XtraceIndselector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from XtraceIndselector


% --- Executes during object creation, after setting all properties.
function XTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XtraceIndselector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in YTraceSelector.
function YTraceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to YTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns YTraceSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from YTraceSelector


% --- Executes during object creation, after setting all properties.
function YTraceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YTraceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NumCrossVal_Callback(hObject, eventdata, handles)
% hObject    handle to NumCrossVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumCrossVal as text
%        str2double(get(hObject,'String')) returns contents of NumCrossVal as a double


% --- Executes during object creation, after setting all properties.
function NumCrossVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumCrossVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NumberPastFeatures_Callback(hObject, eventdata, handles)
% hObject    handle to NumberPastFeatures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumberPastFeatures as text
%        str2double(get(hObject,'String')) returns contents of NumberPastFeatures as a double


% --- Executes during object creation, after setting all properties.
function NumberPastFeatures_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumberPastFeatures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NumberYValues_Callback(hObject, eventdata, handles)
% hObject    handle to NumberYValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumberYValues as text
%        str2double(get(hObject,'String')) returns contents of NumberYValues as a double


% --- Executes during object creation, after setting all properties.
function NumberYValues_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumberYValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StartTime_Callback(hObject, eventdata, handles)
% hObject    handle to StartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartTime as text
%        str2double(get(hObject,'String')) returns contents of StartTime as a double


% --- Executes during object creation, after setting all properties.
function StartTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartTime (see GCBO)
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


% --- Executes on selection change in VelocitySelector.
function VelocitySelector_Callback(hObject, eventdata, handles)
% hObject    handle to VelocitySelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns VelocitySelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from VelocitySelector


% --- Executes during object creation, after setting all properties.
function VelocitySelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VelocitySelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NumberExcludeBins_Callback(hObject, eventdata, handles)
% hObject    handle to NumberExcludeBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumberExcludeBins as text
%        str2double(get(hObject,'String')) returns contents of NumberExcludeBins as a double


% --- Executes during object creation, after setting all properties.
function NumberExcludeBins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumberExcludeBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VelocityCutoff_Callback(hObject, eventdata, handles)
% hObject    handle to VelocityCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VelocityCutoff as text
%        str2double(get(hObject,'String')) returns contents of VelocityCutoff as a double


% --- Executes during object creation, after setting all properties.
function VelocityCutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VelocityCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NumSmooth_Callback(hObject, eventdata, handles)
% hObject    handle to NumSmooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumSmooth as text
%        str2double(get(hObject,'String')) returns contents of NumSmooth as a double


% --- Executes during object creation, after setting all properties.
function NumSmooth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumSmooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MakeCValPlots.
function MakeCValPlots_Callback(hObject, eventdata, handles)
% hObject    handle to MakeCValPlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MakeCValPlots


% --- Executes on button press in MakeErrorHist.
function MakeErrorHist_Callback(hObject, eventdata, handles)
% hObject    handle to MakeErrorHist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MakeErrorHist


% --- Executes on key press with focus on MakeCValPlots and none of its controls.
function MakeCValPlots_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to MakeCValPlots (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
