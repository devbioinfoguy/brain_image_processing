function varargout = Tutorial_Apps(varargin)
% TUTORIAL_APPS explain the basics of creating Apps for SpikeE.
% Please browse the M file. Comments are provided to explain how every
% function works. The interface also provides some explanations. 
% 
% Help can be written in the M file at the header. It will become available
% to Matlab, either by typing down 'help Tutorial_Apps' in the command line
% , or by cliking the Help button of your Apps.
% This is the most convenient way of creating help for your Apps
%
% To add your Apps to SpikeE is extremely easy. Use the GUIDE to create
% your interface FIG file code and initiate your M code. You can either start from
% scratch with GUIDE (as long as you follow to requirements of SpikeE)
% or open an existing Apps in GUIDE and change the filename and adjust 
% the code to your liking. 
% 
% When you are happy with your Apps, just copy both the M file and the
% associated FIG file under the Apps folder or a subfolder of the Apps
% folder. It will become immediately avaiable to an opened instance of
% SpikeE (if you refresh the current Apps list using the '.' button).
% SpikeE is making the list of available Apps by looking for FIG files.
% Basically, if your code does not have an interface file, it will not
% work with SpikeE. You HAVE to make an interface to your code ;-) ...
%
% If needed, you can have a subfolder dedicated to your Apps. Just make
% sure the subfolder is named EXACTLY the same as your Apps and is located
% in the same folder as your main M-file and your FIG-file.
%
% Please note that it is a good practice to create Guis with a 
% PROPORTIONAL resize behavior. This ensures that your Apps will show 
% properly on any screen resolution. To check this, open your Apps with 
% GUIDE and go to Tools->Gui Options...->Resize behavior.
% 
% To sum up, these are the requirements for an Apps to work nicely with
% SpikeE : 
%
% - Have an 'ApplyApps' button and callback where all the processing is done
% - Have a GetSettings function (not associated with any button, so it is
% not a callback) that output a 'Settings' structure to the main interface.
% - Program your 'OpeningFcn' to read this 'Settings' structure to reload
% previously saved settings.
% - Have a 'ValidateValues' button and callback to give back control to the
% main interface.
% - Optionaly a 'OpenHelp' button and function that display the comments in
% the header of your M-file.
% - Copy both your M-file and FIG-file in the 'Apps' folder or subfolder.
% - Read and/or modify one of the shared global variables and respect the
% way data is organized as explained in the Init files in 'Lib/'.
%
% The best way to respect these constraints from the start is to open the
% Apps 'Hello_World' in GUIDE and modify it at your convenience. This is the
% simplest Apps you can make. It will ensure that all these requirements are
% met. 
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help Tutorial_Apps

% Last Modified by GUIDE v2.5 20-Feb-2012 16:54:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Tutorial_Apps_OpeningFcn, ...
                   'gui_OutputFcn',  @Tutorial_Apps_OutputFcn, ...
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
% You probably want to add code that adjust your settings buttons depending on the
% current state of data in the main interface and/or of the global variable
% SpikeMovieData, SpikeTraceData, SpikeImageData and SpikeGui
function Tutorial_Apps_OpeningFcn(hObject, eventdata, handles, varargin)

% handles.ouput if a very convenient way to get access to the object behind
% your Apps. the function 'gcbo' will not work properly in batch mode as the
% background object is the main interface not your interface.
% handles.output will give you access to your interface object.
handles.output = hObject;

% Update handles structure
guidata(handles.output, handles);

% Apps and the main interface share data through 4 global variables :
% SpikeGui, SpikeMovieData, SpikeTraceData and SpikeImageData. You can
% read and write to these structures as you wish. You MUST keep the same
% formating and respect the way data is stored otherwise SpikeE will likely
% crash. The main interface keep track of modification done on these
% variables between instances of Apps. For instance, if you add a new
% movie, it will update the movie list. To understand how these global
% variables are organized, please look into Lib/InitGUI, Lib/InitMovies,
% Lib/InitTraces and Lib/InitImages.
global SpikeMovieData;

if (length(varargin)>1)
% Here we read from the Settings structure created by the function
% GetSettings. This is used to reload saved settings from a previously
% opened instance of this Apps in the batch list.
% You must update this part to fit with how your Apps is reloaded from its
% saved data.
    Settings=varargin{2};
    set(handles.MovieSelector,'Value',Settings.MovieSelectorValue);
    set(handles.MovieSelector,'String',Settings.MovieSelectorString);
else
    % If no settings files are sent to the Apps, then it uses the default
    % values of your Gui as a start. You may place here some code that is
    % still needed to populate your Apps even at the first Opening. Here,
    % for instance, we update a list of available movies on the interface.
    if ~isempty(SpikeMovieData)
        for i=1:length(SpikeMovieData)
            TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
        end
        
        set(handles.MovieSelector,'String',TextMovie);
    end
end
    

% This function send the current settings to the main interface for saving
% purposes and for the batch mode. It is important to HAVE this function
% for the batch mode to work properly. The Name of this function should be
% exactly spelled the same (ie 'GetSettings'). 
% It output a structure Settings with one field per saved feature. 
% You can organize this structure
% as you wish as long as the above 'OpeningFcn' is able to read the
% Settings structure to populate your interface with previously saved
% features. You can also saved any relevant data that are meant to be
% reloaded when your interface is opened again. 
function Settings=GetSettings(hObject)

% Here we get the handles to the object on the Apps interface
handles=guidata(hObject);

% We extract the relevant variables from the interface object.
Settings.MovieSelectorValue=get(handles.MovieSelector,'Value');
Settings.MovieSelectorString=get(handles.MovieSelector,'String');


% This function return the object to your main interface. It is used by the main
% interface to close your Apps or to launch sub-function (like 'GetSettings' 
% or 'ApplyApps').
function varargout = Tutorial_Apps_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% 'ValidateValues' is the LAST function that should be executed by your
% Apps. It uses the function uiresume in the end. When an Apps is opened 
% by the main interface, it put the main interface on HOLD using 'uiwait'.
% uiresume give back control to the main interface. The main interface take care
% of closing your Apps if needed. In some occasions, it will launch
% 'GetSettings' before closing your Apps, to be able to save your
% parameters for the next time you open this Apps in the batch list.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% uiresume gives back control to the main interface
uiresume;


% 'ApplyApps' is the main function of your Apps. It is launched by the
% Main interface when using batch mode. So your are required to keep the
% exact same spelling name for this function. To make your function
% batch-compatible, ALL the operation that you want to be batched should be
% in this function. You can have sub-functions within this M file, but they
% will need to be executed by the 'Apply_Apps_Callback' to be properly
% batched from the main interface.
% This particular example, normalize a selected movie along the rows and
% columns.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% As stated in Tutorial_Apps_OpeningFcn, Apps shared data through global
% variables
global SpikeMovieData;

% It is a very good practice to put your main code between TRY and CATCH
% this ensures that errors are properly taken care of and displayed to the
% user.
try
    % These 2 lines find the object on the Apps that are enable to turn
    % them off. This is to have a 'Grayed' Apps during processing. This
    % ensures that the user is not push any button or else during
    % processing which could cause some unexpected behavior.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    % We open the waitbar
    h=waitbar(0,'Normalising movie...');
    
    % We get the selected movie value from the interface.
    MovieSel=get(handles.MovieSelector,'Value');
    
    % This is to ensure that the waitbar is not called too often. Too many
    % called to the waitbar usually slow down programs a lot.
    dividerWaitbar=10^(floor(log10(SpikeMovieData(MovieSel).DataSize(3)))-1);
    
    % To keep track of the datatype in the global variable.
    LocalClass=class(SpikeMovieData(MovieSel).Movie);
    
    % Here we check based on the dataype how to deal with this normalisation
    if strcmp(LocalClass,'single') || strcmp(LocalClass,'double')
        MaxValue=1/2;
    else
        MaxValue=intmax(LocalClass)/2;
    end
    
    for i=1:SpikeMovieData(MovieSel).DataSize(3)
        data=SpikeMovieData(MovieSel).Movie(:,:,i);
        meanRows = single(repmat(mean(data,1),size(data,1),1));
        meanCols = single(repmat(mean(data,2),1,size(data,2)));
        meanRows = meanRows.*meanCols/mean(meanCols(size(data,2)/2,:));
        
        % Here we modified the data stored in the global variable.
        % It is a good practice to think about data type before writing to the
        % global variables. SpikeE does not assume any datatype for its
        % variables. This is determined by the Loading Apps. This is to ensure
        % minimal use of memory. So you should program your Apps to adjust
        % its datatype to the current dataype in memory, unless higher
        % precision is required. Here we use the 'cast' function to bring back
        % the datatype to its original value.
        SpikeMovieData(MovieSel).Movie(:,:,i)=cast(single(MaxValue)*single(data)./meanRows,LocalClass);
        
        % We only update the waitbar on a subset of iterations
        if (round(i/dividerWaitbar)==i/dividerWaitbar)
            waitbar(i/SpikeMovieData(MovieSel).DataSize(3),h);
        end
    end
    
    % We close the waitbar
    delete(h);
    
    % ValidateValues is executed in the end to trigger the end of your Apps and
    % check all unneeded windows are closed.
    ValidateValues_Callback(hObject, eventdata, handles);
    
    % We turn back on the interface so that the user can interact with it
    % again.
    set(InterfaceObj,'Enable','on');
    
% everything under catch is executed when an error occurs.     
catch errorObj
    
    % We turn back on the interface so that the user can interact with it
    % again.
    set(InterfaceObj,'Enable','on');
    
    % If there is a problem, we display the error message. This is very
    % usefull to debugging. 
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
    
    % We close the waitbar if still exist.
    if exist('h','var')
        if ishandle(h)
            delete(h);
        end
    end
end

% This function  functionopens the help that is written in the header of this M file.
% It is generic to any Apps, so you can just keep exactly the same code for
% your Apps as long as your 'OpenHelp' button is present on the interface
% window.
function OpenHelp_Callback(hObject, eventdata, handles)
% hObject    handle to OpenHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CurrentMfilePath = mfilename('fullpath');
[PathToM, name, ext] = fileparts(CurrentMfilePath);
eval(['doc ',name]);


% The following functions were created by the GUIDE. We don't make use of
% them here but your could if you wanted. For instance, you could put some
% code in MovieSelector_Callback to trigger some processing when the value
% of selected item is change. 
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


% --- Executes on button press in NormRow.
function NormRow_Callback(hObject, eventdata, handles)
% hObject    handle to NormRow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NormRow


% --- Executes on button press in NormColumn.
function NormColumn_Callback(hObject, eventdata, handles)
% hObject    handle to NormColumn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NormColumn
