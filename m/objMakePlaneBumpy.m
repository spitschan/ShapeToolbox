function plane = objMakePlaneBumpy(prm,varargin)

% OBJMAKEPLANEBUMPY
%
% Usage: plane = objMakePlaneBumpy(prm,...)

% Toni Saarela, 2014
% 2014-10-17 - ts - first version

%--------------------------------------------

if ~nargin || isempty(prm)
  prm = [20 .05 .05];
end

[nbumptypes,ncol] = size(prm);

switch ncol
  case 1
    prm = [prm ones(nccomp,1)*[.05 .05]];
  case 2
    prm = [prm ones(nccomp,1)*.05];
end

nbumps = sum(prm(:,1));

% Set default values before parsing the optional input arguments.
filename = 'planebumpy.obj';
mtlfilename = '';
mtlname = '';
mindist = 0;
m = 256;
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

w = 1; % width of the plane
h = m/n * w;

x = linspace(-w/2,w/2,n); % 
y = linspace(-h/2,h/2,m)'; % 

%--------------------------------------------
% TODO:
% Throw an error if the asked minimum distance is a ridiculously large
% number.
%if mindist>
%  error('Yeah right.');
%end
%--------------------------------------------

vertices = zeros(m*n,3);

[X,Y] = meshgrid(x,y);
X = X'; X = X(:);
Y = Y'; Y = Y(:);
Z = zeros(size(X));

for jj = 1:nbumptypes

  if mindist

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
       error('Could not find enough vectors to satisfy the minumum distance criterion.\nConsider reducing the value of ''mindist''.');
    end

    x0 = xtmp(idx_accepted,:);
    y0 = ytmp(idx_accepted,:);

  else
    %- pick n random locations
    x0 = min(x) + rand([prm(jj,1) 1])*(max(x)-min(x));
    y0 = min(y) + rand([prm(jj,1) 1])*(max(y)-min(y));

  end

  clear xtmp ytmp

  %-------------------
  
  for ii = 1:prm(jj,1)

    deltax = X - x0(ii);
    deltay = Y - y0(ii);
    d = sqrt(deltax.^2+deltay.^2);
    
    idx = find(d<3.5*prm(jj,3));
    Z(idx) = Z(idx) + prm(jj,2)*exp(-d(idx).^2/(2*prm(jj,3)^2));
  end

end

vertices = [X Y Z];

if ~isempty(mtlfilename)
  U = (X-min(x))/(max(x)-min(x));
  V = (Y-min(y))/(max(y)-min(y));
  uvcoords = [U V];
end

% Face indices
faces = zeros((m-1)*n*2,3);

%tic
F = ([1 1]'*[1:n-1]);
F = F(:) * [1 1 1];
F(:,2) = F(:,2) + repmat([n n+1]',[n-1 1]);
F(:,3) = F(:,3) + repmat([n+1 1]',[n-1 1]);
for ii = 1:m-1
  faces((ii-1)*(n-1)*2+1:ii*(n-1)*2,:) = (ii-1)*n + F;
end
%toc

%-------------------

if nargout
  plane.vertices = vertices;
  plane.faces = faces;
  plane.npointsx = n;
  plane.npointsy = m;
end

% Write to file
fid = fopen(filename,'w');
fprintf(fid,'# %s\n',datestr(now));
fprintf(fid,'# Created with function %s.\n',mfilename);
fprintf(fid,'#\n# Number of vertices: %d.\n',size(vertices,1));
fprintf(fid,'# Number of faces: %d.\n',size(faces,1));
fprintf(fid,'#\n# Gaussian bump parameters (each row is bump type):\n');
fprintf(fid,'#  # of bumps | Amplitude | Sigma\n');
for ii = 1:nbumptypes
  fprintf(fid,'#  %d           %4.2f       %4.2f\n',prm(ii,:));
end
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

