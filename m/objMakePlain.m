function model = objMakePlain(shape,varargin)

% OBJMAKEPLAIN
%
% Usage:  MODEL = OBJMAKEPLAIN(SHAPE) 
%         MODEL = OBJMAKEPLAIN(SHAPE,[OPTIONS])
%                 OBJMAKEPLAIN(SHAPE,[OPTIONS])
%
% Produce a 3D model mesh object of a given shape and optionally save 
% it to a file in Wavefront obj-format and/or return a structure that
% holds the model information.  The model can be quickly previewed
% with function objShow().
% 
% SHAPE:
% ======
%
% One of 'sphere', 'plane', 'disk', 'cylinder', 'torus', 'revolution', 
% 'extrusion', and 'worm'.  Example: 
%   m = objMakePlain('sphere')
%
% The shapes use a coordinate system where the y-direction is "up" and
% the x-z plane is the reference plane.
% 
% Some notes and default values for the shapes (some can be changed
% with the optional input arguments, see further below):
%
% SPHERE: A unit sphere (radius 1), default mesh size 64x128.
%
% PLANE: A plane with a width and height of 1, lying on the x-y plane,
% centered on the origin.  Default mesh size 128x128.
%
% DISK: A circular disk on the x-z plane, centered at the origin.
% Default mesh size 128x128. 
%
% CYLINDER: A cylinder with radius 1 and height of 2*pi.  Default mesh
% size 128x128.
%
% TORUS: A torus with ring radius of 1 and tube radius of 0.4.
% Default mesh size 128x128.
%
% REVOLUTION: A surface of revolution based on a user-defined profile,
% height 2*pi.  See the option 'rcurve' below on how to define the
% profile.  Default mesh size 128x128.
%
% EXTRUSION: An extrusion based on a user-defined cross-sectional
% profile, height 2*pi.  See option 'ecurve' below on how to define the
% profile.  Default mesh size 128x128.
%
% WORM: A tube-like shape that tracks a user-defined curve in three
% dimensions.  Default tube radius 1.  The curve is defined using
% options 'spinex', 'spinez', and 'spiney'; see below.
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
%  objMakePlain(...,'mymodel.obj',...)
%
% SAVE
% Boolean, toggle saving the model to a file.  Default is false, the
% model is not saved.  Setting the filename (see above) sets this
% option to true.  If filename is not set and the option 'save' is
% true, a default filename is used; the default filename is the name
% of the base shape appended with .obj: 'sphere.obj', 'plane.obj',
% 'torus.obj', 'cylinder.obj', 'revolution.obj', and 'extrusion.obj'.
% Example:
%  objMakePlain('cylinder','save',true);
%
% NPOINTS
% Resolution of the model mesh (number of vertices).  Given as a
% two-vector for the number of vertices in the "vertical" (elevation
% or y, depending on the shape) and "horizontal" (azimuth or x)
% directions.  Example: 
%  objMakePlain(...,'npoints',[64 64],...)
% 
% MATERIAL
% Name of the material for the model and optionally the name of the
% material library (.mtl) file.  Given as a string (material only)
% or a cell array of length two (material and file), in which case
% the elements of the cell array are two strings, the first one for
% the material name and the second for the material library file.
% This option forces the option uvcoords (see below) to true.
% Example:
% objMakePlain(...,'material','mymaterial',...)
% objMakePlain(...,'material',{'mymaterial','matfile.mtl'},...)
%
% UVCOORDS
% Boolean, toggles the computation of texture (uv) coordinates
% (default is false).  Example: 
%  objMakePlain(...,'uvcoords',true,...)
%
% NORMALS
% Boolean, toggle the computation of vertex normals (default false).
% Turning this on improves the quality of rendering, but note that
% some rendering programs might compute the normals for you, making
% it unnecessary to include them in the file.  Example:
%  objMakePlain(...,'normals',true,...)
%
% TUBE_RADIUS, MINOR_RADIUS
% Sets the radius of the "tube" of a torus.  Default 0.4 (the radius
% of the ring, or the distance from the origin to the center of the
% tube is 1).  Example: 
%  objMakePlain(...,'tube_radius',0.2,...)
%
% RCURVE, ECURVE
% A vector giving the curve to use with shapes 'revolution' ('rcurve')
% and 'extrusion' ('ecurve').  When the shape is 'revolution', a
% surface of revolution is produced by revolving the curve about the
% y-axis.  When the shape is 'extrusion', the curve gives the
% cross-sectional profile of the object.  This profile is translated
% along the y-axis to produce a 3D shape.  Example: 
%  profile = .1 + ((-64:63)/64).^2;
%  objMakePlain('revolution','rcurve',profile)
%  objMakePlain('extrusion','ecurve',profile)
%
% You can also combine the two curve types by giving both options.  In
% this case, the 'rcurve' is revolved around the y-axis along a path
% (or radial profile) defined by 'ecurve'.  If the length of the
% vector 'rcurve' or 'ecurve' does not match the size of the model
% mesh in the corresponding direction, the curve is interpolated.
%
% SPINEX, SPINEZ
% As used with shapes 'cylinder', 'revolution', and 'extrusion'; see
% below for use with 'worm'. A vector giving the coordinates of the
% midline, or "spine", of the shape as a function of the y-coordinate.
% The midpoint of each slice of the model in the xz-plane is
% translated from the origin to the coordinates defined by 'spinex'
% and 'spinez'.  The following example produces a sinusoidal curve in
% the x-direction: 
%  y = linspace(0,4*pi,128);
%  x = sin(y);
%  objMakePlain('cylinder','spinex',x,'save',true);
% And adding a cosinusoid to the z-coordinate produces a corkscrew:
%  z = cos(y);
%  objMakePlain('cylinder','spinex',x,'spinez',z,'save',true);
%
% If the length of the vector 'spinex' or 'spinez' does not match the
% size of the model mesh y-direction, the curve is interpolated.
%
% SPINEX, SPINEZ, SPINEY
% As used with shape 'worm'; see above for use with cylinder-like
% objects.  Vectors that define the midline of the worm shape.  For
% example:
%  y = linspace(0,4*pi,128);
%  x = sin(y);
%  z = cos(y);
%  m = objMakePlain('worm','spinex',x,'spinez',z);
%  objShow(m);
%
% SCALEY
% Boolean, set this to true to scale the height of the model so that
% the model has a constant length along its spine when using the
% options 'spinex' and 'spinez'. 
%
% Y
% Can be used when the shape is 'revolution'.  Gives the y-coordinate
% for 'rcurve' (see above).  By default, the y-coordinate is
% monotonically increasing.  Setting a default vector for Y, one can
% define more complex surfaces of revolution.  See the online
% documentation for examples.
%
% RPAR
% When the shape is 'torus', the optional parameter vector RPAR
% defines the modulation for the major radius---the distance from the
% center of the tube to the center of the torus.  The parameter vector
% is [freq phase amplitude].  Example:
%  objMakePlain('torus','rpar',[4 0 .1])
%
% CAPS
% Boolean.  Set this to true to put "caps" at the end of cylinders, 
% surfaces of revolution, and extrusions.  Default false.  Example:
%  objMakePlain('cylinder','caps',true);
%
% WIDTH, HEIGHT
% Scalars, width and height of the model.  Option 'width' can only be
% used with shape 'plane' to set the plane width.  'height' can be
% used with 'plane', 'cylinder', 'revolution', and 'extrusion'.
% Examples:
%  objMakePlain('plane','width',2,'height',0.5);
%  objMakePlain('cylinder','height',1.35);
%
% RADIUS, MAJOR_RADIUS
% Scalar.  Change the radius of a sphere or a cylinder, or the major
% radius of a torus.  Default is 1.  Example:
%  objMakePlain('sphere','radius',1.5);
%
% COORDS:
% Can be used with the 'disk' shape to select the coordinate system in
% which the perturbations are added.  Either 'polar' (default) or
% 'cartesian'.
% 
% RETURNS:
% ========
% A structure holding all the information about the model.  This
% structure can be given as input to another objMake*-function to
% perturb the shape, or it can be given as input to objSaveModel to
% save it to file (but the saving to file is a default behavior of
% objMakePlain, so unless the option 'save' is set to false, it is not
% necessary to save the model manually).
% 
% BATCH PROCESSING:
% =================
% For creating several objects with a single function call, there is
% an option to provide all input arguments to objMakePlain as a single cell
% array.  For example, the following two calls are equivalent:
%  objMakePlain('cylinder','npoints',[64 64],'uvcoords',true,'cyl1.obj')
%  objMakePlain({'cylinder','npoints',[64 64],'uvcoords',true,'cyl1.obj'})
% 
% To create several objects with one call, define several sets of
% parameters in the cells of the only input argument.  In this case,
% then, the only input argument is a cell array of cell arrays:
%  prm = {
%         {'cylinder','npoints',[64 64],'uvcoords',true,'cyl1.obj'},
%         {'plane','npoints',[64 64],'uvcoords',true,'pla1.obj'}
%        };
%  objMakePlain(prm);
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

% Copyright (C) 2015, 2016, 2017 Toni Saarela
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
% 2015-10-10 - ts - added support for worm shape
% 2015-10-15 - ts - fixed the updating of the nargin/narg var to work with matlab
% 2015-10-15 - ts - added option to modulate torus radius (rpar)
%                    previously only possible with objMakeSine etc
%                   updated help
% 2016-01-19 - ts - added the disk shape
% 2016-01-21 - ts - calls objMakeVertices
% 2016-03-25 - ts - renamed objMakePlain, is now a wrapper
% 2016-04-08 - ts - re-enabled batch mode
% 2016-04-14 - ts - help
% 2017-05-26 - ts - help
  
%------------------------------------------------------------

narg = nargin;

% For batch processing.  If there's only one input arg and it's a cell
% array, it has all the parameters.
if iscell(shape) && narg==1
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
  narg = length(shape);
  if narg>1
    varargin = shape(2:end);
  end
  shape = shape{1};
end


model = objMake(shape,'none',varargin{:});

if ~nargin
  clear model
end
