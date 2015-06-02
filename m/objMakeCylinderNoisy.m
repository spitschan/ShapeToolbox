function cylinder = objMakeCylinderNoisy(nprm,varargin)

% OBJMAKECYLINDERNOISY
%
% Usage: cylinder = objMakeCylinderNoisy(...)

% Copyright (C) 2014, 2015 Toni Saarela
% 2014-10-15 - ts - first version written
% 2015-04-03 - ts - calls the new objSaveModelCylinder-function to
%                    compute faces, normals, etc and save the model to a file
%                   saving the model is optional, an existing model
%                     can be updated, many other improvements
% 2015-05-04 - ts - added uv-option without materials
%                   calls objParseArgs and objSaveModel
% 2015-05-14 - ts - improved setting default modulator parameters
% 2015-06-01 - ts - calls objMakeNoise

%------------------------------------------------------------

if ~nargin
  nprm = [];
end
cylinder = objMakeNoise('cylinder',nprm,varargin{:});

if ~nargout
  clear cylinder
end

