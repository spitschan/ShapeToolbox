function model = objParseArgs(model,par)

% OBJPARSEARGS
%
% Parse input arguments to objMake*-functions.

% Copyright 2015 Toni Saarela
% 2015-05-04 - ts - first version
% 2015-05-12 - ts - adds file name extension if needed
% 2015-05-13 - ts - added 'locations' option; other bug fixes
% 2015-05-29 - ts - rms-option now uses the same name-value syntax as
%                    all others
% 2015-05-30 - ts - no separate opts-structure; just update the model
%                    structure given as input
% 2015-05-31 - ts - improved updating of existing model
% 2015-06-03 - ts - added a new flag to indicate custom bump location
%                    are set

% Flag to indicate whether uv-coordinate computation was set to false
% explicitly.  This is used so that the option 'uvcoords' can be used
% to override the effect of option 'material', which sets the
% computation to true.  The user might want to do 
% > objMakeWhatever(...,'material',{'foo','bar'},'uvcoords',false,...)
% in the case that no textures are mapped and only uniform material
% properties are set.  File size will be smaller with no
% uv-coordinates.
uv_explicit_false = false;

if ~isempty(par)
  ii = 1;
  while ii<=length(par)
    if ischar(par{ii})
      switch lower(par{ii})
        case 'mindist'
          if ii<length(par) && isnumeric(par{ii+1})
             ii = ii+1;
             model.opts.mindist = par{ii};
          else
             error('No value or a bad value given for option ''mindist''.');
          end
         case 'npoints'
           if ~model.flags.new_model
              error('You cannot change the size of an existing model.');
           end
           if ii<length(par) && isnumeric(par{ii+1}) && length(par{ii+1}(:))==2
             ii = ii + 1;
             model.m = par{ii}(1);
             model.n = par{ii}(2);
           else
             error('No value or a bad value given for option ''npoints''.');
           end
         case 'material'
           if ii<length(par) && iscell(par{ii+1}) && length(par{ii+1})==2
             ii = ii + 1;
             model.mtlfilename = par{ii}{1};
             model.mtlname = par{ii}{2};
             model.comp_uv = true;
           else
             error('No value or a bad value given for option ''material''.');
           end
         case 'uvcoords'
           if ii<length(par) && isscalar(par{ii+1})
             ii = ii + 1;
             model.flags.comp_uv = par{ii};
             if ~model.flags.comp_uv
                uv_explicit_false = true;
             end
           else
             error('No value or a bad value given for option ''uvcoords''.');
           end
         case 'rms'
           if ii<length(par) && isscalar(par{ii+1})
             ii = ii + 1;
             model.flags.use_rms = par{ii};
           else
             error('No value or a bad value given for option ''rms''.');
           end
           %model.use_rms = true;
         case 'normals'
           if ii<length(par) && isscalar(par{ii+1})
             ii = ii + 1;
             model.flags.comp_normals = par{ii};
           else
             error('No value or a bad value given for option ''normals''.');
           end
         case 'save'
           if ii<length(par) && isscalar(par{ii+1})
             ii = ii + 1;
             model.flags.dosave = par{ii};
           else
             error('No value or a bad value given for option ''save''.');
           end
         case {'tube_radius','minor_radius'}
           if ~model.flags.new_model
              error('You cannot change the radius of an existing model.');
           end
           if ii<length(par) && isnumeric(par{ii+1})
             ii = ii + 1;
             model.tube_radius = par{ii};
           else
             error('No value or a bad value given for option ''tube_radius''.');
           end              
         case 'rpar'
           if ~model.flags.new_model
              error('You cannot change the radius of an existing model.');
           end
           if ii<length(par) && isnumeric(par{ii+1})
             ii = ii + 1;
             model.opts.rprm = par{ii};
           else
             error('No value or a bad value given for option ''radius''.');
           end
         case {'locations','loc'}
           if ii<length(par) && iscell(par{ii+1}) && length(par{ii+1})==2
             ii = ii + 1;
             model.opts.locations = par{ii};
             model.flags.custom_locations = true;
           else
             error('No value or a bad value given for option ''locations''.');
           end
         case 'rotate'
           if ii<length(par) && isnumeric(par{ii+1})
             ii = ii + 1;
             model.rotate = par{ii};
           else
             error('No value or a bad value given for option ''rotate''.');
           end
         case 'curve'
           if ~model.flags.new_model
              error('You cannot change the option ''curve'' in an existing model.');
           end
          if ii<length(par) && isnumeric(par{ii+1})
             ii = ii+1;
             model.curve = par{ii};
             model.curve = model.curve(:)';
          else
             error('No value or a bad value given for option ''curve''.');
          end
         case 'caps'
           if ii<length(par) && isscalar(par{ii+1})
             ii = ii + 1;
             model.flags.caps = par{ii};
           else
             error('No value or a bad value given for option ''caps''.');
           end
        otherwise
          model.filename = par{ii};
      end
    else
        
    end
    ii = ii + 1;
  end % while over par
end

% See comment above for explanation.
if uv_explicit_false
   model.flags.comp_uv = false;
end

% Add file name extension if needed
if isempty(regexp(model.filename,'\.obj$'))
  model.filename = [opts.filename,'.obj'];
end

% if ~model.flags.new_model
%   oldmodel.filename = model.filename;
%   oldmodel.mtlfilename = model.mtlfilename;
%   oldmodel.mtlname = model.mtlname;
%   oldmodel.flags = model.flags;
%   oldmodel.opts = model.opts;
%   model = oldmodel;
%   model.new_model = false;
%   model.normals = [];
% end

