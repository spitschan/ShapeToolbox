function model = objParseCustomParams(model,f,prm)

% OBJPARSECUSTOMPARAMS
%
% model = objParseCustomParams(model,f,prm)

% Copyright (C) 2015 Toni Saarela
% 2015-05-30 - ts - first version
% 2015-10-15 - ts - fixed a bug (use_map was not set with matrix input)

if ischar(f)
  model.opts.imgname = f;
  map = double(imread(model.opts.imgname));
  if ndims(map)>2
    map = mean(map,3);
  end

  model.opts.map = flipud(map/max(map(:)));  

  model.opts.ampl = prm(1);
  model.opts.prm = [];

  [model.opts.mmap,model.opts.nmap] = size(model.opts.map);
  model.m = model.opts.mmap;
  model.n = model.opts.nmap;

  model.flags.use_map = true;

  clear f

elseif isnumeric(f)
  map = f;
  if ndims(map)~=2
    error('The input matrix has to be two-dimensional.');
  end

  model.opts.map = flipud(map/max(abs(map(:))));

  model.opts.ampl = prm(1);
  model.opts.prm = [];

  [model.opts.mmap,model.opts.nmap] = size(model.opts.map);
  model.m = model.opts.mmap;
  model.n = model.opts.nmap;

  model.flags.use_map = true;

  clear f

elseif isa(f,'function_handle')
  model.opts.f = f;
  model.opts.prm = prm;
  [model.opts.nbumptypes,ncol] = size(prm);
  model.opts.nbumps = sum(prm(:,1));
end
