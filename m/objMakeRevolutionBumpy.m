function solid = objMakeRevolutionBumpy(curve,prm,varargin)

% OBJMAKEREVOLUTIONBUMPY
%

% Copyright (C) 2015 Toni Saarela
% 2015-05-14 - ts - first version

ncurve = length(curve);
opts.m = ncurve;
opts.n = ncurve;

if nargin<2 || isempty (prm)
  prm = [20 .1 pi/12];
end

[nbumptypes,ncol] = size(prm);

switch ncol
  case 1
    prm = [prm ones(nccomp,1)*[.1 pi/12]];
  case 2
    prm = [prm ones(nccomp,1)*pi/12];
end

nbumps = sum(prm(:,1));

% set default filename and other stuff
opts.filename = 'revolutionbumpy.obj';
opts.m = 256;
opts.n = 256;
opts.mindist = 0;
opts.locations = {};

[tmp,par] = parseparams(varargin);

% Check other optional input arguments
[opts,solid] = objParseArgs(opts,par);

if isscalar(opts.mindist)
   opts.mindist = ones(1,nbumptypes) * opts.mindist;
elseif length(opts.mindist)~=nbumptypes
  error('Incorrect number of minimum distances defined.');
end

mindist = opts.mindist;

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
  Theta = Theta'; Theta = Theta(:);
  Y = Y'; Y = Y(:);

  if ncurve~=m
    curve = interp1(linspace(0,1,ncurve),curve,linspace(0,1,m));
  end
  
  R = r*repmat(curve(:)',[n 1]);
  R = R(:);

else
  curve = solid.curve;
  m = solid.m;
  n = solid.n;

  r = 1; % radius
  h = 2*pi*r; % height
  theta = linspace(-pi,pi-2*pi/n,n); % azimuth
  y = linspace(-h/2,h/2,m); % 

  Theta = solid.Theta;
  Y = solid.Y;
  R = solid.R;
end

for jj = 1:nbumptypes
    
  if ~isempty(opts.locations) && ~isempty(opts.locations{1}{jj})

     theta0 = opts.locations{1}{jj};
     y0 = opts.locations{2}{jj};

  elseif mindist(jj)
     
    % Pick candidate locations (more than needed):
    nvec = 30*prm(jj,1);
    thetatmp = min(theta) + rand([nvec 1])*(max(theta)-min(theta));
    ytmp = min(y) + rand([nvec 1])*(max(y)-min(y));

    %d = sqrt((thetatmp*ones([1 nvec])-ones([nvec 1])*thetatmp').^2 + ...
    %         (ytmp*ones([1 nvec])-ones([nvec 1])*ytmp').^2);
    
    d = sqrt(wrapAnglePi(thetatmp*ones([1 nvec])-ones([nvec 1])*thetatmp').^2 + ...
             (ytmp*ones([1 nvec])-ones([nvec 1])*ytmp').^2);

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
    y0 = ytmp(idx_accepted,:);

    clear thetatmp ytmp

    % For saving the locations in the model structure
    opts.locations{1}{jj} = theta0;
    opts.locations{2}{jj} = y0;

  else
    %- pick n random locations
    theta0 = min(theta) + rand([prm(jj,1) 1])*(max(theta)-min(theta));
    y0 = min(y) + rand([prm(jj,1) 1])*(max(y)-min(y));

    % For saving the locations in the model structure
    opts.locations{1}{jj} = theta0;
    opts.locations{2}{jj} = y0;

  end
    
  %-------------------
    
  for ii = 1:prm(jj,1)
    deltatheta = abs(wrapAnglePi(Theta - theta0(ii)));
    deltay = Y - y0(ii);
    d = sqrt(deltatheta.^2+deltay.^2);
    
    idx = find(d<3.5*prm(jj,3));
    R(idx) = R(idx) + prm(jj,2)*exp(-d(idx).^2/(2*prm(jj,3)^2));      
    
  end
  
end

X =  R .* cos(Theta);
Z = -R .* sin(Theta);
vertices = [X Y Z];

if opts.new_model
  solid.prm.prm = prm;
  solid.prm.bumptypes = nbumptypes;
  solid.prm.nbumps = nbumps;
  solid.prm.mindist = mindist;
  solid.prm.mfilename = mfilename;
  solid.prm.locations = opts.locations;
  solid.normals = [];
else
  ii = length(solid.prm)+1;
  solid.prm(ii).prm = prm;
  solid.prm(ii).bumptypes = nbumptypes;
  solid.prm(ii).nbumps = nbumps;
  solid.prm(ii).mindist = mindist;
  solid.prm(ii).mfilename = mfilename;
  solid.prm(ii).locations = opts.locations;
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
