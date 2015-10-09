function model = objMake(shape,varargin)

% OBJMAKE
%
% Usage:  MODEL = OBJMAKE(SHAPE) 
%         MODEL = OBJMAKE(SHAPE,[OPTIONS])
%                 OBJMAKE(SHAPE,[OPTIONS])
%
% Produce a 3D model mesh object of a given shape and optionally save 
% it to a file in Wavefront obj-format and/or return a structure that
% holds the model information.
% 
% SHAPE:
% ======
%
% One of 'sphere', 'plane', 'cylinder', 'torus', 'revolution', and
% 'extrusion'.  Example: m = objMake('sphere')
%
% The shapes use a coordinate system where the y-direction is "up" and
% the x-z plane is the reference plane.
% 
% Some notes and default values for the shapes (some can be changed
% with the optional input arguments, see below):
%
% SPHERE: A unit sphere (radius 1), default mesh size 128x256.
%
% PLANE: A plane with a width and height of 1, lying on the x-y plane,
% centered on the origin.  Default mesh size 256x256.  Obviously a
% size of 2x2 would be enough; the larger size is used so that fine
% modulations can later be added to the shape if needed.
%
% CYLINDER: A cylinder with radius 1 and height of 2*pi.  Default mesh
% size 256x256.
%
% TORUS: A torus with ring radius of 1 and tube radius of 0.4.
% Default mesh size 256x256.
%
% REVOLUTION: A surface of revolution based on a user-defined profile,
% height 2*pi.  See the option 'rcurve' below on how to define the
% profile.  Default mesh size 256x256.
%
% EXTRUSION: An extrusion based on a user-defined cross-sectional
% profile, height 2*pi.  See option 'ecurve' below on how to define the
% profile.  Default mesh size 256x256.
%
% NOTE: By default, the model IS NOT SAVED TO A FILE.  To save, you
% have to set the option 'FILENAME' or 'SAVE' (see below).
% 
% 
% OPTIONS:
% ========
%
% With the exception of the filename, all options are gives as
% name-value pairs.  All possible options are listed below.
%
% FILENAME
% A single string giving the name of the file in which to save the
% model.  Setting the filename forces the option 'save' (see below) to
% true. Example:
%  objMake(...,'mymodel.obj',...)
%
% SAVE
% Boolean, toggle saving the model to a file.  Default is false, the
% model is not saved.  Setting the filename (see above) sets this
% option to true.  If filename is not set and the option 'save' is
% true, a default filename is used; the default filename is the name
% of the base shape appended with .obj: 'sphere.obj', 'plane.obj',
% 'torus.obj', 'cylinder.obj', 'revolution.obj', and 'extrusion.obj'.
% Example:
%  objMake('cylinder','save',true);
%
% NPOINTS
% Resolution of the model mesh (number of vertices).  Given as a
% two-vector for the number of vertices in the "vertical" (elevation
% or y, depending on the shape) and "horizontal" (azimuth or x)
% directions.  Example: 
%  objMake(...,'npoints',[64 64],...)
% 
% MATERIAL
% Name of the material library (.mtl) file and the name of the
% material for the model.  Given as a cell array of length two.  The
% elements of the cell array are two strings, the first one for the
% material library file and the second for the material name.  This
% option forces the option uvcoords (see below) to true.  Example:
%  objMake(...,'material',{'matfile.mtl','mymaterial'},...)
%
% Alternatively, you can give the material name only, without the
% material library name:
%  objMake(...,'material','mymaterial',...)
%
% UVCOORDS
% Boolean, toggles the computation of texture (uv) coordinates
% (default is false).  Example: 
%  objMake(...,'uvcoords',true,...)
%
% NORMALS
% Boolean, toggle the computation of vertex normals (default false).
% Turning this on improves the quality of rendering, but note that
% some rendering programs might compute the normals for you, making
% it unnecessary to include them in the file.  Example:
%  objMake(...,'normals',true,...)
%
% TUBE_RADIUS, MINOR_RADIUS
% Sets the radius of the "tube" of a torus.  Default 0.4 (the radius
% of the ring, or the distance from the origin to the center of the
% tube is 1).  Example: 
%  objMake(...,'tube_radius',0.2,...)
%
% RCURVE, ECURVE
% A vector giving the curve to use with shapes 'revolution' ('rcurve')
% and 'extrusion' ('ecurve').  When the shape is 'revolution', a
% surface of revolution is produced by revolving the curve about the
% y-axis.  When the shape is 'extrusion', the curve gives the
% cross-sectional profile of the object.  This profile is translated
% along the y-axis to produce a 3D shape.  Example: 
%  profile = .1 + ((-64:63)/64).^2;
%  objMake('revolution','rcurve',profile)
%  objMake('extrusion','ecurve',profile)
%
% You can also combine the two curve types by giving both options.  In
% this case, the 'rcurve' is revolved around the y-axis along a path
% (or radial profile) defined by 'ecurve'.  If the length of the
% vector 'rcurve' or 'ecurve' does not match the size of the model
% mesh in the corresponding direction, the curve is interpolated.
%
% SPINEX, SPINEZ
% For use with shapes 'cylinder', 'revolution', and 'extrusion' only.
% A vector giving the coordinates of the midline, or "spine", of the
% shape as a function of the y-coordinate.  The following example
% produces a sinusoidal curve in the x-direction:
%  y = linspace(0,4*pi,256);
%  x = sin(y);
%  objMake('cylinder','spinex',x,'save',true);
% And adding a cosinusoid to the z-coordinate produces a corkscrew:
%  z = cos(y);
%  objMake('cylinder','spinex',x,'spinez',z,'save',true);
%
% If the length of the vector 'spinex' or 'spinez' does not match the
% size of the model mesh y-direction, the curve is interpolated.
%
% CAPS
% Boolean.  Set this to true to put "caps" at the end of cylinders, 
% surfaces of revolution, and extrusions.  Default false.  Example:
%  objMake('cylinder','caps',true);
%
% WIDTH, HEIGHT
% Scalars, width and height of the model.  Option 'width' can only be
% used with shape 'plane' to set the plane width.  'height' can be
% used with 'plane', 'cylinder', 'revolution', and 'extrusion'.
% Examples:
%  objMake('plane','width',2,'height',0.5);
%  objMake('cylinder','height',1.35);
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
% BATCH PROCESSING:
% =================
% For creating several objects with a single function call, there is
% an option to provide all input arguments to objMake as a single cell
% array.  For example, the following two calls are equivalent:
%  objMake('cylinder','npoints',[64 64],'uvcoords',true,'cyl1.obj')
%  objMake({'cylinder','npoints',[64 64],'uvcoords',true,'cyl1.obj'})
% 
% To create several objects with one call, define several sets of
% parameters in the cells of the only input argument.  In this case,
% then, the only input argument is a cell array of cell arrays:
%  prm = {
%         {'cylinder','npoints',[64 64],'uvcoords',true,'cyl1.obj'},
%         {'plane','npoints',[64 64],'uvcoords',true,'pla1.obj'}
%        };
%  objMake(prm);
% 
% NOTE:
% =====
% Note that this function does not do anything that the any other
% objMake*-function would not do.  You can always call, say,
% objMakeSine and set the amplitude of modulation to zero to get the
% same unperturbed shape as this function would produce.  This
% function might be useful if you just want to produce a
% surface-of-revolution or an extrusion object.  The other, simple
% basic shapes (sphere, cylinder...) can be usually produced with a
% single command in a graphics/rendering program.

% Copyright (C) 2015 Toni Saarela
% 2015-06-01 - ts - first version, based on objMakeSine
% 2015-06-02 - ts - wrote help
% 2015-06-05 - ts - added option for "caps" for cylinder-type shapes
% 2015-06-08 - ts - revolution and extrusion can be combined
% 2015-06-10 - ts - help
% 2015-06-16 - ts - removed setting of default file name
% 2015-10-02 - ts - minor fixes to help (rcurve, ecurve params)
%                   added option for batch processing
% 2015-10-04 - ts - updated documentation
% 2015-10-08 - ts - added the 'spinex' and 'spinez' options

%------------------------------------------------------------

% For batch processing.  If there's only one input arg and it's a cell
% array, it has all the parameters.
if iscell(shape) && nargin==1
  % If the only input argument is a cell array of cell arrays, recurse
  % through the cells. Each cell holds parameters for one shape.
  if all(cellfun('iscell',shape))
    if length(shape)>1
      objMake(shape(1:end-1));
    end
    objMake(shape{end});
    return
  end
  % Otherwise, unpack the mandatory input arguments from the beginning
  % of the array and assign the rest to varargin:
  nargin = length(shape);
  if nargin>1
    varargin = shape(2:end);
  end
  shape = shape{1};
end

% Set up the model structure
if ischar(shape)
  shape = lower(shape);
  model = objDefaultStruct(shape);
 else
   error('Argument ''shape'' has to be a string.');
% elseif isstruct(shape)
%   model = shape;
%   model = objDefaultStruct(shape,true);
%   model.flags.new_model = false;
% else
%   error('Argument ''shape'' has to be a string or a model structure.');
end
clear shape

% Check and parse optional input arguments
[tmp,par] = parseparams(varargin);
model = objParseArgs(model,par);

switch model.shape
  case {'sphere','plane','torus'}
  case {'cylinder','revolution','extrusion'}
    model = objInterpCurves(model);
    %model.curve = model.curve/max(model.curve);
  otherwise
    error('Unknown shape');
end

%-------------------------------------------------------------
% Vertices
if model.flags.new_model
  model = objSetCoords(model);
end

switch model.shape
  case 'sphere'
    model.vertices = objSph2XYZ(model.Theta,model.Phi,model.R);
  case 'plane'
    model.vertices = [model.X model.Y model.Z];
  case {'cylinder','revolution','extrusion'}
    if model.flags.caps
      model = objAddCaps(model);
    end
    model.X =  model.R .* cos(model.Theta);
    model.Z = -model.R .* sin(model.Theta);
    model.X = model.X + model.spine.X;
    model.Z = model.Z + model.spine.Z;
    model.vertices = [model.X model.Y model.Z];
  case 'torus'
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
model.prm(ii).perturbation = 'none';
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

