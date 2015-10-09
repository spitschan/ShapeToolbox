
=====================
Overview of |toolbox|
=====================

3D models, materials, and rendering
===================================

There are many steps in producing a computer-rendered image of a 3D
model.  The first step is to create the model.  The simplest model
defines a set of points (*vertices*) in three dimensions, and a set of
*faces*, or groups of vertices.  Together the faces approximate the
surface to be modeled.  More information about vertex normals (the
normal vector of the surface-to-be-approximated at that point) and
texture coordinates can be added to improve the rendering of the
model.  The model is often saved in a text file.  **This first step is
the one ShapeToolbox can be used for.**

The next step is to define material properties for the model.  These
are usually defined in a separate file.  Material properties include
surface color, the way the surface reflects light, transparency, and
texture.  The appearance of a given model can be completely altered
by changing the material properties.

Finally, rendering.  Rendering is the process of taking a model object
and its material definitions and modeling the interaction of light
with the object to produce an image.  Examples of rendering programs
are Mitsuba and Radiance, and |toolbox| manual contains some examples
of their use.  Other rendering engines, of course, exist.

What |toolbox| does...
======================

\...and by corollary, what it does not.

The functions in |toolbox| can be used to create 3D wireframe models
of simple objects.  The shapes of the objects available include
spheres, planes, cylinders, and tori.  In addition to these, |toolbox|
can create surfaces of revolution and extrusion shapes based on a
shape profile provided by the user.  These shapes can be further
perturbed by different kinds of modulation.  The modulations include
sinusoidal components, filtered noise, Gaussian bumps and dents, and
other, user-defined perturbations.  User-defined perturbations include
using matrices and images as bump maps, as well as perturbations
defined by user-provided functions.  All parameters for the different
perturbations are provided by the user, so one can easily produce
parametrically varying shapes for experiment purposes.

|toolbox| also includes functions for viewing the models and writing
them to a file.  The models are saved in in plain text in Wavefront
obj-format.  These obj-files can be imported to most modeling and
rendering software.

|toolbox| has options for batch processing---producing a series of
models with a single function call.  Two models can be blended
(morphed) in different proportions to produce a range of intermediate
shapes between them.  Texture coordinates can be defined for texture
mapping, and there is an option for computing vertex normals for
improved rendering quality.

Workflow
========

TODO.
