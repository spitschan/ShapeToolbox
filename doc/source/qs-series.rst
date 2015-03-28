
.. _qs-series:

==========================
Making a series of stimuli
==========================

One of the purposes of |toolbox| is to provide a tool for making
sets of stimuli with parametric variations in shape.

TODO: This example: vary from one frequency to another. ::

  % Set a vector of frequencies
  freq = 4:8;
  
  % Set other parameters to constant values
  a  = .1;  % amplitude
  ph = 0;   % phase
  or = 0;   % angle/orientation
  
  % Loop through frequencies
  for ii = 1:length(freq)
    % Set filename with frequency value
    filename = sprintf('sphere_f%d.obj',freq(ii));
    % Make the model
    objMakeSphere([freq(ii) a ph or],filename);
  end
  
TODO: Next example: Have two components (-60 and 60 degree angles); vary
amplitude to go from component 1 to a mixture to component 2 only. ::

  % Set amplitudes of the two components.  These are between 0 and 0.1,
  % in steps of 0.02, varied in opposition to each other.
  a1 = .1:-0.02:0  % goes from 0.1 to 0.0
  a2 = .1 - a1;    % goes from 0.0 to 0.1
  
  % Set other parameters to constant values
  freq =  20;    % frequency
  ph   =   0;    % phase
  or1  = -60;    % angle/orientation of component 1
  or2  =  60;    % angle/orientation of component 2
  
  % Loop through frequencies
  for ii = 1:length(freq)
    % Set filename with frequency value
    filename = sprintf('sphere_%03d_%03d.obj',100*a1(ii),100*a2(ii));
    % Make the model
    objMakeSphere([freq a1(ii) ph or1; freq a2(ii) ph or2],filename);
  end


Note that these are only examples of making and saving a series of
stimuli.  The particular stimuli produced are not necessarily
interesting or informative to use in a vision experiment.
