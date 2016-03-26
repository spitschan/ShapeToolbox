function model = objMake(shape,perturbation,varargin)

% OBJMAKE
%
% Usage:  MODEL = OBJMAKE(SHAPE,PERTURBATION) 
%         MODEL = OBJMAKE(SHAPE,PERTURBATION,[OPTIONS])
%                 OBJMAKE(SHAPE,PERTURBATION,[OPTIONS])
%
% Produce a 3D model mesh object of a given shape and optionally save 
% it to a file in Wavefront obj-format and/or return a structure that
% holds the model information.
%
% Normally you would not call this function directly but would use one
% of the objMake* wrappers, such as objMake, objMakeSine, etc.

% Copyright (C) 2016 Toni Saarela
% 2016-01-22 - ts - first version, based on objMake*-functions
% 2016-01-28 - ts - minor changes
% 2016-02-19 - ts - handles custom perturbations
% 2016-03-25 - ts - renamed objMake (from objMakeMaster)
% 2016-03-26 - ts - calls the renamed objSave (formerly objSaveModel)

%------------------------------------------------------------

narg = nargin;

% For batch processing.  If there's only one input arg and it's a cell
% array, it has all the parameters.
% if iscell(shape) && narg==1
%   % If the only input argument is a cell array of cell arrays, recurse
%   % through the cells. Each cell holds parameters for one shape.
%   if all(cellfun('iscell',shape))
%     if length(shape)>1
%       objMake(shape(1:end-1));
%     end
%     objMake(shape{end});
%     return
%   end
%   % Otherwise, unpack the mandatory input arguments from the beginning
%   % of the array and assign the rest to varargin:
%   narg = length(shape);
%   if narg>1
%     varargin = shape(2:end);
%   end
%   shape = shape{1};
% end

% Set up the model structure
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

% Set default parameters for the given perturbation:
if isempty(perturbation)
  perturbation = 'none';
end
model = objDefaultPerturbationPrms(model,perturbation);

% Check and parse optional input arguments
[tmp,par] = parseparams(varargin);
model = objParseArgs(model,par);

% Do shape-dependent things if needed
switch model.shape
  case {'sphere','plane','torus','disk'}
  case {'cylinder','revolution','extrusion','worm'}
    model = objInterpCurves(model);
  otherwise
    error('Unknown shape'); % not needed, already checked by objDefaultStruct
end

% Do perturbation-dependent things if needed
switch model.prm(model.idx).perturbation
  case 'none'
  case 'sine'
  case 'noise'
  case 'bump'
  case 'custom'
    model = objParseCustomParams(model);
end

%-------------------------------------------------------------
% Vertices
if model.flags.new_model
  model = objSetCoords(model);
end
model = objAddPerturbation(model);
model = objMakeVertices(model);

%-------------------------------------------------------------
% 

ii = model.idx;
% Get the calling function from the structure array stack.  If it's an
% objMake*-function (a wrapper), add its name to the model structure.
% Also add the name of this function.  Then in objSave write it
% down to the obj-file somehow sensibly.
stack = dbstack;
if length(stack)>1 && strncmp(stack(2).name,'objMake',7)
  model.prm(ii).mfilename = stack(2).name;
  model.prm(ii).mfilename_called = stack(1).name;
else 
  model.prm(ii).mfilename = mfilename;
end
if strcmp(model.shape,'torus')
  model.prm(ii).rprm = model.opts.rprm;
end

if model.flags.dosave
  model = objSave(model);
end

if ~nargout
   clear model
end




