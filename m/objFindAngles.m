function [a1,a2] = objFindAngles(f)

  % OBJFINDANGLES
  %
  % Usage: a = objFindAngles(f)
  %
  % Given frequency f (in cycles per full circle, or 2*pi), find the
  % grating orientation so that the peaks and troughs meet at the
  % angles 0 and 2*pi.  In other words, these angles produce a smooth
  % "corkscrew" pattern around the cylinder or sphere with no
  % discontinuities.
  %
  % For a torus, use:
  %       [a1,a2] = objFindAngles(f)
  % Here, a1 gives the angles that produce a continuous grating
  % pattern along the "azimuth" direction, and a2 gives the angles 
  % around that produce a continuous pattern around the "tube" of the
  % torus.
  %
  % See also: objFindFreqs

% Toni Saarela, 2014
% 2014-10-10 - ts - first version
% 2014-10-21 - ts - renamed, also computes angles for torus
% 2015-06-10 - ts - input arg checking

if ~isscalar(f)
  error('Input must be a scalar.');
end

n = [0:f]';
a1 = 180*acos(n./f)/pi;
a2 = 180*asin(n./f)/pi;
