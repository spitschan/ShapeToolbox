function model = objDefaultStruct(shape,reset)

% OBJDEFAULTSTRUCT
%
% model = objDefaultStruct(shape)
%
% Called by objMake*-functions.

% Copyright (C) 2015 Toni Saarela
% 2015-05-30 - ts - first version
% 2015-05-31 - ts - added the 'reset'-option
% 2015-06-03 - ts - new flag to indicate custom locations are set
% 2015-06-05 - ts - flag to indicate "caps" on cylinders etc
% 2015-06-10 - ts - set default radius, width, height here
% 2015-06-16 - ts - changed default value for dosave to false
%                   added setting default file name

if nargin<2 || isempty(reset)
  reset = false;
end

if ~reset
  switch shape
    case 'sphere'
      model.m = 128;
      model.n = 256;
      model.radius = 1;
    case 'plane'
      model.m = 256;
      model.n = 256;
      model.width = 1;
      model.height = 1;
    case {'cylinder','revolution','extrusion'}
      model.m = 256;
      model.n = 256;
      model.radius = 1;
      model.height = 2*pi*model.radius;
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
  model.filename = [model.shape,'.obj'];
  model.flags.new_model = true;
  model.flags.caps = false;
else
  model = shape;
  model.flags.new_model = false;
  model.flags.oldcaps = model.flags.caps;
end

model.mtlfilename = '';
model.mtlname = '';
model.normals = [];
model.opts.mindist = 0;
model.opts.locations = {};

model.flags.dosave = false;
model.flags.comp_uv = false;
model.flags.comp_normals = false;
model.flags.use_rms = false;
model.flags.use_map = false;
model.flags.custom_locations = false;
