function model = objMake(shape,varargin)

% OBJMAKE
%
% Usage:          OBJMAKE(SHAPE) 
%                 OBJMAKE(SHAPE,[OPTIONS])
%         MODEL = OBJMAKE(...)
%
% Produce a 3D model mesh object of a given shape and save it to a
% file in Wavefront obj-format.
% 
% SHAPE:
% ======
%
% One of 'sphere', 'plane', 'cylinder', 'torus', 'revolution', and
% 'extrusion'.  Example: objMake('sphere')
%
% The shapes use a coordinate system where the y-direction is "up" and
% the x-z plane is the reference plane.
% 
% Some notes and default values for the shapes (some can be changed
% with the optional input arguments, see below):
%
% SPHERE: A unit sphere (radius 1), default mesh size 128x256.  Saved
% to 'sphere.obj'.
%
% PLANE: A plane with a width and height of 2, lying on the x-y plane,
% centered on the origin.  Default mesh size 256x256.  Obviously a
% size of 2x2 would be enough; the larger size is used so that fine
% modulations can later be added to the shape if needed.  Saved in
% 'plane.obj'.
%
% CYLINDER: A cylinder with radius 1 and height of 2*pi.  Default mesh
% size 256x256.  Saved in 'cylinder.obj'.
%
% TORUS: A torus with ring radius of 1 and tube radius of 0.4.
% Default mesh size 256x256, saved in 'torus.obj'.
%
% REVOLUTION: A surface of revolution based on a user-defined profile,
% height 2*pi.  See the option 'curve' below on how to define the
% profile.  Default mesh size 256x256, saved in 'revolution.obj'.
%
% EXTRUSION: An extrusion based on a user-defined cross-sectional
% profile, height 2*pi.  See option 'curve' below on how to define the
% profile.  Default mesh size 256x256, saved in 'extrusion.obj'.
%
% OPTIONS:
% ========
%
% With the exception of the filename, all options are gives as
% name-value pairs.  All possible options are listed below.
%
% FILENAME
% A single string giving the name of the file in which to
% save the model.  Example: objMake(...,'mymodel.obj',...)
%
% NPOINTS
% Resolution of the model mesh (number of vertices).  Given as a
% two-vector for the number of vertices in the "vertical" (elevation
% or y, depending on the shape) and "horizontal" (azimuth or x)
% directions.  Example: objMake(...,'npoints',[64 64],...)
% 
% MATERIAL
% Name of the material library (.mtl) file and the name of the
% material for the model.  Given as a cell array of length two.  The
% elements of the cell array are two strings, the first one for the
% material library file and the second for the material name.  This
% option forces the option uvcoords (see below) to true.  Example:
% objMake(...,'material',{'matfile.mtl','mymaterial'},...)
%
% UVCOORDS
% Boolean, toggles the computation of texture (uv) coordinates
% (default is false).  Example: objMake(...,'uvcoords',true,...)
%
% NORMALS
% Boolean, toggle the computation of vertex normals (default false).
% Turning this on improves the quality of rendering, but note that
% some rendering programs might compute the normals for you, making
% it unnecessary to include them in the file.  Example:
% objMake(...,'normals',true,...)
%
% SAVE
% Boolean, toggle saving the model to a file.  Default is true, the
% model is saved.  You might want to set this to false if you just
% want to make the model structure and modify it with another
% objMake*-function or with objBlend.  Example: 
% m = objMake(...,'save',false,...)
%
% TUBE_RADIUS
% Sets the radius of the "tube" of a torus.  Default 0.4 (the radius
% of the ring, or the distance from the origin to the center of the
% tube is 1).  Example: objMake(...,'tube_radius',0.2,...)
%
% CURVE
% A vector giving the curve to use with shapes 'revolution' and
% 'extrusion'.  When the shape is 'revolution', a surface of
% revolution is produced by revolving the curve about the y-axis.
% When the shape is 'extrusion', the curve gives the cross-sectional
% profile of the object.  This profile is translated along the y-axis
% to produce a 3D shape.  Example: 
%  profile = .1 + ((-64:63)/64).^2;
%  objMake('revolution','curve',profile)
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
[tmp,par] = parseparams(varargin);
model = objParseArgs(model,par);

switch model.shape
  case {'sphere','plane','cylinder','torus'}
  case 'revolution'
    ncurve = length(model.curve);
    if ncurve~=model.m
      model.curve = interp1(linspace(0,1,ncurve),model.curve,linspace(0,1,model.m));
    end
    %model.curve = model.curve/max(model.curve);
  case 'extrusion'
    ncurve = length(model.curve);
    if ncurve~=model.n
      model.curve = interp1(linspace(0,1,ncurve),model.curve,linspace(0,1,model.n));
    end
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
    model.X =  model.R .* cos(model.Theta);
    model.Z = -model.R .* sin(model.Theta);
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

