function model = objDefaultStruct(shape,reset)

% OBJDEFAULTSTRUCT
%
% model = objDefaultStruct(shape)
%
% Called by objMake*-functions.

% Copyright (C) 2015 Toni Saarela
% 2015-05-30 - ts - first version
% 2015-05-31 - ts - added the 'reset'-option

if nargin<2 || isempty(reset)
  reset = false;
end

if ~reset
  switch shape
    case 'sphere'
      model.m = 128;
      model.n = 256;
    case 'plane'
      model.m = 256;
      model.n = 256;
    case {'cylinder','revolution','extrusion'}
      model.m = 256;
      model.n = 256;
    case 'torus'
      model.m = 256;
      model.n = 256;
      model.tube_radius = 0.4;
      model.radius = 1;
      model.opts.rprm = [];
    otherwise
      error('Unknown shape.');
  end
  model.shape = shape;
  model.flags.new_model = true;
else
  model = shape;
  model.flags.new_model = false;
end

model.mtlfilename = '';
model.mtlname = '';
model.normals = [];
model.opts.mindist = 0;
model.opts.locations = {};

model.flags.dosave = true;
model.flags.comp_uv = false;
model.flags.comp_normals = false;
model.flags.use_rms = false;
model.flags.use_map = false;
