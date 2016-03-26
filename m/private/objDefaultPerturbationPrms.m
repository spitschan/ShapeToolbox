function model = objDefaultPerturbationPrms(model,perturbation)

% OBJDEFAULTPERTURBATIONPRMS
%
% Usage: model = objDefaultPerturbationPrms(model,perturbation)

% Copyright (C) 2016 Toni Saarela
% 2016-01-22 - ts - first version, based on objMake*-functions
% 2016-01-28 - ts - added prms for noise, bumps

ii = model.idx;
model.prm(ii).perturbation = perturbation;
switch perturbation
  case 'none'
    ;
  case 'sine'
    switch model.shape
      case 'sphere'
        model.prm(ii).cprm = [8 .1 0 0 0];
      case 'plane'
        model.prm(ii).cprm = [8 .05 0 0 0];
      case {'cylinder','worm'}
        model.prm(ii).cprm = [8 .1 0 0 0];
      case 'torus'
        model.prm(ii).cprm = [8 .05 0 0 0];
      case 'revolution'
        model.prm(ii).cprm = [8 .1 0 0 0];
      case 'extrusion'
        model.prm(ii).cprm = [8 .1 0 0 0];
      case 'disk'
        model.prm(ii).cprm = [8 .1 0 0 0];
      otherwise
        error('Unknown shape');
    end
    model.prm(ii).nccomp = 1;
    model.prm(ii).mprm = [];
    model.prm(ii).nmcomp = 1;

  case 'noise'
    switch model.shape
      case 'sphere'
        model.prm(ii).nprm = [8 1 0 45 .1 0];
      case 'plane'
        model.prm(ii).nprm = [8 1 0 45 .1 0];
      case {'cylinder','worm'}
        model.prm(ii).nprm = [8 1 0 45 .1 0];
      case 'torus'
        model.prm(ii).nprm = [8 1 0 45 .1 0];
      case 'revolution'
        model.prm(ii).nprm = [8 1 0 45 .1 0];
      case 'extrusion'
        model.prm(ii).nprm = [8 1 0 45 .1 0];
      case 'disk'
        model.prm(ii).nprm = [8 1 0 45 .1 0];
      otherwise
        error('Unknown shape');
    end
    model.prm(ii).nncomp = 1;
    model.prm(ii).mprm = [];
    model.prm(ii).nmcomp = 1;

  case 'bump'
    switch model.shape
      case 'sphere'
        model.prm(ii).prm = [20 .1 pi/12];
      case 'plane'
        model.prm(ii).prm = [20 .05 .05];
      case {'cylinder','worm'}
        model.prm(ii).prm = [20 .1 pi/12];
        model = objInterpCurves(model);
      case 'torus'
        model.prm(ii).prm = [20 .1 pi/12];
      case 'revolution'
        model.prm(ii).prm = [20 .1 pi/12];
        model = objInterpCurves(model);
      case 'extrusion'
        model.prm(ii).prm = [20 .1 pi/12];
        model = objInterpCurves(model);
      case 'disk'
        model.prm(ii).prm = [20 .05 .05];
      otherwise
        error('Unknown shape');
    end
  case 'custom'
    model.opts.prm = 0;
  otherwise
    error('Unknown perturbation type.');
end
       
