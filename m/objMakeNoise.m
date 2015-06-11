function model = objMakeNoise(shape,nprm,varargin)

% OBJMAKENOISE
%
% Usage:           objMakeNoise()
%                  objMakeNoise(NPAR,[OPTIONS])
%                  objMakeNoise(NPAR,MPAR,[OPTIONS])
%          model = objMakeNoise(...)
%
% Produce a 3D model mesh object of a given shape, perturbed by
% filtered noise, and save it to a file in Wavefront obj-format.  
% Optionally return a structure that holds the model information.
%
% The base shape is defined by the first argument, SHAPE.  The
% parameters for the noise are defined by NPAR, and the
% parameters for the optional envelope of the modulation are defined
% in MPAR.  See details below.
% 
% SHAPE:
% ======
%
% Either an existing model returned by one of the objMake*-functions,
% or a string defining a new shape.  If a string, has to be one of
% 'sphere', 'plane', 'cylinder', 'torus', 'revolution', and
% 'extrusion'.  Example: objMakeNoise('sphere')
%
% If an existing model structure is given as input, new modulation is
% added to the existing model.  Example:
%   m = objMakeSine('cylinder');
%   objMakeNoise(m);
%
% The shapes use a coordinate system where the y-direction is "up" and
% the x-z plane is the reference plane.
% 
% Some notes and default values for the shapes (some can be changed
% with the optional input arguments, see below):
%
% SPHERE: A unit sphere (radius 1), default mesh size 128x256.  Saved
% to 'spherenoisy.obj'.
%
% PLANE: A plane with a width and height of 1, lying on the x-y plane,
% centered on the origin.  Default mesh size 256x256.  Obviously a
% size of 2x2 would be enough; the larger size is used so that fine
% modulations can later be added to the shape if needed.  Saved in
% 'planenoisy.obj'.
%
% CYLINDER: A cylinder with radius 1 and height of 2*pi.  Default mesh
% size 256x256.  Saved in 'cylindernoisy.obj'.
%
% TORUS: A torus with ring radius of 1 and tube radius of 0.4.
% Default mesh size 256x256, saved in 'torusnoisy.obj'.
%
% REVOLUTION: A surface of revolution based on a user-defined profile,
% height 2*pi.  See the option 'curve' below on how to define the
% profile.  Default mesh size 256x256, saved in 'revolutionnoisy.obj'.
%
% EXTRUSION: An extrusion based on a user-defined cross-sectional
% profile, height 2*pi.  See option 'curve' below on how to define the
% profile.  Default mesh size 256x256, saved in 'extrusionnoisy.obj'.
%
% NPAR:
% =====
%
% Parameters for the filtered noise:
%   NPAR = [FREQ FREQWDT OR ORWDT AMPL],
% where
%   FREQ    - middle frequency, radial (cycle/(2pi)) or, 
%             for plane, spatial frequency
%   FREQWDT - full width at half height, in octaves
%   OR      - orientation in degrees (0 is 'vertical')
%   ORWDT   - orientation bandwidth (FWHH), in degrees
%   AMPL    - amplitude
%
% Set the orientation bandwidt to Inf to get isotropic (non-oriented)
% noise.  
% Several modulation components can be defined in the rows of NPAR.
% The components are added.
%   NPAR = [FREQ1 FREQWDT1 OR1 ORWDT1 AMPL1
%           FREQ2 FREQWDT2 OR2 ORWDT2 AMPL2
%           ...
%           FREQN FREQWDTN ORN ORWDTN AMPLN]
%
% MPAR:
% =====
%
% Parameters for the modulation "envelopes".  The envelope modulates
% the amplitude of the noise.  The format of the parameter vector is
% the same as as in objMakeSine:
%   MPAR = [FREQ AMPL PH ANGLE]
%
% Envelope contrast 0 means no modulation of noise amplitude, contrast
% 1 means the amplitude varies between 0 and the noise amplitude set
% in NPAR.  If several envelopes are defined, they are multiplied.
%
% To pair noise samples with envelopes (for example, to alternate between
% two noise samples), additional group indices can be defined.  Noises
% with the same index are added together, and the amplitude of the
% compound is multiplied with the corresponding envelope.  The group
% inde is the (optional) fifth entry of the parameter vector:
%   NPAR = [FREQ1 FREQWDT1 OR1 ORWDT1 AMPL1 GROUP1
%           ...
%           FREQN FREQWDTN ORN ORWDTN AMPLN GROUPN]
% 
%   MPAR = [FREQ1 AMPL1 PH1 ANGLE1 GROUP1
%           ...
%           FREQM AMPLM PHM ANGLEM GROUPM]
% 
% Group index is a non-negative integer.  Group index 0 (the default
% group index) is special: All noises with index zero are added to
% the other components WITHOUT first being multiplied with a
% modulator.  Modulators with group index 0 multiply the sum of ALL
% components, including components already multiplied by their own
% modulators.  
%
% OPTIONS:
% ========
%
% With the exception of the filename, all options are gives as
% name-value pairs.  All possible options are listed below.
%
% FILENAME
% A single string giving the name of the file in which to
% save the model.  Example: objMakeNoise(...,'mymodel.obj',...)
%
% NPOINTS
% Resolution of the model mesh (number of vertices).  Given as a
% two-vector for the number of vertices in the "vertical" (elevation
% or y, depending on the shape) and "horizontal" (azimuth or x)
% directions.  Example: objMakeNoise(...,'npoints',[64 64],...)
% 
% MATERIAL
% Name of the material library (.mtl) file and the name of the
% material for the model.  Given as a cell array of length two.  The
% elements of the cell array are two strings, the first one for the
% material library file and the second for the material name.  This
% option forces the option uvcoords (see below) to true.  Example:
% objMakeNoise(...,'material',{'matfile.mtl','mymaterial'},...)
%
% UVCOORDS
% Boolean, toggles the computation of texture (uv) coordinates
% (default is false).  Example: objMakeNoise(...,'uvcoords',true,...)
%
% NORMALS
% Boolean, toggle the computation of vertex normals (default false).
% Turning this on improves the quality of rendering, but note that
% some rendering programs might compute the normals for you, making
% it unnecessary to include them in the file.  Example:
% objMakeNoise(...,'normals',true,...)
%
% SAVE
% Boolean, toggle saving the model to a file.  Default is true, the
% model is saved.  You might want to set this to false if you just
% want to make the model structure and modify it with another
% objMake*-function or with objBlend.  Example: 
% m = objMakeNoise(...,'save',false,...)
%
% TUBE_RADIUS, MINOR_RADIUS
% Sets the radius of the "tube" of a torus.  Default 0.4 (the radius
% of the ring, or the distance from the origin to the center of the
% tube is 1).  Example: objMakeNoise(...,'tube_radius',0.2,...)
%
% CURVE
% A vector giving the curve to use with shapes 'revolution' and
% 'extrusion'.  When the shape is 'revolution', a surface of
% revolution is produced by revolving the curve about the y-axis.
% When the shape is 'extrusion', the curve gives the cross-sectional
% profile of the object.  This profile is translated along the y-axis
% to produce a 3D shape.  Example: 
%  profile = .1 + ((-64:63)/64).^2;
%  objMakeNoise('revolution',...,'curve',profile)
%
% CAPS
% Boolean.  Set this to true to put "caps" at the end of cylinders, 
% surfaces of revolution, and extrusions.  Default false.  Example:
%  objMakeNoise('cylinder',[],'caps',true);
%
% WIDTH, HEIGHT
% Scalars, width and height of the model.  Option 'width' can only be
% used with shape 'plane' to set the plane width.  'height' can be
% used with 'plane', 'cylinder', 'revolution', and 'extrusion'.
% Examples:
%  objMakeNoise('plane',[],'width',2,'height',0.5);
%  objMakeNoise('cylinder',[],'height',1.35);
%
% RMS
% Boolean.  If true, the amplitude parameter sets the root mean square
% contrast of the noise.  Default is false: the amplitude parameter
% sets the max absolute value of the noise.
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
% 2015-05-31 - ts - first version, based on objMakeSphereNoisy and
%                    others
% 2015-06-03 - ts - envelope parameter scaling for planes
%                   added handling of tori (yeah i'd just forgotten it)
% 2015-06-05 - ts - added option for "caps" for cylinder-type shapes
%                   updated help
%                   removed the option to modulate torus major radius
%                   (this can now only be done in objMakeSine)
% 2015-06-08 - ts - revolution and extrusion can be combined
% 2015-06-10 - ts - freq units for plane changed (again)--not in
%                    cycle/object anymore; width and height given as
%                    input to noise-making function
%                   help 

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
model.filename = [model.shape,'noisy.obj'];

% Check and parse optional input arguments
[modpar,par] = parseparams(varargin);
model = objParseArgs(model,par);

%------------------------------------------------------------

switch model.shape
  case 'sphere'
    defprm = [8 1 0 45 .1 0];
  case 'plane'
    defprm = [8 1 0 45 .1 0];
  case 'cylinder'
    defprm = [8 1 0 45 .1 0];
  case 'torus'
    defprm = [8 1 0 45 .1 0];
  case 'revolution'
    defprm = [8 1 0 45 .1 0];
    model = objInterpCurves(model);
    %model.curve = model.curve/max(model.curve);
  case 'extrusion'
    defprm = [8 1 0 45 .1 0];
    model = objInterpCurves(model);
    %model.curve = model.curve/max(model.curve);
  otherwise
    error('Unknown shape');
end

if nargin<2 || isempty(nprm)
  nprm = defprm;
end
[nncomp,ncol] = size(nprm);

% Set default group index if needed
if ncol==5
  nprm = [nprm zeros(nncomp,1)];
elseif ncol<5
  error('Incorrect number of columns in input argument ''nprm''.');
end

nprm(:,3:4) = pi * nprm(:,3:4)/180;

%------------------------------------------------------------
% Set the default modulation parameters to empty indicating no
% modulator; set default filename, material filename.
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
    mprm(:,1) = mprm(:,1)*2*pi;
  end
  mprm(:,3:4) = pi * mprm(:,3:4)/180;
end

%------------------------------------------------------------
% Vertices
if model.flags.new_model
  model = objSetCoords(model);
end

switch model.shape
  case 'sphere'
    % For the 2D noise sample, reshape the coordinate vectors to temp 2D matrices
    Theta = reshape(model.Theta,[model.n model.m])';
    Phi = reshape(model.Phi,[model.n model.m])';
    R = reshape(model.R,[model.n model.m])';
    R = R + objMakeNoiseComponents(nprm,mprm,Theta,Phi,model.flags.use_rms,1,1);
    
    % Reshape the radius matrix to a vector again
    R = R'; 
    model.R = R(:);
    model.vertices = objSph2XYZ(model.Theta,model.Phi,model.R);
  case 'plane'
    % For the 2D noise sample, reshape the coordinate vectors to temp 2D matrices
    X = reshape(model.X,[model.n model.m])';
    Y = reshape(model.Y,[model.n model.m])';
    Z = reshape(model.Z,[model.n model.m])';
    Z = Z + objMakeNoiseComponents(nprm,mprm,X,Y,model.flags.use_rms,model.width,model.height);

    % Reshape Z matrix to a vector again
    Z = Z'; 
    model.Z = Z(:);
    model.vertices = [model.X model.Y model.Z];
  case {'cylinder','revolution','extrusion'}
    if ~model.flags.new_model && model.flags.oldcaps
      model = objRemCaps(model);
    end
    Theta = reshape(model.Theta,[model.n model.m])';
    Y = reshape(model.Y,[model.n model.m])';
    R = reshape(model.R,[model.n model.m])';
    R = R + objMakeNoiseComponents(nprm,mprm,Theta,Y,model.flags.use_rms,1,model.height/(2*pi*model.radius));

    R = R';
    model.R = R(:);

    model.X =  model.R .* cos(model.Theta);
    model.Z = -model.R .* sin(model.Theta);
    if model.flags.caps
      model = objAddCaps(model);
    end
    model.vertices = [model.X model.Y model.Z];
  case 'torus'
    % if ~isempty(model.opts.rprm)
    %   rprm = model.opts.rprm;
    %   for ii = 1:size(rprm,1)
    %     model.R = model.R + rprm(ii,2) * sin(rprm(ii,1)*model.Theta + rprm(ii,3));
    %   end
    % end
    if ~isempty(nprm)
      Theta = reshape(model.Theta,[model.n model.m])';
      Phi = reshape(model.Phi,[model.n model.m])';
      r = reshape(model.r,[model.n model.m])';

      r = r + objMakeNoiseComponents(nprm,mprm,Theta,Phi,model.flags.use_rms,1,1);

      r = r';
      model.r = r(:);
    end
    model.vertices = objSph2XYZ(model.Theta,model.Phi,model.r,model.R);
  otherwise
    error('Unknown shape.');
end
%------------------------------------------------------------
% 

if model.flags.new_model
  ii = 1;
else
  ii = length(model.prm)+1;
end
model.prm(ii).perturbation = 'noise';
model.prm(ii).nprm = nprm;
model.prm(ii).mprm = mprm;
model.prm(ii).nncomp = nncomp;
model.prm(ii).nmcomp = nmcomp;
model.prm(ii).use_rms = model.flags.use_rms;
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

