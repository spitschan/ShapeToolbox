function sphere = objMakeSphereCustom(f,prm,varargin)

  % OBJMAKESPHERECUSTOM
  % 
  % Make a sphere with a custom-modulated radius.  The modulation
  % values can be defined by an input matrix or an image, or by
  % providing a handle to a function that determines the modulation.
  %
  % To provide the modulation in an input matrix:
  % > objMakeSphereCustom(I,A), 
  % where I is a two-dimensional matrix and A is a scalar, maps M onto
  % the surface of the sphere and uses the values of I to modulate the
  % sphere radius.  Maximum amplitude of modulation is A (the values
  % of M are first normalized to [-1,1], the multiplied with A).
  %
  % To use an image:
  %   > objMakeSphereCustom(FILENAME,A)
  % The image values are first normalized to [0,1], then multiplied by
  % A.  These values are mapped onto the sphere to modulate the radius.
  %
  % With matrix or image as input, the default number of vertices is
  % the size of the matrix/image.  To define a different number of
  % vertices, do:
  %   > objMakeSphereCustom(I,A,'npoints',[M N])
  % to have M vertices in the elevation direction and N in the azimuth
  % direction.  The values of the matrix/image are interpolated.
  % 
  % The radius of the sphere (before modulation) is one.
  % 
  % Alternatively, provide a handle to a function that defines the
  % modulation:
  %   > objMakeSphereCustom(@F,PRM)
  % F is a function that takes distance as its first input argument
  % and a vector of other parameters as the second.  The return values
  % of F are used to modulate the sphere radius.  The format of the
  % parameter vector is:
  %    PRM = [N DCUT PRM1 PRM2 ...]
  % where
  %    N is the number of random locations at which the function 
  %      is applied
  %    DCUT is the cut-off distance after which no modulation is
  %      applied, in degrees
  %    [PRM1, PRM2...]  are the parameters passed to F
  %
  % To apply the function several times with different parameters:
  %    PRM = [N1 DCUT1 PRM11 PRM12 ...
  %           N2 DCUT2 PRM21 PRM22 ...
  %           ...                     ]
  %
  % Function F will be called as:
  %   > F(D,[PRM1 PRM2 ...])
  % where D is the distance from the midpoint in degrees.  The points 
  % at which the function will be applied are chosen randomly.
  %
  % To restrict how close together the random location can be:
  %   > objMakeSphereCustom(@F,PRM,...,'mindist',DMIN,...)
  % where DMIN is in degrees.
  %
  % The default number of vertices when providing a function handle as
  % input is 128x256 (elevation x azimuth).  To define a different
  % number of vertices:
  %   > objMakeSphereCustom(@F,PRM,...,'npoints',[N M],...)
  %
  % To turn on the computation of surface normals (which will increase
  % coputation time):
  %   > objMakeSphereCustom(...,'NORMALS',true,...)
  %
  % For texture mapping, see help to objMakeSphere or online help.
  % 

  % Examples:
  % TODO
         
% Copyright (C) 2014,2015 Toni Saarela
% 2014-10-18 - ts - first version
% 2014-10-20 - ts - small fixes
% 2014-10-28 - ts - a bunch of fixes and improvements; wrote help
% 2014-11-10 - ts - vertex normals, updated help, all units in degrees
% 2015-04-02 - ts - calls the new objSaveModelSphere-function to
%                    compute faces, normals, etc and save the model to a file
%                   saving the model is optional, an existing model
%                     can be updated

% TODO
% - return the locations of bumps
% - write more info to the obj-file and the returned structure


%--------------------------------------------

if ischar(f)
  imgname = f;
  map = double(imread(imgname));
  if ndims(map)>2
    map = mean(map,3);
  end

  map = flipud(map/max(abs(map(:))));

  ampl = prm(1);

  [mmap,nmap] = size(map);
  m = mmap;
  n = nmap;

  use_map = true;

  clear f

elseif isnumeric(f)
  map = f;
  if ndims(map)~=2
    error('The input matrix has to be two-dimensional.');
  end

  map = flipud(map/max(map(:)));

  ampl = prm(1);

  use_map = true;

  [mmap,nmap] = size(map);
  m = mmap;
  n = nmap;

  clear f

elseif isa(f,'function_handle')
  [nbumptypes,ncol] = size(prm);
  nbumps = sum(prm(:,1));
  use_map = false;

  prm(:,2) = pi*prm(:,2)/180;

  m = 128;
  n = 256;

end


% Set default values before parsing the optional input arguments.
filename = 'spherecustom.obj';
mtlfilename = '';
mtlname = '';
mindist = 0;
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
         case 'material'
           if ii<length(par) && iscell(par{ii+1}) && length(par{ii+1})==2
             ii = ii + 1;
             mtlfilename = par{ii}{1};
             mtlname = par{ii}{2};
           else
             error('No value or a bad value given for option ''material''.');
           end
         case 'normals'
           if ii<length(par) && (isnumeric(par{ii+1}) || islogical(par{ii+1}))
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
             sphere = par{ii};
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

mindist = pi*mindist/180;

%--------------------------------------------
% TODO:
% Throw an error if the asked minimum distance is a ridiculously large
% number.
%if mindist>
%  error('Yeah right.');
%end

%--------------------------------------------
% Vertices

if new_model
  r = 1; % radius
  theta = linspace(-pi,pi-2*pi/n,n); % azimuth
  phi = linspace(-pi/2,pi/2,m); % elevation
  
  [Theta,Phi] = meshgrid(theta,phi);
  r = r * ones([m n]);
else
  m = sphere.m;
  n = sphere.n;
  Theta = sphere.Theta;
  Phi = sphere.Phi;
  R = sphere.R;
  Theta = reshape(Theta,[n m])';
  Phi = reshape(Phi,[n m])';
  r = reshape(R,[n m])';
end

if ~use_map

  R = r;

  for jj = 1:nbumptypes
      
    if mindist
      % Make extra candidate vectors (30 times the required number)
      %ptmp = normrnd(0,1,[30*prm(jj,1) 3]);
      ptmp = randn([30*prm(jj,1) 3]);
      % Make them unit length
      ptmp = ptmp ./ (sqrt(sum(ptmp.^2,2))*[1 1 1]);
      
      % Matrix for the accepted vectors
      p = zeros([prm(jj,1) 3]);
      
      % Compute distances (the same as angles, radius is one) between
      % all the vectors.  Use the real function here---sometimes,
      % some of the values might be slightly larger than one, in which
      % case acos returns a complex number with a small imaginary part.
      d = real(acos(ptmp * ptmp'));
      
      % Always accept the first vector
      idx_accepted = [1];
      n_accepted = 1;
      % Loop over the remaining candidate vectors and keep the ones that
      % are at least the minimum distance away from those already
      % accepted.
      idx = 2;
      while idx <= size(ptmp,1)
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
        error('Could not find enough vectors to satisfy the minumum distance criterion.\nConsider reducing the value of ''mindist''.');
      end
      
      p = ptmp(idx_accepted,:);
      
    else
      %- pick n random directions
      %p = normrnd(0,1,[prm(jj,1) 3]);
      p = randn([prm(jj,1) 3]);
    end
    
    [theta0,phi0,rtmp] = cart2sph(p(:,1),p(:,2),p(:,3));
    
    clear rtmp
    
    %-------------------
    
    for ii = 1:prm(jj,1)
      deltatheta = abs(wrapAnglePi(Theta - theta0(ii)));
      
      %- https://en.wikipedia.org/wiki/Great-circle_distance:
      d = acos(sin(Phi).*sin(phi0(ii))+cos(Phi).*cos(phi0(ii)).*cos(deltatheta));
      
      idx = find(d<prm(jj,2));
      
      R(idx) = R(idx) + f(180.0*d(idx)/pi,prm(jj,3:end));
      
    end
    
  end
else
  if mmap~=m || nmap~=n
    theta2 = linspace(-pi,pi-2*pi/nmap,nmap); % azimuth
    phi2 = linspace(-pi/2,pi/2,mmap); % elevation
    [Theta2,Phi2] = meshgrid(theta2,phi2);
    map = interp2(Theta2,Phi2,map,Theta,Phi);
  end
  R = r + ampl * map;
end

Theta = Theta'; Theta = Theta(:);
Phi   = Phi';   Phi   = Phi(:);
R = R'; R = R(:);

[X,Y,Z] = sph2cart(Theta,Phi,R);
vertices = [X Y Z];

clear X Y Z

% The field prm can be made an array.  If the structure sphere is
% passed to another objMakeSphere*-function, that function will add
% its parameters to that array.
if new_model
  sphere.prm.use_map = use_map;
  if use_map
    if exist(imgname)
      sphere.prm.imgname = imgname;
    end
  else
    sphere.prm.prm = prm;
    sphere.prm.nbumptypes = nbumptypes;
    sphere.prm.nbumps = nbumps;
  end
  sphere.prm.mfilename = mfilename;
  sphere.normals = [];
else
  ii = length(sphere.prm)+1;
  sphere.prm(ii).use_map = use_map;
  if use_map
    if exist(imgname)
      sphere.prm(ii).imgname = imgname;
    end
  else
    sphere.prm(ii).prm = prm;
    sphere.prm(ii).nbumptypes = nbumptypes;
    sphere.prm(ii).nbumps = nbumps;
  end
  sphere.prm(ii).mfilename = mfilename;
  sphere.normals = [];
end
sphere.shape = 'sphere';
sphere.filename = filename;
sphere.mtlfilename = mtlfilename;
sphere.mtlname = mtlname;
sphere.comp_normals = comp_normals;
sphere.n = n;
sphere.m = m;
sphere.Theta = Theta;
sphere.Phi = Phi;
sphere.R = R;
sphere.vertices = vertices;

if dosave
  sphere = objSaveModelSphere(sphere);
end

if ~nargout
   clear sphere
end

%---------------------------------------------
% Functions

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

