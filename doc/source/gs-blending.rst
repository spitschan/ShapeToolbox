
.. _gs-blending:

======================================
Blending (morphing between) two models
======================================

TODO.

Often the best way to make a series of models and smoothly vary
the modulation parameters.

But there is a way to blend/average/morph two models with user-defined
weights.


Make a smooth model and one perturbed by noise.  Then blend those to
different degrees.  This is the only way to do it because the noise is
random.  (Or you could make a matrix of noise and use that as a bump
map.)
