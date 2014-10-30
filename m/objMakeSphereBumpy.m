function sphere = objMakeSphereBumpy(prm,varargin)

% OBJMAKESPHEREBUMPY
% 
% Usage:          objMakeSphereBumpy()
%                 objMakeSphereBumpy()
%        sphere = objMakeSphereBumpy()
%        sphere = objMakeSphereBumpy()
%
%
% Note: The minimum distance between bumps only applies to bumps of
% the same type.  If several types of bumps are defined (in rows of
% the imput argument prm), different types of bumps might be closer
% together than mindist.  This might change in the future.  Then
% again, it might not.

% Toni Saarela, 2014
% 2014-05-06 - ts - first version
% 2014-08-07 - ts - option for mixing bumps with different parameters
%                   made the computations much faster
% 2014-10-09 - ts - better parsing of input arguments
%                   added an option for minimum distance of bumps
%                   added an option for number of vertices
%                   fixed an error in writing the bump specs in the
%                     obj-file comments
% 2014-10-28 - ts - bunch of small changes and improvements;
%                    sigma is given in degrees now

% TODO
% - return the locations of bumps
% - option to add noise to bump amplitudes/sigmas
% - write help
% - write more info to the obj-file and the returned structure

%--------------------------------------------

if ~nargin || isempty(prm)
  prm = [20 .1 8];
end

[nbumptypes,ncol] = size(prm);

switch ncol
  case 1
    prm = [prm ones(nccomp,1)*[.1 8]];
  case 2
    prm = [prm ones(nccomp,1)*8];
end

prm(:,3) = pi*prm(:,3)/180;

nbumps = sum(prm(:,1));

% Set default values before parsing the optional input arguments.
filename = 'spherebumpy.obj';
mtlfilename = '';
mtlname = '';
mindist = 0;
m = 128;
n = 256;

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

mindist = pi*mindist/180;

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
Theta = Theta'; Theta = Theta(:);
Phi   = Phi';   Phi   = Phi(:);
R = r * ones(m*n,1);

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
    
    idx = find(d<3.5*prm(jj,3));
    R(idx) = R(idx) + prm(jj,2)*exp(-d(idx).^2/(2*prm(jj,3)^2));
  end

end

[X,Y,Z] = sph2cart(Theta,Phi,R);
vertices = [X Y Z];

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
fprintf(fid,'#\n# Gaussian bump parameters (each row is bump type):\n');
fprintf(fid,'#  # of bumps | Amplitude | Sigma\n');
for ii = 1:nbumptypes
  fprintf(fid,'#  %10d   %9.2f   %5.2f\n',prm(ii,:));
end

fprintf(fid,'#\n# Sigma is in radians above.\n');

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

%---------------------------------------------------------
% Functions...

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

