function model = objMakeNoise(shape,nprm,varargin)

% OBJMAKENOISE
%
% Usage:           objMakeNoise(SHAPE)
%                  objMakeNoise(SHAPE,NPAR,[OPTIONS])
%                  objMakeNoise(SHAPE,NPAR,MPAR,[OPTIONS])
%          MODEL = objMakeNoise(...)
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
% 'sphere', 'plane', 'cylinder', 'torus', 'revolution', 'extrusion' or
% 'worm'.  See details in the help for objSave.  Example: 
%   objMakeNoise('sphere')
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
% All the same options as in objMake plus the ones listed below.  
% See objMake documentation:
%  help objMake;
%
% RMS
% Boolean.  If true, the amplitude parameter sets the root mean square
% contrast of the noise.  Default is false: the amplitude parameter
% sets the max absolute value of the noise.  Example:
%  objMakeNoise('plane',[16 1 45 30 .025],'rms',true)
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
% 2015-06-16 - ts - removed setting of default file name
% 2015-09-29 - ts - fixed the usage-part of help
% 2015-10-02 - ts - minor fixes to help (rcurve, ecurve params)
%                   added option for batch processing
% 2015-10-08 - ts - added the 'spinex' and 'spinez' options
% 2015-10-10 - ts - added support for worm shape
% 2015-10-11 - ts - fixes in help
% 2015-10-15 - ts - fixed the updating of the nargin/narg var to work with matlab
%                   help refers to objMake instead of repeating
%                   readded option for torus main radius modulation
%                   (why was it taken out?)

%------------------------------------------------------------

narg = nargin;

% For batch processing.  If there's only one input arg and it's a cell
% array, it has all the parameters.
if iscell(shape) && narg==1
  % If the only input argument is a cell array of cell arrays, recurse
  % through the cells. Each cell holds parameters for one shape.
  if all(cellfun('iscell',shape))
    if length(shape)>1
      objMakeNoise(shape(1:end-1));
    end
    objMakeNoise(shape{end});
    return
  end
  % Otherwise, unpack the mandatory input arguments from the beginning
  % of the array and assign the rest to varargin:
  narg = length(shape);
  if narg>2
    varargin = shape(3:end);
  end
  if narg>1
    nprm = shape{2};
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

switch model.shape
  case 'sphere'
    defprm = [8 1 0 45 .1 0];
  case 'plane'
    defprm = [8 1 0 45 .1 0];
  case {'cylinder','worm'}
    defprm = [8 1 0 45 .1 0];
    model = objInterpCurves(model);
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

if narg<2 || isempty(nprm)
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
    model.X = model.X + model.spine.X;
    model.Z = model.Z + model.spine.Z;

    if model.flags.caps
      model = objAddCaps(model);
    end
    model.vertices = [model.X model.Y model.Z];
  case 'worm'
    % TODO: objRemCaps
    Theta = reshape(model.Theta,[model.n model.m])';
    Y = reshape(model.Y,[model.n model.m])';
    R = reshape(model.R,[model.n model.m])';
    R = R + objMakeNoiseComponents(nprm,mprm,Theta,Y,model.flags.use_rms,1,model.height/(2*pi*model.radius));
    R = R';
    model.R = R(:);
    model = objMakeWorm(model);       
    % TODO: objAddCaps
  case 'torus'
    if ~isempty(model.opts.rprm)
      rprm = model.opts.rprm;
      for ii = 1:size(rprm,1)
        model.R = model.R + rprm(ii,2) * sin(rprm(ii,1)*model.Theta + rprm(ii,3));
      end
    end
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

