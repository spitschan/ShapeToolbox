function model = objMakeSine(shape,cprm,varargin)

% OBJMAKESINE
%
% Usage:          objMakeSine(SHAPE) 
%                 objMakeSine(SHAPE,CPAR,[OPTIONS])
%                 objMakeSine(SHAPE,CPAR,MPAR,[OPTIONS]) 
%         MODEL = objMakeSine(...)

% Copyright (C) 2015 Toni Saarela
% 2015-05-31 - ts - first version, based on objmakeSphere and others

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
model.filename = [model.shape,'.obj'];

% Check and parse optional input arguments
[modpar,par] = parseparams(varargin);
model = objParseArgs(model,par);

%------------------------------------------------------------
% Carrier parameters. Set default frequency, amplitude, phase,
% "orientation" and component group id

switch model.shape
  case 'sphere'
    defprm = [8 .1 0 0 0];
  case 'plane'
    defprm = [8 .05 0 0 0];
  case 'cylinder'
    defprm = [8 .1 0 0 0];
  case 'torus'
    defprm = [8 .05 0 0 0];
  case 'revolution'
    defprm = [8 .1 0 0 0];
    ncurve = length(model.curve);
    if ncurve~=model.m
      model.curve = interp1(linspace(0,1,ncurve),model.curve,linspace(0,1,model.m));
    end
    %model.curve = model.curve/max(model.curve);
  case 'extrusion'
    defprm = [8 .1 0 0 0];
    ncurve = length(model.curve);
    if ncurve~=model.n
      model.curve = interp1(linspace(0,1,ncurve),model.curve,linspace(0,1,model.n));
    end
    %model.curve = model.curve/max(model.curve);
  otherwise
    error('Unknown shape');
end

if nargin<2 || isempty(cprm)
  cprm = defprm;
end
[nccomp,ncol] = size(cprm);

% Fill in default carrier parameters if needed
if ncol<5
  defprm = ones(nccomp,1)*defprm;
  cprm(:,ncol+1:5) = defprm(:,ncol+1:5);
end
clear defprm

if strcmp(model.shape,'plane')
  cprm(:,1) = cprm(:,1)*pi;
end
cprm(:,3:4) = pi * cprm(:,3:4)/180;

%------------------------------------------------------------
% Set the default modulation parameters to empty indicating no
% modulator
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
  if strcmp(model.shape,'plane')
    mprm(:,1) = mprm(:,1)*pi;
  end
  mprm(:,3:4) = pi * mprm(:,3:4)/180;
end

%-------------------------------------------------------------
% Vertices
if model.flags.new_model
  model = objSetCoords(model);
end

switch model.shape
  case 'sphere'
    model.R = model.R + objMakeSineComponents(cprm,mprm,model.Theta,model.Phi);
    model.vertices = objSph2XYZ(model.Theta,model.Phi,model.R);
  case 'plane'
    model.Z = model.Z + objMakeSineComponents(cprm,mprm,model.X,model.Y);
    model.vertices = [model.X model.Y model.Z];
  case {'cylinder','revolution','extrusion'}
    model.R = model.R + objMakeSineComponents(cprm,mprm,model.Theta,model.Y);
    model.X =  model.R .* cos(model.Theta);
    model.Z = -model.R .* sin(model.Theta);
    model.vertices = [model.X model.Y model.Z];
  case 'torus'
    if ~isempty(model.opts.rprm)
      rprm = model.opts.rprm;
      for ii = 1:size(rprm,1)
        model.R = model.R + rprm(ii,2) * sin(rprm(ii,1)*model.Theta + rprm(ii,3));
      end
    end
    if ~isempty(cprm)
      model.r = model.r + objMakeSineComponents(cprm,mprm,model.Theta,model.Phi);
    end
    model.vertices = objSph2XYZ(model.Theta,model.Phi,model.r,model.R);
  otherwise
    error('Unknown shape.');
end

%-------------------------------------------------------------
% 

if model.flags.new_model
  ii = 1;
else
  ii = length(model.prm)+1;
end
model.prm(ii).perturbation = 'sine';
model.prm(ii).cprm = cprm;
model.prm(ii).mprm = mprm;
model.prm(ii).nccomp = nccomp;
model.prm(ii).nmcomp = nmcomp;
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

