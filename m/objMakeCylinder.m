function cylinder = objMakeCylinder(cprm,varargin)

% OBJMAKECYLINDER 
%

% Copyright (C) 2014, 2015 Toni Saarela
% 2014-10-10 - ts - first version
% 2014-10-19 - ts - switched to using an external function to compute
%                   the modulation
% 2014-10-20 - ts - added texture mapping
% 2015-01-16 - ts - fixed the call to renamed objMakeSineComponents
% 2015-04-03 - ts - calls the new objSaveModelCylinder-function to
%                    compute faces, normals, etc and save the model to a file
%                   saving the model is optional, an existing model
%                     can be updated
% 2015-05-04 - ts - added uv-option without materials
%                   calls objParseArgs and objSaveModel
% 2015-05-14 - ts - improved setting default parameters
% 2015-06-01 - ts - calls objMakeSine

%------------------------------------------------------------

if ~nargin
  cprm = [];
end
cylinder = objMakeSine('cylinder',cprm,varargin{:});

if ~nargout
  clear cylinder
end

