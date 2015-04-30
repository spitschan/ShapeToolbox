function p = objSaveModelPlane(p)

% OBJSAVEMODELPLANE
%
% Usage: plane = objSaveModelPlane(plane)
%
% A function called by the objMakePlane*-functions to compute
% texture coordinates, faces, and so forth; and to write the model
% to a file.

% Copyright (C) 2015 Toni Saarela
% 2015-04-03 - ts - first version, based on objMakePlane*-functions

m = p.m;
n = p.n;
vertices = p.vertices;

%--------------------------------------------
% Texture coordinates if material is defined
if ~isempty(p.mtlfilename)
  U = (p.X-min(p.X))/(max(p.X)-min(p.X));
  V = (p.Y-min(p.Y))/(max(p.Y)-min(p.Y));
  uvcoords = [U V];
end

%--------------------------------------------
% Faces, vertex indices
faces = zeros((m-1)*(n-1)*2,3);

% Matlab does not allow the [](:) syntax below (Octave does; use
% Octave) , so had to rewrite it using a temporary variable.  Uglier,
% but surprisingly it's faster.
%F(:,1) = [[1 1]'*[1:n-1]](:);
%F(:,2) = [n+2:2*n; 2:n](:);
%F(:,3) = [[[1 1]' * [n+1:2*n]](:)](2:end-1);

ftmp = [[1 1]'*[1:n-1]];
F(:,1) = ftmp(:);
% OR:
%F(:,1) = ceil([1:(2*n-2)]'/2);
ftmp = [n+2:2*n; 2:n];
F(:,2) = ftmp(:);
ftmp = [[1 1]' * [n+1:2*n]];
ftmp = ftmp(:);
F(:,3) = ftmp(2:end-1);

for ii = 1:m-1
  faces((ii-1)*(n-1)*2+1:ii*(n-1)*2,:) = (ii-1)*n + F;
end

%--------------------------------------------
% Vertex normals
if p.comp_normals
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

  % Loop through faces, somewhat faster but still slow because of the loop
  nfaces = (m-1)*(n-1)*2;
  for ii = 1:nfaces
    normals(faces(ii,:),:) = normals(faces(ii,:),:) + [1 1 1]'*fn(ii,:);
  end
  normals = normals./sqrt(sum(normals.^2,2)*[1 1 1]);

  clear fn
end

%--------------------------------------------
% Output argument
p.faces = faces;
if ~isempty(p.mtlfilename)
  p.uvcoords = uvcoords;
end
if p.comp_normals
  p.normals = normals;
end

%--------------------------------------------
% Write to file


fid = fopen(p.filename,'w');
fprintf(fid,'# %s\n',datestr(now,31));
for ii = 1:length(p.prm)
  if ii==1 verb = 'Created'; else verb = 'Modified'; end 
  fprintf(fid,'# %d. %s with function %s from ShapeToolbox.\n',ii,verb,p.prm(ii).mfilename);
end
fprintf(fid,'#\n# Number of vertices: %d.\n',size(vertices,1));
fprintf(fid,'# Number of faces: %d.\n',size(faces,1));
if isempty(p.mtlfilename)
  fprintf(fid,'# Texture (uv) coordinates defined: No.\n');
else
  fprintf(fid,'# Texture (uv) coordinates defined: Yes.\n');
end
if p.comp_normals
  fprintf(fid,'# Vertex normals included: Yes.\n');
else
  fprintf(fid,'# Vertex normals included: No.\n');
end

for ii = 1:length(p.prm)
  fprintf(fid,'#\n# %s\n# %d. %s:\n',repmat('-',1,50),ii,p.prm(ii).mfilename);
  switch p.prm(ii).mfilename
    case 'objMakePlane'
      %- Convert frequencies back to cycles/plane
      p.prm(ii).cprm(:,1) = p.prm(ii).cprm(:,1)/(2*pi);
      if ~isempty(p.prm(ii).mprm)
        p.prm(ii).mprm(:,1) = p.prm(ii).mprm(:,1)/(2*pi);
      end
      writeSpecs(fid,p.prm(ii).cprm,p.prm(ii).mprm);
    case 'objMakePlaneNoisy'
      %- Convert frequencies back to cycles/plane
      if ~isempty(p.prm(ii).mprm)
        p.prm(ii).mprm(:,1) = p.prm(ii).mprm(:,1)/(2*pi);
      end
      writeSpecsNoisy(fid,p.prm(ii).nprm,p.prm(ii).mprm);
      if p.prm(ii).use_rms
        fprintf(fid,'# Use RMS contrast: Yes.\n');
      else
        fprintf(fid,'# Use RMS contrast: No.\n');
      end
    case 'objMakePlaneBumpy'
      writeSpecsBumpy(fid,p.prm(ii).prm)
    case 'objMakePlaneCustom'
      writeSpecsCustom(fid,p.prm(ii))
  end
end

fprintf(fid,'#\n# Phase and angle (if present) are in radians above.\n');

if isempty(p.mtlfilename)
  fprintf(fid,'\n\n# Vertices:\n');
  fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
  fprintf(fid,'# End vertices\n');
  if p.comp_normals
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
  fprintf(fid,'\nmtllib %s\nusemtl %s\n',p.mtlfilename,p.mtlname);
  fprintf(fid,'\n# Vertices:\n');
  fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
  fprintf(fid,'# End vertices\n\n# Texture coordinates:\n');
  fprintf(fid,'vt %8.6f %8.6f\n',uvcoords');
  fprintf(fid,'# End texture coordinates\n');
  if p.comp_normals
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
