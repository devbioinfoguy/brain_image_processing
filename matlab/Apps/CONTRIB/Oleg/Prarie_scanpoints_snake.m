cd('z:\');
Nx=3;
Ny=3;
step=200;
ind=0;
filename=strcat('prariepoints_snake_',num2str(Nx),'x',num2str(Ny),'step',num2str(step),'.xy');
fileID = fopen(filename,'w');
fprintf(fileID,'<?xml version="1.0" encoding="utf-8"?>\n');
fprintf(fileID,'<StageLocations>\n');

formatSpec = '<StageLocation index="%d" x="%d" y="%d" z="%d" />\n';


direct='South';

for i=1:1:Nx
    if(mod(i,2)==1)               
        for j=1:1:Ny
            ind=ind+1;
            X=(i-1)*step;
            Y=(j-1)*step;
            fprintf(fileID,formatSpec,ind,X,Y,0);            
        end
    else
        for j=Ny:-1:1
            ind=ind+1;
            X=(i-1)*step;
            Y=(j-1)*step;
            fprintf(fileID,formatSpec,ind,X,Y,0);            
        end        
    end
        
   
end

fprintf(fileID,'</StageLocations>\n');

fclose(fileID);

% <?xml version="1.0" encoding="utf-8"?>
% <StageLocations>
%   <StageLocation index="0" x="0" y="0" z="0" />
%   <StageLocation index="1" x="0" y="500" z="0" />
%   <StageLocation index="3" x="0" y="1000" z="0" />
%   <StageLocation index="4" x="0" y="1500" z="0" />
%   <StageLocation index="5" x="0" y="2000" z="0" />
%   <StageLocation index="6" x="0" y="2500" z="0" />
%   <StageLocation index="7" x="0" y="1000" z="0" />
%   <StageLocation index="8" x="0" y="1000" z="0" />
%   <StageLocation index="9" x="0" y="1000" z="0" />
% </StageLocations>
