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
% Either an existing model returned by one of the objMake*-functions,
% or a string defining a new shape.  If a string, has to be one of
% 'sphere', 'plane', 'cylinder', 'torus', 'revolution', 'extrusion' or
% 'worm'.  See details in the help for objSave.  Example: 
%   objMakeSine('sphere')
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
% Frequency is radial (in cycle/(2*pi)) for the sphere, cylinder,
% torus, surface of revolution, and extrusion shapes; and spatial
% frequency for the plane shape.  Phase and angle/orientation are
% given in degrees.  Modulations are in sine phase (phase 0 is sine
% phase).  Angle 0 is "vertical", parallel to the y-axis.
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
% the amplitude of the carrier.  The format of the parameter vector is
% the same as as CPAR.  Envelope contrast 0 means no modulation of
% carrier amplitude, contrast 1 means the amplitude varies between 0
% and the carrier amplitude set in CPAR.  If several envelopes are
% defined, they are multiplied.
%
% To pair carriers with envelopes (for example, to alternate between
% two carriers), additional group indices can be defined.  Carriers
% with the same index are added together, and the amplitude of the
% compound is multiplied with the corresponding envelope.  The group
% inde is the (optional) fifth entry of the parameter vector:
%   CPAR = [FREQ1 AMPL1 PH1 ANGLE1 GROUP1
%           ...
%           FREQN AMPLN PHN ANGLEN GROUPN]
% 
%   MPAR = [FREQ1 AMPL1 PH1 ANGLE1 GROUP1
%           ...
%           FREQM AMPLM PHM ANGLEM GROUPM]
% 
% Group index is a non-negative integer.  Group index 0 (the default
% group index) is special: All carriers with index zero are added to
% the other components WITHOUT first being multiplied with a
% modulator.  Modulators with group index 0 multiply the sum of ALL
% components, including components already multiplied by their own
% modulators.  Gets confusing, right?  See examples below and in the
% online help.
%
% OPTIONS:
% ========
%
% All the same options as in objMake.  See objMake documentation:
%  help objMake;
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
% 2015-05-31 - ts - first version, based on objmakeSphere and others
% 2015-06-03 - ts - wrote help
% 2015-06-05 - ts - added option for "caps" for cylinder-type shapes
%                   updated help
% 2015-06-08 - ts - revolution and extrusion can be combined
% 2015-06-10 - ts - freq units for plane changed (again)--not in
%                    cycle/object anymore
%                   help
% 2015-06-16 - ts - removed setting of default file name
% 2015-10-02 - ts - minor fixes to help (rcurve, ecurve params)
%                   added option for batch processing
% 2015-10-08 - ts - added the 'spinex' and 'spinez' options
% 2015-10-10 - ts - added support for worm shape
% 2015-10-15 - ts - fixed the updating of the nargin/narg var to work with matlab
%                   help refers to objMake instead of repeating

%------------------------------------------------------------

narg = nargin;

% For batch processing.  If there's only one input arg and it's a cell
% array, it has all the parameters.
if iscell(shape) && narg==1
  % If the only input argument is a cell array of cell arrays, recurse
  % through the cells. Each cell holds parameters for one shape.
  if all(cellfun('iscell',shape))
    if length(shape)>1
      objMakeSine(shape(1:end-1));
    end
    objMakeSine(shape{end});
    return
  end
  % Otherwise, unpack the mandatory input arguments from the beginning
  % of the array and assign the rest to varargin:
  narg = length(shape);
  if narg>2
    varargin = shape(3:end);
  end
  if narg>1
    cprm = shape{2};
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
% Carrier parameters. Set default frequency, amplitude, phase,
% "orientation" and component group id

switch model.shape
  case 'sphere'
    defprm = [8 .1 0 0 0];
  case 'plane'
    defprm = [8 .05 0 0 0];
  case {'cylinder','worm'}
    defprm = [8 .1 0 0 0];
    model = objInterpCurves(model);
  case 'torus'
    defprm = [8 .05 0 0 0];
  case 'revolution'
    defprm = [8 .1 0 0 0];
    model = objInterpCurves(model);
    %model.curve = model.curve/max(model.curve);
  case 'extrusion'
    defprm = [8 .1 0 0 0];
    model = objInterpCurves(model);
    %model.curve = model.curve/max(model.curve);
  otherwise
    error('Unknown shape');
end

if narg<2 || isempty(cprm)
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
  cprm(:,1) = cprm(:,1)*2*pi;
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
    mprm(:,1) = mprm(:,1)*2*pi;
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
    if ~model.flags.new_model && model.flags.oldcaps
      model = objRemCaps(model);
    end
    model.R = model.R + objMakeSineComponents(cprm,mprm,model.Theta,model.Y);
    if model.flags.caps
      model = objAddCaps(model);
    end
    model.X =  model.R .* cos(model.Theta);
    model.Z = -model.R .* sin(model.Theta);
    model.X = model.X + model.spine.X;
    model.Z = model.Z + model.spine.Z;
    model.vertices = [model.X model.Y model.Z];
  case 'worm'
    % TODO: objRemCaps
    model.R = model.R + objMakeSineComponents(cprm,mprm,model.Theta,model.Y);
    % TODO: objAddCaps
    model = objMakeWorm(model);
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

