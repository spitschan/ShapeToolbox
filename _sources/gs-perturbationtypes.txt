
.. _gs-perturbationtypes:

==================
Perturbation types
==================

This section briefly illustrates the different types of perturbation
that can be added to the shapes.  It also shows some of the other base
shapes (besides the sphere).

Sinusoids
=========

Earlier sections demonstrated perturbing the sphere with sinusoids.
Sinusoids can be added to other shapes as well, for example to planes
and tori::

  t = objMakeSine('torus',[12 .1 0 0]);
  objShow(t)

  p = objMakeSine('plane',[4 .05 0 -45; 12 .025 0 45];
  objShow(p)

  p = objMakeSine('plane',...
                  [24 .05 0 -45 1; 12 .05 0 45 2],...
                  [2 1 0 0 1; 2 1 180 0 2]);
  objShow(p)

Filtered noise
==============

Filtered noise components can be used to perturb all shapes with the
function :ref:`ref-objmakenoise`.  The input vector to this function
defines the filtering parameters: ``[FREQ FREQWDT OR ORWDT AMPL]``,
where freq is the mean frequency, freqwdt is the bakdwidth (full-width
at half height), or is the orientation/angle, and orwdt is the
orientation bandwidth.  ampl is the amplitude.  Examples::

  c = objMakeNoise('cylinder',[10 1 0 30 .07]);
  objShow(c)
  
  c = objMakeNoise('cylinder',[8 1 60 45 .1]);
  objShow(c)

To make isotropic noise, set the orientation bandwidth to ``Inf``::

  m = objMakeNoise('plane',[16 1 0 Inf .05]);
  objShow(m)

  m = objMakeNoise('plane',[4 2 45 20 .1; 32 1 0 Inf .02]);
  objShow(m)

Envelopes can be used with noise carriers just as with
sinusoidal carriers::

  s = objMakeNoise('sphere',[24 1 0 Inf .1],[7 1 -90 90]);

Gaussian bumps and dents
========================

Function :ref:`ref-objmakebump` adds Gaussian "bumps" (or dents) to
the shape.  By default the bumps are randomly placed, but there is an
option for precise positioning of bumps (see the documentation for
:ref:`ref-objmakebump`).  The parameter vector is ``[nbumps ampl sd]``,
where ``nbumps`` is the number of bumps, ``ampl`` is the amplitude,
and ``sd`` is the standard deviation of the Gaussian.

::

   sph = objMakeBump('sphere'); % Uses default parameters
   objShow(sph);

   sph = objMakeBump('sphere',[10 .05 .6; 40 .2 .1]);
   objShow(sph);

   

To make dents, define a negative amplitude::
   
   cyl = objMakeBump('cylinder',[30 -0.05 0.15]);
   objShow(cyl)

   % Combine bumps and dents
   cyl = objMakeBump('cylinder',[20 .1 .4; 40 -.05 .15]);
   objShow(cyl)

When two or more bumps are overlapping, the perturbations are added.
To constrain how close two bumps can be, use the ``mindist``-option
that sets a minimum distance for bump centers::

  p1 = objMakeBump('plane',[20 .1 .03]);
  p2 = objMakeBump('plane',[20 .1 .03],'mindist',.2);
  figure
  subplot(1,2,1); objShow(p1)
  subplot(1,2,2); objShow(p2)

The default behavior of adding overlapping bumps can be overridden by
setting the option ``max`` to true: the perturbations are then
combined using a max-operation instead of summing. ::

  p1 = objMakeBump('plane',[20 .1 .2]);
  p2 = objMakeBump('plane',[20 .1 .2],'max',true);
  figure
  subplot(1,2,1); objShow(p1)
  subplot(1,2,2); objShow(p2)


Custom modulation
=================

Matrix as a height map
----------------------

TODO.


Image as a height map
---------------------

TODO.

::

   s = objMakeCustom ('sphere','shapetoolbox.png',.1);
   objShow(s)

   p = objMakeCustom ('plane','shapetoolbox.png',.05);
   objShow(p)


User-defined function
---------------------

TODO.

::

   spike = @(d,x) x(1)*exp(-d/x(2))

   s = objMakeCustom('sphere',spike,[40 .3 .5 .05],'npoints',[512 256],'mindist',.15);
   objShow(s);
