function model = objMakeCustom(shape,f,prm,varargin)

% OBJMAKECUSTOM
% 
% Usage:          objMakeCustom(SHAPE)
%                 objMakeCustom(SHAPE,FUNC,PAR,[OPTIONS])
%                 objMakeCustom(SHAPE,IMG,AMPL,[OPTIONS])
%                 objMakeCustom(SHAPE,MAT,AMPL,[OPTIONS])
%         MODEL = objMakeCustom(...)
%
% Produce a 3D model mesh object of a given shape, perturbed by
% custom modulation (alternatives explained below), and save it to a
% file in Wavefront obj-format.  Optionally return a structure that
% holds the model information.
%
% The base shape is defined by the first argument, SHAPE.  The base
% shape is perturbed by using either an image or a matrix as a height
% map, or by providing a handle to a function that determines the
% perturbation.  Explained in more detail below.
% 
% SHAPE:
% ======
%
% Either an existing model returned by one of the objMake*-functions,
% or a string defining a new shape.  If a string, has to be one of
% 'sphere', 'plane', 'disk', 'cylinder', 'torus', 'revolution',
% 'extrusion', or 'worm'.  See details in the help for objMakePlain.
% Example:
%   objMakeCustom('sphere',...)
%
% PERTURBATION BY USER-DEFINED FUNCTION
% =====================================
% A user-defined function can be used to determine the perturbation of
% the base shape.  After the shape, provide a function handle and a
% parameter vector:
%   objMakeCustom(shape,$func,par,...)
%
% The function has to accept a vector or matrix of distance values as
% its first input argument, and a vector of parameters as a second
% input argument.  That is, the function accepts calls such as:
%   x = func(d,prm)
% where d is a vector or a matrix, par is a parameter vector, and x is
% an output the same size as d.  The values in x describe the
% perturbation at distance d from a center point.
%
% The parameter vector par has the following format:
%   [NLOCS CUTOFF PAR1 PAR2 ... ]
% where NLOCS is the number of locations at which the function will be
% applied, CUTOFF is the cutoff distance at which the perturbation
% will be zero, and PAR1... are additional parameter that are
% forwarded to the function (as its second input argument).
%
% To apply the same function several times with different parameters,
% define the parameters in rows:
%   [NLOCS1 CUTOFF1 PAR11 PAR12 ... 
%    ...
%    NLOCSN CUTOFFN PARN1 PARN2 ...] 
%
% IMAGE OR MATRIX AS A HEIGHT MAP
% ====================================
% The perturbation value can also be read from an image or a matrix.
% In this case, the second input argument gives the name of the image
% file or the name of the matrix, and the third argument gives the
% amplitude:
%   objMakeCustom(shape,'imgfilename.ext',amplitude,...)
%   objMakeCustom(shape,mymatrix,amplitude,...)
% 
% The pixel values from an image are first scaled to 0-1 and them
% multiplied by the amplitude.  RGB images are averaged across
% channels first.  An input matrix is first scaled so that the maximum
% absolute value is 1, then multiplied by the amplitude.
% 
% OPTIONS:
% ========
%
% All the same options as in objMakePlain plus the ones listed below.  
% See objMakePlain documentation:
%  help objMakePlain;
%
% MINDIST
% Minimum distance between the locations at which the user-defined
% perturbation function is applied.  A scalar of a vector the length of
% which equals the number of parameter sets with which the function is
% called (number of rows in PAR).  Note: The minimum distance
% only applies to perturbations of the same type, it is not applied across
% perturbations types.  Example: 
%   objMakeCustom('plane',@func,...,'mindist',.3)
%
% LOCATIONS
% Locations at which the user-defined perturbation function is
% applied, in a cell array.  The locations are given as
% X and Y for planes, azimuth and elevation / Theta and Phi for
% spheres and tori, and azimuth and Y for cylinders, surfaces of
% revolution, and extrusions.  The format of the cell array (for
% planes, as this example uses x and y) is: 
%   {{[x1 x2 ...]},{[y1 y2 ...]}} 
% for a single perturbation type.  For several types: 
%   {{[x11 x12 ...],[x21 x22 ...],...},{[y11 y12 ...],[y21 y22 ...],...}}
% 
% MAX
% Usually you add the new bump values to the existing
% perturbation. When given the option 'max', the new perturbation
% value is the maximum of the existing perturbation and the new
% one. Example:
%   objMakeBump('plane',...,'max',...)
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

% Copyright (C) 2015, 2016, 2017 Toni Saarela
% 2015-06-01 - ts - first version, based on objMakeBumpy and
%                    others
% 2015-06-05 - ts - added option for "caps" for cylinder-type shapes
%                   help
% 2015-06-08 - ts - revolution and extrusion can be combined
% 2015-06-10 - ts - help
% 2015-06-16 - ts - removed setting of default file name
% 2015-09-29 - ts - minor update to help
% 2015-10-02 - ts - minor fixes to help (rcurve, ecurve params)
%                   added option for batch processing
% 2015-10-08 - ts - added support for the 'spinex' and 'spinez' options
%                   bug fixes and improvements
% 2015-10-09 - ts - added/fixed bump map support for planes,
%                    cylinders, tori
% 2015-10-10 - ts - added support for worm shape
% 2015-10-11 - ts - fixes in help
% 2015-10-15 - ts - fixed the updating of the nargin/narg var to work with matlab
%                   help refers to objMake instead of repeating
%                   added option for torus major radius modulation
%                    (was there a reason it was not here?)
% 2015-10-29 - ts - updated call to renamed objmakeheightmap
% 2016-01-21 - ts - calls objMakeVertices
%                   added (finally) torus major radius modulation
% 2016-03-26 - ts - is now a wrapper for the new objMake
% 2016-04-08 - ts - re-enabled batch mode
% 2017-05-26 - ts - help

% TODO

%------------------------------------------------------------

narg = nargin;

% For batch processing.  If there's only one input arg and it's a cell
% array, it has all the parameters.
if iscell(shape) && narg==1
  % If the only input argument is a cell array of cell arrays, recurse
  % through the cells. Each cell holds parameters for one shape.
  if all(cellfun('iscell',shape))
    if length(shape)>1
      objMakeCustom(shape(1:end-1));
    end
    objMakeCustom(shape{end});
    return
  end
  % Otherwise, unpack the mandatory input arguments from the beginning
  % of the array and assign the rest to varargin:
  narg = length(shape);
  if narg>3
    varargin = shape(4:end);
  end
  if narg>2
    prm = shape{3};
  end
  if narg>1
    f = shape{2};
  end
  shape = shape{1};
end

varargin = {'custom',f,'custompar',prm,varargin{:}};
model = objMake(shape,'custom',varargin{:});

if ~nargin
  clear model
end

