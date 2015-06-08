function model = objInterpCurves(model)

% OBJINTERPCURVES
%
% model = objInterpCurves(model)

% Copyright (C) 2015 Toni Saarela
% 2015-06-08 - ts - first version

if isfield(model,'rcurve')
  nrcurve = length(model.rcurve);
  if nrcurve~=model.m
    model.rcurve = interp1(linspace(0,1,nrcurve),model.rcurve,linspace(0,1,model.m));
  end
end

if isfield(model,'ecurve')
  necurve = length(model.ecurve);
  if necurve~=model.n
    model.ecurve = interp1(linspace(0,1,necurve),model.ecurve,linspace(0,1,model.n));
  end
end

