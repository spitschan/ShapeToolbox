function model = objDefaultPerturbationPrms(model,perturbation)

% OBJDEFAULTPERTURBATIONPRMS
%
% Usage: model = objDefaultPerturbationPrms(model,perturbation)

% Copyright (C) 2016 Toni Saarela
% 2016-01-22 - ts - first version, based on objMake*-functions
% 2016-01-28 - ts - added prms for noise, bumps
% 2016-12-17 - ts - changed the order of prms in the vector
% 2017-05-26 - ts - changed (again) the order of prms in the
%                    vector---how the f**k were they wrong?

ii = model.idx;
model.prm(ii).perturbation = perturbation;
switch perturbation
  case 'none'
    ;
  case 'sine'
    switch model.shape
      case 'sphere'
        model.prm(ii).cprm = [8 0 0 .1 0];
      case 'plane'
        model.prm(ii).cprm = [8 0 0 .05 0];
      case {'cylinder','worm'}
        model.prm(ii).cprm = [8 0 0 .1 0];
      case 'torus'
        model.prm(ii).cprm = [8 0 0 .05 0];
      case 'revolution'
        model.prm(ii).cprm = [8 0 0 .1 0];
      case 'extrusion'
        model.prm(ii).cprm = [8 0 0 .1 0];
      case 'disk'
        model.prm(ii).cprm = [8 0 0 .1 0];
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
        model.prm(ii).prm = [20 pi/12 .1];
      case 'plane'
        model.prm(ii).prm = [20 .05 .1];
      case {'cylinder','worm'}
        model.prm(ii).prm = [20 pi/12 .1];
        model = objInterpCurves(model);
      case 'torus'
        model.prm(ii).prm = [20 pi/12 .1];
      case 'revolution'
        model.prm(ii).prm = [20 pi/12 .1];
        model = objInterpCurves(model);
      case 'extrusion'
        model.prm(ii).prm = [20 pi/12 .1];
        model = objInterpCurves(model);
      case 'disk'
        model.prm(ii).prm = [20 .05 .1];
      otherwise
        error('Unknown shape');
    end
  case 'custom'
    model.opts.prm = 0;
  otherwise
    error('Unknown perturbation type.');
end
       
