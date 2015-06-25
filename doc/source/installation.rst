
.. _installation:

************
Installation
************

=============
Prerequisites
=============

Platform
========

|toolbox| should run on GNU/Linux, Mac, and Windows.  It was
developed in GNU/Linux, and tested most extensively on GNU/Linux and
Mac.  

Octave or Matlab
================

|toolbox| was mainly developed on Ubuntu Linux using Octave 3.8.1 and
Octave 4.0.0.  Tested on XXXX.  It should work with any reasonably
up-to-date version of Octave or Matlab, but no guarantees.

================
Getting the code
================

Using Git
=========

If you have `git <http://www.git-scm.com/>`_ installed, you can clone
the repository and stay up-to-date with the latest version of the
toolbox.  In the terminal or command line, go to the directory where
you want to keep the files, and do::
  
  git clone https://github.com/saarela/ShapeToolbox.git

To keep the code up to date with latest bug fixes, do::

  git pull

often.


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

=========================
Structure of ShapeToolbox
=========================

Folder ``ShapeToolbox/m`` has the code.  It has a sub-folder ``private``, which holds
functions called by the main toolbox functions.

Folder ``ShapeToolbox/doc`` has the documentation.  The folder ``doc/build/html`` has
the html documentation.  Open the file ``doc/build/html/index.html``
to view the manual.

Folder ``ShapeToolbox/demos`` has several subfolders with short demos illustrating
the functionality of the toolbox.

