function plane = objMakePlaneCustom(f,prm,varargin)

  % OBJMAKEPLANECUSTOM
  %
  % Usage: plane = objMakePlaneCustom(f,prm,...)
  %
  % Makes a 3D model plane with custom perturbations in the
  % z-direction. The perturbation can be defined by an input matrix or
  % image, or by providing a handle to a function that determines the
  % modulation.
  %
  % For details on the input arguments, see the help for
  % objMakeSphereCustom.

% Copyright (C) 2014,2015 Toni Saarela

% 2014-10-19 - ts - first version
% 2014-10-20 - ts - small fixes
% 2015-03-05 - ts - fixed computation of faces (they were defined CW,
%                    should be CCW.  oops.)
% 2015-03-06 - ts - added a "help"
% 2015-04-03 - ts - calls the new objSaveModelPlane-function to
%                    compute faces, normals, etc and save the model to a file
%                   saving the model is optional, an existing model
%                     can be updated
% 2015-05-04 - ts - added uv-option without materials;
%                   calls objParseArgs and objSaveModel
% 2015-05-12 - ts - changed plane width and height to 2 (from -1 to 1)
% 2015-05-14 - ts - added bump locations as optional input arg.
%                    locations also included in the model structure
% 2015-05-14 - ts - different minimum distance can be defined for each
%                    bump type
% 2015-05-29 - ts - fixed a bug in normalization of image/matrix values

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
opts.filename = 'planecustom.obj';

[tmp,par] = parseparams(varargin);

% Check other optional input arguments
[opts,plane] = objParseArgs(opts,par);

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

  w = 1; % width of the plane
  h = 1; % m/n * w;
  
  x = linspace(-w/2,w/2,n); % 
  y = linspace(-h/2,h/2,m)'; % 

  [X,Y] = meshgrid(x,y);
  Z = zeros(size(X));
else
  m = plane.m;
  n = plane.n;

  w = plane.w;
  h = plane.h;
  x = linspace(-w/2,w/2,n); % 
  y = linspace(-h/2,h/2,m)'; % 

  X = reshape(plane.X,[n m])';
  Y = reshape(plane.Y,[n m])';
  Z = reshape(plane.Z,[n m])';
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
       
      x0 = opts.locations{1}{jj};
      y0 = opts.locations{2}{jj};
      
    elseif mindist(jj)
       
      % Pick candidate locations (more than needed):
      nvec = 30*prm(jj,1);
      xtmp = min(x) + rand([nvec 1])*(max(x)-min(x));
      ytmp = min(y) + rand([nvec 1])*(max(y)-min(y));
      
      d = sqrt((xtmp*ones([1 nvec])-ones([nvec 1])*xtmp').^2 + (ytmp*ones([1 nvec])-ones([nvec 1])*ytmp').^2);
      
      % Always accept the first vector
      idx_accepted = [1];
      n_accepted = 1;
      % Loop over the remaining candidate vectors and keep the ones that
      % are at least the minimum distance away from those already
      % accepted.
      idx = 2;
      while idx <= size(xtmp,1)
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
      
      x0 = xtmp(idx_accepted,:);
      y0 = ytmp(idx_accepted,:);
      
      clear xtmp ytmp
    
      % For saving the locations in the model structure
      opts.locations{1}{jj} = x0;
      opts.locations{2}{jj} = y0;
  
    else
      %- pick n random locations
      x0 = min(x) + rand([prm(jj,1) 1])*(max(x)-min(x));
      y0 = min(y) + rand([prm(jj,1) 1])*(max(y)-min(y));
      
      % For saving the locations in the model structure
      opts.locations{1}{jj} = x0;
      opts.locations{2}{jj} = y0;
  
    end

    %-------------------
    
    for ii = 1:prm(jj,1)
        
      deltax = X - x0(ii);
      deltay = Y - y0(ii);
      d = sqrt(deltax.^2+deltay.^2);
      
      idx = find(d<prm(jj,2));
      Z(idx) = Z(idx) + f(d(idx),prm(jj,3:end));

    end
    
  end
else
  if mmap~=m || nmap~=n
    x2 = linspace(-w/2,w/2,nmap); % 
    y2 = linspace(-h/2,h/2,mmap)'; % 

    [X2,Y2] = meshgrid(x2,y2);
    map = interp2(X2,Y2,map,X,Y);
  end
  Z = Z + ampl * map;
end

X = X'; X = X(:);
Y = Y'; Y = Y(:);
Z = Z'; Z = Z(:);

vertices = [X Y Z];

if opts.new_model
  plane.prm.use_map = use_map;
  if use_map
    if exist(imgname)
      plane.prm.imgname = imgname;
    end
  else
    plane.prm.prm = prm;
    plane.prm.nbumptypes = nbumptypes;
    plane.prm.nbumps = nbumps;
    plane.prm.mindist = mindist;
    plane.prm.locations = opts.locations;
  end
  plane.prm.mfilename = mfilename;
  plane.normals = [];
else
  ii = length(plane.prm)+1;
  plane.prm(ii).use_map = use_map;
  if use_map
    if exist(imgname)
      plane.prm(ii).imgname = imgname;
    end
  else
    plane.prm(ii).prm = prm;
    plane.prm(ii).nbumptypes = nbumptypes;
    plane.prm(ii).nbumps = nbumps;
    plane.prm(ii).mindist = mindist;
    plane.prm(ii).locations = opts.locations;
  end
  plane.prm(ii).mfilename = mfilename;
  plane.normals = [];
end
plane.shape = 'plane';
plane.filename = opts.filename;
plane.mtlfilename = opts.mtlfilename;
plane.mtlname = opts.mtlname;
plane.comp_uv = opts.comp_uv;
plane.comp_normals = opts.comp_normals;
plane.w = w;
plane.h = h;
plane.n = n;
plane.m = m;
plane.X = X;
plane.Y = Y;
plane.Z = Z;
plane.vertices = vertices;

if opts.dosave
  plane = objSaveModel(plane);
end

if ~nargout
   clear plane
end

