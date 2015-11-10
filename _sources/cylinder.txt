
.. _cylinder:

========
Cylinder
========

.. image:: ../images/cylinder_coords_3d_400.png
   :width: 300px
.. image:: ../images/cylinder_coords.png


Coordinate system
=================


Default mesh size
=================

The default size (number of vertices) for the plane is 128-by-128.
For models with very high-frequency perturbations or otherwise fine
detail, you might want to increase the mesh size.  To do this, use the
option ``npoints``::

  objMakeSine('cylinder',[32 .1 0 0],'npoints',[320 320]);


Default model size
==================

Radius=1.  Height=2*pi.



Modifying the midline of the shape
==================================
