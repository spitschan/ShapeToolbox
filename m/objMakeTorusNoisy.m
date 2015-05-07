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
% 2015-05-04 - ts - added uv-option without materials
%                   calls objParseArgs and objSaveModel

% TODO
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

opts.filename = 'torusnoisy.obj';
opts.use_rms = false;
opts.tube_radius = 0.4;
opts.radius = 1; %% not possible to change at the moment
opts.rprm = [];
opts.n = 256;
opts.m = 256;

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
      mprm = [mprm ones(nmcomp,1)*[1 0 0 0]];
    case 2
      mprm = [mprm zeros(nmcomp,3)];
    case 3
      mprm = [mprm zeros(nmcomp,2)];
    case 4
      mprm = [mprm zeros(nmcomp,1)];
  end
  mprm(:,3:4) = pi * mprm(:,3:4)/180;
end

% Check other optional input arguments
[opts,torus] = objParseArgs(opts,par);
  
% Add file name extension if needed
if isempty(regexp(opts.filename,'\.obj$'))
  opts.filename = [opts.filename,'.obj'];
end

rprm = opts.rprm;

%--------------------------------------------

if opts.new_model
  m = opts.m;
  n = opts.n;
  radius = opts.radius;
  tube_radius = opts.tube_radius;

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
  r = r + objMakeNoiseComponents(nprm,mprm,Theta,Phi,opts.use_rms);
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

if opts.new_model
  torus.prm.nprm = nprm;
  torus.prm.mprm = mprm;
  torus.prm.nncomp = nncomp;
  torus.prm.nmcomp = nmcomp;
  torus.prm.rprm = rprm;
  torus.prm.use_rms = opts.use_rms;
  torus.prm.mfilename = mfilename;
  torus.normals = [];
else
  ii = length(torus.prm)+1;
  torus.prm(ii).nprm = nprm;
  torus.prm(ii).mprm = mprm;
  torus.prm(ii).nncomp = nncomp;
  torus.prm(ii).nmcomp = nmcomp;
  torus.prm(ii).rprm = rprm;
  torus.prm(ii).use_rms = opts.use_rms;
  torus.prm(ii).mfilename = mfilename;
  torus.normals = [];
end
torus.shape = 'torus';
torus.filename = opts.filename;
torus.mtlfilename = opts.mtlfilename;
torus.mtlname = opts.mtlname;
torus.comp_uv = opts.comp_uv;
torus.comp_normals = opts.comp_normals;
torus.radius = radius;
torus.tube_radius = tube_radius;
torus.n = n;
torus.m = m;
torus.Theta = Theta;
torus.Phi = Phi;
torus.R = R;
torus.r = r;
torus.vertices = vertices;

if opts.dosave
  torus = objSaveModel(torus);
end

if ~nargout
   clear torus
end

