function [f1,f2] = objFindFreqs(a,n)

  % OBJFINDFREQS
  %
  % Usage: f = objFindFreqs(a)
  %
  % Given grating orientation (in degrees from vertical), find the
  % frequencies (in cycles per full circle, or 2*pi) f so that the 
  % peaks and troughs meet at the angles 0 and 2*pi.  In other words, 
  % these frequencies produce a smooth "corkscrew" pattern around the 
  % cylinder or sphere with no discontinuities.
  %
  % For a torus, use:
  %       [f1,f2] = objFindFreqs(a)
  % Here, f1 gives the angles that produce a continuous grating
  % pattern along the "azimuth" direction, and f2 gives the angles 
  % around that produce a continuous pattern around the "tube" of the
  % torus.
  %
  % By default, returns 11 suitable frequencies, ordered from low to
  % high.  You can change this with the optional input argument n:
  %        f = objFindFreqs(a,n)
  % where n is an integer, which will return n+1 ferquencies (the
  % first one is always zero).
  %
  % See also: objFindAngles

% Toni Saarela, 2014
% 2014-10-10 - ts - first version
% 2014-10-21 - ts - renamed, also computes frequencies for torus

% TODO: How to set n here?
% Define some default value (say, 10), but have an optional input
% argument to give the desired number of frequencies?

if nargin<2 || isempty(n)
  n = 10;
end

n = [0:n]';
f1 = n./cos(pi*a/180);
f2 = n./sin(pi*a/180);

