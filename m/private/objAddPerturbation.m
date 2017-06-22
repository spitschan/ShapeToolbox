function model = objAddPerturbation(model)

% OBJADDPERTURBATION
%
% Usage: MODEL = OBJADDPERTURBATION(MODEL)

% Copyright (C) 2016 Toni Saarela
% 2016-01-22 - ts - first version, based on old objMake*-functions
% 2016-01-28 - ts - more shapes supported
% 2016-02-19 - ts - custom perturbations
% 2016-02-19 - ts - function handle moved from model.opts.f 
%                   to model.prm(model.idx).f
% 2016-04-14 - ts - small bug fix related to the change above
% 2016-12-17 - ts - new arg order in prm vector
% 2017-05-26 - ts - fixed a bug in polar/cart conversion when
%                    switching between coord systems
% 2017-05-26 - ts - changed the order of parameters for torus
%                     radius modulation
% 2017-06-08 - ts - don't add the perturbations immediately but
%                     stack them, add at the end for more flexibility
% 2017-06-22 - ts - bug fix: plane+noise handled same way as others
%                   cleaned up sine, noise computation
  
% TODO: 
% - objRemCaps for worm
% - perturbation normal to the surface
% - you now use both model.idx and ii to index the current
%   parameter set. unify.
  
  switch model.shape
    case {'cylinder','revolution','extrusion'}    
      if ~model.flags.new_model && model.flags.oldcaps
        model = objRemCaps(model);
      end
    case 'torus'
      if ~isempty(model.opts.rprm)
        rprm = model.opts.rprm;
        for ii = 1:size(rprm,1)
          model.R = model.R + rprm(ii,3) * sin(rprm(ii,1)*model.Theta + rprm(ii,2));
        end
      end
  end

  
  ii = model.idx;
  switch model.prm(ii).perturbation
    case 'none'
      model.P(:,model.idx) = zeros(model.m*model.n,1);
      
    %------------------------------------------------------------
    case 'sine'
      [model.prm(model.idx).nccomp,ncol] = size(model.prm(model.idx).cprm);
      if strcmp(model.shape,'plane')
        model.prm(model.idx).cprm(:,1) = model.prm(model.idx).cprm(:,1)*2*pi;
      end
      model.prm(model.idx).cprm(:,2:3) = pi * model.prm(model.idx).cprm(:,2:3)/180;
      if ncol==4
        model.prm(model.idx).cprm(:,5) = 0; 
      end
      if ~isempty(model.prm(model.idx).mprm)
        [model.prm(model.idx).nmcomp,ncol] = size(model.prm(model.idx).mprm);
        if strcmp(model.shape,'plane')
          model.prm(model.idx).mprm(:,1) = model.prm(model.idx).mprm(:,1)*2*pi;
        end
        model.prm(model.idx).mprm(:,2:3) = pi * model.prm(model.idx).mprm(:,2:3)/180;
        if ncol==4
          model.prm(model.idx).mprm(:,5) = 0; 
        end
      end

      cprm = model.prm(model.idx).cprm;
      mprm = model.prm(model.idx).mprm;
      
      switch model.opts.coords
        case {'spherical','torus'}
          X = model.Theta;
          Y = model.Phi;
        case 'cartesian'
          X = model.X;
          Y = model.Y;
        case 'polar'
          X = model.Theta;
          Y = model.R;
        case 'cylindrical'
          X = model.Theta;
          Y = model.Y;
      end

      model.P(:,model.idx) = objMakeSineComponents(cprm,mprm,X,Y);
      
    %------------------------------------------------------------
    case 'noise'
      [model.prm(model.idx).nncomp,ncol] = size(model.prm(model.idx).nprm);
      model.prm(model.idx).nprm(:,3:4) = pi * model.prm(model.idx).nprm(:,3:4)/180;
      if ncol==5
        model.prm(model.idx).nprm(:,6) = 0; 
      end
      if ~isempty(model.prm(model.idx).mprm)
        [model.prm(model.idx).nmcomp,ncol] = size(model.prm(model.idx).mprm);
        if strcmp(model.shape,'plane')
          model.prm(model.idx).mprm(:,1) = model.prm(model.idx).mprm(:,1)*2*pi;
        end
        model.prm(model.idx).mprm(:,2:3) = pi * model.prm(model.idx).mprm(:,2:3)/180;
        if ncol==4
          model.prm(model.idx).mprm(:,5) = 0; 
        end
      end

      model.prm(ii).use_rms = model.flags.use_rms;

      nprm = model.prm(model.idx).nprm;
      mprm = model.prm(model.idx).mprm;
      
      switch model.opts.coords
        case {'spherical','torus'}
          X = reshape(model.Theta,[model.n model.m])';
          Y = reshape(model.Phi,[model.n model.m])';
          w = 1;
          h = 1;
        case 'cartesian'
          X = reshape(model.X,[model.n model.m])';
          Y = reshape(model.Y,[model.n model.m])';
          w = model.width;
          h = model.height;
        case 'polar'
          X = reshape(model.Theta,[model.n model.m])';
          Y = reshape(model.R,[model.n model.m])';
          w = 1;
          h = 1;
        case 'cylindrical'
          X = reshape(model.Theta,[model.n model.m])';
          Y = reshape(model.Y,[model.n model.m])';
          w = 1;
          h = model.height/(2*pi*model.radius);
      end
      
      P = objMakeNoiseComponents(nprm,mprm,X,Y,model.flags.use_rms,w,h);
      P = P';       
      model.P(:,model.idx) = P(:);

    %------------------------------------------------------------
    case 'bump'

      prm =  model.prm(ii).prm;
      [nbumptypes,ncol] = size(prm);
      
      nbumps = sum(prm(:,1));
      
      % This is too hacky but whatever.  Make a temporary parameter vector
      % that has the cutoff as the second argument.  This way we can use
      % objPlaceBumps from both objMakeBump and objMakeCustom.
      model.prm(ii).prm = [prm(:,1) 3.5*ones(size(prm,1),1) prm(:,2:end)];
      model.prm(ii).nbumptypes = nbumptypes;
      model.prm(ii).nbumps = nbumps;
      
      % Create a function for making the Gaussian profile
      model.prm(ii).f = @(d,prm) prm(2)*exp(-d.^2/(2*prm(1)^2));
      
      model = objPlaceBumps(model);

      % Set the parameter vector back to what it was.  This is horrible.
      model.prm(ii).prm = prm;

    %------------------------------------------------------------
    case 'custom'
      if ~model.flags.use_map
        model = objPlaceBumps(model);
      else
        model = objMakeHeightMap(model);
      end
  end

  % ------------------------------------------------------------
  % Finally, actually add the perturbations
  
  model = objUpdatePerturbations(model);
  
end

