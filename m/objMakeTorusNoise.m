function torus = objMakeTorusNoise(nprm,varargin)

% OBJMAKETORUSNOISE
%
% Usage: torus = objMakeTorusNoise(nprm,...)


% Toni Saarela, 2014
% 2014-10-16 - ts - first version written
% 2014-10-19 - ts - added an option to set tube radius
%                   renamed input option for torus radius parameters
% 2015-03-05 - ts - updated function call to objMakeNoiseComponents

% TODO
% Write stimulus paremeters into the obj-file
% WRITE HELP!  

%--------------------------------------------
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

% Set the default modulation parameters to empty indicating no modulator; set default filename.
mprm  = [];
filename = 'torusnoisy.obj';
use_rms = false;
mtlfilename = '';
mtlname = '';
r = 0.4;
R = 1;
rprm = []; % rprm = [0 0 0];

% Number of vertices in y and x directions, default values
m = 256;
n = 256;

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
         case 'rms'
           use_rms = true;
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

theta = linspace(-pi,pi-2*pi/n,n); % azimuth
phi = linspace(-pi,pi-2*pi/m,m); % 

%--------------------------------------------

%--------------------------------------------
%--------------------------------------------
%fprintf('1\n');
[Theta,Phi] = meshgrid(theta,phi);
%Theta = Theta'; Theta = Theta(:);
%Phi   = Phi';   Phi   = Phi(:);
%fprintf('2\n');

Rmod = zeros(size(Theta));
if ~isempty(rprm)
  for ii = 1:size(rprm,1)
    Rmod = Rmod + rprm(ii,2) * sin(rprm(ii,1)*Theta + rprm(ii,3));
  end
  R = R + Rmod;
end
%fprintf('3\n');
%keyboard
r = r + objMakeNoiseComponents(nprm,mprm,Theta,Phi,use_rms);
%keyboard
%fprintf('4\n');

Theta = Theta'; Theta = Theta(:);
Phi   = Phi';   Phi   = Phi(:);
R = R'; R = R(:);
r = r'; r = r(:);

X = (R + r.*cos(Phi)).*cos(Theta);
Y = (R + r.*cos(Phi)).*sin(Theta);
Z = r.*sin(Phi);

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
