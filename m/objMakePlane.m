function plane = objMakePlane(cprm,varargin)

% OBJMAKEPLANE
% 
% Usage:          objMakePlane()
%                 objMakePlane(cpar,[options])
%                 objMakePlane(cpar,mpar,[options])
%        OR:
%                 plane = objMakePlane(...)
%
% A 3D model of a plane perturbed by sinusoidal modulation(s).  The 
% function writes the vertices and faces into a Wavefront OBJ-file
% and optionally returns them as a structure.
%
% Without any input arguments, makes the default plane with a
% modulation along the x-direction at frequency of 8 cycle/object,
% amplitude of 0.1, and phase of 0.
%
% The width of the plane object is 1.  The modulation of the plane is
% in the same units (e.g., amplitude of 0.1 results in the values in
% the z-direction ranging from -0.1 to 0.1, or 10% of the width of the
% plane).  
%
% The input argument cpar defines the parameters for the modulation.
% The parameters are the frequency, amplitude, phase, and
% orientation/angle:
%   CPAR = [FREQ AMPL PH ANGLE]
%
% The frequency for modulation is in cycle/plane object.  Both the 
% x- and y-coordinates have zero in the middle of the plane.  All
% modulations are sine modulations (phase 0 is the sine phase).  The
% orientation of the modulation is given in degrees, 0 is vertical.
%
% It is possible to define several component modulations.  These
% modulations are added together.  Several components are defined in
% different rows of cpar:
%   CPAR = [FREQ1 AMPL1 PH1 ANGLE1
%           FREQ2 AMPL2 PH2 ANGLE2
%           ...
%           FREQN AMPLN PHN ANGLEN]
%
% Default values for amplitude, phase, and orientation are .1, 0, and 0,
% respectively.  If the number of columns in cpar is less that four,
% the default values will be filled in.
%
% To produce more complex modulations, separate carrier and
% modulator components can be defined with the input argument mpar.
% The carrier components are defined exactly as above.  The
% modulator modulates the amplitude of the carrier.  The parameters
% of the modulator(s) are given in the input argument mpar.  The
% format is the same as in defining the carrier components
% in cpar.  If several modulator components are defined, they are
% added together.  Typically, you will probably want to use a very
% simple (usually a single-component) modulator. Default values are 1 
% for amplitude, 0 for phase and orientation.
% 
% You can also define group indices to carriers and modulators
% to specify which modulators modulate which carriers.  See details in
% the online help on in the help for objMakeSphere.
%
% Optional input arguments can be given to define the number of vertex
% points or the filename for saving the object.
%
% To define the number of vertices in the model, use the option
% 'npoints' followed by a vector of length giving the number of points
% in the y- and x-directions:
%  > objMakePlane(...,'npoints',[m n],...)
% Default numbers are m=256 (y-direction), n=256 (x-direction).
%
% The model is saved in a text file.  The default name of the output
% text file is 'plane.obj'.  A different filename can be gives as a
% string:
%   > objMakePlane(...,'myfilename',...)
% If the custom filename does not have an obj-extension, it will be
% added.
%
% If the output argument is specified, the vertices and faces plus
% some other information are returned in the fields of the output 
% structure.
%
% Examples:
% > objMakePlane()             % Default, 8 cycles in the x-direction
% > objMakePlane([6 .2])       % Six modulation cycles, amplitude 0.2
%
% Modulation components in the two directions (added), save to plaid.obj:
% > objMakePlane([8 .2 0 0; 4 .1 0 90],'plaid.obj') 
% (This will produce a kind of "plaid" pattern.)
%
% Same as above, but use fewer points for a quicker testing (will not
% look good when rendered, but might be useful for experimenting):
% > objMakePlane([8 .2 0 0; 4 .1 0 90],'npoints',[128 128],'plaid.obj') 
%
% Makes a smooth bump:
% > objMakePlane([1 .1 pi/2 0; 1 .1 pi/2 90])    
%
% Two modulation components in the same (azimuth) direction,
% frequencies 4 and 12:
% > objMakePlane([4 .15 0 0; 12 .15 0 0]) 
%
% A vertical carrier with 8 cycles, its amplitude modulated by a
% 2-cycle, vertical modulator, also return the model in the structure
% pln:
% > pln = objMakePlane([8 .2 0 0],[2 1 0 0]) 
%

% Toni Saarela, 2013
% 2013-10-09 - ts - first version
% 2014-07-31 - ts - an optional modulator can be used to modulate the
%                     carrier
%                   option to give grid size as input
%                   write more specs to obj file; return more specs
%                     with structure
% 2014-08-07 - ts - simplified the computation of carriers and
%                    modulators a little, new format for giving the modulation
%                    parameters; better initialization of matrices;
%                    significantly speeded up the computation of
%                    faces; carriers and modulators can have arbitrary
%                    orientations; wrote help
% 2014-10-11 - ts - both phase and orientation are given in degrees now
% 2014-10-11 - ts - now possible to use the modulators to modulate
%                    between two (or more) carriers
% 2014-10-12 - ts - changed default value for modulator amplitude (1)
%                   fixed a bug affecting the case when there are
%                   carriers AND modulators only in group 0
% 2014-10-14 - ts - added an option to compute texture coordinates and
%                    include a mtl file reference
% 2014-10-28 - ts - minor changes
% 2014-11-22 - ts - fixed call to newly named objMakeSineComponents
% 2015-03-05 - ts - fixed computation of faces (they were defined CW,
%                    should be CCW.  oops.)
%                   added computation of vertex normals
%                   improved writing of specs in comments
% 2015-03-06 - ts - updates to help

% TODO
% Add option for noise in the amplitude
% Add option for noise in the frequencies
% More error checking of parameters
% Should the x and y values go from -w/2 to w/2 or from -w/2 to
%   w/2-w/npoints?
% Add an option to define the size of plane
% Update help, add the modulation between carriers thing

%--------------------------------------------

% Carrier parameters

% Set default frequency, amplitude, phase, orientation and component group id

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

cprm(:,1) = cprm(:,1)*(2*pi);
cprm(:,3:4) = pi * cprm(:,3:4)/180;

% Set the default modulation parameters to empty indicating no modulator; set default filename.
mprm  = [];
filename = 'plane.obj';
mtlfilename = '';
mtlname = '';
comp_normals = false;

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
      mprm = [mprm ones(nmcomp,1)*[1 0 0 0]];
    case 2
      mprm = [mprm zeros(nmcomp,3)];
    case 3
      mprm = [mprm zeros(nmcomp,2)];
    case 4
      mprm = [mprm zeros(nmcomp,1)];
  end
  mprm(:,1) = mprm(:,1)*(2*pi);
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

% m = m + 1;
% n = n + 1;

w = 1; % width of the plane
h = m/n * w;

x = linspace(-w/2,w/2,n); % 
y = linspace(-h/2,h/2,m)'; % 

%--------------------------------------------
%--------------------------------------------

vertices = zeros(m*n,3);

[X,Y] = meshgrid(x,y);
%Y = flipud(Y);

Z = objMakeSineComponents(cprm,mprm,X,Y);

X = X'; X = X(:);
Y = Y'; Y = Y(:);
Z = Z'; Z = Z(:);

vertices = [X Y Z];
clear X Y Z

%--------------------------------------------
% Texture coordinates if material is defined
if ~isempty(mtlfilename)
  U = (X-min(x))/(max(x)-min(x));
  V = (Y-min(y))/(max(y)-min(y));
  uvcoords = [U V];
end

%--------------------------------------------
% Faces, vertex indices
faces = zeros((m-1)*(n-1)*2,3);

F(:,1) = [[1 1]'*[1:n-1]](:);
F(:,2) = [n+2:2*n; 2:n](:);
F(:,3) = [[[1 1]' * [n+1:2*n]](:)](2:end-1);
for ii = 1:m-1
  faces((ii-1)*(n-1)*2+1:ii*(n-1)*2,:) = (ii-1)*n + F;
end

%--------------------------------------------
% Vertex normals
if comp_normals
  % Surface normals for the faces
  fn = cross([vertices(faces(:,2),:)-vertices(faces(:,1),:)],...
             [vertices(faces(:,3),:)-vertices(faces(:,1),:)]);

  % Vertex normals
  normals = zeros(m*n,3);
  
  % Loop through vertices, slow
  % for ii = 1:m*n
  %  idx = any(faces==ii,2);
  %  vn = sum(fn(idx,:),1);
  %  normals(ii,:) = vn / sqrt(vn*vn');
  % end

  % Loop through faces, somewhat faster
  nfaces = (m-1)*(n-1)*2;
  for ii = 1:nfaces
    normals(faces(ii,:),:) = normals(faces(ii,:),:) + [1 1 1]'*fn(ii,:);
  end
  normals = normals./sqrt(sum(normals.^2,2)*[1 1 1]);

  clear fn
end

%--------------------------------------------
% Output argument
if nargout
  plane.vertices = vertices;
  plane.faces = faces;
  if ~isempty(mtlfilename)
     plane.uvcoords = uvcoords;
  end
  if comp_normals
     plane.normals = normals;
  end
  plane.npointsx = n;
  plane.npointsy = m;
end

%--------------------------------------------
% Write to file

% Convert frequencies back to cycles/plane
cprm(:,1) = cprm(:,1)/(2*pi);
if ~isempty(mprm)
  mprm(:,1) = mprm(:,1)/(2*pi);
end

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

fprintf(fid,'#\n# Modulation carrier parameters (each row is one component):\n');
fprintf(fid,'#  Frequency | Amplitude | Phase | Angle | Group\n');
for ii = 1:nccomp
  fprintf(fid,'#     %6.2f      %6.2f  %6.2f  %6.2f       %d\n',cprm(ii,:));
end

if ~isempty(mprm)
  fprintf(fid,'#\n# Modulator parameters (each row is one component):\n');
  fprintf(fid,'#  Frequency | Amplitude | Phase | Angle | Group\n');
  for ii = 1:nmcomp
    fprintf(fid,'#     %6.2f      %6.2f  %6.2f  %6.2f       %d\n',mprm(ii,:));
  end
end

fprintf(fid,'#\n# Phase and angle are in radians above.\n');

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
            [faces(:,1) faces(:,1) faces(:,1)...
             faces(:,2) faces(:,2) faces(:,2)...
             faces(:,3) faces(:,3) faces(:,3)]');
  else
    fprintf(fid,'\n# Faces:\n');
    fprintf(fid,'f %d/%d %d/%d %d/%d\n',[faces(:,1) faces(:,1) faces(:,2) faces(:,2) faces(:,3) faces(:,3)]');
  end
  fprintf(fid,'# End faces\n');
end
fclose(fid);



