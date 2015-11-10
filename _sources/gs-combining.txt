
.. _gs-combining:

==========================
Combining modulation types
==========================

As shown in earlier examples, the `objMake*`-functions can return the
model structure, which can then be viewed with the function `objShow`.
Returning the model structure has another use also: it can be passed
as an argument to another `objMake*`-function to add further
perturbation to it.  The following example first makes a cylinder with
a sinusoidal perturbation and then adds Gaussian 'dents' to it::

  m = objMakeSine('cylinder',[4 .1 0 60],'cyl1');
  objMakeBump(m,[50 -.1 .25],'cyl2');

Here are the two shapes side by side:

.. image:: ../images/gs-comb-cyl.png
   :width: 300px


The second example first makes a bumpy plane and then adds
high-frequency noise to it to simulate a rougher surface texture::

  m = objMakeBump('plane',[20 .05 .1],'npoints',[512 512],'plane1');
  objMakeNoise(m,[32 1 0 Inf .02],'plane2');

.. image:: ../images/gs-comb-pln.png
   :width: 300px

