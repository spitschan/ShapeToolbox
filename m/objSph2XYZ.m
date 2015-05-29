function [x,y,z] = objSph2XYZ(theta,phi,r,rtorus)

% OBJSPH2XYZ
%
% Usage: [x,y,z] = objSph2XYZ(theta,phi,r)
%        [x,y,z] = objSph2XYZ(theta,phi,r,rtorus)
% Or:        xyz = objSph2XYZ(...)
%
% Spherical to cartesian coordinates.  Theta is the angle re positive
% x-axis.  Phi is the angle re x-z plane, and equals 0 when on that
% plane.  r is the radius.
% 
% With three input arguments, this is the traditional spherical
% coordinate conversion (y is "up").  With an additional fourth input
% argument (radius of a torus, distance from origin to center of
% tube), convert torus coordinates to cartesian.

% Copyright (C) 2015 Toni Saarela
% 2015-05-29 - ts - first version
% 2015-05-29 - ts - eats torus coordinates, too

if nargin<4
   rtorus = 0;
end

rp =  rtorus + r .* cos(phi);
y =   r .* sin(phi);
x =  rp .* cos(theta);
z = -rp .* sin(theta);

if ~nargout || nargout==1
  x = [x,y,z];
end
