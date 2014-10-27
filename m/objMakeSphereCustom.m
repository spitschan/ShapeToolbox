function sphere = objMakeSphereCustom(f,prm,varargin)

% OBJMAKESPHERECUSTOM
% 
% Usage:          objMakeSphereCustom()

% Toni Saarela, 2014
% 2014-10-18 - ts - first version
% 2014-10-20 - ts - small fixes

% TODO
% - return the locations of bumps
% - write help
% - write more info to the obj-file and the returned structure
% - when using a map, by default make the grid the same size as the


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
  if ndims(map)>2
    map = mean(map,3);
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

  m = 128;
  n = 256;

end


% Set default values before parsing the optional input arguments.
filename = 'spherecustom.obj';
mtlfilename = '';
mtlname = '';
mindist = 0;
%m = 128;
%n = 256;

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

if ~isempty(mtlfilename)
  U = (Theta(:)-min(theta))/(max(theta)-min(theta));
  V = (Phi(:)-min(phi))/(max(phi)-min(phi));
  uvcoords = [U V];
end

faces = zeros((m-1)*n*2,3);

% Face indices

%tic
F = ([1 1]'*[1:n]);
F = F(:) * [1 1 1];
F(:,2) = F(:,2) + [repmat([n n+1]',[n-1 1]); [n 1]'];
F(:,3) = F(:,3) + [repmat([n+1 1]',[n-1 1]); [1 1-n]'];
for ii = 1:m-1
  faces((ii-1)*n*2+1:ii*n*2,:) = (ii-1)*n + F;
end
%toc

%-------------------


if nargout
  sphere.vertices = vertices;
  sphere.faces = faces;
  sphere.npointsx = n;
  sphere.npointsy = m;
end

% Write to file
fid = fopen(filename,'w');
fprintf(fid,'# %s\n',datestr(now));
fprintf(fid,'# Created with function %s.\n',mfilename);
fprintf(fid,'#\n# Number of vertices: %d.\n',size(vertices,1));
fprintf(fid,'# Number of faces: %d.\n',size(faces,1));
% fprintf(fid,'#\n# Gaussian bump parameters (each row is bump type):\n');
% fprintf(fid,'#  # of bumps | Amplitude | Sigma\n');
% for ii = 1:nbumptypes
%   fprintf(fid,'#  %d           %4.2f       %4.2f\n',prm(ii,:));
% end
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
  fprintf(fid,'f %d/%d %d/%d %d/%d\n',expmat(faces,[1,2])');
  fprintf(fid,'# End faces\n\n');
end
fclose(fid);

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

