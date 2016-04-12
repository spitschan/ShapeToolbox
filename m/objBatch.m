function status = objBatch(filename,ignore_errors)

% OBJBATCH
%
% Usage: STATUS = objBatch(PRM,[IGNORE_ERRORS])
%        STATUS = objBatch(FILENAME,[IGNORE_ERRORS])
%
% Create objects in a batch.  
%
% INPUT
% =====
% 
% The first input argument, MODULATION, is a string defining the
% type of modulation/perturbation to the base shape.  Possible
% values are 'none', 'sine', 'noise', 'bump', and 'custom'.
%
% In the first form,
%  > STATUS = objBatch(PRM)
% PRM is a cell array of cell arrays.  Each cell defines the
% parameters for a single model.  The first element of the cell is a
% string defining the perturbation.  Possible values are 'none',
% 'sine', 'noise', 'bump', and 'custom', and it can be different for
% each model.  The contents of the rest of the each cell is exactly
% what you would give as input to the corresponding objMake*-function.
% For example, the following two calls:
%  > objMakeSine('sphere',[8 .05 60 0],'sphere1.obj');
%  > objMakeSine('cylinder',[4 .1 0 0],'cylinder1.obj');
% are equivalent to the single call:
%  > prm = {{'sine','sphere',[8 .05 60 0],'sphere1.obj'},{'sine','cylinder',[4 .1 0 0],'cylinder1.obj'}};
%  > objBatch(prm);
%
% In the second form, 
%  > STATUS = objBatch(FILENAME)
% FILENAME is the name of an .m-file defining the modulation
% parameters.  This file has to be a script (not a function),
% defining a single cell array named 'prm'.  The cells of this cell
% array give the modulation parameters just as with the first form of
% the function above.  The equivalent of the example above would be
% to save the following to a file named, say, 'batchprm.m':
% 
%   prm = {
%          {'sine','sphere',[8 .05 60 0],'sphere1.obj'},
%          {'sine','cylinder',[4 .1 0 0],'cylinder1.obj'}
%         };
%
% and then calling objMakeSine as:
% > objBatch('batchprm.m');
%
% Note that the perturbation does not have to be the same for all models.
% 
% The optional input argument IGNORE_ERRORS is a boolean.  If true,
% the batch processing continues to the next model when an error
% occurs with one set of parameters.  If false (default),
% processing stops and an error is raised.  
% 
% RETURNS
% =======
% 
% When IGNORE_ERRORS is true, the output argument STATUS is 1 if any
% errors occurred.  If all shapes were completed successfully,
% STATUS is always 0.

% Copyright (C) 2015,2016 Toni Saarela
% 2015-10-02 - ts - first version
% 2015-11-09 - ts - fixed errors in help
%                   removed input arg 'modulation', the modulation is
%                   now defined by the first element of the
%                   parameter cell array and can be different for
%                   each model
% 2016-03-26 - ts - renamed objBatch (was objMakeBatch)

status = 0;

if nargin<2 || isempty(ignore_errors)
  ignore_errors = false;
end

if iscell(filename)
  prm = filename;
else
  filename = regexprep(filename,'\.m$','');
  eval(filename);
end

if ~exist('prm')
  error(sprintf('No cell array ''prm'' found.\n'));
elseif ~iscell(prm)
  error(sprintf('The variable ''prm'' has to be a cell array.\n'));
end

for ii = 1:length(prm)
  try
    switch lower(prm{ii}{1})
      case 'none'
        objMake(prm{ii}{2:end});
      case 'sine'
        objMakeSine(prm{ii}{2:end});
      case 'noise'
        objMakeNoise(prm{ii}{2:end});
      case 'bump'
        objMakeBump(prm{ii}{2:end});
      case 'custom'
        objMakeCustom(prm{ii}{2:end});
      otherwise
        error(sprintf('Unknown modulation type.\n'));
    end
  catch err
    if ignore_errors
      status = 1;
      warning(sprintf('Could not create shape number %d.\n',ii));
    else
      rethrow(err);
    end
  end
end
