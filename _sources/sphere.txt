
.. _sphere:

======
Sphere
======


.. image:: ../images/sphere_coords_3d_400.png
   :width: 300px
.. image:: ../images/sphere_coords.png


Coordinate system
=================

TODO: There might be zero-area faces, and Radiance at least will
complain about them.  The sampling is in many cases highly redundant
near the poles where the lines of longitude meet.  This could be
down-sampled when writing to a file to reduce the files size, but it
is not done in |toolbox|.  There are a couple of reasons for this.
The models produced by |toolbox| functions can be given as input to
other functions to add perturbations, and two models can also be
blended.  In these cases, the coordinates systems and the sampling
points have to match.  Also, in some cases you might want a
high-frequency modulation near the poles.  These models are meant for
experiments, not for efficient computer graphics applications, so
|toolbox| does not throw away the vertex data.



.. _objmake-sphere:

objMake
=======


.. _objmakesine-sphere:

objMakeSine
===========


.. _objmakenoise-sphere:

objMakeNoise
============


.. _objmakebump-sphere:

objMakeBump
===========



.. _objmakecustom-sphere:

objMakeCustom
=============

Image
-----

.. image:: ../images/text.png
           

A matrix
--------

User-defined functions
----------------------

Explanation, function handles, blah blah.

A bumpy sphere
^^^^^^^^^^^^^^

First, give an example how one might mimick :ref:`ref-objmakebump` using
the custom function.  Define the bump function in-line.

Define the function::
  
  f = @(d,prm) prm(1)*exp(-d.^2/(2*prm(2)^2))

Now do the thing::

  prm = [20 3.5*8 .1 8]
  
  objMakeCustom('custom',f,prm)


A cratered moon
^^^^^^^^^^^^^^^

Then, give the crater example.  

Specify the crater function::

  function C = crater(d,prm)

  r = prm(1);       % radius of the crater
  a = prm(2);       % amplitude of the crater edge
  width1 = prm(3);  % width of the inner slope
  width2 = prm(4);  % width of the outer slope
  
  d = d-r;
  C = zeros(size(d));
  
  % The inner slope of the crater
  idx = d>-width1 & d<=0;
  C(idx) = a*(1+cos(2*pi*(1/(4*width1))*(d(idx))-pi/2));

  % The outer slope
  idx = d<width2 & d>=0;
  C(idx) = a*(1+cos(2*pi*(1/(4*width2))*(d(idx))+pi/2));


Make the sphere with craters::

  %      n  cutoff radius amplitude width1 width2
  prm = [10 25   15  .025 10 10
         10 12.5 7.5 .025 5  5]

  objMakeCustom('sphere',...
                @crater,prm,...
                'npoints',[256 512],...
                'mindist',30,...
                'moon.obj')


Or make a cylinder with craters::

  prm = [20 pi/8+pi/16 pi/8 .025 pi/16 pi/16]

  objMakeCustom('cylinder',...
                @crater,prm,...
                'npoints',[512 512],...
                'mindist',pi/4);
