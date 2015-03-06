function torus = objMakeTorus(cprm,varargin)

% OBJMAKETORUS
%
% 
% r     - radius of the "tube"
% sprm  - modulation parameters for the radius of the tube:
%         [frequency amplitude phase direction], where
%          frequecy  : in number of cycles per 2*pi
%          amplitude : in units of the radius
%          phase     : in radians
%          direction : see below
% R     - radius of the torus, i.e., the distance from origin to the
%         center of the "tube"
% rprm  - modulation parameters for the radius of the torus:
%         [frequency amplitude phase], where
%          frequecy is in number of cycles per 2*pi
%          amplitude is in units of the radius
%          phase is in radians
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
% 2014-10-15 - ts - changed the order of input arguments
% 2014-10-16 - ts - changed input arguments again, added some parsing
%                    of them
%                   uses a separate function now to compute modulation
%                    components
%                   added texture mapping
% 2014-10-19 - ts - added tube radius as optional input arg,
%                   better input argument parsing
%                   renamed input option for torus radius parameters
% 2015-03-05 - ts - updated function call to objMakeSineComponents

% TODO
% Set input arguments, optional arguments, default values
% Include carriers and modulators?
% Write stimulus paremeters into the obj-file
% Write help!  UPDATE HELP

%--------------------------------------------

% Carrier parameters

% Set default frequency, amplitude, phase, "orientation"  and component group id

if ~nargin || isempty(cprm)
  cprm = [8 .05 0 0 0];
end

[nccomp,ncol] = size(cprm);

switch ncol
  case 1
    cprm = [cprm ones(nccomp,1)*[.05 0 0 0]];
  case 2
    cprm = [cprm zeros(nccomp,3)];
  case 3
    cprm = [cprm zeros(nccomp,2)];
  case 4
    cprm = [cprm zeros(nccomp,1)];
end

cprm(:,3:4) = pi * cprm(:,3:4)/180;

% Set the default modulation parameters to empty indicating no modulator; set default filename.
mprm  = [];
filename = 'torus.obj';
mtlfilename = '';
mtlname = '';
r = 0.4;
R = 1;
rprm = []; % rprm = [0 0 0];

% Number of vertices in azimuth and elevation directions, default values
n = 256;
m = 256;

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
      mprm = [mprm ones(nccomp,1)*[1 0 0 0]];
    case 2
      mprm = [mprm zeros(nccomp,3)];
    case 3
      mprm = [mprm zeros(nccomp,2)];
    case 4
      mprm = [mprm zeros(nccomp,1)];
  end
  mprm(:,3:4) = pi * mprm(:,3:4)/180;
end

% Check other optional input arguments
if ~isempty(par)
   ii = 1;
   while ii<=length(par)
     if ischar(par{ii})
       switch lower(par{ii})
         case 'npoints'
           if ii<length(par) && isnumeric(par{ii+1}) && length(par{ii+1}(:))==2
             ii = ii + 1;
             m = par{ii}(1);
             n = par{ii}(2);
           else
             error('No value or a bad value given for option ''npoints''.');
           end
         case 'tube_radius'
           if ii<length(par) && isnumeric(par{ii+1})
             ii = ii + 1;
             r = par{ii};
           else
             error('No value or a bad value given for option ''tube_radius''.');
           end              
         case {'rprm','radius_prm'}
           if ii<length(par) && isnumeric(par{ii+1})
             ii = ii + 1;
             rprm = par{ii};
           else
             error('No value or a bad value given for option ''radius''.');
           end
         case 'material'
           if ii<length(par) && iscell(par{ii+1}) && length(par{ii+1})==2
             ii = ii + 1;
             mtlfilename = par{ii}{1};
             mtlname = par{ii}{2};
           else
             error('No value or a bad value given for option ''material''.');
           end              
         otherwise
           filename = par{ii};
       end
     end
     ii = ii + 1;
   end
end
  
% Add file name extension if needed
if isempty(regexp(filename,'\.obj$'))
  filename = [filename,'.obj'];
end

% m = m + 1;
% n = n + 1;

theta = linspace(-pi,pi-2*pi/n,n); % azimuth
phi = linspace(-pi,pi-2*pi/m,m); % 

%--------------------------------------------
%--------------------------------------------

[Theta,Phi] = meshgrid(theta,phi);
%Theta = Theta'; Theta = Theta(:);
%Phi   = Phi';   Phi   = Phi(:);

Rmod = zeros(size(Theta));
if ~isempty(rprm)
  for ii = 1:size(rprm,1)
    Rmod = Rmod + rprm(ii,2) * sin(rprm(ii,1)*Theta + rprm(ii,3));
  end
  R = R + Rmod;
end

r = r + objMakeSineComponents(cprm,mprm,Theta,Phi);

Theta = Theta'; Theta = Theta(:);
Phi   = Phi';   Phi   = Phi(:);
R = R'; R = R(:);
r = r'; r = r(:);

X = (R + r.*cos(Phi)).*cos(Theta);
Y = (R + r.*cos(Phi)).*sin(Theta);
Z = r.*sin(Phi);

%X = (R + r.*cos(Phi)).*cos(Theta);
%Y = (R + r.*cos(Phi)).*sin(Theta);
%Z = r.*sin(Phi);

%X = X'; X = X(:);
%Y = Y'; Y = Y(:);
%Z = Z'; Z = Z(:);

vertices = [X Y Z];

if ~isempty(mtlfilename)
  Phi = Phi';
  Theta = Theta';
  U = (Theta(:)-min(theta))/(max(theta)-min(theta));
  V = (Phi(:)-min(phi))/(max(phi)-min(phi));
  uvcoords = [U V];
end

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
F(:,2) = [1; reshape([1 1]'*[2:n],[2*(n-1) 1]); 1];
F(:,3) = [reshape([2:n; ((m-1)*n)+[2:n]],[2*(n-1) 1]); [1 (m-1)*n+1]'];
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
% fprintf(fid,'#\n# Modulation carrier parameters (each row is one component):\n');
% fprintf(fid,'#  Frequency | Amplitude | Phase | Direction*\n');
% for ii = 1:nccomp
%   fprintf(fid,'#  %4.2f        %4.2f        %4.2f    %d\n',cprm(ii,:));
% end
% fprintf(fid,'# *Direction of modulation, 0 indicates azimuth, 1 elevation direction.\n');
% if ~isempty(mprm)
%   fprintf(fid,'#\n# Modulator parameters (each row is one component):\n');
%   fprintf(fid,'#  Frequency | Amplitude | Phase | Direction*\n');
%   for ii = 1:nmcomp
%     fprintf(fid,'#  %4.2f        %4.2f        %4.2f    %d\n',mprm(ii,:));
%   end
%   fprintf(fid,'# *Direction of modulation, 0 indicates azimuth, 1 elevation direction.\n');
% end

if isempty(mtlfilename)
  fprintf(fid,'\n\n# Vertices:\n');
  fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
  fprintf(fid,'# End vertices\n\n# Faces:\n');
  fprintf(fid,'f %d %d %d\n',faces');
  fprintf(fid,'# End faces\n\n');
else
  fprintf(fid,'\n\nmtllib %s\nusemtl %s\n\n',mtlfilename,mtlname);
  fprintf(fid,'\n\n# Vertices:\n');
  fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
  fprintf(fid,'# End vertices\n\n# Texture coordinates:\n');
  fprintf(fid,'vt %8.6f %8.6f\n',uvcoords');
  fprintf(fid,'# End texture coordinates\n\n# Faces:\n');
  fprintf(fid,'f %d/%d %d/%d %d/%d\n',expmat(faces,[1,2])');
  fprintf(fid,'# End faces\n\n');
end
fclose(fid);

