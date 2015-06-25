
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

In order to use the command line interface, you may have to configure the system path to point to the binaries. On Mac, the path to the Mitsuba binaries is most probably /Applications/Mitsuba.app/Contents/MacOS/. If you want your system to see the binaries, it is easiest to make symbolic links to the binaries in a directory that is already on the system path (what is on the path can be checked by typing $PATH in terminal.) On my system, for instance, I ran the following command for the mitsuba binary (repeat for all the other binaries in the directory)::
  
  sudo ls -s /Appplications/Mitsuba.app/Contents/MacOS/mitsuba /opt/local/bin/

Once you have Mitsuba running, you can start the GUI by either typing mtsgui in Terminal, or clicking the Mitsuba icon in Applications (TODO: instructions for linux!).

Open one example scene .xml in Mitsuba to see how it looks (e.g. ShapeToolbox/examples/images/cloudscene.xml). You can rotate the shape by dragging it with the mouse. To render the shape, press the play button. To set rendering parameters, such as camera angle, object size, etc., you can edit the . xml file. See the `Mitsuba documentation <http://www.mitsuba-renderer.org/docs.html>`_ Mitsuba for more info on the parameters.

Rendering in Mitsuba is easy to configure by setting the rendering parameters in an .xml file. You can use the example files in ShapeToolbox/examples to get started. 

Batch rendering in Mitsuba
===============

Once you have .xml files for your shapes, you can render scenes in batches by using wildcars, assuming all of the scene files have the same prefix. E.g. if the prefix for all of your scenes is 'myObject', you can render all your scenes in one folder by saying (TODO: test this!)::

  mitsuba path-to-files/myObject*.xml 


Since we are comfortable working within Octave/Matlab, there are example scripts in the ShapeToolbox/examples to batch render simple scenes in Mitsuba from within Matlab. The xml-files in the examples directory contain default parameters that can be modified as desired. The  m-file wrappers to the mitsuba command can also be modified to change paths to files, filename prefixes, etc.  

========
Radiance
========

TODO: an example on how to do the texture mapping in radiance
(obj2mesh, colorpict...).


==============
Render Toolbox
==============


=======
Blender
=======

