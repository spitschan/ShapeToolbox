
.. _quickstart:

******************************
Getting started with |toolbox|
******************************

This Getting Started tutorial demonstrates the use of the function
:ref:`ref-objmakesine` that produces model of a given base shape and
adds a sinusoidal modulation to that shape.  In this section we'll use
a sphere as the base shape.  With that choice, the function
:ref:`ref-objmakesine` produces spheres with a modulated radius (with
the modulation consisting of sine wave components).  

Other base shapes can be used (planes, cylinder, tori, surfaces of
revolution, extrusions), but the logic for defining the modulation is
the same in them all.  There are also functions for producing other
types of perturbation (for example, based on filtered noise
components).  The use of all those functions should be easy to learn
after familiarizing yourself with the examples in this tutorial.


.. toctree::
   :maxdepth: 1

   qs-viewing
   qs-sphere
   qs-components
   qs-modulation
   qs-series
   qs-normals
   qs-material
   qs-texture
   qs-objspecs
