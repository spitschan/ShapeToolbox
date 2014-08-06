function plane = objMakePlane(f,a,ph,varargin)

% OBJMAKEPLANE
% 
% Usage:          objMakePlane()
%                 objMakePlane(f,a,filename)
%        plane = objMakePlane(f,a,filename)
%
% f is the frequency of the modulation of the radius
% in cycles per plane; default = 8.  f can be a vector 
% of two to define modulations in both azimuth and 
% elevation, e.g., f = [8 4].
%
% a gives the amplitude of the modulation; default = .1.
% (Radius of the plane is 1.)
% 
% The model is saved in a text file.  The optional input 
% argument filename can be used to define the name of the
% file.  Default is 'plane.obj'.
%
% Any of the input arguments can be omitted or left empty.
%       
% If the output argument is specified, the vertices and faces 
% are returned in the structure plane.

% Toni Saarela, 2013
% 2013-10-09 - ts - first version
% 2014-07-31 - ts - an optional modulator can be used to modulate the
%                     carrier
%                   option to give grid size as input
%                   write more specs to obj file; return more specs
%                     with structure

% TODO
% WRITE HELP (the current one is for the sphere function)
% Add option for noise in the amplitude
% Add option for noise in the frequencies
% Option to define the orientation of the carrier
% Option to define the orientation of the modulator
% More error checking of parameters
% Initialize all matrices properly

%--------------------------------------------

% Carrier parameters
% Set default frequency if necessary
if ~nargin || isempty(f)
  f = 8;
end

% Default amplitude
if nargin<2 || isempty(a)
  a = .1 * ones(size(f));
end

% Default phase
if nargin<3 || isempty(ph)
  ph = zeros(size(f));
end

% Set the default modulation parameters to empty indicating no modulator; set default filename.
fmod  = [];
amod  = [];
phmod = [];
filename = 'plane.obj';

% Number of vertices in y and x directions
m = 256;
n = 256;

[modpar,par] = parseparams(varargin);

if ~isempty(modpar)
  if length(modpar)==1
    fmod = modpar{1};
  elseif length(modpar)==2
    fmod = modpar{1};
    amod = modpar{2};
  else
    fmod = modpar{1};
    amod = modpar{2};
    phmod = modpar{3};
  end
end

if ~isempty(par)
   ii = 1;
   while ii<=length(par)
     if ischar(par{ii})
       switch lower(par{ii})
         case 'npoints'
           if ii<length(par) && isnumeric(par{ii+1}) && length(par{ii+1}(:))==2
             ii = ii + 1;
             m = par{ii}(2);
             n = par{ii}(1);
           else
             error('No value or a bad value given for option ''npoints''.');
           end
         otherwise
           filename = par{ii};
       end
     end
     ii = ii + 1;
   end
end

% Set the default values for modulation amplitude and phase.
% Make these the same size as fmod
if ~isempty(fmod)
  if isempty(amod)
    amod = .1 * ones(size(fmod));
  end
  if isempty(phmod)
    phmod = zeros(size(fmod));
  end
end


  
% Add file name extension if needed
if isempty(regexp(filename,'\.obj$'))
  filename = [filename,'.obj'];
end

m = m + 1;
n = n + 1;

r = 1; % extent of the plane, goes from -r to r in both x and y
x = linspace(-r,r,m); % 
y = linspace(-r,r,n)'; % 

f = f/(2*r);
fmod = fmod/(2*r);

%--------------------------------------------

if any(a)<0
  error('Modulation amplitude has to be positive.');
end

%--------------------------------------------

vertices = zeros(m*n,3);

[X,Y] = meshgrid(x,y);

if ~isempty(fmod)
  modx = .5 * (1 + amod(1) * sin(2*pi*fmod(1)*x+phmod(1)));
  if length(fmod)>1
    mody = .5 * (1 + amod(2) * sin(2*pi*fmod(2)*y+phmod(2)));
  else
    mody = ones(size(y));
  end
else
  modx = ones(size(x));
  mody = ones(size(y));
end

for ii = 1:size(f,1)
  carrX(ii,:) = a(ii,1)*sin(2*pi*f(ii,1)*x+ph(ii,1));
  if size(f,2)>1
    carrY(:,ii) = a(ii,2)*sin(2*pi*f(ii,2)*y+ph(ii,2));
  end
end

if size(f,1)>1
  carrX = sum(carrX,1);
  if size(f,2)>1
    carrY = sum(carrY,2);
  end   
end

if size(f,2)>1
  Z = ones(m,1)*(modx.*carrX) + (mody.*carrY)*ones(1,n);
else  
  Z = ones(m,1)*(modx.*carrX);
end   

X = X'; X = X(:);
Y = Y'; Y = Y(:);
Z = Z'; Z = Z(:);

vertices = [X Y Z];

for ii = 1:m-1
  for jj = 1:n-1

    faces((2*ii-2)*(n-1)+2*jj-1,:) = [(ii-1)*n+jj ii*n+jj ii*n+jj+1];
    faces((2*ii-2)*(n-1)+2*jj,:) = [(ii-1)*n+jj ii*n+jj+1 (ii-1)*n+jj+1];

  end
end

if nargout
  plane.vertices = vertices;
  plane.faces = faces;
  plane.npointsx = m-1;
  plane.npointsy = n-1;
end

fid = fopen(filename,'w');
fprintf(fid,'# %s\n',datestr(now));
fprintf(fid,'# Created with function %s.\n',mfilename);
fprintf(fid,'# Modulation carrier frequency (x), cycles/plane: %4.2f.\n',2*r*f(:,1));
fprintf(fid,'# Modulation carrier amplitude (x): %4.2f.\n',a(:,1));
fprintf(fid,'# Modulation carrier phase (x): %4.2f.\n',ph(:,1));
if size(f,2)>1
  fprintf(fid,'# Modulation carrier frequency (y), cycles/plane: %4.2f.\n',2*r*f(:,2));
  fprintf(fid,'# Modulation carrier amplitude (y): %4.2f.\n',a(:,2));
  fprintf(fid,'# Modulation carrier phase (y): %4.2f.\n',ph(:,2));
end
if ~isempty(fmod)
  fprintf(fid,'# Modulator frequency (x), cycles/plane: %4.2f.\n',2*r*fmod(:,1));
  fprintf(fid,'# Modulator amplitude (x): %4.2f.\n',amod(:,1));
  fprintf(fid,'# Modulator phase (x): %4.2f.\n',phmod(:,1));
  if length(fmod)>1
    fprintf(fid,'# Modulator frequency (y), cycles/plane: %4.2f.\n',2*r*fmod(:,2));
    fprintf(fid,'# Modulator amplitude (y): %4.2f.\n',amod(:,2));
    fprintf(fid,'# Modulator phase (y): %4.2f.\n',phmod(:,2));
  end   
end
fprintf(fid,'\n\n# Vertices:\n');
fprintf(fid,'v %8.6f %8.6f %8.6f\n',vertices');
fprintf(fid,'# End vertices\n\n# Faces:\n');
fprintf(fid,'f %d %d %d\n',faces');
fprintf(fid,'# End faces\n\n');
fclose(fid);

