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

%--------------------------------------------------

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

% Set the default modulation parameters to empty indicating no
% modulator; set default filename, material filename.
mprm  = [];
nmcomp = 0;

opts.filename = 'spherenoisy.obj';
opts.use_rms = false;
opts.m = 128;
opts.n = 256;

[modpar,par] = parseparams(varargin);

% If modulator parameters are given as input, set mprm to these values
if ~isempty(modpar)
   mprm = modpar{1};
end

% Set default values to modulator parameters as needed
if ~isempty(mprm)
  [nmcomp,ncol] = size(mprm);
  switch ncol
    case 1
      mprm = [mprm ones(nmcomp,1)*[1 0 0 0]];
    case 2
      mprm = [mprm zeros(nmcomp,4)];
    case 3
      mprm = [mprm zeros(nmcomp,3)];
    case 4
      mprm = [mprm zeros(nmcomp,2)];
  end
  mprm(:,3:4) = pi * mprm(:,3:4)/180;
end

% Check other optional input arguments
[opts,sphere] = objParseArgs(opts,par);
  
% Add file name extension if needed
if isempty(regexp(opts.filename,'\.obj$'))
  opts.filename = [opts.filename,'.obj'];
end

%--------------------------------------------
% Vertices

if opts.new_model
  m = opts.m;
  n = opts.n;

  r = 1; % radius
  theta = linspace(-pi,pi-2*pi/n,n); % azimuth
  phi = linspace(-pi/2,pi/2,m)'; % elevation

  [Theta,Phi] = meshgrid(theta,phi);
else
  n = sphere.n;
  m = sphere.m;
  Theta = reshape(sphere.Theta,[n m])';
  Phi = reshape(sphere.Phi,[n m])';
  r = reshape(sphere.r,[n m])';
end

R = r + objMakeNoiseComponents(nprm,mprm,Theta,Phi,opts.use_rms);

Theta = Theta'; Theta = Theta(:);
Phi   = Phi';   Phi   = Phi(:);
R = R'; R = R(:);

% Convert vertices to cartesian coordinates
[X,Y,Z] = sph2cart(Theta,Phi,R);

% Switch z- and y-coordinates so that the reference plane is the x-z
% plane and y is "up", for consistency across all functions.
vertices = [X Z -Y];

clear X Y Z

% The field prm can be made an array.  If the structure sphere is
% passed to another objMakeSphere*-function, that function will add
% its parameters to that array.
if opts.new_model
  sphere.prm.nprm = nprm;
  sphere.prm.mprm = mprm;
  sphere.prm.nncomp = nncomp;
  sphere.prm.nmcomp = nmcomp;
  sphere.prm.use_rms = opts.use_rms;
  sphere.prm.mfilename = mfilename;
  sphere.normals = [];
else
  ii = length(sphere.prm)+1;
  sphere.prm(ii).nprm = nprm;
  sphere.prm(ii).mprm = mprm;
  sphere.prm(ii).nncomp = nncomp;
  sphere.prm(ii).nmcomp = nmcomp;
  sphere.prm(ii).use_rms = opts.use_rms;
  sphere.prm(ii).mfilename = mfilename;
  sphere.normals = [];
end
sphere.shape = 'sphere';
sphere.filename = opts.filename;
sphere.mtlfilename = opts.mtlfilename;
sphere.mtlname = opts.mtlname;
sphere.comp_uv = opts.comp_uv;
sphere.comp_normals = opts.comp_normals;
sphere.n = n;
sphere.m = m;
sphere.Theta = Theta;
sphere.Phi = Phi;
sphere.R = R;
sphere.vertices = vertices;

if opts.dosave
  sphere = objSaveModel(sphere);
end

if ~nargout
   clear sphere
end

