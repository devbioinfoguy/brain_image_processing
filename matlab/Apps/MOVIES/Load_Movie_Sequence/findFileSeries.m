function [returnFileGroup] = findFileSeries(filePath, allowskiplength, inclSmallerNumbers)

% input is the filepath of one file in a series of files that have
% some numeric indexing in their filenames

% allowskiplength allows skipping of numbers in the index (default = 0 =>
% no skipping allowed, only an uninterrupted series of indixed filenames will be returned)

% inclSmallerNumbers: if false, we only look for filenames containing higher
% indices, if true, we also accept filenames with smaller indices; default
% = false

if ~exist(filePath,'file')
    disp([filePath, ' does not exist. This can lead to strange results...']);
end

if nargin < 3 || isempty(inclSmallerNumbers)
    inclSmallerNumbers = false;
end

if nargin < 2 || isempty(allowskiplength)
    allowskiplength = 0;
end

% first find numbers in the input path that could be used as filename index
[parentDirectory, fileName, fileExt] = fileparts(filePath);
veryBigInt = 100000;
indexPosCount = 1;
indexStartedWalk = false;
for stringWalk = 1:length(fileName)
    if ~indexStartedWalk && isnumReal(fileName(stringWalk))
        indexPositions(indexPosCount,1) = stringWalk;
        indexStartedWalk = true;
        if stringWalk == length(fileName)
            indexPositions(indexPosCount,2) = stringWalk;
            indexStartedWalk = false;
            indexPosCount = indexPosCount + 1;
        end
    elseif indexStartedWalk && ~isnumReal(fileName(stringWalk))
        indexPositions(indexPosCount,2) = stringWalk - 1;
        indexStartedWalk = false;
        indexPosCount = indexPosCount + 1;
    elseif indexStartedWalk && stringWalk == length(fileName)
        indexPositions(indexPosCount,2) = stringWalk;
        indexStartedWalk = false;
        indexPosCount = indexPosCount + 1;
    end    
end

indexPosCount = indexPosCount - 1;


% now walk and look for files - first with increasing index numbers, then with decreasing index numbers in filename
% finally, we will return the longest list we find
maxFileNum = 0;
foundFilesUp = cell(1,indexPosCount);
foundFilesDown = cell(1,indexPosCount);
for testcounter = 1:indexPosCount
    foundFileCounter = 0;
    foundFilesUp{testcounter} = cell(1,veryBigInt);
    foundFilesDown{testcounter} = cell(1,veryBigInt);
    leftsideString = fileName(1:indexPositions(testcounter,1) - 1);
    rightsideString = fileName(indexPositions(testcounter,2) + 1:length(fileName));
    intString = fileName(indexPositions(testcounter,1):indexPositions(testcounter,2));
    if intString(1) == '0'
        padded = true;
        padLen = length(intString);
    else
        padded = false;
    end
    
    firstFileIndex = str2double(intString);
    nextFileIndex = str2double(intString);
    localcounter = 0;
    skipcounter = 0;
    upFileNum(testcounter) = 0;
    while localcounter < veryBigInt && skipcounter > -2
        localcounter = localcounter + 1;
        skipcounter = 0;
        while skipcounter > -1
            if padded
                intString = intToZeroPaddedString(nextFileIndex, padLen);
            else
                intString = num2str(nextFileIndex);
            end
            testFilePath = fullfile(parentDirectory,[leftsideString, intString, rightsideString, fileExt]);
            if exist(testFilePath,'file')
                foundFilesUp{testcounter}{localcounter} = testFilePath;
                foundFileCounter = foundFileCounter + 1;
                upFileNum(testcounter) = upFileNum(testcounter) + 1;
                if foundFileCounter > maxFileNum
                    maxFileNum = foundFileCounter;
                    largestFileBatch = testcounter;
                end
                skipcounter = -1;
            else    
                skipcounter = skipcounter + 1;
            end
            nextFileIndex = nextFileIndex + 1;
            if skipcounter > allowskiplength
                skipcounter = -2;
            end
        end
    end
    
    nextFileIndex = firstFileIndex - 1;
    localcounter = 0;
    skipcounter = 0;
    downFileNum(testcounter) = 0;
    while localcounter < veryBigInt && skipcounter > -2 && nextFileIndex >= 0
        localcounter = localcounter + 1;
        skipcounter = 0;
        while skipcounter > -1
            if padded
                intString = intToZeroPaddedString(nextFileIndex, padLen);
            else
                intString = num2str(nextFileIndex);
            end
            testFilePath = fullfile(parentDirectory,[leftsideString, intString, rightsideString, fileExt]);
            if exist(testFilePath,'file') && inclSmallerNumbers
                foundFilesDown{testcounter}{localcounter} = testFilePath;
                foundFileCounter = foundFileCounter + 1;
                downFileNum(testcounter) = downFileNum(testcounter) + 1;
                if foundFileCounter > maxFileNum
                    maxFileNum = foundFileCounter;
                    largestFileBatch = testcounter;
                end
                skipcounter = -1;
            else    
                skipcounter = skipcounter + 1;
            end
            nextFileIndex = nextFileIndex - 1;
            if skipcounter > allowskiplength
                skipcounter = -2;
            end
        end
    end
    
end

if maxFileNum > 1
    foundFilesUp{largestFileBatch} = foundFilesUp{largestFileBatch}(1:upFileNum(largestFileBatch));
    if downFileNum(largestFileBatch) > 0
        foundFilesDown{largestFileBatch} = fliplr(foundFilesDown{largestFileBatch}(1:downFileNum(largestFileBatch)));
    else
        foundFilesDown{largestFileBatch} = [];
    end
    returnFileGroup = [foundFilesDown{largestFileBatch},foundFilesUp{largestFileBatch}];
else
    returnFileGroup{1} = filePath;
end



function [out] = isnumReal(mynumstr)
% input is a string, output boolean

testnum = str2double(mynumstr);
if ~isnan(testnum) && isreal(testnum)
    out = true;
else
    out = false;
end
    