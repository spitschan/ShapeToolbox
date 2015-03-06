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
%   > objMakeSphereNoisy(@...,'npoints',[N M],...)
%
% To turn on the computation of surface normals (which will increase
% coputation time):
%   > objMakeSphereNoisy(...,'NORMALS',true,...)
%
% For texture mapping, see help to objMakeSphere or online help.
%
% Examples:
% TODO

% Toni Saarela, 2014
% 2014-10-15 - ts - first version written
% 2014-10-28 - ts - polishing; improvements to computation of
%                    faces, uv-coords, writing specs to obj-file
% 2014-11-10 - ts - vertex normals, fixed call to renamed
%                    objMakeNoiseComponents, renamed to
%                    objMakeSphereNoisy, some help
         

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
filename = 'spherenoisy.obj';
use_rms = false;
mtlfilename = '';
mtlname = '';
comp_normals = false;

% Number of vertices in elevation and azimuth directions, default values
m = 128;
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
      mprm = [mprm ones(nmcomp,1)*[1 0 0 0]];
    case 2
      mprm = [mprm zeros(nmcomp,3)];
    case 3
      mprm = [mprm zeros(nmcomp,2)];
    case 4
      mprm = [mprm zeros(nmcomp,1)];
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
         case 'normals'
           if ii<length(par) && (isnumeric(par{ii+1}) || islogical(par{ii+1}))
             ii = ii + 1;
             comp_normals = par{ii};
           else
             error('No value or a bad value given for option ''normals''.');
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

r = 1; % radius
theta = linspace(-pi,pi-2*pi/n,n); % azimuth
phi = linspace(-pi/2,pi/2,m)'; % elevation

%--------------------------------------------
% Vertices

[Theta,Phi] = meshgrid(theta,phi);

R = r + objMakeNoiseComponents(nprm,mprm,Theta,Phi,use_rms);

% Convert vertices to cartesian coordinates
[X,Y,Z] = sph2cart(Theta,Phi,R);

X = X'; X = X(:);
Y = Y'; Y = Y(:);
Z = Z'; Z = Z(:);

vertices = [X Y Z];

clear X Y Z

%--------------------------------------------
% Texture coordinates if material is defined
if ~isempty(mtlfilename)  
  u = linspace(0,1,n+1);
  v = linspace(0,1,m);
  [U,V] = meshgrid(u,v);
  U = U'; V = V';
  uvcoords = [U(:) V(:)];
  clear u v U V
end

%--------------------------------------------
% Faces, vertex indices
faces = zeros((m-1)*n*2,3);

F = ([1 1]'*[1:n]);
F = F(:) * [1 1 1];
F(:,2) = F(:,2) + [repmat([n+1 1]',[n-1 1]); [1 1-n]'];
F(:,3) = F(:,3) + [repmat([n n+1]',[n-1 1]); [n 1]'];
for ii = 1:m-1
  faces((ii-1)*n*2+1:ii*n*2,:) = (ii-1)*n + F;
end

% Faces, uv coordinate indices
if ~isempty(mtlfilename)
  facestxt = zeros((m-1)*n*2,3);
  n2 = n + 1;
  F = ([1 1]'*[1:n]);
  F = F(:) * [1 1 1];
  F(:,2) = reshape([1 1]'*[2:n2]+[1 0]'*n2*ones(1,n),[2*n 1]);
  F(:,3) = n2 + [1; reshape([1 1]'*[2:n],[2*(n-1) 1]); n2];
  for ii = 1:m-1
    facestxt((ii-1)*n*2+1:ii*n*2,:) = (ii-1)*n2 + F;
  end
end

if comp_normals
  % Surface normals for the faces
  fn = cross([vertices(faces(:,2),:)-vertices(faces(:,1),:)],...
             [vertices(faces(:,3),:)-vertices(faces(:,1),:)]);
  normals = zeros(m*n,3);
  
  % for ii = 1:m*n
  %  idx = any(faces==ii,2);
  %  vn = sum(fn(idx,:),1);
  %  normals(ii,:) = vn / sqrt(vn*vn');
  % end

  % Vertex normals
  nfaces = (m-1)*n*2;
  for ii = 1:nfaces
    normals(faces(ii,:),:) = normals(faces(ii,:),:) + [1 1 1]'*fn(ii,:);
  end
  normals = normals./sqrt(sum(normals.^2,2)*[1 1 1]);

  clear fn
end

%--------------------------------------------
% Output argument
if nargout
  sphere.vertices = vertices;
  sphere.faces = faces;
  if ~isempty(mtlfilename)
     sphere.uvcoords = uvcoords;
  end
  if comp_normals
     sphere.normals = normals;
  end
  sphere.npointsx = n;
  sphere.npointsy = m;
end

%--------------------------------------------
% Write to file

fid = fopen(filename,'w');
fprintf(fid,'# %s\n',datestr(now,31));
fprintf(fid,'# Created with function %s from ShapeToolbox.\n',mfilename);
fprintf(fid,'#\n# Number of vertices: %d.\n',size(vertices,1));
fprintf(fid,'# Number of faces: %d.\n',size(faces,1));
if isempty(mtlfilename)
  fprintf(fid,'# Texture (uv) coordinates defined: No.\n');
else
  fprintf(fid,'# Texture (uv) coordinates defined: Yes.\n');
end
if comp_normals
  fprintf(fid,'# Vertex normals included: Yes.\n');
else
  fprintf(fid,'# Vertex normals included: No.\n');
end

fprintf(fid,'#\n# Noise carrier parameters (each row is one component):\n');
fprintf(fid,'#  Frequency | FWHH | Angle | FWHH | Amplitude | Group\n');
for ii = 1:nncomp
  fprintf(fid,'#  %9.2f   %4.2f   %5.2f   %4.2f   %9.2f       %d\n',nprm(ii,:));
end

if ~isempty(mprm)
  fprintf(fid,'#\n# Modulator parameters (each row is one component):\n');
  fprintf(fid,'#  Frequency | Amplitude | Phase | Angle | Group\n');
  for ii = 1:nmcomp
    fprintf(fid,'#     %6.2f      %6.2f  %6.2f  %6.2f       %d\n',mprm(ii,:));
  end
end

fprintf(fid,'#\n# Angle (orientation) and its bandwidth are in radians above.\n');

if isempty(mtlfilename)
  fprintf(fid,'\n\n# Vertices:\n');
  fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
  fprintf(fid,'# End vertices\n');
  if comp_normals
    fprintf(fid,'\n# Normals:\n');
    fprintf(fid,'vn %8.6f %8.6f %8.6f\n',normals');
    fprintf(fid,'# End normals\n');
    fprintf(fid,'\n# Faces:\n');
    fprintf(fid,'f %d//%d %d//%d %d//%d\n',[faces(:,1) faces(:,1) faces(:,2) faces(:,2) faces(:,3) faces(:,3)]');
  else
    fprintf(fid,'\n# Faces:\n');
    fprintf(fid,'f %d %d %d\n',faces');    
  end
  fprintf(fid,'# End faces\n');
else
  fprintf(fid,'\nmtllib %s\nusemtl %s\n',mtlfilename,mtlname);
  fprintf(fid,'\n# Vertices:\n');
  fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
  fprintf(fid,'# End vertices\n\n# Texture coordinates:\n');
  fprintf(fid,'vt %8.6f %8.6f\n',uvcoords');
  fprintf(fid,'# End texture coordinates\n');
  if comp_normals
    fprintf(fid,'\n# Normals:\n');
    fprintf(fid,'vn %8.6f %8.6f %8.6f\n',normals');
    fprintf(fid,'# End normals\n');
    fprintf(fid,'\n# Faces:\n');
    fprintf(fid,'f %d/%d/%d %d/%d/%d %d/%d/%d\n',...
            [faces(:,1) facestxt(:,1) faces(:,1)...
             faces(:,2) facestxt(:,2) faces(:,2)...
             faces(:,3) facestxt(:,3) faces(:,3)]');
  else
    fprintf(fid,'\n# Faces:\n');
    fprintf(fid,'f %d/%d %d/%d %d/%d\n',[faces(:,1) facestxt(:,1) faces(:,2) facestxt(:,2) faces(:,3) facestxt(:,3)]');
  end
  fprintf(fid,'# End faces\n');
end
fclose(fid);

