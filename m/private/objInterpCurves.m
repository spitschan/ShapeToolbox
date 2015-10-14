function model = objInterpCurves(model)

% OBJINTERPCURVES
%
% model = objInterpCurves(model)

% Copyright (C) 2015 Toni Saarela
% 2015-06-08 - ts - first version
% 2015-10-08 - ts - added interpolation of the 'spine' curves

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

%if ~all(model.spine.x==0)
  nx = length(model.spine.x);
  if nx~=model.m
    model.spine.x = interp1(linspace(0,1,nx),model.spine.x,linspace(0,1,model.m));
  end
%end

%if ~all(model.spine.z==0)
  nz = length(model.spine.z);
  if nz~=model.m
    model.spine.z = interp1(linspace(0,1,nz),model.spine.z,linspace(0,1,model.m));
  end
%end

  ny = length(model.spine.y);
  if ny~=model.m
    model.spine.y = interp1(linspace(0,1,ny),model.spine.y,linspace(0,1,model.m));
  end
