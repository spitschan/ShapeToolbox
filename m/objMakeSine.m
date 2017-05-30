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
% 'sphere', 'plane', 'disk','cylinder', 'torus', 'revolution',
% 'extrusion' or 'worm'.  See details in the help for objMakePlain.
% Example: 
%   objMakeSine('sphere')
%
% CPAR:
% =====
%
% Parameters for the modulation "carriers".  The parameters are the
% frequency, angle (orientation), phase, and amplitude:
%   CPAR = [FREQ ANGLE PH AMPL]
%
% The sinusoidal modulation is added to the base shape: to the radius
% for spheres, cylinder, surfaces of revolution, and extrusions; to
% the "tube" radius for tori; and to the z-component of planes and
% disks.
%
% Frequency is radial (in cycle/(2*pi)) for the sphere, cylinder,
% torus, surface of revolution, and extrusion shapes; and spatial
% frequency for the plane shape.  Phase and angle/orientation are
% given in degrees.  Modulations are in sine phase (phase 0 is sine
% phase).  Angle 0 is "vertical", parallel to the y-axis (z-axis
% for planes and disks).
%
% Several carriers are defined in rows of CPAR:
%   CPAR = [FREQ1 ANGLE1 PH1 AMPL1 
%           FREQ2 ANGLE2 PH2 AMPL2 
%           ... 
%           FREQN ANGLEN PHN AMPLN]
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
% index is the (optional) fifth entry of the parameter vector:
%   CPAR = [FREQ1 ANGLE1 PH1 AMPL1 GROUP1
%           ...
%           FREQN ANGLEN PHN AMPLN GROUPN]
% 
%   MPAR = [FREQ1 ANGLE1 PH1 AMPL1 GROUP1
%           ...
%           FREQM ANGLEM PHM AMPLM GROUPM]
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
% All the same options as in objMakePlain.  See objMakePlain
% documentation: 
%   help objMakePlain;
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
% 2016-01-21 - ts - calls objMakeVertices
% 2016-03-25 - ts - is now a wrapper for the new objMake
% 2016-04-08 - ts - re-enabled batch mode
% 2016-04-14 - ts - help

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


if ~isempty(varargin) && isnumeric(varargin{1})
   varargin = {'mpar',varargin{:}};
end

if nargin>1 && ~isempty(cprm)
  varargin = {'cpar',cprm,varargin{:}};
end

model = objMake(shape,'sine',varargin{:});

if ~nargin
  clear model
end
