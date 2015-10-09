function model = objPlaceBumps(model)

% OBJPLACEBUMPS
%
% model = objPlaceBumps(model)
%
% Called by objMakeBumpy, objMakeCustom

% Copyright (C) 2015 Toni Saarela
% 2015-06-01 - ts - first version
% 2015-06-03 - ts - fixed a bug in checking for user-defined locations
% 2015-10-08 - ts - added support for the 'spinex' and 'spinez' options

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

        [theta0,phi0,rtmp] = cart2sph(p(:,1),p(:,2),p(:,3));  
        clear rtmp

        % For saving the locations in the model structure
        model.opts.locations{1}{jj} = theta0;
        model.opts.locations{2}{jj} = phi0;

      else
        %- pick n random directions
        %p = normrnd(0,1,[prm(jj,1) 3]);
        p = randn([prm(jj,1) 3]);

        [theta0,phi0,rtmp] = cart2sph(p(:,1),p(:,2),p(:,3));  
        clear rtmp

        % For saving the locations in the model structure
        model.opts.locations{1}{jj} = theta0;
        model.opts.locations{2}{jj} = phi0;

      end

      %-------------------
      
      for ii = 1:prm(jj,1)
        deltatheta = abs(wrapAnglePi(model.Theta - theta0(ii)));
        
        %- https://en.wikipedia.org/wiki/Great-circle_distance:
        d = acos(sin(model.Phi).*sin(phi0(ii))+cos(model.Phi).*cos(phi0(ii)).*cos(deltatheta));
        
        %idx = find(d<3.5*prm(jj,3));
        %model.R(idx) = model.R(idx) + prm(jj,2)*exp(-d(idx).^2/(2*prm(jj,3)^2));
        idx = find(d<prm(jj,2));
        model.R(idx) = model.R(idx) + model.opts.f(d(idx),prm(jj,3:end));
      end

    end

    model.vertices = objSph2XYZ(model.Theta,model.Phi,model.R);


  case 'plane'

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

        % For saving the locations in the model structure
        model.opts.locations{1}{jj} = x0;
        model.opts.locations{2}{jj} = y0;
        
      else
        %- pick n random locations
        x0 = min(model.x) + rand([prm(jj,1) 1])*(max(model.x)-min(model.x));
        y0 = min(model.y) + rand([prm(jj,1) 1])*(max(model.y)-min(model.y));

        % For saving the locations in the model structure
        model.opts.locations{1}{jj} = x0;
        model.opts.locations{2}{jj} = y0;

      end

      %-------------------
      
      for ii = 1:prm(jj,1)

        deltax = model.X - x0(ii);
        deltay = model.Y - y0(ii);
        d = sqrt(deltax.^2+deltay.^2);
        
        %idx = find(d<3.5*prm(jj,3));
        %model.Z(idx) = model.Z(idx) + prm(jj,2)*exp(-d(idx).^2/(2*prm(jj,3)^2));
        idx = find(d<prm(jj,2));
        model.Z(idx) = model.Z(idx) + model.opts.f(d(idx),prm(jj,3:end));
      end

    end

    model.vertices = [model.X model.Y model.Z];

  case {'cylinder','revolution','extrusion'}
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

        % For saving the locations in the model structure
        opts.locations{1}{jj} = theta0;
        opts.locations{2}{jj} = y0;

      else
        %- pick n random locations
        theta0 = min(model.theta) + rand([prm(jj,1) 1])*(max(model.theta)-min(model.theta));
        y0 = min(model.y) + rand([prm(jj,1) 1])*(max(model.y)-min(model.y));

        % For saving the locations in the model structure
        opts.locations{1}{jj} = theta0;
        opts.locations{2}{jj} = y0;

      end
      
      %-------------------
      
      for ii = 1:prm(jj,1)
        deltatheta = abs(wrapAnglePi(model.Theta - theta0(ii)));
        deltay = model.Y - y0(ii);
        d = sqrt(deltatheta.^2+deltay.^2);
        
        %idx = find(d<3.5*prm(jj,3));
        %model.R(idx) = model.R(idx) + prm(jj,2)*exp(-d(idx).^2/(2*prm(jj,3)^2));      
        idx = find(d<prm(jj,2));
        model.R(idx) = model.R(idx) + model.opts.f(d(idx),prm(jj,3:end));

      end
      
    end

    model.X =  model.R .* cos(model.Theta);
    model.Z = -model.R .* sin(model.Theta);
    model.X = model.X + model.spine.X;
    model.Z = model.Z + model.spine.Z;
    model.vertices = [model.X model.Y model.Z];

  case 'torus'
    fprintf('Gaussian bumps not yet implemented for torus.');

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

