
.. _installation:

************
Installation
************

================
Getting the code
================

Using Git
=========

If you have git installed, you can clone the repository and stay
up-to-date with the latest version of the toolbox.  Go to the
directory where you want to keep the files, and do::
  
  git clone https://github.com/saarela/ShapeToolbox.git


Download zip file
=================

Alternatively, download a zip archive.  Click the following link to
download a zip-archive of the toolbox.  Unzip the file to the
directory where you want to keep the files.

https://github.com/saarela/ShapeToolbox/archive/master.zip

==========
Installing
==========

All you need to do is add the toolbox directory that has the m-files
to Octave or Matlab path.  Fire up Octave/Matlab and add the
folder m in your path like so::

  addpath('path_to_shapetoolbox/m')

For example, ::
  
  addpath('~/Documents/MATLAB/ShapeToolbox/m')

That's it.  Add that command to your startup-file, either
``.octaverc`` (for Octave) or ``startup.m`` (for Matlab) to
automatically add ShapeToolbox to the path every time you start Octave
or Matlab.


