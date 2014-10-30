function varargout = Align_1phot_2phot_v2(varargin)
% ALIGN_1PHOT_2PHOT 
%
% Created by Lacey Kitch in 2012

% Edit the above text to modify the response to help Align_1phot_2phot

% Last Modified by GUIDE v2.5 29-Oct-2012 10:46:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Align_1phot_2phot_OpeningFcn, ...
                   'gui_OutputFcn',  @Align_1phot_2phot_OutputFcn, ...
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
function Align_1phot_2phot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Align_1phot_2phot (see VARARGIN)

% Choose default command line output for Align_1phot_2phot
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global SpikeMovieData
global SpikeImageData

if ~isempty(SpikeMovieData)
    for i=1:length(SpikeMovieData)
        TextMovie{i}=[num2str(i),' - ',SpikeMovieData(i).Label.ListText];
    end
    set(handles.TwoPMovieSelector,'String',TextMovie);
    set(handles.OnePMovieSelector,'String',TextMovie);
end

if ~isempty(SpikeImageData)
    for i=1:length(SpikeImageData)
        TextImage{i}=[num2str(i),' - ',SpikeImageData(i).Label.ListText];
    end
    set(handles.TwoPImageSelector,'String',TextImage);
    set(handles.OnePImageSelector,'String',TextImage);
    set(handles.OnePMapImageSelector,'String',TextImage);
end

if (length(varargin)>1)
    Settings=varargin{2};
    set(handles.TwoPMovieSelector,'Value',Settings.TwoPMovieSelectorValue);
    set(handles.TwoPImageSelector,'Value',Settings.TwoPImageSelectorValue);
    set(handles.OnePMovieSelector,'Value',Settings.OnePMovieSelectorValue);
    set(handles.OnePImageSelector,'Value',Settings.OnePImageSelectorValue);
    set(handles.OnePMapImageSelector,'Value',Settings.OnePMapImageSelectorValue);
    set(handles.InitialAlignment, 'Value', Settings.InitialAlignmentValue);
    set(handles.OnePumPerPix, 'String', Settings.OnePumPerPixString);
    set(handles.TwoPumPerPix, 'String', Settings.TwoPumPerPixString);
    set(handles.MaxDistance, 'String', Settings.MaxDistanceString);
    set(handles.MaxDistanceDiff, 'String', Settings.MaxDistanceDiffString);
end

if get(handles.InitialAlignment, 'Value')==1
    set(handles.OnePMovieSelector, 'Enable', 'on')
    set(handles.OnePMapImageSelector, 'Enable', 'off')
else
    set(handles.OnePMovieSelector, 'Enable', 'off')
    set(handles.OnePMapImageSelector, 'Enable', 'on')
end


% This function send the current settings to the main interface for saving
% purposes and for the batch mode
function Settings=GetSettings(hObject)
handles=guidata(hObject);
Settings.TwoPMovieSelectorValue=get(handles.TwoPMovieSelector,'Value');
Settings.TwoPImageSelectorValue=get(handles.TwoPImageSelector,'Value');
Settings.OnePMovieSelectorValue=get(handles.OnePMovieSelector,'Value');
Settings.OnePImageSelectorValue=get(handles.OnePImageSelector,'Value');
Settings.OnePMapImageSelectorValue=get(handles.OnePMapImageSelector,'Value');
Settings.InitialAlignmentValue=get(handles.InitialAlignment, 'Value');
Settings.OnePumPerPixString=get(handles.OnePumPerPix, 'String');
Settings.TwoPumPerPixString=get(handles.TwoPumPerPix, 'String');
Settings.MaxDistanceString=get(handles.MaxDistance, 'String');
Settings.MaxDistanceDiffString=get(handles.MaxDistanceDiff, 'String');


% --- Outputs from this function are returned to the command line.
function varargout = Align_1phot_2phot_OutputFcn(hObject, eventdata, handles) 
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

% global cellLocs2phot twoPCellLocations
% global minInds costFnc nTrack
% global n s1 s2 r0 r0Mag cellLocs1photGuess2D
% global cellLocs1phot2D closest2photProjs
% global distances
% global xShift yShift
% global onePProjections markedPtsTwoP markedPtsOneP
% global k num1photCells numCloseEnoughCells
% global closeEnoughCells
% global ngAll r0gAll s1gAll s2gAll
% global xCoords yCoords thisImage
% global cellLocs1photGuess
% global ng r
% global ngr0Ind
% global ngDotr0g distsToPlane closeEnoughCellInds cellIDs1photGuess
% global cellIDs1photGuessRest closestk
% global xshiftg yshiftg
% global xShiftGuesses yShiftGuesses 
% global distancesToAdd
% global shiftTrack r0Track s1Track s2Track
% global distances2


try
    % We turn the interface off for processing.
    InterfaceObj=findobj(handles.output,'Enable','on');
    set(InterfaceObj,'Enable','off');
    
    % get parameters from interface
    twoPStackInd=get(handles.TwoPMovieSelector, 'Value');
    maxZ=SpikeMovieData(twoPStackInd).DataSize(3);
    alignTool=get(handles.InitialAlignment, 'Value');
       
    figh=figure;
    onePAx=subplot(121);
    if alignTool==1
        onePMovieInd=get(handles.OnePMovieSelector, 'Value');
        frameToDisplay=round(size(SpikeMovieData(onePMovieInd).Movie,3)/2);
        imagesc(SpikeMovieData(onePMovieInd).Movie(:,:,frameToDisplay));
    else
        onePMapInd=get(handles.OnePMapImageSelector, 'Value');
        imagesc(SpikeImageData(onePMapInd).Image);
    end
    twoPAx=subplot(122);
    imagesc(SpikeMovieData(twoPStackInd).Movie(:,:,1))
    title('Use up/down arrows to change z, press u to undo. CURRENT Z: 1')
    suptitle('Select 3 matching points, in the same order on each side')
    z=1;
    button=1;
    
    zstep=4;
    
    numPtsTwoP=0;
    numPtsOneP=0;
    markedPtsOneP=nan*ones(2,3);
    markedPtsTwoP=nan*ones(3,3);
    while (isempty(button) || button~=115) || (numPtsOneP<3 || numPtsTwoP<3)
        figure(figh)
        [x,y,button]=ginput(1);
        currAx=gca;
        if currAx==onePAx
            if button==117  % u for undo
                markedPtsOneP(:,numPtsOneP)=[nan, nan];
                numPtsOneP=numPtsOneP-1;
            elseif button==1
                if numPtsOneP>=3
                    suptitle('CANNOT SELECT MORE THAN 3 POINTS!')
                    pause(1)
                    suptitle('Select 3 matching points, in the same order on each side')
                else
                    numPtsOneP=numPtsOneP+1;
                    markedPtsOneP(:,numPtsOneP)=[x;y];
                end
            end
            figure(figh)
            axes(onePAx)
            hold off
            if alignTool==1
                imagesc(SpikeMovieData(onePMovieInd).Movie(:,:,frameToDisplay));
            else
                imagesc(SpikeImageData(onePMapInd).Image);
            end
            hold on
            plot(markedPtsOneP(1,1), markedPtsOneP(2,1),'r*')
            plot(markedPtsOneP(1,2), markedPtsOneP(2,2),'g*')
            plot(markedPtsOneP(1,3), markedPtsOneP(2,3),'b*')

        elseif currAx==twoPAx
            if button==30       % up
                if z>1
                    z=z-1;
                end
            elseif button==31   % down
                if z<maxZ
                    z=z+1;
                end
            elseif button==117  % u for undo
                markedPtsTwoP(:,numPtsTwoP)=[nan, nan, nan];
                numPtsTwoP=numPtsTwoP-1;
            elseif button==1
                if numPtsTwoP>=3
                    suptitle('CANNOT SELECT MORE THAN 3 POINTS!')
                    pause(1)
                    suptitle('Select 3 matching points, in the same order on each side')
                else
                    numPtsTwoP=numPtsTwoP+1;
                    markedPtsTwoP(:,numPtsTwoP)=[x;y;z];
                end
            end
            figure(figh)
            axes(twoPAx)
            hold off
            imagesc(SpikeMovieData(twoPStackInd).Movie(:,:,z))
            hold on
            if markedPtsTwoP(3,1)==z
                plot(markedPtsTwoP(1,1), markedPtsTwoP(2,1),'r*')
            elseif markedPtsTwoP(3,1)<=z+3 || markedPtsTwoP(3,1)>=z-3
                plot(markedPtsTwoP(1,1), markedPtsTwoP(2,1),'r.')
            end
            if markedPtsTwoP(3,2)==z
                plot(markedPtsTwoP(1,2), markedPtsTwoP(2,2),'g*')
            elseif markedPtsTwoP(3,2)<=z+3 || markedPtsTwoP(3,1)>=z-3
                plot(markedPtsTwoP(1,2), markedPtsTwoP(2,2),'g.')
            end
            if markedPtsTwoP(3,3)==z
                plot(markedPtsTwoP(1,3), markedPtsTwoP(2,3),'b*')
            elseif markedPtsTwoP(3,3)<=z+3 || markedPtsTwoP(3,1)>=z-3
                plot(markedPtsTwoP(1,3), markedPtsTwoP(2,3),'b.')
            end
            title(['Use up/down arrows to change z, press u to undo. CURRENT Z: ', num2str(z)])
        end
        
    end
    
    close(figh)
    if sum(isnan(markedPtsOneP(:)))+sum(isnan(markedPtsOneP(:)))>0
        error('Need to select 3 points in each frame. Please begin again.')
    end
    
    
    numImages=length(SpikeImageData);
    
    SpikeImageData(numImages+1).Image=markedPtsTwoP;
    SpikeImageData(numImages+1).Label.XLabel='point';
    SpikeImageData(numImages+1).Label.YLabel='dimension';
    SpikeImageData(numImages+1).Label.ListText='marked points 2ph, pixels';
    
    SpikeImageData(numImages+2).Image=markedPtsOneP;
    SpikeImageData(numImages+2).Label.XLabel='point';
    SpikeImageData(numImages+2).Label.YLabel='dimension';
    SpikeImageData(numImages+2).Label.ListText='marked points 1ph, pixels';
    
    
     
%     % get scale from input parameters
%     twoPumPerPix=str2double(get(handles.TwoPumPerPix, 'String'));
%     onePumPerPix=str2double(get(handles.OnePumPerPix, 'String'));
%     % scale = # 2p pixel edges per 1p pixel edge
% 
%     h=waitbar(0.01, 'Aligning stack with 1p cell map....');
% 
% 
%     
%     
%     % get 2p cell locations from cell locations stored in counting image
%     twoPCellLocInd=get(handles.TwoPImageSelector, 'Value');
%     twoPCellLocations=SpikeImageData(twoPCellLocInd).Image;
%     onePICs=get(handles.OnePImageSelector, 'Value');
%     
%     cellLocs2phot=twoPCellLocations';
%     cellLocs2phot(:,1:2)=cellLocs2phot(:,1:2)*twoPumPerPix;
%     cellLocs2phot(:,3)=cellLocs2phot(:,3)*zstep;
%     
%     xrange=[0,size(SpikeMovieData(twoPStackInd).Movie(:,:,1),2)*twoPumPerPix];
%     yrange=[0,size(SpikeMovieData(twoPStackInd).Movie(:,:,1),1)*twoPumPerPix];
%     zrange=[0,maxZ*zstep];
%     
%     xmean=mean(cellLocs2phot(:,1));
%     ymean=mean(cellLocs2phot(:,2));
%     zmean=mean(cellLocs2phot(:,3));
%     
%     cellLocs2phot(:,1)=cellLocs2phot(:,1)-xmean;
%     cellLocs2phot(:,2)=cellLocs2phot(:,2)-ymean;
%     cellLocs2phot(:,3)=cellLocs2phot(:,3)-zmean;
%     
%     xrange=xrange-xmean;
%     yrange=yrange-ymean;
%     zrange=zrange-zmean;
    

%     % get normal vector from 2p points
%     markedPtsTwoP(3,:)=markedPtsTwoP(3,:)*zstep;
%     markedPtsTwoP(1:2,:)=markedPtsTwoP(1:2,:)*twoPumPerPix;
%     markedPtsTwoP(1,:)=markedPtsTwoP(1,:)-xmean;
%     markedPtsTwoP(2,:)=markedPtsTwoP(2,:)-ymean;
%     markedPtsTwoP(3,:)=markedPtsTwoP(3,:)-zmean;
%     markedPtsOneP=markedPtsOneP*onePumPerPix;
%     n=cross(markedPtsTwoP(:,1)-markedPtsTwoP(:,2), markedPtsTwoP(:,2)-markedPtsTwoP(:,3));
%     n=n/norm(n);


%     
%     % get r0, s1, and s2 vector from 2p points
%     r0Mag=dot(n, markedPtsTwoP(:,1));
%     r0=r0Mag*n;
%     s1=[1/n(1), -1/n(2), 0];
%     xnanInd=n(1)==0;
%     ynanInd=n(2)==0;
%     s1(xnanInd,1)=1;
%     s1(xnanInd,2:3)=0;
%     s1(ynanInd,[1,3])=0;
%     s1(ynanInd,2)=1;
%     s1=s1/norm(s1);
%     s2=cross(s1, n);
%     s2=s2/norm(s2);
%     
%     % get shift by minimizing match between 1p and 2p points
%     % minimize {1p1, 1p2, 1p3} - ([s1; s2]*{2p1, 2p2, 2p3} + [xshift; yshift])
%     onePProjections=[s1; s2]*markedPtsTwoP;
%     xShift=mean(markedPtsOneP(1,:)-onePProjections(1,:));
%     yShift=mean(markedPtsOneP(2,:)-onePProjections(2,:));
%     
% 
%     figure(5)
%     hold off
%     plot3(cellLocs2phot(:,1), cellLocs2phot(:,2), cellLocs2phot(:,3),'*');
%     hold on
% 
%     [xmesh, ymesh]=meshgrid(xrange(1):10:xrange(2), yrange(1):10:yrange(2));
%     planeeq=@(x,y,nx,ny,nz,x0,y0,z0)(-(1/nz)*(nx*(x-x0)+ny*(y-y0)-nz*z0));
%     
%     testsurf=planeeq(xmesh, ymesh, n(1), n(2), n(3), r0(1), r0(2), r0(3));
%     testsurf(testsurf<0)=0;
%     surf(xmesh,ymesh,testsurf)
%     hold all
%     
%     cellLocs1phot2D=zeros(length(onePICs),2);
%     sizeIm=size(SpikeImageData(onePICs(1)).Image);
%     xCoords=repmat(1:sizeIm(2), sizeIm(1), 1);
%     yCoords=repmat((1:sizeIm(1))', 1, sizeIm(2));
%     for imInd=1:length(onePICs)
%         thisImageInd=onePICs(imInd);
%         thisImage=SpikeImageData(thisImageInd).Image;
%         thisImSum=sum(sum(thisImage));
%         cellLocs1phot2D(imInd,1)=sum(sum(thisImage.*xCoords))/thisImSum*onePumPerPix;
%         cellLocs1phot2D(imInd,2)=sum(sum(thisImage.*yCoords))/thisImSum*onePumPerPix;
%     end
%     
%     
%     xShiftGuessIncs=-20:5:20;
%     yShiftGuessIncs=-20:5:20;
%     r0MagGuessIncs=-30:10:30;
%     % theta will rotate around x, phi will rotate around y
%     thetaGuessIncs=-pi/180:pi/360:pi/180;
%     phiGuessIncs=-pi/180:pi/360:pi/180;
%     
%     % now:
%     % define n guesses by rotating n by theta and phi rot mats
%     %       % loop? no, repmat n then ... no, have to loop
%     % define shift and r guesses by using GuessIncs vectors
%     % should be good
%     % 
%     % do visualization to check
% 
%     initShiftGuess=[xShift, yShift];
%     xShiftGuesses=initShiftGuess(1)+xShiftGuessIncs;
%     yShiftGuesses=initShiftGuess(2)+yShiftGuessIncs;
% 
%     initr0guess=r0Mag;
%     r0guesses=initr0guess+r0MagGuessIncs;
%     
%     %%%%% begin faster, more recent code
%     maxDistToPlane=30;
%     tomatoFraction=0.5;
%     
%     num1photCells=size(cellLocs1phot2D,1);
%     costFnc=zeros(size(ngAll,1)*length(r0guesses)*length(xShiftGuesses)*length(yShiftGuesses),1);
%     nTrack=zeros(size(ngAll,1)*length(r0guesses)*length(xShiftGuesses)*length(yShiftGuesses),3);
%     s2Track=zeros(size(ngAll,1)*length(r0guesses)*length(xShiftGuesses)*length(yShiftGuesses),3);
%     s1Track=zeros(size(ngAll,1)*length(r0guesses)*length(xShiftGuesses)*length(yShiftGuesses),3);
%     shiftTrack=zeros(size(ngAll,1)*length(r0guesses)*length(xShiftGuesses)*length(yShiftGuesses),2);
%     r0Track=zeros(size(ngAll,1)*length(r0guesses)*length(xShiftGuesses)*length(yShiftGuesses),3);
%     closest2photProjs=zeros(size(ngAll,1)*length(r0guesses)*length(xShiftGuesses)*length(yShiftGuesses),num1photCells);
%     distances=zeros(size(ngAll,1)*length(r0guesses)*length(xShiftGuesses)*length(yShiftGuesses),num1photCells);
%     closest2photProjs2=zeros(size(ngAll,1)*length(r0guesses)*length(xShiftGuesses)*length(yShiftGuesses),num1photCells);
%     distances2=zeros(size(ngAll,1)*length(r0guesses)*length(xShiftGuesses)*length(yShiftGuesses),num1photCells);
% 
% %     nxgAll=repmat(nxguesses,1,length(nyguesses));
% %     nygInds=cumsum(repmat([1 zeros(1,length(nxguesses)-1)], 1, length(nyguesses)));
% %     nygAll=nyguesses(nygInds);
% %     nzgAll=sqrt(1-nxgAll.^2-nygAll.^2);
% %     ngAll=[nxgAll', nygAll', nzgAll'];
%     
%     ngAll=zeros(length(thetaGuessIncs)*length(phiGuessIncs),3);
%     thetagAll=zeros(length(thetaGuessIncs)*length(phiGuessIncs),1);
%     phigAll=zeros(length(thetaGuessIncs)*length(phiGuessIncs),1);
%     ngInd=0;
%     for thetag=thetaGuessIncs
%         for phig=phiGuessIncs
%             ngInd=ngInd+1;
%             thisXrotMat=[1 0 0; 0 cos(thetag) -sin(thetag); 0 sin(thetag) cos(thetag)];
%             thisYrotMat=[cos(phig) 0 sin(phig); 0 1 0; -sin(phig) 0 cos(phig)];
%             ngAll(ngInd,:)=thisXrotMat*thisYrotMat*n;
%             thetagAll(ngInd)=thetag;
%             phigAll(ngInd)=phig;
%         end
%     end
%     
%     r0gInds=cumsum(repmat([1 zeros(1,size(ngAll,1)-1)], 1, length(r0guesses)));
%     ngAll=repmat(ngAll, length(r0guesses), 1);
%     thetagAll=repmat(thetagAll, length(r0guesses), 1);
%     phigAll=repmat(phigAll, length(r0guesses), 1);
%     r0gAll=repmat(r0guesses(r0gInds)', 1, 3).*ngAll;
%     ngDotr0g=sum(r0gAll.*ngAll,2);
% 
%     distsToPlane=ngAll*cellLocs2phot'-repmat(ngDotr0g, 1, size(cellLocs2phot,1));   % num ngs x num 2p cells
%     closeEnoughCells=abs(distsToPlane)<maxDistToPlane;  % num ngs x num 2p cells
% 
%     s1gAll=[1./ngAll(:,1), -1./ngAll(:,2), zeros(size(ngAll(:,2)))];
%     xnanInds=ngAll(:,1)==0;
%     ynanInds=ngAll(:,2)==0;
%     s1gAll(xnanInds,1)=1;
%     s1gAll(xnanInds,2:3)=0;
%     s1gAll(ynanInds,[1,3])=0;
%     s1gAll(ynanInds,2)=1;
%     s1gAll=s1gAll./repmat(sqrt(sum(s1gAll.^2,2)),1,3);
%     %y2gAll=-ngAll(:,3)./(ngAll(:,2)+(ngAll(:,1).^2)./ngAll(:,2));
%     %x2gAll=(y2gAll./ngAll(:,2)).*ngAll(:,1);
%     %s2gAll=[x2gAll, y2gAll, ones(size(y2gAll))];
%     s2gAll=cross(s1gAll, ngAll);
%     s2gAll=s2gAll./repmat(sqrt(sum(s2gAll.^2,2)),1,3);
% 
%     maxDistForMatch=10;
%     minDistDiff=10;
%     expectedNumMatches=num1photCells*tomatoFraction;
% 
%     numBaseGuesses=length(xShiftGuesses);
% 
%     for xShiftInd=1:length(xShiftGuesses)
%         xshiftg=xShiftGuesses(xShiftInd);
%         waitbar(xShiftInd/length(xShiftGuesses),h)
%         for yShiftInd=1:length(yShiftGuesses)
%             yshiftg=yShiftGuesses(yShiftInd); 
% 
%             for ngr0Ind=1:size(ngAll,1)
% 
%                 %costInd=costInd+1;
%                 costInd=(xShiftInd-1)*numBaseGuesses^4+(yShiftInd-1)*numBaseGuesses^3+ngr0Ind;
% 
%                 ng=ngAll(ngr0Ind,:);
%                 r0g=r0gAll(ngr0Ind,:);
%                 s1g=s1gAll(ngr0Ind,:);
%                 s2g=s2gAll(ngr0Ind,:);
%                 
%                 thetag=thetagAll(ngr0Ind);
%                 phig=phigAll(ngr0Ind);
%                 
%                 figure(5)
%                 hold off
%                 plot3(cellLocs2phot(:,1), cellLocs2phot(:,2), cellLocs2phot(:,3),'*');
%                 hold on
%                 surf(xmesh,ymesh,testsurf)
%                 hold all
% 
%                 guesssurf=planeeq(xmesh, ymesh, ng(1), ng(2), ng(3), r0g(1), r0g(2), r0g(3));
%                 %guesssurf(guesssurf<0)=0;
%                 surf(xmesh,ymesh,guesssurf)
%                 title([str2double(round(180/pi*thetag)), ' ' , str2double(round(180/pi*phig)), ' ', str2double(r0g(1)/ng(1))])
%                 %waitforbuttonpress()
%                 
%                 
% 
%                 % project close enough 2phot points to guessed plane
%                 numCloseEnoughCells=sum(closeEnoughCells(ngr0Ind,:));
% 
%                 closeEnoughCellInds=1:size(distsToPlane,2);
%                 closeEnoughCellInds=closeEnoughCellInds(closeEnoughCells(ngr0Ind,:));
% 
%                 cellLocs2photCloseEnoughCells=cellLocs2phot(closeEnoughCellInds,:); % numCloseEnoughCells x 3
%                 distancesCloseEnoughCells=distsToPlane(ngr0Ind, closeEnoughCellInds);
%                 cellLocs1photGuess=cellLocs2photCloseEnoughCells'-ng'*distancesCloseEnoughCells; % 3 x numCloseEnoughCells
%                 cellLocs1photGuess2D=[s1g; s2g]*cellLocs2photCloseEnoughCells'+repmat([xshiftg; yshiftg], 1, numCloseEnoughCells); % 2 x numCloseEnoughCells
%                 cellIDs1photGuess=closeEnoughCellInds;
% 
%                 % now cost function measures how close your 1phot
%                 % guesses are to the measured 1phot points
%                 distancesToAdd=zeros(num1photCells,1);
%                 
%                 if numCloseEnoughCells>0
%                     for k=1:num1photCells
%                         [dist, closestk]=min(sum((cellLocs1photGuess2D'-...
%                             cellLocs1phot2D(k*ones(numCloseEnoughCells,1),:)).^2,2));
%                         dist=sqrt(dist);
% 
%                         if numCloseEnoughCells>1
%                             cellLocs1photGuessRest2D=cellLocs1photGuess2D;
%                             cellLocs1photGuessRest2D(:,closestk)=[];
%                             cellIDs1photGuessRest=cellIDs1photGuess;
%                             cellIDs1photGuessRest(closestk)=[];
%                             [dist2, closestk2]=min(sum((cellLocs1photGuessRest2D'-...
%                                 cellLocs1phot2D(k*ones(numCloseEnoughCells-1,1),:)).^2,2));
%                             closest2photProjs2(costInd, k)=cellIDs1photGuessRest(closestk2);
%                         else
%                             dist2=100000000;
%                         end
%                         dist2=sqrt(dist2);
%                         
%                         distances2(costInd, k)=dist2;
%                         distances(costInd, k)=dist;
%                         diffDist=dist2-dist;
%                         
%                         if dist<maxDistForMatch && diffDist>minDistDiff
%                             distancesToAdd(k)=1;
%                             closest2photProjs(costInd, k)=cellIDs1photGuess(closestk);
%                         end
%                     end
%                     num2photMatches=sum(distancesToAdd);
%                     costFnc(costInd)=sum(distances(costInd,logical(distancesToAdd)))/num2photMatches;
%                     if num2photMatches<0.5*expectedNumMatches || num2photMatches>1.5*expectedNumMatches
%                         costFnc(costInd)=10000;
%                     end
% %                     if num2photMatches>0
% %                         costFnc(costInd)=costFnc(costInd)+...
% %                             maxDistForMatch*max(expectedNumMatches-num2photMatches, 0);
% %                         costFnc(costInd)=costFnc(costInd)/(max(expectedNumMatches-num2photMatches, 0)+num2photMatches);
% %                     else
% %                         costFnc(costInd)=10000;
% %                     end
%                 else
%                     costFnc(costInd)=10000;
%                 end
%                 nTrack(costInd,:)=ng;
%                 shiftTrack(costInd,:)=[xshiftg,yshiftg];
%                 r0Track(costInd, :)=r0g;
%                 s1Track(costInd,:)=s1;
%                 s2Track(costInd,:)=s2;
%             end
%         end
%     end
%     %%%%% end more recent code
% 
%     nonNanInds=~isnan(costFnc);
%     costFnc=costFnc(nonNanInds,:);
%     nTrack=nTrack(nonNanInds,:);
%     r0Track=r0Track(nonNanInds,:);
%     shiftTrack=shiftTrack(nonNanInds,:);
%     s1Track=s1Track(nonNanInds,:);
%     s2Track=s2Track(nonNanInds,:);
%     
%     minInds=find(costFnc==min(costFnc));
%     diffSolInd=1;
%     for minIndInd=2:length(minInds)
%         i=minInds(minIndInd);
%         j=minInds(minIndInd-1);
%         if sum(closest2photProjs(i,:)~=closest2photProjs(j,:))>0
%             diffSolInd=diffSolInd+1;
%         end
%     end
%     
%     minInd=minInds(1);
%     nBest=nTrack(minInd,:);
%     r0Best=r0Track(minInd,:);
%     xShiftBest=shiftTrack(minInd,1);
%     yShiftBest=shiftTrack(minInd,2);
%     
%     closest2photProjsMin=closest2photProjs(minInd,:);
%     closest2photProjsMin=closest2photProjsMin(closest2photProjsMin>0);
%     
%     
%     figure(5)
%     plot3(cellLocs2phot(closest2photProjsMin,1), cellLocs2phot(closest2photProjsMin,2), cellLocs2phot(closest2photProjsMin,3),'g*');
%     hold on
%     
%     bestsurf=planeeq(xmesh, ymesh, nBest(1), nBest(2), nBest(3), r0Best(1), r0Best(2), r0Best(3));
%     bestsurf(bestsurf<0)=0;
%     surf(xmesh,ymesh,bestsurf)
%     hold all
%     
%     figure(6)
%     plot(cellLocs1phot2D(:,1), cellLocs1phot2D(:,2), 'k*')
%     hold on
%     ng=nBest';
%     r0g=r0Best';
%     s1=s1Track(minInd,:);
%     s2=s2Track(minInd,:);
%     xshiftg=xShiftBest;
%     yshiftg=yShiftBest;
%     onePhotInd=0;
%     cellLocs1photGuess=zeros(length(closest2photProjsMin), 3);
%     cellLocs1photGuess2D=zeros(length(closest2photProjsMin), 2);
%     for k=closest2photProjsMin
%         r=cellLocs2phot(k,:)';
%         distToPlane=(ng'*(r-r0g))/(ng'*ng);
%         if abs(distToPlane)<maxDistToPlane
%             %plot3(cellLocs2phot(k,1), cellLocs2phot(k,2), cellLocs2phot(k,3),'g*');
%             onePhotInd=onePhotInd+1;
%             cellLocs1photGuess(onePhotInd,:)=r-distToPlane*ng;
%             cellLocs1photGuess2D(onePhotInd,:)=[s1; s2]*cellLocs1photGuess(onePhotInd,:)'+[xshiftg; yshiftg];
%             cellIDs1photGuess(onePhotInd)=k;
%         end
%     end
%     cellLocs1photGuess2D=cellLocs1photGuess2D(1:onePhotInd,:);
%     plot(cellLocs1photGuess2D(:,1), cellLocs1photGuess2D(:,2), 'ro')
%     
%     
%     
%     close(h)
%     
    
    
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



% --- Executes on selection change in TwoPMovieSelector.
function TwoPMovieSelector_Callback(hObject, eventdata, handles)
% hObject    handle to TwoPMovieSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TwoPMovieSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TwoPMovieSelector


% --- Executes during object creation, after setting all properties.
function TwoPMovieSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TwoPMovieSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TwoPImageSelector.
function TwoPImageSelector_Callback(hObject, eventdata, handles)
% hObject    handle to TwoPImageSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TwoPImageSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TwoPImageSelector


% --- Executes during object creation, after setting all properties.
function TwoPImageSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TwoPImageSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in InitialAlignment.
function InitialAlignment_Callback(hObject, eventdata, handles)
% hObject    handle to InitialAlignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns InitialAlignment contents as cell array
%        contents{get(hObject,'Value')} returns selected item from InitialAlignment

if get(handles.InitialAlignment, 'Value')==1
    set(handles.OnePMovieSelector, 'Enable', 'on')
    set(handles.OnePMapImageSelector, 'Enable', 'off')
else
    set(handles.OnePMovieSelector, 'Enable', 'off')
    set(handles.OnePMapImageSelector, 'Enable', 'on')
end


% --- Executes during object creation, after setting all properties.
function InitialAlignment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InitialAlignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OnePMovieSelector.
function OnePMovieSelector_Callback(hObject, eventdata, handles)
% hObject    handle to OnePMovieSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OnePMovieSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OnePMovieSelector


% --- Executes during object creation, after setting all properties.
function OnePMovieSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OnePMovieSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OnePImageSelector.
function OnePImageSelector_Callback(hObject, eventdata, handles)
% hObject    handle to OnePImageSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OnePImageSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OnePImageSelector


% --- Executes during object creation, after setting all properties.
function OnePImageSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OnePImageSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OnePMapImageSelector.
function OnePMapImageSelector_Callback(hObject, eventdata, handles)
% hObject    handle to OnePMapImageSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OnePMapImageSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OnePMapImageSelector


% --- Executes during object creation, after setting all properties.
function OnePMapImageSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OnePMapImageSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TwoPumPerPix_Callback(hObject, eventdata, handles)
% hObject    handle to TwoPumPerPix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TwoPumPerPix as text
%        str2double(get(hObject,'String')) returns contents of TwoPumPerPix as a double


% --- Executes during object creation, after setting all properties.
function TwoPumPerPix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TwoPumPerPix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function OnePumPerPix_Callback(hObject, eventdata, handles)
% hObject    handle to OnePumPerPix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OnePumPerPix as text
%        str2double(get(hObject,'String')) returns contents of OnePumPerPix as a double


% --- Executes during object creation, after setting all properties.
function OnePumPerPix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OnePumPerPix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
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



function MaxDistanceDiff_Callback(hObject, eventdata, handles)
% hObject    handle to MaxDistanceDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxDistanceDiff as text
%        str2double(get(hObject,'String')) returns contents of MaxDistanceDiff as a double


% --- Executes during object creation, after setting all properties.
function MaxDistanceDiff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxDistanceDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



    
    
    
    
    

%     num1photCells=size(cellLocs1phot2D,1);
%     costFnc=zeros(length(nxguesses)*length(nyguesses)*length(r0guesses)*length(xShiftGuesses)*length(yShiftGuesses),1);
%     nTrack=zeros(length(nxguesses)*length(nyguesses)*length(r0guesses)*length(xShiftGuesses)*length(yShiftGuesses),3);
%     zeroTrack=zeros(length(nxguesses)*length(nyguesses)*length(r0guesses)*length(xShiftGuesses)*length(yShiftGuesses),3);
%     closest2photProjs=zeros(length(nxguesses)*length(nyguesses)*length(r0guesses)*length(xShiftGuesses)*length(yShiftGuesses),num1photCells);
%     distances=zeros(length(nxguesses)*length(nyguesses)*length(r0guesses)*length(xShiftGuesses)*length(yShiftGuesses),num1photCells);
%     costInd=0;
% 
%     minDist=30/twoPumPerPix;
%     for xShiftInd=1:length(xShiftGuesses)
%         xshiftg=xShiftGuesses(xShiftInd);
%         for yShiftInd=1:length(yShiftGuesses)
%             yshiftg=xShiftGuesses(yShiftInd);
%             for nxInd=1:length(nxguesses)
%                 nxg=nxguesses(nxInd);
%                 for nyInd=1:length(nyguesses)
%                     nyg=nyguesses(nyInd);
%                     nzg=sqrt(1-nxg^2-nyg^2);
%                     for r0Ind=1:length(r0guesses)
%                         r0Magg=r0guesses(r0Ind);
% 
%                         % project close enough 2phot points to guessed plane
%                         cellLocs1photGuess=zeros(size(cellLocs2phot));
%                         cellLocs1photGuess2D=zeros(size(cellLocs2phot,1),2);
%                         cellIDs1photGuess=zeros(size(cellLocs2phot,1),1);
%                         ng=[nxg; nyg; nzg];
%                         ng=ng/norm(ng);
%                         r0g=r0Magg*ng;
%                         onePhotInd=0;
%                         for k=1:numCellsTotal
%                             r=cellLocs2phot(k,:)';
%                             distToPlane=(ng'*(r-r0g))/(ng'*ng);
%                             if abs(distToPlane)<minDist
%                                 %plot3(cellLocs2phot(k,1), cellLocs2phot(k,2), cellLocs2phot(k,3),'g*');
%                                 onePhotInd=onePhotInd+1;
%                                 cellLocs1photGuess(onePhotInd,:)=r'-distToPlane*ng';
%                                 cellLocs1photGuess2D(onePhotInd,:)=([s1; s2]*cellLocs1photGuess(onePhotInd,:)'+[xshiftg; yshiftg])/scale;
%                                 cellIDs1photGuess(onePhotInd)=k;
%                             end
%                         end
%                         cellLocs1photGuess2D=cellLocs1photGuess2D(1:onePhotInd,:);
%                         cellIDs1photGuess=cellIDs1photGuess(1:onePhotInd,:);
%                         num1photGuessCells=onePhotInd;
% 
%                         costInd=costInd+1;
%                         if num1photGuessCells>=num1photCells
%                             % now cost function measures how close your 1phot
%                             % guesses are to the measured 1phot points
%                             for k=1:num1photCells
%                                 [dist, closestk]=min(sum((cellLocs1photGuess2D-...
%                                     cellLocs1phot2D(k*ones(num1photGuessCells,1),:)).^2,2));
%                                 closest2photProjs(costInd, k)=cellIDs1photGuess(closestk);
%                                 distances(costInd, k)=dist;
%                                 costFnc(costInd)=costFnc(costInd)+dist;
% 
%                                 cellLocs1photGuessRest2D=cellLocs1photGuess2D;
%                                 cellLocs1photGuessRest2D(closestk,:)=[];
%                                 cellIDs1photGuessRest=cellIDs1photGuess;
%                                 cellIDs1photGuessRest(closestk,:)=[];
%                                 [dist2, closestk2]=min(sum((cellLocs1photGuessRest2D-...
%                                     cellLocs1phot2D(k*ones(num1photGuessCells-1,1),:)).^2,2));
%                                 closest2photProjs2(costInd, k)=cellIDs1photGuessRest(closestk2);
%                                 distances2(costInd, k)=dist2;
%                             end
%                         end
%                         nTrack(costInd,:)=[nxg,nyg, nzg];
%                         zeroTrack(costInd,:)=[r0Magg,xshiftg,yshiftg];
%                     end
%                 end
%             end
%         end
%     end
%     
%     nonNanInds=~isnan(costFnc);
%     costFnc=costFnc(nonNanInds,:);
%     nTrack=nTrack(nonNanInds,:);
%     zeroTrack=zeroTrack(nonNanInds,:);
%     
%     minInds=find(costFnc==min(costFnc));
%     nTrack(minInds,:);
%     zeroTrack(minInds,:);
%     diffSolInd=1;
%     for minIndInd=2:length(minInds)
%         i=minInds(minIndInd);
%         j=minInds(minIndInd-1);
%         if sum(closest2photProjs(i,:)~=closest2photProjs(j,:))>0
%             diffSolInd=diffSolInd+1;
%         end
%     end
%     
%     minInd=minInds(1);
%     nBest=nTrack(minInd,:)';
%     r0Best=zeroTrack(minInd,1)*nBest;
%     xShiftBest=zeroTrack(minInd,2);
%     yShiftBest=zeroTrack(minInd,3);
%     
%     figure(5)
%     plot3(cellLocs2phot(closest2photProjs(minInd,:),1), cellLocs2phot(closest2photProjs(minInd,:),2), cellLocs2phot(closest2photProjs(minInd,:),3),'g*');
%     hold on
%     
%     bestsurf=planeeq(xmesh, ymesh, nBest(1), nBest(2), nBest(3), r0Best(1), r0Best(2), r0Best(3));
%     bestsurf(bestsurf<0)=0;
%     surf(xmesh,ymesh,bestsurf)
%     hold all
%     
%     figure(6)
%     plot(cellLocs1phot2D(:,1), cellLocs1phot2D(:,2), 'k*')
%     hold on
%     ng=nBest;
%     r0g=r0Best;
%     xshiftg=xShiftBest;
%     yshiftg=yShiftBest;
%     onePhotInd=0;
%     for k=closest2photProjs(minInd,:)
%         r=cellLocs2phot(k,:)';
%         distToPlane=(ng'*(r-r0g))/(ng'*ng);
%         if abs(distToPlane)<minDist
%             %plot3(cellLocs2phot(k,1), cellLocs2phot(k,2), cellLocs2phot(k,3),'g*');
%             onePhotInd=onePhotInd+1;
%             cellLocs1photGuess(onePhotInd,:)=r'-distToPlane*ng';
%             cellLocs1photGuess2D(onePhotInd,:)=([s1; s2]*cellLocs1photGuess(onePhotInd,:)'+[xshiftg; yshiftg])/scale;
%             cellIDs1photGuess(onePhotInd)=k;
%         end
%     end
%     cellLocs1photGuess2D=cellLocs1photGuess2D(1:onePhotInd,:);
%     cellIDs1photGuess=cellIDs1photGuess(1:onePhotInd,:);
%     plot(cellLocs1photGuess2D(:,1), cellLocs1photGuess2D(:,2), 'ro')
%     

