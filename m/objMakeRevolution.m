function solid = objMakeRevolution(curve,cprm,varargin)

% OBJMAKEREVOLUTION
%
% Usage: solid = objMakeRevolution(curve,[CPAR],[MPAR],[OPTIONS])
%
% Make a 3D surface-of-revolution model and write it into .obj-file.
% The input argument `curve' is a vector that gives the distance from
% the y-axis at each point.  The 3D-shape is created by rotating this
% curve around the y-axis.
%
% The surface-of-revolution shape can be modulated, as any other shape
% in the toolbox, with sinusoidal components.  Briefly, the optional
% input argument CPAR defines the parameters for the sinusoid(s):
%   CPAR = [FREQ AMPL PH ANGLE]
%
% See details for the modulation and other options in the online help
% or in the help for objMakeSphere.
%
% The default resolution (number of vertices) is the length of the
% input vector 'curve'.  You can change this by setting the input
% argument 'npoints':
% > objMakeRevolution(...,'npoints',[m n],...)
%
% Examples:
% > x = linspace(0,2*pi,256);
% > curve = sin(.5*x).*(1+.5*sin(1.5*x));
% > figure; plot(curve)
% > objMakeRevolution(curve)
%
% The same but with added modulation
% > objMakeRevolution(curve,[8 .1 0 60],[1 1 90 90])

% Copyright (C) 2015 Toni Saarela
% 2015-01-16 - ts - first version
% 2015-01-17 - ts - added the usual sine modulations; wrote a sort of help
% 2015-03-06 - ts - fixed interpolation of the curve; other small
%                    fixes; updated help
% 2015-05-04 - ts - added uv-option without materials
%                   calls objParseArgs and objSaveModel
% 2015-05-14 - ts - improved setting default parameters
% 2015-06-01 - ts - calls objMakeSine

%------------------------------------------------------------

if nargin<2
  cprm = [];
end
solid = objMakeSine('revolution',cprm,varargin{:},'curve',curve);

if ~nargout
  clear solid
end
