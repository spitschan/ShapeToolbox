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
% 'sphere', 'plane', 'cylinder', 'torus', 'revolution', and
% 'extrusion'.  Example: objMakeBump('sphere')
%
% If an existing model structure is given as input, new modulation is
% added to the existing model.  Example:
%   m = objMakeSine('cylinder');
%   objMakeBump(m);
%
% The shapes use a coordinate system where the y-direction is "up" and
% the x-z plane is the reference plane.
% 
% Some notes and default values for the shapes (some can be changed
% with the optional input arguments, see below):
%
% SPHERE: A unit sphere (radius 1), default mesh size 128x256.  Saved
% to 'spherebumpy.obj'.
%
% PLANE: A plane with a width and height of 1, lying on the x-y plane,
% centered on the origin.  Default mesh size 256x256.  Obviously a
% size of 2x2 would be enough; the larger size is used so that fine
% modulations can later be added to the shape if needed.  Saved in
% 'planebumpy.obj'.
%
% CYLINDER: A cylinder with radius 1 and height of 2*pi.  Default mesh
% size 256x256.  Saved in 'cylinderbumpy.obj'.
%
% TORUS: A torus with ring radius of 1 and tube radius of 0.4.
% Default mesh size 256x256, saved in 'torusbumpy.obj'.
%
% REVOLUTION: A surface of revolution based on a user-defined profile,
% height 2*pi.  See the option 'rcurve' below on how to define the
% profile.  Default mesh size 256x256, saved in 'revolutionbumpy.obj'.
%
% EXTRUSION: An extrusion based on a user-defined cross-sectional
% profile, height 2*pi.  See option 'ecurve' below on how to define the
% profile.  Default mesh size 256x256, saved in 'extrusionbumpy.obj'.
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
% With the exception of the filename, all options are gives as
% name-value pairs.  All possible options are listed below.
%
% FILENAME
% A single string giving the name of the file in which to
% save the model.  Example: objMakeBump(...,'mymodel.obj',...)
%
% NPOINTS
% Resolution of the model mesh (number of vertices).  Given as a
% two-vector for the number of vertices in the "vertical" (elevation
% or y, depending on the shape) and "horizontal" (azimuth or x)
% directions.  Example: objMakeBump(...,'npoints',[64 64],...)
% 
% MATERIAL
% Name of the material library (.mtl) file and the name of the
% material for the model.  Given as a cell array of length two.  The
% elements of the cell array are two strings, the first one for the
% material library file and the second for the material name.  This
% option forces the option uvcoords (see below) to true.  Example:
% objMakeBump(...,'material',{'matfile.mtl','mymaterial'},...)
%
% UVCOORDS
% Boolean, toggles the computation of texture (uv) coordinates
% (default is false).  Example: objMakeBump(...,'uvcoords',true,...)
%
% NORMALS
% Boolean, toggle the computation of vertex normals (default false).
% Turning this on improves the quality of rendering, but note that
% some rendering programs might compute the normals for you, making
% it unnecessary to include them in the file.  Example:
% objMakeBump(...,'normals',true,...)
%
% SAVE
% Boolean, toggle saving the model to a file.  Default is true, the
% model is saved.  You might want to set this to false if you just
% want to make the model structure and modify it with another
% objMake*-function or with objBlend.  Example: 
% m = objMakeBump(...,'save',false,...)
%
% TUBE_RADIUS, MINOR_RADIUS
% Sets the radius of the "tube" of a torus.  Default 0.4 (the radius
% of the ring, or the distance from the origin to the center of the
% tube is 1).  Example: objMakeBump(...,'tube_radius',0.2,...)
%
% RCURVE, ECURVE
% A vector giving the curve to use with shapes 'revolution' ('rcurve')
% and 'extrusion' ('ecurve').  When the shape is 'revolution', a
% surface of revolution is produced by revolving the curve about the
% y-axis.  When the shape is 'extrusion', the curve gives the
% cross-sectional profile of the object.  This profile is translated
% along the y-axis to produce a 3D shape.  Example: 
%  profile = .1 + ((-64:63)/64).^2;
%  objMakeBump('revolution',...,'rcurve',profile)
%  objMakeBump('extrusion',...,'ecurve',profile)
%
% You can also combine the two curve types by giving both options.  In
% this case, the 'rcurve' is revolved around the y-axis along a path
% (or radial profile) defined by 'ecurve'.
%
% CAPS
% Boolean.  Set this to true to put "caps" at the end of cylinders, 
% surfaces of revolution, and extrusions.  Default false.  Example:
%  objMakeSine('cylinder',[],'caps',true);
%
% WIDTH, HEIGHT
% Scalars, width and height of the model.  Option 'width' can only be
% used with shape 'plane' to set the plane width.  'height' can be
% used with 'plane', 'cylinder', 'revolution', and 'extrusion'.
% Examples:
%  objMakeBump('plane',...,'width',2,'height',0.5);
%  objMakeBump('cylinder',...,'height',1.35);
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

% TODO
% - option to add noise to bump amplitudes/sigmas

%------------------------------------------------------------

% For batch processing.  If there's only one input arg and it's a cell
% array, it has all the parameters.
if iscell(shape) && nargin==1
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
  nargin = length(shape);
  if nargin>2
    varargin = shape(3:end);
  end
  if nargin>1
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
  case 'cylinder'
    defprm = [20 .1 pi/12];
    model = objInterpCurves(model);
  case 'torus'
    defprm = [];
    clear model
    fprintf('Gaussian bumps not yet implemented for torus.\n');
    return
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

