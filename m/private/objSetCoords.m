function model = objSetCoords(model)

% OBJSETCOORDS
%
% model = objSetCoords(model)
%
% Called by objMake*-functions.

% Copyright (C) 2015 Toni Saarela
% 2015-05-30 - ts - first version
% 2015-06-08 - ts - separate arguments for revolution and extrusion
%                    profiles, can be combined
% 2015-06-10 - ts - radius, width, height not set here anymore
% 2015-10-08 - ts - added handling of the 'spinex' and 'spinez' options

switch model.shape
  case 'sphere'
    theta = linspace(-pi,pi-2*pi/model.n,model.n); % azimuth
    phi = linspace(-pi/2,pi/2,model.m)'; % elevation
    [Theta,Phi] = meshgrid(theta,phi);
    Theta = Theta'; Phi   = Phi';
    model.Theta = Theta(:);
    model.Phi   = Phi(:);
    model.R = model.radius*ones(model.m*model.n,1);
  case 'plane'
    model.x = linspace(-model.width/2,model.width/2,model.n); % 
    model.y = linspace(-model.height/2,model.height/2,model.m)'; % 
    [X,Y] = meshgrid(model.x,model.y);
    X = X'; Y = Y'; 
    model.X = X(:);
    model.Y = Y(:);
    model.Z = zeros(model.m*model.n,1);
  case {'cylinder','revolution','extrusion'}
    model.theta = linspace(-pi,pi-2*pi/model.n,model.n); % azimuth
    model.y = linspace(-model.height/2,model.height/2,model.m)'; %  
    [Theta,Y] = meshgrid(model.theta,model.y);
    Theta = Theta'; Y = Y'; 
    model.Theta = Theta(:);
    model.Y = Y(:);
    switch model.shape
      case 'cylinder'
        model.R = model.radius * ones(model.m*model.n,1);
      case 'revolution'
        if isfield(model,'ecurve')
          R = model.radius * model.ecurve' * model.rcurve;
        else
          R = model.radius * repmat(model.rcurve,[model.n 1]);
        end
        model.R = R(:);
      case 'extrusion'
        if isfield(model,'rcurve')
          R = model.radius * model.ecurve' * model.rcurve;
        else
          R = model.radius * repmat(model.ecurve',[1 model.m]);
        end
        model.R = R(:);
    end
    model.spine.X = ones(model.n,1) * model.spine.x;
    model.spine.X = model.spine.X(:);
    model.spine.Z = ones(model.n,1) * model.spine.z;
    model.spine.Z = model.spine.Z(:);
  case 'torus'
    model.theta = linspace(-pi,pi-2*pi/model.n,model.n);
    model.phi = linspace(-pi,pi-2*pi/model.m,model.m); 
    [Theta,Phi] = meshgrid(model.theta,model.phi);
    Theta = Theta'; Phi = Phi';
    model.Theta = Theta(:);
    model.Phi   = Phi(:);
    model.R = model.radius*ones(model.m*model.n,1);
    model.r = model.tube_radius*ones(model.m*model.n,1);
end

