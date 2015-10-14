
.. _gallerytransparentblob:

================================================
Transparent blob with noisy, textured background
================================================

.. image:: ../images/gallery/blob.png
   :width: 400px

TODO: Render better quality image.

Code for producing the model::
  
  objMakeBump('sphere',[8 .25 pi/8],..
              'material','blobmat',   
              'blob.obj');

  noiseprm = [32 1 45 45 .02];
  for ii = 1:3
    objMakeNoise('plane',noiseprm,   
                 'material','bkgrmat',
                 sprintf('background%0d.obj',ii));
  end

TODO: Radiance code for rendering.
