function torus = objMakeTorusNoisy(nprm,varargin)

% OBJMAKETORUSNOISY
%
% Usage: torus = objMakeTorusNoisy(nprm,...)


% Toni Saarela, 2014
% 2014-10-16 - ts - first version written
% 2014-10-19 - ts - added an option to set tube radius
%                   renamed input option for torus radius parameters
% 2015-03-05 - ts - updated function call to objMakeNoiseComponents
% 2015-04-04 - ts - calls the new objSaveModelTorus-function to
%                    compute faces, normals, etc and save the model to a file
%                   saving the model is optional, an existing model
%                     can be updated, bunch of other minor improvements
% 2015-04-30 - ts - "switched" y and z directions: reference plane is
%                    x-z, y is "up"
% 2015-05-04 - ts - added uv-option without materials
%                   calls objParseArgs and objSaveModel
% 2015-05-14 - ts - improved setting default modulator parameters
% 2015-05-29 - ts - call objSph2XYZ for coordinate conversion
% 2015-06-01 - ts - calls objMakeNoise

%------------------------------------------------------------

if ~nargin
  nprm = [];
end
torus = objMakeNoise('torus',nprm,varargin{:});

if ~nargout
  clear torus
end

