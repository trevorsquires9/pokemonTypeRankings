%%%%%%%%%%%%%%%%%%%%%%%%%%%
% typeEvaluation.m
%
% DESCRIPTION
%   Attempts to quantify how good different pokemon types are. Methods used
%   include a fixed point to a potentially nonlinear system and computing a
%   limiting distribution of a "King of the hill" type Markov chain
%   
% METHODOLOGY
%   Markov Chain:
%   One way to define the "goodness" of a type is to evaluate how well it
%   performs against others. For example, one may consider the ghost type 
%   to be a fairly good one since it rarely loses a 1v1 matchups against 
%   other types. This approach introduces a sort of king of the hill style
%   of evaluation. We consider each type to be participants in a game of 
%   king of the hill where one type is randomly initialized to be the king.
%   A challenger is then randomly selected to fight the king in a 1v1.  The
%   winner is determined by the type matchup between the two. A type's
%   value is then measured by the amount of time that the type remains the
%   king in a long term experiment. 
%
%   Fixed Point Method:
%   Each type has an initially unknown associated value that quantifies how
%   good the type is relative to others. This is further broken down into
%   two values, an offensive and defensive component.  Here we assume that
%   the offensive value of a type is a function of the defensive 
%   values of the other types (via the type chart). Similarly, the
%   defensive value of a type is a function of the offensive values
%   of the other types. We will attempt to compute these values by 
%   solving a fixed point equation. 
%
%
% AUTHOR
%   Trevor Squires
%
% FUNCTION DEPENDENCIES
%   - designDecisions.m
%
% NOTES
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clear MATLAB
clear
clc
close all;

%% Data Initialization
load designVariables

%% Markov Approach
%Construct probability transition matrix
probTrans = zeros(numType);

for i = 1:numType
    %Determine who beats/loses/draws type i in a 1v1
    draws = find(typeChart(i,:) == typeChart(:,i)');
    winners = find(typeChart(i,:) < typeChart(:,i)');
    losers = find(typeChart(i,:) > typeChart(:,i)');

    %Distribute probability of transfering kingship over type matchups
    probTrans(i,winners) = ones(1,length(winners))/(numType);
    probTrans(i,draws) = ones(1,length(draws))/(2*(numType));
    probTrans(i,i) = (length(losers) + (length(draws)+1)/2)/(numType);
end

%Compute stationary vector as an eigenvector of probability transition
%matrix
[vec,~] = eig(probTrans');
vec = real(vec);
markovRank = vec(:,1);
markovRank = markovRank/sum(markovRank); %normalize


%% Fixed Point Method
offVal = ones(numType,1);
defVal = ones(numType,1);
fpiVal = ones(numType,1);

tol = 1e-10;
it = 0;

%Computation of new type values
varChange = Inf;
while varChange > tol
    %Store previous solution for termination condition
    oldVar = fpiVal;
    
    %Offensive values are computed as a function of the defensive
    %values of the types weighted with the damage multipliers from the
    %type chart. We normalize afterwards.
    offVal = offTypeChart*(fpiVal.^offTypeImpactExp);
    offVal = ones(length(numType),1) + normalize(offVal)*valSTD;
    
    %Defensive values are computed similarly using the values of
    %types. 
    defVal = defTypeChart*(fpiVal.^defTypeImpactExp);
    defVal = ones(length(numType),1) + normalize(defVal)*valSTD;
    
    %Overall values are computed according to the function in design decisions 
    fpiVal = ovrFunc([offVal defVal]);
    
    %Store new solution and compare to old one for termination
    newVar = fpiVal;
    varChange = norm(newVar-oldVar);
    
    it = it+1;
end
fpiVal = ovrFunc([offVal defVal]);

%% Dual Type Rankings
possibleDualTypes = nchoosek(1:numType,2);
numDualTypes = nchoosek(numType,2);
ind = (1:numDualTypes)';
firstTypeName = cell(numDualTypes,1);
secondTypeName = cell(numDualTypes,1);
offDualVal = zeros(numDualTypes,1);
defDualVal = zeros(numDualTypes,1);

%Compute dual type values 
for i = 1:numDualTypes
    firstTypeInd = possibleDualTypes(i,1);
    secondTypeInd = possibleDualTypes(i,2);
    firstTypeName{i} = typeNames{firstTypeInd};
    secondTypeName{i} = typeNames{secondTypeInd};
    
    %Offensive value is defined by how well you hit each type with either
    %of your STABs
    offensiveVector = max([typeChart(firstTypeInd,:);typeChart(secondTypeInd,:)]);
    offDualVal(i) = offensiveVector*(fpiVal.^offTypeImpactExp);
    
    %Defensive value is how well you take hits from another type
    typeChartT = typeChart';
    defensiveVector = (typeChartT(firstTypeInd,:).*typeChartT(secondTypeInd,:));
    defensiveVector = 3.^(1.-defensiveVector);
    defDualVal(i) = defensiveVector*(fpiVal.^defTypeImpactExp);
    
end
%Normalize to keep weights of offense/defense the same
offDualVal = ones(length(numType),1) + normalize(offDualVal)*0.125;
defDualVal = ones(length(numType),1) + normalize(defDualVal)*0.125;
ovrDualVal = ovrFunc([offDualVal defDualVal]);
%% Post Processing
singleTypeTable = table(typeNames', offVal, defVal,fpiVal,markovRank, 'VariableNames',{'Type','OffensiveValue','DefensiveValue','FPIValue', 'MarkovValue'});
dualTypeTable = table(ind, firstTypeName,secondTypeName,offDualVal, defDualVal, ovrDualVal, 'VariableNames', {'IndexNumber','FirstType','SecondType','OffensiveValue','DefensiveValue','OverallValue'});

sortrows(dualTypeTable,'OverallValue')