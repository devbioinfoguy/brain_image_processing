% This function shift lines of ImageIn in an alternative fashion with a predefined
% Shift. The result is sent to ImageOut without any change in picture
% dimensions
function ImageOut=SingleDeinterlace(ImageIn,Shift)

PicSize=size(ImageIn);
ImageOut=ImageIn;

for i=1:PicSize(1)
    if ((i/2)==(floor(i/2)))    
        ImageOut(i,:)=zeros(1,PicSize(2));
        OldX=(1:PicSize(2))-Shift;
        Index=find(OldX>0 & OldX<=PicSize(2));
        ImageOut(i,Index)=ImageIn(i,OldX(Index));
    end
end
    
