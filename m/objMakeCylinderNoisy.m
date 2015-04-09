function cylinder = objMakeCylinderNoisy(nprm,varargin)

% OBJMAKECYLINDERNOISY
%
% Usage: cylinder = objMakeCylinderNoisy(...)

% Copyright (C) 2014, 2015 Toni Saarela
% 2014-10-15 - ts - first version written
% 2015-04-03 - ts - calls the new objSaveModelCylinder-function to
%                    compute faces, normals, etc and save the model to a file
%                   saving the model is optional, an existing model
%                     can be updated, many other improvements

%--------------------------------------------------

if ~nargin || isempty(nprm)
  nprm = [8 1 0 45 .1 0];
end

[nncomp,ncol] = size(nprm);

if ncol==5
  nprm = [nprm zeros(nncomp,1)];
elseif ncol<5
  error('Incorrect number of columns in input argument ''nprm''.');
end

nprm(:,3:4) = pi * nprm(:,3:4)/180;

% Set the default modulation parameters to empty indicating no
% modulator; set default filename, material...
mprm  = [];
nmcomp = 0;
filename = 'cylindernoisy.obj';
use_rms = false;
mtlfilename = '';
mtlname = '';
comp_normals = false;
dosave = true;
new_model = true;

% Number of vertices in the two directions, default values
m = 256;
n = 256;

[modpar,par] = parseparams(varargin);

% If modulator parameters are given as input, set mprm to these values
if ~isempty(modpar)
   mprm = modpar{1};
end

% Set default values to modulator parameters as needed
if ~isempty(mprm)
  [nmcomp,ncol] = size(mprm);
  switch ncol
    case 1
      mprm = [mprm ones(nccomp,1)*[.1 0 0 0]];
    case 2
      mprm = [mprm zeros(nccomp,3)];
    case 3
      mprm = [mprm zeros(nccomp,2)];
    case 4
      mprm = [mprm zeros(nccomp,1)];
  end
  mprm(:,3:4) = pi * mprm(:,3:4)/180;
end

if ~isempty(par)
   ii = 1;
   while ii<=length(par)
     if ischar(par{ii})
       switch lower(par{ii})
         case 'npoints'
           if ii<length(par) && isnumeric(par{ii+1}) && length(par{ii+1}(:))==2
             ii = ii + 1;
             m = par{ii}(1);
             n = par{ii}(2);
           else
             error('No value or a bad value given for option ''npoints''.');
           end
         case 'material'
           if ii<length(par) && iscell(par{ii+1}) && length(par{ii+1})==2
             ii = ii + 1;
             mtlfilename = par{ii}{1};
             mtlname = par{ii}{2};
           else
             error('No value or a bad value given for option ''material''.');
           end
         case 'rms'
           use_rms = true;
         case 'normals'
           if ii<length(par) && (isnumeric(par{ii+1}) || islogical(par{ii+1}))
             ii = ii + 1;
             comp_normals = par{ii};
           else
             error('No value or a bad value given for option ''normals''.');
           end
         case 'save'
           if ii<length(par) && isscalar(par{ii+1})
             ii = ii + 1;
             dosave = par{ii};
           else
             error('No value or a bad value given for option ''save''.');
           end              
         case 'model'
           if ii<length(par) && isstruct(par{ii+1})
             ii = ii + 1;
             cylinder = par{ii};
             new_model = false;
           else
             error('No value or a bad value given for option ''model''.');
           end
         otherwise
           filename = par{ii};
       end
     end
     ii = ii + 1;
   end
end
  
% Add file name extension if needed
if isempty(regexp(filename,'\.obj$'))
  filename = [filename,'.obj'];
end

%--------------------------------------------

if new_model
  r = 1; % radius
  h = 2*pi*r; % height
  theta = linspace(-pi,pi-2*pi/n,n); % azimuth
  y = linspace(-h/2,h/2,m); % 
  
  [Theta,Y] = meshgrid(theta,y);
else
  Theta = cylinder.Theta;
  Y = cylinder.Y;
  r = cylinder.R;
  m = cylinder.m;
  n = cylinder.n;
  Theta = reshape(Theta,[n m])';
  Y = reshape(Y,[n m])';
  r = reshape(r,[n m])';
end

R = r + objMakeNoiseComponents(nprm,mprm,Theta,Y,use_rms);

Theta = Theta'; Theta = Theta(:);
Y = Y'; Y = Y(:);
R = R'; R = R(:);

% Convert vertices to cartesian coordinates
X = R .* cos(Theta);
Z = -R .* sin(Theta);

vertices = [X Y Z];

if new_model
  cylinder.prm.nprm = nprm;
  cylinder.prm.mprm = mprm;
  cylinder.prm.nncomp = nncomp;
  cylinder.prm.nmcomp = nmcomp;
  cylinder.prm.use_rms = use_rms;
  cylinder.prm.mfilename = mfilename;
  cylinder.normals = [];
else
  ii = length(cylinder.prm)+1;
  cylinder.prm(ii).nprm = nprm;
  cylinder.prm(ii).mprm = mprm;
  cylinder.prm(ii).nncomp = nncomp;
  cylinder.prm(ii).nmcomp = nmcomp;
  cylinder.prm(ii).use_rms = use_rms;
  cylinder.prm(ii).mfilename = mfilename;
  cylinder.normals = [];
end
cylinder.shape = 'cylinder';
cylinder.filename = filename;
cylinder.mtlfilename = mtlfilename;
cylinder.mtlname = mtlname;
cylinder.comp_normals = comp_normals;
cylinder.n = n;
cylinder.m = m;
cylinder.Theta = Theta;
cylinder.Y = Y;
cylinder.R = R;
cylinder.vertices = vertices;

if dosave
  cylinder = objSaveModelCylinder(cylinder);
end

if ~nargout
   clear cylinder
end

