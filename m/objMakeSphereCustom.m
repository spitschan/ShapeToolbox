function sphere = objMakeSphereCustom(f,prm,varargin)

  % OBJMAKESPHERECUSTOM
  % 
  % Make a sphere with a custom modulation for the radius.  The
  % modulation values can be defined by an input matrix or an image.
  % Alternatively, one can by providing a handle to a function that 
  % determines the modulation.
  %
  % To provide the modulation in an input matrix:
  % > objMakeSphereCustom(I,A), 
  % where I is a two-dimensional matrix and A is a scalar, maps M onto
  % the surface of the sphere and uses the values of I to modulate the
  % sphere radius.  Maximum amplitude of modulation is A (the values
  % of M are first normalized to [-1,1], the multiplied with A).
  %
  % To use an image:
  % > objMakeSphereCustom(FILENAME,A)
  % The image values are first normalized to [0,1], then multiplied by
  % A.  These values are mapped onto the sphere to modulate the radius.
  %
  % With matrix of image as input, the default number of vertices is
  % the size of the matrix/image.  To define a different number of
  % vertices:
  % > objMakeSphereCustom(I,A,'npoints',[M N])
  % to have M vertices in the elevation direction and N in the azimuth
  % direction.  The values of the matrix/image are interpolated.
  % 
  % Provide a function handle:
  % > objMakeSphereCustom(@F,PRM)
  % F is a function that takes distance as its first input argument
  % and a vector of other parameters as the second.  The return values
  % of F are used to modulate the sphere radius.  The format of the
  % parameters is:
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
  % > F(D,[PRM1 PRM2 ...])
  % where D is the distance from the randomly chosen midpoint.
  %
  % To restrict how close together the random location can be:
  % > objMakeSphereCustom(@F,PRM,'mindist',DMIN)
  % where DMIN is in degrees.
  %
  % The default number of vertices when providing a function handle as
  % input is 128x256 (elevation x azimuth).  To define a different
  % number of vertices:
  % > objMakeSphereCustom(@F,PRM,'npoints',[N M])
  %
  % For texture mapping, see help to objMakeSphere or online help.
         
% Toni Saarela, 2014
% 2014-10-18 - ts - first version
% 2014-10-20 - ts - small fixes
% 2014-10-28 - ts - a bunch of fixes and improvements; wrote help

% TODO
% - return the locations of bumps
% - write more info to the obj-file and the returned structure


%--------------------------------------------

if ischar(f)
  map = double(imread(f));
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

r = 1; % radius
theta = linspace(-pi,pi-2*pi/n,n); % azimuth
phi = linspace(-pi/2,pi/2,m); % elevation

%--------------------------------------------
% TODO:
% Throw an error if the asked minimum distance is a ridiculously large
% number.
%if mindist>
%  error('Yeah right.');
%end

%--------------------------------------------
% Vertices

[Theta,Phi] = meshgrid(theta,phi);

% Theta = Theta'; Theta = Theta(:);
% Phi   = Phi';   Phi   = Phi(:);
% R = ones(m*n,1);

if ~use_map

  R = r * ones([m n]);

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
      
      R(idx) = R(idx) + f(d(idx),prm(jj,3:end));
      
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

%--------------------------------------------
% Texture coordinates if material is defined
if ~isempty(mtlfilename)
  %Phi = Phi';
  %Theta = Theta';
  %U = (Theta(:)-min(theta))/(max(theta)-min(theta));
  %V = (Phi(:)-min(phi))/(max(phi)-min(phi));
  
  u = linspace(0,1,n+1);
  v = linspace(0,1,m);
  [U,V] = meshgrid(u,v);
  U = U'; V = V';
  uvcoords = [U(:) V(:)];
  clear u v U V
end

%--------------------------------------------
% Faces, vertex indices

faces = zeros((m-1)*n*2,3);

F = ([1 1]'*[1:n]);
F = F(:) * [1 1 1];
F(:,2) = F(:,2) + [repmat([n+1 1]',[n-1 1]); [1 1-n]'];
F(:,3) = F(:,3) + [repmat([n n+1]',[n-1 1]); [n 1]'];
for ii = 1:m-1
  faces((ii-1)*n*2+1:ii*n*2,:) = (ii-1)*n + F;
end

% Faces, uv coordinate indices
if ~isempty(mtlfilename)
  facestxt = zeros((m-1)*n*2,3);
  n2 = n + 1;
  F = ([1 1]'*[1:n]);
  F = F(:) * [1 1 1];
  F(:,2) = reshape([1 1]'*[2:n2]+[1 0]'*n2*ones(1,n),[2*n 1]);
  F(:,3) = n2 + [1; reshape([1 1]'*[2:n],[2*(n-1) 1]); n2];
  for ii = 1:m-1
    facestxt((ii-1)*n*2+1:ii*n*2,:) = (ii-1)*n2 + F;
  end
end

%--------------------------------------------
% Output argument

if nargout
  sphere.vertices = vertices;
  sphere.faces = faces;
  if ~isempty(mtlfilename)
     sphere.uvcoords = uvcoords;
  end
  sphere.npointsx = n;
  sphere.npointsy = m;
end

%--------------------------------------------
% Write to file

fid = fopen(filename,'w');
fprintf(fid,'# %s\n',datestr(now,31));
fprintf(fid,'# Created with function %s from ShapeToolbox.\n',mfilename);
fprintf(fid,'#\n# Number of vertices: %d.\n',size(vertices,1));
fprintf(fid,'# Number of faces: %d.\n',size(faces,1));

% TODO: 
% Write specs here
% - name of image
% - some info about input matrix
% - name of function called plus parameters

if isempty(mtlfilename)
  fprintf(fid,'\n\n# Vertices:\n');
  fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
  fprintf(fid,'# End vertices\n\n# Faces:\n');
  fprintf(fid,'f %d %d %d\n',faces');
  fprintf(fid,'# End faces\n\n');
else
  fprintf(fid,'\n\nmtllib %s\nusemtl %s\n\n',mtlfilename,mtlname);
  fprintf(fid,'\n\n# Vertices:\n');
  fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
  fprintf(fid,'# End vertices\n\n# Texture coordinates:\n');
  fprintf(fid,'vt %8.6f %8.6f\n',uvcoords');
  fprintf(fid,'# End texture coordinates\n\n# Faces:\n');
  fprintf(fid,'f %d/%d %d/%d %d/%d\n',[faces(:,1) facestxt(:,1) faces(:,2) facestxt(:,2) faces(:,3) facestxt(:,3)]');
  fprintf(fid,'# End faces\n\n');
end
fclose(fid);

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

