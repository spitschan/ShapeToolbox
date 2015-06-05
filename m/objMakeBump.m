function model = objMakeBump(shape,prm,varargin)

% OBJMAKEBUMP
% 
% Usage:          objMakeBump(SHAPE)
%                 objMakeBump(SHAPE,PAR,[OPTIONS])
%         model = objMakeBump(...)
%

% Copyright (C) 2015 Toni Saarela
% 2015-05-31 - ts - first version, based on objMakeSphereBumpy and
%                    others
% 2015-06-01 - ts - does planes, cylinders, and other shapes
% 2015-06-03 - ts - fixed a bug in setting the cutoff parameter
% 2015-06-05 - ts - added option for "caps" for cylinder-type shapes

% TODO
% - option to add noise to bump amplitudes/sigmas

%------------------------------------------------------------

if ischar(shape)
  shape = lower(shape);
  model = objDefaultStruct(shape);
elseif isstruct(shape)
  model = shape;
  model = objDefaultStruct(shape,true);
else
  error('Argument ''shape'' has to be a string or a model structure.');
end
clear shape
model.filename = [model.shape,'bumpy.obj'];

% Check and parse optional input arguments
[modpar,par] = parseparams(varargin);
model = objParseArgs(model,par);

%------------------------------------------------------------
% Bump parameters

switch model.shape
  case 'sphere'
    defprm = [20 .1 pi/12];
  case 'plane'
    defprm = [20 .05 .05];
  case 'cylinder'
    defprm = [20 .1 pi/12];
  case 'torus'
    defprm = [];
    clear model
    fprintf('Gaussian bumps not yet implemented for torus.\n');
    return
  case 'revolution'
    defprm = [20 .1 pi/12];
    ncurve = length(model.curve);
    if ncurve~=model.m
      model.curve = interp1(linspace(0,1,ncurve),model.curve,linspace(0,1,model.m));
    end
    %model.curve = model.curve/max(model.curve);
  case 'extrusion'
    defprm = [20 .1 pi/12];
    ncurve = length(model.curve);
    if ncurve~=model.n
      model.curve = interp1(linspace(0,1,ncurve),model.curve,linspace(0,1,model.n));
    end
    %model.curve = model.curve/max(model.curve);
  otherwise
    error('Unknown shape');
end

if nargin<2 || isempty(prm)
  prm = defprm;
end

[nbumptypes,ncol] = size(prm);

nbumps = sum(prm(:,1));

if model.flags.new_model
  ii = 1;
else
  ii = length(model.prm)+1;
end
% This is too hacky but whatever.  Make a temporary parameter vector
% that has the cutoff as the second argument.  This way we can use
% objPlaceBumps from both objMakeBump and objMakeCustom.
model.prm(ii).prm = [prm(:,1) 3.5*ones(size(prm,1),1) prm(:,2:end)];
model.prm(ii).nbumptypes = nbumptypes;
model.prm(ii).nbumps = nbumps;

% Create a function for making the Gaussian profile
model.opts.f = @(d,prm) prm(1)*exp(-d.^2/(2*prm(2)^2));

%------------------------------------------------------------
% Vertices
if model.flags.new_model
  model = objSetCoords(model);
elseif ~isempty(strmatch(model.shape,{'cylinder','revolution','extrusion'}))
  if model.flags.oldcaps
     model = objRemCaps(model);
  end
end
model = objPlaceBumps(model);
if ~isempty(strmatch(model.shape,{'cylinder','revolution','extrusion'}))
  if model.flags.caps
     model = objAddCaps(model);
  end
end

% Set the parameter vector back to what it was.
model.prm(ii).prm = prm;

%------------------------------------------------------------
% The field prm can be made an array.  If the structure model is
% passed to another objMakeModel*-function, that function will add
% its parameters to that array.
ii = length(model.prm);
model.prm(ii).perturbation = 'bump';
model.prm(ii).mindist = model.opts.mindist;
model.prm(ii).mfilename = mfilename;
model.prm(ii).locations = model.opts.locations;
%if strcmp(model.shape,'torus')
%  model.prm(ii).rprm = model.opts.rprm;
%end

if model.flags.dosave
  model = objSaveModel(model);
end

if ~nargout
   clear model
end

%---------------------------------------------------------
% Functions...

function theta = wrapAnglePi(theta)

% WRAPANGLEPI
%
% Usage: theta = wrapAnglePi(theta)

% Toni Saarela, 2010
% 2010-xx-xx - ts - first version

theta = rem(theta,2*pi);
theta(theta>pi) = -2*pi+theta(theta>pi);
theta(theta<-pi) = 2*pi+theta(theta<-pi);
%theta(X==0 & Y==0) = 0;

