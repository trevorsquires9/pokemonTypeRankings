%%%%%%%%%%%%%%%%%%%%%%%%%%%
% designDecisions.m
%
% DESCRIPTION
%   Initializes variables required for computation of type values in
%   typeEvaluator.m.
%
% DESIGN DECISIONS
%   - valSTD: standard deviation of normalization. Note that higher values
%   will affect the convergence of the fixed point iteration so this was
%   somewhat arbitrarily set to 1/8
%   
%   - offWeights: a vector of weights corresponding to how much a damage
%   multiplier should be valued.  For example, is hitting for 2x the damage
%   twice as good as hitting for neutral or is hitting neutrally of high
%   value and hitting for 2x only marginally better? This is a major
%   variable to be decided upon
%
%   - defWeights: similarly, a vector which determines how valuable a
%   particular damage multiplier is defensively. Here, we chose to
%   recognize resistances highly whereas double resistances and immunities
%   are only slightly more impactful. 
%
%   - offTypeImpactExp: a quantity that balances the values of a type vs
%   the above weights. For example, steel hits rock for 2x damage, but if
%   rock is a terrible typing, how much should this resistance actually
%   matter? A higher offTypeImpactExp value will put greater weight on the
%   fact that rock is a bad type and a lower offTypeImpactExp will put
%   greater weight on the fact that steel does good damage vs it. This
%   quantity greatly affects the convergence of the FPI though so it is
%   generally left unchanged. defTypeImpactExp is a similar constant. 
%
%   ovrFunc: a user defined function that maps an offensive value and a
%   defensive value of a type into a single overall value. The two commonly
%   used functions here are the geometric mean and the 2-norm.  The
%   geometric mean will give good overall values to types that have good
%   offense and defense while the 2-norm will prioritize types that have
%   either large offensive or defensive values. A major design variable. 
%
% AUTHOR
%   Trevor Squires
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = designDecisions()
typeNames = {'normal','fire','water','electric','grass','ice','fighting','poison','ground','flying','psychic','bug','rock','ghost','dragon','dark','steel','fairy'};
numType = length(typeNames);
valSTD = 0.125;

typeChart = [];
typeChart = [typeChart; 1 1 1 1 1 1 1 1 1 1 1 1  0.5 0 1 1 0.5 1]; %normal
typeChart = [typeChart; 1 0.5 0.5 1 2 2 1 1 1 1 1 2 0.5 1 0.5 1 2 1]; %fire
typeChart = [typeChart; 1 2 0.5 1 0.5 1 1 1 2 1 1 1 2 1 0.5 1 1 1]; %water
typeChart = [typeChart; 1 1 2 0.5 0.5 1 1 1 0 2 1 1 1 1 0.5 1 1 1 ]; %electric
typeChart = [typeChart; 1 0.5 2 1 0.5 1 1 0.5 2 0.5 1 0.5 2 1 0.5 1 0.5 1]; %grass
typeChart = [typeChart; 1 0.5 0.5 1 2 0.5 1 1 2 2 1 1 1 1 2 1 0.5 1]; %ice
typeChart = [typeChart; 2 1 1 1 1 2 1 0.5 1 0.5 0.5 0.5 2 0 1 2 2 0.5]; %fighting
typeChart = [typeChart; 1 1 1 1 2 1 1 0.5 0.5 1 1 1 0.5 0.5 1 1 0 2]; %poison
typeChart = [typeChart; 1 2 1 2 0.5 1 1 2 1 0 1 0.5 2 1 1 1 2 1]; %ground
typeChart = [typeChart; 1 1 1 0.5 2 1 2 1 1 1 1 2 0.5 1 1 1 0.5 1]; %flying
typeChart = [typeChart; 1 1 1 1 1 1 2 2 1 1 0.5 1 1 1 1 0 0.5 1]; %psychic
typeChart = [typeChart; 1 0.5 1 1 2 1 0.5 0.5 1 0.5 2 1 1 0.5 1 2 0.5 0.5]; %bug
typeChart = [typeChart; 1 2 1 1 1 2 0.5 1 0.5 2 1 2 1 1 1 1 0.5 1]; %rock
typeChart = [typeChart; 0 1 1 1 1 1 1 1 1 1 2 1 1 2 1 0.5 1 1]; %ghost
typeChart = [typeChart; 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 1 0.5 0]; %dragon
typeChart = [typeChart; 1 1 1 1 1 1 0.5 1 1 1 2 1 1 2 1 0.5 1 0.5]; %dark
typeChart = [typeChart; 1 0.5 0.5 0.5 1 2 1 1 1 1 1 1 2 1 1 1 0.5 2]; %steel
typeChart = [typeChart; 1 0.5 1 1 1 1 2 0.5 1 1 1 1 1 1 2 2 0.5 1]; %fairy

damageMultipliers = [0, 0.25, 0.5, 1, 2, 4];
offWeights = [0, 0.25, 0.5, 1, 2, 4];
defWeights = [3, 2.5, 2, 1, 0.5, 0.25];
offTypeChart = zeros(numType);
defTypeChart = zeros(numType);

for i = 1:length(damageMultipliers)
    ind = find(typeChart == damageMultipliers(i));
    offTypeChart(ind) = offWeights(i)*ones(1,length(ind));
    
    ind = find(typeChart' == damageMultipliers(i));
    defTypeChart(ind) = defWeights(i)*ones(1,length(ind));
end

offTypeImpactExp = 3;
defTypeImpactExp = 3;

ovrFunc = @(x) vecnorm(x,2,2);

save('designVariables')
end

