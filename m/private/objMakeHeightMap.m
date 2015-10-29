function model = objMakeHeightMap(model)

% OBJMAKEHEIGHTMAP

% Copyright (C) 2015 Toni Saarela
% 2015-06-01 - ts - first version
% 2015-10-08 - ts - bug fixes
% 2015-10-09 - ts - added/fixed bump map support for planes,
%                    cylinders, tori
% 2015-10-10 - ts - added support for the worm shape
% 2015-10-29 - ts - renamed from objMakeBumpMap to objMakeHeightMap

switch model.shape
  case 'sphere'
    R = reshape(model.R,[model.n model.m])';
    if model.opts.mmap~=model.m || model.opts.nmap~=model.n
      Theta = model.Theta;
      Phi = model.Phi;
      Theta = reshape(Theta,[model.n model.m])';
      Phi = reshape(Phi,[model.n model.m])';
      
      theta2 = linspace(-pi,pi-2*pi/model.nmap,model.opts.nmap); % azimuth
      phi2 = linspace(-pi/2,pi/2,model.opts.mmap); % elevation
      [Theta2,Phi2] = meshgrid(theta2,phi2);
      model.opts.map = interp2(Theta2,Phi2,model.opts.map,Theta,Phi);
    end
    R = R + model.opts.ampl * model.opts.map;
    R = R'; model.R = R(:);
  case 'plane'
    Z = reshape(model.Z,[model.n model.m])';
    if model.opts.mmap~=model.m || model.opts.nmap~=model.n
      X = model.X;
      Y = model.Y;
      X = reshape(X,[model.n model.m])';
      Y = reshape(Y,[model.n model.m])';
      
      x2 = linspace(-model.width/2,model.width/2,model.opts.nmap); % 
      y2 = linspace(-model.height/2,model.height/2,model.opts.mmap)'; % 
      [X2,Y2] = meshgrid(x2,y2);
      model.opts.map = interp2(X2,Y2,model.opts.map,X,Y);
    end
    Z = Z + model.opts.ampl * model.opts.map;
    Z = Z'; model.Z = Z(:);
  case {'cylinder','revolution','extrusion','worm'}
    R = reshape(model.R,[model.n model.m])';
    if model.opts.mmap~=model.m || model.opts.nmap~=model.n
      Theta = model.Theta;
      Y = model.Y;
      Theta = reshape(Theta,[model.n model.m])';
      Y = reshape(Y,[model.n model.m])';
      
      theta2 = linspace(-pi,pi-2*pi/model.opts.nmap,model.opts.nmap); % azimuth
      y2 = linspace(-model.height/2,model.height/2,model.opts.mmap); % 
      [Theta2,Y2] = meshgrid(theta2,y2);
      model.opts.map = interp2(Theta2,Y2,model.opts.map,Theta,Y);
    end
    R = R + model.opts.ampl * model.opts.map;
    R = R'; model.R = R(:);
  case 'torus'
    r = reshape(model.r,[model.n model.m])';
    if model.opts.mmap~=model.m || model.opts.nmap~=model.n
      Theta = model.Theta;
      Phi = model.Phi;
      Theta = reshape(Theta,[model.n model.m])';
      Phi = reshape(Phi,[model.n model.m])';
      
      theta2 = linspace(-pi,pi-2*pi/model.nmap,model.opts.nmap); % azimuth
      phi2 = linspace(-pi/2,pi/2,model.opts.mmap); % elevation
      [Theta2,Phi2] = meshgrid(theta2,phi2);
      model.opts.map = interp2(Theta2,Phi2,model.opts.map,Theta,Phi);
    end
    r = r + model.opts.ampl * model.opts.map;
    r = r'; model.r = r(:);
end
