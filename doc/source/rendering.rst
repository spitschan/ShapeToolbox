
.. _rendering:

*********
Rendering
*********

Some tools for rendering images of the 3D shapes are listed below.
Please note that |toolbox| does *not* include any rendering
capabilities.  It only produces the models.  The tools listed below
can be useful for rendering the shapes, but they are not part of
|toolbox|, and they are not the only ones available out there.


=======
Mitsuba
=======

Mitsuba is an open-source rendering program that is based on PBRT (physically-based rendering). This means that Mitsuba mimics the physical interaction between light and surfaces relatively accurately. Mitsuba has both a GUI and a command-line interface (although configuring the command line tools on Mac/Windows can be challenging). The advantage of Mitsuba in comparison to other physically accurate renderers, such as RADIANCE, is its ease of use especially for rendering newbies. 

See `The Mitsuba project <http://www.mitsuba-renderer.org/download.html>`_ for downloading instructions and packages for Windows, Mac, and Linux. Also see `the documentation <http://www.mitsuba-renderer.org/docs.html>`_ for getting started with the software. 

In order to use the command line interface, you may have to configure the system path to point to the binaries (This should happen automatically on both Linux and Mac, but I did not have such luck on my Mac). On a Mac, the path to the Mitsuba binaries is most probably /Applications/Mitsuba.app/Contents/MacOS/. If you want your system to see the binaries, it is easiest to make symbolic links to the binaries in a directory that is already on the system path (what is on the path can be checked by typing $PATH in terminal.) On my Mac, for instance, I ran the following command for the mitsuba binary (repeat for all the other binaries in the directory)::
  
  sudo ln -s /Appplications/Mitsuba.app/Contents/MacOS/mitsuba /opt/local/bin/

Once you have Mitsuba running, you can start the GUI by either typing mtsgui in Terminal in Mac/Linux, or clicking the Mitsuba icon in Applications (or equivalent) on a Mac (Windows).

Open one example scene .xml in Mitsuba to see how it looks (e.g. ShapeToolbox/demos/cloudscene.xml). You can rotate the shape by dragging it with the mouse. To render the shape, press the play button. 

It is relatively easy to configure the rendering parameters in Mitsuba by editing an .xml file, which is a text file  you can edit in your favorite text editor.  You can use the example files in ShapeToolbox/examples to get started. Look at the file examples/demo_cylinder/cylinder.xml. The parameters for the shape are defined in the lower part of the file (see the <shape> flag). The color and material  are defined in the <bsdf> section. Play with the color values (value=) and see what happens! The orientation of the cylinder relative to the camera is defined by the <transform> parameters. Finally, the illumination in the scene is defined my the <emitter> parameter. See `Mitsuba documentation <http://www.mitsuba-renderer.org/docs.html>`_ Mitsuba for more illumination types!

Mitsuba allows for environment maps to illuminate the scenes, which creates a more realistic illumimation. `The Mitsuba project <http://www.mitsuba-renderer.org/download.html>`_ webpage has some examples with environment maps, and we also have some example scenes with environment maps (see e.g. demos/demo_sphere/sphere_env.xml). Unlike RADIANCE, Mitsuba requires the maps to be in longitude-latitude format ("unwrapped"). Such maps are available in high resolution and high dynamic range (for free!) from `Paul Debevec  <http://www.pauldebevec.com/Probes/>`_ and `Bernhard Vogel  <http://dativ.at/lightprobes/>`_. 

Batch rendering in Mitsuba
===============

Once you have .xml files for your shapes, you can render scenes in batches by using wildcars, assuming all of the scene files have the same prefix. E.g. if the prefix for all of your scenes is 'myObject', you can render all your scenes in one folder by saying::

  mitsuba path-to-files/myObject*.xml 


Since we are comfortable working within Octave/Matlab, there are example scripts in the ShapeToolbox/demos to batch render simple scenes in Mitsuba from within Matlab (TODO). The xml-files in the examples directory contain default parameters that can be modified as desired. The  m-file wrappers to the mitsuba command can also be modified to change paths to files, filename prefixes, etc.  

========
Radiance
========

`Radiance <http://radsite.lbl.gov/radiance/>`_ is a ray-tracing software package, which allows for physically accurate rendering. Radiance has been used extensively in vision science applications, but it has a pretty steep learning curve (compared to Mitsuba, for instance). Because of the status of Radiance as state-of-the-art physically-based rendering for two decades, we have included examples of Matlab wrappers to Radiance in the demos/rendering directory. Radiance does produce beautiful images, and so it is sometimes our rendering engine of choice.

Radiance allows texture mapping, but unfortunately does not understand the texture mapping created in ShapeToolbox without additional tweaking. We have included demos of material definition files that Radiance should understand. To map your textures onto objects, you will naturally have to edit the files appropriately. 

TODO: an example on how to do the texture mapping in radiance
(obj2mesh, colorpict...).


==============
RenderToolbox3
==============

`RenderToolbox3 <http://rendertoolbox.org/>`_  is a set of free and open-source Matlab tools that facilitate 3D rendering with physically-based renderers.A particular focus is on easy manipulation of surface spectral reflectances, surface materials, and illuminant spectral power distributions. Setting up RenderToolbox for Mac is probably straightforward, but might be tricky for Linux (although there are instructions for CentOS Linux on the webpage). RenderTooolbox is not implemented on Windows. RenderToolbox is great for rendering scenes with parametric manipulation of surface reflectance and illumination. For simple scenes and demos it may be easier to start with Mitsuba or Blender, which are simple to get running.        

=======
Blender
=======



