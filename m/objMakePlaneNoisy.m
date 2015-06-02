function plane = objMakePlaneNoisy(nprm,varargin)

% OBJMAKEPLANENOISY
%
% Usage:           objMakePlaneNoisy()
%                  objMakePlaneNoisy(NPAR,[OPTIONS])
%                  objMakePlaneNoisy(NPAR,MPAR,[OPTIONS])
%         sphere = objMakePlaneNoisy(...)
%
% A 3D model plane modulated in the z-direction by filtered noise.
%
% Without any input arguments, makes an example plane with default
% parameters adn saves the model in planenoisy.obj.
%
% The parameters for the filtered noise are given in the input
% argument NPAR:
%   NPAR = [FREQ FREQWDT OR ORWDT AMPL],
% with
%   FREQ    - middle frequency, in cycles per plane
%   FREQWDT - full width at half height, in octaves
%   OR      - orientation in degrees (0 is 'vertical')
%   ORWDT   - orientation bandwidth (FWHH), in degrees
%   AMPL    - amplitude
% 
% The width and height of the plane is 1.
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
% parameters are identical to those in the function objMakePlane.
% The parameters are frequency, amplitude, orientation, and phase:
%   MPAR = [FREQ AMPL OR PH]
% 
% You can also define group indices to noise carriers and modulators
% to specify which modulators modulate which carriers.  See details in
% the online help on in the help for objMakeSphere.
%
% By default, saves the object in planenoisy.obj.  To save in a
% different file, define the output file name as a string:
%   > objMakeSphereNoisy(...,'newfilename',...)
%
% The default number of vertices when providing a function handle as
% input is 256x256.  To define a different
% number of vertices:
%   > objMakePlaneNoisy(...,'npoints',[N M],...)
%
% To turn on the computation of surface normals (which will increase
% computation time):
%   > objMakePlaneNoisy(...,'normals',true,...)
%
% For texture mapping, see help to objMakePlane or online help.
%

% Examples:
% TODO

% Copyright (C) 2013,2014,2015 Toni Saarela
% 2013-10-15 - ts - first, rudimentary version
% 2014-10-09 - ts - improved speed, included filtering function,
%                   added input arguments/options
% 2014-10-11 - ts - improved filtering function, added orientation filtering
% 2014-10-11 - ts - now possible to use the modulators to modulate
%                    between two (or more) carriers
%                   can have different sizes in x and y directions
%                    (not tested properly yet)
% 2014-10-12 - ts - fixed a bug affecting the case when there are
%                   carriers AND modulators only in group 0
% 2014-10-15 - ts - added an option to compute texture coordinates and
%                    include a mtl file reference
% 2014-10-28 - ts - minor changes
% 2015-03-05 - ts - fixed computation of faces (they were defined CW,
%                    should be CCW.  oops.)
%                   vertex normals; write specs in comments; help
% 2015-04-03 - ts - calls the new objSaveModelPlane-function to
%                    compute faces, normals, etc and save the model to a file
%                   saving the model is optional, an existing model
%                     can be updated
% 2015-05-04 - ts - added uv-option without materials;
%                   calls objParseArgs and objSaveModel
% 2015-05-12 - ts - changed plane width and height to 2 (from -1 to 1)
% 2015-05-14 - ts - improved setting default modulator parameters
% 2015-05-30 - ts - tidying, new function calls for default arguments etc
% 2015-06-01 - ts - calls objMakeNoise

%------------------------------------------------------------

if ~nargin
  nprm = [];
end
plane = objMakeNoise('plane',nprm,varargin{:});

if ~nargout
  clear plane
end

