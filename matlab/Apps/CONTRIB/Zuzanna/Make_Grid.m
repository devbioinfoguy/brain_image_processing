function varargout = Make_Grid(varargin)
% MAKE_GRID M-file for Make_Grid.fig
%      MAKE_GRID, by itself, creates a new MAKE_GRID or raises the existing
%      singleton*.
%
%      H = MAKE_GRID returns the handle to a new MAKE_GRID or the handle to
%      the existing singleton*.
%
%      MAKE_GRID('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAKE_GRID.M with the given input arguments.
%
%      MAKE_GRID('Property','Value',...) creates a new MAKE_GRID or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Make_Grid_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Make_Grid_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Make_Grid

% Last Modified by GUIDE v2.5 12-May-2012 14:39:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Make_Grid_OpeningFcn, ...
                   'gui_OutputFcn',  @Make_Grid_OutputFcn, ...
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


% --- Executes just before Make_Grid is made visible.
function Make_Grid_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Make_Grid (see VARARGIN)

% Choose default command line output for Make_Grid
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Make_Grid wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global SpikeImageData;
global DLPstim;

   if ~isempty(SpikeImageData)
        for i=1:length(SpikeImageData)
            TextImage{i}=['Image ',num2str(i)];
        end
        set(handles.Image_Selector,'String',TextImage);
    end
    
  if ~isempty(DLPstim)
    set(handles.Xoffset,'String',DLPstim.SaveParam.Xoffset);
    set(handles.Yoffset,'String',DLPstim.SaveParam.Yoffset);
    set(handles.Case_Size,'String',DLPstim.SaveParam.CaseHeight);
    set(handles.Xdim,'String',DLPstim.SaveParam.CaseX);
    set(handles.Ydim,'String',DLPstim.SaveParam.CaseY);
    set(handles.Scale,'String',DLPstim.SaveParam.Scale);   
        
    else
        set(handles.DLPNotLoaded,'Value',1);
    end

if (length(varargin)>1)
    Settings=varargin{2};
%     set(handles.TraceSelector_Stims,'String',Settings.TraceSelectorStimsString);
%     set(handles.TraceSelector_Stims,'Value',Settings.TraceSelectorStimsValue);
% %     set(handles.TraceSelector_Spikes,'String',Settings.TraceSelectorSpikesString);
%     set(handles.TraceSelector_Spikes,'Value',Settings.TraceSelectorSpikesValue);
    set(handles.Xoffset,'String',Settings.XoffsetString);
    set(handles.Yoffset,'String',Settings.YoffsetString);
    set(handles.Case_Size,'String',Settings.CaseSizeString);
    set(handles.Xdim,'String',Settings.XdimString);
    set(handles.Ydim,'String',Settings.YdimString);
    set(handles.Scale,'String',Settings.ScaleString);
    
    set(handles.DLPNotLoaded,'Value',Settings.DLPNotLoadedValue); 
    set(handles.DLPtoImage,'Value',Settings.DLPtoImageValue); 
    set(handles.Imageto2p,'Value',Settings.Imageto2pValue); 
    set(handles.PlotonImage,'Value',Settings.PlotonImageValue); 
    
end


% --- Outputs from this function are returned to the command line.
function varargout = Make_Grid_OutputFcn(hObject, eventdata, handles) 
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
Settings.ImageSelectorString=get(handles.Image_Selector,'String');
Settings.ImageSelectorValue=get(handles.Image_Selector,'Value');

Settings.XoffsetString=get(handles.Xoffset,'String');
Settings.YoffsetString=get(handles.Yoffset,'String');
Settings.CaseSizeString=get(handles.Case_Size,'String');
Settings.XdimString=get(handles.Xdim,'String');
Settings.YdimString=get(handles.Ydim,'String');
Settings.ScaleString=get(handles.Scale,'String');

Settings.DLPtoImageValue=get(handles.DLPtoImage,'Value');
Settings.Imageto2pValue=get(handles.Imageto2p,'Value');
Settings.PlotonImageValue=get(handles.PlotonImage,'Value');
Settings.DLPNotLoadedValue=get(handles.DLPNotLoaded,'Value');



% --- Executes on button press in ApplyApps.
function ApplyApps_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyApps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SpikeImageData;
global DLPstim;

ImagesToApply=get(handles.Image_Selector,'Value');



%%%%%%%%%%%%%

xoffset=str2double(get(handles.Xoffset,'String'));
yoffset=str2double(get(handles.Yoffset,'String'));
ydim=str2double(get(handles.Ydim,'String')); 
casesize=str2double(get(handles.Case_Size,'String')); 
xdim=str2double(get(handles.Xdim,'String')); 
scale=str2double(get(handles.Scale,'String'));
NoDLP=str2double(get(handles.DLPNotLoaded,'Value'));

DLPtoimage=get(handles.DLPtoImage,'Value');
imageto2p=get(handles.Imageto2p,'Value');
plotonimage=get(handles.PlotonImage,'Value');

total_screenwidth=800; % <== change here if screen resolution changed
WidthScreen=round(total_screenwidth/scale); %square screen section, bigger square
HeightScreen=WidthScreen;

global Coords
global Coords_2p

Coords=grid_coords(WidthScreen,HeightScreen,casesize,xdim,ydim,xoffset,yoffset);


plot_grid(Coords);

global Trans_mat_toImage
global Trans_ori_toImage
        
if DLPtoimage==1
Coords_image=trans_coords(Coords,Trans_mat_toImage,Trans_ori_toImage);
plot_grid(Coords_image);
end


global Trans_mat
global Trans_ori

if imageto2p==1
Coords_2p=trans_coords(Coords_image,Trans_mat,Trans_ori);    
plot_grid(Coords_2p);
end

if plotonimage==1
    
    for n=1:length(ImagesToApply)
        plot_grid_on_image(Coords_2p,SpikeImageData(ImagesToApply(n)).Image)
        
    end
    
end


ValidateValues_Callback(hObject, eventdata, handles);

%%%%%%%%%%%%

%generates coordinates for all corners of a grid
function coords=grid_coords(widthscreen,heightscreen,casesize,xdim,ydim,xoffset,yoffset) 

PixelCaseHeight=round(casesize*ydim);
PixelCaseWidth=round(casesize*xdim);

NumberCaseX=floor((widthscreen)/PixelCaseWidth);
NumberCaseY=floor((heightscreen)/PixelCaseHeight);

% We check the limit in number of possible case
NumberCaseX=min(widthscreen,max(1,NumberCaseX));
NumberCaseY=min(heightscreen,max(1,NumberCaseY));

LeftMatrix=0:PixelCaseWidth:widthscreen;
TopMatrix=0:PixelCaseHeight:heightscreen;

KeptIndices=randperm(NumberCaseX*NumberCaseY);
[XCoord,YCoord]=ind2sub([NumberCaseX,NumberCaseY],KeptIndices);

% XCoord=1:1:length(LeftMatrix);
% XCoord=repmat(XCoord,1,length(XCoord));
% XCoord=sort(XCoord);
% YCoord=1:1:length(TopMatrix);
% YCoord=repmat(YCoord,1,length(YCoord));

coord_matrix(1,:)=LeftMatrix(XCoord)+xoffset;
coord_matrix(2,:)=TopMatrix(YCoord)+yoffset;
coord_matrix(3,:)=LeftMatrix(XCoord)+PixelCaseWidth+xoffset;
coord_matrix(4,:)=TopMatrix(YCoord)+PixelCaseHeight+yoffset;

%top left corner:
coords(1,:)=coord_matrix(1,:);
coords(2,:)=coord_matrix(2,:);
%top right corner:
coords(3,:)=coord_matrix(3,:);
coords(4,:)=coord_matrix(2,:);
%bottom left corner:
coords(5,:)=coord_matrix(1,:);
coords(6,:)=coord_matrix(4,:);
%bottom right corner:
coords(7,:)=coord_matrix(3,:);
coords(8,:)=coord_matrix(4,:);
        
function new_coords=trans_coords(coords,trans_mat,trans_vec)

new_coords=zeros(size(coords));

for k=1:size(coords,2)
vec=trans_mat*[coords(1,k); coords(2,k)] + trans_vec;
new_coords(1,k)=vec(1); 
new_coords(2,k)=vec(2);

vec=trans_mat*[coords(3,k); coords(4,k)] + trans_vec;
new_coords(3,k)=vec(1); 
new_coords(4,k)=vec(2);

vec=trans_mat*[coords(5,k); coords(6,k)] + trans_vec;
new_coords(5,k)=vec(1); 
new_coords(6,k)=vec(2);

vec=trans_mat*[coords(7,k); coords(8,k)] + trans_vec;
new_coords(7,k)=vec(1); 
new_coords(8,k)=vec(2);

end

function plot_grid(coords)
figure;
for i=1:2:7
    plot(coords(i,:),coords(i+1,:),'k.')
    hold on
    axis([min(min(coords))-10 max(max(coords))+10 min(min(coords))-10 max(max(coords))+10])
end

function plot_grid_on_image(coords,img)
figure;
imagesc(img);
axis equal;
hold on;
for i=1:2:7
    plot(coords(i,:),coords(i+1,:),'w.')
    hold on
end

% --- Executes on button press in ValidateValues.
function ValidateValues_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;


function Xoffset_Callback(hObject, eventdata, handles)
% hObject    handle to Xoffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Xoffset as text
%        str2double(get(hObject,'String')) returns contents of Xoffset as a double


% --- Executes during object creation, after setting all properties.
function Xoffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xoffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Yoffset_Callback(hObject, eventdata, handles)
% hObject    handle to Yoffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Yoffset as text
%        str2double(get(hObject,'String')) returns contents of Yoffset as a double


% --- Executes during object creation, after setting all properties.
function Yoffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Yoffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Case_Size_Callback(hObject, eventdata, handles)
% hObject    handle to Case_Size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Case_Size as text
%        str2double(get(hObject,'String')) returns contents of Case_Size as a double


% --- Executes during object creation, after setting all properties.
function Case_Size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Case_Size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Xdim_Callback(hObject, eventdata, handles)
% hObject    handle to Xdim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Xdim as text
%        str2double(get(hObject,'String')) returns contents of Xdim as a double


% --- Executes during object creation, after setting all properties.
function Xdim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xdim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function Ydim_Callback(hObject, eventdata, handles)
% hObject    handle to Ydim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ydim as text
%        str2double(get(hObject,'String')) returns contents of Ydim as a double


% --- Executes during object creation, after setting all properties.
function Ydim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ydim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DLPNotLoaded.
function DLPNotLoaded_Callback(hObject, eventdata, handles)
% hObject    handle to DLPNotLoaded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DLPNotLoaded



function Scale_Callback(hObject, eventdata, handles)
% hObject    handle to Scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Scale as text
%        str2double(get(hObject,'String')) returns contents of Scale as a double


% --- Executes during object creation, after setting all properties.
function Scale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DLPtoImage.
function DLPtoImage_Callback(hObject, eventdata, handles)
% hObject    handle to DLPtoImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DLPtoImage


% --- Executes on button press in Imageto2p.
function Imageto2p_Callback(hObject, eventdata, handles)
% hObject    handle to Imageto2p (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Imageto2p


% --- Executes on button press in PlotonImage.
function PlotonImage_Callback(hObject, eventdata, handles)
% hObject    handle to PlotonImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PlotonImage


% --- Executes on selection change in Image_Selector.
function Image_Selector_Callback(hObject, eventdata, handles)
% hObject    handle to Image_Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Image_Selector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Image_Selector


% --- Executes during object creation, after setting all properties.
function Image_Selector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Image_Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
