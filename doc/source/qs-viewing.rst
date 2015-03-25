
.. _qs-viewing:

===============================
A note on viewing the 3D-models
===============================

When developing a new 3D model and trying out or testing various
parameters, it is useful to be able to quickly view the model and then
make adjustments.  This section lists a few ways (there are others) to
viewing the models.

Note that the tips below are only for quick viewing of the models.
For rendering images of the models, see :ref:`rendering`.


view3dscene
===========

`view3dscene <http://castle-engine.sourceforge.net/view3dscene.php>`_
is a fast and useful program for viewing 3D models, including
Wavefront obj-files.  It has versions for GNU/Linux, Mac, and Windows.
It allows quick viewing of the models with easy rotation, translation,
zoom, and so forth.  It also uses the material properties and texture
mappings specified for the model.


objShow()
=========

|toolbox| provides the function ``objShow()`` for viewing a model.
This function takes as its input a structure returned by one of the
objMake*-functions in the toolbox---it does not read an obj-file from
disk.  Examples of use::

  sphere = objMakeSphere();
  objShow(sphere)

  tor = objMakeTorusNoise();
  objShow(tor,'surfl')

See :ref:`ref-objshow` (or ``help objShow`` in Octave/Matlab) for details.
This is useful for quickly viewing the shape.  It does not render
material properties or do texture mapping.

Blender
=======

`Blender <http://www.blender.org/>`_ is a full-fledged 3D graphics
creation and rendering software.  You can import obj-files to Blender
for quick viewing of the models.

Note: While Blender is great for viewing the shapes produced, it does
not always work well with the the material and texture-mapping options
in |toolbox|.  If you want quick viewing of the shapes along with the
materials and textures you've defined for the object, `view3dscene
<http://castle-engine.sourceforge.net/view3dscene.php>`_ should do a
good job.
