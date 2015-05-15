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
% 2015-04-30 - ts - "switched" y and z directions: reference plane is
%                    x-z, y is "up"
% 2015-05-04 - ts - added uv-option without materials
%                   calls objParseArgs and objSaveModel
% 2015-05-14 - ts - improved setting default parameters

% TODO
% Set input arguments, optional arguments, default values
% Include carriers and modulators?
% Write stimulus paremeters into the obj-file
% Write help!  UPDATE HELP

%--------------------------------------------

% Carrier parameters

% Set default frequency, amplitude, phase, "orientation"  and component group id

defprm = [8 .05 0 0 0];

if ~nargin || isempty(cprm)
  cprm = defprm;
end

[nccomp,ncol] = size(cprm);

% Fill in default carrier parameters if needed
if ncol<5
  defprm = ones(nccomp,1)*defprm;
  cprm(:,ncol+1:5) = defprm(:,ncol+1:5);
end
clear defprm

cprm(:,3:4) = pi * cprm(:,3:4)/180;

% Set the default modulation parameters to empty indicating no modulator; set default filename.
mprm  = [];
nmcomp = 0;

opts.filename = 'torus.obj';
opts.tube_radius = 0.4;
opts.radius = 1; %% not possible to change at the moment
opts.rprm = [];
opts.n = 256;
opts.m = 256;

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
[opts,torus] = objParseArgs(opts,par);

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

% Switch z- and y-coordinates so that the reference plane is the x-z
% plane and y is "up", for consistency across all functions.
vertices = [X Z -Y];

if opts.new_model
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

