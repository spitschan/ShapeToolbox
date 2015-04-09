function torus = objMakeTorus(cprm,varargin)

% OBJMAKETORUS
%
% 
% r     - radius of the "tube"
% sprm  - modulation parameters for the radius of the tube:
%         [frequency amplitude phase direction], where
%          frequecy  : in number of cycles per 2*pi
%          amplitude : in units of the radius
%          phase     : in radians
%          direction : see below
% R     - radius of the torus, i.e., the distance from origin to the
%         center of the "tube"
% rprm  - modulation parameters for the radius of the torus:
%         [frequency amplitude phase], where
%          frequecy is in number of cycles per 2*pi
%          amplitude is in units of the radius
%          phase is in radians
%

% Copyright (C) 2014, 2015 Toni Saarela
% 2014-08-08 - ts - first, rudimentary version
% 2014-10-07 - ts - new format of parameter vectors
%                   renamed some variables, added input arguments
%                   allow several component modulations
% 2014-10-08 - ts - improved the computation of the faces ("wraps
%                   around" in both directions now)
% 2014-10-15 - ts - changed the order of input arguments
% 2014-10-16 - ts - changed input arguments again, added some parsing
%                    of them
%                   uses a separate function now to compute modulation
%                    components
%                   added texture mapping
% 2014-10-19 - ts - added tube radius as optional input arg,
%                   better input argument parsing
%                   renamed input option for torus radius parameters
% 2015-03-05 - ts - updated function call to objMakeSineComponents
% 2015-04-04 - ts - calls the new objSaveModelTorus-function to
%                    compute faces, normals, etc and save the model to a file
%                   saving the model is optional, an existing model
%                     can be updated, bunch of other minor improvements


% TODO
% Set input arguments, optional arguments, default values
% Include carriers and modulators?
% Write stimulus paremeters into the obj-file
% Write help!  UPDATE HELP

%--------------------------------------------

% Carrier parameters

% Set default frequency, amplitude, phase, "orientation"  and component group id

if ~nargin || isempty(cprm)
  cprm = [8 .05 0 0 0];
end

[nccomp,ncol] = size(cprm);

switch ncol
  case 1
    cprm = [cprm ones(nccomp,1)*[.05 0 0 0]];
  case 2
    cprm = [cprm zeros(nccomp,3)];
  case 3
    cprm = [cprm zeros(nccomp,2)];
  case 4
    cprm = [cprm zeros(nccomp,1)];
end

cprm(:,3:4) = pi * cprm(:,3:4)/180;

% Set the default modulation parameters to empty indicating no modulator; set default filename.
mprm  = [];
nmcomp = 0;
filename = 'torus.obj';
mtlfilename = '';
mtlname = '';
tube_radius = 0.4;
radius = 1;
rprm = [];
comp_normals = false;
dosave = true;
new_model = true;

% Number of vertices in azimuth and elevation directions, default values
n = 256;
m = 256;

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

% Check other optional input arguments
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
  Theta = Theta'; Theta = Theta(:);
  Phi   = Phi';   Phi   = Phi(:);
  R = radius*ones(size(Theta));
  r = tube_radius*ones(size(Theta));
else
  n = torus.n;
  m = torus.m;
  radius = torus.radius;
  tube_radius = torus.tube_radius;
  Theta = torus.Theta;
  Phi = torus.Phi;
  R = torus.R;
  r = torus.r;
end

if ~isempty(rprm)
  Rmod = zeros(size(Theta));
  for ii = 1:size(rprm,1)
    Rmod = Rmod + rprm(ii,2) * sin(rprm(ii,1)*Theta + rprm(ii,3));
  end
  R = R + Rmod;
end

if ~isempty(cprm)
  r = r + objMakeSineComponents(cprm,mprm,Theta,Phi);
end

X = (R + r.*cos(Phi)).*cos(Theta);
Y = (R + r.*cos(Phi)).*sin(Theta);
Z = r.*sin(Phi);

vertices = [X Y Z];

if new_model
  torus.prm.cprm = cprm;
  torus.prm.mprm = mprm;
  torus.prm.nccomp = nccomp;
  torus.prm.nmcomp = nmcomp;
  torus.prm.rprm = rprm;
  torus.prm.mfilename = mfilename;
  torus.normals = [];
else
  ii = length(torus.prm)+1;
  torus.prm(ii).cprm = cprm;
  torus.prm(ii).mprm = mprm;
  torus.prm(ii).nccomp = nccomp;
  torus.prm(ii).nmcomp = nmcomp;
  torus.prm(ii).rprm = rprm;
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

