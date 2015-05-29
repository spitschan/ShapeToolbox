function solid = objMakeExtrusion(curve,cprm,varargin)

% OBJMAKEEXTRUSION
%
% Usage: solid = objMakeExtrusion(curve,[options])

% Copyright (C) 2015 Toni Saarela
% 2015-05-18 - ts - first version

% TODO:
% - add a modulation in y-direction (basically surface of revolution
%   multiplying the extrusion)
% - add all the usual modulation options
% - add closure option
% - change how rotation is done.  First make a matrix (with circshift)
%   that has an integer number of rotations.  Then interpolate in 2D
%   the desired number of turns.  This might help to preserve shapr
%   edges better.

opts.new_model = true;

curve = curve(:)';
ncurve = length(curve);
opts.m = ncurve;
opts.n = ncurve;
opts.rotate = 0;

defprm = [0 0 0 0 0];

if nargin<2 || isempty (cprm)
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

% set default filename and other stuff
mprm  = [];
nmcomp = 0;

opts.filename = 'extrusion.obj';

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

  if ~opts.rotate
    R = repmat(curve,[m 1]);
  else
    fprintf('\nWARNING: The rotation option is experimental and works\n');
    fprintf('\n         well only for n_rotations=1.\n');
    shifts = opts.n * linspace(0,opts.rotate-opts.rotate/opts.m,opts.m);
    for ii = 1:opts.m
      R(ii,:) = circshiftinterp(curve,shifts(ii));
      %R(ii,:) = circshift(curve,[0 (ii-1)]);
    end
  end

  Theta = Theta'; Theta = Theta(:);
  Y = Y'; Y = Y(:);
  R = R'; R = R(:);
else
  m = solid.m;
  n = solid.n;
  Theta = solid.Theta;
  Y = solid.Y;
  R = solid.R;
end

R = R + objMakeSineComponents(cprm,mprm,Theta,Y);

% Convert vertices to cartesian coordinates
X =  R .* cos(Theta);
Z = -R .* sin(Theta);

vertices = [X Y Z];

if opts.new_model
  solid.prm.cprm = cprm;
  solid.prm.mprm = mprm;
  solid.prm.nccomp = nccomp;
  solid.prm.nmcomp = nmcomp;
  solid.prm.mfilename = mfilename;
  solid.normals = [];
else
  ii = length(solid.prm)+1;
  solid.prm(ii).cprm = cprm;
  solid.prm(ii).mprm = mprm;
  solid.prm(ii).nccomp = nccomp;
  solid.prm(ii).nmcomp = nmcomp;
  solid.prm(ii).mfilename = mfilename;
  solid.normals = [];
end
solid.shape = 'extrusion';
solid.filename = opts.filename;
solid.mtlfilename = opts.mtlfilename;
solid.mtlname = opts.mtlname;
solid.comp_uv = opts.comp_uv;
solid.comp_normals = opts.comp_normals;
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

%------------------------------------------------------------

function x = circshiftinterp(x,n)

% CIRCSHIFTINTERP
%
% x = circshiftinterp(x,n)

% Copyright (C) 2015 Toni Saarela
% 2015-05-21 - ts - first version

x = x(:)';

nfrac = rem(n,1);
n = fix(n);

x = circshift(x,[0 n]);

if nfrac
   y1 = 0:length(x);
   y2 = (0:(length(x)-1)) + nfrac;
   x = interp1(y1,[x x(1)],y2);
end

