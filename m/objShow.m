function h = objShow(obj,func)

  % OBJSHOW
  %
  % Usage: h = objShow(obj,[viewfunc])
  %
  % View a 3D model returned by one of the make objMake-functions in
  % the toolbox.
  %
  % Returns a handle h to the rendered graphics object.
  %
  % The optional input argument 'viewfunc' specifies the Octave/Matlab
  % function for showing the object.  Possible values are 'surf'
  % (default), 'surfl', and 'mesh'.
  %
  % Note: This function is just for quick and convenient viewing of
  % the shape, without texture mapping or material properties. Only
  % the shape is shown.  The shape is rendered using the vertex data,
  % so in some shapes there might be discontinuities (in spheres,
  % cylinders, tori...).  These discontinuities will not be there when
  % the shape is properly rendered with a 3D modeling software.
  %
  % Examples:
  % > sphere = objMakeSphere();
  % > objShow(sphere)
  % 
  % > tor = objMakeTorusNoise();
  % > objShow(tor,'surfl')

  % Toni Saarela, 2014
  % 2014-07-28 - ts - first version
  % 2015-03-05 - ts - use shading interp; wrote help

if nargin<2 || isempty(func)
  func = 'surf';
end

% Temporary hack
try
   m = obj.m;
   n = obj.n;
catch
  m = obj.npointsy;
  n = obj.npointsx;
end

X = reshape(obj.vertices(:,1),[m n]);
Y = reshape(obj.vertices(:,2),[m n]);
Z = reshape(obj.vertices(:,3),[m n]);

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
set(gca,'Visible','Off');
