
.. _ref-sphere:

=======
Spheres
=======

These functions perturb a unit sphere (radius 1) with different kinds
of modulation.

.. _ref-objmakesphere:

objMakeSphere
=============

Modulate the sphere radius by adding sinusoidal components and
optionally envelopes that modulate their amplitude.

.. mat:function:: m = objMakeSphere(cpar[,mpar][,options])

   :param cpar: 
      Modulation carrier parameters::
        
        [frequency amplitude phase angle]
      
      Or a matrix if defining multiple carriers::

        [frequency1 amplitude1 phase1 angle1 [group_id1]]
        ...
        frequencyN amplitudeN phaseN angleN [group_idN]]

      Frequency is given in cycles per :math:`2\pi`, phase and angle
      in degrees.  Optional group id number can be defined to couple
      carriers with envelopes (see below).  Carriers with the same
      group id are added together and then multiplied by the
      corresponding envelope.  Finally, the groups are added together.
      Group id 0 (default) is special: carriers with id 0 are first
      added to the other components without an envelope.  Possible
      envelope (see below) with id 0 finally multiplies all other
      components, no matter what their group id is.

   :param mpar: 
      Modulation envelope parameters::
        
        [frequency amplitude phase angle]
      
      Or a matrix if defining multiple envelopes::

        [frequency1 amplitude1 phase1 angle1 [group_id1]
        ...
        frequencyN amplitudeN phaseN angleN [group_idN]]

   :param options:

      Other options can be defined in any order.  With the exception
      of the filename, these are name-value pairs.

      - *'filename'* - a string giving the filename to save the object.
        Default 'sphere.obj'.  Two save in 

      - *'npoints'* - A two-vector that sets number of vertices.
        Default ``[128 256]``.  Example::
        
          'npoints',[256 512]

      - *'uvcoords'* - ``true`` or ``false`` (default).  Toggle
        computation of texture (uv-) coordinates.  Example::
          
          'uvcoods',true

      - *'material'* - A cell array giving a material library file and
        material name.  Forces computation of uv-coordinates::

          'material',{'materialfile.mtl','matname'}

      - *'normals'* - ``true`` or ``false`` (default).  Toggle
        computation of vertex normals::
          
          'normals',true

      - *'save'* - ``true`` (default) or ``false``.  Toggle
        saving the model to a file.  Example to skip saving::

          objMakeSphere(cpar,'save',false)

      - *'model'* - A model object structure returned by an
        objMakeSphere*-function.  The modulation is added to the
        existing model::

          'model',m

   :return: A structure holding the model object information.  Can be
            used as input to another objMakeSphere*-function or saved
            using :ref:`ref-objsavemodel`.


.. _ref-objmakespherenoisy:

objMakeSphereNoisy
====================

Modulate the sphere by adding filtered noise components, and
optionally envelopes that modulate the noise amplitude.

.. mat:function:: m = objMakeSphereNoisy(npar[,mpar][,options])

   :param npar: 
      Noise carrier parameters::
        
        [frequency freqFWHH angle angleFWHH amplitude]
      
      Or a matrix if defining multiple carriers::

        [frequency1 freqFWHH1 angle1 angleFWHH1 amplitude1 [group_id1]]
        ...
        [frequencyN freqFWHHN angleN angleFWHHN amplitudeN [group_idN]]

      Frequency is given in cycles per :math:`2\pi`, bandwidth
      (freqFWHH) in octaves.  Angle (orientation) and its bandwidth
      given in degrees.  Amplitude is the peak absolute value of the
      modulation.  If the option ``rms`` is true (see below),
      the amplitude parameter defines the root-mean-square contrast.

      Group id numbers are as in :ref:`ref-objmakesphere` above.

   :param mpar: Same format as :ref:`ref-objmakesphere` above. 

   :param options: 
      Same ones as :ref:`ref-objmakesphere` above, plus the following:

      - *'rms'* - ``true`` or ``false`` (default).  Whether the
        amplitude defines root-mean-square contrast instead of peak value.

   :return: A structure holding the model object information.  Can be
            used as input to another objMakeSphere*-function or saved
            using :ref:`ref-objsavemodel`.


.. _ref-objmakespherebumpy:

objMakeSphereBumpy
====================

Modulate the sphere by adding Gaussian bumps to the surface.

.. mat:function:: m = objMakeSphereBumpy(par[,options])

   :param par: 
      Gaussian bump parameters::
        
        [nbumps amplitude sigma]
        
      Or a matrix if defining several bump types::

        [nbumps1 amplitude1 sigma1
         ...
         nbumpsN amplitudeN sigmaN]
         
      Amplitude can be negative to make dents.  Sigma is the space
      constant of the Gaussian, given in radians.

   :param options: 
      Same ones as :ref:`ref-objmakesphere` above, plus the following:

      - *'mindist'* - Minimum distance between bumps, in radians.  Can
        be a scalar or a vector if there are several bump types
        defined.  If sevearl bump types are defined and ``mindist`` is
        a scalar, the same minimum distance is used for all types.

      - *'locations'* - Bump locations.  By default the bumps are
        placed in random locations (constrained by ``mindist`` if
        defined).  By defining ``locations`` the bumps are placed at
        requested locations.  Locations are given as azimuth (theta) and
        elevation (phi) angles (in radians) in cell arrays::

          % Single bump type, three bumps
          'locations',{{[t1 t2 t3]},{[p1 p2 p3]}}

          % Two bump types, first one has three, second one two bump types
          'locations',{{[t11 t12 t13],[t21 t22]},{[p11 p12 p13],[p21 p22]}}


        The location array can be left empty for a given bump type, in
        which case the locations are chosen at random.

   :return: A structure holding the model object information.  Can be
            used as input to another objMakeSphere*-function or saved
            using :ref:`ref-objsavemodel`.

.. _ref-objmakespherecustom:

objMakeSphereCustom
=====================


.. mat:function:: m = objMakeSphereCustom(function_handle,par[,options])

   Modulate the sphere by providing a handle to a function and input
   parameters that define the modulation.


   :param function_handle: A handle to a function that is used to
                           compute the perturbations.  That function
                           has to take a distance parameter as its
                           first input argument and possibly a vector
                           of further parameters as the second argument.

   :param par: 
      A vector of parameters for calling the function.  The vector
      gives the number of locations at which the function is applied,
      a cutoff distance from the mid-point, and other parameters fed
      to the custom function::

        [nloc cut_dist prm1 prm2 . . . prmN]

      To apply the same function with different sets of parameters::

        [nloc1 cut_dist1 prm11 prm12 . . . prm1N
         ...
         nlocM cut_distM prmM1 prmM2 . . . prmMN]

      Locations are chosen at random (possibly constrained by
      ``mindist``) if the option ``locations`` is not used.

   :param options: 
      Same ones as :ref:`ref-objmakespherebumpy` above.
 

.. mat:function:: m = objMakeSphereCustom(image,amplitude[,options])

   Use an image as a 'bump map'.

   :param image: Name of an image file.  The values of the image are
                 used as a bump map to perturb the sphere.  If the
                 image is an RGB image, the average value (over r,
                 g, b) is used.

   :param amplitude: Maximum amplitude of modulation.  The values of
                     the image map are first normalized to 0-1, then
                     multiplied by the amplitude parameter to
                     determine the final perturbation values.

   :param options: 
      Same ones as :ref:`ref-objmakesphere` above.

.. mat:function:: m = objMakeSphereCustom(matrix,amplitude[,options])

   Use a matrix as a bump map.

   :param matrix: A matrix to be used as a bump map to perturb the
                  sphere.

   :param amplitude: Maximum amplitude of modulation (maximum absolute
                     perturbation value).

   :param options: 
      Same ones as :ref:`ref-objmakesphere` above.

   :return: A structure holding the model object information.  Can be
            used as input to another objMakeSphere*-function or saved
            using :ref:`ref-objsavemodel`.
