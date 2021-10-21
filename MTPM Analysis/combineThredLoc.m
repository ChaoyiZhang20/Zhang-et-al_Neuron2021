% coded by zfqy
% last edit: Nov 19,2019

function combinedLoc = combineThredLoc(threLoc,combineThre)
combinedLoc = threLoc;
for i = 1:size(threLoc,1)
    threLoc_temp = threLoc(i,:);
    gap = [];
    flag = 0;
    initP = 0;
    endP = 0;
    for j = 1:length(threLoc_temp)-1
        if threLoc_temp(j)==1 && threLoc_temp(j+1)==0
            initP = j+1;
            flag = 1;
        elseif threLoc_temp(j)==0 && threLoc_temp(j+1)==1 && flag==1
            endP = j;
            gap = [gap;[initP,endP]];
            flag = 0;
        end
    end

    for j = 1:size(gap,1)
        if gap(j,2)-gap(j,1)<combineThre
            threLoc_temp(gap(j,1):gap(j,2))=1;
        end
    end
    
    combinedLoc(i,:) = threLoc_temp;
end