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

% Toni Saarela, 2014
% 2014-10-19 - ts - first version
% 2014-10-20 - ts - small fixes
% 2015-03-05 - ts - fixed computation of faces (they were defined CW,
%                    should be CCW.  oops.)
% 2015-03-06 - ts - added a "help"

%--------------------------------------------

% TODO: Double-check the vertex normal computation

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

  m = 256;
  n = 256;

end


% Set default values before parsing the optional input arguments.
filename = 'planecustom.obj';
mtlfilename = '';
mtlname = '';
mindist = 0;
comp_normals = false;

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


if ~use_map
  Z = zeros([m n]);
  
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
  Z = ampl * map;
end

X = X'; X = X(:);
Y = Y'; Y = Y(:);
Z = Z'; Z = Z(:);

vertices = [X Y Z];
clear X Y Z

%--------------------------------------------
% Texture coordinates if material is defined
if ~isempty(mtlfilename)
  U = (X-min(x))/(max(x)-min(x));
  V = (Y-min(y))/(max(y)-min(y));
  uvcoords = [U V];
end

%--------------------------------------------
% Faces, vertex indices
faces = zeros((m-1)*(n-1)*2,3);

F(:,1) = [[1 1]'*[1:n-1]](:);
F(:,2) = [n+2:2*n; 2:n](:);
F(:,3) = [[[1 1]' * [n+1:2*n]](:)](2:end-1);
for ii = 1:m-1
  faces((ii-1)*(n-1)*2+1:ii*(n-1)*2,:) = (ii-1)*n + F;
end

%--------------------------------------------
% Vertex normals
if comp_normals
  % Surface normals for the faces
  fn = cross([vertices(faces(:,2),:)-vertices(faces(:,1),:)],...
             [vertices(faces(:,3),:)-vertices(faces(:,1),:)]);

  % Vertex normals
  normals = zeros(m*n,3);
  
  % Loop through vertices, slow
  % for ii = 1:m*n
  %  idx = any(faces==ii,2);
  %  vn = sum(fn(idx,:),1);
  %  normals(ii,:) = vn / sqrt(vn*vn');
  % end

  % Loop through faces, somewhat faster
  nfaces = (m-1)*(n-1)*2;
  for ii = 1:nfaces
    normals(faces(ii,:),:) = normals(faces(ii,:),:) + [1 1 1]'*fn(ii,:);
  end
  normals = normals./sqrt(sum(normals.^2,2)*[1 1 1]);

  clear fn
end

%--------------------------------------------
% Output argument
if nargout
  plane.vertices = vertices;
  plane.faces = faces;
  if ~isempty(mtlfilename)
     plane.uvcoords = uvcoords;
  end
  if comp_normals
     plane.normals = normals;
  end
  plane.npointsx = n;
  plane.npointsy = m;
end

%--------------------------------------------
% Write to file

fid = fopen(filename,'w');
fprintf(fid,'# %s\n',datestr(now,31));
fprintf(fid,'# Created with function %s from ShapeToolbox.\n',mfilename);
fprintf(fid,'#\n# Number of vertices: %d.\n',size(vertices,1));
fprintf(fid,'# Number of faces: %d.\n',size(faces,1));
if isempty(mtlfilename)
  fprintf(fid,'# Texture (uv) coordinates defined: No.\n');
else
  fprintf(fid,'# Texture (uv) coordinates defined: Yes.\n');
end
if comp_normals
  fprintf(fid,'# Vertex normals included: Yes.\n');
else
  fprintf(fid,'# Vertex normals included: No.\n');
end

if use_map
  if exist(imgname)
     fprintf(fid,'#\n# Modulation values defined by the (average) intensity\n');
     fprintf(fid,'# of the image %s.\n',imgname);
  else
     fprintf(fid,'#\n# Modulation values defined by a custom matrix.\n');
  end
else    
  fprintf(fid,'#\n#  Modulation defined by a custom user-defined function.\n');
  fprintf(fid,'#  Modulation parameters:\n');
  fprintf(fid,'#  # of locations | Cut-off dist. | Custom function arguments\n');
  for ii = 1:nbumptypes
    fprintf(fid,'#  %14d   %13.2f   ',prm(ii,1:2));
    fprintf(fid,'%5.2f  ',prm(ii,3:end));
    fprintf(fid,'\n');
  end
end

if isempty(mtlfilename)
  fprintf(fid,'\n\n# Vertices:\n');
  fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
  fprintf(fid,'# End vertices\n');
  if comp_normals
    fprintf(fid,'\n# Normals:\n');
    fprintf(fid,'vn %8.6f %8.6f %8.6f\n',normals');
    fprintf(fid,'# End normals\n');
    fprintf(fid,'\n# Faces:\n');
    fprintf(fid,'f %d//%d %d//%d %d//%d\n',[faces(:,1) faces(:,1) faces(:,2) faces(:,2) faces(:,3) faces(:,3)]');
  else
    fprintf(fid,'\n# Faces:\n');
    fprintf(fid,'f %d %d %d\n',faces');    
  end
  fprintf(fid,'# End faces\n');
else
  fprintf(fid,'\nmtllib %s\nusemtl %s\n',mtlfilename,mtlname);
  fprintf(fid,'\n# Vertices:\n');
  fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
  fprintf(fid,'# End vertices\n\n# Texture coordinates:\n');
  fprintf(fid,'vt %8.6f %8.6f\n',uvcoords');
  fprintf(fid,'# End texture coordinates\n');
  if comp_normals
    fprintf(fid,'\n# Normals:\n');
    fprintf(fid,'vn %8.6f %8.6f %8.6f\n',normals');
    fprintf(fid,'# End normals\n');
    fprintf(fid,'\n# Faces:\n');
    fprintf(fid,'f %d/%d/%d %d/%d/%d %d/%d/%d\n',...
            [faces(:,1) faces(:,1) faces(:,1)...
             faces(:,2) faces(:,2) faces(:,2)...
             faces(:,3) faces(:,3) faces(:,3)]');
  else
    fprintf(fid,'\n# Faces:\n');
    fprintf(fid,'f %d/%d %d/%d %d/%d\n',[faces(:,1) faces(:,1) faces(:,2) faces(:,2) faces(:,3) faces(:,3)]');
  end
  fprintf(fid,'# End faces\n');
end
fclose(fid);

