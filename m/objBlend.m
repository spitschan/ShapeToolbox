function m = objBlend(m1,m2,w1,w2)

% OBJBLEND
%
% Usage: model = objBlend(model1,model2,w1,w2)

% Copyright (C) 2015 Toni Saarela
% 2015-04-03 - ts - first version

% TODO:
% - Option to save/not save.
% - Option to give filename(s).
% - Better parsing of input arguments.
% - Check that number of vertices matches.  Add option for
%   interpolation?
% - Include the parameters (and weights) of the two models somehow
%   sensibly.
% - Vectors of weights are accepted as input but not really
%   used---implement

if nargin==2
   w1 = .5;
   w2 = .5;
elseif nargin==3
  if ~(all(w1<=1) && all(w1>=0))
     error('With three input arguments, the weights have to be in range [0,1].');
  end
  w2 = 1 - w1;
elseif nargin==4
  if length(w1)~=length(w2)
    if ~(isscalar(w1) || isscalar(w2))
      error('Weight vectors have to have the same length or one has to be a scalar.');
    end
  end
  if length(w1)>length(w2)
    w2 = w2 * ones(size(w1));
  elseif length(w1)<length(w2)
    w1 = w1 * ones(size(w1));
  end
  tot = w1 + w2;
  w1 = w1./tot;
  w2 = w2./tot;
else
  error('Incorrect number of input arguments.');
end

if ~strcmp(m1.shape,m2.shape)
   error('Only objects with the same base shape can be blended.');
end

switch m1.shape
  case 'sphere'
    m = m1;
    m.R = w1(1)*m1.R + w2(1)*m2.R;
    [X,Y,Z] = sph2cart(m.Theta,m.Phi,m.R);
    m.vertices = [X Y Z];
    m.normals = [];
    m.faces = [];
  case 'plane'
    m = m1;
    m.Z = w1(1)*m1.Z + w2(1)*m2.Z;
    m.vertices = [m.X m.Y m.Z];
    m.normals = [];
    m.faces = [];
  case 'cylinder'
    fprintf('Blending not implemented for cylinders.\n');
  case 'torus'
    fprintf('Blending not implemented for tori.\n');
  case 'revolution'
    fprintf('Blending not implemented for surface-of-revolution.\n');
  otherwise
    error('Unknown or unsupported shape.');
end

w1 
w2
