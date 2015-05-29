function cylinder = objMakeCylinderCustom(f,prm,varargin)

% OBJMAKECYLINDERCUSTOM
% 
% Usage:          objMakeCylinderCustom()

% Copyright (C) 2014, 2015 Toni Saarela
% 2014-10-18 - ts - first version
% 2014-10-19 - ts - small fixes
% 2014-10-20 - ts - small fixes
% 2015-04-03 - ts - calls the new objSaveModelCylinder-function to
%                    compute faces, normals, etc and save the model to a file
%                   saving the model is optional, an existing model
%                     can be updated, many other improvements
% 2015-05-04 - ts - added uv-option without materials
%                   calls objParseArgs and objSaveModel
% 2015-05-14 - ts - added bump locations as optional input arg.
%                    locations also included in the model structure
% 2015-05-14 - ts - different minimum distance can be defined for each
%                    bump type
% 2015-05-29 - ts - fixed a bug in normalization of image/matrix values

% TODO
% - return the locations of bumps
% - write help

%--------------------------------------------

if ischar(f)
  imgname = f;
  map = double(imread(imgname));
  if ndims(map)>2
    map = mean(map,3);
  end

  map = flipud(map/max(map(:)));

  ampl = prm(1);

  [mmap,nmap] = size(map);
  opts.m = mmap;
  opts.n = nmap;

  use_map = true;

  clear f

elseif isnumeric(f)
  map = f;
  if ndims(map)~=2
    error('The input matrix has to be two-dimensional.');
  end

  map = flipud(map/max(abs(map(:))));

  ampl = prm(1);

  use_map = true;

  [mmap,nmap] = size(map);
  opts.m = mmap;
  opts.n = nmap;

  clear f

elseif isa(f,'function_handle')
  [nbumptypes,ncol] = size(prm);
  nbumps = sum(prm(:,1));
  use_map = false;

  opts.m = 256;
  opts.n = 256;

  opts.mindist = 0;
  opts.locations = {};

end


% Set default values before parsing the optional input arguments.
opts.filename = 'cylindercustom.obj';

[tmp,par] = parseparams(varargin);

% Check other optional input arguments
[opts,cylinder] = objParseArgs(opts,par);

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

  r = 1; % radius
  h = 2*pi*r; % height
  theta = linspace(-pi,pi-2*pi/n,n); % azimuth
  y = linspace(-h/2,h/2,m); % 
  
  [Theta,Y] = meshgrid(theta,y);
  R = r * ones([m n]);
else
  m = cylinder.m;
  n = cylinder.n;

  r = 1; % radius
  h = 2*pi*r; % height
  theta = linspace(-pi,pi-2*pi/n,n); % azimuth
  y = linspace(-h/2,h/2,m); % 

  Theta = reshape(cylinder.Theta,[n m])';
  Y = reshape(cylinder.Y,[n m])';
  R = reshape(cylinder.R,[n m])';
end

if ~use_map

  if isscalar(opts.mindist)
    opts.mindist = ones(1,nbumptypes) * opts.mindist;
  elseif length(opts.mindist)~=nbumptypes
    error('Incorrect number of minimum distances defined.');
  end
  
  mindist = opts.mindist;

  for jj = 1:nbumptypes
      
    if ~isempty(opts.locations) && ~isempty(opts.locations{1}{jj})
       
      theta0 = opts.locations{1}{jj};
      y0 = opts.locations{2}{jj};
      
    elseif mindist(jj)

      %- Pick candidate locations (more than needed):
      nvec = 30*prm(jj,1);
      thetatmp = min(theta) + rand([nvec 1])*(max(theta)-min(theta));
      ytmp = min(y) + rand([nvec 1])*(max(y)-min(y));

    %d = sqrt((thetatmp*ones([1 nvec])-ones([nvec 1])*thetatmp').^2 + ...
    %         (ytmp*ones([1 nvec])-ones([nvec 1])*ytmp').^2);
    
    d = sqrt(wrapAnglePi(thetatmp*ones([1 nvec])-ones([nvec 1])*thetatmp').^2 + ...
             (ytmp*ones([1 nvec])-ones([nvec 1])*ytmp').^2);

      %- Always accept the first vector
      idx_accepted = [1];
      n_accepted = 1;
      %- Loop over the remaining candidate vectors and keep the ones that
      %- are at least the minimum distance away from those already
      %- accepted.
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
      
      idx = find(d<prm(jj,2));
      R(idx) = R(idx) + f(d(idx),prm(jj,3:end));
    end
    
  end
else
  if mmap~=m || nmap~=n
    theta2 = linspace(-pi,pi-2*pi/nmap,nmap); % azimuth
    y2 = linspace(-h/2,h/2,mmap); % 
    [Theta2,Y2] = meshgrid(theta2,y2);
    map = interp2(Theta2,Y2,map,Theta,Y);
  end
  R = R + ampl * map;
end

Theta = Theta'; Theta = Theta(:);
Y = Y'; Y = Y(:);
R = R'; R = R(:);

X =  R .* cos(Theta);
Z = -R .* sin(Theta);

vertices = [X Y Z];

if opts.new_model
  cylinder.prm.use_map = use_map;
  if use_map
    if exist(imgname)
      cylinder.prm.imgname = imgname;
    end
  else
    cylinder.prm.prm = prm;
    cylinder.prm.nbumptypes = nbumptypes;
    cylinder.prm.nbumps = nbumps;
    cylinder.prm.mindist = mindist;
    cylinder.prm.locations = opts.locations;
  end
  cylinder.prm.mfilename = mfilename;
  cylinder.normals = [];
else
  ii = length(cylinder.prm)+1;
  cylinder.prm(ii).use_map = use_map;
  if use_map
    if exist(imgname)
      cylinder.prm(ii).imgname = imgname;
    end
  else
    cylinder.prm(ii).prm = prm;
    cylinder.prm(ii).nbumptypes = nbumptypes;
    cylinder.prm(ii).nbumps = nbumps;
    cylinder.prm(ii).mindist = mindist;
    cylinder.prm(ii).locations = opts.locations;
  end
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


%--------------------------------------------------

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

