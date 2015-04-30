function torus = objMakeTorusNoisy(nprm,varargin)

% OBJMAKETORUSNOISY
%
% Usage: torus = objMakeTorusNoisy(nprm,...)


% Toni Saarela, 2014
% 2014-10-16 - ts - first version written
% 2014-10-19 - ts - added an option to set tube radius
%                   renamed input option for torus radius parameters
% 2015-03-05 - ts - updated function call to objMakeNoiseComponents
% 2015-04-04 - ts - calls the new objSaveModelTorus-function to
%                    compute faces, normals, etc and save the model to a file
%                   saving the model is optional, an existing model
%                     can be updated, bunch of other minor improvements
% 2015-04-30 - ts - "switched" y and z directions: reference plane is
%                    x-z, y is "up"

% TODO
% Write stimulus paremeters into the obj-file
% WRITE HELP!  

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

% Set the default modulation parameters to empty indicating no modulator; set default filename.
mprm  = [];
nmcomp = 0;
filename = 'torusnoisy.obj';
use_rms = false;
mtlfilename = '';
mtlname = '';
tube_radius = 0.4;
radius = 1;
rprm = [];
comp_normals = false;
dosave = true;
new_model = true;

% Number of vertices in y and x directions, default values
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
      mprm = [mprm ones(nccomp,1)*[1 0 0 0]];
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
         case 'tube_radius'
           if ii<length(par) && isnumeric(par{ii+1})
             ii = ii + 1;
             tube_radius = par{ii};
           else
             error('No value or a bad value given for option ''tube_radius''.');
           end              
         case {'rprm','radius_prm'}
           if ii<length(par) && isnumeric(par{ii+1})
             ii = ii + 1;
             rprm = par{ii};
           else
             error('No value or a bad value given for option ''radius''.');
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
           if ii<length(par) && isscalar(par{ii+1})
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
             torus = par{ii};
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
  theta = linspace(-pi,pi-2*pi/n,n);
  phi = linspace(-pi,pi-2*pi/m,m); 
  [Theta,Phi] = meshgrid(theta,phi);
  R = radius*ones(size(Theta));
  r = tube_radius*ones(size(Theta));
else
  n = torus.n;
  m = torus.m;
  radius = torus.radius;
  tube_radius = torus.tube_radius;
  Theta = reshape(torus.Theta,[n m])';
  Phi = reshape(torus.Phi,[n m])';
  R = reshape(torus.R,[n m])';
  r = reshape(torus.r,[n m])';
end

if ~isempty(rprm)
  Rmod = zeros(size(Theta));
  for ii = 1:size(rprm,1)
    Rmod = Rmod + rprm(ii,2) * sin(rprm(ii,1)*Theta + rprm(ii,3));
  end
  R = R + Rmod;
end

if ~isempty(nprm)
  r = r + objMakeNoiseComponents(nprm,mprm,Theta,Phi,use_rms);
end

Theta = Theta'; Theta = Theta(:);
Phi   = Phi';   Phi   = Phi(:);
R = R'; R = R(:);
r = r'; r = r(:);

X = (R + r.*cos(Phi)).*cos(Theta);
Y = (R + r.*cos(Phi)).*sin(Theta);
Z = r.*sin(Phi);

% Switch z- and y-coordinates so that the reference plane is the x-z
% plane and y is "up", for consistency across all functions.
vertices = [X Z -Y];

if new_model
  torus.prm.nprm = nprm;
  torus.prm.mprm = mprm;
  torus.prm.nncomp = nncomp;
  torus.prm.nmcomp = nmcomp;
  torus.prm.rprm = rprm;
  torus.prm.use_rms = use_rms;
  torus.prm.mfilename = mfilename;
  torus.normals = [];
else
  ii = length(torus.prm)+1;
  torus.prm(ii).nprm = nprm;
  torus.prm(ii).mprm = mprm;
  torus.prm(ii).nncomp = nncomp;
  torus.prm(ii).nmcomp = nmcomp;
  torus.prm(ii).rprm = rprm;
  torus.prm(ii).use_rms = use_rms;
  torus.prm(ii).mfilename = mfilename;
  torus.normals = [];
end
torus.shape = 'torus';
torus.filename = filename;
torus.mtlfilename = mtlfilename;
torus.mtlname = mtlname;
torus.comp_normals = comp_normals;
torus.radius = radius;
torus.tube_radius = tube_radius;
torus.n = n;
torus.m = m;
torus.Theta = Theta;
torus.Phi = Phi;
torus.R = R;
torus.r = r;
torus.vertices = vertices;

if dosave
  torus = objSaveModelTorus(torus);
end

if ~nargout
   clear torus
end

