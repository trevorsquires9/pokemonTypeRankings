function [output] = defaultField(struct,field,value)

if ~(isfield(struct,field))
    output = value;
else
    output = getfield(struct,field);
end
end

