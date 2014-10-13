function f = objCylinderFindFreqs(a)

  % OBJCYLINDERFINDANGLES
  %
  % Usage: f = objCylinderFindFreqs(a)
  %
  % Given grating angle (in degrees from vertical), find the
  % frequencies (in cycles per full circle) f that produce a smooth
  % "corkscrew" pattern around the cylinder with no discontinuities.
  %
  % See also: objMakeCylinder, objCylinderFindAngles

% Toni Saarela, 2014
% 2014-10-10 - ts - first version

% TODO: How to set n here?
% Define some default value (say, 10), but have an optional input
% argument to give the desired number of frequencies?

%n = 0:???;
f = [0:10]./cos(pi*a/180);

