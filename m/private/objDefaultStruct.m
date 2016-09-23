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
% 2015-10-08 - ts - added 'spinex' and 'spinez' variables
% 2015-10-10 - ts - added support for worm shape
% 2015-10-14 - ts - added max -flag
% 2015-10-15 - ts - changed default sizes
% 2015-10-20 - ts - changed default for scaley to false
% 2016-01-19 - ts - added disk shape
% 2016-01-22 - ts - added index for the number of "layers"
% 2016-05-27 - ts - groups
% 2016-05-30 - ts - flags for uv and normals are saved when resetting

if nargin<2 || isempty(reset)
  reset = false;
end

if ~reset
  switch shape
    case 'sphere'
      model.m = 64;
      model.n = 128;
      model.radius = 1;
    case 'plane'
      model.m = 128;
      model.n = 128;
      model.width = 1;
      model.height = 1;
    case {'cylinder','revolution','extrusion','worm'}
      model.m = 128;
      model.n = 128;
      model.radius = 1;
      model.height = 2*pi*model.radius;
      model.spine.x = zeros(1,model.m);
      model.spine.y = linspace(-model.height/2,model.height/2,model.m);
      model.spine.z = zeros(1,model.m);
    case 'torus'
      model.m = 128;
      model.n = 128;
      model.tube_radius = 0.4;
      model.radius = 1;
      model.opts.rprm = [];
    case {'disk','disc'}
      shape = 'disk';
      model.m = 128; 
      model.n = 128;
      model.radius = 1;
      model.opts.coords = 'polar';
    otherwise
      error('Unknown shape.');
  end
  model.shape = shape;
  model.filename = [model.shape,'.obj'];
  model.flags.new_model = true;
  model.flags.caps = false;
  model.flags.comp_uv = false;
  model.flags.comp_normals = false;
  model.idx = 1;
else
  model = shape;
  model.flags.new_model = false;
  model.flags.oldcaps = model.flags.caps;
  model.idx = length(model.prm)+1;
end

model.mtlfilename = '';
model.mtlname = '';
model.normals = [];
model.opts.mindist = 0;
model.opts.locations = {};

model.flags.dosave = false;
model.flags.use_rms = false;
model.flags.use_map = false;
model.flags.custom_locations = false;
model.flags.scaley = false;
model.flags.max = false;

model.group.idx = 1;
model.flags.write_groups = false;
