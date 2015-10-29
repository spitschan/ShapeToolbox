function model = objMakeBump(shape,prm,varargin)

% OBJMAKEBUMP
% 
% Usage:          objMakeBump(SHAPE)
%                 objMakeBump(SHAPE,PAR,[OPTIONS])
%         MODEL = objMakeBump(...)
%
% Produce a 3D model mesh object of a given shape, perturbed by
% Gaussian bumps or dents, and save it to a file in Wavefront obj-format.  
% Optionally return a structure that holds the model information.
%
% The base shape is defined by the first argument, SHAPE.  The
% parameters for the bumps are defined by PAR.  By default the bump
% locations are chosen at random, but custom locations can also be
% used.  See details below.
% 
% SHAPE:
% ======
%
% Either an existing model returned by one of the objMake*-functions,
% or a string defining a new shape.  If a string, has to be one of
% 'sphere', 'plane', 'cylinder', 'torus', 'revolution', 'extrusion' or
% 'worm'.  See details in the help for objSave.  Example: 
%   objMakeBump('sphere')
%
% PAR:
% ====
%
% Parameters for the Gaussian bumps.  The vector PAR defines the
% number of bumps, their amplitude, and the space constant:
%   PAR = [NBUMPS AMPL SD]
% 
% Amplitude can be negative to produce dents.  Units for the space
% constant are radians for spheres, tori, cylinder, surfaces of
% revolution, and extrusions.
%
% To have different types of bump in the same model, define several
% sets of parameters in the rows of PAR:
%   PAR = [NBUMPS1 AMPL1 SD1
%          NBUMPS2 AMPL2 SD2
%          ...
%          NBUMPSN AMPLN SDN]
%
% OPTIONS:
% ========
%
% All the same options as in objMake plus the ones listed below.  
% See objMake documentation:
%  help objMake;
%
% MINDIST
% Minimum distance between bumps.  A scalar of a vector the length of
% which equals the number of bump types.  Note: The minimum distance
% only applies to bumps of the same type, it is not applied across
% bump types.  Example: objMakeBump('plane',[20 .05 .06],'mindist',.3)
%
% LOCATIONS
% Locations of the bumps in a cell array.  The locations are given as
% X and Y for planes, azimuth and elevation / Theta and Phi for
% spheres and tori, and azimuth and Y for cylinders, surfaces of
% revolution, and extrusions.  The format of the cell array (for
% planes, as this example uses x and y) is: 
%   {{[x1 x2 ...]},{[y1 y2 ...]}} 
% for a single bump type.  For several bump types: 
%   {{[x11 x12 ...],[x21 x22 ...],...},{[y11 y12 ...],[y21 y22 ...],...}}
% Example: place two bumps and two dents diagonally on a plane:
%   objMakeBump('plane',[2 .1 .1; 2 -.1 .1],'locations',...
%               {{[-.5 .5],[-.5 .5]},{[-.5 .5],[.5 -.5]}})
% 
% TODO: MAX
%
% RETURNS:
% ========
% A structure holding all the information about the model.  This
% structure can be given as input to another objMake*-function to
% perturb the shape, or it can be given as input to objSaveModel to
% save it to file (but the saving to file is a default behavior of
% objMake, so unless the option 'save' is set to false, it is not
% necessary to save the model manually).
% 
% EXAMPLES:
% =========
% TODO

% Copyright (C) 2015 Toni Saarela
% 2015-05-31 - ts - first version, based on objMakeSphereBumpy and
%                    others
% 2015-06-01 - ts - does planes, cylinders, and other shapes
% 2015-06-03 - ts - fixed a bug in setting the cutoff parameter
% 2015-06-05 - ts - added option for "caps" for cylinder-type shapes
%                   help
% 2015-06-08 - ts - revolution and extrusion can be combined
% 2015-06-10 - ts - help
% 2015-06-16 - ts - removed setting of default file name
% 2015-09-29 - ts - minor update to help
% 2015-10-02 - ts - minor fixes to help (rcurve, ecurve params)
%                   added option for batch processing
% 2015-10-08 - ts - added support for the 'spinex' and 'spinez' options
% 2015-10-10 - ts - added support for worm shape
% 2015-10-11 - ts - fixes in documentation; added support for torus again
% 2015-10-15 - ts - fixed the updating of the nargin/narg var to work with matlab

% TODO
% - option to add noise to bump amplitudes/sigmas

%------------------------------------------------------------

narg = nargin;

% For batch processing.  If there's only one input arg and it's a cell
% array, it has all the parameters.
if iscell(shape) && narg==1
  % If the only input argument is a cell array of cell arrays, recurse
  % through the cells. Each cell holds parameters for one shape.
  if all(cellfun('iscell',shape))
    if length(shape)>1
      objMakeBump(shape(1:end-1));
    end
    objMakeBump(shape{end});
    return
  end
  % Otherwise, unpack the mandatory input arguments from the beginning
  % of the array and assign the rest to varargin:
  narg = length(shape);
  if narg>2
    varargin = shape(3:end);
  end
  if narg>1
    prm = shape{2};
  end
  shape = shape{1};
end

% Set up the model structure
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
  case {'cylinder','worm'}
    defprm = [20 .1 pi/12];
    model = objInterpCurves(model);
  case 'torus'
    defprm = [20 .1 pi/12];
    % defprm = [];
    % clear model
    % fprintf('Gaussian bumps not yet implemented for torus.\n');
    % return
  case 'revolution'
    defprm = [20 .1 pi/12];
    model = objInterpCurves(model);
    %model.curve = model.curve/max(model.curve);
  case 'extrusion'
    defprm = [20 .1 pi/12];
    model = objInterpCurves(model);
    %model.curve = model.curve/max(model.curve);
  otherwise
    error('Unknown shape');
end

if narg<2 || isempty(prm)
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
if strcmp(model.shape,'torus')
  model.prm(ii).rprm = model.opts.rprm;
end

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

