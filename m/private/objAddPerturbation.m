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
  
% TODO: objRemCaps for worm

switch model.shape
  case {'cylinder','revolution','extrusion'}    
    if ~model.flags.new_model && model.flags.oldcaps
      model = objRemCaps(model);
    end
  case 'torus'
    if ~isempty(model.opts.rprm)
      rprm = model.opts.rprm;
      for ii = 1:size(rprm,1)
        model.R = model.R + rprm(ii,1) * sin(rprm(ii,2)*model.Theta + rprm(ii,3));
      end
    end
end

ii = model.idx;
switch model.prm(ii).perturbation
  case 'none'
    ;
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
    switch model.shape
      case 'sphere'
        model.R = model.R + objMakeSineComponents(cprm,mprm,model.Theta,model.Phi);
      case 'plane'
        model.Z = model.Z + objMakeSineComponents(cprm,mprm,model.X,model.Y);
      case {'cylinder','revolution','extrusion'}
        model.R = model.R + objMakeSineComponents(cprm,mprm,model.Theta,model.Y);
      case 'worm'
        model.R = model.R + objMakeSineComponents(cprm,mprm,model.Theta,model.Y);
      case 'torus'
        model.r = model.r + objMakeSineComponents(cprm,mprm,model.Theta,model.Phi);
      case 'disk'
        if strcmp(model.opts.coords,'polar')
          model.Y = model.Y + objMakeSineComponents(cprm,mprm,model.Theta,model.R);
          [model.X, model.Z] = pol2cart(model.Theta,model.R);
        elseif strcmp(model.opts.coords,'cartesian')
          model.Y = model.Y + objMakeSineComponents(cprm,mprm,model.X,model.Z);
          [model.Theta, model.R] = pol2cart(model.X,model.Z);
        end
      otherwise
        error('Unknown shape.');
    end
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
    switch model.shape
      case 'sphere'
        % For the 2D noise sample, reshape the coordinate vectors to temp 2D matrices
        Theta = reshape(model.Theta,[model.n model.m])';
        Phi = reshape(model.Phi,[model.n model.m])';
        R = reshape(model.R,[model.n model.m])';
        R = R + objMakeNoiseComponents(nprm,mprm,Theta,Phi,model.flags.use_rms,1,1);
        
        % Reshape the radius matrix to a vector again
        R = R'; 
        model.R = R(:);
      case 'plane'
        % For the 2D noise sample, reshape the coordinate vectors to temp 2D matrices
        X = reshape(model.X,[model.n model.m])';
        Y = reshape(model.Y,[model.n model.m])';
        Z = reshape(model.Z,[model.n model.m])';
        Z = Z + objMakeNoiseComponents(nprm,mprm,X,Y,model.flags.use_rms,model.width,model.height);

        % Reshape Z matrix to a vector again
        Z = Z'; 
        model.Z = Z(:);
      case {'cylinder','revolution','extrusion'}
        Theta = reshape(model.Theta,[model.n model.m])';
        Y = reshape(model.Y,[model.n model.m])';
        R = reshape(model.R,[model.n model.m])';
        R = R + objMakeNoiseComponents(nprm,mprm,Theta,Y,model.flags.use_rms,1,model.height/(2*pi*model.radius));

        R = R';
        model.R = R(:);

      case 'worm'
        Theta = reshape(model.Theta,[model.n model.m])';
        Y = reshape(model.Y,[model.n model.m])';
        R = reshape(model.R,[model.n model.m])';
        R = R + objMakeNoiseComponents(nprm,mprm,Theta,Y,model.flags.use_rms,1,model.height/(2*pi*model.radius));
        R = R';
        model.R = R(:);
      case 'torus'
        if ~isempty(nprm)
          Theta = reshape(model.Theta,[model.n model.m])';
          Phi = reshape(model.Phi,[model.n model.m])';
          r = reshape(model.r,[model.n model.m])';

          r = r + objMakeNoiseComponents(nprm,mprm,Theta,Phi,model.flags.use_rms,1,1);

          r = r';
          model.r = r(:);
        end
      case 'disk'
        if strcmp(model.opts.coords,'polar')
          % For the 2D noise sample, reshape the coordinate vectors to temp 2D matrices
          Theta = reshape(model.Theta,[model.n model.m])';
          R = reshape(model.R,[model.n model.m])';
          Y = reshape(model.Y,[model.n model.m])';
          Y = Y + objMakeNoiseComponents(nprm,mprm,Theta,R,model.flags.use_rms,1,1);
          
          % Reshape the radius matrix to a vector again
          Y = Y'; 
          model.Y = Y(:);

          [model.X, model.Z] = pol2cart(model.Theta,model.R);
        elseif strcmp(model.opts.coords,'cartesian')
          error('Noise in cartesian coordinates not implemented for shape ''disk''.');
        end
      otherwise
        error('Unknown shape.');
    end


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

       
