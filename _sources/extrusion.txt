

=========
Extrusion
=========

.. image:: ../images/cylinder_coords.png



Coordinate system
=================



Default mesh size
=================

The default size (number of vertices) for the plane is 128-by-128.
For models with very high-frequency perturbations or otherwise fine
detail, you might want to increase the mesh size.  To do this, use the
option ``npoints``::

  objMakeSine('extrusion',[32 .1 0 0],...,'npoints',[320 320]);


Default model size
==================

Height=2*pi.


Defining the shape profile
==========================


Modifying the midline of the shape
==================================
