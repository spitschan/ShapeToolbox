
.. _ref-helperfuncs:

================
Helper functions
================


.. _ref-objfindangles:

objFindAngles
=============


.. _ref-objfindfreqs:

objFindFreqs
============

.. _ref-objsavemodel:

objSaveModel
============


.. _ref-objshow:

objShow
=======


.. _ref-objread:

objRead
=======

::
   
   % OBJREAD
   %
   % Usage: MODEL = OBJREAD(FILENAME)
   %
   % Try to read vertex, vertex normal, texture coordinate, and face data
   % from the Wavefront obj file FILENAME.  Emphasis on the work 'try'.
   %
   % The function returns a model structure that holds the vertex and
   % other data.  This model can be viewed with objShow.  objShow needs 
   % to know the size of the mesh, saved in the model structure in fields
   % m and n.  The objMake*-functions in ShapeToolbox write the mesh
   % resolution to the comments of the obj-file.  objRead attempts to
   % read this.  Otherwise, objRead assumes the mesh is square, in other
   % words, that m=n=sqrt(n_of_vertices).  If this is not the case,
   % viewing with objShow does not work.  If you know the size of the
   % mesh, you can set the values of m and n in the structure manually.
   %
   % Note that this function is very limited.  It is not meant as a
   % general-purpose function for reading Wavefront obj files.  It only
   % reads the vertex, texture coordinate, normal, and face data from a
   % well-structured file.   It should work reasonably well for files
   % written by ShapeToolbox though.
   % 
   % Example:
   %  model = objRead('my_funky_object.obj');
   %  objShow(model);
   %
   % % Note that in the above example you could also just do:
   %  objShow('my_funky_object.obj')
   % % because objShow calls objRead if necessary.
   %
   % Manually set the mesh size for a non-square mesh:
   %  model = objRead('my_funky_object.obj');
   %  model.m = 50;
   %  model.n = 40;
   %  objShow(model);
