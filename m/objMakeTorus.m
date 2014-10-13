function torus = objMakeTorus(R,rprm,r,sprm,filename)

% OBJMAKETORUS
%
% 
% R     - radius of the torus, i.e., the distance from origin to the
%         center of the "tube"
% rprm  - modulation parameters for the radius of the torus:
%         [frequency amplitude phase], where
%          frequecy is in number of cycles per 2*pi
%          amplitude is in units of the radius
%          phase is in radians
% r     - radius of the "tube"
% sprm  - modulation parameters for the radius of the tube:
%         [frequency amplitude phase direction], where
%          frequecy  : in number of cycles per 2*pi
%          amplitude : in units of the radius
%          phase     : in radians
%          direction : see below
%
% The direction parameter for the modulation of the "tube" (see
% above) defines the direction of modulation, but I'm too tired to
% figure out how to explain this to you.  The value of the direction
% parameter is 0 or 1.

% Toni Saarela, 2014
% 2014-08-08 - ts - first, rudimentary version
% 2014-10-07 - ts - new format of parameter vectors
%                   renamed some variables, added input arguments
%                   allow several component modulations
% 2014-10-08 - ts - improved the computation of the faces ("wraps
%                   around" in both directions now)

% TODO
% Set input arguments, optional arguments, default values
% Include carriers and modulators?
% Write stimulus paremeters into the obj-file
% Write help!

%--------------------------------------------

% Radius
if ~nargin || isempty(R)
  R = 1;
end

% Radius modulation parameters
if nargin<2 || isempty(rprm)
  rprm = [8 .1 0];
end

% Radius 
if nargin<3 || isempty(r)
  r = 0.2;
end

% Surface modulation parameters
if nargin<4 || isempty(sprm)
  sprm = [16 .05 0 1];
end
sprm(:,end) = logical(sprm(:,end));

if nargin<5 || isempty(filename)
  filename = 'torus.obj';
end

% Number of vertices in azimuth and elevation directions
m = 256; 
n = 256;

%r = 1; % radius
theta = linspace(-pi,pi-2*pi/n,n); % azimuth
phi = linspace(-pi,pi-2*pi/m,m); % 

%--------------------------------------------

[Theta,Phi] = meshgrid(theta,phi);
Theta = Theta'; Theta = Theta(:);
Phi   = Phi';   Phi   = Phi(:);

Rmod = zeros(size(Theta));
for ii = 1:size(rprm,1)
  Rmod = Rmod + rprm(ii,2) * sin(rprm(ii,1)*Theta + rprm(ii,3));
end
rmod = zeros(size(Phi));
for ii = 1:size(sprm,1)
  rmod = rmod + ...
         sprm(ii,2) * ...
         sin((1-sprm(ii,4))*sprm(ii,1)*Phi + sprm(ii,4)*sprm(ii,1)*Theta + sprm(ii,3));
end

R = R + Rmod;
r = r + rmod;

X = (R + r.*cos(Phi)).*cos(Theta);
Y = (R + r.*cos(Phi)).*sin(Theta);
Z = r.*sin(Phi);

vertices = [X Y Z];

faces = zeros(m*n*2,3);

% Face indices.
% Good luck figuring out what goes on below.  This was the fastest way
% I came up with so far and commenting is for losers.
%tic
F = ([1 1]'*[1:n]);
F = F(:) * [1 1 1];
F(:,2) = F(:,2) + [repmat([n n+1]',[n-1 1]); [n 1]'];
F(:,3) = F(:,3) + [repmat([n+1 1]',[n-1 1]); [1 1-n]'];
for ii = 1:m-1
  faces((ii-1)*n*2+1:ii*n*2,:) = (ii-1)*n + F;
end
F(:,1) = (m-1)*n+F(:,1);
F(:,2) = [reshape([1:n-1;(m-1)*n+(2:n)],[2*(n-1),1]); [n 1]'];
F(:,3) = [reshape([(m-1)*n+(2:n);2:n],[2*(n-1),1]); [1 (m-1)*n+1]'];
faces((m-1)*n*2+1:m*n*2,:) = F;
%toc

if nargout
  torus.vertices = vertices;
  torus.faces = faces;
  torus.npointsx = n;
  torus.npointsy = m;
end

% Write to file
fid = fopen(filename,'w');
fprintf(fid,'# %s\n',datestr(now));
fprintf(fid,'# Created with function %s.\n',mfilename);
fprintf(fid,'#\n# Number of vertices: %d.\n',size(vertices,1));
fprintf(fid,'# Number of faces: %d.\n',size(faces,1));
## fprintf(fid,'#\n# Modulation carrier parameters (each row is one component):\n');
## fprintf(fid,'#  Frequency | Amplitude | Phase | Direction*\n');
## for ii = 1:nccomp
##   fprintf(fid,'#  %4.2f        %4.2f        %4.2f    %d\n',cprm(ii,:));
## end
## fprintf(fid,'# *Direction of modulation, 0 indicates azimuth, 1 elevation direction.\n');
## if ~isempty(mprm)
##   fprintf(fid,'#\n# Modulator parameters (each row is one component):\n');
##   fprintf(fid,'#  Frequency | Amplitude | Phase | Direction*\n');
##   for ii = 1:nmcomp
##     fprintf(fid,'#  %4.2f        %4.2f        %4.2f    %d\n',mprm(ii,:));
##   end
##   fprintf(fid,'# *Direction of modulation, 0 indicates azimuth, 1 elevation direction.\n');
## end
fprintf(fid,'\n\n# Vertices:\n');
fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
fprintf(fid,'# End vertices\n\n# Faces:\n');
fprintf(fid,'f %d %d %d\n',faces');
fprintf(fid,'# End faces\n\n');
fclose(fid);
