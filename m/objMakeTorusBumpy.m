function torus = objMakeTorusBumpy(prm,varargin)

% OBJMAKETORUSBUMPY
%
% Usage: torus = objMakeTorusBumpy(prm,varargin)

% Copyright (C) 2015 Toni Saarela
% 2015-04-05 - ts - first version

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
filename = 'torusbumpy.obj';
mtlfilename = '';
mtlname = '';
mindist = 0;
tube_radius = 0.4;
radius = 1;
rprm = [];
m = 256;
n = 256;
comp_normals = false;
dosave = true;
new_model = true;

[tmp,par] = parseparams(varargin);
if ~isempty(par)
  ii = 1;
  while ii<=length(par)
    if ischar(par{ii})
      switch lower(par{ii})
        case 'mindist'
          if ii<length(par) && isnumeric(par{ii+1})
             ii = ii+1;
             mindist = par{ii};
          else
             error('No value or a bad value given for option ''mindist''.');
          end
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
    else
        
    end
    ii = ii + 1;
  end % while over par
end

if isempty(regexp(filename,'\.obj$'))
  filename = [filename,'.obj'];
end

%--------------------------------------------
% TODO:
% Throw an error if the asked minimum distance is a ridiculously large
% number.
%if mindist>
%  error('Yeah right.');
%end
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

    d = sqrt(wrapAnglePi(thetatmp*ones([1 nvec])-ones([nvec 1])*thetatmp').^2 + ...
         wrapAnglePi(  phitmp*ones([1 nvec])-ones([nvec 1])*phitmp'  ).^2);


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
    % See comment in objMakeCylinderCustom
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

vertices = [X Y Z];

if new_model
  torus.prm.prm = prm;
  torus.prm.bumptypes = nbumptypes;
  torus.prm.nbumps = nbumps;
  torus.prm.rprm = rprm;
  torus.prm.mfilename = mfilename;
  torus.normals = [];
else
  ii = length(torus.prm)+1;
  torus.prm(ii).prm = prm;
  torus.prm(ii).bumptypes = nbumptypes;
  torus.prm(ii).nbumps = nbumps;
  torus.prm(ii).rprm = rprm;
  torus.prm(ii).mfilename = mfilename;
  torus.normals = [];
end
torus.shape = 'torus';
torus.filename = filename;
torus.mtlfilename = mtlfilename;
torus.mtlname = mtlname;
torus.comp_normals = comp_normals;
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

