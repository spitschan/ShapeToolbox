function [opts,shape] = objParseArgs(opts,par)

% OBJPARSEARGS
%
% Parse input arguments to objMake*-functions.

% Copyright 2015 Toni Saarela
% 2015-05-04 - ts - first version
% 2015-05-12 - ts - adds file name extension if needed
% 2015-05-13 - ts - added 'locations' option; other bug fixes

opts.mtlfilename = '';
opts.mtlname = '';
opts.comp_uv = false;
opts.comp_normals = false;
opts.dosave = true;
opts.new_model = true;

% Flag to indicate whether uv-coordinate computation was set to false
% explicitly.  This is used so that the option 'uvcoords' can be used
% to override the effect of option 'material', which sets the
% computation to true.  The user might want to do 
% > objMakeWhatever(...,'material',{'foo','bar'},'uvcoords',false,...)
% in the case that no textures are mapped and only uniform material
% properties are set.  File size will be smaller with no
% uv-coordinates.
uv_explicit_false = false;

shape = {};

if ~isempty(par)
  ii = 1;
  while ii<=length(par)
    if ischar(par{ii})
      switch lower(par{ii})
        case 'mindist'
          if ii<length(par) && isnumeric(par{ii+1})
             ii = ii+1;
             opts.mindist = par{ii};
          else
             error('No value or a bad value given for option ''mindist''.');
          end
         case 'npoints'
           if ii<length(par) && isnumeric(par{ii+1}) && length(par{ii+1}(:))==2
             ii = ii + 1;
             opts.m = par{ii}(1);
             opts.n = par{ii}(2);
           else
             error('No value or a bad value given for option ''npoints''.');
           end
         case 'material'
           if ii<length(par) && iscell(par{ii+1}) && length(par{ii+1})==2
             ii = ii + 1;
             opts.mtlfilename = par{ii}{1};
             opts.mtlname = par{ii}{2};
             opts.comp_uv = true;
           else
             error('No value or a bad value given for option ''material''.');
           end
         case 'uvcoords'
           if ii<length(par) && isscalar(par{ii+1})
             ii = ii + 1;
             opts.comp_uv = par{ii};
             if ~opts.comp_uv
                uv_explicit_false = true;
             end
           else
             error('No value or a bad value given for option ''uvcoords''.');
           end
         case 'rms'
           opts.use_rms = true;
         case 'normals'
           if ii<length(par) && isscalar(par{ii+1})
             ii = ii + 1;
             opts.comp_normals = par{ii};
           else
             error('No value or a bad value given for option ''normals''.');
           end
         case 'save'
           if ii<length(par) && isscalar(par{ii+1})
             ii = ii + 1;
             opts.dosave = par{ii};
           else
             error('No value or a bad value given for option ''save''.');
           end
         case 'model'
           if ii<length(par) && isstruct(par{ii+1})
             ii = ii + 1;
             shape = par{ii};
             opts.new_model = false;
           else
             error('No value or a bad value given for option ''model''.');
           end
         case 'tube_radius'
           if ii<length(par) && isnumeric(par{ii+1})
             ii = ii + 1;
             opts.tube_radius = par{ii};
           else
             error('No value or a bad value given for option ''tube_radius''.');
           end              
         case {'rprm','radius_prm'}
           if ii<length(par) && isnumeric(par{ii+1})
             ii = ii + 1;
             opts.rprm = par{ii};
           else
             error('No value or a bad value given for option ''radius''.');
           end
         case {'locations','loc'}
           if ii<length(par) && iscell(par{ii+1}) && length(par{ii+1})==2
             ii = ii + 1;
             opts.locations = par{ii};
           else
             error('No value or a bad value given for option ''locations''.');
           end
         case 'rotate'
           if ii<length(par) && isnumeric(par{ii+1})
             ii = ii + 1;
             opts.rotate = par{ii};
           else
             error('No value or a bad value given for option ''rotate''.');
           end
        otherwise
          opts.filename = par{ii};
      end
    else
        
    end
    ii = ii + 1;
  end % while over par
end

% See comment above for explanation.
if uv_explicit_false
   opts.comp_uv = false;
end

% Add file name extension if needed
if isempty(regexp(opts.filename,'\.obj$'))
  opts.filename = [opts.filename,'.obj'];
end
