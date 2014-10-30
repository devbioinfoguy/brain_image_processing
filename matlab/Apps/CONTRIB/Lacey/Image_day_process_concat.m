function varargout = Image_day_process_concat(varargin)
% IMAGE_DAY_PROCESS_CONCAT 
%This APP goes through the files listed in filelist and downsamples,
%normalizes, and saves the files.

% Last Modified by Maggie 5-Sep-2012 21:34:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Image_day_process_concat_OpeningFcn, ...
                   'gui_OutputFcn',  @Image_day_process_concat_OutputFcn, ...
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
function Image_day_process_concat_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Image_day_process_concat (see VARARGIN)

% Choose default command line output for Image_day_process_concat
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Here we read from the Settings structure created by the function
% GetSettings. This is used to reload saved settings from a previously
% opened instance of this Apps in the batch list.
if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.ListFile,'String',Settings.ListFileString);  
    set(handles.SpatDown,'String',Settings.SpatDownString);  
    set(handles.OutputDirectory,'String',Settings.OutputDirectoryString); 
    set(handles.ListFile, 'Value', Settings.ListFileValue);
    set(handles.umPerPixel, 'String', Settings.umPerPixelString);
    set(handles.Framerate, 'String', Settings.FramerateString);
    set(handles.Concat, 'Value', Settings.ConcatValue);
    set(handles.concatCR, 'Value', Settings.concatCRValue);
    %set(handles.BlackThresh, 'String', Settings.BlackThreshString);
    %set(handles.RemoveBlack, 'Value', Settings.RemoveBlackValue);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)

handles=guidata(hObject);
Settings.ListFileString=get(handles.ListFile,'String');
Settings.SpatDownString=get(handles.SpatDown,'String');
Settings.OutputDirectoryString=get(handles.OutputDirectory,'String');
Settings.ConcatValue=get(handles.Concat, 'Value');
Settings.ListFileValue=get(handles.ListFile, 'Value');
Settings.umPerPixelString=get(handles.umPerPixel, 'String');
Settings.FramerateString=get(handles.Framerate, 'String');
Settings.concatCRValue=get(handles.concatCR, 'Value');
Settings.RemoveBlackValue=get(handles.RemoveBlack, 'Value');
Settings.BlackThreshString=get(handles.BlackThresh, 'String');


% --- Outputs from this function are returned to the command line.
function varargout = Image_day_process_concat_OutputFcn(hObject, eventdata, handles) 
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

try
    
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    downsample_xy = str2double(get(handles.SpatDown,'String'));
    filelist=get(handles.ListFile,'String');
    filevals=get(handles.ListFile, 'Value');
    
    filelist=filelist(filevals);
    savedir=get(handles.OutputDirectory,'String');
    
    concat=get(handles.Concat,'Value');
    if concat
        cInd=length(SpikeMovieData)+1;
        initConcat=0;
    end
    concatCR=get(handles.concatCR,'Value');
    if concatCR && concat
        cCRInd=length(SpikeMovieData)+2;
        initConcatCR=0;
    elseif concatCR
        cCRInd=length(SpikeMovieData)+1;
        initConcatCR=0;
    end
    umPerPix=str2double(get(handles.umPerPixel, 'String'));
    framerate=eval(get(handles.Framerate, 'String'));
    
    h=waitbar(0,'Working...');
    
    if concat || concatCR
            totalFrames=0;
            for i = 1:numel(filelist)
                totalFrames=totalFrames+size(imfinfo(filelist{i}),1);% Number of frames
            end
    end
    
    
    %Go through each file in filelist
    for i = 1:numel(filelist)
        
        %First load and downsample the movie
        TifLink = Tiff(filelist{i}, 'r'); % We create the Tiff object to the file
        TmpImage = TifLink.read();% We read one picture to get the image size as well as the data type
        TifLink.close(); clear TifLink
        
        LocalImage = imresize(TmpImage, 1/downsample_xy);%Resize
        SizeImage=size(LocalImage);%Get the xy dimensions
        Numberframe=size(imfinfo(filelist{i}),1);% Number of frames
        
        % Pre-allocate the movie
        Movie=zeros(SizeImage(1),SizeImage(2),Numberframe,class(LocalImage));
        clear LocalImage SizeImage TmpImage
        
        % We use low-level access to the tifflib library file to avoid duplicating
        % Access to the Tif properties while reading long list of directories in Tiffs
        FileID = tifflib('open',filelist{i},'r');
        rps = tifflib('getField',FileID,Tiff.TagID.RowsPerStrip);
        hImage = tifflib('getField',FileID,Tiff.TagID.ImageLength);
        rps = min(rps,hImage);
        
        for j=1:Numberframe
            tifflib('setDirectory',FileID,1+j-1);
            
            % Go through each strip of data.
            for r = 1:rps:hImage
                row_inds = r:min(hImage,r+rps-1);
                stripNum = tifflib('computeStrip',FileID,r);
                if downsample_xy~=1
                    TmpImage(row_inds,:) = tifflib('readEncodedStrip',FileID,stripNum);
                else
                    Movie(row_inds,:,j)= tifflib('readEncodedStrip',FileID,stripNum);
                end
            end
            if downsample_xy~=1
                Movie(:,:,j)=imresize(TmpImage,1/downsample_xy);
            end
        end
        tifflib('close',FileID);
        
        if concat
            if ~initConcat
                frInd=0;
                SpikeMovieData(cInd).Movie=zeros([size(Movie,1), size(Movie,2), totalFrames], class(Movie));
                SpikeMovieData(cInd).Movie(:,:,frInd+(1:Numberframe))=Movie;
                frInd=frInd+Numberframe;
                SpikeMovieData(cInd).Path=savedir;
                SpikeMovieData(cInd).Filename=filelist{1};
                initConcat=1;
            else
                SpikeMovieData(cInd).Movie(:,:,frInd+(1:Numberframe))=Movie;
                frInd=frInd+Numberframe;
            end
            if i==numel(filelist)
               if get(handles.RemoveBlack, 'Value')
                    movSize=size(SpikeMovieData(cInd).Movie);
                    SpikeMovieData(cInd).DataSize=movSize;
                   
                    thresh=str2double(get(handles.BlackThresh, 'String'));
                    frToRemove=[];
                    for fr=1:SpikeMovieData(cInd).DataSize(3)
                        thisMean=mean(mean(squeeze(SpikeMovieData(cInd).Movie(:,:,fr))));
                        if thisMean<thresh
                            frToRemove(end+1)=fr;
                        end
                    end
                    SpikeMovieData(cInd).Movie(:,:,frToRemove)=[];
                end
                
                movSize=size(SpikeMovieData(cInd).Movie);
                SpikeMovieData(cInd).DataSize=movSize;
                xpos=repmat(umPerPix*(1:movSize(2)), movSize(1), 1);
                ypos=repmat(umPerPix*(1:movSize(1))', 1, movSize(2));
                SpikeMovieData(cInd).Xposition=xpos;
                SpikeMovieData(cInd).Yposition=ypos;
                SpikeMovieData(cInd).Zposition=zeros(size(xpos));
                if length(framerate)==1
                    SpikeMovieData(cInd).TimeFrame=(1/framerate)*(1:movSize(3));
                    SpikeMovieData(cInd).Exposure=(1/framerate)*ones(movSize(1:2));
                else
                    SpikeMovieData(cInd).TimeFrame=(1/framerate(i))*(1:movSize(3));
                    SpikeMovieData(cInd).Exposure=(1/framerate(i))*ones(movSize(1:2));
                end
                SpikeMovieData(cInd).TimePixel=zeros(movSize, 'uint8');
                SpikeMovieData(cInd).TimePixelUnits=1*10^(-6);
                SpikeMovieData(cInd).Label.XLabel='\mum';
                SpikeMovieData(cInd).Label.YLabel='\mum';
                SpikeMovieData(cInd).Label.ZLabel='\mum';
                SpikeMovieData(cInd).Label.CLabel='Fluorescence (au)';
                SpikeMovieData(cInd).Label.ListText='Concat movie';
            end
        end
        
        %Perform Column-Row-Normalization
        MaxValue=intmax(class(Movie))/2;
        
        for j=1:size(Movie,3)
            data= Movie(:,:,j);
            meanRows = single(repmat(mean(data,1),size(data,1),1));
            meanCols = single(repmat(mean(data,2),1,size(data,2)));
            meanRows = meanRows.*meanCols/mean(meanCols(floor(size(data,2)/2),:));
            
            Movie(:,:,j)=cast(single(MaxValue)*single(data)./meanRows,class(Movie));
        end
        
        if concatCR
            if ~initConcatCR
                frCRInd=0;
                SpikeMovieData(cCRInd).Movie=zeros([size(Movie,1), size(Movie,2), totalFrames], class(Movie));
                SpikeMovieData(cCRInd).Movie(:,:,frCRInd+(1:Numberframe))=Movie;
                frCRInd=frCRInd+Numberframe;
                SpikeMovieData(cCRInd).Path=savedir;
                SpikeMovieData(cCRInd).Filename=filelist{1};
                initConcatCR=1;
            else
                SpikeMovieData(cCRInd).Movie(:,:,frCRInd+(1:Numberframe))=Movie;
                frCRInd=frCRInd+Numberframe;
            end
            if i==numel(filelist)
                if get(handles.RemoveBlack, 'Value')
                    SpikeMovieData(cCRInd).Movie(:,:,frToRemove)=[];
                end
                
                movSize=size(SpikeMovieData(cCRInd).Movie);
                SpikeMovieData(cCRInd).DataSize=movSize;
                xpos=repmat(umPerPix*(1:movSize(2)), movSize(1), 1);
                ypos=repmat(umPerPix*(1:movSize(1))', 1, movSize(2));
                SpikeMovieData(cCRInd).Xposition=xpos;
                SpikeMovieData(cCRInd).Yposition=ypos;
                SpikeMovieData(cCRInd).Zposition=zeros(size(xpos));
                if length(framerate)==1
                    SpikeMovieData(cCRInd).TimeFrame=(1/framerate)*(1:movSize(3));
                    SpikeMovieData(cCRInd).Exposure=(1/framerate)*ones(movSize(1:2));
                else
                    SpikeMovieData(cCRInd).TimeFrame=(1/framerate(i))*(1:movSize(3));
                    SpikeMovieData(cCRInd).Exposure=(1/framerate(i))*ones(movSize(1:2));
                end
                SpikeMovieData(cCRInd).TimePixel=zeros(movSize, 'uint8');
                SpikeMovieData(cCRInd).TimePixelUnits=1*10^(-6);
                SpikeMovieData(cCRInd).Label.XLabel='\mum';
                SpikeMovieData(cCRInd).Label.YLabel='\mum';
                SpikeMovieData(cCRInd).Label.ZLabel='\mum';
                SpikeMovieData(cCRInd).Label.CLabel='Fluorescence (au)';
                SpikeMovieData(cCRInd).Label.ListText='Concat CR movie';
            end
        end
        
        
        %Save downsampled, normalized movie in savedir
        tagstruct.Compression = 1;
        tagstruct.ImageLength = size(Movie,1);
        tagstruct.ImageWidth = size(Movie,2);
        tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software = 'MATLAB';
        tagstruct.SampleFormat = 1;
        tagstruct.BitsPerSample = 16;
        
        [pathstr, name, ext]=fileparts(filelist{i});
        savestring = ['Normalized_', name, ext];
        savestring = fullfile(savedir,savestring);
        TifFile = Tiff(savestring,'w');
        for j=1:Numberframe
            TifFile.setTag(tagstruct);
            TifFile.write(Movie(:,:,j));
            TifFile.writeDirectory();
        end
        TifFile.close();
        waitbar(i/numel(filelist),h);
    end
    delete(h);
    
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


% --- Executes on selection change in ListFile.
function ListFile_Callback(hObject, eventdata, handles)
% hObject    handle to ListFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListFile contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListFile


% --- Executes during object creation, after setting all properties.
function ListFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddFiles.
function AddFiles_Callback(hObject, eventdata, handles)
% hObject    handle to AddFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName] = uigetfile('*.tif','Select tif files','MultiSelect','on');

if iscell(FileName) || FileName~=0
    currentFileList=get(handles.ListFile,'String');
    
    % This is because Matlab does only output cells if more than one file
    % is selected
    if ~iscell(FileName)
        FileName={FileName};
    end
    % We concatenate the list 
    for i=1:numel(FileName)
        currentFileList=[currentFileList;{fullfile(PathName,FileName{i})}];
    end
    set(handles.ListFile,'String',currentFileList);
end

% --- Executes on button press in ChangeDir.
function ChangeDir_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

folder_name = uigetdir;

if folder_name~=0
    set(handles.OutputDirectory,'String',folder_name);
end


function SpatDown_Callback(hObject, eventdata, handles)
% hObject    handle to SpatDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SpatDown as text
%        str2double(get(hObject,'String')) returns contents of SpatDown as a double


% --- Executes during object creation, after setting all properties.
function SpatDown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpatDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Concat.
function Concat_Callback(hObject, eventdata, handles)
% hObject    handle to Concat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Concat


% --- Executes on button press in concatCR.
function concatCR_Callback(hObject, eventdata, handles)
% hObject    handle to concatCR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of concatCR



function umPerPixel_Callback(hObject, eventdata, handles)
% hObject    handle to umPerPixel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of umPerPixel as text
%        str2double(get(hObject,'String')) returns contents of umPerPixel as a double


% --- Executes during object creation, after setting all properties.
function umPerPixel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to umPerPixel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Framerate_Callback(hObject, eventdata, handles)
% hObject    handle to Framerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Framerate as text
%        str2double(get(hObject,'String')) returns contents of Framerate as a double


% --- Executes during object creation, after setting all properties.
function Framerate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Framerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RemoveBlack.
function RemoveBlack_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveBlack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RemoveBlack



function BlackThresh_Callback(hObject, eventdata, handles)
% hObject    handle to BlackThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BlackThresh as text
%        str2double(get(hObject,'String')) returns contents of BlackThresh as a double


% --- Executes during object creation, after setting all properties.
function BlackThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BlackThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
