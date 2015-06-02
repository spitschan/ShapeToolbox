function plane = objMakePlaneCustom(f,prm,varargin)

  % OBJMAKEPLANECUSTOM
  %
  % Usage: plane = objMakePlaneCustom(f,prm,...)
  %
  % Makes a 3D model plane with custom perturbations in the
  % z-direction. The perturbation can be defined by an input matrix or
  % image, or by providing a handle to a function that determines the
  % modulation.
  %
  % For details on the input arguments, see the help for
  % objMakeSphereCustom.

% Copyright (C) 2014,2015 Toni Saarela

% 2014-10-19 - ts - first version
% 2014-10-20 - ts - small fixes
% 2015-03-05 - ts - fixed computation of faces (they were defined CW,
%                    should be CCW.  oops.)
% 2015-03-06 - ts - added a "help"
% 2015-04-03 - ts - calls the new objSaveModelPlane-function to
%                    compute faces, normals, etc and save the model to a file
%                   saving the model is optional, an existing model
%                     can be updated
% 2015-05-04 - ts - added uv-option without materials;
%                   calls objParseArgs and objSaveModel
% 2015-05-12 - ts - changed plane width and height to 2 (from -1 to 1)
% 2015-05-14 - ts - added bump locations as optional input arg.
%                    locations also included in the model structure
% 2015-05-14 - ts - different minimum distance can be defined for each
%                    bump type
% 2015-05-29 - ts - fixed a bug in normalization of image/matrix values
% 2015-05-30 - ts - tidying, new function calls for default arguments etc
% 2015-06-01 - ts - calls objMakeCustom

%------------------------------------------------------------

plane = objMakeCustom('plane',f,prm,varargin{:});

if ~nargout
  clear plane
end

