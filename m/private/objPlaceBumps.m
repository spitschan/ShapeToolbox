function model = objPlaceBumps(model)

% OBJPLACEBUMPS
%
% model = objPlaceBumps(model)
%
% Called by objMakeBump, objMakeCustom

% Copyright (C) 2015,2016,2017 Toni Saarela
% 2015-06-01 - ts - first version
% 2015-06-03 - ts - fixed a bug in checking for user-defined locations
% 2015-10-08 - ts - added support for the 'spinex' and 'spinez' options
% 2015-10-10 - ts - added support for worm shape
% 2015-10-11 - ts - added support for torus (again)
% 2015-10-14 - ts - added option to sum/take max
% 2015-10-15 - ts - fixed the max/sum functionality for sphere,
%                    cylinder, torus
% 2016-01-21 - ts - coordinate conversions moved to objMakeVertices
% 2016-02-19 - ts - minor changes in error messages;
%                   fixed saving the locations in model structure;
%                   uses the function handle model.prm(model.idx).f
%                   instead of the old model.opts.f
% 2016-06-20 - ts - minor restructuring
% 2017-06-06 - ts - make the perturbation profiles but don't add
%                    them to the model yet;
%                   bug fix with torus---multiple bump types were
%                   not added, only the last one was used; fixed
% 2017-11-10 - ts - bug fix for sphere, cylinder: get size from
%                    field Rbase instead of R (R will not exist yet
%                    if this is the first perturbation added)
  
ii = length(model.prm);
prm = model.prm(ii).prm;
nbumptypes = model.prm(ii).nbumptypes;
nbumps = model.prm(ii).nbumps;

if isscalar(model.opts.mindist)
   model.opts.mindist = ones(1,nbumptypes) * model.opts.mindist;
elseif length(model.opts.mindist)~=nbumptypes
  error('Incorrect number of minimum distances defined.');
end

switch model.shape
  case 'sphere'
    % Rtmp = zeros(size(model.R));
    Rtmp = zeros(size(model.Rbase));
    for jj = 1:nbumptypes

      if model.flags.custom_locations && ~isempty(model.opts.locations{1}{jj})

        theta0 = model.opts.locations{1}{jj};
        phi0 = model.opts.locations{2}{jj};

      elseif model.opts.mindist(jj)
        % Make extra candidate vectors (30 times the required number)
        %ptmp = normrnd(0,1,[30*prm(jj,1) 3]);
        ptmp = randn([30*prm(jj,1) 3]);
        % Make them unit length
        ptmp = ptmp ./ (sqrt(sum(ptmp.^2,2))*[1 1 1]);
        
        % Matrix for the accepted vectors
        p = zeros([prm(jj,1) 3]);

        % Compute distances (the same as angles, radius is one) between
        % all the vectors.  Use the real function here---sometimes,
        % some of the values might be slightly larger than one, in which
        % case acos returns a complex number with a small imaginary part.
        d = real(acos(ptmp * ptmp'));

        % Always accept the first vector
        idx_accepted = [1];
        n_accepted = 1;
        % Loop over the remaining candidate vectors and keep the ones that
        % are at least the minimum distance away from those already
        % accepted.
        idx = 2;
        while idx <= size(ptmp,1)
          if all(d(idx_accepted,idx)>=model.opts.mindist(jj))
            idx_accepted = [idx_accepted idx];
            n_accepted = n_accepted + 1;
          end
          if n_accepted==prm(jj,1)
            break
          end
          idx = idx + 1;
        end

        if n_accepted<prm(jj,1)
          error(sprintf('Could not find enough vectors to satisfy the minumum distance criterion.\nConsider reducing the value of ''mindist''.'));
        end

        p = ptmp(idx_accepted,:);

      else
        %- pick n random directions
        %p = normrnd(0,1,[prm(jj,1) 3]);
        p = randn([prm(jj,1) 3]);

      end

      [theta0,phi0,rtmp] = cart2sph(p(:,1),p(:,2),p(:,3));  
      clear rtmp

      % For saving the locations in the model structure
      model.opts.locations{1}{jj} = theta0;
      model.opts.locations{2}{jj} = phi0;

      %-------------------
      
      for ii = 1:prm(jj,1)
        deltatheta = abs(wrapAnglePi(model.Theta - theta0(ii)));
        
        %- https://en.wikipedia.org/wiki/Great-circle_distance:
        d = acos(sin(model.Phi).*sin(phi0(ii))+cos(model.Phi).*cos(phi0(ii)).*cos(deltatheta));
        
        %idx = find(d<3.5*prm(jj,3));
        %model.R(idx) = model.R(idx) + prm(jj,2)*exp(-d(idx).^2/(2*prm(jj,3)^2));
        idx = find(d<prm(jj,2));
        if model.flags.max
          % model.R(idx) = max(model.R(idx), model.prm(model.idx).f(d(idx),prm(jj,3:end)));
          Rtmp(idx) = max(Rtmp(idx), model.prm(model.idx).f(d(idx),prm(jj,3:end)));
        else
          % model.R(idx) = model.R(idx) + model.prm(model.idx).f(d(idx),prm(jj,3:end));
          Rtmp(idx) = Rtmp(idx) + model.prm(model.idx).f(d(idx),prm(jj,3:end));
        end
      end % loop over bumps of this type
    end % over bump types

    % model.R = model.R + Rtmp;

    model.P(:,model.idx) = Rtmp;
    
  case 'plane'
    Ztmp = zeros(size(model.Z));
    for jj = 1:nbumptypes

      if model.flags.custom_locations && ~isempty(model.opts.locations{1}{jj})

        x0 = model.opts.locations{1}{jj};
        y0 = model.opts.locations{2}{jj};

      elseif model.opts.mindist(jj)

        % Pick candidate locations (more than needed):
        nvec = 30*prm(jj,1);
        xtmp = min(model.x) + rand([nvec 1])*(max(model.x)-min(model.x));
        ytmp = min(model.y) + rand([nvec 1])*(max(model.y)-min(model.y));

        
        d = sqrt((xtmp*ones([1 nvec])-ones([nvec 1])*xtmp').^2 + (ytmp*ones([1 nvec])-ones([nvec 1])*ytmp').^2);

        % Always accept the first vector
        idx_accepted = [1];
        n_accepted = 1;
        % Loop over the remaining candidate vectors and keep the ones that
        % are at least the minimum distance away from those already
        % accepted.
        idx = 2;
        while idx <= size(xtmp,1)
          if all(d(idx_accepted,idx)>=model.opts.mindist(jj))
            idx_accepted = [idx_accepted idx];
            n_accepted = n_accepted + 1;
          end
          if n_accepted==prm(jj,1)
            break
          end
          idx = idx + 1;
        end

        if n_accepted<prm(jj,1)
          error(sprintf('Could not find enough vectors to satisfy the minumum distance criterion.\nConsider reducing the value of ''mindist''.'));
        end

        x0 = xtmp(idx_accepted,:);
        y0 = ytmp(idx_accepted,:);

        clear xtmp ytmp
        
      else
        %- pick n random locations
        x0 = min(model.x) + rand([prm(jj,1) 1])*(max(model.x)-min(model.x));
        y0 = min(model.y) + rand([prm(jj,1) 1])*(max(model.y)-min(model.y));

      end

      % For saving the locations in the model structure
      model.opts.locations{1}{jj} = x0;
      model.opts.locations{2}{jj} = y0;

      %-------------------
      
      for ii = 1:prm(jj,1)

        deltax = model.X - x0(ii);
        deltay = model.Y - y0(ii);
        d = sqrt(deltax.^2+deltay.^2);
        
        %idx = find(d<3.5*prm(jj,3));
        %model.Z(idx) = model.Z(idx) + prm(jj,2)*exp(-d(idx).^2/(2*prm(jj,3)^2));
        idx = find(d<prm(jj,2));
        if model.flags.max
          Ztmp(idx) = max(Ztmp(idx), model.prm(model.idx).f(d(idx),prm(jj,3:end)));
        else
          Ztmp(idx) = Ztmp(idx) + model.prm(model.idx).f(d(idx),prm(jj,3:end));
        end
      end % for over bumps of this type

    end % for over bump types
    
    model.P(:,model.idx) = Ztmp;


  case {'cylinder','revolution','extrusion','worm'}

    % Rtmp = zeros(size(model.R));
    Rtmp = zeros(size(model.Rbase));

    for jj = 1:nbumptypes
        
      if model.flags.custom_locations && ~isempty(model.opts.locations{1}{jj})

        theta0 = model.opts.locations{1}{jj};
        y0 = model.opts.locations{2}{jj};

      elseif model.opts.mindist(jj)
             
        % Pick candidate locations (more than needed):
        nvec = 30*prm(jj,1);
        thetatmp = min(model.theta) + rand([nvec 1])*(max(model.theta)-min(model.theta));
        ytmp = min(model.y) + rand([nvec 1])*(max(model.y)-min(model.y));

        %d = sqrt((thetatmp*ones([1 nvec])-ones([nvec 1])*thetatmp').^2 + ...
        %         (ytmp*ones([1 nvec])-ones([nvec 1])*ytmp').^2);
        
        d = sqrt(wrapAnglePi(thetatmp*ones([1 nvec])-ones([nvec 1])*thetatmp').^2 + ...
                 (ytmp*ones([1 nvec])-ones([nvec 1])*ytmp').^2);

        % Always accept the first vector
        idx_accepted = [1];
        n_accepted = 1;
        % Loop over the remaining candidate vectors and keep the ones that
        % are at least the minimum distance away from those already
        % accepted.
        idx = 2;
        while idx <= size(thetatmp,1)
          if all(d(idx_accepted,idx)>=model.opts.mindist(jj))
            idx_accepted = [idx_accepted idx];
            n_accepted = n_accepted + 1;
          end
          if n_accepted==prm(jj,1)
            break
          end
          idx = idx + 1;
        end

        if n_accepted<prm(jj,1)
          error(sprintf('Could not find enough vectors to satisfy the minumum distance criterion.\nConsider reducing the value of ''mindist''.'));
        end

        theta0 = thetatmp(idx_accepted,:);
        y0 = ytmp(idx_accepted,:);

        clear thetatmp ytmp

      else
        %- pick n random locations
        theta0 = min(model.theta) + rand([prm(jj,1) 1])*(max(model.theta)-min(model.theta));
        y0 = min(model.y) + rand([prm(jj,1) 1])*(max(model.y)-min(model.y));

      end
      
      % For saving the locations in the model structure
      model.opts.locations{1}{jj} = theta0;
      model.opts.locations{2}{jj} = y0;

      %-------------------
      
      for ii = 1:prm(jj,1)
        deltatheta = abs(wrapAnglePi(model.Theta - theta0(ii)));
        deltay = model.Y - y0(ii);
        d = sqrt(deltatheta.^2+deltay.^2);
        
        %idx = find(d<3.5*prm(jj,3));
        %model.R(idx) = model.R(idx) + prm(jj,2)*exp(-d(idx).^2/(2*prm(jj,3)^2));      
        idx = find(d<prm(jj,2));
        if model.flags.max
          % model.R(idx) = max(model.R(idx), model.prm(model.idx).f(d(idx),prm(jj,3:end)));
          Rtmp(idx) = max(Rtmp(idx), model.prm(model.idx).f(d(idx),prm(jj,3:end)));
        else
          % model.R(idx) = model.R(idx) + model.prm(model.idx).f(d(idx),prm(jj,3:end));
          Rtmp(idx) = Rtmp(idx) + model.prm(model.idx).f(d(idx),prm(jj,3:end));
        end
      end % loop over bumps of this type
      
    end % loop over bump types

    % model.R = model.R + Rtmp;
    
    model.P(:,model.idx) = Rtmp;

  case 'torus'
    rtmp = zeros(size(model.r));
    for jj = 1:nbumptypes
      if model.flags.custom_locations && ~isempty(model.opts.locations{1}{jj})

        theta0 = model.opts.locations{1}{jj};
        phi0 = model.opts.locations{2}{jj};

      elseif model.opts.mindist(jj)
        % Pick candidate locations (more than needed):
        nvec = 30*prm(jj,1);
        thetatmp = min(model.theta) + rand([nvec 1])*(max(model.theta)-min(model.theta));
        phitmp = min(model.phi) + rand([nvec 1])*(max(model.phi)-min(model.phi));
        
        d = sqrt(wrapAnglePi(thetatmp*ones([1 nvec])-ones([nvec 1])*thetatmp').^2 + ...
                 wrapAnglePi(phitmp*ones([1 nvec])-ones([nvec 1])*phitmp').^2);

        % Always accept the first vector
        idx_accepted = [1];
        n_accepted = 1;
        % Loop over the remaining candidate vectors and keep the ones that
        % are at least the minimum distance away from those already
        % accepted.
        idx = 2;
        while idx <= size(thetatmp,1)
          if all(d(idx_accepted,idx)>=model.opts.mindist(jj))
            idx_accepted = [idx_accepted idx];
            n_accepted = n_accepted + 1;
          end
          if n_accepted==prm(jj,1)
            break
          end
          idx = idx + 1;
        end

        if n_accepted<prm(jj,1)
          error(sprintf('Could not find enough vectors to satisfy the minumum distance criterion.\nConsider reducing the value of ''mindist''.'));
        end

        theta0 = thetatmp(idx_accepted,:);
        phi0 = phitmp(idx_accepted,:);

        clear thetatmp phitmp

      else % No predefined locations, no minimum distance, just random
        %- pick n random locations
        theta0 = min(model.theta) + rand([prm(jj,1) 1])*(max(model.theta)-min(model.theta));
        phi0 = min(model.phi) + rand([prm(jj,1) 1])*(max(model.phi)-min(model.phi));

      end

      % For saving the locations in the model structure
      model.opts.locations{1}{jj} = theta0;
      model.opts.locations{2}{jj} = phi0;

      %-------------------
      
      for ii = 1:prm(jj,1)
        deltatheta = abs(wrapAnglePi(model.Theta - theta0(ii)));
        deltaphi = abs(wrapAnglePi(model.Phi - phi0(ii)));
        d = sqrt(deltatheta.^2+deltaphi.^2);
              
        idx = find(d<prm(jj,2));
        if model.flags.max
          % model.r(idx) = max(model.r(idx), model.prm(model.idx).f(d(idx),prm(jj,3:end)));
          rtmp(idx) = max(rtmp(idx), model.prm(model.idx).f(d(idx),prm(jj,3:end)));
        else
          % model.r(idx) = model.r(idx) + model.prm(model.idx).f(d(idx),prm(jj,3:end));
          rtmp(idx) = rtmp(idx) + model.prm(model.idx).f(d(idx),prm(jj,3:end));
        end
      end % bumps of this type
    end % bump types

    % model.r = model.r + rtmp;

    model.P(:,model.idx) = rtmp;

    % if ~isempty(model.opts.rprm)
    %   rprm = model.opts.rprm;
    %   for ii = 1:size(rprm,1)
    %     model.R = model.R + rprm(ii,2) * sin(rprm(ii,1)*model.Theta + rprm(ii,3));
    %   end
    % end

  case 'disk'
    Ytmp = zeros(size(model.Y));
    if strcmp(model.opts.coords,'polar')
      error('Bumps in polar coordinates not implemented for shape ''disk''.');
    % [model.X, model.Z] = pol2cart(model.Theta,model.R);
    elseif strcmp(model.opts.coords,'cartesian')

      for jj = 1:nbumptypes

        if model.flags.custom_locations && ~isempty(model.opts.locations{1}{jj})

          x0 = model.opts.locations{1}{jj};
          z0 = model.opts.locations{2}{jj};

        elseif model.opts.mindist(jj)

          % Pick candidate locations (more than needed):
          nvec = round(4/pi*30*prm(jj,1));
          xtmp = min(model.X(:)) + rand([nvec 1])*(max(model.X(:))-min(model.X(:)));
          ztmp = min(model.Z(:)) + rand([nvec 1])*(max(model.Z(:))-min(model.Z(:)));

          idx = sqrt(xtmp.^2+ztmp.^2)<model.radius;
          xtmp = xtmp(idx);
          ztmp = ztmp(idx);
          clear idx

          d = sqrt((xtmp*ones([1 nvec])-ones([nvec 1])*xtmp').^2 + (ztmp*ones([1 nvec])-ones([nvec 1])*ztmp').^2);

          % Always accept the first vector
          idx_accepted = [1];
          n_accepted = 1;
          % Loop over the remaining candidate vectors and keep the ones that
          % are at least the minimum distance away from those already
          % accepted.
          idx = 2;
          while idx <= size(xtmp,1)
            if all(d(idx_accepted,idx)>=model.opts.mindist(jj))
              idx_accepted = [idx_accepted idx];
              n_accepted = n_accepted + 1;
            end
            if n_accepted==prm(jj,1)
              break
            end
            idx = idx + 1;
          end

          if n_accepted<prm(jj,1)
            error(sprintf('Could not find enough vectors to satisfy the minumum distance criterion.\nConsider reducing the value of ''mindist''.'));
          end

          x0 = xtmp(idx_accepted,:);
          z0 = ztmp(idx_accepted,:);

          clear xtmp ztmp

        else
          %- pick n random locations
          x0 = min(model.X(:)) + rand([prm(jj,1) 1])*(max(model.X(:))-min(model.X(:)));
          z0 = min(model.Z(:)) + rand([prm(jj,1) 1])*(max(model.Z(:))-min(model.Z(:)));

        end

        % For saving the locations in the model structure
        model.opts.locations{1}{jj} = x0;
        model.opts.locations{2}{jj} = z0;
        
        %-------------------
        
        for ii = 1:prm(jj,1)

          deltax = model.X - x0(ii);
          deltaz = model.Z - z0(ii);
          d = sqrt(deltax.^2+deltaz.^2);

          idx = find(d<prm(jj,2));
          if model.flags.max
            Ytmp(idx) = max(Ytmp(idx), model.prm(model.idx).f(d(idx),prm(jj,3:end)));
          else
            Ytmp(idx) = Ytmp(idx) + model.prm(model.idx).f(d(idx),prm(jj,3:end));
          end
        end

      end
      
      model.P(:,model.idx) = Ytmp;

      % Why the f**k is this here? Is it really needed? Should't
      % be. Shouldn't hurt, either, but really shouldn't be needed.
      [model.Theta, model.R] = pol2cart(model.X,model.Z);           
    end

end

function theta = wrapAnglePi(theta)

% WRAPANGLEPI
%
% Usage: theta = wrapAnglePi(theta)

% Toni Saarela, 2010
% 2010-xx-xx - ts - first version

theta = rem(theta,2*pi);
theta(theta>pi) = -2*pi+theta(theta>pi);
theta(theta<-pi) = 2*pi+theta(theta<-pi);
%theta(X==0 & Y==0) = 0;

