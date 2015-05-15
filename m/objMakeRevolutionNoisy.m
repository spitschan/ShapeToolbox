function solid = objMakeRevolutionNoisy(curve,nprm,varargin)

% OBJMAKEREVOLUTIONNOISY
%
% Usage: solid = objMakeRevolutionNoisy(curve,nprm,[OPTIONS])
%
% Note: if modifying an existing model, the first input argument (the
% curve) is ignored.  Just leave it empty.


% Copyright (C) 2015 Toni Saarela
% 2015-04-05 - ts - first version
% 2015-05-04 - ts - added uv-option without materials
%                   calls objParseArgs and objSaveModel
% 2015-05-14 - ts - improved setting default modulator parameters

%--------------------------------------------------

ncurve = length(curve);
opts.m = ncurve;
opts.n = ncurve;

if nargin<2 || isempty(nprm)
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

opts.filename = 'revolutionnoisy.obj';
opts.use_rms = false;

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
[opts,solid] = objParseArgs(opts,par);

%--------------------------------------------
% Vertices 

if opts.new_model
  m = opts.m;
  n = opts.n;

  r = 1; % radius
  h = 2*pi*r; % height
  theta = linspace(-pi,pi-2*pi/n,n); % azimuth
  y = linspace(-h/2,h/2,m); % 
  
  [Theta,Y] = meshgrid(theta,y);

  if ncurve~=m
    curve = interp1(linspace(0,1,ncurve),curve,linspace(0,1,m));
  end
  
  %R = r*repmat(curve(:)',[n 1])';
  R = r * repmat(curve(:),[1 n]);

else
  curve = solid.curve;
  m = solid.m;
  n = solid.n;
  Theta = reshape(solid.Theta,[n m])';
  Y = reshape(solid.Y,[n m])';
  R = reshape(solid.R,[n m])';
end

R = R + objMakeNoiseComponents(nprm,mprm,Theta,Y,opts.use_rms);

Theta = Theta'; Theta = Theta(:);
Y = Y'; Y = Y(:);
R = R'; R = R(:);

X =  R .* cos(Theta);
Z = -R .* sin(Theta);

vertices = [X Y Z];

if opts.new_model
  solid.prm.nprm = nprm;
  solid.prm.mprm = mprm;
  solid.prm.nncomp = nncomp;
  solid.prm.nmcomp = nmcomp;
  solid.prm.use_rms = opts.use_rms;
  solid.prm.mfilename = mfilename;
  solid.normals = [];
else
  ii = length(solid.prm)+1;
  solid.prm(ii).nprm = nprm;
  solid.prm(ii).mprm = mprm;
  solid.prm(ii).nncomp = nncomp;
  solid.prm(ii).nmcomp = nmcomp;
  solid.prm(ii).use_rms = opts.use_rms;
  solid.prm(ii).mfilename = mfilename;
  solid.normals = [];
end
solid.shape = 'revolution';
solid.filename = opts.filename;
solid.mtlfilename = opts.mtlfilename;
solid.mtlname = opts.mtlname;
solid.comp_uv = opts.comp_uv;
solid.comp_normals = opts.comp_normals;
solid.curve = curve;
solid.n = n;
solid.m = m;
solid.Theta = Theta;
solid.Y = Y;
solid.R = R;
solid.vertices = vertices;

if opts.dosave
  solid = objSaveModel(solid);
end

if ~nargout
   clear solid
end
