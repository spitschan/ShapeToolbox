function sphere = objMakeSphereCustom(f,prm,varargin)

  % OBJMAKESPHERECUSTOM
  % 
  % Make a sphere with a custom-modulated radius.  The modulation
  % values can be defined by an input matrix or an image, or by
  % providing a handle to a function that determines the modulation.
  %
  % To provide the modulation in an input matrix:
  % > objMakeSphereCustom(I,A), 
  % where I is a two-dimensional matrix and A is a scalar, maps M onto
  % the surface of the sphere and uses the values of I to modulate the
  % sphere radius.  Maximum amplitude of modulation is A (the values
  % of M are first normalized to [-1,1], the multiplied with A).
  %
  % To use an image:
  %   > objMakeSphereCustom(FILENAME,A)
  % The image values are first normalized to [0,1], then multiplied by
  % A.  These values are mapped onto the sphere to modulate the radius.
  %
  % With matrix or image as input, the default number of vertices is
  % the size of the matrix/image.  To define a different number of
  % vertices, do:
  %   > objMakeSphereCustom(I,A,'npoints',[M N])
  % to have M vertices in the elevation direction and N in the azimuth
  % direction.  The values of the matrix/image are interpolated.
  % 
  % The radius of the sphere (before modulation) is one.
  % 
  % Alternatively, provide a handle to a function that defines the
  % modulation:
  %   > objMakeSphereCustom(@F,PRM)
  % F is a function that takes distance as its first input argument
  % and a vector of other parameters as the second.  The return values
  % of F are used to modulate the sphere radius.  The format of the
  % parameter vector is:
  %    PRM = [N DCUT PRM1 PRM2 ...]
  % where
  %    N is the number of random locations at which the function 
  %      is applied
  %    DCUT is the cut-off distance after which no modulation is
  %      applied, in radians
  %    [PRM1, PRM2...]  are the parameters passed to F
  %
  % To apply the function several times with different parameters:
  %    PRM = [N1 DCUT1 PRM11 PRM12 ...
  %           N2 DCUT2 PRM21 PRM22 ...
  %           ...                     ]
  %
  % Function F will be called as:
  %   > F(D,[PRM1 PRM2 ...])
  % where D is the distance from the midpoint in degrees.  The points 
  % at which the function will be applied are chosen randomly.
  %
  % To restrict how close together the random location can be:
  %   > objMakeSphereCustom(@F,PRM,...,'mindist',DMIN,...)
  % where DMIN is in radians.
  %
  % The default number of vertices when providing a function handle as
  % input is 128x256 (elevation x azimuth).  To define a different
  % number of vertices:
  %   > objMakeSphereCustom(@F,PRM,...,'npoints',[N M],...)
  %
  % To turn on the computation of surface normals (which will increase
  % coputation time):
  %   > objMakeSphereCustom(...,'NORMALS',true,...)
  %
  % For texture mapping, see help to objMakeSphere or online help.
  % 

  % Examples:
  % TODO
         
% Copyright (C) 2014,2015 Toni Saarela
% 2014-10-18 - ts - first version
% 2014-10-20 - ts - small fixes
% 2014-10-28 - ts - a bunch of fixes and improvements; wrote help
% 2014-11-10 - ts - vertex normals, updated help, all units in degrees
% 2015-04-02 - ts - calls the new objSaveModelSphere-function to
%                    compute faces, normals, etc and save the model to a file
%                   saving the model is optional, an existing model
%                     can be updated
% 2015-04-30 - ts - "switched" y and z directions: reference plane is
%                    x-z, y is "up"; added uv-option without materials
% 2015-05-04 - ts - calls objParseArgs and objSaveModel
% 2015-05-14 - ts - added bump locations as optional input arg.
%                    locations also included in the model structure
% 2015-05-14 - ts - different minimum distance can be defined for each
%                    bump type
% 2015-05-29 - ts - call objSph2XYZ for coordinate conversion
% 2015-05-29 - ts - sizes and distances given in radians,
%                    fixed a bug in normalization of image/matrix values
% 2015-05-30 - ts - tidying, new function calls for default arguments etc
%                   bump sizes, distances given in radians
% 2015-06-01 - ts - calls objMakeCustom

%------------------------------------------------------------

sphere = objMakeCustom('sphere',f,prm,varargin{:});

if ~nargout
  clear sphere
end

