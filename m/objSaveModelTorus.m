function t = objSaveModelTorus(t)

% t = objSaveModelTorus(t)
%
% Usage: t = objSaveModelTorus(t)
%
% A function called by the objMakeTorus*-functions to compute
% texture coordinates, faces, and so forth; and to write the model
% to a file.

% Copyright (C) 2015 Toni Saarela
% 2015-04-04 - ts - first version

%--------------------------------------------

m = t.m;
n = t.n;
vertices = t.vertices;

%--------------------------------------------

% Texture coordinates if material is defined
if ~isempty(t.mtlfilename)
  u = linspace(0,1,n+1);
  v = linspace(0,1,m+1);
  [U,V] = meshgrid(u,v);
  U = U'; V = V';
  uvcoords = [U(:) V(:)];
  clear u v U V
end

%--------------------------------------------
% Faces, vertex indices
faces = zeros(m*n*2,3);

% The first part is the same as with the sphere:
F = ([1 1]'*[1:n]);
F = F(:) * [1 1 1];
F(:,2) = F(:,2) + [repmat([n+1 1]',[n-1 1]); [1 1-n]'];
F(:,3) = F(:,3) + [repmat([n n+1]',[n-1 1]); [n 1]'];
% But loop until m, not m-1 as phi goes -pi to pi here, not -pi/2 to
% pi/2.
for ii = 1:m
  faces((ii-1)*n*2+1:ii*n*2,:) = (ii-1)*n + F;
end
% Finally, to wrap around properly in the phi-direction:
faces = 1 + mod(faces-1,m*n);

% Faces, uv coordinate indices.  Not pretty but works.  May be
% prettified in the future, but don't hold your breath.
if ~isempty(t.mtlfilename)
  facestxt = zeros(m*n*2,3);
  F1 = [1 1]' * [1:n];
  F1 = F1(:);
  F2 = [(n+3):2*(n+1);2:(n+1)];
  F2 = F2(:);
  F3 = [1 1]' * [(n+2):2*(n+1)];
  F3 = F3(:);
  F3 = F3(2:end-1);
  F = [F1 F2 F3];
  for ii = 1:m
    facestxt((ii-1)*n*2+1:ii*n*2,:) = (ii-1)*(n+1) + F;
  end
end

%--------------------------------------------
% Vertex normals
if t.comp_normals
  % Surface normals for the faces
  fn = cross([vertices(faces(:,2),:)-vertices(faces(:,1),:)],...
             [vertices(faces(:,3),:)-vertices(faces(:,1),:)]);
  normals = zeros(m*n,3);
  
  % Loop through vertices, slow
  % for ii = 1:m*n
  %  idx = any(faces==ii,2);
  %  vn = sum(fn(idx,:),1);
  %  normals(ii,:) = vn / sqrt(vn*vn');
  % end

  % Loop through faces, somewhat faster but still slow because of the loop
  nfaces = m*n*2;
  for ii = 1:nfaces
    normals(faces(ii,:),:) = normals(faces(ii,:),:) + [1 1 1]'*fn(ii,:);
  end
  normals = normals./sqrt(sum(normals.^2,2)*[1 1 1]);

  clear fn
end

%--------------------------------------------
% Output argument

t.faces = faces;
if ~isempty(t.mtlfilename)
  t.uvcoords = uvcoords;
end
if t.comp_normals
  t.normals = normals;
end

%--------------------------------------------
% Write to file

fid = fopen(t.filename,'w');
fprintf(fid,'# %s\n',datestr(now,31));
for ii = 1:length(t.prm)
  if ii==1 verb = 'Created'; else verb = 'Modified'; end 
  fprintf(fid,'# %d. %s with function %s from ShapeToolbox.\n',ii,verb,t.prm(ii).mfilename);
end
fprintf(fid,'#\n# Number of vertices: %d.\n',size(vertices,1));
fprintf(fid,'# Number of faces: %d.\n',size(faces,1));
if isempty(t.mtlfilename)
  fprintf(fid,'# Texture (uv) coordinates defined: No.\n');
else
  fprintf(fid,'# Texture (uv) coordinates defined: Yes.\n');
end
if t.comp_normals
  fprintf(fid,'# Vertex normals included: Yes.\n');
else
  fprintf(fid,'# Vertex normals included: No.\n');
end

for ii = 1:length(t.prm)
  fprintf(fid,'#\n# %s\n# %d. %s:\n',repmat('-',1,50),ii,t.prm(ii).mfilename);
  switch t.prm(ii).mfilename
    case 'objMakeTorus'
      writeSpecs(fid,t.prm(ii).cprm,t.prm(ii).mprm);
    case 'objMakeTorusBumpy'
      writeSpecsBumpy(fid,t.prm(ii).prm);
    case 'objMakeTorusNoisy'
      writeSpecsNoisy(fid,t.prm(ii).nprm,t.prm(ii).mprm);
      if t.prm(ii).use_rms
        fprintf(fid,'# Use RMS contrast: Yes.\n');
      else
        fprintf(fid,'# Use RMS contrast: No.\n');
      end
    case 'objMakeTorusCustom'
      writeSpecsCustom(fid,t.prm(ii))
  end
end

fprintf(fid,'#\n# Phase and angle (if present) are in radians above.\n');

if isempty(t.mtlfilename)
  fprintf(fid,'\n\n# Vertices:\n');
  fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
  fprintf(fid,'# End vertices\n');
  if t.comp_normals
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
  fprintf(fid,'\nmtllib %s\nusemtl %s\n',t.mtlfilename,t.mtlname);
  fprintf(fid,'\n# Vertices:\n');
  fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
  fprintf(fid,'# End vertices\n\n# Texture coordinates:\n');
  fprintf(fid,'vt %8.6f %8.6f\n',uvcoords');
  fprintf(fid,'# End texture coordinates\n');
  if t.comp_normals
    fprintf(fid,'\n# Normals:\n');
    fprintf(fid,'vn %8.6f %8.6f %8.6f\n',normals');
    fprintf(fid,'# End normals\n');
    fprintf(fid,'\n# Faces:\n');
    fprintf(fid,'f %d/%d/%d %d/%d/%d %d/%d/%d\n',...
            [faces(:,1) facestxt(:,1) faces(:,1)...
             faces(:,2) facestxt(:,2) faces(:,2)...
             faces(:,3) facestxt(:,3) faces(:,3)]');
  else
    fprintf(fid,'\n# Faces:\n');
    fprintf(fid,'f %d/%d %d/%d %d/%d\n',[faces(:,1) facestxt(:,1) faces(:,2) facestxt(:,2) faces(:,3) facestxt(:,3)]');
  end
  fprintf(fid,'# End faces\n');
end
fclose(fid);

%--------------------------------------------
% Functions to write the modulation specs; these are called above

function writeSpecs(fid,cprm,mprm)

nccomp = size(cprm,1);
nmcomp = size(mprm,1);

fprintf(fid,'#\n# Modulation carrier parameters (each row is one component):\n');
fprintf(fid,'#  Frequency | Amplitude | Phase | Angle | Group\n');
for ii = 1:nccomp
  fprintf(fid,'#     %6.2f      %6.2f  %6.2f  %6.2f       %d\n',cprm(ii,:));
end

if ~isempty(mprm)
  fprintf(fid,'#\n# Modulator parameters (each row is one component):\n');
  fprintf(fid,'#  Frequency | Amplitude | Phase | Angle | Group\n');
  for ii = 1:nmcomp
    fprintf(fid,'#     %6.2f      %6.2f  %6.2f  %6.2f       %d\n',mprm(ii,:));
  end
end

function writeSpecsBumpy(fid,prm)

nbumptypes = size(prm,1);

fprintf(fid,'#\n# Gaussian bump parameters (each row is bump type):\n');
fprintf(fid,'#  # of bumps | Amplitude | Sigma\n');
for ii = 1:nbumptypes
  fprintf(fid,'#  %10d   %9.2f   %5.2f\n',prm(ii,:));
end

function writeSpecsNoisy(fid,nprm,mprm)

nncomp = size(nprm,1);
nmcomp = size(mprm,1);

fprintf(fid,'#\n# Noise carrier parameters (each row is one component):\n');
fprintf(fid,'#  Frequency | FWHH | Angle | FWHH | Amplitude | Group\n');
for ii = 1:nncomp
  fprintf(fid,'#  %9.2f   %4.2f   %5.2f   %4.2f   %9.2f       %d\n',nprm(ii,:));
end

if ~isempty(mprm)
  fprintf(fid,'#\n# Modulator parameters (each row is one component):\n');
  fprintf(fid,'#  Frequency | Amplitude | Phase | Angle | Group\n');
  for ii = 1:nmcomp
    fprintf(fid,'#     %6.2f      %6.2f  %6.2f  %6.2f       %d\n',mprm(ii,:));
  end
end

function writeSpecsCustom(fid,prm)

if prm.use_map
  if isfield(prm,'imgname')
     fprintf(fid,'#\n# Modulation values defined by the (average) intensity\n');
     fprintf(fid,'# of the image %s.\n',prm.imgname);
  else
     fprintf(fid,'#\n# Modulation values defined by a custom matrix.\n');
  end
else    
  fprintf(fid,'#\n#  Modulation defined by a custom user-defined function.\n');
  fprintf(fid,'#  Modulation parameters:\n');
  fprintf(fid,'#  # of locations | Cut-off dist. | Custom function arguments\n');
  for ii = 1:prm.nbumptypes
    fprintf(fid,'#  %14d   %13.2f   ',prm.prm(ii,1:2));
    fprintf(fid,'%5.2f  ',prm.prm(ii,3:end));
    fprintf(fid,'\n');
  end
end
