function varargout = Cell_Counter(varargin)
% CELL_COUNTER 
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Cell_Counter

% Last Modified by GUIDE v2.5 29-Sep-2012 11:40:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Cell_Counter_OpeningFcn, ...
                   'gui_OutputFcn',  @Cell_Counter_OutputFcn, ...
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
function Cell_Counter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Cell_Counter (see VARARGIN)

% Choose default command line output for Cell_Counter
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeMovieData
global SpikeImageData

if ~isempty(SpikeMovieData)
    for i=1:length(SpikeMovieData)
        TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
    end
    set(handles.MovieSelector,'String',TextMovie);
end

if ~isempty(SpikeImageData)
    for i=1:length(SpikeImageData)
        TextImage{i}=[num2str(i),' - ',SpikeImageData(i).Label.ListText];
    end
    set(handles.ImageSelector,'String',TextImage);
end

if ~get(handles.StartedCountingAlready, 'Value')
    set(handles.ImageSelector, 'Enable', 'off')
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.MovieSelector,'Value',Settings.MovieSelectorValue);
    set(handles.ImageSelector,'Value',Settings.ImageSelectorValue);
    set(handles.StartedCountingAlready, 'Value', Settings.StartedCountingAlreadyValue);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.ImageSelectorValue=get(handles.ImageSelector,'Value');
Settings.StartedCountingAlreadyValue=get(handles.StartedCountingAlready, 'Value');


% --- Outputs from this function are returned to the command line.
function varargout = Cell_Counter_OutputFcn(hObject, eventdata, handles) 
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

global SpikeMovieData
global SpikeImageData

try
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    % get parameters from interface
    stackInd=get(handles.MovieSelector, 'Value');
    maxZ=SpikeMovieData(stackInd).DataSize(3);
    if get(handles.StartedCountingAlready, 'Value')
        cellLocInd=get(handles.ImageSelector, 'Value');
        cellLocations=SpikeImageData(cellLocInd).Image;
    else
        cellLocInd=length(SpikeImageData)+1;
        cellLocations=zeros(3,0);
    end
       
    figh=figure;
    imagesc(SpikeMovieData(stackInd).Movie(:,:,1))
    hold on
    plot(cellLocations(1,cellLocations(3,:)==1),cellLocations(1,cellLocations(3,:)==1),'g*')
    title('Use up/down arrows to change z, press s to save and quit. CURRENT Z: 1')
    z=1;
    button=1;
    while isempty(button) || button~=115
        figure(figh)
        [x,y,button]=ginput(1);
        if button==30   % up
            figure(figh)
            if z>1
                z=z-1;
            end
        elseif button==31   % down
            if z<maxZ
                z=z+1;
            end
        else
            if button==117  % u for undo
                cellLocations(:,end)=[];
            elseif button==1
                cellLocations(:,end+1)=[x;y;z];
            end
        end
        hold off
        imagesc(SpikeMovieData(stackInd).Movie(:,:,z))
        hold on
        plot(cellLocations(1,cellLocations(3,:)==z), cellLocations(2,cellLocations(3,:)==z),'g*')
        plot(cellLocations(1,cellLocations(3,:)==z-3), cellLocations(2,cellLocations(3,:)==z-3),'b*')
        plot(cellLocations(1,cellLocations(3,:)==z-2), cellLocations(2,cellLocations(3,:)==z-2),'b*')
        plot(cellLocations(1,cellLocations(3,:)==z-1), cellLocations(2,cellLocations(3,:)==z-1),'b*')
        plot(cellLocations(1,cellLocations(3,:)==z+1), cellLocations(2,cellLocations(3,:)==z+1),'b*')
        plot(cellLocations(1,cellLocations(3,:)==z+2), cellLocations(2,cellLocations(3,:)==z+2),'b*')
        plot(cellLocations(1,cellLocations(3,:)==z+3), cellLocations(2,cellLocations(3,:)==z+3),'b*')
        title(['Use up/down arrows to change z, press u to undo, press s to save and quit. CURRENT Z: ', num2str(z)])
    end

    close(figh)
    SpikeImageData(cellLocInd).Image=cellLocations;
    SpikeImageData(cellLocInd).Label.ListText=['Cell Locations ', SpikeMovieData(stackInd).Label.ListText];
    SpikeImageData(cellLocInd).Label.XLabel=SpikeMovieData(stackInd).Label.XLabel;
    SpikeImageData(cellLocInd).Label.YLabel=SpikeMovieData(stackInd).Label.YLabel;
    
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

% Hint: listbox controls usually have a white background on Windows.
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




function MaxLengthDifference_Callback(hObject, eventdata, handles)
% hObject    handle to MaxLengthDifference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxLengthDifference as text
%        str2double(get(hObject,'String')) returns contents of MaxLengthDifference as a double


% --- Executes during object creation, after setting all properties.
function MaxLengthDifference_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxLengthDifference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeAfter_Callback(hObject, eventdata, handles)
% hObject    handle to TimeAfter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeAfter as text
%        str2double(get(hObject,'String')) returns contents of TimeAfter as a double


% --- Executes during object creation, after setting all properties.
function TimeAfter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeAfter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CuttingBehav.
function CuttingBehav_Callback(hObject, eventdata, handles)
% hObject    handle to CuttingBehav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CuttingBehav contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CuttingBehav


% --- Executes during object creation, after setting all properties.
function CuttingBehav_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CuttingBehav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in StartedCountingAlready.
function StartedCountingAlready_Callback(hObject, eventdata, handles)
% hObject    handle to StartedCountingAlready (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StartedCountingAlready

if ~get(handles.StartedCountingAlready, 'Value')
    set(handles.ImageSelector, 'Enable', 'off')
else
    set(handles.ImageSelector, 'Enable', 'on')    
end
