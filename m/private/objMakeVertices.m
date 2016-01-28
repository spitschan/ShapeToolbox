function model = objMakeVertices(model)

% OBJMAKEVERTICES
%
% Usage: MODEL = objMakeVertices(model)
%
% Compute vertices for the model.  Do the necessary conversions (eg
% from spherical to cartesian) and add/update the field "vertices" in
% the model structure.

% Copyright (C) 2016 Toni Saarela
% 2016-01-21 - ts - first version

switch model.shape
  case 'sphere'
    model.vertices = objSph2XYZ(model.Theta,model.Phi,model.R);
  case 'plane'
    model.vertices = [model.X model.Y model.Z];
  case {'cylinder','revolution','extrusion'}
    if model.flags.caps
      model = objAddCaps(model);
    end
    model.X =  model.R .* cos(model.Theta);
    model.Z = -model.R .* sin(model.Theta);
    X = model.X + model.spine.X;
    Z = model.Z + model.spine.Z;
    model.vertices = [X model.Y Z];
  case 'torus'
    model.vertices = objSph2XYZ(model.Theta,model.Phi,model.r,model.R);
  case 'worm'
    % TODO: objAddCaps
    model = objMakeWorm(model);
  case 'disk'
    model.vertices = [model.X model.Y model.Z];    
  otherwise
    error('Unknown shape.');
end
