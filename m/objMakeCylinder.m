function cylinder = objMakeCylinder(cprm,varargin)

% OBJMAKECYLINDER 
%

% Toni Saarela, 2014
% 2014-10-10 - ts - first version
% 2014-10-19 - ts - switched to using an external function to compute
%                   the modulation
% 2014-10-20 - ts - added texture mapping

% TODO
% Add an option to define whether modulations are done in angle
% (theta) units or distance units.
% Add modulators
% More and better parsing of input arguments

if ~nargin || isempty(cprm)
  cprm = [8 .1 0 0 0];
end

[nccomp,ncol] = size(cprm);

switch ncol
  case 1
    cprm = [cprm ones(nccomp,1)*[.1 0 0 0]];
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
filename = 'cylinder.obj';
mtlfilename = '';
mtlname = '';

% Number of vertices in azimuth and elevation directions
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

%cprm(:,1) = cprm(:,1)*(2*pi);
r = 1; % radius
h = 2*pi*r; % height
theta = linspace(-pi,pi-2*pi/n,n); % azimuth
y = linspace(-h/2,h/2,m); % 

%--------------------------------------------

[Theta,Y] = meshgrid(theta,y);
Theta = Theta'; Theta = Theta(:);
Y = Y'; Y = Y(:);

R = r + _objMakeSineComponents(cprm,mprm,Theta,Y);;

% Convert vertices to cartesian coordinates
X = R .* cos(Theta);
Z = -R .* sin(Theta);

vertices = [X Y Z];

if ~isempty(mtlfilename)
  %Phi = Phi';
  %Theta = Theta';
  U = (Theta-min(theta))/(max(theta)-min(theta));
  V = (Y-min(y))/(max(y)-min(y));
  uvcoords = [U V];
end

faces = zeros((m-1)*n*2,3);

% Face indices

%tic
F = ([1 1]'*[1:n]);
F = F(:) * [1 1 1];
F(:,2) = F(:,2) + [repmat([n n+1]',[n-1 1]); [n 1]'];
F(:,3) = F(:,3) + [repmat([n+1 1]',[n-1 1]); [1 1-n]'];
for ii = 1:m-1
  faces((ii-1)*n*2+1:ii*n*2,:) = (ii-1)*n + F;
end
%toc

if nargout
  cylinder.vertices = vertices;
  cylinder.faces = faces;
  cylinder.npointsx = n;
  cylinder.npointsy = m;
end

# Write to file
fid = fopen(filename,'w');
fprintf(fid,'# %s\n',datestr(now));
fprintf(fid,'# Created with function %s.\n',mfilename);
fprintf(fid,'#\n# Number of vertices: %d.\n',size(vertices,1));
fprintf(fid,'# Number of faces: %d.\n',size(faces,1));
fprintf(fid,'#\n# Modulation carrier parameters (each row is one component):\n');
fprintf(fid,'#  Frequency | Amplitude | Phase | Orientation\n');
for ii = 1:nccomp
  fprintf(fid,'#  %4.2f        %4.2f        %4.2f    %d\n',cprm(ii,:));
end
% if ~isempty(mprm)
%   fprintf(fid,'#\n# Modulator parameters (each row is one component):\n');
%   fprintf(fid,'#  Frequency | Amplitude | Phase | Orientation\n');
%   for ii = 1:nmcomp
%     fprintf(fid,'#  %4.2f        %4.2f        %4.2f    %d\n',mprm(ii,:));
%   end
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

