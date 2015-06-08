function model = objRead(fn)

% OBJREAD
%
% Usage: MODEL = OBJREAD(FILENAME)
%
% Try to read vertex, vertex normal, texture coordinate, and face data
% from the Wavefront obj file FILENAME.
%
% The function returns a model structure that holds the vertex and
% other data.  This model can be viewed with objShow.  objShow needs 
% to know the size of the mesh, saved in the model structure in fields
% m and n.  objRead assumes the mesh is square, in other words, that
% m=n=sqrt(n_of_vertices).  If this is not the case, viewing with
% objShow does not work.  If you know the size of the mesh, you can
% set the values of m and n manually.
%
% Note that this function is very limited.  It is not meant as a
% general-purpose function for reading Wavefront obj files.  It only
% reads the vertex, texture coordinate, normal, and face data from a
% well-structured file.   It should work reasonably well for files
% written by ShapeToolbox though
% 
% Example:
% model = objRead('my_funky_object.obj');
% objShow(model);
%
% % Note that in the above example you could also just do:
% objShow('my_funky_object.obj')
%
% model = objRead('my_funky_object.obj');
% model.m = 50;
% model.n = 40;
% objShow(model);

% Copyright (C) 2015 Toni Saarela
% 2015-06-04 - ts - first version
% 2015-06-05 - ts - fixed a string quote bug
% 2015-06-06 - ts - reads normals, uv, faces in addition to vertex data

model.vertices = zeros(1e5,3);
model.normals = zeros(1e5,3);
model.uvcoords = zeros(1e5,2);
model.faces = zeros(2e5,3);

nv = 0;
nn = 0;
nt = 0;
nf = 0;

fp = fopen(fn,'r');
s = fgetl(fp);
ii = 1;
while ischar(s)
  % if ~isempty(regexp(s,'^v\s+'))
  if strncmp(s,'v ',2)
    val = sscanf(s,'v %f %f %f')';
    nv = nv + 1;
    model.vertices(nv,:) = val;
  % elseif ~isempty(regexp(s,'^vn\s+'))
  elseif strncmp(s,'vn ',2)
    val = sscanf(s,'vn %f %f %f')';
    nn = nn + 1;
    model.normals(nn,:) = val;
  % elseif ~isempty(regexp(s,'^vt\s+'))
  elseif strncmp(s,'vt ',2)
    val = sscanf(s,'vt %f %f')';
    nt = nt + 1;
    model.uvcoords(nt,:) = val;
  % elseif ~isempty(regexp(s,'^f\s+'))
  elseif strncmp(s,'f ',2)
    val = sscanf(s,'f %d %d %d')';
    nf = nf + 1;
    model.faces(nf,:) = val;
  end
  ii = ii + 1;
  s = fgetl(fp);
end

fclose(fp);

if nv
   model.vertices = model.vertices(1:nv,:);
else
  model.vertices = [];
end

if nn
   model.normals = model.normals(1:nn,:);
else
  model.normals = [];
end

if nt
   model.uvcoords = model.uvcoords(1:nt,:);
else
  model.uvcoords = [];
end

if nf
   model.faces = model.faces(1:nf,:);
else
  model.faces = [];
end

% while isempty(regexp(s,'^v\s+'))
%   s = fgetl(fp);
% end

% val = sscanf(s,'v %f %f %f')';
% ii = 1;
% while ~isempty(val)
%   model.vertices(ii,:) = val;
%   s = fgetl(fp);
%   val = sscanf(s,'v %f %f %f')';
%   ii = ii + 1;
% end
% fclose(fp);

model.m = int32(sqrt(nv));
if model.m^2==nv
  model.n = model.m;
else
  model.m = [];
  model.n = [];
end
