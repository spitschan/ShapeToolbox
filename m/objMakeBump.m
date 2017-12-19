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
% 'sphere', 'plane', 'disk', 'cylinder', 'torus', 'revolution',
% 'extrusion' or 'worm'.  See details in the help for objMakePlain.
% Example: 
%   objMakeBump('sphere')
%
% PAR:
% ====
%
% Parameters for the Gaussian bumps.  The vector PAR defines the
% number of bumps, their amplitude, and the space constant:
%   PAR = [NBUMPS SD AMPL]
% 
% Amplitude can be negative to produce dents.  Units for the space
% constant are radians for spheres, tori, cylinder, surfaces of
% revolution, and extrusions.
%
% To have different types of bump in the same model, define several
% sets of parameters in the rows of PAR:
%   PAR = [NBUMPS1 SD1 AMPL1
%          NBUMPS2 SD2 AMPL2
%          ...
%          NBUMPSN SDN AMPLN]
%
% OPTIONS:
% ========
%
% All the same options as in objMakePlain plus the ones listed below.
% See objMakePlain documentation: 
%   help objMakePlain;
%
% MINDIST
% Minimum distance between bumps.  A scalar of a vector the length of
% which equals the number of bump types.  Note: The minimum distance
% only applies to bumps of the same type, it is not applied across
% bump types.  Example: 
%   objMakeBump('plane',[20 .05 .06],'mindist',.3)
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
%   objMakeBump('plane',[2 .1 .1; 2 .1 -.1],'locations',...
%               {{[-.25 .25],[-.25 .25]},{[-.25 .25],[.25 -.25]}})
% 
% MAX
% Usually you add the new bump values to the existing
% perturbation. When given the option 'max', the new perturbation
% value is the maximum of the existing perturbation and the new
% one. Example:
%   objMakeBump('plane',...,'max',...)
%
% RETURNS:
% ========
%
% A structure holding all the information about the model.  This
% structure can be given as input to another objMake*-function to
% perturb the shape, or it can be given as input to objSave to save it
% to file (although, unless the option 'save' is set to false when
% calling an objMake*-function, it is not necessary to save the model
% manually).
% 
% EXAMPLES:
% =========
% TODO

% Copyright (C) 2015, 2016, 2017 Toni Saarela
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
% 2016-01-21 - ts - calls objMakeVertices
%                   added (finally) torus major radius modulation
%                   added disk shape
% 2016-02-19 - ts - function handle moved from model.opts.f 
%                   to model.prm(model.idx).f
% 2016-03-26 - ts - is now a wrapper for the new objMake
% 2016-04-08 - ts - re-enabled batch mode
% 2017-05-26 - ts - help
% 2017-12-05 - ts - fix to help

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

if nargin>1 && ~isempty(prm)
  varargin = {'par',prm,varargin{:}};
end

model = objMake(shape,'bump',varargin{:});

if ~nargin
  clear model
end

