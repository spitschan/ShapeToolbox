function sphere = objMakeSphereBumpy(prm,varargin)

% OBJMAKESPHEREBUMPY
% 
% Usage:          objMakeSphereBumpy()
%                 objMakeSphereBumpy(PAR,[OPTIONS])
%        SPHERE = objMakeSphereBumpy(...)
%
% Make a 3D model sphere with the radius perturbed by Gaussian
% 'bumps'.  The input vector defines the number of bumps and their
% amplitude and spread:
%   PAR = [NBUMPS AMPL SD]
% 
% The radius of the unmodulated sphere is 1.  The bumbs are added to
% this radius with the amplitude AMPL.  The amplitude can be negative
% to produce dents. The spread (standard deviation) of the bumps is
% given by SD, in degrees.
%
% To have different types of bumps in the same sphere, define several
% sets of parameters in the rows of PAR:
%   PAR = [NBUMPS1 AMPL1 SD1
%          NBUMPS2 AMPL2 SD2
%          ...
%          NBUMPSN AMPLN SDN]
%
% Options:
% 
% By default, saves the object in spherebumpy.obj.  To save in a
% different file, define the output file name as a string:
%   > objMakeSphereBumpy(...,'newfilename',...)
%
% Other optional arguments are key-value pairs.  To set the minimum
% distance between the bumps (in degrees), use:
%  > objMakeSphereBumpy(...,'mindist',DMIN)
%
% The default number of vertices is 128x256 (elevation x azimuth).  
% To define a different number of vertices:
%   > objMakeSphereBumpy(...,'npoints',[N M],...)
%
% To turn on the computation of surface normals (which will increase
% coputation time):
%   > objMakeSphereBumpy(...,'NORMALS',true,...)
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
% 2014-05-06 - ts - first version
% 2014-08-07 - ts - option for mixing bumps with different parameters
%                   made the computations much faster
% 2014-10-09 - ts - better parsing of input arguments
%                   added an option for minimum distance of bumps
%                   added an option for number of vertices
%                   fixed an error in writing the bump specs in the
%                     obj-file comments
% 2014-10-28 - ts - bunch of small changes and improvements;
%                     sigma is given in degrees now
% 2014-11-10 - ts - vertex normals, basic help
% 2015-04-02 - ts - calls the new objSaveModelSphere-function to
%                    compute faces, normals, etc and save the model to a file
%                   saving the model is optional, an existing model
%                     can be updated
% 2015-04-30 - ts - "switched" y and z directions: reference plane is
%                    x-z, y is "up"; added uv-option without materials
% 2015-05-04 - ts - calls objParseArgs and objSaveModel
% 2015-05-13 - ts - added bump locations as optional input arg.
%                    locations also included in the model structure
% 2015-05-14 - ts - different minimum distance can be defined for each
%                    bump type
% 2015-05-29 - ts - call objSph2XYZ for coordinate conversion
% 2015-05-29 - ts - bump sigma and min distance given in radians
% 2015-05-30 - ts - tidying, new function calls for default arguments etc
% 2015-06-01 - ts - calls objMakeBump

%------------------------------------------------------------

if ~nargin
  prm = [];
end
sphere = objMakeBump('sphere',prm,varargin{:});

if ~nargout
  clear sphere
end
