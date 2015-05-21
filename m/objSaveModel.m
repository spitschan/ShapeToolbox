function s = objSaveModel(s)

% OBJSAVEMODEL
%
% Usage: model = objSaveModel(model)
%
% A function called by the objMake*-functions to compute
% texture coordinates, faces, and so forth; and to write the model
% to a file.
%
% I'd love to start the names of these helper functions with an
% underscore (_) to make it clear they're helper functions not to
% be directly called by the user, but Matlab doesn't allow it
% (Octave allows it.  Use Octave.)

% Copyright (C) 2015 Toni Saarela
% 2015-04-06 - ts - first version, based on the model-type-specific
%                    functions
% 2015-05-04 - ts - uses option comp_uv for uv-coords instead of
%                    checking whether mtl filename is empty
% 2015-05-07 - ts - bettered the writing of vertices etc to file.
%                    it's better now.
% 2015-05-12 - ts - plane width and height are now 2, changed freq conversion
% 2015-05-18 - ts - added new model shape, 'extrusion'

m = s.m;
n = s.n;
vertices = s.vertices;

%--------------------------------------------
% Faces, vertex indices

switch s.shape
  case {'sphere','cylinder','revolution','extrusion'}
    faces = zeros((m-1)*n*2,3);
    F = ([1 1]'*[1:n]);
    F = F(:) * [1 1 1];
    F(:,2) = F(:,2) + [repmat([n+1 1]',[n-1 1]); [1 1-n]'];
    F(:,3) = F(:,3) + [repmat([n n+1]',[n-1 1]); [n 1]'];
    for ii = 1:m-1
      faces((ii-1)*n*2+1:ii*n*2,:) = (ii-1)*n + F;
    end
  case 'plane'
    faces = zeros((m-1)*(n-1)*2,3);
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
  case 'torus'
    faces = zeros(m*n*2,3);
    % The first part is the same as with the sphere:
    F = ([1 1]'*[1:n]);
    F = F(:) * [1 1 1];
    F(:,2) = F(:,2) + [repmat([n+1 1]',[n-1 1]); [1 1-n]'];
    F(:,3) = F(:,3) + [repmat([n n+1]',[n-1 1]); [n 1]'];
    % But loop until m, not m-1 as phi goes -pi to pi here (not -pi/2 to
    % pi/2) and faces wrap around the "tube".
    for ii = 1:m
      faces((ii-1)*n*2+1:ii*n*2,:) = (ii-1)*n + F;
    end
    % Finally, to wrap around properly in the phi-direction:
    faces = 1 + mod(faces-1,m*n);
end

% Texture coordinates if material is defined
if s.comp_uv
  switch s.shape
    case {'sphere','cylinder','revolution','extrusion'}
      u = linspace(0,1,n+1);
      v = linspace(0,1,m);
      [U,V] = meshgrid(u,v);
      U = U'; V = V';
      uvcoords = [U(:) V(:)];

      % Faces, uv coordinate indices
      facestxt = zeros((m-1)*n*2,3);
      n2 = n + 1;
      F = ([1 1]'*[1:n]);
      F = F(:) * [1 1 1];
      F(:,2) = reshape([1 1]'*[2:n2]+[1 0]'*n2*ones(1,n),[2*n 1]);
      F(:,3) = n2 + [1; reshape([1 1]'*[2:n],[2*(n-1) 1]); n2];
      for ii = 1:m-1
        facestxt((ii-1)*n*2+1:ii*n*2,:) = (ii-1)*n2 + F;
      end
    case 'plane'
      U = (s.X-min(s.X))/(max(s.X)-min(s.X));
      V = (s.Y-min(s.Y))/(max(s.Y)-min(s.Y));
      uvcoords = [U V];

      facestxt = faces;

    case 'torus'
      u = linspace(0,1,n+1);
      v = linspace(0,1,m+1);
      [U,V] = meshgrid(u,v);
      U = U'; V = V';
      uvcoords = [U(:) V(:)];

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
  clear u v U V


end

%--------------------------------------------
% Vertex normals
if s.comp_normals
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

  % Loop through faces, somewhat faster but still slow
  switch s.shape
    case {'sphere','cylinder','revolution','extrusion'}
      nfaces = (m-1)*n*2;
    case 'plane'
      nfaces = (m-1)*(n-1)*2;
    case 'torus'
      nfaces = m*n*2;
  end
  for ii = 1:nfaces
    normals(faces(ii,:),:) = normals(faces(ii,:),:) + [1 1 1]'*fn(ii,:);
  end
  normals = normals./sqrt(sum(normals.^2,2)*[1 1 1]);

  clear fn
end

%--------------------------------------------
% Output argument

s.faces = faces;
if s.comp_uv
  s.uvcoords = uvcoords;
end
if s.comp_normals
  s.normals = normals;
end

%--------------------------------------------
% Write to file

fid = fopen(s.filename,'w');
fprintf(fid,'# %s\n',datestr(now,31));
if length(s.prm)==1
   fprintf(fid,'# Created with function %s from ShapeToolbox.\n',s.prm.mfilename);
else
  for ii = 1:length(s.prm)
    if ii==1 verb = 'Created'; else verb = 'Modified'; end 
    fprintf(fid,'# %d. %s with function %s from ShapeToolbox.\n',ii,verb,s.prm(ii).mfilename);
  end
end
fprintf(fid,'#\n# Number of vertices: %d.\n',size(vertices,1));
fprintf(fid,'# Number of faces: %d.\n',size(faces,1));

if s.comp_uv
  fprintf(fid,'# Texture (uv) coordinates defined: Yes.\n');
else
  fprintf(fid,'# Texture (uv) coordinates defined: No.\n');
end

if s.comp_normals
  fprintf(fid,'# Vertex normals included: Yes.\n');
else
  fprintf(fid,'# Vertex normals included: No.\n');
end

modsine = {'objMakeSphere','objMakePlane',...
           'objMakeCylinder','objMakeTorus',...
           'objMakeRevolution','objMakeExtrusion'};
modnoise = {'objMakeSphereNoisy','objMakePlaneNoisy',...
           'objMakeCylinderNoisy','objMakeTorusNoisy',...
           'objMakeRevolutionNoisy','objMakeExtrusionNoisy'};
modbumpy = {'objMakeSphereBumpy','objMakePlaneBumpy',...
           'objMakeCylinderBumpy','objMakeTorusBumpy',...
           'objMakeRevolutionBumpy','objMakeExtrusionBumpy'};
modcustom = {'objMakeSphereCustom','objMakePlaneCustom',...
           'objMakeCylinderCustom','objMakeTorusCustom',...
           'objMakeRevolutionCustom','objMakeExtrusionCustom'};

for ii = 1:length(s.prm)
    if length(s.prm)==1
      fprintf(fid,'#\n# %s\n# %s parameters:\n',repmat('-',1,50),s.prm(ii).mfilename);
    else
      fprintf(fid,'#\n# %s\n# %d. %s parameters:\n',repmat('-',1,50),ii,s.prm(ii).mfilename);
    end
  switch s.prm(ii).mfilename
    %---------------------------------------------------
    case modsine
      if strcmp(s.shape,'plane')
        %- Convert frequencies back to cycles/plane
        s.prm(ii).cprm(:,1) = s.prm(ii).cprm(:,1)/(pi);
        if ~isempty(s.prm(ii).mprm)
          s.prm(ii).mprm(:,1) = s.prm(ii).mprm(:,1)/(pi);
        end         
      end
      writeSpecs(fid,s.prm(ii).cprm,s.prm(ii).mprm);
    %---------------------------------------------------
    case modbumpy
      writeSpecsBumpy(fid,s.prm(ii).prm);
    %---------------------------------------------------
    case modnoise
      if strcmp(s.shape,'plane')
        %- Convert frequencies back to cycles/plane
        if ~isempty(s.prm(ii).mprm)
          s.prm(ii).mprm(:,1) = s.prm(ii).mprm(:,1)/(pi);
        end
      end
      writeSpecsNoisy(fid,s.prm(ii).nprm,s.prm(ii).mprm);
      if s.prm(ii).use_rms
        fprintf(fid,'# Use RMS contrast: Yes.\n');
      else
        fprintf(fid,'# Use RMS contrast: No.\n');
      end
    %---------------------------------------------------
    case modcustom
      writeSpecsCustom(fid,s.prm(ii))
    %---------------------------------------------------
 end
end

fprintf(fid,'#\n# Phase and angle (if present) are in radians above.\n');

if ~isempty(s.mtlfilename)
  fprintf(fid,'\n# Materials:\nmtllib %s\nusemtl %s\n',s.mtlfilename,s.mtlname);
end

fprintf(fid,'\n# Vertices:\n');
fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
fprintf(fid,'# End vertices\n');

if s.comp_uv
  fprintf(fid,'\n# Texture coordinates:\n');
  fprintf(fid,'vt %8.6f %8.6f\n',uvcoords');
  fprintf(fid,'# End texture coordinates\n');
end

if s.comp_normals
  fprintf(fid,'\n# Normals:\n');
  fprintf(fid,'vn %8.6f %8.6f %8.6f\n',normals');
  fprintf(fid,'# End normals\n');
end

# Write face defitions to file.  These are written differently
# depending on whether uvcoordinates and/or normals are included.
fprintf(fid,'\n# Faces:\n');
if ~s.comp_uv
  if s.comp_normals
    fprintf(fid,'f %d//%d %d//%d %d//%d\n',...
            [faces(:,1) faces(:,1) ...
             faces(:,2) faces(:,2) ...
             faces(:,3) faces(:,3)]');
  else
    fprintf(fid,'f %d %d %d\n',faces');    
  end
else
  if s.comp_normals
    fprintf(fid,'f %d/%d/%d %d/%d/%d %d/%d/%d\n',...
            [faces(:,1) facestxt(:,1) faces(:,1)...
             faces(:,2) facestxt(:,2) faces(:,2)...
             faces(:,3) facestxt(:,3) faces(:,3)]');
  else
    fprintf(fid,'f %d/%d %d/%d %d/%d\n',...
            [faces(:,1) facestxt(:,1) ...
             faces(:,2) facestxt(:,2) ...
             faces(:,3) facestxt(:,3)]');
  end
end
fprintf(fid,'# End faces\n');
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
