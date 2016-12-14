function h = objShow(obj,func,showaxes)

% OBJSHOW
%
% Usage: h = objShow(model)
%        h = objShow(model,[viewfunc],[showaxes])
%        h = objShow(filename,...)
%
% View a 3D model returned by one of the make objMake-functions in
% the toolbox.  Alternatively, attempt to read such a model from a
% Wavefront obj -file (see help objRead for limitations of doing
% this). 
%
% Returns a handle h to the rendered graphics object.
%
% The optional input argument 'viewfunc' specifies the Octave/Matlab
% function for showing the object.  Possible values are 'surfl'
% (default), 'surf',  and 'mesh'.  A further option 'wireframe' is
% similar to 'mesh' but shows a see-through wireframe model.
%
% Examples:
% > sphere = objMakeSine('sphere');
% > objShow(sphere)
% 
% > tor = objMakeNoise('torus');
% > objShow(tor,'surf')
%
% The second optional input argument can be set to true to make the
% axes visible.  Default is false, axes not visible.
  
% Note: This function is just for quick and convenient viewing of
% the shape, without texture mapping or material properties. Only
% the shape is shown.  The shape is rendered using the vertex data
% only (the face definitions are not used).

%, so in some shapes there
% might be a discontinuity (in spheres, cylinders, tori...), as if a
% piece or a wedge of the object was missing.  That discontinuity
% will not be there when the shape is properly rendered with a 3D
% modeling software.
%

% Copyright (C) 2014,2015,2016 Toni Saarela
% 2014-07-28 - ts - first version
% 2015-03-05 - ts - use shading interp; wrote help
% 2015-06-04 - ts - updated help
% 2015-06-04 - ts - fixed a bug in reshaping the matrices, which
%                    made the rendering to be distorted
%                   attemps to read a model from file if string
%                    given as input
% 2015-06-10 - ts - repeat the first row/column of vertices to avoid
%                    the missing 'wedge' in the rendered model
% 2015-10-14 - ts - 'mesh' shows only the vertex mesh, white faces
%                   'surf' does not use interpolation
%                   added 'wireframe' option for see-through wireframe model
%                   added 'worm' as a shape option
% 2015-10-15 - ts - different commands for matlab and octave to set
%                    viewing options
% 2016-06-14 - ts - minor changes to help
% 2016-12-13 - ts - improved viewing directions, rotation etc in Matlab
%                   can set axes visible

% TODO
% https://se.mathworks.com/help/matlab/examples/displaying-complex-three-dimensional-objects.html
% use patch object?
% material: shiny etc
% light position, ambient, specular etc
  
  if ischar(obj)
    obj = objRead(obj);
  end

  if nargin<2 || isempty(func)
    func = 'surfl';
  end

  if nargin<3 || isempty(showaxes)
    showaxes = false;
  end
  
  isoctave = exist('OCTAVE_VERSION');
  
  X = reshape(obj.vertices(:,1),[obj.n obj.m])';
  Y = reshape(obj.vertices(:,2),[obj.n obj.m])';
  Z = reshape(obj.vertices(:,3),[obj.n obj.m])';

  if isfield(obj,'shape')
    switch obj.shape
      case {'sphere','cylinder','revolution','extrusion','worm'}
        X = reshape(obj.vertices(:,1),[obj.n obj.m])';
        Y = reshape(obj.vertices(:,2),[obj.n obj.m])';
        Z = reshape(obj.vertices(:,3),[obj.n obj.m])';
        X = [X X(:,1)]; 
        Y = [Y Y(:,1)]; 
        Z = [Z Z(:,1)]; 
      case 'torus'
        X = reshape(obj.vertices(:,1),[obj.n obj.m])';
        Y = reshape(obj.vertices(:,2),[obj.n obj.m])';
        Z = reshape(obj.vertices(:,3),[obj.n obj.m])';
        X = [X X(:,1)]; 
        Y = [Y Y(:,1)]; 
        Z = [Z Z(:,1)]; 
        X = [X; X(1,:)]; 
        Y = [Y; Y(1,:)]; 
        Z = [Z; Z(1,:)]; 
    end
  end

  % Switch the y and z coordinates.  Matlab insists having z as the
  % up-direction when 3d rotation is on, so we do this to have y up.
  tmp = Y;
  Y = Z;
  Z = tmp;
  
  %figure;
  switch lower(func)
    case 'surfl'
      h = surfl(X,Y,Z,[4 10 4]);%,'cdata');
      if ~isoctave
        hl = light(gca);
      end
      shading interp;
      colormap gray;
    case 'surf'
      h = surf(X,Y,Z);
      colormap gray;
    case 'mesh'
      h = mesh(X,Y,Z);
      set(h,'EdgeColor',[0 0 0],'FaceColor',[1 1 1]);
    case 'wireframe'
      h = mesh(X,Y,Z);
      set(h,'EdgeColor',[0 0 0],'FaceColor','none');
    otherwise
      error('Unknown viewing function.  Use ''surfl'', ''surf'', ''mesh'', or ''wireframe''.')
  end
  axis equal
  set(gca,'Visible','Off');

  if isoctave
    try
      set(gca,'CameraUpVector',[0 1 0]);%,'CameraPosition',[0 0 1]);
      view([1 1 1]);
      rotate3d on
    catch
      ;
    end
  else
    %rotate3d on
    set(gca,'CameraUpVector',[0 0 1],...
            'CameraUpVectorMode','manual',...
            'CameraPosition',[1 1 1]);
    %view([1 1 1]);
    %
    h3 = rotate3d;
    % set(h3,'ActionPreCallback',@setViewProperlyMatlabSucksSoBadly);
    % set(h3,'ActionPostCallback',@setViewProperlyMatlabSucksSoBadly);
    set(h3,'Enable','On');
    
    
    
  end

  if showaxes
    set(gca,'Visible','On')
    xlabel('x')
    % Switch the labels of y and z, because Matlab insists having z
    % point up when 3d rotation is on.  For this reason, the y and
    % z coordinates are also switched (above) for viewing.
    ylabel('z')
    zlabel('y')
  end

  if ~nargout
    clear h
  end
end


% function setViewProperlyMatlabSucksSoBadly(src,event)
  
%   set(get(src,'CurrentAxes'),...
%       'CameraUpVector',[0 1 0],...
%       'CameraUpVectorMode','manual');
  
% end
