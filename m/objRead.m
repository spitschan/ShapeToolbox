function model = objRead(fn)

% OBJREAD
%
% Usage: MODEL = OBJREAD(FILENAME)
%
% Try to read vertex data from file FILENAME.  The file should be in
% Wavefront obj format.  Only the vertex data are read at the moment.
%
% The function returns a model structure that holds the vertex data.
% This model can be viewed with objShow.  objShow needs to know the
% size of the mesh, saved in the model structure in fields m and n.
% objRead assumes the mesh is square, in other words, that
% m=n=sqrt(n_of_vertices).  If this is not the case, viewing with
% objShow does not work.  If you know the size of the mesh, you can
% set the values of m and n manually.
%
% Note that this function is very limited.  It is not meant as a
% general-purpose function for reading Wavefront obj files.  It should
% work reasonably well for files written by ShapeToolbox.
% 
% Example:
% model = objRead('my_funky_object.obj');
% objShow(model);
%
% model = objRead('my_funky_object.obj');
% model.m = 64;
% model.n = 32;
% objShow(model);

% Copyright (C) 2015 Toni Saarela
% 2015-06-04 - ts - first version
% 2015-06-05 - ts - fixed a string quote bug

model.vertices = [];

fp = fopen(fn,'r');
s = fgetl(fp);
while isempty(regexp(s,'^v\s+'))
  s = fgetl(fp);
end

val = sscanf(s,'v %f %f %f')';
ii = 1;
while ~isempty(val)
  model.vertices(ii,:) = val;
  s = fgetl(fp);
  val = sscanf(s,'v %f %f %f')';
  ii = ii + 1;
end
fclose(fp);

model.m = sqrt(ii-1);
model.n = model.m;
