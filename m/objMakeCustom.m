function model = objMakeCustom(shape,f,prm,varargin)

% OBJMAKECUSTOM
% 
% Usage:          objMakeCustom(SHAPE)
%                 objMakeCustom(SHAPE,FUNC,PAR,[OPTIONS])
%                 objMakeCustom(SHAPE,IMG,AMPL,[OPTIONS])
%                 objMakeCustom(SHAPE,MAT,AMPL,[OPTIONS])
%         model = objMakeCustom(...)
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
% 'sphere', 'plane', 'cylinder', 'torus', 'revolution', and
% 'extrusion'.  Example: objMakeCustom('sphere',...)
%
% If an existing model structure is given as input, new modulation is
% added to the existing model.  Example:
%   m = objMakeSine('cylinder');
%   objMakeCustom(m,...);
%
% The shapes use a coordinate system where the y-direction is "up" and
% the x-z plane is the reference plane.
% 
% Some notes and default values for the shapes (some can be changed
% with the optional input arguments, see below):
%
% SPHERE: A unit sphere (radius 1), default mesh size 128x256.  Saved
% to 'spherecustom.obj'.
%
% PLANE: A plane with a width and height of 1, lying on the x-y plane,
% centered on the origin.  Default mesh size 256x256.  Obviously a
% size of 2x2 would be enough; the larger size is used so that fine
% modulations can later be added to the shape if needed.  Saved in
% 'planecustom.obj'.
%
% CYLINDER: A cylinder with radius 1 and height of 2*pi.  Default mesh
% size 256x256.  Saved in 'cylindercustom.obj'.
%
% TORUS: A torus with ring radius of 1 and tube radius of 0.4.
% Default mesh size 256x256, saved in 'toruscustom.obj'.
%
% REVOLUTION: A surface of revolution based on a user-defined profile,
% height 2*pi.  See the option 'curve' below on how to define the
% profile.  Default mesh size 256x256, saved in 'revolutioncustom.obj'.
%
% EXTRUSION: An extrusion based on a user-defined cross-sectional
% profile, height 2*pi.  See option 'curve' below on how to define the
% profile.  Default mesh size 256x256, saved in 'extrusioncustom.obj'.
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
% With the exception of the filename, all options are gives as
% name-value pairs.  All possible options are listed below.
%
% FILENAME
% A single string giving the name of the file in which to
% save the model.  Example: objMakeCustom(...,'mymodel.obj',...)
%
% NPOINTS
% Resolution of the model mesh (number of vertices).  Given as a
% two-vector for the number of vertices in the "vertical" (elevation
% or y, depending on the shape) and "horizontal" (azimuth or x)
% directions.  Example: objMakeCustom(...,'npoints',[64 64],...)
% 
% MATERIAL
% Name of the material library (.mtl) file and the name of the
% material for the model.  Given as a cell array of length two.  The
% elements of the cell array are two strings, the first one for the
% material library file and the second for the material name.  This
% option forces the option uvcoords (see below) to true.  Example:
% objMakeCustom(...,'material',{'matfile.mtl','mymaterial'},...)
%
% UVCOORDS
% Boolean, toggles the computation of texture (uv) coordinates
% (default is false).  Example: objMakeCustom(...,'uvcoords',true,...)
%
% NORMALS
% Boolean, toggle the computation of vertex normals (default false).
% Turning this on improves the quality of rendering, but note that
% some rendering programs might compute the normals for you, making
% it unnecessary to include them in the file.  Example:
% objMakeCustom(...,'normals',true,...)
%
% SAVE
% Boolean, toggle saving the model to a file.  Default is true, the
% model is saved.  You might want to set this to false if you just
% want to make the model structure and modify it with another
% objMake*-function or with objBlend.  Example: 
% m = objMakeCustom(...,'save',false,...)
%
% TUBE_RADIUS, MINOR_RADIUS
% Sets the radius of the "tube" of a torus.  Default 0.4 (the radius
% of the ring, or the distance from the origin to the center of the
% tube is 1).  Example: objMakeCustom(...,'tube_radius',0.2,...)
%
% CURVE
% A vector giving the curve to use with shapes 'revolution' and
% 'extrusion'.  When the shape is 'revolution', a surface of
% revolution is produced by revolving the curve about the y-axis.
% When the shape is 'extrusion', the curve gives the cross-sectional
% profile of the object.  This profile is translated along the y-axis
% to produce a 3D shape.  Example: 
%  profile = .1 + ((-64:63)/64).^2;
%  objMakeCustom('revolution',...,'curve',profile)
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
%  objMakeCustom('plane',...,'width',2,'height',0.5);
%  objMakeCustom('cylinder',...,'height',1.35);
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

switch model.shape
  case {'sphere','plane','cylinder','torus'}
  case 'revolution'
    model = objInterpCurves(model);
    %model.curve = model.curve/max(model.curve);
  case 'extrusion'
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

