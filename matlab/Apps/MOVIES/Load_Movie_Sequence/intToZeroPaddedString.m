function [outstring] = intToZeroPaddedString(myint, padLength)

outstringtemp = sprintf('%u',myint);
strlen = length(outstringtemp);
topad = padLength - strlen;


if topad > 0
    outstring(1,1:padLength) = '0';
    outstring(topad+1:padLength) = outstringtemp;
else
    outstring = outstringtemp;
end

end