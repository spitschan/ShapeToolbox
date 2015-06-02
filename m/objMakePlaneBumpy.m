function plane = objMakePlaneBumpy(prm,varargin)

% OBJMAKEPLANEBUMPY
%
% Usage:          objMakePlaneBumpy()
%                 objMakePlaneBumpy(PAR,[OPTIONS])
%        PLANE = objMakePlaneBumpy(...)
%
% A 3D model plane perturbed in the z-direction by Gaussian
% 'bumps'.  The input vector defines the number of bumps and their
% amplitude and spread:
%   PAR = [NBUMPS AMPL SD]
% 
% The width of the plane is 1.  The bumbs are added to the plane so
% that they modulate the plane in the z-direction with amplitude AMPL.
% So an amplitude of 0.1 means a bump height that is 10% of the plane 
% width.  The amplitude can be negative to produce dents. The spread 
% (standard deviation) of the bumps is given by SD.
%
% To have a mix of different types of bump in the same plane, define 
% several sets of parameters in the rows of PAR:
%   PAR = [NBUMPS1 AMPL1 SD1
%          NBUMPS2 AMPL2 SD2
%          ...
%          NBUMPSN AMPLN SDN]
%
% Options:
% 
% By default, saves the object in planebumpy.obj.  To save in a
% different file, define the output file name as a string:
%   > objMakePlaneBumpy(...,'newfilename',...)
%
% Other optional arguments are key-value pairs.  To set the minimum
% distance between the bumps, use:
%  > objMakePlaneBumpy(...,'mindist',DMIN)
%
% The default number of vertices is 256x256.  To define a different
% number of vertices:
%   > objMakePlaneBumpy(...,'npoints',[N M],...)
%
% To turn on the computation of surface normals (which will increase
% coputation time):
%   > objMakePlaneBumpy(...,'NORMALS',true,...)
%
% For texture mapping, see help to objMakeSphere or online help.
%
% Note: The minimum distance between bumps only applies to bumps of
% the same type.  If several types of bumps are defined (in rows of
% the imput argument prm), different types of bumps might be closer
% together than mindist.  This might change in the future.
%

% Examples:
% TODO

% Copyright (C) 2014,2015 Toni Saarela

% 2014-10-17 - ts - first version
% 2015-03-05 - ts - fixed computation of faces (they were defined CW,
%                    should be CCW.  oops.)
%                   added vertex normals; better writing of specs in comments
% 2015-04-03 - ts - calls the new objSaveModelPlane-function to
%                    compute faces, normals, etc and save the model to a file
%                   saving the model is optional, an existing model
%                     can be updated
% 2015-05-04 - ts - added uv-option without materials;
%                   calls objParseArgs and objSaveModel
% 2015-05-12 - ts - changed plane width and height to 2 (from -1 to 1)
% 2015-05-13 - ts - added bump locations as optional input arg.
%                    locations also included in the model structure
% 2015-05-14 - ts - different minimum distance can be defined for each
%                    bump type
% 2015-05-30 - ts - tidying, new function calls for default arguments etc
% 2015-06-01 - ts - calls objMakeBump

%------------------------------------------------------------

if ~nargin
  prm = [];
end
plane = objMakeBump('plane',prm,varargin{:});

if ~nargout
  clear plane
end
