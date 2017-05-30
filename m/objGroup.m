function [model,groups] = objGroup(model,groups,names,materials)

% OBJGROUP
%
% Usage: model = objGroup(model,groups,[names],[materials])
%        [model,groups] = objGroup(...)
%
% Define face group indices or names, as well as (optionally) material
% names for those groups.  Assigning faces of the model to different
% groups allows one to define different material properties to
% different parts of an object (as an alternative to texture mapping).  
%
% INPUTS
% ------
% model     - a model made with one of the objMake*-functions 
% groups    - a matrix of integers that gives a 'map' of the groups
% names     - names of the groups (optional)
% materials - material names for the groups (optional)
%
% The matrix 'groups' defines a map of the face groups.  There will be
% as many groups as there are unique integers in this matrix.  If this
% matrix does not match in size to the number of faces in the model,
% it will be scaled.  At its simplest, the matrix might be [0 1], in
% which case there would be two face groups with indices 0 and 1.
%
% See the online help for more information and examples.
  
% Copyright (C) 2016, 2017 Toni Saarela
% 2016-05-27 - ts - first version
% 2016-05-28 - ts - handles all shapes (first version did only spheres
%                    et al.)
% 2016-05-28 - ts - renamed from objVertexGroups to objGroup because
%                    this thing has absolutely nothing to do with
%                    vertex groups
% 2016-06-30 - ts - fixed a bug with checking group matrix size for tori
% 2016-09-23 - ts - wrote help
% 2016-11-04 - ts - added the above comment
% 2017-05-26 - ts - help
  
[m,n] = size(groups);

switch model.shape
  case {'sphere','cylinder','revolution','extrusion','worm'}
    if m~=(2*(model.m-1)) || n~=model.n
      groups = expmat(groups,ceil([2*(model.m-1)/m model.n/n]));
      groups = groups(1:(2*(model.m-1)),1:model.n);
      % groups = interp2(linspace(0,1,n),...
      %                  linspace(0,1,m)',...
      %                  groups,...
      %                  linspace(0,1,model.n),...
      %                  linspace(0,1,2*(model.m-1))',...
      %                  'nearest');
    end
  case {'plane','disk'}
    if m~=(2*(model.m-1)) || n~=(2*(model.n-1))
      groups = expmat(groups,ceil([2*(model.m-1)/m (model.n-1)/n]));
      groups = groups(1:(2*(model.m-1)),1:(model.n-1));
      % groups = interp2(linspace(0,1,n),...
      %                  linspace(0,1,m)',...
      %                  groups,...
      %                  linspace(0,1,model.n-1),...
      %                  linspace(0,1,2*(model.m-1))',...
      %                  'nearest');
    end
  case 'torus'
    if m~=(2*model.m) || n~=model.n
      groups = expmat(groups,ceil([2*model.m/m model.n/n]));
      groups = groups(1:(2*model.m),1:model.n);
      % groups = interp2(linspace(0,1,n),...
      %                  linspace(0,1,m)',...
      %                  groups,...
      %                  linspace(0,1,model.n),...
      %                  linspace(0,1,2*model.m)',...
      %                  'nearest');
    end
  % otherwise
  %   error('Groups not yet implemented for shape %s.\n',model.shape);
end

model.group.groups = groups';
model.group.groups = model.group.groups(:);
model.group.idx = unique(groups);
ngroups = length(model.group.idx);

if nargin<3 || isempty(names)
   model.group.names = {};
   for ii = 1:ngroups
       model.group.names{ii} = sprintf('group%d',model.group.idx(ii));
   end
else
  model.group.names = names;
end

if nargin<4 || isempty(materials)
  model.group.materials = {};
else
  model.group.materials = materials;
end

model.flags.write_groups = true;

if nargout<2
   clear groups
end

%------------------------------------------------------------
% Functions

function X = expmat(X,expfac)

% EXPMAT

% Copyright (C) 2006, 2009, 2016 Toni Saarela

[m,n] = size(X);

X = [X(:) * ones(1,expfac(1))]';
X = reshape(X,m*expfac(1),n);

X = X';

[m,n] = size(X);

X = [X(:) * ones(1,expfac(2))]';
X = reshape(X,m*expfac(2),n);

X = X';
