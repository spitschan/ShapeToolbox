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

%--------------------------------------------

% TODO
% Add an option for unequal size in x and y -- see objMakePlane
% If orientation full width is zero, that means no orientation
% filtering.  Or wait, should it be Inf?

if ~nargin || isempty(nprm)
  nprm = [8 1 0 45 .1 0];
end

[nncomp,ncol] = size(nprm);

if ncol==5
  nprm = [nprm zeros(nncomp,1)];
elseif ncol<5
  error('Incorrect number of columns in input argument ''nprm''.');
end

nprm(:,3:4) = pi * nprm(:,3:4)/180;

% Set the default modulation parameters to empty indicating no modulator; set default filename.
mprm  = [];
nmcomp = 0;

opts.filename = 'planenoisy.obj';
opts.m = 256;
opts.n = 256;
opts.use_rms = false;

[modpar,par] = parseparams(varargin);

% If modulator parameters are given as input, set mprm to these values
if ~isempty(modpar)
  mprm = modpar{1};
  % Set default values to modulator parameters as needed
  [nmcomp,ncol] = size(mprm);
  if ncol<5
    defprm = ones(nmcomp,1)*[1 0 0 0];
    mprm(:,ncol+1:5) = defprm(:,ncol:4);
    clear defprm
  end
  mprm(:,1) = mprm(:,1)*(pi);
  mprm(:,3:4) = pi * mprm(:,3:4)/180;
end

% Check other optional input arguments
[opts,plane] = objParseArgs(opts,par);

%--------------------------------------------

if opts.new_model
  m = opts.m;
  n = opts.n;

  w = 2; % width of the plane
  h = 2; % m/n * w;
  
  x = linspace(-w/2,w/2,n); % 
  y = linspace(-h/2,h/2,m)'; % 

  [X,Y] = meshgrid(x,y);
  Z = 0;
else
  m = plane.m;
  n = plane.n;
  X = reshape(plane.X,[n m])';
  Y = reshape(plane.Y,[n m])';
  Z = reshape(plane.Z,[n m])';
end

%--------------------------------------

Z = Z + objMakeNoiseComponents(nprm,mprm,X,Y,opts.use_rms);

X = X'; X = X(:);
Y = Y'; Y = Y(:);
Z = Z'; Z = Z(:);

vertices = [X Y Z];


if opts.new_model
  plane.prm.nprm = nprm;
  plane.prm.mprm = mprm;
  plane.prm.nncomp = nncomp;
  plane.prm.nmcomp = nmcomp;
  plane.prm.use_rms = opts.use_rms;
  plane.prm.mfilename = mfilename;
  plane.normals = [];
else
  ii = length(plane.prm)+1;
  plane.prm(ii).nprm = nprm;
  plane.prm(ii).mprm = mprm;
  plane.prm(ii).nncomp = nncomp;
  plane.prm(ii).nmcomp = nmcomp;
  plane.prm(ii).use_rms = opts.use_rms;
  plane.prm(ii).mfilename = mfilename;
  plane.normals = [];
end
plane.shape = 'plane';
plane.filename = opts.filename;
plane.mtlfilename = opts.mtlfilename;
plane.mtlname = opts.mtlname;
plane.comp_uv = opts.comp_uv;
plane.comp_normals = opts.comp_normals;
plane.w = w;
plane.h = h;
plane.n = n;
plane.m = m;
plane.X = X;
plane.Y = Y;
plane.Z = Z;
plane.vertices = vertices;

if opts.dosave
  plane = objSaveModel(plane);
end

if ~nargout
   clear plane
end
