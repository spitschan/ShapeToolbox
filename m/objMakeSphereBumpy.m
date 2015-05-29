function sphere = objMakeSphereBumpy(prm,varargin)

% OBJMAKESPHEREBUMPY
% 
% Usage:          objMakeSphereBumpy()
%                 objMakeSphereBumpy(PAR,[OPTIONS])
%        SPHERE = objMakeSphereBumpy(...)
%
% Make a 3D model sphere with the radius perturbed by Gaussian
% 'bumps'.  The input vector defines the number of bumps and their
% amplitude and spread:
%   PAR = [NBUMPS AMPL SD]
% 
% The radius of the unmodulated sphere is 1.  The bumbs are added to
% this radius with the amplitude AMPL.  The amplitude can be negative
% to produce dents. The spread (standard deviation) of the bumps is
% given by SD, in degrees.
%
% To have different types of bumps in the same sphere, define several
% sets of parameters in the rows of PAR:
%   PAR = [NBUMPS1 AMPL1 SD1
%          NBUMPS2 AMPL2 SD2
%          ...
%          NBUMPSN AMPLN SDN]
%
% Options:
% 
% By default, saves the object in spherebumpy.obj.  To save in a
% different file, define the output file name as a string:
%   > objMakeSphereBumpy(...,'newfilename',...)
%
% Other optional arguments are key-value pairs.  To set the minimum
% distance between the bumps (in degrees), use:
%  > objMakeSphereBumpy(...,'mindist',DMIN)
%
% The default number of vertices is 128x256 (elevation x azimuth).  
% To define a different number of vertices:
%   > objMakeSphereBumpy(...,'npoints',[N M],...)
%
% To turn on the computation of surface normals (which will increase
% coputation time):
%   > objMakeSphereBumpy(...,'NORMALS',true,...)
%
% For texture mapping, see help to objMakeSphere or online help.
%
% Note: The minimum distance between bumps only applies to bumps of
% the same type.  If several types of bumps are defined (in rows of
% the imput argument prm), different types of bumps might be closer
% together than mindist.  This might change in the future.
%

% Examples:
% TODO

% Copyright (C) 2014,2015 Toni Saarela
% 2014-05-06 - ts - first version
% 2014-08-07 - ts - option for mixing bumps with different parameters
%                   made the computations much faster
% 2014-10-09 - ts - better parsing of input arguments
%                   added an option for minimum distance of bumps
%                   added an option for number of vertices
%                   fixed an error in writing the bump specs in the
%                     obj-file comments
% 2014-10-28 - ts - bunch of small changes and improvements;
%                     sigma is given in degrees now
% 2014-11-10 - ts - vertex normals, basic help
% 2015-04-02 - ts - calls the new objSaveModelSphere-function to
%                    compute faces, normals, etc and save the model to a file
%                   saving the model is optional, an existing model
%                     can be updated
% 2015-04-30 - ts - "switched" y and z directions: reference plane is
%                    x-z, y is "up"; added uv-option without materials
% 2015-05-04 - ts - calls objParseArgs and objSaveModel
% 2015-05-13 - ts - added bump locations as optional input arg.
%                    locations also included in the model structure
% 2015-05-14 - ts - different minimum distance can be defined for each
%                    bump type
% 2015-05-29 - ts - call objSph2XYZ for coordinate conversion

% TODO
% - option to add noise to bump amplitudes/sigmas

%--------------------------------------------

if ~nargin || isempty(prm)
  prm = [20 .1 8];
end

[nbumptypes,ncol] = size(prm);

switch ncol
  case 1
    prm = [prm ones(nccomp,1)*[.1 8]];
  case 2
    prm = [prm ones(nccomp,1)*8];
end

prm(:,3) = pi*prm(:,3)/180;

nbumps = sum(prm(:,1));

% Set default values before parsing the optional input arguments.
opts.filename = 'spherebumpy.obj';
opts.m = 128;
opts.n = 256;
opts.mindist = 0;
opts.locations = {};

[tmp,par] = parseparams(varargin);

% Check other optional input arguments
[opts,sphere] = objParseArgs(opts,par);

if isscalar(opts.mindist)
   opts.mindist = ones(1,nbumptypes) * opts.mindist;
elseif length(opts.mindist)~=nbumptypes
  error('Incorrect number of minimum distances defined.');
end

mindist = pi*opts.mindist/180;

%--------------------------------------------
% TODO:
% Throw an error if the asked minimum distance is a ridiculously large
% number.
%if mindist>
%  error('Yeah right.');
%end

%--------------------------------------------
% Vertices

if opts.new_model
  m = opts.m;
  n = opts.n;

  r = 1; % radius
  theta = linspace(-pi,pi-2*pi/n,n); % azimuth
  phi = linspace(-pi/2,pi/2,m); % elevation
  
  [Theta,Phi] = meshgrid(theta,phi);
  Theta = Theta'; Theta = Theta(:);
  Phi   = Phi';   Phi   = Phi(:);
  R = r * ones(m*n,1);
else
  m = sphere.m;
  n = sphere.n;
  Theta = sphere.Theta;
  Phi = sphere.Phi;
  R = sphere.R;
end

for jj = 1:nbumptypes

  if ~isempty(opts.locations) && ~isempty(opts.locations{1}{jj})

     theta0 = opts.locations{1}{jj};
     phi0 = opts.locations{2}{jj};

  elseif mindist(jj)
    % Make extra candidate vectors (30 times the required number)
    %ptmp = normrnd(0,1,[30*prm(jj,1) 3]);
    ptmp = randn([30*prm(jj,1) 3]);
    % Make them unit length
    ptmp = ptmp ./ (sqrt(sum(ptmp.^2,2))*[1 1 1]);
    
    % Matrix for the accepted vectors
    p = zeros([prm(jj,1) 3]);

    % Compute distances (the same as angles, radius is one) between
    % all the vectors.  Use the real function here---sometimes,
    % some of the values might be slightly larger than one, in which
    % case acos returns a complex number with a small imaginary part.
    d = real(acos(ptmp * ptmp'));

    % Always accept the first vector
    idx_accepted = [1];
    n_accepted = 1;
    % Loop over the remaining candidate vectors and keep the ones that
    % are at least the minimum distance away from those already
    % accepted.
    idx = 2;
    while idx <= size(ptmp,1)
      if all(d(idx_accepted,idx)>=mindist)
         idx_accepted = [idx_accepted idx];
         n_accepted = n_accepted + 1;
      end
      if n_accepted==prm(jj,1)
        break
      end
      idx = idx + 1;
    end

    if n_accepted<prm(jj,1)
       error(sprintf('Could not find enough vectors to satisfy the minumum distance criterion.\nConsider reducing the value of ''mindist''.'));
    end

    p = ptmp(idx_accepted,:);

    [theta0,phi0,rtmp] = cart2sph(p(:,1),p(:,2),p(:,3));  
    clear rtmp

    % For saving the locations in the model structure
    opts.locations{1}{jj} = theta0;
    opts.locations{2}{jj} = phi0;

  else
    %- pick n random directions
    %p = normrnd(0,1,[prm(jj,1) 3]);
    p = randn([prm(jj,1) 3]);

    [theta0,phi0,rtmp] = cart2sph(p(:,1),p(:,2),p(:,3));  
    clear rtmp

    % For saving the locations in the model structure
    opts.locations{1}{jj} = theta0;
    opts.locations{2}{jj} = phi0;

  end

  %-------------------
  
  for ii = 1:prm(jj,1)
    deltatheta = abs(wrapAnglePi(Theta - theta0(ii)));
    
    %- https://en.wikipedia.org/wiki/Great-circle_distance:
    d = acos(sin(Phi).*sin(phi0(ii))+cos(Phi).*cos(phi0(ii)).*cos(deltatheta));
    
    idx = find(d<3.5*prm(jj,3));
    R(idx) = R(idx) + prm(jj,2)*exp(-d(idx).^2/(2*prm(jj,3)^2));
  end

end

vertices = objSph2XYZ(Theta,Phi,R);

% The field prm can be made an array.  If the structure sphere is
% passed to another objMakeSphere*-function, that function will add
% its parameters to that array.
if opts.new_model
  sphere.prm.prm = prm;
  sphere.prm.nbumptypes = nbumptypes;
  sphere.prm.nbumps = nbumps;
  sphere.prm.mindist = mindist;
  sphere.prm.mfilename = mfilename;
  sphere.prm.locations = opts.locations;
  sphere.normals = [];
else
  ii = length(sphere.prm)+1;
  sphere.prm(ii).prm = prm;
  sphere.prm(ii).nbumptypes = nbumptypes;
  sphere.prm(ii).nbumps = nbumps;
  sphere.prm(ii).mindist = mindist;
  sphere.prm(ii).mfilename = mfilename;
  sphere.prm(ii).locations = opts.locations;
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

%---------------------------------------------------------
% Functions...

function theta = wrapAnglePi(theta)

% WRAPANGLEPI
%
% Usage: theta = wrapAnglePi(theta)

% Toni Saarela, 2010
% 2010-xx-xx - ts - first version

theta = rem(theta,2*pi);
theta(theta>pi) = -2*pi+theta(theta>pi);
theta(theta<-pi) = 2*pi+theta(theta<-pi);
%theta(X==0 & Y==0) = 0;

