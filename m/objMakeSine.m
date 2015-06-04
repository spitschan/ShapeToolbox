function model = objMakeSine(shape,cprm,varargin)

% OBJMAKESINE
%
% Usage:          objMakeSine(SHAPE) 
%                 objMakeSine(SHAPE,CPAR,[OPTIONS])
%                 objMakeSine(SHAPE,CPAR,MPAR,[OPTIONS]) 
%         MODEL = objMakeSine(...)
%
% Produce a 3D model mesh object of a given shape, perturbed by
% sinusoidal modulation, and save it to a file in Wavefront
% obj-format.  Optionally return a structure that holds the model
% information.
%
% The base shape is defined by the first argument, SHAPE.  The
% parameters for the modulation are defined by CPAR, and the
% parameters for the optional envelope of the modulation are defined
% in MPAR.  See details below.
% 
% SHAPE:
% ======
%
% One of 'sphere', 'plane', 'cylinder', 'torus', 'revolution', and
% 'extrusion'.  Example: objMakeSine('sphere')
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
% CPAR:
% =====
%
% Parameters for the modulation "carriers".  The parameters are the
% frequency, amplitude, phase, and angle (orientation):
%   CPAR = [FREQ AMPL PH ANGLE]
%
% The sinusoidal modulation is added to the base shape: to the radius
% for spheres, cylinder, surfaces of revolution, and extrusions; to
% the "tube" radius for tori; and to the z-component of planes.
%
% Unit of frequency is cycle/(2*pi) for the sphere, cylinder, torus,
% surface of revolution, and extrusion shapes; and cycle/plane for the
% plane shape.  Phase and angle/orientation are given in degrees.
% Modulations are in sine phase (phase 0 is sine phase).  Angle 0 is
% "vertical", parallel to the y-axis.
%
% Several carriers are defined in rows of CPAR:
%   CPAR = [FREQ1 AMPL1 PH1 ANGLE1 
%           FREQ2 AMPL2 PH2 ANGLE2 
%           ... 
%           FREQN AMPLN PHN ANGLEN]
%
% MPAR:
% =====
%
% Parameters for the modulation "envelopes".  The envelope modulates
% the amplitude of the carrier.  TODO.
% 
% OPTIONS:
% ========
%
% With the exception of the filename, all options are gives as
% name-value pairs.  All possible options are listed below.
%
% FILENAME
% A single string giving the name of the file in which to
% save the model.  Example: objMakeSine(...,'mymodel.obj',...)
%
% NPOINTS
% Resolution of the model mesh (number of vertices).  Given as a
% two-vector for the number of vertices in the "vertical" (elevation
% or y, depending on the shape) and "horizontal" (azimuth or x)
% directions.  Example: objMakeSine(...,'npoints',[64 64],...)
% 
% MATERIAL
% Name of the material library (.mtl) file and the name of the
% material for the model.  Given as a cell array of length two.  The
% elements of the cell array are two strings, the first one for the
% material library file and the second for the material name.  This
% option forces the option uvcoords (see below) to true.  Example:
% objMakeSine(...,'material',{'matfile.mtl','mymaterial'},...)
%
% UVCOORDS
% Boolean, toggles the computation of texture (uv) coordinates
% (default is false).  Example: objMakeSine(...,'uvcoords',true,...)
%
% NORMALS
% Boolean, toggle the computation of vertex normals (default false).
% Turning this on improves the quality of rendering, but note that
% some rendering programs might compute the normals for you, making
% it unnecessary to include them in the file.  Example:
% objMakeSine(...,'normals',true,...)
%
% SAVE
% Boolean, toggle saving the model to a file.  Default is true, the
% model is saved.  You might want to set this to false if you just
% want to make the model structure and modify it with another
% objMake*-function or with objBlend.  Example: 
% m = objMakeSine(...,'save',false,...)
%
% TUBE_RADIUS
% Sets the radius of the "tube" of a torus.  Default 0.4 (the radius
% of the ring, or the distance from the origin to the center of the
% tube is 1).  Example: objMakeSine(...,'tube_radius',0.2,...)
%
% CURVE
% A vector giving the curve to use with shapes 'revolution' and
% 'extrusion'.  When the shape is 'revolution', a surface of
% revolution is produced by revolving the curve about the y-axis.
% When the shape is 'extrusion', the curve gives the cross-sectional
% profile of the object.  This profile is translated along the y-axis
% to produce a 3D shape.  Example: 
%  profile = .1 + ((-64:63)/64).^2;
%  objMakeSine('revolution','curve',profile)
% 
% RPRM
% TODO: Parameters for modulating the "main" radius of the torus.
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


% Copyright (C) 2015 Toni Saarela
% 2015-05-31 - ts - first version, based on objmakeSphere and others
% 2015-06-03 - ts - wrote help

%------------------------------------------------------------

if ischar(shape)
  shape = lower(shape);
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
[modpar,par] = parseparams(varargin);
model = objParseArgs(model,par);

%------------------------------------------------------------
% Carrier parameters. Set default frequency, amplitude, phase,
% "orientation" and component group id

switch model.shape
  case 'sphere'
    defprm = [8 .1 0 0 0];
  case 'plane'
    defprm = [8 .05 0 0 0];
  case 'cylinder'
    defprm = [8 .1 0 0 0];
  case 'torus'
    defprm = [8 .05 0 0 0];
  case 'revolution'
    defprm = [8 .1 0 0 0];
    ncurve = length(model.curve);
    if ncurve~=model.m
      model.curve = interp1(linspace(0,1,ncurve),model.curve,linspace(0,1,model.m));
    end
    %model.curve = model.curve/max(model.curve);
  case 'extrusion'
    defprm = [8 .1 0 0 0];
    ncurve = length(model.curve);
    if ncurve~=model.n
      model.curve = interp1(linspace(0,1,ncurve),model.curve,linspace(0,1,model.n));
    end
    %model.curve = model.curve/max(model.curve);
  otherwise
    error('Unknown shape');
end

if nargin<2 || isempty(cprm)
  cprm = defprm;
end
[nccomp,ncol] = size(cprm);

% Fill in default carrier parameters if needed
if ncol<5
  defprm = ones(nccomp,1)*defprm;
  cprm(:,ncol+1:5) = defprm(:,ncol+1:5);
end
clear defprm

if strcmp(model.shape,'plane')
  cprm(:,1) = cprm(:,1)*pi;
end
cprm(:,3:4) = pi * cprm(:,3:4)/180;

%------------------------------------------------------------
% Set the default modulation parameters to empty indicating no
% modulator
mprm  = [];
nmcomp = 0;

% If modulator parameters are given as input, set mprm to these values
if ~isempty(modpar)
  mprm = modpar{1};
  % Set default values to modulator parameters as needed
  [nmcomp,ncol] = size(mprm);
  if ncol<5
    defprm = ones(nmcomp,1)*[1 0 0 0];
    mprm(:,ncol+1:5) = defprm(:,ncol:4);
    clear defprm
  end
  if strcmp(model.shape,'plane')
    mprm(:,1) = mprm(:,1)*pi;
  end
  mprm(:,3:4) = pi * mprm(:,3:4)/180;
end

%-------------------------------------------------------------
% Vertices
if model.flags.new_model
  model = objSetCoords(model);
end

switch model.shape
  case 'sphere'
    model.R = model.R + objMakeSineComponents(cprm,mprm,model.Theta,model.Phi);
    model.vertices = objSph2XYZ(model.Theta,model.Phi,model.R);
  case 'plane'
    model.Z = model.Z + objMakeSineComponents(cprm,mprm,model.X,model.Y);
    model.vertices = [model.X model.Y model.Z];
  case {'cylinder','revolution','extrusion'}
    model.R = model.R + objMakeSineComponents(cprm,mprm,model.Theta,model.Y);
    model.X =  model.R .* cos(model.Theta);
    model.Z = -model.R .* sin(model.Theta);
    model.vertices = [model.X model.Y model.Z];
  case 'torus'
    if ~isempty(model.opts.rprm)
      rprm = model.opts.rprm;
      for ii = 1:size(rprm,1)
        model.R = model.R + rprm(ii,2) * sin(rprm(ii,1)*model.Theta + rprm(ii,3));
      end
    end
    if ~isempty(cprm)
      model.r = model.r + objMakeSineComponents(cprm,mprm,model.Theta,model.Phi);
    end
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
model.prm(ii).perturbation = 'sine';
model.prm(ii).cprm = cprm;
model.prm(ii).mprm = mprm;
model.prm(ii).nccomp = nccomp;
model.prm(ii).nmcomp = nmcomp;
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

