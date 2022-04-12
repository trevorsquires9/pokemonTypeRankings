clear
clc
close all;

%% Data Initialization
load typeValues
load naiveChart.mat

[numType,~] = size(typeChart);

%% Model Type Chart as a Transition Probability Matrix
probTrans = zeros(numType);
for i = 1:numType
    draws = [];
    winners = [];
    losers = [];
    for j = 1:numType
        if typeChart(i,j) > typeChart(j,i)
        	losers = [losers; j];
        elseif typeChart(i,j) < typeChart(j,i)
            winners = [winners; j];
        else
            draws = [draws; j];
        end
    end
    tmp = zeros(1,numType);
    tmp(winners) = ones(1,length(winners))/(numType);
    tmp(draws) = ones(1,length(draws))/(2*(numType));
    tmp(i) = (length(losers) + (length(draws)+1)/2)/(numType);
    probTrans(i,:) = tmp;
end

%% Analysis of Markov Property
[vec,val] = eig(probTrans');
vec = real(vec);
val = diag(val);
stationaryVec = vec(:,1);
stationaryVec = stationaryVec/sum(stationaryVec);

ovrVal = summary.OverallValue;

summary = table(typeNames', stationaryVec, ovrVal, 'VariableNames', {'TypeName', 'LimitingDistribution','OverallValue'});
sortrows(summary, 'LimitingDistribution')