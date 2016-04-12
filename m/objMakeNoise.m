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


% Copyright (C) 2015,2016 Toni Saarela
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
% 2016-01-21 - ts - calls objMakeVertices
%                   added the disk shape
% 2016-03-25 - ts - is now a wrapper for the new objMake
% 2016-04-08 - ts - re-enabled batch mode

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

if ~isempty(varargin) && isnumeric(varargin{1})
   varargin = {'mpar',varargin{:}};
end

if nargin>1 && ~isempty(nprm)
  varargin = {'npar',nprm,varargin{:}};
end

model = objMake(shape,'noise',varargin{:});

if ~nargin
  clear model
end
