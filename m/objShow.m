function h = objShow(obj,func)

  % OBJSHOW
  %
  % Usage: h = objShow(model,[viewfunc])
  %        h = objShow(filename,[viewfunc])
  %
  % View a 3D model returned by one of the make objMake-functions in
  % the toolbox.  Alternatively, attempt to read such a model from a
  % Wavefront obj -file (see help objRead for limitations of this
  % approach).
  %
  % Returns a handle h to the rendered graphics object.
  %
  % The optional input argument 'viewfunc' specifies the Octave/Matlab
  % function for showing the object.  Possible values are 'surf',
  % 'surfl' (default), and 'mesh'.
  %
  % Note: This function is just for quick and convenient viewing of
  % the shape, without texture mapping or material properties. Only
  % the shape is shown.  The shape is rendered using the vertex data
  % only (the face definitions are used), so in some shapes there
  % might be a discontinuity (in spheres, cylinders, tori...), as if a
  % piece or a wedge of the object was missing.  That discontinuity
  % will not be there when the shape is properly rendered with a 3D
  % modeling software.
  %
  % Examples:
  % > sphere = objMakeSine('sphere');
  % > objShow(sphere)
  % 
  % > tor = objMakeNoise('torus');
  % > objShow(tor,'surf')

  % Copyright (C) 2014,2015 Toni Saarela
  % 2014-07-28 - ts - first version
  % 2015-03-05 - ts - use shading interp; wrote help
  % 2015-06-04 - ts - updated help
  % 2015-06-04 - ts - fixed a bug in reshaping the matrices, which
  %                    made the rendering to be distorted
  %                   attemps to read a model from file if string
  %                    given as input
if ischar(obj)
  obj = objRead(obj);
end

if nargin<2 || isempty(func)
  func = 'surfl';
end

% Note that the y and z directions are swapped on purpose here.
% ShapeToolbox uses y as "up", as do many rendering programs, while
% Matlab and Octave use z as "up". To show the model in the same
% orientation as it would be rendered with no transformations, do the
% swap here.
X = reshape(obj.vertices(:,1),[obj.n obj.m])';
%Y = reshape(obj.vertices(:,3),[obj.n obj.m])';
%Z = reshape(obj.vertices(:,2),[obj.n obj.m])';
% Without the swap:
Y = reshape(obj.vertices(:,2),[obj.n obj.m])';
Z = reshape(obj.vertices(:,3),[obj.n obj.m])';

figure;
switch lower(func)
  case 'surf'
    h = surf(X,Y,Z);
  case 'surfl'
    h = surfl(X,Y,Z);
  case 'mesh'
    h = mesh(X,Y,Z);
end
shading interp;
colormap gray;
axis equal
set(gca,'Visible','Off');
% 

try
  set(gca,'CameraUpVector',[0 1 0]);
  rotate3d on
catch
  ;
end
