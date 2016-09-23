function model = objParseCustomParams(model)

% OBJPARSECUSTOMPARAMS
%
% model = objParseCustomParams(model,f,prm)

% Copyright (C) 2015 Toni Saarela
% 2015-05-30 - ts - first version
% 2015-10-15 - ts - fixed a bug (use_map was not set with matrix input)
% 2016-02-19 - ts - moved things from model.opts to model.prm(model.idx)

ii = model.idx;
f = model.opts.f;
prm = model.opts.prm;
model.opts.f = [];
model.opts.prm = [];

if ischar(f)
  model.prm(ii).imgname = f;
  map = double(imread(model.prm(ii).imgname));
  if ndims(map)>2
    map = mean(map,3);
  end

  model.prm(ii).map = flipud(map/max(map(:)));  

  model.prm(ii).ampl = prm(1);

  [model.prm(ii).mmap,model.prm(ii).nmap] = size(model.prm(ii).map);
  model.m = model.prm(ii).mmap;
  model.n = model.prm(ii).nmap;

  model.flags.use_map = true;

  clear f

elseif isnumeric(f)
  map = f;
  if ndims(map)~=2
    error('The input matrix has to be two-dimensional.');
  end

  model.prm(ii).map = flipud(map/max(abs(map(:))));

  model.prm(ii).ampl = prm(1);

  [model.prm(ii).mmap,model.prm(ii).nmap] = size(model.prm(ii).map);
  model.m = model.prm(ii).mmap;
  model.n = model.prm(ii).nmap;

  model.flags.use_map = true;

  clear f

elseif isa(f,'function_handle')
  model.prm(ii).f = f;
  model.prm(ii).prm = prm;
  [model.prm(ii).nbumptypes,ncol] = size(prm);
  model.prm(ii).nbumps = sum(prm(:,1));
end

% This is a terrible hack to make objSave work in case another
% objMake*-function is used *after* objMakeCustom.  Other functions
% reset the flag use_map to false, and then objSave will always try to
% write "bump" specs into the obj-file comments.  This fails if a map
% had actually been used.  For a quick fix, save the flag in the
% parameter group and use that.  But now we have the same flag in two
% places.  Terrible hack.  Terrible.  Terrible.
model.prm(ii).use_map = model.flags.use_map;
