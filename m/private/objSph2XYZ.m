function [x,y,z] = objSph2XYZ(theta,phi,r,rtorus)

% OBJSPH2XYZ
%
% Usage: [x,y,z] = objSph2XYZ(theta,phi,r,[rtorus])
%        [x,y,z] = objSph2XYZ(spher_coords,[rtorus])
% Or:        xyz = objSph2XYZ(...)
%
% Spherical to cartesian coordinates.  Theta is the angle re positive
% y-axis.  Phi is the angle re x-z plane, and equals 0 when on that
% plane.  r is the radius.
% 
% With three input arguments, this is the traditional spherical
% coordinate conversion (y is "up").  With an additional fourth input
% argument (radius of a torus, distance from origin to center of
% tube), convert torus coordinates to cartesian.
%
% The input coordinates can be given as a matrix with each
% coordinate in a column.
  
% Copyright (C) 2015 Toni Saarela
% 2015-05-29 - ts - first version
% 2015-05-29 - ts - eats torus coordinates, too
% 2017-12-05 - ts - accepts matrix input, help updated

  if nargin == 1
    if size(theta,2)==3
      r = theta(:,3);
      phi = theta(:,2);
      theta = theta(:,1);
    elseif size(theta,2)==4
      rtorus = theta(:,4);
      r = theta(:,3);
      phi = theta(:,2);
      theta = theta(:,1);
    else
      error('The input matrix has to have 3 or 4 columns.');
    end
  elseif nargin == 2
    rtorus = phi;
    r = theta(:,3);
    phi = theta(:,2);
    theta = theta(:,1);    
  elseif nargin == 3
    rtorus = 0;
  elseif nargin ~= 4
    error('Invalid number of input args.');
  end

  rp =  rtorus + r .* cos(phi);
  y =   r .* sin(phi);
  x =  rp .* cos(theta);
  z = -rp .* sin(theta);
  
  if ~nargout || nargout==1
    x = [x,y,z];
  end

end
