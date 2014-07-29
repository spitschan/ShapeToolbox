function sphere = objMakeSphereBumpy(sigma,a,nbumps,filename)

% OBJMAKESPHEREBUMPY
% 
% Usage:          objMakeSphereBumpy()
%                 objMakeSphereBumpy()
%        sphere = objMakeSphereBumpy()
%        sphere = objMakeSphereBumpy()
%

% Toni Saarela, 2014
% 2014-05-06 - ts - first version

% TODO
% - add a constraint on how close together the bumps can be?
% - return the locations of bumps
% - option to add noise to bump amplitudes
% - write help
% - option for several bump scales (sigmas)
% - option to make a crude low res version (129x65), and/or option
%   for user to define res
% - write more info to the obj-file an the returned structure

%--------------------------------------------

if ~nargin || isempty(sigma)
  sigma = pi/12;
end

if nargin<2 || isempty(a)
  a = .1;
end

if nargin<3 || isempty(nbumps)
  nbumps = 20;
end

lsigma = length(sigma);
lampl  = length(a);

nbumptypes = max([lsigma lampl]);

if ~any(lsigma==[1 nbumptypes])
  error('Mismatch in the sizes of sigma and amplitude vectors.');
end

if ~any(lampl==[1 nbumptypes])
  error('Mismatch in the sizes of sigma and amplitude vectors.');
end

% HERE
% check length of nbumps
% if sigma, a, nbumps is scalar, make it a vector of length nbumptypes
% make a long vector of all bumps

% Default file name
if nargin<4 || isempty(filename)
  filename = 'sphere.obj';
elseif isempty(regexp(filename,'\.obj$'))
  filename = [filename,'.obj'];
end

% Number of vertices in azimuth and elevation directions
m = 256 + 1; % 128 + 1; % 
n = 128 + 1; % 64 + 1;  % 

r = 1; % radius
theta = linspace(-pi,pi,m); % azimuth
phi = linspace(-pi/2,pi/2,n); % elevation

%--------------------------------------------


%--------------------------------------------

% pick n random directions
p = normrnd(0,1,[nbumps 3]);

[theta0,phi0,rtmp] = cart2sph(p(:,1),p(:,2),p(:,3));

clear rtmp

%-------------------

[Theta,Phi] = meshgrid(theta,phi);
Theta = Theta(:);
Phi = Phi(:);
R = ones(m*n,1);

for ii = 1:nbumps
  deltatheta = abs(wrapAnglePi(Theta - theta0(ii)));
  
  % https://en.wikipedia.org/wiki/Great-circle_distance:
  d = acos(sin(Phi).*sin(phi0(ii))+cos(Phi).*cos(phi0(ii)).*cos(deltatheta));

  idx = find(d<3.5*sigma);
  R(idx) = R(idx) + a*exp(-d(idx).^2/(2*sigma^2));
end

[x,y,z] = sph2cart(Theta,Phi,R);
vertices = [x y z];


%-------------------

% Face indices
for ii = 1:n-1
  for jj = 1:m-1
    %faces((ii-1)*(m-1)+jj,:) = [(ii-1)*m+jj ii*m+jj ii*m+jj+1 (ii-1)*m+jj+1];

    %faces((2*ii-2)*(m-1)+jj,:) = [(ii-1)*m+jj ii*m+jj ii*m+jj+1];
    %faces((2*ii-1)*(m-1)+jj,:) = [(ii-1)*m+jj ii*m+jj+1 (ii-1)*m+jj+1];

    faces((2*ii-2)*(m-1)+2*jj-1,:) = [(ii-1)*m+jj ii*m+jj ii*m+jj+1];
    faces((2*ii-2)*(m-1)+2*jj,:) = [(ii-1)*m+jj ii*m+jj+1 (ii-1)*m+jj+1];
    
  end
end

if nargout
  sphere.vertices = vertices;
  sphere.faces = faces;
end

% Write to file
fid = fopen(filename,'w');
fprintf(fid,'# %s\n',datestr(now));
#fprintf(fid,'# Modulation frequency (azimuth): %4.2f.',f(:,1));
#fprintf(fid,'\n# Modulation amplitude (azimuth): %4.2f.',a(:,1));
#if size(f,2)>1
#  fprintf(fid,'\n# Modulation frequency (elevation): %4.2f.',f(:,2));
#  fprintf(fid,'\n# Modulation amplitude (elevation): %4.2f.',a(:,2));
#end
fprintf(fid,'\n\n# Vertices:\n');
fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
fprintf(fid,'# End vertices\n\n# Faces:\n');
%fprintf(fid,'f %d %d %d %d\n',faces');
fprintf(fid,'f %d %d %d\n',faces');
fprintf(fid,'# End faces\n\n');
fclose(fid);




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

