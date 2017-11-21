
.. _torus:

=====
Torus
=====

.. image:: ../images/coordinates/torus_coords_3d_400.png
   :width: 300px
.. image:: ../images/coordinates/torus_coords.png


Coordinate system
=================



Default mesh size
=================

The default size (number of vertices) for the torus is 128-by-128.
For models with very high-frequency perturbations or otherwise fine
detail, you might want to increase the mesh size.  To do this, use the
option ``npoints``::

  objMakeSine('torus',[32 .1 0 0],'npoints',[320 320]);

Default model size
==================

Main radius=1.  Minor (tube) radius=0.4.

Modulation of the main radius
=============================

The torus also has the option for the modulation of the major radius.
This happens as a function of the angle theta.

