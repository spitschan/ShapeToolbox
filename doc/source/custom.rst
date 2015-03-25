
.. _custom:

======
Custom
======


.. _objmakecustom:

objMakeCustom()
===============

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

First, give an example how one might mimick :ref:`ref-objmakespherebumpy` using
the custom function.  Define the bump function in-line.

Define the function::
  
  f = @(d,prm) prm(1)*exp(-d.^2/(2*prm(2)^2))

Now do the thing::

  prm = [20 3*pi/12 .1 pi/12]
  
  objMakeSphereCustom(f,prm)


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
  prm = [10 pi/8  pi/12 .025 pi/16 pi/16
         10 pi/16 pi/24 .025 pi/32 pi/32]

  objMakeSphereCustom(@crater,prm,...
                      'npoints',[256 512],...
                      'mindist',pi/6,...
                      'filename','moon.obj')


Or make a cylinder with craters::

  prm = [20 pi/8+pi/16 pi/8 .025 pi/16 pi/16]

  objMakeCylinderCustom(@crater,prm,...
                        'npoints',[512 512],...
                        'mindist',pi/4);
