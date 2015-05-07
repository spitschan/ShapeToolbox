function torus = objMakeTorusBumpy(prm,varargin)

% OBJMAKETORUSBUMPY
%
% Usage: torus = objMakeTorusBumpy(prm,varargin)

% Copyright (C) 2015 Toni Saarela
% 2015-04-05 - ts - first version
% 2015-04-30 - ts - "switched" y and z directions: reference plane is
%                    x-z, y is "up"
% 2015-05-04 - ts - added uv-option without materials
%                   calls objParseArgs and objSaveModel


%--------------------------------------------

if ~nargin || isempty(prm)
  prm = [20 .1 pi/24];
end

[nbumptypes,ncol] = size(prm);

switch ncol
  case 1
    prm = [prm ones(nccomp,1)*[.05 pi/12]];
  case 2
    prm = [prm ones(nccomp,1)*pi/12];
end

nbumps = sum(prm(:,1));

% Set default values before parsing the optional input arguments.
opts.filename = 'torusbumpy.obj';
opts.tube_radius = 0.4;
opts.radius = 1; %% not possible to change at the moment
opts.rprm = [];
opts.n = 256;
opts.m = 256;
opts.mindist = 0;

[tmp,par] = parseparams(varargin);

% Check other optional input arguments
[opts,torus] = objParseArgs(opts,par);
  
% Add file name extension if needed
if isempty(regexp(opts.filename,'\.obj$'))
  opts.filename = [opts.filename,'.obj'];
end

mindist = opts.mindist;
rprm = opts.rprm;


%--------------------------------------------
% TODO:
% Throw an error if the asked minimum distance is a ridiculously large
% number.
%if mindist>
%  error('Yeah right.');
%end
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

  theta = linspace(-pi,pi-2*pi/n,n);
  phi = linspace(-pi,pi-2*pi/m,m); 

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

for jj = 1:nbumptypes
    
  if mindist
     
    % Pick candidate locations (more than needed):
    nvec = 30*prm(jj,1);
    thetatmp = min(theta) + rand([nvec 1])*(max(theta)-min(theta));
    phitmp = min(phi) + rand([nvec 1])*(max(phi)-min(phi));
    
    %d = sqrt((thetatmp*ones([1 nvec])-ones([nvec 1])*thetatmp').^2 + ...
    %         (phitmp*ones([1 nvec])-ones([nvec 1])*phitmp').^2);

    %d = sqrt(wrapAnglePi(thetatmp*ones([1 nvec])-ones([nvec 1])*thetatmp').^2 + ...
    %     wrapAnglePi(  phitmp*ones([1 nvec])-ones([nvec 1])*phitmp'  ).^2);

    deltatheta = wrapAnglePi(thetatmp*ones([1 nvec])-ones([nvec 1])*thetatmp');
    deltaphi   = wrapAnglePi(  phitmp*ones([1 nvec])-ones([nvec 1])*phitmp'  );

    %HERE
    %disttheta = 
    %d = sqrt(.^2 + ...
    %     .^2);


    % Always accept the first vector
    idx_accepted = [1];
    n_accepted = 1;
    % Loop over the remaining candidate vectors and keep the ones that
    % are at least the minimum distance away from those already
    % accepted.
    idx = 2;
    while idx <= size(thetatmp,1)
      if all(d(idx_accepted,idx)>=mindist)
         idx_accepted = [idx_accepted idx];
         n_accepted = n_accepted + 1;
      end
      if n_accepted==prm(jj,1)
        break
      end
      idx = idx + 1;
    end

    if n_accepted<prm(jj,1)
       error(sprintf('Could not find enough vectors to satisfy the minumum distance criterion.\nConsider reducing the value of ''mindist''.'));
    end

    theta0 = thetatmp(idx_accepted,:);
    phi0 = phitmp(idx_accepted,:);

  else
    %- pick n random locations
    theta0 = min(theta) + rand([prm(jj,1) 1])*(max(theta)-min(theta));
    phi0 = min(phi) + rand([prm(jj,1) 1])*(max(phi)-min(phi));

  end
    
  clear thetatmp phitmp

  %-------------------
    
  for ii = 1:prm(jj,1)
    % Note that this is a total hack.  The spread of the bumps is in
    % units of the theta angle, the angle around the torus.  Convert
    % that to distance along the surface in that direction.  Then
    % compute the distance on the surface in the phi-direction, the
    % direction around the tube of the torus.  Use those to compute
    % total distance.  NOTE: This is not the correct way to do it.
    % Computing actual distance on the surface of a torus requires
    % more (using calculus of variations).  This is a very crude
    % approximation that only works reasonably well at short
    % distances, that is, with small bumps.

    % Get the angular difference for theta (azimuth direction)
    deltatheta = abs(wrapAnglePi(Theta - theta0(ii)));
    % Compute the distance in that direction.  Note this depends on
    % the angle around the tube of the torus.
    disttheta = deltatheta * (radius+tube_radius*cos(phi0(ii)));
    
    % Angular difference for phi, this is the angle around the tube.
    deltaphi = abs(wrapAnglePi(Phi - phi0(ii)));
    % Distance.  We're computing in distance not angle so that the
    % bumps are symmetric.
    distphi = deltaphi * tube_radius;

    %d = sqrt(deltatheta.^2+deltaphi.^2);
    d = sqrt(disttheta.^2+distphi.^2);

    idx = find(d<3.5*prm(jj,3));
    r(idx) = r(idx) + prm(jj,2)*exp(-d(idx).^2/(2*prm(jj,3)^2));      
    
  end
  
end

X = (R + r.*cos(Phi)).*cos(Theta);
Y = (R + r.*cos(Phi)).*sin(Theta);
Z = r.*sin(Phi);

% Switch z- and y-coordinates so that the reference plane is the x-z
% plane and y is "up", for consistency across all functions.
vertices = [X Z -Y];

if opts.new_model
  torus.prm.prm = prm;
  torus.prm.bumptypes = nbumptypes;
  torus.prm.nbumps = nbumps;
  torus.prm.mindist = mindist;
  torus.prm.rprm = rprm;
  torus.prm.mfilename = mfilename;
  torus.normals = [];
else
  ii = length(torus.prm)+1;
  torus.prm(ii).prm = prm;
  torus.prm(ii).bumptypes = nbumptypes;
  torus.prm(ii).nbumps = nbumps;
  torus.prm(ii).mindist = mindist;
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

%----------------------------------------------------

function theta = wrapAnglePi(theta)

% WRAPANGLEPI
%
% Usage: theta = wrapAnglePi(theta)

% Toni Saarela, 2010
% 2010-xx-xx - ts - first version

theta = rem(theta,2*pi);
theta(theta>pi) = -2*pi+theta(theta>pi);
theta(theta<-pi) = 2*pi+theta(theta<-pi);
%theta(X==0 & Y==0) = 0;

