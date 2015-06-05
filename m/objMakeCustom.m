function model = objMakeCustom(shape,f,prm,varargin)

% OBJMAKECUSTOM
% 
% Usage:          objMakeCustom(SHAPE)
%                 objMakeCustom(SHAPE,FUNC,PAR,[OPTIONS])
%                 objMakeCustom(SHAPE,IMG,AMPL,[OPTIONS])
%                 objMakeCustom(SHAPE,MAT,AMPL,[OPTIONS])
%         model = objMakeCustom(...)
%

% Copyright (C) 2015 Toni Saarela
% 2015-06-01 - ts - first version, based on objMakeBumpy and
%                    others
% 2015-06-05 - ts - added option for "caps" for cylinder-type shapes

% TODO

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
model.filename = [model.shape,'custom.obj'];

model = objParseCustomParams(model,f,prm);

% Check and parse optional input arguments
[modpar,par] = parseparams(varargin);
model = objParseArgs(model,par);

%------------------------------------------------------------

if model.flags.new_model
  ii = 1;
else
  ii = length(model.prm)+1;
end
model.prm(ii).prm = model.opts.prm;
model.prm(ii).nbumptypes = model.opts.nbumptypes;
model.prm(ii).nbumps = model.opts.nbumps;

%------------------------------------------------------------
% Vertices
if model.flags.new_model
  model = objSetCoords(model);
elseif ~isempty(strmatch(model.shape,{'cylinder','revolution','extrusion'}))
  if model.flags.oldcaps
     model = objRemCaps(model);
  end
end

if ~model.flags.use_map
  model = objPlaceBumps(model);
else
  model = objMakeBumpMap(model);
end

if ~isempty(strmatch(model.shape,{'cylinder','revolution','extrusion'}))
  if model.flags.caps
     model = objAddCaps(model);
  end
end

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

