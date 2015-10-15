function model = objMakeCustom(shape,f,prm,varargin)

% OBJMAKECUSTOM
% 
% Usage:          objMakeCustom(SHAPE)
%                 objMakeCustom(SHAPE,FUNC,PAR,[OPTIONS])
%                 objMakeCustom(SHAPE,IMG,AMPL,[OPTIONS])
%                 objMakeCustom(SHAPE,MAT,AMPL,[OPTIONS])
%         MODEL = objMakeCustom(...)
%
% Produce a 3D model mesh object of a given shape, perturbed by
% custom modulation (alternatives explained below), and save it to a
% file in Wavefront obj-format.  Optionally return a structure that
% holds the model information.
%
% The base shape is defined by the first argument, SHAPE.  The base
% shape is perturbed by using either an image or a matrix as a height
% or a bump map, or by providing a handle to a function that
% determines the perturbation.  Explained in more detail below.
% 
% SHAPE:
% ======
%
% Either an existing model returned by one of the objMake*-functions,
% or a string defining a new shape.  If a string, has to be one of
% 'sphere', 'plane', 'cylinder', 'torus', 'revolution', 'extrusion',
% or 'worm'.  See details in the help for objSave.  Example: 
%   objMakeCustom('sphere',...)
%
% PERTURBATION BY USER-DEFINED FUNCTION
% =====================================
% A user-defined function can be used to determine the perturbation of
% the base shape.  After the shape, provide a function handle and a
% parameter vector:
%   objMakeCustom(shape,$func,par,...)
%
% The function has to accept a vector or matrix of distance values as
% its first input argument, and a vector of parameters as a second
% input argument.  That is, the function accepts calls such as:
%   x = func(d,prm)
% where d is a vector or a matrix, par is a parameter vector, and x is
% an output the same size as d.  The values in x describe the
% perturbation at distance d from a center point.
%
% The parameter vector par has the following format:
%   [NLOCS CUTOFF PAR1 PAR2 ... ]
% where NLOCS is the number of locations at which the function will be
% applied, CUTOFF is the cutoff distance at which the perturbation
% will be zero, and PAR1... are additional parameter that are
% forwarded to the function (as its second input argument).
%
% To apply the same function several times with different parameters,
% define the parameters in rows:
%   [NLOCS1 CUTOFF1 PAR11 PAR12 ... 
%    ...
%    NLOCSN CUTOFFN PARN1 PARN2 ...] 
%
% IMAGE OR MATRIX AS A HEIGHT/BUMP MAP
% ====================================
% The perturbation value can also be read from an image or a matrix.
% In this case, the second input argument gives the name of the image
% file or the name of the matrix, and the third argument gives the
% amplitude:
%   objMakeCustom(shape,'imgfilename.ext',amplitude,...)
%   objMakeCustom(shape,mymatrix,amplitude,...)
% 
% The pixel values from an image are first scaled to 0-1 and them
% multiplied by the amplitude.  RGB images are averaged across
% channels first.  An input matrix is first scaled so that the maximum
% absolute value is 1, then multiplied by the amplitude.
% 
% OPTIONS:
% ========
%
% All the same options as in objMake plus the ones listed below.  
% See objMake documentation:
%  help objMake;
%
% MINDIST
% Minimum distance between the locations at which the user-defined
% perturbation function is applied.  A scalar of a vector the length of
% which equals the number of parameter sets with which the function is
% called (number of rows in PAR).  Note: The minimum distance
% only applies to perturbations of the same type, it is not applied across
% perturbations types.  Example: 
%   objMakeCustom('plane',@func,...,'mindist',.3)
%
% LOCATIONS
% Locations at which the user-defined perturbation function is
% applied, in a cell array.  The locations are given as
% X and Y for planes, azimuth and elevation / Theta and Phi for
% spheres and tori, and azimuth and Y for cylinders, surfaces of
% revolution, and extrusions.  The format of the cell array (for
% planes, as this example uses x and y) is: 
%   {{[x1 x2 ...]},{[y1 y2 ...]}} 
% for a single perturbation type.  For several types: 
%   {{[x11 x12 ...],[x21 x22 ...],...},{[y11 y12 ...],[y21 y22 ...],...}}
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
% 2015-06-01 - ts - first version, based on objMakeBumpy and
%                    others
% 2015-06-05 - ts - added option for "caps" for cylinder-type shapes
%                   help
% 2015-06-08 - ts - revolution and extrusion can be combined
% 2015-06-10 - ts - help
% 2015-06-16 - ts - removed setting of default file name
% 2015-09-29 - ts - minor update to help
% 2015-10-02 - ts - minor fixes to help (rcurve, ecurve params)
%                   added option for batch processing
% 2015-10-08 - ts - added support for the 'spinex' and 'spinez' options
%                   bug fixes and improvements
% 2015-10-09 - ts - added/fixed bump map support for planes,
%                    cylinders, tori
% 2015-10-10 - ts - added support for worm shape
% 2015-10-11 - ts - fixes in help
% 2015-10-15 - ts - fixed the updating of the nargin/narg var to work with matlab
%                   help refers to objMake instead of repeating
%                   added option for torus major radius modulation
%                    (was there a reason it was not here?)

% TODO

%------------------------------------------------------------

narg = nargin;

% For batch processing.  If there's only one input arg and it's a cell
% array, it has all the parameters.
if iscell(shape) && narg==1
  % If the only input argument is a cell array of cell arrays, recurse
  % through the cells. Each cell holds parameters for one shape.
  if all(cellfun('iscell',shape))
    if length(shape)>1
      objMakeCustom(shape(1:end-1));
    end
    objMakeCustom(shape{end});
    return
  end
  % Otherwise, unpack the mandatory input arguments from the beginning
  % of the array and assign the rest to varargin:
  narg = length(shape);
  if narg>3
    varargin = shape(4:end);
  end
  if narg>2
    prm = shape{3};
  end
  if narg>1
    f = shape{2};
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

model = objParseCustomParams(model,f,prm);

% Check and parse optional input arguments
[modpar,par] = parseparams(varargin);
model = objParseArgs(model,par);

switch model.shape
  case {'sphere','plane','torus'}
  case {'cylinder','revolution','extrusion','worm'}
    model = objInterpCurves(model);
    %model.curve = model.curve/max(model.curve);
  otherwise
    error('Unknown shape');
end

%------------------------------------------------------------

if model.flags.new_model
  ii = 1;
else
  ii = length(model.prm)+1;
end
model.prm(ii).prm = model.opts.prm;
if ~model.flags.use_map
  model.prm(ii).nbumptypes = model.opts.nbumptypes;
  model.prm(ii).nbumps = model.opts.nbumps;
end

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
  switch model.shape
    case 'sphere'
      model.vertices = objSph2XYZ(model.Theta,model.Phi,model.R);
    case 'plane'
      model.vertices = [model.X model.Y model.Z];
    case 'torus'
      if ~isempty(model.opts.rprm)
        rprm = model.opts.rprm;
        for ii = 1:size(rprm,1)
          model.R = model.R + rprm(ii,2) * sin(rprm(ii,1)*model.Theta + rprm(ii,3));
        end
      end
      model.vertices = objSph2XYZ(model.Theta,model.Phi,model.r,model.R);
    case {'cylinder','revolution','extrusion'}
      model.X =  model.R .* cos(model.Theta);
      model.Z = -model.R .* sin(model.Theta);
      model.X = model.X + model.spine.X;
      model.Z = model.Z + model.spine.Z;
      model.vertices = [model.X model.Y model.Z];
    case 'worm'
      model = objMakeWorm(model);
  end
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
model.prm(ii).perturbation = 'custom';
model.prm(ii).mindist = model.opts.mindist;
model.prm(ii).mfilename = mfilename;
model.prm(ii).locations = model.opts.locations;
model.prm(ii).use_map = model.flags.use_map;
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

