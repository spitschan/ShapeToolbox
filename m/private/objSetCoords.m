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

switch model.shape
  case 'sphere'
    theta = linspace(-pi,pi-2*pi/model.n,model.n); % azimuth
    phi = linspace(-pi/2,pi/2,model.m)'; % elevation
    [Theta,Phi] = meshgrid(theta,phi);
    Theta = Theta'; Phi   = Phi';
    model.Theta = Theta(:);
    model.Phi   = Phi(:);
    model.R = ones(model.m*model.n,1);
  case 'plane'
    model.w = 2; % width of the plane
    model.h = 2; % m/n * w;
    model.x = linspace(-model.w/2,model.w/2,model.n); % 
    model.y = linspace(-model.h/2,model.h/2,model.m)'; % 
    [X,Y] = meshgrid(model.x,model.y);
    X = X'; Y = Y'; 
    model.X = X(:);
    model.Y = Y(:);
    model.Z = zeros(model.m*model.n,1);
  case 'cylinder'
    model.r = 1; % radius
    model.h = 2*pi*model.r; % height
    model.theta = linspace(-pi,pi-2*pi/model.n,model.n); % azimuth
    model.y = linspace(-model.h/2,model.h/2,model.m)'; %  
    [Theta,Y] = meshgrid(model.theta,model.y);
    Theta = Theta'; Y = Y'; 
    model.Theta = Theta(:);
    model.Y = Y(:);
    model.R = model.r * ones(model.m*model.n,1);
  case 'torus'
    model.theta = linspace(-pi,pi-2*pi/model.n,model.n);
    model.phi = linspace(-pi,pi-2*pi/model.m,model.m); 
    [Theta,Phi] = meshgrid(model.theta,model.phi);
    Theta = Theta'; Phi = Phi';
    model.Theta = Theta(:);
    model.Phi   = Phi(:);
    model.R = model.radius*ones(model.m*model.n,1);
    model.r = model.tube_radius*ones(model.m*model.n,1);
  case 'revolution'
    model.r = 1; % radius
    model.h = 2*pi*model.r; % height
    model.theta = linspace(-pi,pi-2*pi/model.n,model.n); % azimuth
    model.y = linspace(-model.h/2,model.h/2,model.m)'; %  
    [Theta,Y] = meshgrid(model.theta,model.y);
    Theta = Theta'; Y = Y'; 
    model.Theta = Theta(:);
    model.Y = Y(:);

    if isfield(model,'ecurve')
      R = model.r * model.ecurve' * model.rcurve;
    else
      R = model.r*repmat(model.rcurve,[model.n 1]);
    end

    model.R = R(:);
  case 'extrusion'
    model.r = 1; % radius
    model.h = 2*pi*model.r; % height
    model.theta = linspace(-pi,pi-2*pi/model.n,model.n); % azimuth
    model.y = linspace(-model.h/2,model.h/2,model.m)'; %  
    [Theta,Y] = meshgrid(model.theta,model.y);
    Theta = Theta'; Y = Y'; 
    model.Theta = Theta(:);
    model.Y = Y(:);

    if isfield(model,'rcurve')
      R = model.r * model.ecurve' * model.rcurve;
    else
      R = model.r*repmat(model.ecurve',[1 model.m]);
    end

    model.R = R(:);
end

