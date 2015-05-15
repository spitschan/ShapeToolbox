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
% 2015-05-04 - ts - added uv-option without materials
%                   calls objParseArgs and objSaveModel
% 2015-05-14 - ts - improved setting default modulator parameters

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

opts.filename = 'cylindernoisy.obj';
opts.use_rms = false;
opts.m = 256; 
opts.n = 256;

[modpar,par] = parseparams(varargin);

% If modulator parameters are given as input, set mprm to these values
if ~isempty(modpar)
  mprm = modpar{1};
  % Set default values to modulator parameters as needed
  [nmcomp,ncol] = size(mprm);
  if ncol<5
    defprm = ones(nmcomp,1)*[1 0 0 0];
    mprm(:,ncol+1:5) = defprm(:,ncol:4);
    clear defprm
  end
  mprm(:,3:4) = pi * mprm(:,3:4)/180;
end

% Check other optional input arguments
[opts,cylinder] = objParseArgs(opts,par);

%--------------------------------------------

if opts.new_model
  m = opts.m;
  n = opts.n;

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

R = r + objMakeNoiseComponents(nprm,mprm,Theta,Y,opts.use_rms);

Theta = Theta'; Theta = Theta(:);
Y = Y'; Y = Y(:);
R = R'; R = R(:);

% Convert vertices to cartesian coordinates
X = R .* cos(Theta);
Z = -R .* sin(Theta);

vertices = [X Y Z];

if opts.new_model
  cylinder.prm.nprm = nprm;
  cylinder.prm.mprm = mprm;
  cylinder.prm.nncomp = nncomp;
  cylinder.prm.nmcomp = nmcomp;
  cylinder.prm.use_rms = opts.use_rms;
  cylinder.prm.mfilename = mfilename;
  cylinder.normals = [];
else
  ii = length(cylinder.prm)+1;
  cylinder.prm(ii).nprm = nprm;
  cylinder.prm(ii).mprm = mprm;
  cylinder.prm(ii).nncomp = nncomp;
  cylinder.prm(ii).nmcomp = nmcomp;
  cylinder.prm(ii).use_rms = opts.use_rms;
  cylinder.prm(ii).mfilename = mfilename;
  cylinder.normals = [];
end
cylinder.shape = 'cylinder';
cylinder.filename = opts.filename;
cylinder.mtlfilename = opts.mtlfilename;
cylinder.mtlname = opts.mtlname;
cylinder.comp_uv = opts.comp_uv;
cylinder.comp_normals = opts.comp_normals;
cylinder.n = n;
cylinder.m = m;
cylinder.Theta = Theta;
cylinder.Y = Y;
cylinder.R = R;
cylinder.vertices = vertices;

if opts.dosave
  cylinder = objSaveModel(cylinder);
end

if ~nargout
   clear cylinder
end

