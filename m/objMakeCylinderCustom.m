function cylinder = objMakeCylinderCustom(f,prm,varargin)

% OBJMAKECYLINDERCUSTOM
% 
% Usage:          objMakeCylinderCustom()

% Copyright (C) 2014, 2015 Toni Saarela
% 2014-10-18 - ts - first version
% 2014-10-19 - ts - small fixes
% 2014-10-20 - ts - small fixes
% 2015-04-03 - ts - calls the new objSaveModelCylinder-function to
%                    compute faces, normals, etc and save the model to a file
%                   saving the model is optional, an existing model
%                     can be updated, many other improvements
% 2015-05-04 - ts - added uv-option without materials
%                   calls objParseArgs and objSaveModel
% 2015-05-14 - ts - added bump locations as optional input arg.
%                    locations also included in the model structure
% 2015-05-14 - ts - different minimum distance can be defined for each
%                    bump type
% 2015-05-29 - ts - fixed a bug in normalization of image/matrix values
% 2015-06-01 - ts - calls objMakeCustom

%------------------------------------------------------------

cylinder = objMakeCustom('cylinder',f,prm,varargin{:});

if ~nargout
  clear cylinder
end

