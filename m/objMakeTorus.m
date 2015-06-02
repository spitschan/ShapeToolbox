function torus = objMakeTorus(cprm,varargin)

% OBJMAKETORUS
%
% 
% r     - radius of the "tube"
% sprm  - modulation parameters for the radius of the tube:
%         [frequency amplitude phase direction], where
%          frequecy  : in number of cycles per 2*pi
%          amplitude : in units of the radius
%          phase     : in radians
%          direction : see below
% R     - radius of the torus, i.e., the distance from origin to the
%         center of the "tube"
% rprm  - modulation parameters for the radius of the torus:
%         [frequency amplitude phase], where
%          frequecy is in number of cycles per 2*pi
%          amplitude is in units of the radius
%          phase is in radians
%

% Copyright (C) 2014, 2015 Toni Saarela
% 2014-08-08 - ts - first, rudimentary version
% 2014-10-07 - ts - new format of parameter vectors
%                   renamed some variables, added input arguments
%                   allow several component modulations
% 2014-10-08 - ts - improved the computation of the faces ("wraps
%                   around" in both directions now)
% 2014-10-15 - ts - changed the order of input arguments
% 2014-10-16 - ts - changed input arguments again, added some parsing
%                    of them
%                   uses a separate function now to compute modulation
%                    components
%                   added texture mapping
% 2014-10-19 - ts - added tube radius as optional input arg,
%                   better input argument parsing
%                   renamed input option for torus radius parameters
% 2015-03-05 - ts - updated function call to objMakeSineComponents
% 2015-04-04 - ts - calls the new objSaveModelTorus-function to
%                    compute faces, normals, etc and save the model to a file
%                   saving the model is optional, an existing model
%                     can be updated, bunch of other minor improvements
% 2015-04-30 - ts - "switched" y and z directions: reference plane is
%                    x-z, y is "up"
% 2015-05-04 - ts - added uv-option without materials
%                   calls objParseArgs and objSaveModel
% 2015-05-14 - ts - improved setting default parameters
% 2015-05-29 - ts - call objSph2XYZ for coordinate conversion
% 2015-06-01 - ts - calls objMakeSine

%------------------------------------------------------------

if ~nargin
  cprm = [];
end
torus = objMakeSine('torus',cprm,varargin{:});

if ~nargout
  clear torus
end

