.. TBD Toolbox documentation master file, created by
   sphinx-quickstart on Mon Oct 13 16:49:54 2014.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

================
|toolbox| manual
================

**NOTE: This manual is a work in progress.  Currently only the
Getting Started -section has any meaningful content.  More added as
often as possible.**

|toolbox| is a collection of Octave/Matlab functions for generating 3D
models of various shapes and saving them in the Wavefront .obj-file
format.  The shapes available include spheres, planes, cylinders,
tori, and surfaces or revolution of your choice.

These shapes can be further perturbed by different kinds of
modulation: sinusoidal and filtered noise components allow for
parametric modulation of the shapes.  Gaussian bumps of other
user-defined surface perturbations can also be used.

The main purpose of |toolbox| is to provide a tool for producing
controlled stimulus sets for experiments in visual perception and
cognition.  The target audience is thus psychophysisists,
neuroscientists, and experimental psychologists; but anyone who might
find the tools useful is welcome to use and build on them.

The range of base shapes is limited to a handful of simple shapes, but
the options for modulation can result in very complex shapes.
However, |toolbox| is *not* a general-purpose 3D-modeling software with
which you can create arbitrary or real-world stimuli such as houses
and faces.  Nor is it a rendering tool: after creating the models with
|toolbox|, you have to render them using some other program to create images.

For examples of the shapes you can produce with |toolbox|, have a look
at the :ref:`gallery`.


.. toctree::
   :maxdepth: 2
   
   .. intro
   installation
   quickstart
   object_types
   helperfuncs
   texture
   rendering
   gallery
   reference

..
   Indices and tables
   ==================

   * :ref:`genindex`
   * :ref:`modindex`
   * :ref:`search`

