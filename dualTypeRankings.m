%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dualTypeRanking.m
%
% DESCRIPTION
%   Attempts to quantify how good different pokemon types are by finding a
%   fixed point to a potentially nonlinear system. 
%   
% METHODOLOGY
%   Each type has an initially unknown associated value that quantifies how
%   good the type is relative to others. This is further broken down into
%   two values, an offensive and defensive component.  Here we assume that
%   the offensive value of a type is a linear function of the defensive 
%   values of the other types (via the type chart). Similarly, the
%   defensive value of a type is a linear function of the offensive values
%   of the other types. We will attempt to compute these values by 
%   solving a fixed point equation. 
%
% AUTHOR
%   Trevor Squires
%
% FUNCTION DEPENDENCIES
%
% NOTES
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Post Processing

summary = table(ind, firstTypeName, secondTypeName, offVal, defVal, fpiVal, 'VariableNames',{'IndexNumber','FirstType','SecondType','OffensiveValue','DefensiveValue','OverallValue'});

