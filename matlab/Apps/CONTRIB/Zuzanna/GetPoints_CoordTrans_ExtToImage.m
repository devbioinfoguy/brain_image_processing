function varargout = GetPoints_CoordTrans_ExtToImage(varargin)
% GETPOINTS_COORDTRANS_EXTTOIMAGE MATLAB code for GetPoints_CoordTrans_ExtToImage.fig
%      GETPOINTS_COORDTRANS_EXTTOIMAGE, by itself, creates a new GETPOINTS_COORDTRANS_EXTTOIMAGE or raises the existing
%      singleton*.
%
%      H = GETPOINTS_COORDTRANS_EXTTOIMAGE returns the handle to a new GETPOINTS_COORDTRANS_EXTTOIMAGE or the handle to
%      the existing singleton*.
%
%      GETPOINTS_COORDTRANS_EXTTOIMAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GETPOINTS_COORDTRANS_EXTTOIMAGE.M with the given input arguments.
%
%      GETPOINTS_COORDTRANS_EXTTOIMAGE('Property','Value',...) creates a new GETPOINTS_COORDTRANS_EXTTOIMAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GetPoints_CoordTrans_ExtToImage_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GetPoints_CoordTrans_ExtToImage_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Created by Jerome Lecoq in 2012

% Edit the above text to modify the response to help GetPoints_CoordTrans_ExtToImage

% Last Modified by GUIDE v2.5 22-Apr-2012 15:25:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GetPoints_CoordTrans_ExtToImage_OpeningFcn, ...
                   'gui_OutputFcn',  @GetPoints_CoordTrans_ExtToImage_OutputFcn, ...
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


% --- Executes just before GetPoints_CoordTrans_ExtToImage is made visible.
function GetPoints_CoordTrans_ExtToImage_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GetPoints_CoordTrans_ExtToImage (see VARARGIN)
global SpikeImageData;

% Choose default command line output for GetPoints_CoordTrans_ExtToImage
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GetPoints_CoordTrans_ExtToImage wait for user response (see UIRESUME)
% uiwait(handles.figure1);
NumberImages=length(SpikeImageData);

if ~isempty(SpikeImageData)
    for i=1:NumberImages
        TextImage{i}=[num2str(i),' - ',SpikeImageData(i).Label.ListText];
    end
    set(handles.ImageSelector,'String',TextImage);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.ImageSelector,'Value',intersect(1:NumberImages,Settings.ImageSelectorValue));
    set(handles.NbPoints,'String',Settings.NbPointsString);
else
    set(handles.ImageSelector,'Value',[]);
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.ImageSelectorValue=get(handles.ImageSelector,'Value');
Settings.NbPointsString=get(handles.NbPoints,'String')


% --- Outputs from this function are returned to the command line.
function varargout = GetPoints_CoordTrans_ExtToImage_OutputFcn(hObject, eventdata, handles) 
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
global SpikeImageData;


try
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
   
    ImageSel=get(handles.ImageSelector,'Value');
   
    nb_pts_per_im = str2num(get(handles.NbPoints,'String'));
      
    NumberImages=length(ImageSel);
    
    Xpts=zeros(nb_pts_per_im*NumberImages,1);
    Ypts=zeros(nb_pts_per_im*NumberImages,1);
    Xpts_new=zeros(nb_pts_per_im*NumberImages,1);
    Ypts_new=zeros(nb_pts_per_im*NumberImages,1);
    Xpts_new_im=zeros(nb_pts_per_im,1);
    Ypts_new_im=zeros(nb_pts_per_im,1);
    
    
    for n=1:NumberImages
        
        f=figure;
        imagesc(SpikeImageData(ImageSel(n)).Image);
        
        [Xpts_new_im,Ypts_new_im] = ginput(nb_pts_per_im);
        
        for i=1:nb_pts_per_im
        
        prompt=['Give X and Y (space-separated) in old/ext coord system for point ' int2str((n-1)*nb_pts_per_im+i) ': '];
        
        coord_str=input(prompt,'s');
        
        [xs,ys]=strread(coord_str,'%n%n','delimiter',' ');
        
        Xpts((n-1)*nb_pts_per_im+i)=xs;
        Ypts((n-1)*nb_pts_per_im+i)=ys;
        
        Xpts_new((n-1)*nb_pts_per_im+i)=Xpts_new_im(i);
        Ypts_new((n-1)*nb_pts_per_im+i)=Ypts_new_im(i);
        
  
        end
    end
    

global Trans_mat_toImage
global Trans_ori_toImage

New = [Xpts_new(1) Ypts_new(1) Xpts_new(2) Ypts_new(2) Xpts_new(3) Ypts_new(3)]';
Mat = [Xpts(1) Ypts(1) 1 0 0 0;0 0 0 Xpts(1) Ypts(1) 1;
    Xpts(2) Ypts(2) 1 0 0 0;0 0 0 Xpts(2) Ypts(2) 1;
    Xpts(3) Ypts(3) 1 0 0 0;0 0 0 Xpts(3) Ypts(3) 1];


Trans = inv(Mat)*New;

Trans_mat_toImage = [Trans(1) Trans(2);
            Trans(4) Trans(5)];
Trans_ori_toImage = [Trans(3) Trans(6)]';
    
% Then do Trans_mat_toImage*[x1 y1]'+Trans_ori_toImage to get X1 Y1, the coords in the new coordinate system (ie the image system, from the DLP system)   
  
%   
%     close(f);
    
    ValidateValues_Callback(hObject, eventdata, handles);
    set(InterfaceObj,'Enable','on');
    
catch errorObj
    set(InterfaceObj,'Enable','on');
    % If there is a problem, we display the error message
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');

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



function NbPoints_Callback(hObject, eventdata, handles)
% hObject    handle to NbPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NbPoints as text
%        str2double(get(hObject,'String')) returns contents of NbPoints as a double


% --- Executes during object creation, after setting all properties.
function NbPoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NbPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
