function m1 = objBlend(m1,m2,varargin)

% OBJBLEND
%
% Usage: MODEL = OBJBLEND(MODEL1,MODEL2,[W],[OPTIONS])
%                OBJBLEND(MODEL1,MODEL2,[W],[OPTIONS])
%
% Blend (compute a weighted average of) two model objects.  
%
% INPUT MODELS AND WEIGHTS:
% =========================
% 
% With a scalar weight W (which has to be in 0-1), give weight W to
% MODEL1 and weight 1-W to MODEL2.
%
% With a two-vector weight W=[W1 W2], weight the models in proportions
% W1/(W1+W2) and W2/(W1+W2).
%
% If the weight is omitted, average the models (weights 0.5 and 0.5).
% 
% The input models (MODEL1 and MODEL2) are structures returned by the
% objMake*-functions.  The models have to have the same base shape
% (sphere, plane...) and their mesh sizes (number of vertices in each
% direction) have to match.
%
% RETURNS:
% ========
% 
% A new model structure.  NOTE: At the moment, the returned model only
% contains the parameters of the first model.  These are also written
% into the obj-file comments.
% 
% OPTIONS:
% ========
% 
% FILENAME
% A single string giving the name of the file in which to
% save the model.  Example: objBlend(m1,m2,.5,'blended.obj',...)
%
% SAVE
% Boolean, toggle saving the model to a file.  Default is true, the
% model is saved.  You might want to set this to false if you just
% want to make the model structure and modify it with another
% objMake*-function or with objBlend.  Example: 
% m = objMake(...,'save',false,...)
%
% EXAMPLES:
% =========
%
% % Make models:
% m1 = objMakeNoise('sphere',[],'save',false);
% m2 = objMakeBumpy('sphere',[],'save',false);
%
% % Blend 50-50, save in 'sphere_050_050.obj':
% objBlend(m1,m2)
%
% % Save the same model in 'blob.obj':
% objBlend(m1,m2,'blob.obj')
%
% % Weights 0.2 and 0.8, not saved:
% m = objBlend(m1,m2,0.2,'save',false);
%
% % Weights again 0.2 and 0.8, save in 'blob.obj':
% m = objBlend(m1,m2,[4 16],'blob.obj');

% Copyright (C) 2015 Toni Saarela
% 2015-04-03 - ts - first version
% 2015-05-14 - ts - eats cylinders; other minor tweaks
% 2015-05-14 - ts - devours tori, surfaces of revolution
%                   wrote help, added options, saving of model
% 2015-06-02 - ts - updated help; fixed a bug in setting default weights

% TODO:
% - Better parsing of input arguments.
% - Check that number of vertices matches.  Add option for
%   interpolation?  Meh.
% - Include the parameters (and weights) of the two models somehow
%   sensibly.
% - Vectors of weights are accepted as input but not really
%   used---implement

dosave = true;
filename = '';
[w,par] = parseparams(varargin);
if ~isempty(par)
  ii = 1;
  while ii<=length(par)
    if ischar(par{ii})
      switch lower(par{ii})
        case 'save'
          if ii<length(par) && isscalar(par{ii+1})
            ii = ii + 1;
            dosave = par{ii};
          else
            error('No value or a bad value given for option ''save''.');
          end
        otherwise
          filename = par{ii};
      end
    end
    ii = ii + 1;
  end
end

if isempty(w)
  w = [.5 .5];
else 
  w = w{1};
  if isscalar(w)
    if ~((w<=1) && (w>=0))
      error('With three input arguments, the weight has to be in range [0,1].');
    end
    w(2) = 1 - w;
  else
    tot = w(1) + w(2);
    w(1) = w(1)./tot;
    w(2) = w(2)./tot;
  end
end

if isempty(filename)
   filename = sprintf('%s_%03d_%03d.obj',m1.shape,100*w(1),100*w(2));
end

if ~strcmp(m1.shape,m2.shape)
  error('Only objects with the same base shape can be blended.');
end

switch m1.shape
  case 'sphere'
    m1.R = w(1)*m1.R + w(2)*m2.R;
    [X,Y,Z] = sph2cart(m1.Theta,m1.Phi,m1.R);
    % Switch z- and y-coordinates so that the reference plane is the
    % x-z plane and y is "up", for consistency across all functions.
    m1.vertices = [X Z -Y];
  case 'plane'
    m1.Z = w(1)*m1.Z + w(2)*m2.Z;
    m1.vertices = [m1.X m1.Y m1.Z];
  case 'cylinder'
    m1.R = w(1)*m1.R + w(2)*m2.R;
    X =  m1.R .* cos(m1.Theta);
    Z = -m1.R .* sin(m1.Theta);
    m1.vertices = [X m1.Y Z];
  case 'torus'
    m1.R = w(1)*m1.R + w(2)*m2.R;
    m1.r = w(1)*m1.r + w(2)*m2.r;

    X = (m1.R + m1.r .* cos(m1.Phi)).*cos(m1.Theta);
    Y = (m1.R + m1.r .* cos(m1.Phi)).*sin(m1.Theta);
    Z = m1.r .* sin(m1.Phi);

    % Switch z- and y-coordinates so that the reference plane is the
    % x-z plane and y is "up", for consistency across all functions.
    m1.vertices = [X Z -Y];
  case 'revolution'
    m1.R = w(1)*m1.R + w(2)*m2.R;
    X =  m1.R .* cos(m1.Theta);
    Z = -m1.R .* sin(m1.Theta);
    m1.vertices = [X m1.Y Z];
  otherwise
    error('Unknown or unsupported shape.');
end

m1.normals = [];
m1.faces = [];

if dosave
  m1.filename = filename;
  m1 = objSaveModel(m1);
end

if ~nargout
   clear m1
end
