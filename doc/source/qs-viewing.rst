
.. _qs-viewing:

===========================
A note on viewing 3D-models
===========================

When developing a new 3D model and trying out or testing various
parameters, it is useful to be able to quickly view the model and then
make adjustments.  This section lists a few ways to viewing the
models.  There are certainly other programs that can be used as well,
and this list is not meant to be exhaustive, nor does it claim to
include the best options available.  It merely gives a few pointers.

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
  objShow(tor,'surf')

See :ref:`ref-objshow` (or ``help objShow`` in Octave/Matlab) for details.
This is useful for quickly viewing the shape.  It does not render
material properties or do texture mapping.

Blender
=======

`Blender <http://www.blender.org/>`_ is a full-fledged 3D graphics
creation, animation, and rendering software.  You can import obj-files
to Blender for quick viewing of the models.

While Blender is great for viewing the shapes produced, it might be
tricky to make the material properties associated with the Wavefront
.obj-file work (it also might be that the author just did not spend
enough time trying to figure it out).  If you want quick viewing of
the shapes along with the materials and textures you've defined for
the object, `view3dscene
<http://castle-engine.sourceforge.net/view3dscene.php>`_ should do a
good job.
