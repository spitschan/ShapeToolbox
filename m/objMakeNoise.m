function model = objMakeNoise(shape,nprm,varargin)

% OBJMAKENOISE
%
% Usage:           objMakeNoise()
%                  objMakeNoise(NPAR,[OPTIONS])
%                  objMakeNoise(NPAR,MPAR,[OPTIONS])
%          model = objMakeNoise(...)


% Copyright (C) 2015 Toni Saarela
% 2015-05-31 - ts - first version, based on objMakeSphereNoisy and
%                    others

%------------------------------------------------------------

if ischar(shape)
  model = objDefaultStruct(shape);
elseif isstruct(shape)
  model = shape;
  model = objDefaultStruct(shape,true);
  model.flags.new_model = false;
else
  error('Argument ''shape'' has to be a string or a model structure.');
end
clear shape
model.filename = [model.shape,'noisy.obj'];

% Check and parse optional input arguments
[modpar,par] = parseparams(varargin);
model = objParseArgs(model,par);

%------------------------------------------------------------

switch model.shape
  case 'sphere'
    defprm = [8 1 0 45 .1 0];
  case 'plane'
    defprm = [8 1 0 45 .1 0];
  case 'cylinder'
    defprm = [8 1 0 45 .1 0];
  case 'torus'
    defprm = [8 1 0 45 .1 0];
  case 'revolution'
    defprm = [8 1 0 45 .1 0];
    ncurve = length(model.curve);
    if ncurve~=model.m
      model.curve = interp1(linspace(0,1,ncurve),model.curve,linspace(0,1,model.m));
    end
    %model.curve = model.curve/max(model.curve);
  case 'extrusion'
    defprm = [8 1 0 45 .1 0];
    ncurve = length(model.curve);
    if ncurve~=model.n
      model.curve = interp1(linspace(0,1,ncurve),model.curve,linspace(0,1,model.n));
    end
    %model.curve = model.curve/max(model.curve);
  otherwise
    error('Unknown shape');
end

if nargin<2 || isempty(nprm)
  nprm = defprm;
end
[nncomp,ncol] = size(nprm);

% Set default group index if needed
if ncol==5
  nprm = [nprm zeros(nncomp,1)];
elseif ncol<5
  error('Incorrect number of columns in input argument ''nprm''.');
end

nprm(:,3:4) = pi * nprm(:,3:4)/180;

%------------------------------------------------------------
% Set the default modulation parameters to empty indicating no
% modulator; set default filename, material filename.
mprm  = [];
nmcomp = 0;

% If modulator parameters are given as input, set mprm to these values
if ~isempty(modpar)
  mprm = modpar{1};
  % Set default values to modulator parameters as needed
  [nmcomp,ncol] = size(mprm);
  if ncol<5
    defprm = ones(nmcomp,1)*[1 0 0 0];
    mprm(:,ncol+1:5) = defprm(:,ncol:4);
    clear defprm
  end
  mprm(:,3:4) = pi * mprm(:,3:4)/180;
end

%------------------------------------------------------------
% Vertices
if model.flags.new_model
  model = objSetCoords(model);
end

switch model.shape
  case 'sphere'
    % For the 2D noise sample, reshape the coordinate vectors to temp 2D matrices
    Theta = reshape(model.Theta,[model.n model.m])';
    Phi = reshape(model.Phi,[model.n model.m])';
    R = reshape(model.R,[model.n model.m])';
    R = R + objMakeNoiseComponents(nprm,mprm,Theta,Phi,model.flags.use_rms);
    
    % Reshape the radius matrix to a vector again
    R = R'; 
    model.R = R(:);
    model.vertices = objSph2XYZ(model.Theta,model.Phi,model.R);
  case 'plane'
    % For the 2D noise sample, reshape the coordinate vectors to temp 2D matrices
    X = reshape(model.X,[model.n model.m])';
    Y = reshape(model.Y,[model.n model.m])';
    Z = reshape(model.Z,[model.n model.m])';
    Z = Z + objMakeNoiseComponents(nprm,mprm,X,Y,model.flags.use_rms);

    % Reshape Z matrix to a vector again
    Z = Z'; 
    model.Z = Z(:);
    model.vertices = [model.X model.Y model.Z];
  case {'cylinder','revolution','extrusion'}
    Theta = reshape(model.Theta,[model.n model.m])';
    Y = reshape(model.Y,[model.n model.m])';
    R = reshape(model.R,[model.n model.m])';
    R = R + objMakeNoiseComponents(nprm,mprm,Theta,Y,model.flags.use_rms);

    R = R';
    model.R = R(:);

    model.X =  model.R .* cos(model.Theta);
    model.Z = -model.R .* sin(model.Theta);
    model.vertices = [model.X model.Y model.Z];
end
%------------------------------------------------------------
% 

if model.flags.new_model
  ii = 1;
else
  ii = length(model.prm)+1;
end
model.prm(ii).perturbation = 'noise';
model.prm(ii).nprm = nprm;
model.prm(ii).mprm = mprm;
model.prm(ii).nncomp = nncomp;
model.prm(ii).nmcomp = nmcomp;
model.prm(ii).use_rms = model.flags.use_rms;
model.prm(ii).mfilename = mfilename;
if strcmp(model.shape,'torus')
  model.prm(ii).rprm = model.opts.rprm;
end

if model.flags.dosave
  model = objSaveModel(model);
end

if ~nargout
   clear model
end

