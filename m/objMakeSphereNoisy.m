function sphere = objMakeSphereNoisy(nprm,varargin)

% OBJMAKESPHERENOISY
%
% Usage:           objMakeSphereNoisy()
%                  objMakeSphereNoisy(NPAR,[OPTIONS])
%                  objMakeSphereNoisy(NPAR,MPAR,[OPTIONS])
%         sphere = objMakeSphereNoisy(...)
%
% A 3D model sphere with the radius modulated by band-pass filtered
% noise.
% 
% Without any input arguments, makes an example sphere with default
% parameters and saves the model to spherenoisy.obj.
%
% The parameters for the filtered noise are given by the input
% argument NPAR:
%   NPAR = [FREQ FREQWDT OR ORWDT AMPL],
% with
%   FREQ    - middle frequency, in cycles/(2pi)
%   FREQWDT - full width at half height, in octaves
%   OR      - orientation in degrees (0 is 'vertical')
%   ORWDT   - orientation bandwidth (FWHH), in degrees
%   AMPL    - amplitude
% 
% The radius of the unmodulated sphere is 1. 
% 
% Several modulation components can be defined in the rows of NPAR.
% The components are added.
%   NPAR = [FREQ1 FREQWDT1 OR1 ORWDT1 AMPL1
%           FREQ2 FREQWDT2 OR2 ORWDT2 AMPL2
%           ...
%           FREQN FREQWDTN ORN ORWDTN AMPLN]
%
% To produce more complex modulations, separate carrier and
% modulator components can be defined.  The carrier components are
% defined exactly as above.  The modulator modulates the amplitude
% of the carrier.  The parameters of the modulator(s) are given in
% the input argument MPAR.  The modulators are sinusoidal; their
% parameters are identical to those in the function objMakeSphere.
% The parameters are frequency, amplitude, orientation, and phase:
%   MPAR = [FREQ AMPL OR PH]
% 
% You can also define group indices to noise carriers and modulators
% to specify which modulators modulate which carriers.  See details in
% the online help on in the help for objMakeSphere.
%
% By default, saves the object in spherenoisy.obj.  To save in a
% different file, define the output file name as a string:
%   > objMakeSphereNoisy(...,'newfilename',...)
%
% The default number of vertices when providing a function handle as
% input is 128x256 (elevation x azimuth).  To define a different
% number of vertices:
%   > objMakeSphereNoisy(...,'npoints',[N M],...)
%
% To turn on the computation of surface normals (which will increase
% computation time):
%   > objMakeSphereNoisy(...,'normals',true,...)
%
% For texture mapping, see help to objMakeSphere or online help.
%

% Examples:
% TODO

% Copyright (C) 2014,2015 Toni Saarela
% 2014-10-15 - ts - first version written
% 2014-10-28 - ts - polishing; improvements to computation of
%                    faces, uv-coords, writing specs to obj-file
% 2014-11-10 - ts - vertex normals, fixed call to renamed
%                    objMakeNoiseComponents, renamed to
%                    objMakeSphereNoisy, some help         
% 2015-04-02 - ts - calls the new objSaveModelSphere-function to
%                    compute faces, normals, etc and save the model to a file
%                   saving the model is optional, an existing model
%                     can be updated
% 2015-04-30 - ts - "switched" y and z directions: reference plane is
%                    x-z, y is "up"; added uv-option without materials
% 2015-05-04 - ts - calls objParseArgs and objSaveModel
% 2015-05-14 - ts - improved setting default modulator parameters
% 2015-05-29 - ts - call objSph2XYZ for coordinate conversion
% 2015-05-30 - ts - tidying, new function calls for default arguments etc
% 2015-06-01 - ts - calls objMakeNoise

%------------------------------------------------------------

if ~nargin
  nprm = [];
end
sphere = objMakeNoise('sphere',nprm,varargin{:});

if ~nargout
  clear sphere
end

