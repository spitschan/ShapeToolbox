function plane = objMakePlaneNoise(nprm,varargin)

%

% Toni Saarela, 2013
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
filename = 'planenoisy.obj';
use_rms = false;
mtlfilename = '';
mtlname = '';

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
      mprm = [mprm ones(nmcomp,1)*[.1 0 0 0]];
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

w = 1; % width of the plane
h = m/n * w;

x = linspace(-w/2,w/2,n); % 
y = linspace(-h/2,h/2,m)'; % 

%f = f/(2*r);

%--------------------------------------------

%if a<0
%  error('Modulation amplitude has to be positive.');
%end

%--------------------------------------------

vertices = zeros(m*n,3);

[X,Y] = meshgrid(x,y);
Y = flipud(Y);

%--------------------------------------

Z = _objMakeNoiseComponents(nprm,mprm,X,Y,use_rms);

X = X'; X = X(:);
Y = Y'; Y = Y(:);
Z = Z'; Z = Z(:);

vertices = [X Y Z];

if ~isempty(mtlfilename)
  U = (X-min(x))/(max(x)-min(x));
  V = (Y-min(y))/(max(y)-min(y));
  uvcoords = [U V];
end

faces = zeros((m-1)*(n-1)*2,3);

%tic
F = ([1 1]'*[1:n-1]);
F = F(:) * [1 1 1];
F(:,2) = F(:,2) + repmat([n n+1]',[n-1 1]);
F(:,3) = F(:,3) + repmat([n+1 1]',[n-1 1]);
for ii = 1:m-1
  faces((ii-1)*(n-1)*2+1:ii*(n-1)*2,:) = (ii-1)*n + F;
end
%toc

if nargout
  plane.vertices = vertices;
  plane.faces = faces;
  plane.npointsx = n;
  plane.npointsy = m;
end

fid = fopen(filename,'w');
fprintf(fid,'# %s\n',datestr(now));


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



