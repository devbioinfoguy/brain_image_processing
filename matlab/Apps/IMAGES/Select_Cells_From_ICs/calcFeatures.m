function features=calcFeatures(FiltersToClassify, TracesToClassify)

global SpikeTraceData
global SpikeImageData

numICs=length(FiltersToClassify);
examples=zeros(numICs,6);

% parameters for selecting local area size
USEMEAN=false;
USEMAX=false;
USESTD=true;
sizeSigma=4;

% time features
for ICind=1:numICs
    TraceInd=TracesToClassify(ICind);
    ica_sig(ICind, :)=SpikeTraceData(TraceInd).Trace;
end 
nummaxes=20;
stds_time = std(ica_sig');
stdAll=std(reshape(ica_sig, numel(ica_sig),1));
means_time = mean(ica_sig');
clear nspikes
clear spikeDurs
nspikes=zeros(numICs,1);
hasSpike=zeros(numICs,1);
spikeDurs=zeros(numICs,1);
maxes=zeros(numICs,nummaxes);
spikeSigma=4;
for ICind=1:numICs
    thisSignal=ica_sig(ICind,:);
    thresh=means_time(ICind)+spikeSigma*stdAll;
    j=1;
    while j<nummaxes
        [val, ind]=max(thisSignal);
        
        if val>thresh
            indL=ind-1;
            spikeDur=1;
            notHigh=0;
            % search behind
            while notHigh<5
                if indL<1
                    notHigh=10;
                elseif thisSignal(indL)>thresh
                    spikeDur=spikeDur+1;
                    notHigh=0;
                else
                    notHigh=notHigh+1;
                end
                indL=indL-1;
            end
            % search ahead
            notHigh=0;
            indH=ind+1;
            while notHigh<5
                if indH>length(thisSignal)
                    notHigh=10;
                elseif thisSignal(indH)>thresh
                    spikeDur=spikeDur+1;
                    notHigh=0;
                else
                    notHigh=notHigh+1;
                end
                indH=indH+1;
            end
            if spikeDur>1
                spikeDurs(ICind)=spikeDurs(ICind)+spikeDur;
                nspikes(ICind)=nspikes(ICind)+1;
                topind=indH-4;
                bottomind=indL+4;
            else
                bottomind=max(ind-1,1);
                topind=min(ind+1,length(thisSignal));
            end

            j=j+1;
            thisSignal(bottomind:topind)=[];
            
        else
            j=nummaxes+1;
        end

    end
    hasSpike(ICind)=nspikes(ICind)>0;
end
clear ica_sig

spikeDurs(logical(hasSpike))=spikeDurs(logical(hasSpike))./nspikes(logical(hasSpike));
hasSpike(hasSpike==0)=-1;
examples(:,1)=nspikes;
examples(:,2)=spikeDurs;


% spatial features
numPixelsHor=size(SpikeImageData(FiltersToClassify(1)).Image,2);
numPixelsVert=size(SpikeImageData(FiltersToClassify(1)).Image,1);
for k=2:length(FiltersToClassify)
    if size(SpikeImageData(FiltersToClassify(1)).Image,2)~=numPixelsHor
        error('calcFeatures:sizeCheck', 'IC Filters do not all have the same size')
    elseif size(SpikeImageData(FiltersToClassify(1)).Image,1)~=numPixelsVert
        error('calcFeatures:sizeCheck', 'IC Filters do not all have the same size')
    end
end

sums=zeros(numICs,1);
stds=zeros(numICs,1);
spotSizes=zeros(numICs,1);
FTspotSizes=zeros(numICs,1);
diffFTquartiles=zeros(numICs,1);
whatsLeftVals=zeros(numICs,1);
imageMaxes=zeros(numICs,1);
r=15;
FTr=10;
for ICind=1:numICs
    this_filter=SpikeImageData(FiltersToClassify(ICind)).Image;
    this_std=std(reshape(this_filter,numel(this_filter),1));
    this_mean=std(reshape(this_filter,numel(this_filter),1));
    
    %find max and cut off to obtain just local area
    [vals,ind1]=max(this_filter);
    [val,ind2]=max(vals);
    this_max=val;
    imageMaxes(ICind)=val;
    meanPositionY=ind1(ind2);
    meanPositionX=ind2;
    bottomind=max(1,meanPositionY-r);
    topind=min(numPixelsVert,meanPositionY+r);
    leftind=max(1,meanPositionX-r);
    rightind=min(numPixelsHor,meanPositionX+r); 
    this_max_area=this_filter(bottomind:topind,leftind:rightind);   
    
    %sums and stds of local area
    sums(ICind)=sum(sum(this_max_area))/numel(this_max_area);
    stds(ICind)=std(reshape(this_max_area,numel(this_max_area),1));
    
    %number of pixels >4stds from mean, but truncated to only include local area
    if USEMEAN
        spotThresh=this_mean/2;
    elseif USEMAX
        spotThresh=0.5*this_max;
    elseif USESTD
        spotThresh=this_mean+sizeSigma*this_std;
    end
    this_max_area(this_max_area<spotThresh)=0;
    spotSizes(ICind)=sum(sum(this_max_area>0));  

    % now calculate image features on fft of image
    % useful for identifying dust
    this_filter=abs(fftshift(fft2(this_filter)));
    
    %find max and cut off to obtain just local area
    [vals,ind1]=max(this_filter);
    [val,ind2]=max(vals);
    this_max=val;
    imageMaxes(ICind)=val;
    meanPositionY=ind1(ind2);
    meanPositionX=ind2;
    bottomind=max(1,meanPositionY-FTr);
    topind=min(numPixelsVert,meanPositionY+FTr);
    leftind=max(1,meanPositionX-FTr);
    rightind=min(numPixelsHor,meanPositionX+FTr); 
    this_max_area=this_filter(bottomind:topind,leftind:rightind);
    
    %sums and stds of local area
    sums(ICind)=sum(sum(this_max_area))/numel(this_max_area);
    stds(ICind)=std(reshape(this_max_area,numel(this_max_area),1));
    
    %number of pixels >4stds from mean, but truncated to only include area
    spotThresh=0.5*this_max;
    this_max_area(this_max_area<spotThresh)=0;
    FTspotSizes(ICind)=sum(sum(this_max_area>0));
    
    diffFTquartiles(ICind)=abs(sum(sum(abs(this_filter(1:50, 1:50))+abs(this_filter(end-49:end, end-49:end))))-...
    sum(sum(abs(this_filter(1:50, end-49:end))+abs(this_filter(end-49:end, 1:50)))))/...
    sum(sum(abs(this_filter(1:50, 1:50))+abs(this_filter(end-49:end, end-49:end))));
end

spotSizes(spotSizes>500)=0;
examples(:,3)=spotSizes;
examples(:,4)=FTspotSizes;
spotSizeDev=(spotSizes-mean(spotSizes)).^2;
examples(:,5)=spotSizeDev;
examples(:,6)=diffFTquartiles;


% normalize features
exMeans=mean(examples);
if ismember(0, exMeans)
    warning('calcFeatures:meanZero', 'Mean of some feature is zero - choosing more ICs to classify will give better classification');
    exMeans(exMeans==0)=1;
end
examples=examples./(exMeans'*ones(1,size(examples,1)))';

% add constant to features to allow offset
features=[ones(size(examples,1),1) examples];
