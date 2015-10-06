
.. _ref-objmake:

=======
objMake
=======

::

   % OBJMAKE
   %
   % Usage:  MODEL = OBJMAKE(SHAPE) 
   %         MODEL = OBJMAKE(SHAPE,[OPTIONS])
   %                 OBJMAKE(SHAPE,[OPTIONS])
   %
   % Produce a 3D model mesh object of a given shape and optionally save 
   % it to a file in Wavefront obj-format and/or return a structure that
   % holds the model information.
   % 
   % SHAPE:
   % ======
   %
   % One of 'sphere', 'plane', 'cylinder', 'torus', 'revolution', and
   % 'extrusion'.  Example: m = objMake('sphere')
   %
   % The shapes use a coordinate system where the y-direction is "up" and
   % the x-z plane is the reference plane.
   % 
   % Some notes and default values for the shapes (some can be changed
   % with the optional input arguments, see below):
   %
   % SPHERE: A unit sphere (radius 1), default mesh size 128x256.
   %
   % PLANE: A plane with a width and height of 1, lying on the x-y plane,
   % centered on the origin.  Default mesh size 256x256.  Obviously a
   % size of 2x2 would be enough; the larger size is used so that fine
   % modulations can later be added to the shape if needed.
   %
   % CYLINDER: A cylinder with radius 1 and height of 2*pi.  Default mesh
   % size 256x256.
   %
   % TORUS: A torus with ring radius of 1 and tube radius of 0.4.
   % Default mesh size 256x256.
   %
   % REVOLUTION: A surface of revolution based on a user-defined profile,
   % height 2*pi.  See the option 'rcurve' below on how to define the
   % profile.  Default mesh size 256x256.
   %
   % EXTRUSION: An extrusion based on a user-defined cross-sectional
   % profile, height 2*pi.  See option 'ecurve' below on how to define the
   % profile.  Default mesh size 256x256.
   %
   % NOTE: By default, the model IS NOT SAVED TO A FILE.  To save, you
   % have to set the option 'FILENAME' or 'SAVE' (see below).
   % 
   % 
   % OPTIONS:
   % ========
   %
   % With the exception of the filename, all options are gives as
   % name-value pairs.  All possible options are listed below.
   %
   % FILENAME
   % A single string giving the name of the file in which to save the
   % model.  Setting the filename forces the option 'save' (see below) to
   % true. Example:
   %  objMake(...,'mymodel.obj',...)
   %
   % SAVE
   % Boolean, toggle saving the model to a file.  Default is false, the
   % model is not saved.  Setting the filename (see above) sets this
   % option to true.  If filename is not set and the option 'save' is
   % true, a default filename is used; the default filename is the name
   % of the base shape appended with .obj: 'sphere.obj', 'plane.obj',
   % 'torus.obj', 'cylinder.obj', 'revolution.obj', and 'extrusion.obj'.
   % Example:
   %  objMake('cylinder','save',true);
   %
   % NPOINTS
   % Resolution of the model mesh (number of vertices).  Given as a
   % two-vector for the number of vertices in the "vertical" (elevation
   % or y, depending on the shape) and "horizontal" (azimuth or x)
   % directions.  Example: 
   %  objMake(...,'npoints',[64 64],...)
   % 
   % MATERIAL
   % Name of the material library (.mtl) file and the name of the
   % material for the model.  Given as a cell array of length two.  The
   % elements of the cell array are two strings, the first one for the
   % material library file and the second for the material name.  This
   % option forces the option uvcoords (see below) to true.  Example:
   %  objMake(...,'material',{'matfile.mtl','mymaterial'},...)
   %
   % UVCOORDS
   % Boolean, toggles the computation of texture (uv) coordinates
   % (default is false).  Example: 
   %  objMake(...,'uvcoords',true,...)
   %
   % NORMALS
   % Boolean, toggle the computation of vertex normals (default false).
   % Turning this on improves the quality of rendering, but note that
   % some rendering programs might compute the normals for you, making
   % it unnecessary to include them in the file.  Example:
   %  objMake(...,'normals',true,...)
   %
   % TUBE_RADIUS, MINOR_RADIUS
   % Sets the radius of the "tube" of a torus.  Default 0.4 (the radius
   % of the ring, or the distance from the origin to the center of the
   % tube is 1).  Example: 
   %  objMake(...,'tube_radius',0.2,...)
   %
   % RCURVE, ECURVE
   % A vector giving the curve to use with shapes 'revolution' ('rcurve')
   % and 'extrusion' ('ecurve').  When the shape is 'revolution', a
   % surface of revolution is produced by revolving the curve about the
   % y-axis.  When the shape is 'extrusion', the curve gives the
   % cross-sectional profile of the object.  This profile is translated
   % along the y-axis to produce a 3D shape.  Example: 
   %  profile = .1 + ((-64:63)/64).^2;
   %  objMake('revolution','rcurve',profile)
   %  objMake('extrusion','ecurve',profile)
   %
   % You can also combine the two curve types by giving both options.  In
   % this case, the 'rcurve' is revolved around the y-axis along a path
   % (or radial profile) defined by 'ecurve'.
   %
   % CAPS
   % Boolean.  Set this to true to put "caps" at the end of cylinders, 
   % surfaces of revolution, and extrusions.  Default false.  Example:
   %  objMake('cylinder','caps',true);
   %
   % WIDTH, HEIGHT
   % Scalars, width and height of the model.  Option 'width' can only be
   % used with shape 'plane' to set the plane width.  'height' can be
   % used with 'plane', 'cylinder', 'revolution', and 'extrusion'.
   % Examples:
   %  objMake('plane','width',2,'height',0.5);
   %  objMake('cylinder','height',1.35);
   % 
   % RETURNS:
   % ========
   % A structure holding all the information about the model.  This
   % structure can be given as input to another objMake*-function to
   % perturb the shape, or it can be given as input to objSaveModel to
   % save it to file (but the saving to file is a default behavior of
   % objMake, so unless the option 'save' is set to false, it is not
   % necessary to save the model manually).
   % 
   % BATCH PROCESSING:
   % =================
   % For creating several objects with a single function call, there is
   % an option to provide all input arguments to objMake as a single cell
   % array.  For example, the following two calls are equivalent:
   %  objMake('cylinder','npoints',[64 64],'uvcoords',true,'cyl1.obj')
   %  objMake({'cylinder','npoints',[64 64],'uvcoords',true,'cyl1.obj'})
   % 
   % To create several objects with one call, define several sets of
   % parameters in the cells of the only input argument.  In this case,
   % then, the only input argument is a cell array of cell arrays:
   %  prm = {
   %         {'cylinder','npoints',[64 64],'uvcoords',true,'cyl1.obj'},
   %         {'plane','npoints',[64 64],'uvcoords',true,'pla1.obj'}
   %        };
   %  objMake(prm);
   % 
   % NOTE:
   % =====
   % Note that this function does not do anything that the any other
   % objMake*-function would not do.  You can always call, say,
   % objMakeSine and set the amplitude of modulation to zero to get the
   % same unperturbed shape as this function would produce.  This
   % function might be useful if you just want to produce a
   % surface-of-revolution or an extrusion object.  The other, simple
   % basic shapes (sphere, cylinder...) can be usually produced with a
   % single command in a graphics/rendering program.
