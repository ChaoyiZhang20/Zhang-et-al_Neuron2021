%% 
% classification1: increase in Push/ increase in Retreat
% classification2: increase in Push/ decrease in Retreat
% classification3: increase in Push/ no change in Retreat
% classification4: decrease in Push/ increase in Retreat
% classification5: decrease in Push/ decrease in Retreat
% classification6: decrease in Push/ no change in Retreat
% classification7: no change in Push/ increase in Retreat
% classification8: no change in Push/ decrease in Retreat
% classification9: no change in Push/ no change in Retreat

function [classification]=ClassChange(unitNum, Push_H, Push_CI, Retreat_H, Retreat_CI)
classification=zeros(unitNum,1);
for tt=1:unitNum
    switch Push_H(tt)
        case 1   %% change in push
            if  Push_CI(tt)>0  %% increase in push
                switch Retreat_H(tt)
                    case 1 %% change in retreat
                        if Retreat_CI(tt)>0 %% increase in retreat
                            classification(tt,1)=1;
                        else %% decrease in retreat
                            classification(tt,1)=2;
                        end
                    case 0
                        classification(tt,1)=3;
                end
            else  %% decrease in push
                switch Retreat_H(tt)
                    case 1 %% change in retreat
                        if Retreat_CI(tt)>0 %% increase in retreat
                            classification(tt,1)=4;
                        else %% decrease in retreat
                            classification(tt,1)=5;
                        end
                    case 0
                        classification(tt,1)=6;
                end
            end          
            
        case 0  %% no change in push
            switch Retreat_H(tt)
                    case 1 %% change in retreat
                        if Retreat_CI(tt)>0 %% increase in retreat
                            classification(tt,1)=7;
                        else %% decrease in retreat
                            classification(tt,1)=8;
                        end
                    case 0
                        classification(tt,1)=9;
            end
    end
end