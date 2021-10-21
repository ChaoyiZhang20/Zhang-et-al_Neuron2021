
% count transient events with or without specific period
% coded by zfqy
% Feb 14, 2020

function transientNum = countTransient(varargin)

if nargin == 1
    transient = varargin{1};
    startTime = 1;
    endTime = size(transient,2);
elseif nargin == 3
    transient = varargin{1};
    startTime = varargin{2};
    endTime = varargin{3};
else
    error('wrong input number')
end

startPoint = cell(size(transient,1),1);
endPoint = cell(size(transient,1),1);

for i = 1:size(transient,1)
    
    tempTansient = transient(i,:);
    
    if tempTansient(startTime) == 1
        startPoint{i} = [startPoint{i},startTime];
    end
    
    for j = startTime+1:endTime-1
        if (tempTansient(j)==1 && tempTansient(j-1)==0)
            startPoint{i} = [startPoint{i},j];
        end
        
        if tempTansient(j)==1 && tempTansient(j+1)==0
            endPoint{i} = [endPoint{i},j];
        end
    end
    
    if tempTansient(endTime) == 1
        endPoint{i} = [endPoint{i},endTime];
    end
    
end

transientNum = arrayfun(@(x) length(startPoint{x}),1:size(transient,1),...
    'uniformoutput',false);
transientNum = cell2mat(transientNum)';
