
===================================
3D models, materials, and rendering
===================================

There are many steps in producing a computer-rendered image of a 3D
model.  The first step is to create the model.  The simplest model
defines a set of points (*vertices*) in three dimensions, and a set of
*faces*, or groups of vertices.  Together the faces approximate the
surface to be modeled.  More information about vertex normals (the
normal vector of the surface-to-be-approximated at that point) and
texture coordinates can be defined to improve the rendering of the
model.  The model is often saved in a text file.  This first step is
the one |toolbox| can be used for.

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

