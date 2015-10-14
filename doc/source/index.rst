.. TBD Toolbox documentation master file, created by
   sphinx-quickstart on Mon Oct 13 16:49:54 2014.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.


================
|toolbox| manual
================

|toolbox| is a collection of Octave/Matlab functions for generating 3D
models of various shapes and saving them in the Wavefront .obj-file
format.  The shapes available include spheres, planes, cylinders,
tori, as well as surfaces or revolution and extrusions based on
user-defined shape profiles.

These shapes can be further perturbed by different kinds of
modulation: sinusoidal and filtered noise components allow for
parametric modulation of the shapes.  Gaussian bumps or other, custom,
user-defined surface perturbations can also be used to modulate the
shape.

The main purpose of |toolbox| is to provide a tool for producing
controlled stimulus sets for experiments in visual perception and
cognition.  The target audience is thus psychophysisists,
neuroscientists, and experimental psychologists; but anyone who might
find the tools useful is welcome to use and build on them.

The range of base shapes is limited to a handful of simple shapes, but
the options for modulation can result in very complex shapes.
However, |toolbox| is *not* a general-purpose 3D-modeling software
with which you can create arbitrary or real-world stimuli such as
houses and faces.  Nor is it a rendering tool: after creating the
models with |toolbox|, you have to render them using a rendering
engine to create 2D images.

For examples of the shapes you can produce with |toolbox|, along with
the code to produce them, have a look at the :ref:`gallery`.  For the
impatient, this might be the best way to get started---look at the
examples and start modifying them.

For more complete projects and step-by-step instructions, there is the
:ref:`tutorials` section.  For anyone who read this far, just start
from the beginning, or maybe in the :ref:`getstart` section.
You would have probably done that anyway.


.. toctree::
   :maxdepth: 1
   
   installation
   gettinghelp
   overview
   gettingstarted
   tutorials
   object_types
   bending
   helperfuncs
   rendering
   gallery
   reference
   license

..
   Indices and tables
   ==================

   * :ref:`genindex`
   * :ref:`modindex`
   * :ref:`search`

